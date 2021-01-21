; =========================================================================================================
;
;   Testcode for printing a meander and a rectangle at the end to adjust babysteps
;
; =========================================================================================================
;
M291 P"First layer calibration for #FILAMENT_NAME. Press OK to continue or CANCEL to abort." R"#FILAMENT_NAME at #FILAMENT_TEMPERATURE°C" S3
;
;====== start preheat start script ========================================================================
;
G90                      ; use absolute coordinates
M83                      ; extruder relative mode
;
G28 W                    ; home all without mesh bed level
G0 X60 Y-3 Z80           ; move extruder above bed keep extruder in front for cleaning and checking
;
M104 S160 T0             ; pre-heat extruder to 160C 
M140 S60                 ; this will take the layer 1 temperature for bed 0
M190 S60                 ; wait for bed temp
;
G29                      ; mesh bed leveling 
G0 X0 Y-3 Z0 F3000
;
M104 S215                ; set extruder temperature
M109 S215                ; wait for extruder temp
;
M572 D0 S0.00            ; set pressure advance
;
;====== end preheat start script ==========================================================================
;
; =========================================================================================================
; start introLine
G1 Y-3.0 F1000.0         ; go outside print area
G92 E0.0
G1 X60.0 E5.0  F1000.0   ; intro line
G1 X100.0 E7.0  F1000.0  ; intro line
; done introline
; =========================================================================================================
; start meander
G1 Z0.50 F7200.000
G1 X50 Y155 F6000
G1 Z0.150 F7200.000
G1 F1080
G1 X75 Y155 E2.5
G1 X100 Y155 E2
G1 X200 Y155 E2.62773
G1 X200 Y135 E0.66174
G1 X50 Y135 E3.62773
G1 X50 Y115 E0.49386
G1 X200 Y115 E3.62773
G1 X200 Y95 E0.49386
G1 X50 Y95 E3.62773
G1 X50 Y75 E0.49386
G1 X200 Y75 E3.62773
G1 X200 Y55 E0.49386
G1 X50 Y55 E3.62773
; done meander
; =========================================================================================================
; start Rectangle
G1 X50 Y35 E0.738
G1 X80 Y35.00 E0.738
G1 Y34.60 E0.010
G1 X50 Y34.60 E0.738
G1 Y34.20 E0.010
G1 X80 Y34.20 E0.738
G1 Y33.80 E0.010
G1 X50 Y33.80 E0.738
G1 Y33.40 E0.010
G1 X80 Y33.40 E0.738
G1 Y33.00 E0.010
G1 X50 Y33.00 E0.738
G1 Y32.60 E0.010
G1 X80 Y32.60 E0.738
G1 Y32.20 E0.010
G1 X50 Y32.20 E0.738
G1 Y31.80 E0.010
G1 X80 Y31.80 E0.738
G1 Y31.40 E0.010
G1 X50 Y31.40 E0.738
G1 Y31.00 E0.010
G1 X80 Y31.00 E0.738
G1 Y30.60 E0.010
G1 X50 Y30.60 E0.738
G1 Y30.20 E0.010
G1 X80 Y30.20 E0.738
G1 Y29.80 E0.010
G1 X50 Y29.80 E0.738
G1 Y29.40 E0.010
G1 X80 Y29.40 E0.738
G1 Y29.00 E0.010
G1 X50 Y29.00 E0.738
G1 Y28.60 E0.010
G1 X80 Y28.60 E0.738
G1 Y28.20 E0.010
G1 X50 Y28.20 E0.738
G1 Y27.80 E0.010
G1 X80 Y27.80 E0.738
G1 Y27.40 E0.010
G1 X50 Y27.40 E0.738
G1 Y27.00 E0.010
G1 X80 Y27.00 E0.738
G1 Y26.60 E0.010
G1 X50 Y26.60 E0.738
G1 Y26.20 E0.010
G1 X80 Y26.20 E0.738
G1 Y25.80 E0.010
G1 X50 Y25.80 E0.738
G1 Y25.40 E0.010
G1 X80 Y25.40 E0.738
G1 Y25.00 E0.010
G1 X50 Y25.00 E0.738
G1 Y24.60 E0.010
G1 X80 Y24.60 E0.738
G1 Y24.20 E0.010
G1 X50 Y24.20 E0.738
G1 Y23.80 E0.010
G1 X80 Y23.80 E0.738
G1 Y23.40 E0.010
G1 X50 Y23.40 E0.738
G1 Y23.00 E0.010
G1 X80 Y23.00 E0.738
G1 Y22.60 E0.010
G1 X50 Y22.60 E0.738
G1 Y22.20 E0.010
; done rectangle
; =========================================================================================================
; start end script
G1 F1000.0               ; set feed rate
G1 E-3                   ; retract 3mm
M104 S0                  ; turn off temperature
M140 S0                  ; turn off heatbed
M107                     ; turn off fan
G1 X0 Y200 F7200         ; home XY axis
M84 XY                   ; disable motors
; done end script
; =========================================================================================================
