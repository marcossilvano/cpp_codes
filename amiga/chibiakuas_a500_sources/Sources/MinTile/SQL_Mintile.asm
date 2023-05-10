
ScreenBase equ $00020000+(128*32)


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




UserRam equ $38000		;Don't try this at home! may corrupt part of the OS if we're unlucky

SqlProgbase equ $30000
	org SqlProgbase

QlProg_Start:
	
	Trap #0						;Supervisor mode
	ori #0700,sr				;Disable interrupts
	
		move.b #%00001000,$18063	;Force 8 color mode!
	
		lea QlProg_Start,a1
		move.l #SqlProgbase,a0
		move.l #QlProg_End-QlProg_Start,d0
QlProg_CopyAgain:	
		move.b (a1)+,(a0)+
		dbra d0,QlProg_CopyAgain
		

		jmp (SqlProgbase+(QlProg_Run-QlProg_Start))
QlProg_Run:	


	move.l #$00020000+512,sp	;Set up stack pointer
	
	
	
;Build our X-flip LUT

	move.l #FlipLUT,a0		;256 byte Lookup Table
	clr.b d1				;Byte to flip
FillLut:
	
	move.b d1,d0
	and.b #%00000011,d0		;---D
	rol.b #6,d0				;D---
	move.b d0,d2
	
	move.b d1,d0	
	and.b #%00001100,d0		;--C-
	rol.b #2,d0				;-C--
	or.b d0,d2
	
	move.b d1,d0
	and.b #%00110000,d0		;-B--
	ror.b #2,d0				;--B-
	or.b d0,d2			
	
	move.b d1,d0
	and.b #%11000000,d0		;A---
	ror.b #6,d0				;---A
	or.b d0,d2
	move.b d2,(a0)+			
	
	addq.b #1,d1
	bne FillLut				;Repeat for all 256


;Copy tilemap to cache	
	
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
	
	
;Draw the screen	
	
	move.l #TestSprite,a5
	move.l #TileCache,a2
	jsr cls
	
	

;	move.l #ChibikoDef,a4
;	jsr DrawSpriteAlways	;Draw Player Sprite

	
	move.w #$60,d1			;Xpos
	move.w #$60,d4			;Ypos
	
	
InfLoop:
	moveM.l d1/d4,-(sp)
		jsr ReadJoystick
		
	moveM.l (sp)+,d1/d4
	
	
	move.l d0,-(sp)
StartDraw:
		move.b d0,d3
				
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
	
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	


QLJoycommand:
	dc.b $09	;0 - Command
	dc.b $01	;1 - parameter bytes
	dc.l 0		;2345 - send option (%00=low nibble)
	dc.b 1		;6 - Parameter: Row
	dc.b 2		;7 - length of reply (%10=8 bits)
	even
	
ReadJoystick:
		 lea QLJoycommand,a3
		 move.b #$11,d0	;Command 17
		 Trap #1		;Send Keyrequest to the IO CPU
						;Returns row in D1
		
		clr.l d0		;D0 is our result
		
		move.b d1,d2
		roxr.b #4,d2	; ESC
		roxl.b #1,d0	;Start (4)
		
		roxr.b #2,d2	; \ 
		roxl.b #1,d0	;Fire 3 (6)
		
		move.b d1,d2
		roxr.b #1,d2	; Enter (1)
		roxl.b #1,d0	;Fire 2
		
		roxr.b #6,d2	;Space (7)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #5,d2	;Right (5)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #2,d2	;Left (2)
		roxl.b #1,d0
		
		roxr.b #6,d2	;Down (8)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #3,d2	;Up   (3)
		roxl.b #1,d0
		
		eor.b #$FF,d0		;Flip Player 1 bits
		rts
		

	include "/srcALL/V1_MinimalTile.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

GetScreenPos: ; d1=x d4=y (in pairs of pixels)
	and.l #$FE,d1
	and.l #$FF,d4
	
;	rol.l #1,d1				;Multiply X*2 (2 bytes per 4/8 pixels)
	rol.l #8,d4				;Multiply Y*128*2
	
	move.l #$00020000+(128*32),a6	;Screen starts at $20000
	add.l d4,a6
	add.l d1,a6
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

NextTile:
	clr.l d0
	move.b (a2),d0		;A2=Tilemap data
	beq EmptyTile
	
	tst.b (TileClear)	;Clear Tiles?
	beq NoClear
	clr.b (a2)			;Yes!
NoClear:

	lsl.l #5,d0			;Tile num *32
	move.l a5,a3		;A5=Bitmap Source
	add.l d0,a3			;A3=Source Pattern data
	
	addq.l #1,a2		;Next Tilemap Tile
	
	move.l #128,d1		;Bytes per line

	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3)+,d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	add.l d1,a6			;Down a line
	
	move.l (a3),d0		;Get a source long from pattern
	move.l d0,(a6)		;Write to screen (8 pixels)	
	
	sub.l #128*7-4,a6	;Back up + across one tile
	
	subq.b #1,d7		;Repeat until all tiles done
	bne NextTile
	rts
	
EmptyTile:
	addq.l #1,a2		;Next Tilemap Tile
	add.l #4,a6			;Across one VRAM tile
	subq.b #1,d7		;Repeat until all tiles done
	bne NextTile
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DoStripRev:
	move.l #FlipLUT,a1

NextTileRev:
	clr.l d0
	move.b (a2),d0		;A2=Tilemap data
	beq EmptyTileRev
	
	tst.b (TileClear)	;Clear Tiles?
	beq NoClearRev
	clr.b (a2)			;Yes!
NoClearRev:

	lsl.l #5,d0			;Tile num *32

	move.l a5,a3		;A5=Bitmap Source
	add.l d0,a3
		
	subq.l #1,a2		;Next Tilemap Tile
	move.l #128+1,d2		;Bytes per line
	
	move.w #7,d1		;Line Count 8-1=7
	clr.l d0
DrawTileNextLineRev:	
	move.b (a3)+,d0		;Get a source Byte from pattern
	move.b (a1,d0),d0	;Flip Via LUT
	move.b d0,(a6)+		;Write to screen
	
	move.b (a3)+,d0		;Get a source Byte from pattern
	move.b (a1,d0),d0	;Flip Via LUT
	move.b d0,(a6)		;Write to screen
	
	subq.l #3,a6		;Back 4 pixels 
	
	move.b (a3)+,d0		;Get a source Byte from pattern
	move.b (a1,d0),d0	;Flip Via LUT
	move.b d0,(a6)+		;Write to screen
	
	move.b (a3)+,d0		;Get a source Byte from pattern
	move.b (a1,d0),d0	;Flip Via LUT
	move.b d0,(a6)		;Write to screen
					
	add.l d2,a6		;Down one screen line
	dbra d1,DrawTileNextLineRev
		
	sub.l #1024-4,a6	;Back up + across one tile
	
	subq.b #1,d7
	bne NextTileRev		;Repeat until all tiles done
	rts
	
EmptyTileRev:
	subq.l #1,a2		;Next Tilemap Tile
	add.l #4,a6			;Across one VRAM tile
	
	subq.b #1,d7		;Repeat until all tiles done
	bne NextTileRev
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
FlipLUT:		;bottom byte of address must be $????00-???FF
	ds 256
	

TestSprite:
	ds 16
	incbin "\ResALL\Yquest\SQL_YQuest.RAW"
TestChibiko:
	incbin "\ResALL\SpeedTiles\Chibiko2TilesSQL.RAW"

TileCache:
	ds 24*32


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
	
ChibicloneDef:
	dc.l TestSpriteList	;Tilemap
	dc.l TestChibiko		;Pattern Data
	dc.b 20,32		;Width,Height
	dc.b 64,128		;X,Y
	dc.b 1,1			;RefreshTile,Sprite
	dc.b 64,128		;X,Y
	dc.b 0,0			;Flags
	
ChibikoDef:
	dc.l TestSpriteList	;Tilemap
	dc.l TestChibiko		;Pattern Data
	dc.b 20,32		;Width,Height
	dc.b $60,$60		;X,Y
	dc.b 1,1			;RefreshTile,Sprite
	dc.b 64,128		;X,Y
	dc.b 1,1			;Flags

ZeroTileCacheRev: dc.w 0	
striproutine: dc.w 0
TileClear: dc.w 0
offset1:  dc.w 0
offset2:  dc.w 0
	
spritehclip: dc.l 0





QlProg_End: