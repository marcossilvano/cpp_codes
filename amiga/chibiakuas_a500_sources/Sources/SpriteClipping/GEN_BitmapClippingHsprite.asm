	include "\SrcALL\BasicMacros.asm"


VscreenMinX equ 48-4		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80-4

VscreenWid equ 160+4		;Visible Screen Size in logical units
VscreenHei equ 96+24-4

VscreenWidClip equ 0
VscreenHeiClip equ 0



;Ram Variables
PlayerX  equ $00FF0000		;Ram for Cursor Xpos
PlayerY  equ $00FF0000+2	;Ram for Cursor Ypos

;Ram Variables
Cursor_X equ $00FF0000+4		;Ram for Cursor Xpos
Cursor_Y equ $00FF0000+8	;Ram for Cursor Ypos
spritehclip equ $00FF0000+2	;Sprite Clipping 


;Video Ports
VDP_data	EQU	$C00000	; VDP data, R/W word or longword access only
VDP_ctrl	EQU	$C00004	; VDP control, word or longword writes only

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 					Traps
	DC.L	$FFFFFE00		;SP register value
	DC.L	ProgramStart	;Start of Program Code
	DS.L	7,IntReturn		; bus err,addr err,illegal inst,divzero,CHK,TRAPV,priv viol
	DC.L	IntReturn		; TRACE
	DC.L	IntReturn		; Line A (1010) emulator
	DC.L	IntReturn		; Line F (1111) emulator
	DS.L	4,IntReturn		; Reserverd /Coprocessor/Format err/ Uninit Interrupt
	DS.L	8,IntReturn		; Reserved
	DC.L	IntReturn		; spurious interrupt
	DC.L	IntReturn		; IRQ level 1
	DC.L	IntReturn		; IRQ level 2 EXT
	DC.L	IntReturn		; IRQ level 3
	DC.L	IntReturn		; IRQ level 4 Hsync
	DC.L	IntReturn		; IRQ level 5
	DC.L	IntReturn		; IRQ level 6 Vsync
	DC.L	IntReturn		; IRQ level 7 
	DS.L	16,IntReturn	; TRAPs
	DS.L	16,IntReturn	; Misc (FP/MMU)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Header
	DC.B	"SEGA GENESIS    "	;System Name
	DC.B	"(C)CHBI "			;Copyright
 	DC.B	"2019.JAN"			;Date
	DC.B	"ChibiAkumas.com                                 " ; Cart Name
	DC.B	"ChibiAkumas.com                                 " ; Cart Name (Alt)
	DC.B	"GM CHIBI001-00"	;TT NNNNNNNN-RR T=Type (GM=Game) N=game Num  R=Revision
	DC.W	$0000				;16-bit Checksum (Address $000200+)
	DC.B	"J               "	;Control Data (J=3button K=Keyboard 6=6button C=cdrom)
	DC.L	$00000000			;ROM Start
	DC.L	$003FFFFF			;ROM Length
	DC.L	$00FF0000,$00FFFFFF	;RAM start/end (fixed)
	DC.B	"            "		;External RAM Data
	DC.B	"            "		;Modem Data
	DC.B	"                                        " ;MEMO
	DC.B	"JUE             "	;Regions Allowed

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Generic Interrupt Handler
IntReturn:
	rte
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
	move.l #$C0000000,d0	;Color 0
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000000000000000,VDP_data
			
	move.l #$C0020000,d0	;Color 1
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000011000000110,VDP_data
	
	move.l #$C0040000,d0	;Color 2
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000111011100000,VDP_data
	
	move.l #$C0060000,d0	;Color 3
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000111011101110,VDP_data
	
	move.l #$C01E0000,d0	;Color 15 (Font)
	move.l d0,VDP_Ctrl
	move.w #%0000000011101110,VDP_data
	
	MOVE.W	#$8144,(VDP_Ctrl)				; C00004 reg 1 = 0x44 unblank display
	
	lea Bitmap,a0					;Source data
	move.w #BitmapEnd-Bitmap,d1
	move.l #256*32,d2				;32 bytes per tile
	jsr DefineTiles	
	
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Set up Font
	lea Font,A1					 ;Font Address in ROM
	move.l #Font_End-Font,d6	 ;Our font contains 96 letters 8 lines each
	
	move.l #$40000000,(VDP_Ctrl);Start writes to address $0000
								;(Patterns in Vram)
NextFont:
	move.b (A1)+,d0		;Get byte from font
	moveq.l #7,d5		;Bit Count (8 bits)
	clr.l d1			;Reset BuildUp Byte
	
Font_NextBit:			;1 color per nibble = 4 bytes

	rol.l #3,d1			;Shift BuildUp 3 bits left
	roxl.b #1,d0		;Shift a Bit from the 1bpp font into the Pattern
	roxl.l #1,d1		;Shift bit into BuildUp
	dbra D5,Font_NextBit;Next Bit from Font
	
	move.l d1,d0		; Make fontfrom Color 1 to color 15
	rol.l #1,d1			;Bit 1
	or.l d0,d1
	rol.l #1,d1			;Bit 2
	or.l d0,d1
	rol.l #1,d1			;Bit 3
	or.l d0,d1
	
	move.l d1,(VDP_Data);Write next Long of char (one line) to VDP
	dbra d6,NextFont	;Loop until done

	

	clr.b Cursor_X			;Clear Cursor XY
	clr.b Cursor_Y
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	move.w #VscreenMinX,(PlayerX)	;x
	move.w #VscreenMinY,(PlayerY)	;y
	
	
	move.b #%00001111,d3
	jmp StartDraw			;Force sprite draw on first run
		
InfLoop:
	moveM.l d0-d2/a0-a5,-(sp)
		jsr Player_ReadControlsDual	;Read Joystick
		move.b d0,d3
	moveM.l (sp)+,d0-d2/a0-a5
	and.b #%00001111,d3		;Directions only
	cmp.b #%00001111,d3
	beq InfLoop				;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1				;Back up X
	move.w (PlayerY),d4				;Back up Y

	
	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	

	Move.w d1,(PlayerX)
	Move.w d4,(PlayerY)
	
PlayerPosYOk:	
	jsr DrawPlayer			;Deaw player sprite
	moveM.l d0-d7/a0-a5,-(sp)
		clr.b Cursor_X			;Clear Cursor XY
		clr.b Cursor_Y
	
		jsr Monitor		;D5=Spritecount
	
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	
	move.l #$2FFF,d7	;Wait a bit
	jsr PauseD1
	
	jmp InfLoop
PauseD1:
	dbra d7,PauseD1
	rts
	
	
BlankPlayer:	
	move.l #0,d7		;TileStart Number
	jmp DrawPlayer2
DrawPlayer:
	move.l #256+1,d7	;TileStart Number
DrawPlayer2:

	move.l #24,d3	;WID
	move.l #24,d6	;HEI		
	
	jsr docrop
	bcs DrawSpriteAbort

FillAreaWithTiles:		;Set area (d0,d1) Wid:d2 Hei:D3
	and.l #$FF,d1				;Convert all to bytes
	and.l #$FF,d4			
	and.l #$FF,d3
	and.l #$FF,d6
		
	lsl.l #1,d1					;Convert to Pixels
	lsl.l #1,d4
		
	add.l #128-8,d1				;Top left screenpos
	add.l #128-8,d4
		
	lsr.l #2,d3					;Width to Tiles
	beq DrawSpriteAbort
	lsr.l #2,d6					;Height to Tiles
	beq DrawSpriteAbort
		
	move.l #0,d5				;Hsprite Num
		
		  ;PCCVHNNNNNNNNNNN 
	or.w #%1000000000000000,d7	;Set Priority
	
		
	subq.l #1,d3				;Reduce our counters by 1 for dbra
	subq.l #1,d6		
NextTileLine:
	movem.l d1/d3,-(sp)			 ;Width
		
NextTileb:
		move.l d2,-(sp)
		move.b d5,d2			;Hardware Spr Num
		and.l #$FF,d2
		lsl.l #3,d2				;8 bytes per Sprite
		add.l #$D800,d2			;Base Sprite Address
		jsr prepareVram
		move.l (sp)+,d2

		addq.w #1,d5			 ;Increase Hsprite
		
		move.w d4,(VDP_data)	; ------VV VVVVVVVV - Vpos
		move.w d5,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
		move.w d7,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
		move.w d1,(VDP_data)	; -------H HHHHHHHH - Hpos
		
		addq.w #1,d7			;Increase Tilenum
		add.w #8,d1			 	;Move across 8 pixels
		
		dbra d3,NextTileb
		clr.l d0
		move.b (spritehclip),d0
		add.w d0,d7
		
		add.w #8,d4			 	;Move down 8 pixels
	movem.l (sp)+,d1/d3
	dbra d6,NextTileLine	 	;Do next line

	;Loop back to start of sprites
	move.w #0,(VDP_data)	; ------VV VVVVVVVV - Vpos
	move.w #0,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
	move.w #0,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
	move.w #0,(VDP_data)	; -------H HHHHHHHH - Hpos
	rts
	
	
DrawSpriteAbort:
	move.l #$D800,d2		;Base Sprite Address
	jsr prepareVram

	;Loop back to start of sprites
	move.w #0,(VDP_data)	; ------VV VVVVVVVV - Vpos
	move.w #0,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
	move.w #0,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
	move.w #0,(VDP_data)	; -------H HHHHHHHH - Hpos

	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
Font:							;1bpp font - 8x8 96 characters 
	incbin "\ResALL\Font96.FNT"
Font_End:		

Bitmap:
	dc.b $00,$03,$30,$00
	dc.b $00,$03,$30,$00
	dc.b $00,$03,$30,$00
	dc.b $33,$30,$03,$33
	dc.b $33,$30,$03,$33
	dc.b $00,$03,$30,$00
	dc.b $00,$03,$30,$00
	dc.b $00,$03,$30,$00
	


	incbin "\ResALL\Sprites\RawMSXVdp.RAW"
BitmapEnd:
	even
	

DefineTiles:						;Copy D1 bytes of data from A0 to VDP memory D2 

	jsr prepareVram					;Calculate the memory location we want to write
DefineTilesAgain:						; the tile pattern definitions to
		move.l (a0)+,d0				
		move.l d0,(VDP_data)		;Send the tile data to the VDP
		dbra d1,DefineTilesAgain
		
	rts
			
prepareVram:							;To select a memory location D2 we need to calculate 
										;the command byte... depending on the memory location
	moveM.l d0-d7/a0-a7,-(sp)			;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
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
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
	
	
Player_ReadControlsDual:		;D0=1up D1=2up ---7654S321RLDU
	
	move.b #%01000000,($A1000B)	; Set direction IOIIIIII (I=In O=Out)
	move.l #$A10005,a0			;RW port for player 2
	jsr Player_ReadOne			;Read buttons
	
	move.l d0,-(sp)
		move.b #%01000000,($A10009)	; Set direction IOIIIIII (I=In O=Out)
		move.l #$A10003,a0		;RW port for player 1
		jsr Player_ReadOne		;Read buttons
	move.l (sp)+,d1
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
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		

	;;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6
docrop:
	clr.l d2					;D5=top D2=bottom crop
	clr.l d5
	clr.b (spritehclip)			;H-clip
	
;crop top side
	clr.l d0
	move.b d4,d0				;X-pos
	sub.b #vscreenminy,d0		;>minimum co-odinate
	bcc notcrop					;nc=nothing needs cropping
	neg.b d0
	add #2,d0
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	
	move.b d0,d5				;top crop
	and.l #%00000011,d0			;Draw 7 offscreen pixels
	eor.l #%00000011,d0
notcrop:
	move.b d0,d4				;Draw Ypos
	
	
;crop bottom hand side
	add.b d6,d0					;Add Height
	sub.b #vscreenhei-vscreenheiclip,d0	;logical height of screen
	bcs nobcrop					;c=nothing needs cropping
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d2				;amount to remove from bottom 
nobcrop:

;Calculate new height
	clr.l d0
	move.b d5,d0				;units to remove from top
	add.b d2,d0					;units to remove from bottom
	and.l #%11111100,d0
	beq novclip					;nothing to remove?
	sub.b d0,d6					;subtract from old height
	
	lsr.b #2,d5					;Amount to remove from top
	
	mulu d3,d5					;Calculate amount to remove 
								;(Lines*BytesPerLine)

	lsr.b #2,d5					;Convert to no of tiles
	add.l d5,d7
	
NoVClip:
	clr.l d2
	clr.l d5

;crop left hand side
	move.b d1,d0
	sub.b #vscreenminx,d0		;remove left virtual border
	bcc nolcrop					;nc=nothing needs cropping
	neg.b d0					;Amount to remove
	add #2,d0
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	
	move.b d0,d5
	and.l #%00000011,d0			;Draw 7 offscreen pixels
	eor.l #%00000011,d0
nolcrop:
	move.b d0,d1				;Draw Xpos
	
;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreeneen?
	move.b d0,d2
	
norcrop:
	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	and.l #%11111100,d0
	beq nohclip					;nothing to crop?
	
	move.b d0,d2			;amount to subtract from width (right)
	
	lsr.b #2,d0
	move.b d0,(spritehclip)		;Tiles to skip after each line

	sub.b d2,d3					;Update Width

;amount to subtract from left
	lsr.l #2,d5					;No of tiles
	add.l d5,d7					;move across 
	
	
nohclip:

	andi #%11111110,ccr		;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr		;set carry (nothing to draw)
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
PrintChar:				;Show D0 to screen
	moveM.l d0-d7/a0-a7,-(sp)
		and.l #$FF,d0			;Keep only 1 byte
		sub #32,d0				;No Characters in our font below 32
PrintCharAlt:		
		Move.L  #$40000003,d5	;top 4=write, bottom $3=Cxxx range
		clr.l d4					;Tilemap at $C000+

		Move.B (Cursor_Y),D4	
		rol.L #8,D4				;move $-FFF to $-FFF----
		rol.L #8,D4
		rol.L #7,D4				;2 bytes per tile * 64 tiles per line
		add.L D4,D5				;add $4------3
		
		Move.B (Cursor_X),D4
		rol.L #8,D4				;move $-FFF to $-FFF----
		rol.L #8,D4
		rol.L #1,D4				;2 bytes per tile
		add.L D4,D5				;add $4------3
		
		MOVE.L	D5,(VDP_ctrl)	; C00004 write next character to VDP
		;or.w #%0000000000000000,d0
		MOVE.W	D0,(VDP_data)	; C00000 store next word of name data

		addq.b #1,(Cursor_X)	;INC Xpos
		move.b (Cursor_X),d0
		cmp.b #39,d0
		bls nextpixel_Xok
		jsr NewLine			;If we're at end of line, start newline
nextpixel_Xok:
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
PrintString:
		move.b (a3)+,d0			;Read a character in from A3
		cmp.b #255,d0
		beq PrintString_Done	;return on 255
		jsr PrintChar			;Print the Character
		bra PrintString
PrintString_Done:		
	rts
	
NewLine:
	addq.b #1,(Cursor_Y)		;INC Y
	clr.b (Cursor_X)			;Zero X
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "\SrcALL\Multiplatform_Monitor.asm"
    	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
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
	
