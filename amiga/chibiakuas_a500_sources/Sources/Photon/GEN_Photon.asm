	include "\SrcALL\BasicMacros.asm"

Color1 equ 1				;Color palette
Color2 equ 2				;These are color attributes
Color3 equ 3				
Color4 equ 4

ScreenWidth40 equ 1			;Screen Size Settings
ScreenWidth equ 320
ScreenHeight equ 224
ScreenHeight240 equ 1
	
UserRam equ $00FF0000		;Memory for the game
	
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
	move.w #%0000111011100000,VDP_data
	
	move.l #$C0040000,d0	;Color 2
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000111000001110,VDP_data
	
	move.l #$C0060000,d0	;Color 3
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000000011100000,VDP_data
	
;Turn on the screen
	
	move.l #$C0080000,d0	;Color 4
	move.l d0,VDP_Ctrl
	;        ----BBB-GGG-RRR-
	move.w #%0000000011101110,VDP_data
	MOVE.W	#$8144,(VDP_Ctrl)				; C00004 reg 1 = 0x44 unblank display
	
; Fill the screen with concecutive tiles 

	move.l #0,d0	;SX
	move.l #0,d1	;SY

	move.l #40,d2	;WID
	move.l #32,d3	;HEI

	move.l #1,d4	;TileStart Number
	jsr FillAreaWithTiles
		
;Clear the game variables
	
	lea userram,a3
	move.l #$100,d1
	jsr cldir0				;Clear Game Ram
	
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


infloop:					;main loop	
	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0
	move.b d0,(tick)

	move.l #300,d1			;slow down delay

	move.b (boost),d0
	bne boostoff			;boost - no delay 

	move.l #100,d1			;(compensate for font draw)

boostoff:
	move.b #%11111111,d2	;key buffer

pausebc:
	pushbc
		pushde
			jsr Player_ReadControlsDual		;Get Joystick
		popde
		cmp.b #%11111111,d0
		beq pausenokey
		move.b d0,d2		;store any pressed joystick buttons
pausenokey:		;released - nuke key, and relese keypress
	popbc
	subq.l #1,d1			
	bne pausebc

	tst.b (keytimeout)
	beq startdraw
	
	cmp.b #%11111111,d2			;Seems to be a 'bouncing' problem,
	bne startdraw				; I had to alter the key release code.
	clr.b (keytimeout)	
	move.b #%11111111,d2
startdraw:
	
	tst.b (keytimeout)
	bne joyskip					;yes, skip keypresses

	move.b #1,(boost)			;boost off

processkeys:
	move.l #playerdirection,a3
	move.l #playerxacc,a6		;point a6 to player accelerations 

	btst #2,d2					;4321RLDU - L
	bne joynotleft

	subq.w #1,(a3)
	jsr setplayerdirection

	move.b #1,(keytimeout)		;ignore keypresses

joynotleft:
	btst #3,d2					;4321RLDU - R
	bne joynotright

	addq.w #1,(a3)
	jsr setplayerdirection

	move.b #1,(keytimeout)		;ignore keypresses

joynotright:
	btst #4,d2					;4321RLDU - F
	bne joynotfire
	tst.b (boostpower)			;check if boost power remains
	beq joynotfire

	clr.b (boost)				;turn on boost
joynotfire:
joyskip:
	
	jsr handleplayer			;draw and update player
	jsr handlecpu				;draw and update cpu
	jmp infloop

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;D1=X D4=Y	D2=Color	
PSET:		
	moveM.l d0-d7/a0-a7,-(sp)
		move.l d2,-(sp)
			jsr CalcVramAddr	;Get Vram address
			jsr prepareVramRead
			
			move.l (VDP_data),d7;Get current word
			
			jsr prepareVramWrite	
			
			move.b d1,d3
			and.l #%00000111,d3	;8 pixels per Long
			lsl.l #2,d3
			move.l #PixelMask,a6	
			add.l d3,a6
			move.l (a6),d1		;Mask for pixel
			move.l (a6),d4
			eor.l #$FFFFFFFF,d4	;Mask for background 
		move.l (sp)+,d2
		
		and.l #$0F,d2
		lsl.l #2,d2
		move.l #ColorMask,a6	;Get color mask
		add.l d2,a6
		and.l (a6),d1			;Apply color mask to pixel mask

		and.l d4,d7				;Remove the pixel we want to change
		or.l d1,d7				;Set pixel
		move.l d7,(VDP_data)	;Wriite new pixel
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
	
Point:
	moveM.l d1-d7/a0-a7,-(sp)
		jsr CalcVramAddr 
		jsr prepareVramRead
		move.l (VDP_data),d7
			
		move.b d1,d3
		and.l #%00000111,d3		;Pixel within long
		lsl.l #2,d3
		move.l #PixelMask,a6
		add.l d3,a6
		and.l (a6),d7
		move.l d7,d0
		
		move.b d1,d3
		and.l #%00000111,d3		;Pixel within long
		eor.l #%00000111,d3			
ShiftAgain:
		beq PointDone
		lsr.l #4,d0				;Shift the nibble according
		subq.l #1,d3				;to the pixel pos
		bra ShiftAgain
PointDone:
	moveM.l (sp)+,d1-d7/a0-a7
	rts

	
CalcVramAddr:	;d1=Xpos d4=Ypos
	move.w d1,d2
	and.l #%111111000,d2 ;Tile Xpos*8*4 (32 bytes per tile)
	
	lsl.l #2,d2
	
	move.b d4,d0
	and.l #%00000111,d0	;Yline*4 (4 bytes per line)
	lsl.l #2,d0
	
	add.l d0,d2

	move.b d4,d0
	and.l #%11111000,d0	;40*8*4 
	asl.l #7,d0 		;Tile Ypos *32
	add.l d0,d2
	
	move.b d4,d0
	and.l #%11111000,d0	;40*8*4 
	asl.l #5,d0 		;Tile Ypos *8
	
	add.l d0,d2
	add.l #32,d2		;Skip tile 0
	rts

	align 2
PixelMask:
	dc.l $F0000000,$0F000000,$00F00000,$000F0000
	dc.l $0000F000,$00000F00,$000000F0,$0000000F
ColorMask:
	dc.l $00000000,$11111111,$22222222,$33333333
	dc.l $44444444,$55555555,$66666666,$77777777
	dc.l $88888888,$99999999,$AAAAAAAA,$BBBBBBBB
	dc.l $CCCCCCCC,$DDDDDDDD,$EEEEEEEE,$FFFFFFFF

	even
	

			
prepareVramWrite:					;To select a memory location D2 we need to calculate 
									;the command byte... depending on the memory location
	moveM.l d0-d7/a0-a7,-(sp)		;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
		move.l d2,d0
		and.w #%1100000000000000,d0	;Shift the top two bits to the far right 
		rol.w #2,d0
		
		and.l #%0011111111111111,d2	 ;shift all the other bits left two bytes
		rol.l #8,d2		
		rol.l #8,d2
		
		or.l d0,d2						
		or.l #$40000000,d2			;Set the second bit from the top to 1 (Write)
									;#%01000000 00000000 00000000 00000000
		move.l d2,(VDP_ctrl)
	moveM.l (sp)+,d0-d7/a0-a7
	rts

prepareVramRead:					;To select a memory location D2 we need to calculate 
									;the command byte... depending on the memory location
	moveM.l d0-d7/a0-a7,-(sp)		;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
		move.l d2,d0
		and.w #%1100000000000000,d0	;Shift the top two bits to the far right 
		rol.w #2,d0
		
		and.l #%0011111111111111,d2	;shift all the other bits left two bytes
		rol.l #8,d2		
		rol.l #8,d2
		
		or.l d0,d2								
		move.l d2,(VDP_ctrl)
	moveM.l (sp)+,d0-d7/a0-a7
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
	
Cls:
	Move.L  #$40000000,d0	;Tile1
	MOVE.L	D0,(VDP_ctrl)	;C00004 Get VRAM address
	move.l #40*28*8+8,d1
ClsAgain:
	
	clr.l (VDP_data)		;C00000 Select tile for mem loc
	dbra d1,ClsAgain
	rts

	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	
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
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	even
	include "\ResAll\Vector\VectorFont.asm"
	
	include "PH_Title.asm"
	even
	
	include "\SrcALL\BasicFunctions.asm"	
	include "\SrcALL\MultiPlatform_ShowDecimal.asm"
	include "PH_DataDefs.asm"
	include "PH_RamDefs.asm"
	
	even
	include "PH_Multiplatform.asm"
	include "PH_Vector.asm"
	even