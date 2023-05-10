	include "\SrcALL\BasicMacros.asm"

ScreenWidth32 equ 1
ScreenWidth equ 32
ScreenHeight equ 32
ScreenObjWidth equ 128-2
ScreenObjHeight equ 256-8

UserRam equ $30000	

;We're using the ProgramStart to calculate relative address for the LevelData
;This is because we don't know the execute address of the Sinclar Ql version.

ProgramStart:	
	move.b #%00001000,$18063	;Force 8 color mode!
	
	lea userram,a3
	move.l #$800,d1
	jsr cldir0				;Clear Game Ram
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
showtitle:
;init game defaults
	move.b #3,(lives)
									
	clr.l (Score)
	clr.b (level)

	clr.b (playerobject)	;player sprite
	clr.l d0

	jsr chibisound			;mute sound

	jsr cls					;scr clear

;show title screen	
	move.l #titlepic,a3
	move.l #0,d4
titlepixnexty:
	move.l #0,d1
titlepixnextx:
	moveM.l d1/d4/a3,-(sp)
		move.b (a3),d0
		beq titlenosprite
	
		jsr GetSpriteAddr	;Calculate sprite address
	
		asl.l #1,d1			;Xpos * 2
		asl.l #3,d4			;Ypos * 8
		add.l #16,d4
		jsr showsprite
titlenosprite:
	moveM.l (sp)+,d1/d4/a3
	addq.l #1,a3
	addq.l #1,d1
	cmp.l #screenwidth,d1
	bne titlepixnextx
	addq.l #1,d4	
	cmp.l #24,d4
	bne titlepixnexty

;Text Messages
	move.l #$0D12,d3
	jsr locate
	lea txtfire,a3			;show press fire
	jsr printstring

	move.l #$1201,d3
	jsr locate
	lea txturl,a3			;show url
	jsr printstring

	move.l #$001C,d3
	jsr locate
	lea txthiscore,a3
	jsr printstring 		;show the highscore
	lea HiScore,a0		
    move.l #3,d1
    jsr BCD_Show
	
startlevel:
	jsr waitforfire
	jsr cls
	jsr resetplayer			;Center Player
	jsr levelinit			;Set up enemies
	
infloop:
	move.l #12,d1			;Loop Delay
	move.l #%11111111,d2	;KeyPress
pausebc:

	jsr Player_ReadControlsDual
	
	cmp.b #%11111111,d0		;Key Pressed?
	beq pausenokey
	move.b d0,d2			;Save keypresses
pausenokey:
	dbra d1,pausebc
	
startdraw:
	movem.l d2,-(sp)
		jsr drawui			;Show User Interface

		lea playerobject,a4
		jsr blanksprite		;Remove old player sprite
	movem.l (sp)+,d2
	
	cmp.b #0,(keytimeout)	;ignore UDLR during key timeout
	beq processkeys
	subq.b #1,(keytimeout)
	jmp joyskip				;skip player input

processkeys:
	move.l #playeraccy,a3
	move.l #0,d5			;Key Timeout

	btst #0,d2				;4321RLDU
	bne joynotup
	move.b (a3),d0
	sub.b #1,d0				;Left
	move.b d0,(a3)
	move.l #5,d5
joynotup:
	btst #1,d2				;4321RLDU
	bne joynotdown
	move.b (a3),d0
	add.b #1,d0				;Right
	move.b d0,(a3)
	move.l #5,d5
joynotdown:
	move.l #playeraccx,a3
	btst #2,d2				;4321RLDU
	bne joynotleft
	move.b (a3),d0
	sub.b #1,d0				;Up
	move.b d0,(a3)
	move.l #5,d5
joynotleft:
	btst #3,d2				;4321RLDU
	bne joynotright
	move.b (a3),d0
	add.b #1,d0				;Down
	move.b d0,(a3)
	move.l #5,d5
joynotright:	
	btst #4,d2				;4321RLDU
	bne joynotfire
	jsr playerfirebullet	;Fire a bullet
joynotfire:
	btst #5,d2
	bne joynotfire2
	clr.b (playeraccx)		;Stop movement
	clr.b (playeraccy)
joynotfire2:
	move.b d5,(keytimeout)	;Update KeyTimeout
	
joyskip:
	jsr drawandmove			;Draw objects
	jmp infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Cls:
	move.l #$00020000,a3	;Address to clear
	move.l #(256*128),d1	;Bytes to clear
	jsr cldir0
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0
		sub.l #32,d0			;No character before space
		asl.l #5,d0				;32 bytes per char 
		lea FontData,a3
		add.l d0,a3
		
		clr.l d1
		clr.l d4
		move.b (CursorX),d1
		move.b (CursorY),d4
		
		asl.l #1,d1				;Xpos * 2
		asl.l #3,d4				;Ypos * 8
		jsr showsprite
		
		addq.b #1,(CursorX)
	moveM.l (sp)+,d0-d7/a3
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BlankSprite:	
	move.b (O_CollProg,A4),d0
	
	cmp.b #250,d0
	bcs BlankSpriteNoReturn
	rts
BlankSpriteNoReturn:
	moveM.l d0-d7,-(sp)
		lea FontData,a3	;Sprite Source (Space)
	jmp DrawBoth


GetSpriteAddr:
	moveM.l d0-d7,-(sp)
		and.l #$FF,d0
		asl.l #5,d0					;32 bytes per sprite
		lea SpriteData,a3
		add.l d0,a3
		
		clr.l d0
		move.b (SpriteFrame),d0
		asl.l #8,d0					;512 bytes per bank
		asl.l #1,d0
		add.l d0,a3
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
ShowSprite:					;Show Sprite A0 at (D1,D4)
	moveM.l d0-d7,-(sp)
		jmp ShowSpriteB
	
DoGetSpriteObj:				;Get Settings from Object A4
	moveM.l d0-d7,-(sp)
		Move.b (O_SprNum,A4),d0	;Sprite Source
		jsr GetSpriteAddr
	
DrawBoth:
		move.b (O_Xpos,A4),d1	;Get Xpos from A4
		lsr.b #1,d1
		move.b (O_Ypos,A4),d4	;Get Ypos from A4
ShowSpriteB:	
		jsr GetScreenPos		;Get Position in Vram
		move.l #8-1,d2			;Height
BmpNextLine:
		move.l (a3)+,(a2)		
		add.l #128,a2			;Add 128 to move down a line
		dbra d2,BmpNextLine
	moveM.l (sp)+,d0-d7
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos: ; d1=x d2=y - returns result in A2
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		rol.l #1,d1				;Multiply X*2 (2 bytes per 4/8 pixels)
		rol.l #7,d4				;Multiply Y*128
		
		move.l #$00020000,a2	;Screen starts at $20000
		add.l d4,a2
		add.l d1,a2
	moveM.l (sp)+,d1-d4
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Player_ReadControlsDual:;---7654S321RLDU
	moveM.l d1-d2,-(sp)	
		 lea QLJoycommand,a3
		 move.b #$11,d0	;Command 17
		 Trap #1		;Send Keyrequest to the IO CPU
						;Returns row in D1
		
		clr.l d0		;D0 is our result
		move.b d1,d2
		roxr.b #4,d2	; ESC
		roxl.b #1,d0	;Start (4)
		
		roxr.b #2,d2	; \ 
		roxl.b #1,d0	;Fire 3 (6)
		
		move.b d1,d2
		roxr.b #1,d2	; Enter (1)
		roxl.b #1,d0	;Fire 2
		
		roxr.b #6,d2	;Space (7)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #5,d2	;Right (5)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #2,d2	;Left (2)
		roxl.b #1,d0
		
		roxr.b #6,d2	;Down (8)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #3,d2	;Up   (3)
		roxl.b #1,d0
		
		move.l #$FFFFFFFF,d1	;Dummy player2
		eor.l d1,d0		;Flip Player 1 bits
	moveM.l (sp)+,d1-d2
	rts
	
QLJoycommand:
	dc.b $09	;0 - Command
	dc.b $01	;1 - parameter bytes
	dc.l 0		;2345 - send option (%00=low nibble)
	dc.b 1		;6 - Parameter: Row
	dc.b 2		;7 - length of reply (%10=8 bits)
	even
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
waitforfire:

	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	bne waitforfire

waitforfireb:
	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	beq waitforfireb
	rts



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BitmapData:
FontData:
	incbin "\ResALL\Yquest\FontSQL.RAW"

SpriteData:
	incbin "\ResALL\Yquest\SQL_YQuest.raw"
	incbin "\ResALL\Yquest\SQL_YQuest2.raw"
	incbin "\ResALL\Yquest\SQL_YQuest3.raw"
	incbin "\ResALL\Yquest\SQL_YQuest4.raw"
BitmapDataEnd:	
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "YQ_Multiplatform.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\SrcALL\Multiplatform_BCD.asm"
	include "\SrcALL\BasicFunctions.asm"	
	include "\SrcALL\MultiPlatform_ShowDecimal.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "YQ_DataDefs.asm"
	even
	
	include "YQ_RamDefs.asm"
	even
	