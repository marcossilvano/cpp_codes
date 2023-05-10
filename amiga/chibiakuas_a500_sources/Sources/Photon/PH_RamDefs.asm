
;Player Data

PlayerDirection equ UserRam 	;What direction Player is facing (1 byte)

PlayerX equ PlayerDirection+2 	;Player X position (2 bytes)
PlayerY equ PlayerX+2			;Player Y position (2 bytes)

playerxacc equ PlayerY+2 		;Player X acceleration (2 bytes)
playeryacc equ playerxacc+2 	;Player Y acceleration (2 bytes)

;Cpu Data

CpuX equ playeryacc+2 			;Cpu X position (2 bytes)
CpuY equ CpuX+2 				;Cpu Y position (2 bytes)

CpuDirection equ CpuY+2			;What direction Cpu is facing (1 byte)

Cpuxacc equ CpuDirection+2 		;Cpu X acceleration (2 bytes)
Cpuyacc equ Cpuxacc+2 			;Cpu Y acceleration (2 bytes)

CpuTurn equ Cpuyacc+2			;What direction Cpu will turn (1 byte)

;Other Game Data

KeyTimeout equ CpuTurn+2 		;time a keypress will be ignored (1 byte)
BestLevel equ KeyTimeout+2 		;'Highscore' - best level reached (1 byte)
Level equ BestLevel+2 			;Current level (1 byte)
CpuAI equ Level+2 				;CPU Pixel look ahead lower=smarter (1 byte)
Lives equ CpuAI+2				;Player Lives (1 byte)
Tick equ Lives+2				;Game Tick (used for boost) (1 byte)
boost equ Tick+2 				;Turbo speed (1 byte)
BoostPower equ boost+2 			;Remaining boost power (1 byte)
ShownBoostPower equ BoostPower+2 ;Boost power value shown to screen (1 byte)
RandomSeed 	equ ShownBoostPower+2 ;Random seed (2 bytes)

;Line drawing

XposDir equ RandomSeed+2		;X Line Direction (1 byte)
Xpos24 equ XposDir+2 			;Xpos of current pixel (3 bytes)

YposDir equ Xpos24+4			;Y Line Direction (1 byte)
Ypos24 equ YposDir+2			;Ypos of current pixel (3 bytes)

Scale equ Ypos24+4				;Line Scale (1 byte)
LineColor equ Scale+2 			;Line Color (1 byte)

