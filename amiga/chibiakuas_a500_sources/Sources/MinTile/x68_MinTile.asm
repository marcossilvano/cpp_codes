
ScreenBase equ $c00000+(1024*16)


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



			;		 FEDCBA9876543210	
			move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
			move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
			;		 --SSTTGG44332211
			move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
			;		 FEDCBA9876543210	
			;				  ST43210		
			move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
			
			move.w #$025,$E80000 	;R00 Horizontal total 
			move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
			move.w #$000,$E80004	;R02 Horizontal display start position
			move.w #$020,$E80006	;R03 Horizontal display end position
			move.w #$103,$E80008	;R04 Vertical total 
			move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
			move.w #$010,$E8000C	;R06 Vertical display start position
			move.w #$100,$E8000E	;R07 Vertical display end position
			move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
			
			;move.w #$25,$EB080A		; Sprite H Total
			;move.w #$04,$EB080C		; Sprite H Disp
			;move.w #$10,$EB080E		; Sprite V Disp
			;move.w #$00,$EB0810		; Sprite Res %---FVVHH

;Palette	
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82000	;Color 0
	move.w #%0000001110011100,$e82002	;Color 1
	move.w #%1111100000111110,$e82004	;Color 2
	move.w #%1111111111111110,$e82006	;Color 3


	
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
	
	;move.l #TestSprite,a5
	;move.l #TileCache,a2
	;jsr cls
	

	move.l #ChibikoDef,a4
	;jsr DrawSpriteAlways	;Draw Player Sprite

	
	
	move.w #$60,d1			;Back up X
	move.w #$60,d4			;Back up Y
	

	;jsr DrawPlayer			;Draw Player Sprite
	
	
	
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
	


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
GetScreenPos: 					;d1=x d2=y (in pairs of pixels)
	moveM.l d0-d7,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		asl.l #2,d1				;2 bytes per pixel
		move.l d1,a6
		
		rol.l #8,d4				;1024 bytes per Y line 
		rol.l #3,d4
		add.l d4,a6
		
		add.l #$c00000+(1024*16),a6	;Graphics Vram – Page 0
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

NextTile:
	clr.l d0
	move.b (a2),d0			;A2=Tilemap data
	beq TileDone
	
	tst.b (TileClear)		;Clear Tiles?
	beq NoClear
	clr.b (a2)				;Yes!
NoClear:

	lsl.l #5,d0				;Tile num *32

	move.l a5,a3			;A5=Bitmap Source
	add.l d0,a3
	
	move.l a6,-(sp)
		move.w #7,d1		;Line Count -1
		clr.l d0
		
DrawTileNextLine:			;A6=Vram Dest
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		move.b (a3)+,d0		
		move.w d0,(a6)+		;Copy Bottom Nibble
			
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		move.b (a3)+,d0		
		move.w d0,(a6)+		;Copy Bottom Nibble
		
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		move.b (a3)+,d0		
		move.w d0,(a6)+		;Copy Bottom Nibble
		
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		move.b (a3)+,d0		
		move.w d0,(a6)+		;Copy Bottom Nibble
		
		add.l #1024-16,a6	;Down a VRAM line
		
		dbra d1,DrawTileNextLine	;Next line
	move.l (sp)+,a6

TileDone:		
	addq.l #1,a2			;Next Tilemap Tile
	add.l #16,a6			;Across one screen tile
	
	subq.b #1,d7			;Tile count
	bne NextTile
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DoStripRev:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

NextTileRev:
	clr.l d0
	move.b (a2),d0			;A2=Tilemap data
	beq TileDoneRev
	
	tst.b (TileClear)		;Clear Tiles?
	beq NoClearRev
	clr.b (a2)				;Yes!
NoClearRev:

	lsl.l #5,d0				;Tile num *32

	move.l a5,a3			;A5=Bitmap Source
	add.l d0,a3
	
	move.l a6,-(sp)
		move.w #7,d1		;Line Count -1
		clr.l d0
		add.l #4,a3			;Move to last byte of line
		
DrawTileNextLineRev:	
		move.b -(a3),d0
		move.w d0,(a6)+		;Copy Bottom Nibble
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		
		move.b -(a3),d0
		move.w d0,(a6)+		;Copy Bottom Nibble
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		
		move.b -(a3),d0
		move.w d0,(a6)+		;Copy Bottom Nibble
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		
		move.b -(a3),d0
		move.w d0,(a6)+		;Copy Bottom Nibble
		move.b (a3),d0		
		ror.b #4,d0			
		move.w d0,(a6)+		;Copy Top Nibble
		
		add.l #8,a3			;Next source line
		add.l #1024-16,a6	;Down a VRAM line
		
		dbra d1,DrawTileNextLineRev		;Next line
	move.l (sp)+,a6

TileDoneRev:		
	subq.l #1,a2			;Next Tilemap Tile
	add.l #16,a6			;Across one screen tile
	
	subq.b #1,d7			;Tile count
	bne NextTileRev
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	include "/srcALL/V1_MinimalTile.asm"

TestSprite:
	incbin "\ResALL\Yquest\MSX2_Yquest.raw"
TestChibiko:
	incbin "\ResALL\SpeedTiles\Chibiko2TilesSAM.RAW"

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
	
;Current player pos
PlayerX: dc.w $10
PlayerY: dc.w $10

;Last player pos (For clearing sprite)
PlayerX2: dc.w $10
PlayerY2: dc.w $10

spritehclip: dc.l 0




ReadJoystick:		;Returns: ---7654S321RLDU

	;move.l #$E9A003,a0			;Select Joystick # 2
	move.l #$E9A001,a0		;Select Joystick # 1
	
JoystickProcessOne:			;Returns: ---7654S321RLDU
	clr.l d0
	
;	         76543210
	move.b #%00000000,$E9A005	;8255 Port C (Default Controls)
	move.b (a0),d1				;-21-RLDU
	roxr.b d1
	roxr.b d0	;U
	roxr.b d1
	roxr.b d0	;D
	roxr.b d1
	roxr.b d0	;L
	roxr.b d1
	roxr.b d0	;R
	roxr.b #2,d1				;skip -
	
	roxr.b d0	;F1
	roxr.b d1
	roxr.b d0	;F2
	
	;	     76543210
	move.b #%00110000,$E9A005	;8255 Port C (Get Extra Controls)
	move.b (a0),d1				;-S3-M654 ?
	move.b d1,d3
	roxr.b #6,d1				;-------S 3	
	roxr.b d0	;F3
	roxr.b d1
	roxr.b d0	;Start
	
	and.l #$0000000F,d3			;____M654
	rol.l #8,d3
	
	or.l d3,d0
	or.l #$FFFFF000,d0
KeyboardScanner_AllowJoysticks:
	rts	
	
	