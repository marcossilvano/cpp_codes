
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Starting values for player object
PlayerObjectBak:
	dc.b 0
	
	ifd PlayerHsprite
		dc.b PlayerHsprite
	else
		dc.b 0
	endif
	
	dc.b ScreenObjWidth/2,ScreenObjHeight/2,0,0,0,0



ObjectByteSize equ 8	;8 bytes per object
;SpriteAddress,Xpos,Ypos,Xpos2,Ypos2,Xaccel,Yaccel,Program,Collision
Enemies equ 40			;40 Enemies onscreen MAX (including Mines / Crystals)
BulletCount equ 8		;Bullets (Player + Enemy)
OnscreenCrystals equ 5 	;Crystals onscreen (on collection more respawn up to level count)


LevelMap:			;Pointers to level data
	dc.l Level1
	dc.l Level2
	dc.l Level3
	dc.l Level4
	dc.l Level5
	dc.l Level6
	dc.l Level7
	dc.l Level8
	dc.l Level9
	dc.l Level10
	dc.l Level11
	dc.l Level12
	dc.l Level13
	dc.l Level14
	dc.l Level15
	dc.l Level16
	
Level1:	 
;Header
	dc.b 3,0			;CrystalCount , unused
;Object List - (Type,Count)
	dc.b 1,3			;Slow purplee
	dc.b 2,3			;Crystals
	dc.b 4,5			;Mines
	dc.b 0,255		;End of list
;Level Definition Ends

Level2: ;(Type,Count)
	dc.b 5,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 1,3			;Slow purplee
	dc.b 2,5			;Crystals
	dc.b 4,5			;Mines
	dc.b 0,255		;End of list

Level3: ;(Type,Count)
	dc.b 8,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 1,3			;Slow purplee
	dc.b 2,5			;Crystals
	dc.b 4,7			;Mines
	dc.b 0,255		;End of list

Level4: ;(Type,Count)
	dc.b 8,0			;CrystalCount , unused
	dc.b 3,2			;FastBlue
	dc.b 1,2			;Slow purplee
	dc.b 5,1			;Toothy
	dc.b 2,5			;Crystals
	dc.b 4,7			;Mines
	dc.b 0,255		;End of list

Level5: ;(Type,Count)
	dc.b 10,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 1,1			;Slow purplee
	dc.b 5,1			;Toothy
	dc.b 6,3			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,10			;Mines
	dc.b 0,255		;End of list

Level6: ;(Type,Count)
	dc.b 10,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,2			;Slow purplee
	dc.b 6,2			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,10			;Mines
	dc.b 0,255		;End of list


Level7: ;(Type,Count)
	dc.b 15,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,2			;Slow purplee
	dc.b 6,1			;Wiggle
	dc.b 8,1			;Moody
	dc.b 2,5			;Crystals
	dc.b 4,13			;Mines
	dc.b 0,255		;End of list


Level8: ;(Type,Count)
	dc.b 15,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,1			;Slow purplee
	dc.b 6,1			;Wiggle
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 2,5			;Crystals
	dc.b 4,13			;Mines
	dc.b 0,255		;End of list

Level9: ;(Type,Count)
	dc.b 20,0			;CrystalCount , unused
	dc.b 3,1			;FastBlue
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,1			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 2,5			;Crystals
	dc.b 4,13			;Mines
	dc.b 0,255		;End of list

Level10: ;(Type,Count)
	dc.b 20,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,1			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 2,5			;Crystals
	dc.b 4,13			;Mines
	dc.b 0,255		;End of list


Level11: ;(Type,Count)
	dc.b 25,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 5,1			;Toothy
	dc.b 1,3			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 6,1			;Wiggle
	dc.b 9,1			;Vbar
	dc.b 2,5			;Crystals
	dc.b 4,15			;Mines
	dc.b 0,255		;End of list

Level12: ;(Type,Count)
	dc.b 25,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 1,3			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 6,1			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,15			;Mines
	dc.b 12,1			;Clouder
	dc.b 0,255		;End of list



Level13: ;(Type,Count)
	dc.b 25,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 1,3			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 6,1			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,15			;Mines
	dc.b 12,2			;Clouder
	dc.b 0,255		;End of list

Level14: ;(Type,Count)
	dc.b 25,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 1,2			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 6,1			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,17			;Mines
	dc.b 12,3			;Clouder
	dc.b 0,255		;End of list


Level15: ;(Type,Count)
	dc.b 25,0			;CrystalCount , unused
	dc.b 11,1			;JoinedDuo
	dc.b 7,1			;Jelly
	dc.b 1,1			;Slow purplee
	dc.b 10,1			;Three Eyes
	dc.b 8,1			;Moody
	dc.b 9,1			;Vbar
	dc.b 6,1			;Wiggle
	dc.b 2,5			;Crystals
	dc.b 4,17			;Mines
	dc.b 12,4			;Clouder
	dc.b 0,255		;End of list

Level16: ;(Type,Count)
	dc.b 30,0			;CrystalCount , unused
	dc.b 2,5			;Crystals
	dc.b 4,25			;Mines
	dc.b 12,5			;Clouder
	dc.b 1,5			;Slow purplee
	dc.b 0,255		;End of list


;Template Objects for leves
;	dc.b 1,1			;Slow purplee
;	dc.b 2,5			;Crystals
;	dc.b 3,1			;FastBlue
;	dc.b 5,1			;Toothy
;	dc.b 6,1			;Wiggle
;	dc.b 7,1			;Jelly
;	dc.b 8,1			;Moody
;	dc.b 9,1			;Vbar
;	dc.b 10,1			;Three Eyes
;	dc.b 11,1			;JoinedDuo
;	dc.b 12,1			;Clouder

;	dc.b 0,255		;End of list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enemy Definition latout
D_SprNum equ 0				;Sprite Number
D_CollProg equ 1 			;Collision program (1=Crystal 0=anything 3=Bullet (player) 255=nothing 254=dead)
D_Program equ 2 			;0=static 1+=moving
D_Xacc equ 3				;Acceleration X
D_Yacc equ 4				;Acceleration Y
;5,6,7 						;Unused
	
EnemyDefinitions:
	;  S,COL,P,X,Y,-,-,-
	dc.b 0,255,0,0,0,0,0,0	;Empty (0)
	dc.b 1,0,1,1,1,0,0,0	;Slow Purple (1)
	dc.b 2,1,0,0,0,0,0,0	;Crystal (2)
	dc.b 3,0,2,2,2,0,0,0	;Fast Blue (3)
	dc.b 4,0,1,0,0,0,0,0	;Mine (4)
	dc.b 8,0,3,1,1,0,0,0	;Toothy (5)
	dc.b 9,0,4,2,2,0,0,0	;Wiggle (6)
	dc.b 10,0,5,2,2,0,0,0	;Jelly (7)
	dc.b 11,0,5,3,3,0,0,0	;Moody (8)
	dc.b 12,0,3,2,2,0,0,0	;Vbar (9)
	dc.b 13,0,3,3,3,0,0,0	;Three-Eyes (10)
	dc.b 14,0,1,3,3,0,0,0	;JoinedDuo (11)
	dc.b 15,0,6,3,3,0,0,0	;Clouder (11)

	align 4			;for Vasm
	
;Random number Lookup tables
Randoms1:
	dc.b $0A,$9F,$F0,$1B,$69,$3D,$E8,$52,$C6,$41,$B7,$74,$23,$AC,$8E,$D5
Randoms2:
	dc.b $9C,$EE,$B5,$CA,$AF,$F0,$db,$69,$3D,$58,$22,$06,$41,$17,$74,$83

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;Text Strings

;Title Screen Strings
txtUrl: dc.b "LearnAsm.Net",255

	ifd ScreenWidth20
txtFire: dc.b "Press Fire",255
	else
txtFire: dc.b "Press Fire To Start",255
	endif
	
TxtHiScore:   dc.b "HiScore:",255

;Game Over Strings
	ifd ScreenWidth20
txtDead: dc.b "Game Over!",255
	else
txtDead: dc.b "Game Over... You're Dead! :-(",255
	endif
	
TxtNewHiscore: dc.b "New Hiscore!",255

;Level Complete Strings
txtComplete: dc.b "Level Complete!",255

;Ingame Strings
	ifd ScreenWidth20
TxtCrystals: dc.b 'Cr',255
TxtLevel: dc.b 'Lv',255
TxtLives: dc.b 'Li',255	
TxtScore:   dc.b "",255
	else
	
TxtCrystals: dc.b 'Crystal:',255
TxtLevel: dc.b 'Level:',255
TxtLives: dc.b 'Lives:',255	
TxtScore:   dc.b "Score:",255
	endif



;Binary Coded Decimal Score Additions

BCD1: dc.b  $00,$00,$00,$01	;1 		Score 'adders' for BCD... 
BCD3: dc.b  $00,$00,$00,$03	;3		my BCD requires value to add to match in length destination score
BCD5: dc.b  $00,$00,$00,$05	;5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Title Screen Logo - Different versions depending on screen size
TitlePic:
	ifd ScreenWidth32
		dc.b 0,10,10,0,0,6,0,0,0,0,0,0,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,10,10,10,0,0,0,4,4,4,4,0,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0
		dc.b 0,10,10,10,10,0,4,4,4,4,0,10,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,0,10,10,10,0,0,4,0,0,0,10,10,0,0,0,0,0,0,0,0,0,6,0,0,0,0,0,0,0,0,0
		dc.b 6,0,0,10,10,10,0,0,0,0,10,10,0,4,4,0,0,0,0,0,0,0,0,0,0,0,0,6,0,0,0,0
		dc.b 0,0,0,10,10,10,0,0,0,10,10,15,15,4,4,0,0,0,0,0,0,0,0,0,0,0,0,15,15,0,0,0
		dc.b 0,4,0,0,10,10,0,0,0,15,15,15,15,15,15,0,0,0,0,0,0,0,0,0,0,15,15,15,15,15,15,0
		dc.b 4,4,4,0,10,10,10,0,10,10,10,0,15,15,15,15,0,0,0,0,0,0,0,0,15,15,15,15,0,0,0,0
		dc.b 4,4,0,0,0,10,10,10,10,10,0,0,0,4,15,15,0,0,0,0,0,0,0,0,15,15,0,0,0,0,6,0
		dc.b 4,4,0,6,0,0,10,10,10,0,0,0,0,4,0,15,0,0,15,15,15,15,0,0,15,0,0,0,0,0,0,0
		dc.b 4,4,0,0,0,0,10,10,10,0,6,0,0,4,0,0,15,15,15,15,15,15,15,15,0,0,0,0,0,0,0,0
		dc.b 4,4,0,0,0,0,10,10,10,0,0,0,4,4,0,15,15,15,15,15,15,15,15,15,15,0,0,0,0,0,0,0
		dc.b 4,4,4,0,0,0,10,10,10,0,0,4,4,0,15,15,2,2,15,15,15,15,2,2,15,15,0,0,0,0,6,0
		dc.b 0,4,4,4,0,0,0,0,0,0,4,4,0,0,15,15,15,2,15,15,15,15,2,15,15,15,0,0,0,0,0,0
		dc.b 0,0,4,4,4,4,4,4,4,4,4,0,0,0,15,15,15,15,15,15,15,15,15,15,15,15,0,0,0,0,0,0
		dc.b 0,0,0,0,8,8,4,4,4,0,0,0,8,0,15,15,0,0,0,0,0,0,0,0,15,15,0,0,0,0,0,0
		dc.b 0,0,0,8,8,8,8,0,0,0,0,8,8,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0
		dc.b 6,0,8,8,0,10,8,8,0,0,8,8,0,0,0,0,0,0,8,8,8,0,0,8,8,8,0,0,0,0,8,0
		dc.b 0,8,8,0,0,0,0,8,8,0,8,8,0,0,8,0,0,8,0,0,8,0,8,8,8,0,0,8,8,8,8,8
		dc.b 0,8,0,0,6,0,0,8,8,0,8,8,0,8,8,0,8,8,0,8,8,0,8,8,0,0,8,8,8,8,8,8
		dc.b 0,8,0,0,8,8,0,8,0,8,8,0,0,8,8,0,8,8,8,8,0,0,0,8,8,0,0,0,8,8,0,0
		dc.b 0,8,8,0,8,8,8,8,0,8,8,0,8,8,8,8,8,8,0,0,0,0,0,0,8,8,0,0,8,8,0,0
		dc.b 0,0,8,8,8,8,8,0,0,0,8,8,8,0,0,0,8,8,0,8,8,8,0,8,8,0,0,0,8,8,0,0
		dc.b 0,0,0,0,0,8,8,0,0,0,0,0,0,0,6,0,0,8,8,8,0,0,8,8,0,0,0,0,8,0,0,0
	endif
	ifd ScreenWidth20
		dc.b 6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,10,10,0,0,0,0,10,10,0,0,6,0,0,0,0,0,0,0,0
		dc.b 0,10,10,0,4,4,0,10,10,0,0,0,0,0,0,0,0,6,0,0
		dc.b 0,0,10,10,0,0,10,10,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 4,0,10,10,0,10,10,10,4,0,0,0,0,0,6,0,0,0,0,0
		dc.b 4,0,0,10,10,10,10,0,0,4,0,0,0,0,0,0,0,0,0,0
		dc.b 4,0,0,10,10,10,0,0,0,4,0,15,15,15,0,0,15,15,15,0
		dc.b 4,4,0,10,10,0,0,0,4,4,15,0,0,15,15,15,15,0,0,15
		dc.b 4,4,4,10,10,0,0,4,4,0,0,0,15,15,15,15,15,15,0,0
		dc.b 0,4,4,4,4,4,4,4,0,0,0,15,2,2,15,15,2,2,15,0
		dc.b 0,0,10,4,4,4,4,0,0,6,0,15,15,15,15,15,15,15,15,0
		dc.b 0,0,10,10,0,0,0,0,0,0,0,15,0,0,0,0,0,0,15,0
		dc.b 6,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
		dc.b 0,8,8,0,0,8,0,0,8,0,8,8,8,0,8,8,0,8,8,8
		dc.b 8,0,0,8,0,8,0,0,8,0,8,8,0,0,8,0,0,0,8,0
		dc.b 8,0,8,8,0,8,0,0,8,0,8,0,0,0,0,8,0,0,8,0
		dc.b 0,8,8,0,0,0,8,8,0,0,8,8,8,0,8,8,0,0,8,0
		dc.b 0,0,8,8,0,6,0,0,0,0,0,0,0,0,0,0,0,6,0,0
	endif
	ifd ScreenWidth40
		dc.b 0,10,10, 0, 0, 6, 0, 0, 0, 0, 0, 0,10,10,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 0,10,10,10, 0, 0, 0, 4, 4, 4, 4, 0,10,10,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 0,10,10,10,10, 0, 4, 4, 4, 4, 0,10,10,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 0, 0,10,10,10, 0, 0, 4, 0, 0, 0,10,10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 6, 0, 0,10,10,10, 0, 0, 0, 0,10,10, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0
		dc.b 0, 0, 0,10,10,10, 0, 0, 0,10,10,10, 0, 4, 4, 0, 0, 0, 0,15,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15, 0, 0, 0
		dc.b 0, 4, 0, 0,10,10, 0, 0, 0,10,10, 0, 0, 0, 4, 4, 0,15,15,15,15,15,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15,15,15,15, 0
		dc.b 4, 4, 4, 0,10,10,10, 0,10,10,10, 0, 0, 0, 4, 4, 0, 0, 0, 0,15,15,15,15, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15,15, 0, 0, 0, 0
		dc.b 4, 4, 0, 0, 0,10,10,10,10,10, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0,15,15, 0, 0, 0, 0, 0, 0, 0, 0,15,15, 0, 0, 0, 0, 6, 0
		dc.b 4, 4, 0, 6, 0, 0,10,10,10, 0, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0,15, 0, 0,15,15,15,15, 0, 0,15, 0, 0, 0, 0, 0, 0, 0
		dc.b 4, 4, 0, 0, 0, 0,10,10,10, 0, 6, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15,15,15,15,15,15, 0, 0, 0, 0, 0, 0, 0, 0
		dc.b 4, 4, 0, 0, 0, 0,10,10,10, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15,15,15,15,15,15,15,15, 0, 0, 0, 0, 0, 0, 0
		dc.b 4, 4, 4, 0, 0, 0,10,10,10, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15, 2, 2,15,15,15,15, 2, 2,15,15, 0, 0, 0, 0, 6, 0
		dc.b 0, 4, 4, 4, 0, 0, 0, 0, 0, 0, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15, 2,15,15,15,15, 2,15,15,15, 0, 0, 0, 0, 0, 0
		dc.b 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,15,15,15,15,15,15,15,15,15,15,15,15, 0, 0, 0, 0, 0, 0
		dc.b 0, 0, 0, 0, 4, 4, 4, 4, 4, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0,15,15, 0, 0, 0, 0, 0, 0, 0, 0,15,15, 0, 0, 0, 0, 0, 0
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0,15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0
		dc.b 6, 0, 0, 0, 0,10,10,10, 0, 0, 8, 8, 0, 0, 8, 8, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 8, 8, 8, 0, 0, 8, 8, 8, 0, 0, 0, 0, 8, 0
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 8, 8, 0, 8, 8, 0, 0, 8, 0, 0, 8, 0, 0, 8, 0, 8, 8, 8, 0, 0, 8, 8, 8, 8, 8
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 6, 0, 0, 8, 8, 0, 8, 8, 0, 8, 8, 0, 8, 8, 0, 8, 8, 0, 8, 8, 0, 0, 8, 8, 8, 8, 8, 8
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 8, 8, 0, 8, 0, 8, 8, 0, 0, 8, 8, 0, 8, 8, 8, 8, 0, 0, 0, 8, 8, 0, 0, 0, 8, 8, 0, 0
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 8, 8, 8, 8, 0, 8, 8, 0, 8, 8, 8, 8, 8, 8, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 8, 8, 0, 0
		dc.b 0, 6, 0, 0, 0, 0, 6, 0, 0, 0, 8, 8, 8, 8, 8, 0, 0, 0, 8, 8, 8, 0, 0, 0, 8, 8, 0, 8, 8, 8, 0, 8, 8, 0, 0, 0, 8, 8, 0, 0
		dc.b 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0, 0, 0, 6, 0, 0, 8, 8, 8, 0, 0, 8, 8, 0, 0, 0, 0, 8, 0, 0, 0
	endif
