; =========================================================================================================
;
; filament load macro
;
; for #CARIBOU_VARIANT
;
; =========================================================================================================
;
M300 S500 P600         ; beep
T0                     ; select tool
M291 P"Insert filament. Press ok to start feeding filament..." S2       ; Display new message
M291 P"Feeding filament.... " S1 T25
;
G91                    ; set to Relative Positioning
G1 E#CARIBOU_INITIALLOAD F400            ; feed #CARIBOU_INITIALLOADmm of filament at 400mm/min
G1 E15 F200            ; feed 15mm of filament at 200mm/min
G4 P1000               ; wait one second
;
M98 P"0:/macros/03-Filament_Handling/purge.g"
;
G1 E-0.5 F200	       ; retract 0.5mm of filament at 400mm/min
M291 P"..... done" T30
M400                   ; wait for the moves to finish
;
; =========================================================================================================