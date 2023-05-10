TestChibiko equ 16+1
TestSprite equ 0

ScreenBase equ $C000+8+(64*4)

TileCache equ $00FF0000


;Define some memory for ChibiSound (256 bytes)
chibisoundram equ $00FF2000

SongOffset equ ChibiSoundRam+128 ; dc.l 0	
;Remap internal addresses in song (eg compiled for $8000
; loaded to $2000 = offsets of -$6000
SongBase  equ SongOffset+4 ; dc.l Song1
SongChannels equ SongBase+4 ; dc.b 0
SongSpeed equ  SongChannels+1 ; dc.b 0

	

	
ChibicloneDef equ $00FF0400
ChibikoDef 	  equ $00FF0420


ZeroTileCacheRev  equ $00FF0500
striproutine 	  equ $00FF0502
TileClear 		  equ $00FF0504
offset1 		  equ $00FF0506
offset2			  equ $00FF0508
spritehclip   	  equ $00FF050A
HSpriteNum		  equ $00FF050B


	include "\SrcAll\BasicMacros.asm"
		
TileSmoothXmove equ 1	;move in blocks <8 pixels
TileSmoothYmove equ 1	;This would just waste cpu power

VscreenMinX equ 64		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80

;VscreenWid equ 24		;Visible Screen Size in logical units
;VscreenHei equ 24

;LIMITATION.. The Virtual screen cannot be smaller than the sprite or 
;the crop will malfunction! (It can be the same size)

VscreenWid equ 128			;Visible Screen Size in logical units
VscreenHei equ 96

	
VscreenWidClip equ 2	;alter right boundary due to working in words
VscreenHeiClip equ 3


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;Video Ports
VDP_data equ $C00000	; VDP data, R/W word or longword access only
VDP_ctrl equ $C00004	; VDP control, word or longword writes only

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	dc.l $FFFFFE00		;SP register value
	dc.l ProgramStart	;Start of Program Code
	ds.l 7,IntReturn		;bus err,addr err,illegal inst,divzero,CHK,TRAPV,priv viol
	dc.l IntReturn		;TRACE
	dc.l IntReturn		;Line A (1010) emulator
	dc.l IntReturn		;Line F (1111) emulator
	ds.l 4,IntReturn		;Reserverd /Coprocessor/Format err/ Uninit Interrupt
	ds.l 8,IntReturn		;Reserved
	dc.l IntReturn		;spurious interrupt
	
	dc.l IntReturn		;IRQ level 1
	dc.l IntReturn		;IRQ level 2 EXT
	dc.l IntReturn		;IRQ level 3
	dc.l IntReturn		;IRQ level 4 Hsync
	dc.l IntReturn		;IRQ level 5
	dc.l InterruptHandler;IRQ level 6 Vsync ($00000078) ***
	dc.l IntReturn		;IRQ level 7 
	
	dc.l 16,IntReturn	;TRAPs
	dc.l 16,IntReturn	;Misc (FP/MMU)
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;					Header
	dc.b "SEGA GENESIS    "	;System Name
	dc.b "(C)CHBI "			;Copyright
 	dc.b "2019.JAN"			;Date
	dc.b "ChibiAkumas.com                                 " ;Cart Name
	dc.b "ChibiAkumas.com                                 " ;Cart Name (Alt)
	dc.b "GM CHIBI001-00"	;TT NNNNNNNN-RR T=Type (GM=Game) N=game Num  R=Revision
	dc.w $0000				;16-bit Checksum (Address $000200+)
	dc.b "J               "	;Control Data (J=3button K=Keyboard 6=6button C=cdrom)
	dc.l $00000000			;ROM Start
	dc.l $003FFFFF			;ROM Length
	dc.l $00FF0000,$00FFFFFF	;RAM start/end (fixed)
	dc.b "            "		;External RAM Data
	dc.b "            "		;Modem Data
	dc.b "                                        " ;MEMO
	dc.b "JUE             "	;Regions Allowed

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
	lea Palette,a1
	move.l #16,d1
	move.l #$C0000000,d0		;Color 0
PaletteAgain:	
	move.l d0,(VDP_Ctrl)
	move.w (a1)+,(VDP_data)		;----BBB-GGG-RRR-
	add.l #$00020000,d0
	dbra d1,PaletteAgain

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	jsr chibisoundpro_init	;Init sound driver
	
	move.l #Song1,a3
	move.l a3,(SongBase)	;Song address
	
	jsr StartSong 			;Init song

	move.b #6,(SongSpeed)	;Tweak speed for 60hz
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;We need to set the interrupt level <6 to enable the interrupt 6
	
		;  T-S--III---XNZVC
	andi #%1111100011111111,sr		;Interrupt Level=0
	ori  #%00000110000000000,sr		;Interrupt Level=6
	
;Set up the VDP to cause the interrupt	
	
	MOVE.W	#$8164,(VDP_Ctrl)	;C00004 reg 1 = 0x44 unblank display
								;+$20 = Vblank on
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	lea Bitmap,a0					;Source data
	move.w #Bitmap_End-Bitmap,d1
	move.l #32,a6				;Dest VRAM 32 bytes per tile
	jsr DefineTiles	
	
	
	
		
	move.l #xChibicloneDef,a1
	move.l #ChibicloneDef,a2
	move.l #64-1,d0
CopyAgain:
	move.b (a1)+,(a2)+
	dbra d0,CopyAgain
	


	
		
	move.l #24-1,d7
	
	move.l #TileMap2,a3
	move.l #TileCache,a2
FillYAgain:
	move.l #32-1,d1
FillXAgain:
		move.b (a3)+,(a2)+
	dbra d1,FillXAgain
		
	add.l  #4,a3
	
	dbra d7,FillYAgain
	
	
	move.l #TestSprite,a5
	move.l #TileCache,a2 	;TileCache
	jsr cls
	
	
	move.l #ChibikoDef,a4
	jsr DrawSpriteAlways	;Draw Player Sprite
	
	

	move.w #$60,d1			;Back up X
	move.w #$60,d4			;Back up Y
	
InfLoop:
	moveM.l d1/d4,-(sp)

		jsr ReadJoystick
	moveM.l (sp)+,d1/d4
	
	
	move.l d0,-(sp)
StartDraw:
	move.b d0,d3
		
		;moveM.l d0-d7/a0-a5,-(sp)
		;	jsr DrawPlayer			;Draw Player Sprite
		;moveM.l (sp)+,d0-d7/a0-a5


	
	
	move.l #ChibikoDef,a4
	
	btst #4,d3
	bne JoyNotFire
		addq.b #1,(Spr_Flags,a4)
		jsr FlagSpriteForRefresh
		
		add.b #1,(offset1)
		
		move.b (offset1),d0
		move.b (offset2),d2
		cmp.b d2,d0
		beq NoScrollChange
		
		and.l #%00000011,d0
		and.l #%00000011,d2
		
			move.b #32,d7
			move.b #24,d6

			move.l #TileCache,a2

			move.l #Tilemap2,a1
			add.l d0,a1
			
			move.l #Tilemap2,a3
			add.l d2,a3
			jsr ChangeScroll
		
		move.b (offset1),(offset2)
		
		
	
NoScrollChange:
JoyNotFire:	
	move.l (sp)+,d3
		
		

	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
		subq.b #1,d4		;Move Y Up the screen
		jsr FlagSpriteForRefresh
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
		addq.b #1,d4		;Move Y DOWN the screen
		jsr FlagSpriteForRefresh
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
		subq.b #1,d1		;Move X Left
		jsr FlagSpriteForRefresh
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
		addq.b #1,d1		;Move X Right
		jsr FlagSpriteForRefresh
JoyNotRight: 	

	moveM.l d1/d4,-(sp)
		move.l #ChibikoDef,a4
		;jsr RemoveSprite
			
	moveM.l (sp)+,d1/d4
	
	
	
	move.b d1,(Spr_Xpos,a4)
	move.b d4,(Spr_Ypos,a4)
	
	
	
	moveM.l d1/d4,-(sp)
		;move.l #ChibikoDef,a4
		;jsr ZeroSpriteInCache
		
	
		move.l #ChibicloneDef,a4

		jsr FlagSpriteForRefresh
		
		;jsr RemoveSprite
		
		addq.b #1,(Spr_Xpos,a4)
		;jsr ZeroSpriteInCache

	
	
		move.b #1,(TileClear)
		
		move.l #TestSprite,a5
		move.l #TileCache,a2
		jsr cls
	
		
		
		clr.b (TileClear)
		
		
		clr.b (HSpriteNum)		
		move.l #ChibicloneDef,a4
		jsr DrawSprite			;Draw Player Sprite

		
		move.l #ChibikoDef,a4
		jsr DrawSpriteAlways	;Draw Player Sprite
		
		jsr FinishSprites
		
	moveM.l (sp)+,d1/d4
	
	
	
	
	move.l #$FFF,d7
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d7,PauseD1
	rts
	
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	
	
ReadJoystick:		;D0=1up D1=2up ---7654S321RLDU
	
	;move.b #%01000000,($A1000B)	; Set direction IOIIIIII (I=In O=Out)
	;move.l #$A10005,a0			;RW port for player 2
	;jsr Player_ReadOne			;Read buttons
	
	;move.l d0,-(sp)
		move.b #%01000000,($A10009)	; Set direction IOIIIIII (I=In O=Out)
		move.l #$A10003,a0		;RW port for player 1
		jsr Player_ReadOne		;Read buttons
	;move.l (sp)+,d1
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
	

	

	
waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

;Tile Addr: VRAM Addr = $C000 + (Ypos * 64* 2) + (Xpos *2)

GetScreenPos: ; d1=x d2=y - returns screen address in A6
	moveM.l d1-d4,-(sp)
		and.l #%11111100,d1
		and.l #%11111100,d4
		move.l #ScreenBase,a6 ;Get screen pointer into a6
		
		asr.l #1,d1
		add.l d1,a6
		
		asl.l #5,d4
		
		add.l d4,a6
	moveM.l (sp)+,d1-d4
	rts
		
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
DoStripSprite:		;bc/D1.D4=xy pos
		move.l d1,-(sp)
NextTileSpr:
		clr.l d0
		move.b (a2),d0	;BC=Tilemap data
		beq EmptyTileSpr
		
		tst.b (TileClear)
		beq NoClearSpr
		clr.b (a2)
NoClearSpr:
		addq.l #1,a2		;INC BC

		move.l d0,-(sp)

			jsr GetHSprite
			addq.b #1,(HSpriteNum)
			
		
			clr.l d0
			move.b d4,d0
			asl.l #1,d0
			add.l #128+(2*8),d0
		
			move.w d0,(VDP_data)	; ------VV VVVVVVVV - Vpos
			
			
			clr.l d0
			move.b (HSpriteNum),d0
			move.w d0,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
			
		move.l (sp)+,d0
		add.l a5,d0
		move.w d0,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
		
		clr.l d0
		move.b d1,d0
		asl.l #1,d0
		add.l #128+(4*8),d0
		
		move.w d0,(VDP_data)	; -------H HHHHHHHH - Hpos
			
		add.l #4,d1
		
TileDoneSpr:	
		subq.b #1,d7
		bne NextTileSpr
TileDone2Spr:
	move.l (sp)+,d1
	add.l #4,d4
	rts
EmptyTileSpr:
	addq.l #1,a2		;INC BC
	add.l #4,d1
	jmp TileDoneSpr
	rts




DoStripSpriteRev:		;bc/D1.D4=xy pos
		move.l d1,-(sp)
NextTileSprRev:
		clr.l d0
		move.b (a2),d0	;BC=Tilemap data
		beq EmptyTileSprRev
		
		tst.b (TileClear)
		beq NoClearSprRev
		clr.b (a2)
NoClearSprRev:
		subq.l #1,a2		;INC BC

		move.l d0,-(sp)

			jsr GetHSprite
			addq.b #1,(HSpriteNum)
			
			clr.l d0
			move.b d4,d0
			asl.l #1,d0
			add.l #128+(2*8),d0
		
			move.w d0,(VDP_data)	; ------VV VVVVVVVV - Vpos
			
			clr.l d0
			move.b (HSpriteNum),d0
			move.w d0,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
			
		move.l (sp)+,d0
		add.l a5,d0
		or.w #%0000100000000000,d0
		move.w d0,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
		
		clr.l d0
		move.b d1,d0
		asl.l #1,d0
		add.l #128+(4*8),d0
		
		move.w d0,(VDP_data)	; -------H HHHHHHHH - Hpos
			
		add.l #4,d1
		
TileDoneSprRev:	
		subq.b #1,d7
		bne NextTileSprRev
TileDone2SprRev:
	move.l (sp)+,d1
	add.l #4,d4
	rts
EmptyTileSprRev:
	subq.l #1,a2		;INC BC
	add.l #4,d1
	jmp TileDoneSprRev
	rts




	
	
	

	
GetHSprite:
		clr.l d0		;Hardware Spr Num
		move.b (HSpriteNum),d0
		lsl.l #3,d0			;8 bytes per Sprite
		add.l #$D800,d0		;Base Sprite Address
		jsr prepareVramd0
	rts
	
FinishSprites:
		jsr GetHSprite
;Loop back to start of sprites
		move.w #0,(VDP_data)	; ------VV VVVVVVVV - Vpos
		move.w #0,(VDP_data)	; ----WWHH -LLLLLLL - Width, Height, Link (to next sprite)
		move.w #0,(VDP_data)	; PCCVHNNN NNNNNNNN - Priority, Color palette , Vflip, Hflip, tile Number
		move.w #0,(VDP_data)	; -------H HHHHHHHH - Hpos
		
	rts	
	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width
		jsr prepareVram
NextTile:
		clr.l d0
		move.b (a2),d0	;BC=Tilemap data
		beq EmptyTile
		
		tst.b (TileClear)
		beq NoClear
		clr.b (a2)
NoClear:
		add.l a5,d0
				
		addq.l #1,a2		;INC BC
		
		MOVE.W	D0,(VDP_data)		; C00000 Select tile for mem loc
			
		add.l #2,a6
TileDone:	
		subq.b #1,d7
		bne NextTile
TileDone2:

	rts
EmptyTile:
	addq.l #1,a2		;INC BC
	add.l #2,a6
	jsr prepareVram
	jmp TileDone

;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width


DoStripRev:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width
		jsr prepareVram
NextTileRev:
		clr.l d0
		move.b (a2),d0	;BC=Tilemap data
		beq EmptyTileRev
		
		tst.b (TileClear)
		beq NoClearRev
		clr.b (a2)
NoClearRev:
		add.w #%0000100000000000,d0
		add.l a5,d0
		
		subq.l #1,a2		;INC BC
		;%LPPVHTTT	TTTTTTTT  T=Tille number  H=Hflip  V=vflip  P=palette number   L=Layer (in front of /behind sprites)
		MOVE.W	D0,(VDP_data)		; C00000 Select tile for mem loc
			
		add.l #2,a6
TileDoneRev:	
		subq.b #1,d7
		bne NextTileRev
TileDone2Rev:

	rts
EmptyTileRev:
	subq.l #1,a2		;INC BC
	add.l #2,a6
	jsr prepareVram
	jmp TileDoneRev

	

	include "/srcALL/V1_MinimalTile.asm"
	
Bitmap:
	incbin "\ResALL\Yquest\MSX2_Yquest.RAW"
	incbin "\ResALL\SpeedTiles\Chibiko2TilesSAM.RAW"
Bitmap_End:

Tilemap2
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,01,2,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,02,1,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,01,2,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,02,1,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,01,2,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,01,2,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,01,2,1,1
	dc.b 4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,01,2,1,1
	dc.b 4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,02,1,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,01,2,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,02,1,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,01,2,1,1
	dc.b 2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,2,2,2,2,3,3,3,3,02,1,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,01,2,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,01,2,1,1
	dc.b 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,01,2,1,1
	dc.b 4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,02,1,1,1
	dc.b 1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,01,2,1,1
	dc.b 4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,4,4,4,4,1,1,1,1,02,1,1,1



	even
TestSpriteList:
Sprite_1:
  dc.b 0,1,2,3,4
  dc.b 5,6,7,8,9
  dc.b 10,11,12,13,14
  dc.b 15,16,17,18,19
  dc.b 20,21,22,23,24
  dc.b 25,26,27,28,29
  dc.b 0,30,31,32,0
  dc.b 0,33,34,35,0	
	
xChibicloneDef:
	dc.l TestSpriteList	;Tilemap			4
	dc.l TestChibiko		;Pattern Data	8
	dc.b 20,32		;Width,Height			10
	dc.b 64,128		;X,Y					12
	dc.b 1,1			;RefreshTile,Sprite	14
	dc.b 64,128		;X,Y					16
	dc.b 0,0			;Flags				18
	ds.b 14
	
xChibikoDef:
	dc.l TestSpriteList	;Tilemap
	dc.l TestChibiko		;Pattern Data
	dc.b 20,32		;Width,Height
	dc.b $60,$60		;X,Y
	dc.b 1,1			;RefreshTile,Sprite
	dc.b 64,128		;X,Y
	dc.b 1,1			;Flags
	ds.b 14



DefineTiles:						;Copy D1 bytes of data from A0 to VDP memory D2 
	jsr prepareVram					;Calculate the memory location we want to write
DefineTilesAgain:						; the tile pattern definitions to
		move.l (a0)+,d0				
		move.l d0,(VDP_data)		;Send the tile data to the VDP
		dbra d1,DefineTilesAgain
		
	rts
prepareVramd0:							;To select a memory location D2 we need to calculate 
										;the command byte... depending on the memory location
	moveM.l d0-d2,-(sp)			;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
		move.l d0,d2
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
	
prepareVram:							;To select a memory location D2 we need to calculate 
										;the command byte... depending on the memory location
	moveM.l d0-d7/a0-a7,-(sp)			;$7FFF0003 = Vram $FFFF.... $40000000=Vram $0000
		move.l a6,d2
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
	
Palette:	
    dc.w %0000000000000000; ;0  %----BBB-GGG-RRR-
    dc.w %0000111000001000; ;1  %----BBB-GGG-RRR-
    dc.w %0000111011100000; ;2  %----BBB-GGG-RRR-
    dc.w %0000111011101110; ;3  %----BBB-GGG-RRR-
    dc.w %0000100000000000; ;4  %----BBB-GGG-RRR-
    dc.w %0000100000001000; ;5  %----BBB-GGG-RRR-
    dc.w %0000100010000000; ;6  %----BBB-GGG-RRR-
    dc.w %0000110011001100; ;7  %----BBB-GGG-RRR-
    dc.w %0000100010001000; ;8  %----BBB-GGG-RRR-
    dc.w %0000000000001110; ;9  %----BBB-GGG-RRR-
    dc.w %0000000011100000; ;10  %----BBB-GGG-RRR-
    dc.w %0000000011101110; ;11  %----BBB-GGG-RRR-
    dc.w %0000111000000000; ;12  %----BBB-GGG-RRR-
    dc.w %0000111000001110; ;13  %----BBB-GGG-RRR-
    dc.w %0000111011100000; ;14  %----BBB-GGG-RRR-
    dc.w %0000111011101110; ;15  %----BBB-GGG-RRR-
	
	
	
VDPSettings:
	DC.B $04 ; 0 mode register 1											---H-1M-
	DC.B $04 ; 1 mode register 2											-DVdP--- V=Vblank interrupt
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
	

	include "\SrcALL\Multiplatform_ChibiTracks.asm"
	include "\SrcALL\Multiplatform_ChibiTracks_Tweener.asm"
	include "\SrcALL\Multiplatform_Fraction16.asm"
	
	include "\SrcALL\V1_ChibiSoundPro.asm"
	
	
	
	include "\SrcALL\BasicFunctions.asm"
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Song1:
	;incbin "\ResAll\ChibiSoundPro\Song1000.cbt"
	;include "\ResAll\ChibiSoundPro\CBT1.asm"
	;incbin "\ResAll\ChibiSoundPro\song.cbt"
	;incbin "\ResAll\ChibiSoundPro\song2.cbt"
	incbin "\ResAll\ChibiSoundPro\ChibiAkumasTheme.cbt"
	;include "\ResAll\ChibiSoundPro\Song2.asm"
	even
	
InterruptHandler:
	moveM.l d0-d7/a0-a6,-(sp)
	
			jsr ChibiTracks_Play
			
	moveM.l (sp)+,d0-d7/a0-a6
	rte
