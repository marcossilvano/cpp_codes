PlayerHsprite equ 1

	include "\SrcALL\BasicMacros.asm"

ScreenWidth32 equ 1
ScreenWidth equ 32
ScreenHeight equ 30
ScreenObjWidth equ 128-2
ScreenObjHeight equ 256-24




	;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	;		 --SSTTGG44332211
	move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
	;		 FEDCBA9876543210	
	;				  ST43210		
	move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
	
	move.w #$025,$E80000 	;R00 Horizontal total 
	move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$000,$E80004	;R02 Horizontal display start position
	move.w #$020,$E80006	;R03 Horizontal display end position
	move.w #$103,$E80008	;R04 Vertical total 
	move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$010,$E8000C	;R06 Vertical display start position
	move.w #$100,$E8000E	;R07 Vertical display end position
	move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
	
;Init Hsprites
	move.w #$25,$EB080A		; Sprite H Total
	move.w #$04,$EB080C		; Sprite H Disp
	move.w #$10,$EB080E		; Sprite V Disp
	move.w #$00,$EB0810		; Sprite Res %---FVVHH

	;  	     FEDCBA9876543210	
	move.w #%0000001000000000,$eB0808 ;Disp/CPU 1=sprites on (slow writing)
	
;Palette	
	lea Palette,a3
	move.l #$e82000,a2		;Bitmap palette
	move.l #16-1,d0
PaletteAgain:	
	move.w (a3)+,(a2)+		;GGGGGRRRRRBBBBB- 5 bit per channel
	dbra d0,PaletteAgain
	
;Hsprite Palette
	lea Palette,a3
	move.l #$e82200,a2		;Hardware sprite Palette
	move.l #16-1,d0
HspritePaletteAgain:	
	move.w (a3)+,(a2)+		;GGGGGRRRRRBBBBB- 5 bit per channel
	dbra d0,HspritePaletteAgain
	
;Hsprite Patterns	
	move.l #0,d0		;Tile Number
	lea HSprites,a3		;Sprite Address
	move.l #HSprites_end-HSprites,d2		;Sprite Address
	jsr DefineSprite	;Copy Sprite data to vram
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	lea userram,a3
	move.l #$800,d1
	jsr cldir0				;Clear Game Ram
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
showtitle:
;init game defaults
	move.b #3,(lives)		;Lives=3
									
	clr.l (Score)			;Zero Score
	clr.b (level)			;Level =0

	clr.b (playerobject)	;player sprite
	
	clr.l d0
	jsr chibisound			;mute sound

	jsr cls					;scr clear

;show title screen	
	move.l #titlepic,a3			;Title Tile pic
	move.l #0,d4
titlepixnexty:
	move.l #0,d1
titlepixnextx:
	moveM.l d1/d4/a3,-(sp)
			move.b (a3),d0
			beq titlenosprite
		
			jsr GetSpriteAddr	;Calculate Address of Sprite in Ram
		
			asl.l #2,d1
			asl.l #3,d4
			add.l #16,d4
			jsr showsprite		;Draw Tile to screen
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
	jsr waitforfire			;Wait for fire to be pressed
	jsr cls					
	jsr resetplayer			;Center Player
	jsr levelinit			;Set up enemies
	
	
;Set HSprite numbers
	move.l #2,d4			;Sprite Num (1=Player  2+=objects etc)

	lea bulletarray,a4		;Player Bullets (8)
	move.l #bulletcount,d1
	jsr sethardwaresprites

	lea enemybulletarray,a4	;enemy bullets (8)
	move.l #bulletcount,d1
	jsr sethardwaresprites

	lea objectarray,a4		;objects (40)= 57 sprites total
	move.l #enemies,d1
	jsr sethardwaresprites
	
	
infloop:
	move.l #600,d1			;Loop Delay
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
	move.l #$c00000,a3	  ;Screen Base
	move.l #(1024*256),d1 ;We have to fill the full width of the maximum screen (1024)
	jsr cldir0			  ;Fill With Zeros
	
	
	move.l #40+8+8+1,d0		;Hsprite count
CLS_NextSprite:	
	jsr BlankSpriteHard		;Clear a hardware sprite
	dbra d0,CLS_NextSprite
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0				;Space Char
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0			
		sub.l #32,d0			;No Characters <32
		asl.l #5,d0				;32 bytes per char
		lea FontData,a3			
		add.l d0,a3				;Add offset to font base
		
		clr.l d1
		clr.l d4
		move.b (CursorX),d1		;Get Cursor pos
		move.b (CursorY),d4
		
		asl.l #2,d1				;Multiply up XY pos
		asl.l #3,d4
		jsr showsprite			;Show Character
		
		addq.b #1,(CursorX)		;Move draw position 1 char
	moveM.l (sp)+,d0-d7/a3
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BlankSprite:	
	move.b (O_CollProg,A4),d0
	
	cmp.b #250,d0
	bcs BlankSpriteNoReturn
	rts
BlankSpriteNoReturn:
	move.b (O_HSprNum,a4),d0	;Get Hsprite Number
	
	subq.b #1,d0				;0 = software tile
	cmp.b #128,d0
	bcc BlankSpriteSoft			;255 = Software Tile
	cmp.b #255,d0
	bne BlankSpriteHard			;0-127 = Hardware sprite
BlankSpriteSoft:			
	moveM.l d0-d7,-(sp)
		lea FontData,a3			;Sprite Source (Space)
	jmp DrawBoth

BlankSpriteHard:				;Remove Hsprite
	moveM.l d0-d7,-(sp)
		move.l #0,d1			;XY pos=0 (offscreen)
		move.l #0,d2
		jmp DrawBothHard
		

GetSpriteAddr:
	moveM.l d0-d7,-(sp)
		and.l #$FF,d0
		asl.l #5,d0				;32 bytes per sprite
		lea SpriteData,a3
		add.l d0,a3
		
		clr.l d0
		move.b (SpriteFrame),d0
		asl.l #8,d0				;512 bytes per bank
		asl.l #1,d0
		add.l d0,a3		
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
ShowSprite:
	moveM.l d0-d7,-(sp)
		jmp ShowSpriteB
	
DoGetSpriteObj:				;Get Settings from Object IX
	moveM.l d0-d7,-(sp)
		Move.b (O_SprNum,A4),d0	;Sprite Source
		jsr GetSpriteAddr
	
DrawBoth:
		move.b (O_Xpos,A4),d1
		move.b (O_Ypos,A4),d4
ShowSpriteB:	
		jsr GetScreenPos		;Get Position in Vram
		
		move.l #8-1,d2			;Height
BmpNextLine:			
		move.l #(8/2)-1,d1		;2 pixels per word in 16 color mode
		move.l a2,-(sp)
BmpNextPixel:				;Note, each pixel is 2 bytes in ram
			move.b (a3),d0
			ror #4,d0			;Copy Top Nibble
			move.w d0,(a2)+
			move.b (a3)+,d0		;Copy Bottom Nibble
			move.w d0,(a2)+
			dbra d1,BmpNextPixel
		move.l (sp)+,a2			;Get the left Xpos back
		addA #1024,a2			;Move down a line
		dbra d2,BmpNextLine
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetScreenPos: ; d1=x d4=y.... result in A2
	moveM.l d0-d7,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		rol.l #2,d1				;2 bytes per pixel		
		add.l #$c00000,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a2
		
		rol.l #8,d4				;1024 bytes per Y line 
		rol.l #2,d4
		add.l d4,a2
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
Player_ReadControlsDual:		;Returns: ---7654S321RLDU
	moveM.l d1-d7/a0-a7,-(sp)
		move.l #$E9A001,a0		;Select Joystick # 1
		jsr JoystickProcessOne	;Process buttons
	moveM.l (sp)+,d1-d7/a0-a7
	rts
	
	
	
JoystickProcessOne:			;Returns: ---7654S321RLDU
	clr.l d0	
;	         76543210
	move.b #%00000000,$E9A005	;8255 Port C (Default Controls)
	move.b (a0),d1				;-21-RLDU
	roxr.b d1
	roxr.b d0	;U
	roxr.b d1
	roxr.b d0	;D
	roxr.b d1
	roxr.b d0	;L
	roxr.b d1
	roxr.b d0	;R
	roxr.b #2,d1				;skip -
	roxr.b d0	;F1
	roxr.b d1
	roxr.b d0	;F2
	
	;	     76543210
	move.b #%00110000,$E9A005	;8255 Port C (Get Extra Controls)
	move.b (a0),d1				;-S3-M654 ?
	move.b d1,d3
	roxr.b #6,d1				;-------S 3	
	roxr.b d0	;F3
	roxr.b d1
	roxr.b d0	;Start
	
	and.l #$0000000F,d3			;____M654
	rol.l #8,d3
	
	or.l d3,d0
	or.l #$FFFFF000,d0
	rts	
	
	
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
	

DoGetHSpriteObj:			;Show object A4 as a hardware sprite
	moveM.l d0-d7,-(sp)
		moveM.l d0,-(sp)
			clr.l d0
			move.b (SpriteFrame),d0
			lsl.l #4,d0 			;16 patterns per bank
			add.b (O_SprNum,A4),d0	;Sprite Source
			
			MOVE.l	D0,d3	;Tile pattern
			
		moveM.l (sp)+,d0	;Hsprite Num
		clr.l d1
		clr.l d2
	
		move.b (O_Xpos,A4),d1
		lsl.l #1,d1
		move.b (O_Ypos,A4),d2
		
		add.l #16,d1
		add.l #16,d2
DrawBothHard:
		move.l #0,d4		;Palette
		move.l #3,d5		;Priority

		jsr SetSprite 		;Set Hardware sprite
	moveM.l (sp)+,d0-d7
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	;move.l #1,d0		;Tile Number
	;lea Sprite,a3		;Sprite Address
	;d2=ByteCount
DefineSprite:
	rol.l #7,d0			;Each sprite has 128 bytes of data (&80 bytes)
	add.l #$EB8000,d0	;Base address of sprite vram
	move.l d0,a0
	subq.l #1,d2
	clr.l d0
CopySpriteAgain:		;Copy the data from A3 to the Sprite ram
	move.w (a3)+,(a0)+
	dbra d2,CopySpriteAgain
	rts

	

	; move.l #0,d0		;Hardware Sprite Number
	; move.l #$50,d1	;Xpos
	; move.l #$30,d2	;Ypos
	; move.l #0,d3		;Sprite Pattern
	; move.l #0,d4		;Palette
	; move.l #3,d5		;Priority
	
	
	;D0=SprNum D1,D2=XY pos  D3=Spr Pattern D4= Palette D5 Priority (3=front)	
SetSprite:
	moveM.l d0-d2/a0,-(sp)	
		rol.l #3,d0			;8 bytes per sprite
		add.l #$EB0000,d0
		move.l d0,a0
		
		move.w d1,(a0)+		;------XX XXXXXXXX - X=Xpos
		move.w d2,(a0)+		;------YY YYYYYYYY - Y=Ypos
		
		rol.l #8,d4			;Shift palette into top byte
		add.l d4,d3
		
		move.w d3,(a0)+		;VH--CCCC SSSSSSSS - S=Sprite C=Color V=Vflip H=Hflip
		move.w d5,(a0)+		;-------- ------PP - P=Priority
	moveM.l (sp)+,d0-d2/a0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Hardware Sprite Patterns
HSprites:
	incbin "\ResALL\Yquest\x68Spr_Yquest.RAW"
	incbin "\ResALL\Yquest\x68Spr_Yquest2.RAW"
	incbin "\ResALL\Yquest\x68Spr_Yquest3.RAW"
	incbin "\ResALL\Yquest\x68Spr_Yquest4.RAW"
HSprites_end:
	

	
BitmapData:
FontData:
	incbin "\ResALL\Yquest\MSX2_Font.raw"

SpriteData:
	incbin "\ResALL\Yquest\MSX2_YQuest.raw"
	incbin "\ResALL\Yquest\MSX2_YQuest2.raw"
	incbin "\ResALL\Yquest\MSX2_YQuest3.raw"
	incbin "\ResALL\Yquest\MSX2_YQuest4.raw"
BitmapDataEnd:	
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

Palette:
    dc.w %0000000000000000; ;0  %GGGGGRRRRRBBBBB-
    dc.w %1111100010000010; ;1  %GGGGGRRRRRBBBBB-
    dc.w %0101101011010110; ;2  %GGGGGRRRRRBBBBB-
    dc.w %1010010100101000; ;3  %GGGGGRRRRRBBBBB-
    dc.w %1111111111111110; ;4  %GGGGGRRRRRBBBBB-
    dc.w %1000000101011000; ;5  %GGGGGRRRRRBBBBB-
    dc.w %1101000110001100; ;6  %GGGGGRRRRRBBBBB-
    dc.w %0011011100001100; ;7  %GGGGGRRRRRBBBBB-
    dc.w %0111011100011000; ;8  %GGGGGRRRRRBBBBB-
    dc.w %1010111100010100; ;9  %GGGGGRRRRRBBBBB-
    dc.w %1111111111010010; ;10  %GGGGGRRRRRBBBBB-
    dc.w %0010110100101000; ;11  %GGGGGRRRRRBBBBB-
    dc.w %0000011111111110; ;12  %GGGGGRRRRRBBBBB-
    dc.w %0011000000110100; ;13  %GGGGGRRRRRBBBBB-
    dc.w %0110000111101100; ;14  %GGGGGRRRRRBBBBB-
    dc.w %1101000000111110; ;15  %GGGGGRRRRRBBBBB-
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "YQ_Multiplatform2.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\SrcALL\Multiplatform_BCD.asm"
	include "\SrcALL\BasicFunctions.asm"	
	include "\SrcALL\MultiPlatform_ShowDecimal.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "YQ_DataDefs.asm"
	even
	
	include "YQ_RamDefs.asm"
	even
	
UserRam:
	ds $800
	
	
	
	