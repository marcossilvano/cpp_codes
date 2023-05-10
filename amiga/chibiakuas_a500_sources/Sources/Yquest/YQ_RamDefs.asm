
;Object layout - used by all sprites... Enemies, player and bullets
O_SprNum equ 0 		;Sprite Number
o_HsprNum equ 1		;Hardware SpriteNumber
O_Xpos equ 2		;X Position
O_Ypos equ 3		;Y position
O_Xacc equ 4		;Acceleration X
O_Yacc equ 5		;Acceleration Y
O_Program equ 6		;0=static 1+=moving
O_CollProg equ 7 	;1=Crystal 0=anything 3=Bullet (player) 255=nothing 254=dead





YQuestRam equ UserRam

CursorX equ YQuestRam				;1 Byte		Ypos of next Char
CursorY equ CursorX+1				;1 Byte		Xpos of next Char

SpriteFrame equ CursorY+1			;1 Byte		Sprite Frame (0-3)

;SprNum,Spare,Xpos,Ypos,Xacc,Yacc,Prog,ColPrg
BulletArray equ SpriteFrame+1		;8 bytes per bullet Player Bullets
	
;SprNum,Spare,Xpos,Ypos,Xacc,Yacc,Prog,ColPrg
EnemyBulletArray equ 8*8+BulletArray;8 bytes per bullet Enemy Bullets
	
;SprNum,Spare,Xpos,Ypos,Xacc,Yacc,Prog,ColPrg
ObjectArray equ 8*8+EnemyBulletArray; ds 40*8
	

Invincibility equ 40*8+ObjectArray	;1 Byte		Player Invincible time

RandomSeed equ Invincibility+1		;1 Word		Random Seed
KeyTimeout equ RandomSeed+2			;1 Byte		Time to ignore keypresses
Lives equ KeyTimeout+1				;1 Byte		Player Lives
Level equ Lives+1					;1 Byte		Level Number (Zero based)
Crystals equ Level+1				;1 Byte		Remaining crystals on level
PlayingSFX equ Crystals+1			;1 Byte		Current Sound FX
PlayingSFX2 equ PlayingSFX+1		;1 Byte		Last Sound FX
Score equ PlayingSFX2+1 			;4 BCD Bytes 8 Digit score
HiScore equ Score+4 				;4 BCD Bytes 8 Digit Hiscore


;SprNum,Spare,Xpos,Ypos,Xacc,Yacc,Prog,ColPrg
PlayerObject equ HiScore+4			;1 Byte		Sprite Number
									;1 Byte		Unused Byte
PlayerX equ PlayerObject+2 			;1 Byte		Player Xpos
PlayerY equ PlayerX+1 				;1 Byte		Player Ypos
PlayerAccX equ PlayerY+1			;1 Byte		Player X acceleration
PlayerAccY equ PlayerAccX+1			;1 Byte		Player Y acceleration
PlayerProgram equ PlayerAccY+1		;1 Byte		Object Movement  Routine
									;1 Byte		Object Collision Routine

LastPosX equ PlayerProgram+2		;: db 0
LastPosY equ LastPosX+1				;: db 0








; CursorY:     db 0
; CursorX:     db 0

; SpriteFrame: db 0

; BulletArray:
	; ds 8*8;,255
; EnemyBulletArray:
	; ds 8*8;,255
	
	
; ObjectArray:
	; ds 40*8


; Invincibility: db 0

; RandomSeed: dw &0
; KeyTimeout: db 0
; Lives: db 0
; Level: db 0
; PlayingSFX: db 0
; PlayingSFX2: db 0
; Score:db &00,&00,&00,&00
; HiScore:db &00,&00,&00,&00

; PlayerObject:
	; ;dw SpriteData
	; db 0	;Sprite num
	; db 0
; ;Current player pos
; PlayerX: db 0
; PlayerY: db 0
; PlayerAccX: db &0
; PlayerAccY: db &0
; PlayerProgram: db 0	
				; db 0 	;Dummy byte for collision action

; ;Last player pos (For clearing sprite)
; LastPosX: db 0
; LastPosY: db 0

