M291 P"Prepare for filament loading. Please wait while the nozzle is being heated up. Press OK to continue or CANCEL to abort." R"Loading ABS at 250°C" S3;
G91                ; relative positioning
;G1 Z20 F6000 H2    ; lift Z relative to current position
M104 S250	       ; Set current tool temperature to 250C
M116        	   ; Wait for the temperatures to be reached
;
M98 P"0:/macros/09 Filament Handling/load.g"
;
