#!/bin/bash
#
# This bash script is used to generate automatically the CaribouDuet configuration files and macros
# 
# Supported OS: Windows 10, Linux64 bit
#
# Change log:
# 12 Jan 2021, wschadow, initial version
# 14 Jan 2021, wschadow, added generation of filament files
# 17 Jan 2021, wschadow, simplified OUTPUT_PATHs
# 17 Jan 2021, wschadow, added generation of preheat macros
#
#
# Copyright Caribou Research & Development 2021. Licensed under GPL3.
# Source code and release notes are available on github: https://github.com/Caribou3d/CaribouDuet-Configuration-and-Macros
#

#### Start check if OSTYPE is supported
OS_FOUND=$( command -v uname)

case $( "${OS_FOUND}" | tr '[:upper:]' '[:lower:]') in
  linux*)
    TARGET_OS="linux"
   ;;
  msys*|cygwin*|mingw*)
    # or possible 'bash on windows'
    TARGET_OS='windows'
   ;;
  nt|win*)
    TARGET_OS='windows'
    ;;
  *)
    TARGET_OS='unknown'
    ;;
esac
# Windows
if [ $TARGET_OS == "windows" ]; then
	if [ $(uname -m) == "x86_64" ]; then
		echo "$(tput setaf 2)Windows 64-bit found$(tput sgr0)"
		Processor="64"
	elif [ $(uname -m) == "i386" ]; then
		echo "$(tput setaf 2)Windows 32-bit found$(tput sgr0)"
		Processor="32"
	fi
# Linux
elif [ $TARGET_OS == "linux" ]; then
	if [ $(uname -m) == "x86_64" ]; then
		echo "$(tput setaf 2)Linux 64-bit found$(tput sgr0)"
		Processor="64"
	elif [[ $(uname -m) == "i386" || $(uname -m) == "i686" ]]; then
		echo "$(tput setaf 2)Linux 32-bit found$(tput sgr0)"
		Processor="32"
	elif [ $(uname -m) == "aarch64" ]; then
		echo "$(tput setaf 2)Linux aarch64 bit found$(tput sgr0)"
		Processor="aarch64"
	fi
else
	echo "$(tput setaf 1)This script doesn't support your Operating system!"
	echo "Please use Linux 64-bit or Windows 10 64-bit with Linux subsystem / git-bash"
	echo "Read the notes of build.sh$(tput sgr0)"
	exit 1
fi
#sleep 2
#### End check if OSTYPE is supported

# Check for zip
if ! type zip > /dev/null; then
	if [ $TARGET_OS == "windows" ]; then
		echo "$(tput setaf 1)Missing 'zip' which is important to run this script"
		echo "Download and install 7z-zip from its official website https://www.7-zip.org/"
		echo "By default, it is installed under the directory /c/Program Files/7-Zip in Windows 10 as my case."
		echo "Run git Bash under Administrator privilege and"
		echo "navigate to the directory /c/Program Files/Git/mingw64/bin,"
		echo "you can run the command $(tput setaf 2)ln -s /c/Program Files/7-Zip/7z.exe zip.exe$(tput sgr0)"
		exit 3
	elif [ $TARGET_OS == "linux" ]; then
		echo "$(tput setaf 1)Missing 'zip' which is important to run this script"
		echo "install it with the command $(tput setaf 2)'sudo apt-get install zip'$(tput sgr0)"
		exit 3
	fi
fi

#### Set build environment 
BUILD_ENV="0.1"
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

# List few useful data
echo
echo "Script path :" $SCRIPT_PATH
echo "OS          :" $OS
echo ""

# Get Commit_Hash
GIT_COMMIT_HASH=$(git log --pretty=format:"%h" -1)

# Get Commit_Number
GIT_COMMIT_NUMBER=$(git rev-list HEAD --count)

# First argument defines which variant of the CaribouDuet configuration will be build
if [ -z "$1" ] ; then
	# Select which variant of the CaribouDuet configuration will be build, like
	PS3="Select a variant: "
	while IFS= read -r -d $'\0' f; do
		options[i++]="$f"
	done < <(find Configuration/sys/variants/ -maxdepth 1 -type f -name "*" -print0 )
	select opt in "${options[@]}" "All" "Quit"; do
		case $opt in
			*.sh)
				VARIANT=$(basename "$opt" ".sh")
				VARIANTS[i++]="$opt"
				break
				;;
			"All")
				VARIANT="All"
				ALL_VARIANTS="All"
				VARIANTS=${options[*]}
				break
				;;
			"Quit")
				echo "You chose to stop"
					exit
					;;
			*)
				echo "$(tput setaf 1)This is not a valid variant$(tput sgr0)"
				;;
		esac
	done
else
	if [ -f "$SCRIPT_PATH/Configuration/sys/variants/$1" ] ; then 
		VARIANTS=$1
	else
		echo "$(tput setaf 1)$1 could not be found in Firmware/variants please choose a valid one$(tput setaf 2)"
		ls -1 $SCRIPT_PATH/Configuration/sys/variants/*.sh | xargs -n1 basename
		echo "$(tput sgr0)"
		exit 21
	fi
fi

# =========================================================================================================

echo
echo 'creating Preheat Macros ...'
echo

PREHEATPATH=$SCRIPT_PATH/Configuration/macros/02-Preheat
PREHEATOUTPUT=$SCRIPT_PATH/Configuration/macros/02-Preheat/processed

# generate filaments
#
# read existing variants
while IFS= read -r -d $'\0' f; do
	preheatoptions[i++]="$f"
done < <(find Configuration/macros/02-Preheat/*.h -maxdepth 1 -type f -name "*" -print0 )
PREHEATVARIANTS=${preheatoptions[*]}

# prepare output folder
if [ ! -d "$PREHEATOUTPUT" ]; then
	mkdir -p $PREHEATOUTPUT || exit 27
else 	
	rm -fr $PREHEATOUTPUT || exit 27
	mkdir -p $PREHEATOUTPUT || exit 27
fi

i=0
for v in ${PREHEATVARIANTS[*]}
do
	
	VARIANT=$(basename "$v" ".h")
	

	# read filament definition
	source $PREHEATPATH/$VARIANT.h
	i=$((i+1))
	
	echo 'generating file for:' $FILAMENTNAME

	
	# create preheat preheat file
	sed "
	{s/#FILAMENT_NAME/${FILAMENTNAME}/g};
	{s/#FILAMENT_TEMPERATURE/${FILAMENT_TEMPERATURE}/g}
	" < $PREHEATPATH/Preheat > $PREHEATOUTPUT/0$i-$FILAMENTNAME-$FILAMENT_TEMPERATURE

done

cp $PREHEATPATH/Cooldown $PREHEATOUTPUT

# =========================================================================================================


echo
echo 'creating filament files ...'
echo

# generate filaments
#
# read existing variants
while IFS= read -r -d $'\0' f; do
	filamentoptions[i++]="$f"
done < <(find Configuration/filaments/*.h -maxdepth 1 -type f -name "*" -print0 )
FILAMENTVARIANTS=${filamentoptions[*]}

for v in ${FILAMENTVARIANTS[*]}
do
	
	VARIANT=$(basename "$v" ".h")
	
	# =========================================================================================================
	#
	# set output 
	#

	FILAMENTPATH=$SCRIPT_PATH/Configuration/filaments
	FILAMENTOUTPUT=$SCRIPT_PATH/Configuration/filaments/filaments

	# read filament definition
	source $FILAMENTPATH/$VARIANT.h
	
	echo 'generating files for:' $FILAMENTNAME

	# prepare output folder
	if [ ! -d "$SCRIPT_PATH/filaments/$FILAMENTNAME" ]; then
		mkdir -p $FILAMENTOUTPUT/$FILAMENTNAME || exit 27
	else 	
		rm -fr $FILAMENTOUTPUT/$FILAMENTNAME || exit 27
		mkdir -p $FILAMENTOUTPUT/$FILAMENTNAME || exit 27
	fi

	# create load.g
	sed "
	{s/#FILAMENT_NAME/${FILAMENTNAME}/};
	{s/#FILAMENT_TEMPERATURE/${FILAMENT_TEMPERATURE}/g}
	" < $FILAMENTPATH/load.g > $FILAMENTOUTPUT/$FILAMENTNAME/load.g

	# create load.g
	sed "
	{s/#FILAMENT_NAME/${FILAMENTNAME}/};
	{s/#FILAMENT_TEMPERATURE/${FILAMENT_TEMPERATURE}/g}
	" < $FILAMENTPATH/unload.g > $FILAMENTOUTPUT/$FILAMENTNAME/unload.g

	# create config.g
	cp $FILAMENTPATH/config.g $FILAMENTOUTPUT/$FILAMENTNAME/
done


echo
echo 'creating zip file for filaments ....'

# create zip file for filaments
zip a $FILAMENTOUTPUT/filaments.zip $FILAMENTOUTPUT/* | tail -4

echo
echo '... done'


# =========================================================================================================

echo
echo 'generating configurations and macros ....'
echo


for v in ${VARIANTS[*]}
do
	VARIANT=$(basename "$v" ".sh")
	# Find firmware version in config.g file and use it to generate the output folder
	CC=$(grep --max-count=1 "\bRelease\b" $SCRIPT_PATH/Configuration/sys/config.g | sed -e's/  */ /g'|cut -d '"' -f2|sed 's/\.//g')
	# Find build version in config.g file and use it to generate the output folder
	BUILD=$(grep --max-count=1 "\bBuild\b" $SCRIPT_PATH/Configuration/sys/config.g | sed -e's/  */ /g'|cut -d ' ' -f3)

	if [ "$BUILD" == "$GIT_COMMIT_NUMBER" ] ; then
		echo "FW_COMMIT in Configuration.h is identical to current git commit number"
	else
		echo "$(tput setaf 5)FW_COMMIT $BUILD in Configuration.h is DIFFERENT to current git commit number $GIT_COMMIT_NUMBER. To cancel this process press CRTL+C and update the FW_COMMIT value.$(tput sgr0)"
		if [ -z "$ALL_VARIANTS" ]; then
			read -t 2 -p "Press Enter to continue..."
		fi
	fi
	
	#Prepare config files folders
	if [ ! -d "$SCRIPT_PATH/../CC-build/CC$CC-Build$BUILD" ]; then
		mkdir -p $SCRIPT_PATH/../CC-build/CC$CC-Build$BUILD || exit 27
	fi

	OUTPUT_FOLDER="CC-build/CC$CC-Build$BUILD"
	
	#List some useful data
	echo "$(tput setaf 2)$(tput setab 7) "
	echo "Variant       :" $VARIANT
	echo "Configuration :" $CC
	echo "Build #       :" $BUILD
	echo "Config Folder :" $OUTPUT_FOLDER
	echo "$(tput sgr0)"


	VARIANTOUTPUT=$SCRIPT_PATH/../CC-build/CC$CC-Build$BUILD/$VARIANT
	
	# prepare output folder
	if [ ! -d "$SCRIPT_PATH/../CC-build/CC$CC-Build$BUILD/$VARIANT" ]; then
		mkdir -p $VARIANTOUTPUT || exit 27
	else 	
		rm -fr $VARIANTOUTPUT || exit 27
		mkdir -p $VARIANTOUTPUT || exit 27
	fi
	
	# copy filament.zip to build directory
	cp $FILAMENTOUTPUT/filaments.zip $VARIANTOUTPUT

	# copy macros directory
	mkdir $VARIANTOUTPUT/macros
	find $SCRIPT_PATH/Configuration/macros/* -maxdepth 0 ! -name "*Preheat*" -exec cp -r -t  $VARIANTOUTPUT/macros {} \+
 	cp -r $SCRIPT_PATH/Configuration/macros/02-Preheat/processed $VARIANTOUTPUT/macros/02-Preheat

	
	# copy sys directory
	mkdir -p $VARIANTOUTPUT/sys || exit 27
	cp  $SCRIPT_PATH/Configuration/sys/*.* $VARIANTOUTPUT/sys
	# delete deploy.g and retract.g from target for all variants except BL-Touch versions
	if [[ $VARIANT != *"BL"* ]]; then
	  rm $VARIANTOUTPUT/sys/deployprobe.g
	  rm $VARIANTOUTPUT/sys/retractprobe.g
    fi
	
	# run script to generate config.g and change macros
	cd $SCRIPT_PATH/Configuration/sys/variants/
	$SCRIPT_PATH/Configuration/sys/variants/$VARIANT.sh

    # move 00_Level-X-Axis-xxx to output folder and rename to 00-Level-X-Axis
	mv ../../macros/00-Level-X-Axis-$VARIANT $VARIANTOUTPUT/macros/00-Level-X-Axis
	
	# move config-xxx.g to output folder and rename to config.g
	mv ../config-$VARIANT.g $VARIANTOUTPUT/sys/config.g

	# move homez-xxx.g to output folder and rename to homez.g
	mv ../homez-$VARIANT.g $VARIANTOUTPUT/sys/homez.g
	
	# move homeall-xxx.g to output folder and rename to homeall.g
	mv ../homeall-$VARIANT.g $VARIANTOUTPUT/sys/homeall.g

	# create zip file for macros and remove directory
	echo
	echo 'creating zip file for macros ....'
	zip a $VARIANTOUTPUT/macros.zip $VARIANTOUTPUT/macros/* | tail -4
	rm -fr $VARIANTOUTPUT/macros

	# create zip file for sys and remove directory
	echo
	echo 'creating zip file for sys ....'

	zip a $VARIANTOUTPUT/sys.zip $VARIANTOUTPUT/sys/* | tail -4
	rm -fr $VARIANTOUTPUT/sys

	# create zip-file for configuration
	echo
	echo 'creating zip file for configuration ....'
	zip a $SCRIPT_PATH/../CC-build/CC$CC-Build$BUILD/CC$CC-$VARIANT-Build$BUILD.zip  $VARIANTOUTPUT/*.zip | tail -4
	
	echo
	echo '... done'

done

# delete filament folders in source directory
rm -fr $SCRIPT_PATH/Configuration/filaments/filaments
rm -fr $SCRIPT_PATH/Configuration/macros/02-Preheat/processed
