

;Ram Variables
PlayerX  equ $00FF0000		;Ram for Cursor Xpos
PlayerY  equ $00FF0000+2	;Ram for Cursor Ypos
PlayerX2 equ $00FF0000+4	;Ram for Cursor Xpos
PlayerY2 equ $00FF0000+6	;Ram for Cursor Ypos

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
	
	MOVE.W	#$8144,(VDP_Ctrl)		;C00004 reg 1 = 0x44 unblank display
	
	lea Bitmap,a0					;Source data
	move.w #BitmapEnd-Bitmap,d1
	move.l #256*32,d2				;32 bytes per tile
	jsr DefineTiles	


	move.w #3,(PlayerX)		;x
	move.w #3,(PlayerY)		;y
	
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
	move.w (PlayerX),d0				;Back up X
	move.w d0,(PlayerX2)

	move.w (PlayerY),d1				;Back up Y
	move.w d1,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr BlankPlayer				;Remove old sprite
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d1		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d1		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d0		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d0		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerY)
	move.w d0,(PlayerX)
	
;X Boundary Check - if we go <0 we will end up at &FFFF
	cmp.w #40,d0
	bcs PlayerPosXOk		
	jmp PlayerReset		;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check - only need to check 1 byte
	cmp #28,d1
	bcs PlayerPosYOk	;Not Out of bounds
	
PlayerReset:
	Move.w (PlayerX2),d0	;Reset Xpos	
	Move.w d0,(PlayerX)
	
	Move.w (PlayerY2),d1	;Reset Ypos	
	Move.w d1,(PlayerY)
	
PlayerPosYOk:	
	jsr DrawPlayer			;Deaw player sprite
	
	move.l #$FFFFFFFF,d1	;Wait a bit
	jsr PauseD1
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	

BlankPlayer:						;Clear Sprite (Tile)
	move.l #257,d4
	jmp DrawSprite
DrawPlayer:							;Draw Smiley
	move.l #256,d4
DrawSprite:	
		Move.L  #$40000003,d5		;$C000 offset + Vram command
		clr.L d7
		Move.B d1,D7				
	
		rol.L #8,D7					; Calculate Ypos
		rol.L #8,D7
		rol.L #7,D7
		add.L D7,D5
	
		move.B d0,D7				;Calculate Xpos
		rol.L #8,D7
		rol.L #8,D7
		rol.L #1,D7
		add.L D7,D5
	
		MOVE.L	D5,(VDP_ctrl)		; C00004 Get VRAM address
		MOVE.W	D4,(VDP_data)		; C00000 Select tile for mem loc
	rts

Bitmap:			;Smiley
	DC.B $00,$11,$11,$00     ;  0
    DC.B $01,$11,$11,$10     ;  1
    DC.B $11,$31,$13,$11     ;  2
    DC.B $11,$11,$11,$11     ;  3
    DC.B $11,$11,$11,$11     ;  4
    DC.B $11,$21,$12,$11     ;  5
    DC.B $01,$12,$21,$10     ;  6
    DC.B $00,$11,$11,$00     ;  7
	
BitmapBlank:	;Empty Sprite
	DS.B 4*8
BitmapEnd:
	even
		
	
	
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
	
