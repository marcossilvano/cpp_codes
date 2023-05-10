

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
	
	
	
	move.l #$C0200000,d0	;Color 0
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000111000000000,VDP_data
			
	move.l #$C0220000,d0	;Color 1
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000000011101110,VDP_data
	
	move.l #$C0240000,d0	;Color 2
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000111011100000,VDP_data
	
	move.l #$C0260000,d0	;Color 3
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000000000001110,VDP_data
	
	
	MOVE.W	#$8144,(VDP_Ctrl)				; C00004 reg 1 = 0x44 unblank display
	
	lea Bitmap,a0					;Source data
	move.w #BitmapEnd-Bitmap,d1
	move.l #256*32,d2				;32 bytes per tile
	jsr DefineTiles	

	
;Scroll-A Chibiko	
	move.l #$04,d0	;SX
	move.l #$04,d1	;SY
	move.l #6,d2	;WID
	move.l #6,d3	;HEI
	move.l #256+1,d4			;TileStart Number
	jsr FillAreaWithTilesA
	
;Scroll-B Chibiko
	move.l #13,d0	;SX
	move.l #13,d1	;SY
	move.l #6,d2	;WID
	move.l #6,d3	;HEI
	move.l #256+1,d4			;TileStart Number	ScrB=Background
	;move.l #$8000+256+1,d4		;TileStart Number 	ScrB=Foreground
	
	jsr FillAreaWithTilesB
	
;Window Fill with plusses	
	Move.L  #$70000003,d5		;$E000 offset + Vram command
	MOVE.L	D5,(VDP_ctrl)		;C00004 Get VRAM address
	move.l #$800-1,d0
FillWindow:	
	MOVE.W	#$2100,(VDP_data)	;C00000 Select tile for mem loc
	dbra d0,FillWindow
	
	
;Window Chibiko	
	move.l #13,d0	;SX
	move.l #13,d1	;SY
	move.l #6,d2	;WID
	move.l #6,d3	;HEI
	move.l #$2101,d4			;TileStart Number (257 - pal 1)
	jsr FillAreaWithTilesW		;Window Replaces Tilemap
	
	
;Scroll Test

	move.l #$00009160,d5		;VDP Reg command (%8rvv)  -Window X pos
	move.l #$00009260,d6		;VDP Reg command (%8rvv)  -Window Y pos
InfLoop:

;HSCROLL is in VRAM
	move.l #$DC00,d2			;$DC00=Xpos A	;$DC02=Xpos B
	jsr prepareVram
	move.w d0,(VDP_data)		;Send the tile data to the VDP
	
	move.l #$DC02,d2			;$DC00=Xpos A	;$DC02=Xpos B
	jsr prepareVram
	move.w d0,(VDP_data)		;Send the tile data to the VDP
	
;VSCROLL is in 'VSRAM'!?!
	move.l #$40000010,d1		;$00=Ypos A	$02=Ypos B
	move.l d1,(VDP_Ctrl)
	move.w d0,(VDP_data)		;Send the tile data to the VDP
	
	move.l #$40020010,d1		;Ypos B
	move.l d1,(VDP_Ctrl)
	move.w d0,(VDP_data)		;Send the tile data to the VDP
	
	
	move.l d0,-(sp)	
		and #%00000111,d0
		bne NoWindowChange
	
		move.w d5,(VDP_Ctrl)	;Update Window Xpos
		move.w d6,(VDP_Ctrl)	;Update Window Ypos
		addq.b #1,d5			;Inc Window Xpos
		addq.b #1,d6			;Inc Window Ypos
NoWindowChange:
	move.l (sp)+,d0
	addq.l #1,d0				;Window Delay counter

	move.l #$FF00,d1
Delay:
	dbra d1,Delay
	
	jmp InfLoop				;Halt CPU
		

Bitmap:
	dc.b $11,$13,$31,$11
	dc.b $10,$03,$30,$01
	dc.b $10,$03,$30,$01
	dc.b $33,$30,$03,$33
	dc.b $33,$30,$03,$33
	dc.b $10,$03,$30,$01
	dc.b $10,$03,$30,$01
	dc.b $11,$13,$31,$11
	


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

;Scroll-B
FillAreaWithTilesB:			;Set area (d0,d1) Wid:d2 Hei:D3
	moveM.l d0-d7/a0-a7,-(sp)
		move.l #$60000003,d6	;E000 base (Scroll-B)
		bra FillAreaWithTilesAlt

;Window
FillAreaWithTilesW:			;Set area (d0,d1) Wid:d2 Hei:D3
	moveM.l d0-d7/a0-a7,-(sp)
		move.L  #$70000003,d6	;F000 base (Window)
		bra FillAreaWithTilesAlt	
		
;Scroll-A
FillAreaWithTilesA:			;Set area (d0,d1) Wid:d2 Hei:D3
	moveM.l d0-d7/a0-a7,-(sp)
		move.l #$40000003,d6	;C000 base (Scroll-A)
FillAreaWithTilesAlt:
		clr.l d7
		
		subq.l #1,d3			;Reduce our counters by 1 for dbra
		subq.l #1,d2		
NextTileLine:
		move.l d2,-(sp)			 ;Wid
			Move.L  d6,d5 		;offset + Vram command
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
	
	DC.B $37 ;13 H scroll table base (A=Top 6 bits)							--AAAAAA = $DC00
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
	
