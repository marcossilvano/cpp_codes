
VscreenMinX equ 48		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80

VscreenWid equ 160+4		;Visible Screen Size in logical units
VscreenHei equ 112+6

VscreenWidClip equ 0
VscreenHeiClip equ 0



PlayerX  equ $100010	;Ram for Cursor Xpos
PlayerY  equ $100010+2	;Ram for Cursor Ypos
spritehclip  equ $100010+4	;Ram for Cursor Ypos

flag_VBlank	equ  $100000   	;(byte) vblank flag in ram

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
	move.w	#2,$3C000C			;LSPC_IRQ_ACK - ack. interrupt #2 (HBlank)
	move.b	d0,$300001			;REG_DIPSW - kick watchdog
	rte
IRQ3:
	move.w  #1,$3C000C			;LSPC_IRQ_ACK - acknowledge interrupt 3
	move.b	d0,$300001			;REG_DIPSW - kick watchdog
	rte
	 	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 							UserReq_Game

userReq_Game:
	move.b	d0,$300001		;REG_DIPSW -Kick watchdog
	
	;        -RGB			;Color Num:
	move.w #$0000,$401FFE	;0 - Background color
	move.w #$0808,$400022	;1
	move.w #$00FF,$400024	;2
	move.w #$0FFF,$400026	;3
	move.w #$0FFF,$40003E	;15 - Font
		
	
	jsr $C004C2 			;FIX_CLEAR - clear fix layer
	jsr $C004C8				;LSP_1st   - clear first sprite
	
	
	move.w #VscreenMinX,(PlayerX)	;x
	move.w #VscreenMinY,(PlayerY)	;y
	
	move.b #%00000000,d3
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:
	moveM.l d0-d2/a0-a5,-(sp)
		jsr Player_ReadControlsDual
		move.b d0,d3
	moveM.l (sp)+,d0-d2/a0-a5
	
	and #%00001111,d3		;Check directions
	cmp #%00001111,d3
	beq InfLoop				;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1		;Back up X
	move.w (PlayerY),d4		;Back up Y
	
	;moveM.l d0-d7/a0-a5,-(sp)
		;jsr BlankPlayer		;Remove old sprite
	;moveM.l (sp)+,d0-d7/a0-a5
		
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	

	move.w d1,(PlayerX)
	move.w d4,(PlayerY)
	
	
PlayerPosYOk:	
	jsr DrawPlayer			;Show new player position
	jsr ClearUnusedSprites
	
	move.l #$7FFF,d1	;Delay
	jsr PauseD1
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	
	
	;move.l #3,d0	;SX
	;move.l #3,d1	;SY
	;move.l #6,d2	;WID
	;move.l #6,d3	;HEI
	;move.l #256,d4	;TileStart

DrawPlayer:	
	move.l #$2600,d7		;Pattern

	move.l #24,d3	;WID
	move.l #24,d6	;HEI
	
	jsr docrop
	bcs DrawSpriteAbort
	
	move.l #0,d5			;Sprnum
	
	lsl.l #1,d1				;Xpos to Pixels
	lsl.l #1,d4				;Ypos to Pixels
		
	lsr.l #3,d3				;16 H-pixels per sprite
	beq DrawSpriteAbort
	lsr.l #3,d6				;16 V-pixels per sprite
	beq DrawSpriteAbort
		
		
	moveM.l d0-d4,-(sp)
		subq.l #1,d3			;Height -1
		subq.l #1,d6			;Width  -1
NextTileLine:
		moveM.l d1/d3,-(sp)
NextTileb:		
			jsr SetSprite	;D5=Sprnum	D1=Xpos D4=Ypos D7=Pattern
			
			add.l #16,d1		;Move across one 16 pixel sprite
			addq.w #1,d7		;Increase Tile number
			addq.w #1,d5		;Hsprite number
			
			dbra d3,NextTileb
			add.w #16,d1		;Increase X

			clr.l d0
			move.b (spritehclip),d0
			add.w d0,d7
			
		movem.l (sp)+,d1/d3		;Restore Width
		add.l #16,d4			;Increase Y
		dbra d6,NextTileLine
	moveM.l (sp)+,d0-d4
	rts
	
DrawSpriteAbort:
	move.l #0,d5		;Sprnum
	rts

ClearUnusedSprites:
	cmp.w #9,d5					;hide sprites <9
	bcc ClearUnusedSpritesDone
	
	move.l #255,d1				;Set un-needed sprites as offscreen
	move.l #255,d4
	jsr SetSprite
	addq.w #1,d5				;Next sprite
	jmp ClearUnusedSprites
ClearUnusedSpritesDone:	
	rts
	
	
SetSprite:	;D5=Sprnum	D1=Xpos D4=Ypos D7=Pattern
	moveM.l d0-d7,-(sp)	
		
		move.l d5,d0
		add.l #$8000,d5			;Sprite Settings start at $8000+Sprnum
		
		move.w d5,$3C0000 		
		move.w #$0FFF,$3C0002	;----HHHH VVVVVVVV - Shrink
		
		add.l #$200,d5			;Ypos at $8200+Sprnum
		move.w d5,$3C0000 		
		
		neg d4
		add.l #288+208+12,d4
		
		rol.l #7,d4				;Shift Ypos into correct position
		or.l #$0001,d4			;Just 1 sprite
		
		move.w d4,$3C0002		;YYYYYYYY YCSSSSSS Ypos
										;Chain Sprite Size (1 sprite)
		
		add.l #$200,d5			;Xpos at $8400+Sprnum
		move.w d5,$3C0000 		
		
		sub.w #4,d1
		
		lsl.l #7,d1
		move.w d1,$3C0002		;XXXXXXXX X------- Xpos	
		
		move.l d0,d5
		rol.l #6,d5				;SpriteNum*64
		move.w d5,$3C0000 		;TileNum.1 at $0000+Sprnum*64
		
		move.w d7,$3C0002		;NNNNNNNN NNNNNNNN Tile
								;(tiles start at $2000 - set by MAME XML)									
		addq.l #1,d5
		move.w d5,$3C0000 		;TilePal.1 at $0001+Sprnum*64
				
		move.w #$0100,$3C0002	;PPPPPPPP NNNNAAVH Palette Tile, 
								;Autoanimate Flip
	moveM.l (sp)+,d0-d7
	rts
		
	
	
Player_ReadControlsDual:
;AES/MVS, WritePro,Card2, Card1, P2-Sel,P2-Strt,P1-Sel,P1-Strt
	move.b $380000,d2
	
	move.b $300000,d0	;Joy1 - DCBARLDU
	
	move.b $340000,d1	;Joy2 - DCBARLDU
	
	rts
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		

	;;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6
docrop:
	clr.l d2					;D5=top D2=bottom crop
	clr.l d5
	clr.b (spritehclip)			;H-clip
	
;crop top side
	clr.l d0
	move.b d4,d0				;X-pos
	sub.b #vscreenminy,d0		;>minimum co-odinate
	bcc notcrop					;nc=nothing needs cropping
	neg.b d0
	add #7,d0
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d5				;top crop
	and.b #%00000111,d0
	eor.b #%00000111,d0
	;add.b #1,d0					;0-15 pixels offscreen
notcrop:
	move.b d0,d4				;Draw Ypos

;crop bottom hand side
	add.b d6,d0					;Add Height
	sub.b #vscreenhei-vscreenheiclip,d0	;logical height of screen
	bcs nobcrop					;c=nothing needs cropping
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d2				;amount to remove from bottom 
nobcrop:

;Calculate new height
	clr.l d0
	move.b d5,d0				;units to remove from top
	add.b d2,d0					;units to remove from bottom
	and.l #%11111000,d0
	beq novclip					;nothing to remove?
	sub.b d0,d6					;subtract from old height
	
	
;Calculate lines to skip from the top
	and.l #$FF,d5				;lines to remove from top
	beq NoVClip
	
	;add.b #8,d5
	lsr.b #3,d5					;Amount to remove from top
	beq NoVClip
	
	mulu d3,d5					;Calculate amount to remove 
								;(Lines*BytesPerLine)

	lsr.l #3,d5					;Convert to no of tiles
	add.l d5,d7
	
	
NoVClip:
	clr.l d2
	clr.l d5

;crop left hand side
	move.b d1,d0
	sub.b #vscreenminx,d0		;remove left virtual border
	bcc nolcrop					;nc=nothing needs cropping
	neg.b d0					;Amount to remove
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen	
	move.b d0,d5
	add.b #7,d0
	and.b #%00000111,d0			;0-15 pixels offscreen
	eor.b #%00000111,d0
nolcrop:
	move.b d0,d1				;Draw Xpos
	
	
;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreeneen?
	move.b d0,d2
	

norcrop:
	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	;and.l #%11111000,d0
	beq nohclip					;nothing to crop?
	
	move.b d0,d2			;amount to subtract from width (right)
	
	add.b #7,d0
	lsr.b #3,d0
	move.b d0,(spritehclip)		;Tiles to skip after each line

	sub.b d2,d3					;Update Width

;amount to subtract from left
	add.b #7,d5
	lsr.l #3,d5					;No of tiles
	add.l d5,d7					;move across 
	
	
nohclip:
	
	andi #%11111110,ccr		;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr		;set carry (nothing to draw)
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Palette:
    dc.w $0000; ;0  -RGB
    dc.w $01F0; ;1  -RGB
    dc.w $0555; ;2  -RGB
    dc.w $0AAA; ;3  -RGB
    dc.w $0FFF; ;4  -RGB
    dc.w $0286; ;5  -RGB
    dc.w $03D3; ;6  -RGB
    dc.w $0E33; ;7  -RGB
    dc.w $0E76; ;8  -RGB
    dc.w $0EA5; ;9  -RGB
    dc.w $0FF4; ;10  -RGB
    dc.w $0A2A; ;11  -RGB
    dc.w $0F0F; ;12  -RGB
    dc.w $003D; ;13  -RGB
    dc.w $036B; ;14  -RGB
    dc.w $00DF; ;15  -RGB
