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
	move.w #%0000011000000000,VDP_data
			
	move.l #$C0020000,d0	;Color 1
	move.l d0,VDP_Ctrl
	move.w #%0000000011101110,VDP_data
	
	move.l #$C0040000,d0	;Color 2
	move.l d0,VDP_Ctrl
	move.w #%0000111011100000,VDP_data
	
	move.l #$C0060000,d0	;Color 3
	move.l d0,VDP_Ctrl
	move.w #%0000000000001110,VDP_data
	
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

	

	clr.b Cursor_X			;Clear Cursor XY
	clr.b Cursor_Y
	
	;Turn on screen
	move.w	#$8144,(VDP_Ctrl);C00004 reg 1 = 0x44 unblank display
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	lea Message,a3
	jsr PrintString		;Print String to screen
	
	jsr NewLine			;Start a new line
		
	jsr Monitor				;Show Registers

	jsr Monitor_MemDump		;Dump 6 lines from  $00000000
	dc.l $00001000
	dc.w $6
	
	jmp *				;Halt CPU
		

Message: dc.b 'Hello World',255		
	even

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
    	