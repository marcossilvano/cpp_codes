
;4 directions represented as accelerations	
Directions:				
	dc.w 0,-1		; Up
	dc.w 1,0		; Right
	dc.w 0,1		; Down
	dc.w -1,0		; Left


;Random number Lookup tables	
		Align 4	
Randoms1:
	dc.b $0A,$9F,$F0,$1B,$69,$3D,$E8,$52,$C6,$41,$B7,$74,$23,$AC,$8E,$D5
Randoms2:
	dc.b $9C,$EE,$B5,$CA,$AF,$F0,$DB,$69,$3D,$58,$22,$06,$41,$17,$74,$83

	even
;Default Settings for new level
UserRamBak:
 dc.w 1						;Rotation
	ifd ScreenWidth20
		dc.w 16				;Player X
		dc.w 16				;Player Y
	else
		dc.w 32
		dc.w 32
	endif
 dc.w 1						;Accel X
 dc.w 0						;Accel Y
	ifd ScreenWidth20
		dc.w ScreenWidth-16	;Cpu X
		dc.w ScreenHeight-16;Cpu Y
	else
		dc.w ScreenWidth-32
		dc.w ScreenHeight-32
	endif
 dc.w 3						;Cpu Direction
 dc.w -1					;Cpu Accel X
 dc.w 0						;Cpu Accel Y
 dc.w 1						;Cpu Turn
UserRamBakEnd:


;Title Message
	ifd ScreenWidth20
Ttitle1:
	dc.b "Battle of the Chibi",255
Ttitle2:
	dc.b "Photonic hunters!",255
	else
Ttitle:
	dc.b "Battle of the Chibi Photonic hunters!",255
	endif
TBestLevel:
	dc.b "BestLevel:",255

;Game Over message
Tgameover:
	dc.b "Game Over!",255
TYouSuck:
	ifd ScreenWidth40
		dc.b "Your Performance Sucks!",255
	else
		dc.b "Your GamePlay Sucks!",255
	endif
TYouRock:
	dc.b "New Best Performance!",255

	
;Obstruction objects (Cpacket format)
Object1:
	;   CYYYYYYY, DXXXXXXX  CD=Command Y=Y dest X=X dest
    dc.b %00000011,%01111101	;Move
    dc.b %00000000,%10000110	;  Line
    dc.b %01111010,%10000000	;  Line
    dc.b %00000000,%11111010	;  Line
    dc.b %00000110,%10000000	;  Line
    dc.b %01111010,%10000110	;  Line
    dc.b %00000000,%01111010	;Move
    dc.b %10000110,%10000110	;  Line + End

Object2:
    dc.b %00000001,%01111101	;Move
    dc.b %00000010,%10000000	;  Line
    dc.b %00000000,%10000010	;  Line
    dc.b %00000000,%00000010	;Move
    dc.b %00000000,%10000010	;  Line
    dc.b %01111110,%10000000	;  Line
    dc.b %01111110,%00000000	;Move
    dc.b %01111110,%10000000	;  Line
    dc.b %00000000,%11111110	;  Line
    dc.b %00000000,%01111110	;Move
    dc.b %00000000,%11111110	;  Line
    dc.b %10000010,%10000000	;  Line + End
	
	even
	
	
	