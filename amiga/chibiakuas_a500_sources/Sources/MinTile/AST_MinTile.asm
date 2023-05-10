


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

    SECTION TEXT		;CODE Section

    pea    ST_Start     ;Push address to call to onto stack
    move.w  #$26,-(sp)  ;Supexec (38: set supervisor execution)
    trap    #14         ;XBIOS Trap
    addq.w  #6,sp       ;remove item from stack
	jmp *				;Wait for Supervisor mode to start

ST_Start:
	move.b #$00,$ff8260		;Screen Mode: 00=320x200 4 planes
	
    move.l #screen_mem,d0  	;Move address to screen mem to d0
    add.l #$ff,d0      		;Add 255 d0 address
    clr.b d0           		;Clear lowest byte in address
    move.l d0,ScreenBase	;Save screen start
	
    lsr.w #8,d0       		;we need to convert $00ABCD?? into $00AB00CD
    move.l d0,$ff8200		;store the resulting 16 bits into the screen start register
							;&FF8201 = High byte
							;&FF8203 = Mid  byte
							;Low byte cannot be specified
							
	move.l #$ff8240,a1		;Define palette
	lea Palette,a0
	move.l #16-1,d0
PaletteAgain:						
	move.w (a0)+,(a1)+		;%-----RRR-GGG-BBB
	dbra d0,PaletteAgain
	
	
	jsr KeyboardScanner_AllowJoysticks						;S-----E- ---DCBA	S=Set/Clr E=enable ABCD=Channnels	
										
								
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Build the lookup table
		
	move.l #FlipLUT,a0		;Lookup table
	clr.l d1				;Byte to convert
FillLut:
	move.b d1,d0
	
	move.w #7,d3			;8 bits 
FillLut2:	
		roxr.b #1,d0		;Shift a bit right out of source
		roxl.b #1,d2		;Shift a bit left in to destination
	dbra d3,FillLut2
	
	move.b d2,(a0)+			;Write the byte
	
	addq.b #1,d1			;Repeat for 0-255
	bne FillLut

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
	
		
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
		jsr RemoveSprite
			
	moveM.l (sp)+,d1/d4
	
	
	
	move.b d1,(Spr_Xpos,a4)
	move.b d4,(Spr_Ypos,a4)
	
	
	
	moveM.l d1/d4,-(sp)
		;move.l #ChibikoDef,a4
		jsr ZeroSpriteInCache
		
	
		move.l #ChibicloneDef,a4

		jsr FlagSpriteForRefresh
		
		jsr RemoveSprite
		
		addq.b #1,(Spr_Xpos,a4)
		jsr ZeroSpriteInCache

	
	
		move.b #1,(TileClear)
		
		move.l #TestSprite,a5
		move.l #TileCache,a2
		jsr cls
	
		
		
		clr.b (TileClear)
		
		
		
		move.l #ChibicloneDef,a4

		jsr DrawSprite			;Draw Player Sprite

		
		move.l #ChibikoDef,a4
		jsr DrawSpriteAlways	;Draw Player Sprite
	moveM.l (sp)+,d1/d4
	
	
	
	
	move.l #$FFF,d7
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d7,PauseD1
	rts
	
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	

	
waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;4 words for 4 bitplanes are concecutive in memory, eg: $0000111122223333

;Addr = ScreenMem + (Ypos * 40) + Xpos
GetScreenPos: ; d4=x d2=y - returns screen address in A6
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1
		lsr.b #2,d1				;Convert Xpos to tiles
		move.l ScreenBase,a6 	;Get screen pointer into a6
		move.l d1,d3	
		and.l #%11111110,d1	 	;Offset in Words
		and.l #%00000001,d3	 	;Byte offset (1 tile)
		rol.l #2,d1			 	;4 Bitplane words consecutive in memory
		add.l d1,a6				;Add Word offset
		add.l d3,a6				;Add Byte offset
		
		add.l #4*4,a6			;Centre screen
		
		mulu #160*2,d4			 ;160 bytes per Y line
		add.l d4,a6
	moveM.l (sp)+,d1-d4
	rts
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

NextTile:
	clr.l d0
	move.b (a2),d0		;BC=Tilemap data
	beq EmptyTile
	
	tst.b (TileClear)
	beq NoClear
	clr.b (a2)
NoClear:

	lsl.l #5,d0			;32 bytes per pattern
	move.l a5,a3		;A5=Tile Pattern Base
	add.l d0,a3
	
	addq.l #1,a2		;Next Tilemap Tile
	
	move.l a6,-(sp)
		move.w #7,d1			;8 lines
		clr.l d0
DrawTileNextLine:	
		move.b (a3)+,(a6)		;Bitplane 0
		move.b (a3)+,(2,a6)		;Bitplane 1
		move.b (a3)+,(4,a6)		;Bitplane 2
		move.b (a3)+,(6,a6)		;Bitplane 3
		
		add.l #160,a6			;Down one pixel line
		
		dbra d1,DrawTileNextLine	;Next Line	
	move.l (sp)+,a6

TileDone:	
	addq.l #1,a6			;Across one tile
	
	move.l a6,d0
	and.b #%00000001,d0	;Need to jump to next 8 byte block?
	bne TileDoneb
	add.l #6,a6			;Yes!
TileDoneb:		
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTile
	rts
	
EmptyTile:
	addq.l #1,a2		;Next Tilemap Tile
	jmp TileDone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

DoStripRev:	
	move.l #FlipLUT,a1	;Xflip Lookup Table
NextTileRev:
	clr.l d0
	move.b (a2),d0		;A2=Tilemap data
	beq EmptyTileRev
	
	tst.b (TileClear)	;Clear Tiles?
	beq NoClearRev
	clr.b (a2)			;Yes!
NoClearRev:

	lsl.l #5,d0			;32 bytes per pattern
	move.l a5,a3		;A5=Tile Pattern Base
	add.l d0,a3
		
	subq.l #1,a2		;Last Tilemap Tile
	
	move.l a6,-(sp)
		move.w #7,d1	;8 lines
		clr.l d0
		
DrawTileNextLineRev:	
		move.b (a3)+,d0			;Get a source byte
		move.b (a1,d0),d0		;Convert via LUT
		move.b d0,(a6)			;Bitplane 0
		
		move.b (a3)+,d0			;Get a source byte
		move.b (a1,d0),d0		;Convert via LUT
		move.b d0,(2,a6)		;Bitplane 1
		
		move.b (a3)+,d0			;Get a source byte
		move.b (a1,d0),d0		;Convert via LUT
		move.b d0,(4,a6)		;Bitplane 2
		
		move.b (a3)+,d0			;Get a source byte
		move.b (a1,d0),d0		;Convert via LUT
		move.b d0,(6,a6)		;Bitplane 3

		add.l #160,a6			;Down one pixel line
				
		dbra d1,DrawTileNextLineRev	;Next Line
	move.l (sp)+,a6
	
TileDoneRev:
	addq.l #1,a6			;Across one tile

	move.l a6,d0
	and.b #%00000001,d0	;Need to jump to next 8 byte block?
	bne TileDonebRev
	add.l #6,a6			;Yes!
TileDonebRev:			
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTileRev
TileDone2Rev:
	rts
EmptyTileRev:
	subq.l #1,a2		;Last Tilemap Tile
	jmp TileDoneRev
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	

	include "/srcALL/V1_MinimalTile.asm"

TestSprite:
	incbin "\ResALL\Yquest\AST_YQuest.RAW"
TestChibiko:
	incbin "\ResALL\SpeedTiles\Chibiko2TilesAST.RAW"


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

Palette:
    dc.w %0000000000000000; ;0  %-----RRR-GGG-BBB
    dc.w %0000010000000111; ;1  %-----RRR-GGG-BBB
    dc.w %0000000001110111; ;2  %-----RRR-GGG-BBB
    dc.w %0000011101110111; ;3  %-----RRR-GGG-BBB
    dc.w %0000000000000100; ;4  %-----RRR-GGG-BBB
    dc.w %0000010000000100; ;5  %-----RRR-GGG-BBB
    dc.w %0000000001000100; ;6  %-----RRR-GGG-BBB
    dc.w %0000011001100110; ;7  %-----RRR-GGG-BBB
    dc.w %0000010001000100; ;8  %-----RRR-GGG-BBB
    dc.w %0000011100000000; ;9  %-----RRR-GGG-BBB
    dc.w %0000000001110000; ;10  %-----RRR-GGG-BBB
    dc.w %0000011101110000; ;11  %-----RRR-GGG-BBB
    dc.w %0000000000000111; ;12  %-----RRR-GGG-BBB
    dc.w %0000011100000111; ;13  %-----RRR-GGG-BBB
    dc.w %0000000001110111; ;14  %-----RRR-GGG-BBB
    dc.w %0000011101110111; ;15  %-----RRR-GGG-BBB


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



readJoystick:
	move.b (Joystickdata+1),d0	;Process Joy 1
	
Player_ReadControlsProcessOne:;Joypad bits 			F---RLDU  	?
	or.l #$FFFFFF00,d0
	roxl.b #1,d0			;Fire -> eXtend flag	---RLDU-   	F 
	rol.b #3,d0				;skip Unused bits		RLDU----   	F 
	roxr.b #1,d0			;Get back F				FRLDU---   	- 
	ror.b #3,d0				;Move needed bits back	---FRLDU   	- 
	eor.b #$FF,d0			;Flip the bits of the bottom byte
	rts

		
		
		
KeyboardScanner_AllowJoysticks:	;Install Joystick handler

	move.w	#$14,-(sp)		;IKBD command $14 - set joystick event reporting
	move.w	#4,-(sp)		;Device no 4 (keyboard - Joystick is part of keyboard)
	move.w	#3,-(sp)		;Bconout (send cmd to keyboard)
	trap	#13				;BIOS Trap
	addq.l 	#6,sp			;Fix the stack

	move.w  #34,-(sp)		;return IKBD vector table (KBDVBASE)
	trap  	#14				;XBIOS trap
	addq.l  #2,sp 			;Fix the stack
	
	move.l  d0,IkbdVector 	;store IKBD vectors address for later
	move.l  d0,a0  			;A0 points to IKBD vectors
	move.l  (24,a0),OldJoyVec;backup old joystick vector so we can restore it
	
	move.l  #JoystickHandler,(24,a0); Set our Joystick Handler
	rts
	
JoystickHandler:			;This is our Joystick handler, it will be executed 
							;by the firmware handler

	move.b  (1,a0),Joystickdata  ; store joy 0 data
	move.b  (2,a0),Joystickdata+1; store joy 1 data
	rts  

IkbdVector:	dc.l 0 			; original IKBD vector storage
OldJoyVec:	dc.l 0    		; original joy vector storage
Joystickdata:ds.b 2			;Joypad bits F---RLDU 



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
screen_mem:				;Reserve screen memory 
    ds.b    32256
ScreenBase: ds.l 1		;Var for base of screen ram
		
	
ChibicloneDef:
	ds.b 32
	
ChibikoDef:
	ds.b 32

	align 8
FlipLUT:
	ds.b 256

TileCache:
	ds.b 24*32

	
ZeroTileCacheRev: ds.w 1
striproutine: ds.w 1
TileClear: ds.w 1
offset1:  ds.w 1
offset2:  ds.w 1
	
;Current player pos
PlayerX: ds.w 1
PlayerY: ds.w 1

;Last player pos (For clearing sprite)
PlayerX2: ds.w 1
PlayerY2: ds.w 1

spritehclip: ds.w 1

