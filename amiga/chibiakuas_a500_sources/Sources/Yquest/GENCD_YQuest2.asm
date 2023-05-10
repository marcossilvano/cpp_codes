	include "\SrcALL\BasicMacros.asm"
PlayerHsprite equ 1


ScreenWidth40 equ 1
ScreenWidth equ 40
ScreenHeight equ 28
ScreenObjWidth equ 160-4
ScreenObjHeight equ 232-16


UserRam equ $00FFF000

;Video Ports
VDP_data	EQU	$C00000	; VDP data, R/W word or longword access only
VDP_ctrl	EQU	$C00004	; VDP control, word or longword writes only

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;org $00FF0000-$200
	org $00200000-$200
	
	
	
	;incbin "X:\BldGEN\template_E.iso"	;Eur
	incbin "X:\BldGEN\template_J.iso"	;Jpn
	;incbin "X:\BldGEN\template_U.iso"	;USA
	
	nop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Program Start
	
	
ProgramStart:
	;initialize TMSS (TradeMark Security System)
	move.b ($A10001),D0		;A10001 test the hardware version
	and.b #$0F,D0
	beq	NoTmss				;branch if no TMSS chip
	move.l #'SEGA',($A14000);A14000 disable TMSS 
NoTmss:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Set Up Graphics

	lea VDPSettings,A5		;Initialize Screen Registers
	move.l #VDPSettingsEnd-VDPSettings,D1 ;length of Settings
	
	move.w (VDP_ctrl),D0	;C00004 read VDP status (interrupt acknowledge?)
	move.l #$00008000,d5	;VDP Reg command (%8rvv)
	
NextInitByte:
	move.b (A5)+,D5			;get next video control byte
	move.w D5,(VDP_ctrl)	;C00004 send write register command to VDP
		;   8RVV - R=Reg V=Value
	add.w #$0100,D5			;point to next VDP register
	dbra D1,NextInitByte	;loop for rest of block

		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Set up palette
	
	;Define palette
	lea Palette,a1
	move.l #16,d1
	move.l #$C0000000,d0	;Color 0
PaletteAgain:
	
	move.l d0,(VDP_Ctrl)
	move.w (a1)+,(VDP_data)	;----BBB-GGG-RRR-
	add.l #$00020000,d0
	dbra d1,PaletteAgain
	
	
	lea BitmapData,a0					;Source data
	move.w #BitmapDataEnd-BitmapData,d1
	move.l #0*32,d2				;32 bytes per tile
	jsr DefineTiles	
	
	
;Init Sprite Links - link of each visible sprite must point to the last.
	
	move.l #40+8+8+1,d0
LinkNextSprite:	
	jsr BlankSpriteHard
	dbra d0,LinkNextSprite
	
	MOVE.W	#$8144,(VDP_Ctrl)	;C00004 reg 1 = 0x44 unblank display
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

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
		jsr GetSpriteAddr	;Get Tile number
		
		add.l #1,d4			;Move down a line
		jsr showsprite		;SHow Sprite to Screen
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
	move.l #$1202+1,d3
	jsr locate
	lea txtfire,a3			;show press fire
	jsr printstring

	move.l #$0018+1,d3
	jsr locate
	lea txturl,a3			;show url
	jsr printstring

	move.l #$1818+1,d3
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
	Move.L  #$40000003,d0		;$C000 offset + Vram command
	MOVE.L	D0,(VDP_ctrl)		; C00004 Get VRAM address
	move.l #32*28*2,d1
ClsAgain:
	clr.W	(VDP_data)		; C00000 Select tile for mem loc
	dbra d1,ClsAgain
		
	move.l #40+8+8+1,d0
CLS_NextSprite:	
	jsr BlankSpriteHard		;Clear Hardware sprites
	dbra d0,CLS_NextSprite
	
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0
		sub.l #32,d0
		clr.l d1
		clr.l d4
		move.b (CursorX),d1
		move.b (CursorY),d4
		
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
	move.b (O_HSprNum,a4),d0;Get Hsprite Number
	
	subq.b #1,d0			;0 = software tile
	cmp.b #128,d0
	bcc BlankSpriteSoft		;255 = Software Tile
	cmp.b #255,d0
	bne BlankSpriteHard		;0-127 = Hardware sprite
BlankSpriteSoft:		
	moveM.l d0-d7,-(sp)
		move.l #0,d0		;Sprite Source (Space)
	jmp DrawBoth
	
BlankSpriteHard:			;Remove Hsprite
	moveM.l d0-d7,-(sp)
		move.l #0,d1		;Move Sprite offscreen
		move.l #0,d2
		jmp DrawBothHard

GetSpriteAddr:
	and.l #$FF,d0
	add.l #96,d0		;First 32 patterns are font
	clr.l d7
	move.b (SpriteFrame),d7
	asl.l #4,d7
	add.l d7,d0			;16 tiles per bank
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
		lsr.b #2,d1
		lsr.b #3,d4
ShowSpriteB:	
	
		Move.L  #$40000003,d5		;$C000 offset + Vram command
		clr.L d7
		
		Move.B d4,D7				
		rol.L #8,D7					; Calculate Ypos
		rol.L #8,D7
		rol.L #7,D7
		add.L D7,D5
		
		clr.L d7
		move.B d1,D7				;Calculate Xpos
		rol.L #8,D7
		rol.L #8,D7
		rol.L #1,D7
		add.L D7,D5
	
		MOVE.L	D5,(VDP_ctrl)		; C00004 Get VRAM address
		MOVE.W	D0,(VDP_data)		; C00000 Select tile for mem loc
		
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
Player_ReadControlsDual:		;Returns: ---7654S321RLDU
	moveM.l d1-d7/a0-a7,-(sp)
		move.b #%01000000,($A10009)	; Set direction IOIIIIII (I=In O=Out)
		move.l #$A10003,a0		;RW port for player 1
		jsr Player_ReadOne		;Read buttons
	moveM.l (sp)+,d1-d7/a0-a7
	rts
	
	
Player_ReadOne:			;Read in and reformat a players buttons
	move.b  #$40,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b  (a0),d2		; d0.b = --CBRLDU	Store in D2
	
	move.b	#$0,(a0)	; TH = 0
	nop		;Delay
	nop
	move.b	(a0),d1		; d1.b = --SA--DU	Store in D1
	
	move.b  #$40,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b	#$0,(a0)	; TH = 0
	nop		;Delay
	nop
	move.b  #$40,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b	(a0),d3		; d1.b = --CBXYZM	Store in D3
	move.b	#$0,(a0)	; TH = 0
	
	clr.l d0			;Clear buildup byte
	roxr.b d2
	roxr.b d0			;U
	roxr.b d2
	roxr.b d0			;D
	roxr.b d2
	roxr.b d0			;L
	roxr.b d2
	roxr.b d0			;R
	roxr.b #5,d1
	roxr.b d0			;A
	roxr.b d2
	roxr.b d0			;B
	roxr.b d2
	roxr.b d0			;C
	roxr.b d1
	roxr.b d0			;S
	
	move.l d3,d1
	roxl.l #7,d1		;XYZ
	and.l #%0000011100000000,d1
	or.l d1,d0			
	
	move.l d3,d1
	roxl.l #8,d1		;M
	roxl.l #3,d1		
	and.l #%0000100000000000,d1
	or.l d1,d0
	
	or.l #$FFFFF000,d0	;Set unused bits to 1
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


DoGetHSpriteObj:
	moveM.l d0-d7,-(sp)
		moveM.l d0,-(sp)
			Move.b (O_SprNum,A4),d0	;Sprite Source
			jsr GetSpriteAddr		;Hspr use Tile Patterns 
			MOVE.l	D0,d3			;Tile
		moveM.l (sp)+,d0			;Hsprite
		clr.l d1
		clr.l d2
		clr.l d4
	
		move.b (O_Xpos,A4),d1
		lsl.l #1,d1					;Double logical Xpos
		move.b (O_Ypos,A4),d2
		
		add.l #128,d1				;Top left screenpos
		add.l #128,d2
DrawBothHard:	

;Each visible sprite must link to next	
		move.b d0,d4
		addq.b #1,d4		;Chain to next sprite
		cmp.b #40+8+8+1,d4
		bne LinkOk
		clr.l d4			;Chain last sprite to 1st
LinkOk:		
		jsr SetSprite
	moveM.l (sp)+,d0-d7
	rts
	
		
	
SetSprite:	;D0=SpriteNumber, (D1,D2)=(X,Y) D3=Tilenum D4=Link to next sprite
	move.l d2,-(sp)
		move.b d0,d2		;Hardware Spr Num
		and.l #$FF,d2
		lsl.l #3,d2			;8 bytes per Sprite
		add.l #$D800,d2		;Base Sprite Address
		jsr prepareVram
	move.l (sp)+,d2
	
	move.w d2,(VDP_data)	; ------VV VVVVVVVV - Vpos
	move.w d4,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
	move.w d3,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
	move.w d1,(VDP_data)	; -------H HHHHHHHH - Hpos
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


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


DefineTiles:						;Copy D1 bytes of data from A0 to VDP memory D2 

	jsr prepareVram					;Calculate the memory location we want to write
DefineTilesAgain:						; the tile pattern definitions to
		move.l (a0)+,d0				
		move.l d0,(VDP_data)		;Send the tile data to the VDP
		dbra d1,DefineTilesAgain
		
	rts
			
prepareVram:							;To select a memory location D2 we need to calculate 
										;the command byte... depending on the memory location
	moveM.l d0-d2,-(sp)			;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
		move.l d2,d0
		and.w #%1100000000000000,d0		;Shift the top two bits to the far right 
		rol.w #2,d0
		
		and.l #%0011111111111111,d2	    ; shift all the other bits left two bytes
		rol.l #8,d2		
		rol.l #8,d2
		
		or.l d0,d2						
		or.l #$40000000,d2				;Set the second bit from the top to 1
										;#%01000000 00000000 00000000 00000000
		move.l d2,(VDP_ctrl)
	moveM.l (sp)+,d0-d2
	rts
	
	
	
VDPSettings:
	DC.B $04 ; 0 mode register 1											---H-1M-
	DC.B $04 ; 1 mode register 2											-DVdP---
	DC.B $30 ; 2 name table base for scroll A (A=top 3 bits)				--AAA--- = $C000
	DC.B $3C ; 3 name table base for window (A=top 4 bits / 5 in H40 Mode)	--AAAAA- = $F000
	DC.B $07 ; 4 name table base for scroll B (A=top 3 bits)				-----AAA = $E000
	DC.B $6C ; 5 sprite attribute table base (A=top 7 bits / 6 in H40)		-AAAAAAA = $D800
	DC.B $00 ; 6 unused register											--------
	DC.B $00 ; 7 background color (P=Palette C=Color)						--PPCCCC
	DC.B $00 ; 8 unused register											--------
	DC.B $00 ; 9 unused register											--------
	DC.B $FF ;10 H interrupt register (L=Number of lines)					LLLLLLLL
	DC.B $00 ;11 mode register 3											----IVHL
	DC.B $81 ;12 mode register 4 (C bits both1 = H40 Cell)					C---SIIC
	DC.B $37 ;13 H scroll table base (A=Top 6 bits)							--AAAAAA = $FC00
	DC.B $00 ;14 unused register											--------
	DC.B $02 ;15 auto increment (After each Read/Write)						NNNNNNNN
	DC.B $01 ;16 scroll size (Horiz & Vert size of ScrollA & B)				--VV--HH = 64x32 tiles
	DC.B $00 ;17 window H position (D=Direction C=Cells)					D--CCCCC
	DC.B $00 ;18 window V position (D=Direction C=Cells)					D--CCCCC
	DC.B $FF ;19 DMA length count low										LLLLLLLL
	DC.B $FF ;20 DMA length count high										HHHHHHHH
	DC.B $00 ;21 DMA source address low										LLLLLLLL
	DC.B $00 ;22 DMA source address mid										MMMMMMMM
	DC.B $80 ;23 DMA source address high (C=CMD)							CCHHHHHH
VDPSettingsEnd:
	even
	

Palette:
    dc.w %0000000000000000; ;0  %----BBB-GGG-RRR-
    dc.w %0000000011100000; ;1  %----BBB-GGG-RRR-
    dc.w %0000010001000100; ;2  %----BBB-GGG-RRR-
    dc.w %0000101010101010; ;3  %----BBB-GGG-RRR-
    dc.w %0000111011101110; ;4  %----BBB-GGG-RRR-
    dc.w %0000011010000010; ;5  %----BBB-GGG-RRR-
    dc.w %0000001011000010; ;6  %----BBB-GGG-RRR-
    dc.w %0000001000101110; ;7  %----BBB-GGG-RRR-
    dc.w %0000011001101110; ;8  %----BBB-GGG-RRR-
    dc.w %0000010010101110; ;9  %----BBB-GGG-RRR-
    dc.w %0000010011101110; ;10  %----BBB-GGG-RRR-
    dc.w %0000101000101010; ;11  %----BBB-GGG-RRR-
    dc.w %0000111000001110; ;12  %----BBB-GGG-RRR-
    dc.w %0000110000100000; ;13  %----BBB-GGG-RRR-
    dc.w %0000101001100010; ;14  %----BBB-GGG-RRR-
    dc.w %0000111011000000; ;15  %----BBB-GGG-RRR-


	
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
	
	

	org $240000