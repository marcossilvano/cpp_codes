
ScreenBase equ screen_mem+4


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


DMACON  EQU $dff096 ;DMA control write (clear or set)
DMACONR  EQU $dff002 

INTENA  EQU $dff09a ;Interrupt enable bits (clear or set bits)
BPLCON0 EQU $dff100 ;Bitplane control register (misc. control bits)
BPLCON1 EQU $dff102 ;Bitplane control reg. (scroll value PF1, PF2)
BPL1MOD EQU $dff108 ;Bitplane modulo (odd planes)
BPL2MOD EQU $dff10a ;Bitplane modulo (even planes)
DIWSTRT EQU $dff08e ;Display window start (upper left vert-horiz position)
DIWSTOP EQU $dff090 ;Display window stop (lower right vert.-horiz. Position)
DDFSTRT EQU $dff092 ;Display bitplane data fetch start (horiz. Position)
DDFSTOP EQU $dff094 ;Display bitplane data fetch stop (horiz. position)
COP1LCH EQU $dff080	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
;--Bz--P-- --------

;Blitter hardware
	
BLTCON0 equ $DFF040	;Blitter control register 0 
BLTCON1 equ $DFF042	;Blitter control register 1

BLTAFWM equ $DFF044	;First Word Mask for A
BLTALWM equ $DFF046	;Last Word Mask for A

BLTCPTH equ $DFF048 ;Address C H
BLTCPTL equ $DFF04A ;Address C L

BLTBPTH equ $DFF04C ;Address B H
BLTBPTL equ $DFF04E ;Address B L

BLTAPTH equ $DFF050 ;Address A H
BLTAPTL equ $DFF052 ;Address A L

BLTDPTH equ $DFF054 ;Address D H
BLTDPTL equ $DFF056 ;Address D L

BLTSIZE equ $DFF058 ;Size of area + START!

BLTCMOD equ $DFF060 ;Modulo C
BLTBMOD equ $DFF062 ;Modulo B
BLTAMOD equ $DFF064 ;Modulo A
BLTDMOD equ $DFF066 ;Modulo D
	
	
	SECTION TEXT		;CODE Section
	
	
			;Enable the screen display
	
	move.l	#gfxname,a1 	;'graphics.library' defined in chip ram
	moveq.l	#0,d0
	move.l	$4,a6
	jsr	(-552,a6)			;Exec - Openlibrary
	
	move.l	d0,gfxbase
	move.l 	d0,a6
	move.l #0,a1			;Null view
	jsr (-222,a6)			;LoadView - Use a (possibly freshly created) coprocessor 
							;	instruction list to create the current display.
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;Start defining our screen layout
	
; 		      FEDCBA9876543210
; 			  RPPPHDCG----PIE-	 		;four bitPlanes (16 color) Color on
	move.w	#%0100001000000000,BPLCON0	;Bitplane control register (misc. control bits)
	
	move.w	#$0000,BPLCON1				;Horizontal scroll 0 - Bitplane control reg. (scroll value PF1, PF2)
	
;4 bitplanes 
;40 bytes each - so skip 3 bitplanes (3*40=120) after each line
	move.w	#120,BPL1MOD				;Bitplane modulo (odd planes)
	move.w	#120,BPL2MOD				;Bitplane modulo (even planes)
	
	
	move.w	#$2c81,DIWSTRT				;Display window start (upper left vert-horiz position)
	move.w	#$F4C1,DIWSTOP				;Display window stop (lower right vert.-horiz. Position)
	move.w	#$0038,DDFSTRT				;Display bitplane data fetch start (horiz. Position)
	move.w	#$00d0,DDFSTOP				;Display bitplane data fetch stop (horiz. position)
		  	; FEDCBA9876543210
			;-------DbCBSDAAAA
	move.w  #%1000000110000000,DMACON   ;DMA set ON  - DMA control (and blitter status) read 
										;	(Bit 15 defines set/clear for other bits)
			;-------DbCBSDAAAA
	move.w 	#%0000000001011111,DMACON	;DMA set OFF - turn off sound
	move.w 	#%1100000000000000,INTENA	;IRQ set ON  - Interrupt enable bits read - Turn on master
	move.w 	#%0011111111111111,INTENA	;IRQ set OFF - Turn off all others

	
	
	
	lea CopperList,a6					;Copperlist (Commands run by Copper Coprocessor) -all addresses start DFFnnn
   ;Entry format:
   ;Change setting:
   ; %0000000n nnnnnnn0 DDDDDDDD DDDDDDDD	nnn= address to Change ($DFFnnn) DDDD=new value to set address
   
   ;wait for pos:
   ; $VVVVVVVV HHHHHHH1 1vvvvvvv hhhhhhh0   V=Vops H=Hpos v= Vpos Compare enable  h=hpos compare enable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ;Define Memory layout
   ;4 bitplanes are interleaved on concecutive Y lines 
   
	;Send the address of each bitplane in two parts
	move.l #Screen_Mem+(40*0),d0	;Bitplane 0
	move.w #$00e2,(a6)+			;Bitplane 0 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e0,(a6)+			;Bitplane 0 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*1),d0	;Bitplane 1
	move.w #$00e6,(a6)+			;Bitplane 1 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e4,(a6)+			;Bitplane 1 pointer (high 3 bits)
	move.w d0,(a6)+		

	move.l #Screen_Mem+(40*2),d0	;Bitplane 2
	move.w #$00ea,(a6)+			;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e8,(a6)+			;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*3),d0	;Bitplane 3
	move.w #$00eE,(a6)+			;Bitplane 3 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00eC,(a6)+			;Bitplane 3 pointer (high 3 bits)
	move.w d0,(a6)+		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l a6,(a1)			;the copperlist into our pointer for easy changing
	       ; AAAA-RGB		;Address - RGB
    move.l #$01800000,(a6)+ ;0  -RGB
    move.l #$0182080F,(a6)+ ;1  -RGB
    move.l #$018400FF,(a6)+ ;2  -RGB
    move.l #$01860FFF,(a6)+ ;3  -RGB
    move.l #$01880008,(a6)+ ;4  -RGB
    move.l #$018A0808,(a6)+ ;5  -RGB
    move.l #$018C0088,(a6)+ ;6  -RGB
    move.l #$018E0CCC,(a6)+ ;7  -RGB
    move.l #$01900888,(a6)+ ;8  -RGB
    move.l #$01920F00,(a6)+ ;9  -RGB
    move.l #$019400F0,(a6)+ ;10  -RGB
    move.l #$01960FF0,(a6)+ ;11  -RGB
    move.l #$0198000F,(a6)+ ;12  -RGB
    move.l #$019A0F0F,(a6)+ ;13  -RGB
    move.l #$019C00FF,(a6)+ ;14  -RGB
    move.l #$019E0FFF,(a6)+ ;15  -RGB
    move.l #$01A00000,(a6)+ ;16  -RGB
    move.l #$01A20000,(a6)+ ;17  -RGB
    move.l #$01A40111,(a6)+ ;18  -RGB
    move.l #$01A60111,(a6)+ ;19  -RGB
    move.l #$01A80222,(a6)+ ;20  -RGB
    move.l #$01AA0222,(a6)+ ;21  -RGB
    move.l #$01AC0333,(a6)+ ;22  -RGB
    move.l #$01AE0333,(a6)+ ;23  -RGB
    move.l #$01B00444,(a6)+ ;24  -RGB
    move.l #$01B20444,(a6)+ ;25  -RGB
    move.l #$01B40555,(a6)+ ;26  -RGB
    move.l #$01B60555,(a6)+ ;27  -RGB
    move.l #$01B80666,(a6)+ ;28  -RGB
    move.l #$01BA0666,(a6)+ ;29  -RGB
    move.l #$01BC0777,(a6)+ ;30  -RGB
    move.l #$01BE0777,(a6)+ ;31  -RGB

	move.l #$fffffffe,(a6)+		; end of copperlist (COPPER_HALT)

	jsr waitVBlank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	;Enable Copperlist
	
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)

			 
			 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Enable BLIT DMA		 
	;        FEDCBA9876543210
	;move.w #%1000000001000000,(DMACON)  ;$DFF096 DMACON - DMA control write (clear or set)
										;S-----E- ---DCBA	S=Set/Clr E=enable ABCD=Channnels	
										
										
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

;	jmp *
	
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
	

waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;Addr = ScreenMem + (Ypos * 40) + Xpos
 ;d1=x d4=y - returns screen address in A6

GetScreenPos:
	lea screen_mem+4,a6  	;Load address of screen (in chip ram) into A6
	
	and.l #$FF,d1			;Clear all but the bottom byte
	lsr #2,d1				;Convert to tiles
	add.l d1,a6				;Add X 
	
	and.l #$FF,d4
	mulu #40*4*2,d4			;4 bitplanes 40 bytes per Y line 
	add.l d4,a6
	rts
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

NextTile:
	clr.l d0
	move.b (a2),d0		;A2=Tilemap data
	beq EmptyTile
	
	tst.b (TileClear)	;Clear Tiles?
	beq NoClear
	clr.b (a2)			;Yes!
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
		move.b (a3)+,(40,a6)	;Bitplane 1
		move.b (a3)+,(80,a6)	;Bitplane 2
		move.b (a3)+,(120,a6)	;Bitplane 3
		
		add.l #160,a6			;Down one pixel line
		
		dbra d1,DrawTileNextLine	;Next Line
		
	move.l (sp)+,a6

TileDone:		
	add.l #1,a6			;Across one tile
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTile
	rts
	
EmptyTile:
	addq.l #1,a2		;Next Tilemap Tile
	
	add.l #1,a6			;Across one tile
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTile
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DoStripRev:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

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
		
	subq.l #1,a2		;Next Tilemap Tile
	
	move.l a6,-(sp)
		move.w #7,d1	;8 lines
		clr.l d0
		
DrawTileNextLineRev:	
		move.b (a3)+,d0		;Get a source byte
		move.b (a1,d0),d0	;Convert via LUT
		move.b d0,(a6)		;Bitplane 0
		
		move.b (a3)+,d0		;Get a source byte
		move.b (a1,d0),d0	;Convert via LUT
		move.b d0,(40,a6)	;Bitplane 1
			
		move.b (a3)+,d0		;Get a source byte
		move.b (a1,d0),d0	;Convert via LUT
		move.b d0,(80,a6)	;Bitplane 2
		
		move.b (a3)+,d0		;Get a source byte
		move.b (a1,d0),d0	;Convert via LUT
		move.b d0,(120,a6)	;Bitplane 3

		add.l #160,a6		;Down one pixel line
		
		dbra d1,DrawTileNextLineRev
	move.l (sp)+,a6

TileDoneRev:		
	add.l #1,a6			;Across one tile
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTileRev
	rts
	
EmptyTileRev:
	subq.l #1,a2		;Next Tilemap Tile
	
	add.l #1,a6			;Across one tile
	
	subq.b #1,d7		;Repeat for next tile
	bne NextTileRev
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	include "/srcALL/V1_MinimalTile.asm"

TestSprite:
	incbin "\ResALL\Yquest\AST_YQuest.RAW"
TestChibiko:
	incbin "\ResALL\SpeedTiles\Chibiko2TilesAST.RAW"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	


ReadJoystick:		;Returns: ---7654S321RLDU
	move.b #%00111111,$BFE201	;Direction for port A (BFE001)....0=in 1=out... 
								;(For fire buttons)

	;move.w $dff00A,d2			;Joystick-mouse 0 data (vert,horiz) (Joy2)
	;move.b $bfe001,d5			;/FIR1 /FIR0  /RDY /TK0  /WPRO /CHNG /LED  OVL
	;rol.b #1,d5					;Fire0 for joy 2
		
	move.w $dff00c,d2		;Joystick-mouse 1 data (vert,horiz) (Joy1)
	move.b $bfe001,d5		;/FIR1 /FIR0  /RDY /TK0  /WPRO /CHNG /LED  OVL

Player_ReadControlsOne:	;Translate HV data into joystick values
	clr.l d0	
	clr.l d1
	clr.l d3
	clr.l d4
	
	;Get the 4 bits that are needed for the directions
	roxr.l #1,d2	;bit 0
	roxl.l #1,d3
	roxr.l #1,d2	;bit 1
	roxl.l #1,d4
	roxr.l #7,d2	;bit 8
	roxl.l #1,d0
	and.l #1,d2		;bit 9
	
	;Calculate the new directions
	move.b d2,d1
	eor.b d0,d1
	roxr.b d1
	roxr.b d0		;Up (Bit 9 Xor 8)
	
	move.b d4,d1
	eor.b d3,d1
	roxr.b d1
	roxr.b d0		;Down (Bit 1 Xor 0)
	
	roxr.b d2
	roxr.b d0		;Left (Bit 9)
	roxr.b d4
	roxr.b d0		;Right (Bit 1)
	
	roxl.b d5
	roxr.b d0		;Fire
	
	ror.b #3,d0
	eor.b #%11101111,d0	;Invert UDLR bits
	or.l #$FFFFFF00,d0	;Set unused bits
	rts
	
	

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxbase:	dc.l 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Section ChipRAM,Data_c		;Request memory within the 'Chip Ram' base memory 
								;This is the only ram our screen and copperlist can use
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	CNOP 0,4					;Pad with NOP to next 32 bit boundary
	
	

Screen_Mem:						;This is our screen
	ds.b    320*200*4			;320x200 4 bitplanes (16 color)

	CNOP 0,4					;Pad with NOP to next 32 bit boundary
CopperList:
	dc.l $ffffffe 				;COPPER_HALT - end of list (new list)
	ds.b 1024					;Define 1024 bytes of chip ram for our copperlist

	
ChibicloneDef:
	ds.b 32
	
ChibikoDef:
	ds.b 32


	
	;CNOP 0,8
FlipLUT:
	ds 256

TileCache:
	ds 24*32

	
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

