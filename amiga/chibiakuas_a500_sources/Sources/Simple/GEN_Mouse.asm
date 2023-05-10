
UserRam equ $00FF0000
	include "\SrcALL\BasicMacros.asm"


;Ram Variables
Cursor_X equ $00FF0000		;Ram for Cursor Xpos
Cursor_Y equ $00FF0000+1	;Ram for Cursor Ypos

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

	

	
	;Turn on screen
	move.w	#$8144,(VDP_Ctrl);C00004 reg 1 = 0x44 unblank display
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


	lea Bitmap,a0					;Source data
	move.w #BitmapEnd-Bitmap,d1
	move.l #256*32,d2				;32 bytes per tile
	jsr DefineTiles	

	move.l #13,d0	;SX
	move.l #13,d1	;SY

	move.l #6,d2	;WID
	move.l #6,d3	;HEI

	move.l #256+1,d4	;TileStart Number
	jsr FillAreaWithTiles
	
	
	
inf:	
	move.l #0,d0
	
	clr.l d1
	move.l (NewPosX),d1		;Xpos for sprite
	lsr.l #8,d1
	add.l #128,d1
	
	clr.l d2
	move.l (NewPosY),d2		;Ypos for Sprite
	lsr.l #8,d2
	add.w #128,d2
	
	move.l #256,d3
	move.l #0,d4
	jsr SetSprite	
;D0=SpriteNumber, (D1,D2)=(X,Y) D3=Tilenum D4=Link to next sprite
		
	clr.b Cursor_X			;Clear Cursor XY (for monito)
	clr.b Cursor_Y
	
	jsr Player_ReadMouse
	jsr Monitor				;Show Registers
	
	move.l (NewPosX),d6
	btst #0,d3				;IS X movement Positive or Negative?
	bne NegativeX
	
;PositiveX					;Positive!
	asl.l #8,d0				;*256
	add.l d0,d6
	cmp.l #312*256,d6		;Is X over X axis
	bcc XOverFlow
	move.l d6,(NewPosX)		;Update Xpos
	jmp DoY
XOverFlow:
	move.l #312*256,(NewPosX)
	jmp DoY
	
NegativeX:					;Negative!
	ext.w d0				;Sign Extend Byte to long
	ext.l d0
	asl.l #8,d0				;*256
	add.l d0,d6
	bcc XUnderflow			;<Is X < 0?
	move.l d6,(NewPosX)	
	jmp DoY
XUnderflow:
	clr.l (NewPosX)
	
DoY:
	move.l (NewPosY),d6
	;neg.b d1
	;beq MouseDone			;No Y Move
	
	btst #1,d3	
	bne NegativeY			;Y axis is flipped	
	
;PositiveY					;Positive!
	asl.l #8,d1				;*256
	add.l d1,d6
	cmp.l #216*256,d6		;Is Y over Y axis
	bcc YOverflow
	jmp MouseDone
YOverflow:
	move.l #216*256,d6
	jmp MouseDone
	
NegativeY:					;Negative!
	ext.w d1				;Sign Extend Byte to long
	ext.l d1
	asl.l #8,d1				;*256
	add.l d1,d6
	bcs MouseDone
	jmp YUnderflow			;<Is Y<0
YUnderflow:
	clr.l d6
MouseDone:	
	move.l d6,(NewPosY)
	
	jmp inf
		
OldPosX equ UserRam		;Last Mouse position
OldPosY equ UserRam+4
NewPosX  equ UserRam+8	;Current Mouse position
NewPosY equ UserRam+12

FireHeld  equ UserRam+16		;Mouse Left is Held
FireDown equ UserRam+17		;Mouse Left was pressed (not processed yet)




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

FillAreaWithTiles:			;Set area (d0,d1) Wid:d2 Hei:D3
	moveM.l d0-d7/a0-a7,-(sp)
		clr.l d7
		
		subq.l #1,d3		;Reduce our counters by 1 for dbra
		subq.l #1,d2		
NextTileLine:
		move.l d2,-(sp)			 ;Wid
			Move.L  #$40000003,d5;$C000 offset + Vram command
			Move.L #0,d7
			Move.B d1,D7				
			
			rol.L #8,D7			;Calculate Ypos
			rol.L #8,D7
			rol.L #7,D7
			add.L D7,D5
			
			Move.B d0,D7		;Calculate Xpos
			rol.L #8,D7
			rol.L #8,D7
			rol.L #1,D7
			add.L D7,D5
		
			MOVE.L	D5,(VDP_ctrl);C00004 Get VRAM address
NextTileb:		
			MOVE.W	D4,(VDP_data);C00000 Select tile for mem loc
			addq.w #1,d4		 ;Increase Tilenum
			dbra d2,NextTileb
			add.w #1,d1			 ;Move down a line
		move.l (sp)+,d2
		dbra d3,NextTileLine	 ;Do next line
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
		
	
Player_ReadMouse:		
	;move.b #%01100000,($A10009) ;Set direction IOOIIIII (I=In O=Out)
	;move.l #$A10003,a0		;RW port for player 1
	
	move.b #%01100000,($A1000B)	;Set direction IOOIIIII (I=In O=Out)
	move.l #$A10005,a0			;RW port for player 2
	
	clr.l d0	;D0 = Xpos		%XXXXXXXX
	clr.l d1	;D1 = Ypos		%YYYYYYYY
	clr.l d2	;D2 = Buttons	%----SMLR
	clr.l d3	;D3 = Overflow / sign %---YXyx 
;$60 Request data... Returns %01110000
	move.b  #$60,(a0)	
	nop		;Delay
	nop
	
;$20... Returns %00111011
	move.b  #$20,(a0)	; TH = 1
	nop		;Delay
	nop
	
;$00... Returns %00011111
	move.b	#$0,(a0)	; TH = 0
	nop		;Delay
	nop
	
;$20... Returns %00111111
	move.b  #$20,(a0)	; TH = 1
	nop		;Delay
	nop
	
;$00... Returns %0001YXyx	YX=Overflow yx=sign (1=negative) 
	move.b	#$00,(a0)	; TH = 0
	nop		;Delay
	nop
	move.b	(a0),d3
	and.b #%00001111,d3		;Store Flags
	
;$20... Returns %0010SMRL 	Start Middle Left Right buttons
	move.b  #$20,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b	(a0),d2 
	and.b #%00001111,d2	;Store 4 buttons
	
;$00... Returns %0001XXXX	X High byte
	move.b	#$0,(a0)	; TH = 0
	nop		;Delay
	nop
	move.b	(a0),d0
	and.b #$0F,d0
	rol.b #4,d0			;Store Top X Nibble
	
;$20... Returns %0010XXXX	X Low Byte
	move.b  #$20,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b	(a0),d4
	and.b #$0F,d4
	or.b d4,d0			;Store Bottom X Nibble
	
;$00... Returns %0001YYYY	Y High Nibble
	move.b	#$0,(a0)	; TH = 0
	nop		;Delay
	nop
	move.b	(a0),d1
	and.b #$0F,d1
	rol.b #4,d1			;Store Top Y Nibble
	
;$20... Returns %0010YYYY	Y Low Nibble
	move.b  #$20,(a0)	; TH = 1
	nop		;Delay
	nop
	move.b	(a0),d4
	and.b #$0F,d4		
	or.b d4,d1			;Store Bottom Y Nibble
		
	move.b	#$60,(a0)	; Transfer Stop
	rts
	


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
	
Font:							;1bpp font - 8x8 96 characters 
	incbin "\ResALL\Font96.FNT"
Font_End:		

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
	


	include "\SrcALL\Multiplatform_Monitor.asm"
    	