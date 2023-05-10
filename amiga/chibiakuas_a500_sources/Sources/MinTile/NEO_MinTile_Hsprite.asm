TestChibiko equ $2800
TestChibikoRev equ $2800	;We need reversed tiles for the FIX layer
TestSprite equ $2200

ScreenBase equ $7000+4+(32*4)	;Not used

TileCache equ $100000

	
ChibicloneDef equ $100400
ChibikoDef 	  equ $100420


ZeroTileCacheRev  equ $100500
striproutine 	  equ $100502
TileClear 		  equ $100504
offset1 		  equ $100506
offset2			  equ $100508
spritehclip   	  equ $10050A
HSpriteNum		  equ $10050B


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



;Ram Variables

flag_VBlank	equ  $100600   	;(byte) vblank flag in ram


; This Header is based on the work from 
; "Neo-Geo Assembly Programming for the Absolute Beginner" by freem
; http://ajworld.net/neogeodev/beginner/

	
	dc.l	$0010F300		; Initial Supervisor Stack Pointer (SSP)
	dc.l	$00C00402		; Initial PC			(BIOS $C00402)
	dc.l	$00C00408		; Bus error/Monitor		(BIOS $C00408)
	dc.l	$00C0040E		; Address error			(BIOS $C0040E)
	dc.l	$00C00414		; Illegal Instruction	(BIOS $C00414)
	dc.l	$00C00426		; Divide by 0
	dc.l	$00C00426		; CHK Instruction
	dc.l	$00C00426		; TRAPV Instruction
	dc.l	$00C0041A		; Privilege Violation	(BIOS $C0041A)
	dc.l	$00C00420		; Trace					(BIOS $C00420)
	dc.l	$00C00426		; Line 1010 Emulator
	dc.l	$00C00426		; Line 1111 Emulator
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C0042C		; Uninitialized Interrupt Vector

	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00426		; Reserved
	dc.l	$00C00432		; Spurious Interrupt
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 									Interrupts
	dc.l	VBlank			; Level 1 interrupt (VBlank)
	dc.l	IRQ2			; Level 2 interrupt (HBlank)
	dc.l	IRQ3			; Level 3 interrupt
	dc.l	$00000000		; Level 4 interrupt
	dc.l	$00000000		; Level 5 interrupt
	dc.l	$00000000		; Level 6 interrupt
	dc.l	$00000000		; Level 7 interrupt (NMI)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;									 Traps
	dc.l	$FFFFFFFF		; TRAP #0 Instruction
	dc.l	$FFFFFFFF		; TRAP #1 Instruction
	dc.l	$FFFFFFFF		; TRAP #2 Instruction
	dc.l	$FFFFFFFF		; TRAP #3 Instruction
	dc.l	$FFFFFFFF		; TRAP #4 Instruction
	dc.l	$FFFFFFFF		; TRAP #5 Instruction
	dc.l	$FFFFFFFF		; TRAP #6 Instruction
	dc.l	$FFFFFFFF		; TRAP #7 Instruction
	dc.l	$FFFFFFFF		; TRAP #8 Instruction
	dc.l	$FFFFFFFF		; TRAP #9 Instruction
	dc.l	$FFFFFFFF		; TRAP #10 Instruction
	dc.l	$FFFFFFFF		; TRAP #11 Instruction
	dc.l	$FFFFFFFF		; TRAP #12 Instruction
	dc.l	$FFFFFFFF		; TRAP #13 Instruction
	dc.l	$FFFFFFFF		; TRAP #14 Instruction
	dc.l	$FFFFFFFF		; TRAP #15 Instruction
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	dc.l	$FFFFFFFF		; Reserved
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;							Cart Header
	dc.b "NEO-GEO"
	dc.b $00 			;System Version (0=cart; 1/2 are used for CD games)
	dc.w $0FFF 			;NGH number ($0000 is prohibited)
	dc.l $00080000 		;game prog size in bytes (4Mbits/512KB)
	dc.l $00108000 		;pointer to backup RAM block (first two bytes are debug dips)
	dc.w $0000 			;game save size in bytes
	dc.b $00 			;Eye catcher anim flag (0=BIOS,1=game,2=nothing)
	dc.b $00 			;Sprite bank for eyecatch if done by BIOS
	dc.l softDips_All  	;Software dips for Japan
	dc.l softDips_All   ;Software dips for USA
	dc.l softDips_All 	;Software dips for Europe
	jmp USER 			; $122
	jmp PLAYER_START 	; $128
	jmp DEMO_END 		; $12E
	jmp COIN_SOUND 		; $134

	dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
	dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
	dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
	dc.l $FFFFFFFF,$FFFFFFFF,$FFFFFFFF,$FFFFFFFF
	dc.l $FFFFFFFF,$FFFFFFFF

	;org $00000182
	dc.l TRAP_CODE 				;pointer to TRAP_CODE

	; security code required by Neo-Geo games
TRAP_CODE:
	dc.l $76004A6D,$0A146600,$003C206D,$0A043E2D
	dc.l $0A0813C0,$00300001,$32100C01,$00FF671A
	dc.l $30280002,$B02D0ACE,$66103028,$0004B02D
	dc.l $0ACF6606,$B22D0AD0,$67085088,$51CFFFD4
	dc.l $36074E75,$206D0A04,$3E2D0A08,$3210E049
	dc.l $0C0100FF,$671A3010,$B02D0ACE,$66123028
	dc.l $0002E048,$B02D0ACF,$6606B22D,$0AD06708
	dc.l $588851CF,$FFD83607
	dc.w $4E75
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 				Software Dip Switches (a.k.a. "soft dip")
softDips_All:
	dc.b "EXAMPLE SET A   " 		; Game Name
	dc.w $FFFF 						; Special Option 1
	dc.w $FFFF 						; Special Option 2
	dc.b $FF 						; Special Option 3
	dc.b $FF 						; Special Option 4
	dc.b $02 						; Option 1: 2 choices, default #0
	dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00 ; filler
	dc.b "OPTION 1A   " 			; Option 1 description
	dc.b "CHOICE1 A   " 			; Option choices
	dc.b "CHOICE2 A   "

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 									USER
; Needs to perform actions according to the value in BIOS_USER_REQUEST.
; Must jump back to SYSTEM_RETURN at the end so the BIOS can have control.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

USER:	
	move.b	d0,$300001			;Kick watchdog
	lea		$10F300,sp			;Set stack pointer to BIOS_WORKRAM
	move.w	#0,$3C0006			;LSPC_MODE - Disable auto-animation, timer interrupts
									;set auto-anim speed to 0 frames
	move.w	#7,$3C000C			;LSPC_IRQ_ACK - acknowledge all IRQs

	move.w	#$2000,sr			; Enable VBlank interrupt, go Supervisor

	; Handle user request
	moveq	#0,d0
	move.b	($10FDAE).l,d0		;BIOS_USER_REQUEST
	lsl.b	#2,d0				; shift value left to get offset into table
	lea		cmds_USER_REQUEST,a0
	movea.l	(a0,d0),a0
	jsr		(a0)
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 							BIOS_USER_REQUEST commands

cmds_USER_REQUEST:
	dc.l	userReq_StartupInit	; Command 0 (Initialize)
	dc.l	userReq_StartupInit	; Command 1 (Custom eyecatch)
	dc.l	userReq_Game		; Command 2 (Demo Game/Game)
	dc.l	userReq_Game		; Command 3 (Title Display)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 							userReq_StartupInit

userReq_StartupInit:
	move.b	d0,$300001		;REG_DIPSW - kick watchdog
	jmp		$C00444			;SYSTEM_RETURN

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;				Handle Interrupts and system events	
	
PLAYER_START:					;Player pressed start on title
	move.b	d0,$300001;REG_DIPSW		; kick the watchdog
	rts
	
COIN_SOUND:					
DEMO_END:						
	rts

VBlank:
	btst	#7,$10FD80			;BIOS_SYSTEM_MODE - check if the BIOS wants to run its vblank
	bne		gamevbl
	jmp		$C00438				;SYSTEM_INT1 - run BIOS vblank
gamevbl:						;run the game's vblank
	movem.l d0-d7/a0-a6,-(sp)	;save registers
		move.w	#4,$3C000C		;LSPC_IRQ_ACK - acknowledge the vblank interrupt
		move.b	d0,$300001		;REG_DIPSW - kick the watchdog	
		jsr		$C0044A 		;"Call SYSTEM_IO every 1/60 second."
		jsr		$C004CE			;Puzzle Bobble calls MESS_OUT just after SYSTEM_IO
		move.b	#0,flag_VBlank	;clear vblank flag so waitVBlank knows to stop
	movem.l (sp)+,d0-d7/a0-a6	;restore registers
	rte

IRQ2:
	move.w	#2,$3C000C		;LSPC_IRQ_ACK - ack. interrupt #2 (HBlank)
	move.b	d0,$300001		;REG_DIPSW - kick watchdog
	rte
IRQ3:
	move.w  #1,$3C000C		;LSPC_IRQ_ACK - acknowledge interrupt 3
	move.b	d0,$300001		;REG_DIPSW - kick watchdog
	rte
	 	
		
		
;==============================================================================;
; WaitVBlank
; Waits for VBlank to finish (via a flag cleared at the end).

WaitVBlank:
	move.b	#1,flag_VBlank		; set our flag, which gets unset in our vblank

.waitLoop
	tst.b	flag_VBlank			; test the flag
	bne.s	.waitLoop			; if it's not cleared, keep looping until vblank finishes

	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 							UserReq_Game

userReq_Game:
	move.b	d0,$300001		;REG_DIPSW -Kick watchdog
	
	
	jsr $C004C2 			;FIX_CLEAR - clear fix layer
	jsr $C004C8				;LSP_1st   - clear first sprite

		
	;        -RGB			
	move.w #$0000,$401FFE	;0 - Common Background color
	
	lea Palette,a3
	move.l #$400020,a2
	move.l #16-1,d0
PaletteAgain:	
	move.w (a3)+,(a2)+	
	dbra d0,PaletteAgain
	
		
;;;;;;;;;;;; Define TileMap ;;;;;;;;;;;;;;;;;;;;;;;;
	
	move.w #$0000,d6		;Tile Vran Addr $0000
	
	;move.w #$0FFF,d5 		;Scale (16x16 Normal)
	move.w #$077F,d5 		;Scale (8x8   Half Size)
	;move.w #$0110,d5 		;Scale (Tiny!)
	
	move.l #32-1,d4			;Sprites (Width)
	move.l #24-1,d2			;Tiles per sprite (height)
	
	
;;;;;;;;;;;; Anchor Sprite (one) ;;;;;;;;;;;;;;;;;;;;;;;;
;First sprite is anchor to others!

	move.w #$8000,d7		;Attribs addr $8000+ (Shrink)
	Move.w d7,$3C0000 		
	move.w d5,$3C0002		;----HHHH VVVVVVVV - Shrink
	
	add.w #$200,d7			;$8200+ (Ypos)
	Move.w d7,$3C0000 		
	move.w #$F021,d0		;33=32 tall (looping)
	move.w d0,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
	
	add.w #$200,d7			;$8400+ (Xpos)
	move.w d7,$3C0000 	
	move.w #$1000,$3C0002	;XXXXXXXX X------- Xpos
	
	sub.w #$400,d7			;$8000+ (Shrink)
		
;;;;;;;;;;;; Tiles (Columns) ;;;;;;;;;;;;;;;;;;;;;;;;
SpriteLoop:	
	move.l d2,d3			;Init Counter for Tilecount
	
TileLoop: ; Sprites in column ;;;;;;;;;;;
	move.w d6,$3C0000 		;$0000+ (TileAddr)
	move.w #$2200,$3C0002	;NNNNNNNN NNNNNNNN Tile Number 
	
	addq.w #1,d6			;$0001+ (TilePal)
	move.w d6,$3C0000 		
	move.w #$0100,$3C0002	;PPPPPPPP NNNNAAVH Palette Tile, 
								;Autoanim Flip
	addq.w #1,d6
	dbra d3,TileLoop		;Repeat for next sprite in column
	
;;;;;;;;;;;; end of column - Chained Sprite ;;;;;;;;;;;; 
	and.w #%1111111111000000,d6	;Next Tile Set
	add.w #%0000000001000000,d6
	add.w #$001,d7				;Next Sprite
	
	Move.w d7,$3C0000 		;Attribs addr $8000+ (Shrink)
	move.w d5,$3C0002		;----HHHH VVVVVVVV - Shrink
	
	add.w #$200,d7			;$8200+ (Ypos)
	Move.w d7,$3C0000 		
	move.w #$0040,$3C0002	;YYYYYYYY YCSSSSSS Ypos 
	
	add.w #$200,d7			;$8400+ (Xpos)
	move.w d7,$3C0000 	
	move.w #$0000,$3C0002	;XXXXXXXX X------- Xpos
	
	sub.w #$400,d7			;$8000+ (Shrink)
	
	dbra d4,SpriteLoop		;Next Column

;;;;;;;;;;;; Spriteloop done ;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
NoTileMap:

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
	
	
	
	
	move.l #xChibicloneDef,a1
	move.l #ChibicloneDef,a2
	move.l #64-1,d0
CopyAgain:
	move.b (a1)+,(a2)+
	dbra d0,CopyAgain
	
	
	
	
	move.l #TestSprite,a5
	move.l #TileCache,a2 	;TileCache
	jsr cls
	
	move.b #32,(HSpriteNum)

	move.l #ChibikoDef,a4
	jsr DrawSpriteAlways	;Draw Player Sprite
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;IL:
;	move.b	d0,$300001			;Kick watchdog
	;jmp IL
	
	


	
		
	
	
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
	;	jsr RemoveSprite
			
	moveM.l (sp)+,d1/d4
	
	
	
	move.b d1,(Spr_Xpos,a4)
	move.b d4,(Spr_Ypos,a4)
	
	
	
	moveM.l d1/d4,-(sp)
		;move.l #ChibikoDef,a4
	;	jsr ZeroSpriteInCache
		
	
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
		move.b #32,(HSpriteNum)	
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
	move.b d0,$300001	;REG_DIPSW - Kick the watchdog

	dbra d7,PauseD1
	rts
	
FinishSprites:
	move.b (HSpriteNum),d0
FinishSprites2:
	clr.l d1
	move.b d0,d1
	add.l #$8200,d1
	Move.w d1,$3C0000 
	Move.w #0,$3C0002		;Write new Tilenum to address
	
	addq.b #1,d0
	cmp.b #128,d0
	bne FinishSprites2
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
; SetTile:;		Tile XY(D1,D2)=D0
	; moveM.l d1-d2,-(sp)
		; rol.w #6,d1				;Xpos * 64
		; rol.w #1,d2				;Ypos * 2
		; add.w d2,d1				;Address of 'TileAddr' (tilenum)
		; Move.w d1,$3C0000 
		; Move.w d0,$3C0002		;Write new Tilenum to address
	; moveM.l (sp)+,d1-d2
	; rts

;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	
	
ReadJoystick:		;D0=1up D1=2up ---7654S321RLDU
	
		move.b $300000,d0	;Joy1 - DCBARLDU
	
	rts
	

GetScreenPos: ;Dummy function
	rts
		
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
DoStrip:	;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width
	moveM.l d1,-(sp)		;Back up XPos
NextTile:
		clr.l d0
		move.b (a2),d0		;Source Tilemap
		beq EmptyTile
		
		tst.b (TileClear)	;Clear Tile?
		beq NoClear
		clr.b (a2)			;Yes!
NoClear:
		add.l a5,d0
		move.l d0,-(sp)		
		addq.l #1,a2		;Next tile in Tilemap 
	
		move.l d1,d0
		and.l #%11111100,d0
		rol.w #4,d0			;Xpos * 64 (32 sprites per colunn)
		move.l d0,a6
		
		move.l d4,d0
		and.l #%11111100,d0
		ror.w #1,d0			;Ypos * 2 (2 bytes per sprite)
		add.w d0,a6			;Address of 'TileAddr' (tilenum)
		Move.w a6,$3C0000 	;$0000+ TileAddr
			
		move.l (sp)+,d0
		Move.w d0,$3C0002	;Write new Tilenum to address
		
TileDone:	
		add.l #4,d1			;Across one tile.
		subq.b #1,d7
		bne NextTile
TileDone2:
	moveM.l (sp)+,d1		;Restore Xpos
	add.l #4,d4				;Down one line
	rts
	
	
EmptyTile:
	addq.l #1,a2			;Next tile in Tilemap 
	jmp TileDone

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

DoStripSprite:			;bc/D1.D4=xy pos
	move.l d1,-(sp)
NextTileSpr:
		clr.l d0
		move.b (a2),d0			;Source Tilemap
		beq EmptyTileSpr
		
		tst.b (TileClear)		;Clear Tile?
		beq NoClearSpr
		clr.b (a2)				;Yes!
NoClearSpr:

		addq.l #1,a2			;Next tile in Tilemap 

		clr.l d2
		move.b (HSpriteNum),d2	;Get Sprite Num (32 = First)
		rol.l #6,d2				;Spritenum *64
		move.l d2,a6
		Move.w a6,$3C0000 		;$0000+ (TileAddr)
		add.l a5,d0				;Add Tile offset
		move.w d0,$3C0002		;NNNNNNNN NNNNNNNN Tile Number 
				
		add.l #1,a6				
		Move.w a6,$3C0000 		;$0001+ (TilePal)
		move.w #$0100,$3C0002	;PPPPPPPP NNNNAAVH Palette Tile
	
		clr.l d0
		move.b (HSpriteNum),d0
		add.l #$8000,d0			;$8000+ (Shrink)
		move.l d0,a6
		Move.w a6,$3C0000 	
		move.w #$077F,$3C0002	;----HHHH VVVVVVVV - Shrink
				
		add #$200,a6
		Move.w a6,$3C0000 		;$8200+ (Ypos)
		move.l #241,d0
		sub.b d4,d0
		rol.l #1,d0				;Logical Units->Pixels
		rol.l #7,d0				;Shift Ypos into correct position
		or.l #$0001,d0			;Just 1 sprite
		move.w d0,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
				
		add #$200,a6
		Move.w a6,$3C0000 		;$8400+ (Xpos)
		move.l d1,d0
		rol.l #1,d0				;Logical Units->Pixels
		add.l #32,d0
		rol.l #7,d0				;Shift Xpos into correct position
		move.w d0,$3C0002		;XXXXXXXX X------- Xpos

		addq.b #1,(HSpriteNum)	;Move to next Hsprite
			
TileDoneSpr:	
		add.l #4,d1				;Across 8 pixels
		subq.b #1,d7
		bne NextTileSpr			;Repeat for next tile
TileDone2Spr:
	move.l (sp)+,d1
	add.l #4,d4					;Down 8 lines
	rts
	
EmptyTileSpr:
	addq.l #1,a2				;Next tile in Tilemap 
	jmp TileDoneSpr
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;A2=Tilemap A5=TileBitmap A6=Vram dest D7=Width

DoStripSpriteRev:	;bc/D1.D4=xy pos
		move.l d1,-(sp)
NextTileSprRev:
		clr.l d0
		move.b (a2),d0			;Source Tilemap
		beq EmptyTileSprRev
		
		tst.b (TileClear)		;Clear Tile?
		beq NoClearSprRev
		clr.b (a2)				;Yes!
NoClearSprRev:

		subq.l #1,a2			;Last tile in tilemap
		
		clr.l d2
		move.b (HSpriteNum),d2	;Get Sprite Num (32 = First)
		rol.l #6,d2				;Spritenum *64
		move.l d2,a6
		Move.w a6,$3C0000 		;$0000+ (TileAddr)
		add.l a5,d0				;Add Tile offset
		move.w d0,$3C0002		;NNNNNNNN NNNNNNNN Tile Number 
				
		add.l #1,a6				
		Move.w a6,$3C0000 		;$0001+ (TilePal)
		;Set Xflip (H bit)
		move.w #$0101,$3C0002	;PPPPPPPP NNNNAAVH Palette Tile, Hflip
	
		clr.l d0
		move.b (HSpriteNum),d0
		add.l #$8000,d0			;$8000+ (Shrink)
		move.l d0,a6
		Move.w a6,$3C0000 	
		move.w #$077F,$3C0002	;----HHHH VVVVVVVV - Shrink
				
		add #$200,a6
		Move.w a6,$3C0000 		;$8200+ (Ypos)
		move.l #241,d0
		sub.b d4,d0
		rol.l #1,d0				;Logical Units->Pixels
		rol.l #7,d0				;Shift Ypos into correct position
		or.l #$0001,d0			;Just 1 sprite
		move.w d0,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
		
		add #$200,a6
		Move.w a6,$3C0000 		;$8400+ (Xpos)
		move.l d1,d0
		rol.l #1,d0				;Logical Units->Pixels
		add.l #32,d0
		rol.l #7,d0				;Shift Xpos into correct position
		move.w d0,$3C0002		;XXXXXXXX X------- Xpos

		addq.b #1,(HSpriteNum)	;Move to next Hsprite
		
TileDoneSprRev:	
		add.l #4,d1				;Across 8 pixels
		subq.b #1,d7
		bne NextTileSprRev		;Repeat for next tile
TileDone2SprRev:
	move.l (sp)+,d1
	add.l #4,d4					;Down 8 lines
	rts
	
EmptyTileSprRev:
	subq.l #1,a2				;Last tile in tilemap
	jmp TileDoneSprRev

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	

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
	dc.l TestChibikoRev
	ds.b 10
	
xChibikoDef:
	dc.l TestSpriteList	;Tilemap
	dc.l TestChibiko		;Pattern Data
	dc.b 20,32		;Width,Height
	dc.b $60,$60		;X,Y
	dc.b 1,1			;RefreshTile,Sprite
	dc.b 64,128		;X,Y
	dc.b 1,1			;Flags
	dc.l TestChibikoRev
	ds.b 10

	

Palette:
    dc.w $0000; ;0  -RGB
    dc.w $080F; ;1  -RGB
    dc.w $00FF; ;2  -RGB
    dc.w $0FFF; ;3  -RGB
    dc.w $0008; ;4  -RGB
    dc.w $0808; ;5  -RGB
    dc.w $0088; ;6  -RGB
    dc.w $0CCC; ;7  -RGB
    dc.w $0888; ;8  -RGB
    dc.w $0F00; ;9  -RGB
    dc.w $00F0; ;10  -RGB
    dc.w $0FF0; ;11  -RGB
    dc.w $000F; ;12  -RGB
    dc.w $0F0F; ;13  -RGB
    dc.w $00FF; ;14  -RGB
    dc.w $0FFF; ;15  -RGB
