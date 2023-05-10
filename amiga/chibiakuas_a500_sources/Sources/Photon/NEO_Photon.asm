	include "\SrcALL\BasicMacros.asm"

Color1 equ 1				;Color palette
Color2 equ 2				;These are color attributes
Color3 equ 3				
Color4 equ 4				

ScreenWidth20 equ 1
ScreenWidth equ 192		 	;Screen is 96 tiles wide, 31 tiles tall
ScreenHeight equ 124		;each tile is 2x4 pixels
;ScreenHeight equ 111		;For Square Pixels
							;Only 2 colors per tile :-(
UserRam equ  $100200		;Game Ram Area


	include "\SrcALL\BasicMacros.asm"
	
	
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
	move.w	#2,$3C000C		;LSPC_IRQ_ACK - ack. interrupt #2 (HBlank)
	move.b	d0,$300001		;REG_DIPSW - kick watchdog
	rte
IRQ3:
	move.w  #1,$3C000C		;LSPC_IRQ_ACK - acknowledge interrupt 3
	move.b	d0,$300001		;REG_DIPSW - kick watchdog
	rte
	 	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 							UserReq_Game

userReq_Game:
	move.b	d0,$300001		;REG_DIPSW -Kick watchdog
	
	;        -RGB			;Color Num:
	move.w #$0000,$401FFE	;0 - Background color
	
;Palette	
	lea Palette,a3
	move.l #$400020,a2
	move.l #16-1,d0
PaletteAgain:	
	move.w (a3)+,(a2)+		;		;GGGGGRRRRRBBBBB- 5 bit per channel
	dbra d0,PaletteAgain
	
	
	
	jsr $C004C2 			;FIX_CLEAR - clear fix layer
	jsr $C004C8				;LSP_1st   - clear first sprite

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	
	lea userram,a3
	move.l #$800,d1
	jsr cldir0				;Clear Game Ram

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;;;;;;;;;;;; Define TileMap using a grid of sprites ;;;;;;;;;;;; 
	
	move.w #$8000,d7		;Attribs addr
	move.w #$0000,d6		;Tile Addr
	
	move.w #$026F,d5 		;Scale (each sprite is 2x4 pixels)
	;move.w #$0280,d5 		;Scale (Square pixels)
	
	move.l #96,d4			;Sprites (Width)
	move.l #30,d2			;Tiles per sprite (height)
	
	
;;;;;;;;;;;; Anchor Sprite ;;;;;;;;;;;; 
;First sprite is anchor to others!
	
	Move.w d7,$3C0000 
	move.w d5,$3C0002		;----HHHH VVVVVVVV - Shrink
	
	add.w #$200,d7
	
	Move.w d7,$3C0000 
	move.w #$F821,d0		;33=32 tall (looping)
	
	move.w d0,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
	
	add.w #$200,d7
	
	move.w d7,$3C0000 	
	move.w #$0800,$3C0002	;XXXXXXXX X------- Xpos
	
	sub.w #$400,d7
	
;;;;;;;;;;;; Tiles ;;;;;;;;;;;; 	
SpriteLoop:	
	move.l d2,d3			;Init Counter for Tilecount (30)
TileLoop:
	move.w d6,$3C0000 	
	move.w #$2010,$3C0002	;Tile Number (defaults to $2010)
	
	addq.w #1,d6
	
	move.w d6,$3C0000 	
	move.w #$0100,$3C0002	;PPPPPPPP NNNNAAVH Palette Tile, 
								;Autoanim Flip
	addq.w #1,d6
	
	dbra d3,TileLoop		;Repeat for next (30 total)
	
;;;;;;;;;;;; Chained Sprites ;;;;;;;;;;;;  
	and.w #%1111111111000000,d6	;Next Tile Set
	add.w #%0000000001000000,d6
	add.w #$001,d7				;Next Sprite
	
	Move.w d7,$3C0000 
	move.w d5,$3C0002		;----HHHH VVVVVVVV - Shrink
	
	add.w #$200,d7
	
	Move.w d7,$3C0000 
	move.w #$0040,$3C0002	;YYYYYYYY YCSSSSSS Ypos 
	
	add.w #$200,d7
	
	move.w d7,$3C0000 	
	move.w #$0000,$3C0002	;XXXXXXXX X------- Xpos
	
	sub.w #$400,d7
	
	dbra d4,SpriteLoop		;Next Sprite (96 total)

;;;;;;;;;;;; Spriteloop done ;;;;;;;;;;;; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Set tilenumbers
	
	
	jsr cls
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


infloop:					;main loop	

	move.b	d0,$300001		;REG_DIPSW -Kick watchdog

	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0
	move.b d0,(tick)

	move.l #600,d1			;slow down delay

	move.b (boost),d0
	bne boostoff			;boost - no delay 

	move.l #300,d1			;(compensate for font draw)

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
		bra keysdown

pausenokey:		;released - nuke key, and relese keypress
		clr.b (keytimeout)	
		move.b #%11111111,d2
keysdown:
	popbc
	subq.l #1,d1
	bne pausebc
	
startdraw:	
	tst.b (keytimeout)			;See if Keytimeout not cleared
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
	tst.b (boostpower)		;check if boost power remains
	beq joynotfire

	clr.b (boost)		;turn on boost
joynotfire:
joyskip:
	
	jsr handleplayer		;draw and update player
	jsr handlecpu			;draw and update cpu
	jmp infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
pset:
	moveM.l d1-d7/a0-a7,-(sp)
		move.l d1,d3
		lsr.l #1,d3	  ;Remove bottom bit of Xpos (2 pixels per tile)
		move.l d4,d5
		lsr.l #2,d5	;Remove 2 bottom bits of Ypos (4 pixels per tile)

;Select Tile
		add.l #$2400,d0			;Add First tilenum in ROM
		rol.w #6,d3				;Xpos * 64
		rol.w #1,d5				;Ypos * 2
		add.w d5,d3				;Address of 'TileAddr' (tilenum)
		Move.w d3,$3C0000 
		Move.w $3C0002,d0		;Read Tilenum
		
;Calculate Y Pos of sprite
		and.l #3,d4				;Y position
		
		move.l #PixelMap,a4
		add.l d4,a4
		clr.l d5
		move.b (a4),d5			;Get Y position lookup

;Calculate X Pos of sprite
		btst #0,d1				;Xposition
		bne PsetOddX
		lsl.w #4,d5				;16 different tiles per x line
PsetOddX:

;Apply Color
		and.l #$F,d2			;Color number
		beq ZeroPixel
		
		and.l #$FCFF,d0			;Remove current color 
		
		subq.l #1,d2			;Bank 0 = Color 1
		asl.l #8,d2				;256 tiles per color
		or.l d2,d0				;Or in color
		
;Update Tile
		or.w d5,d0				;Set Tile to new pixel sprite
		Move.w d0,$3C0002
	moveM.l (sp)+,d1-d7/a0-a7
	rts
ZeroPixel:
		eor.w #$FFFF,d5			;Mask to remove pixel
		and.W d5,d0				;Remove pixel
		Move.w d0,$3C0002		;Save tile back
	moveM.l (sp)+,d1-d7/a0-a7
	rts

PixelMap:	;Y position lookups
		dc.b %00001000,%00000100,%00000010,%00000001
	
	
	
Point:
	moveM.l d1-d7/a0-a7,-(sp)
		move.l d1,d3
		lsr.l #1,d3			;Remove bottom bit of Xpos
		move.l d4,d5
		lsr.l #2,d5
		
		add.l #$2400,d0		;Add First tilenum in ROM
		rol.w #6,d3			;Xpos * 64
		rol.w #1,d5			;Ypos * 2
		add.w d5,d3			;Address of 'TileAddr' (tilenum)
		Move.w d3,$3C0000 
		Move.w $3C0002,d0	;Write new Tilenum to address
		
		and.l #$3,d4
		move.l #PixelMap,a4
		add.l d4,a4
		clr.l d5
		move.b (a4),d5
		
		btst #0,d1
		bne GetPixelOdd
		lsl.w #4,d5
GetPixelOdd
		and.b d5,d0			;Mask the pixel we're looking at
		and.l #$FF,d0
	moveM.l (sp)+,d1-d7/a0-a7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
Cls:
	move.l #30,d2			;Ypos
TileNextY:	
	move.l #96,d1			;Xpos
TileNextX:	
	clr.l d0				;Tile 0
	
	jsr SetTile				;Change the tile in the sprites
	
	dbra d1,TileNextX
	dbra d2,TileNextY
	rts
	
SetTile:;		Tile XY(D1,D2)=D0
	moveM.l d1-d2,-(sp)
		add.l #$2400,d0			;Add First tilenum in ROM
		rol.w #6,d1				;Xpos * 64
		rol.w #1,d2				;Ypos * 2
		add.w d2,d1				;Address of 'TileAddr' (tilenum)
		Move.w d1,$3C0000 
		Move.w d0,$3C0002		;Write new Tilenum to address
	moveM.l (sp)+,d1-d2
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
Player_ReadControlsDual:	;---7654S321RLDU
	moveM.l d1-d7,-(sp)
		ifd NeoJoy_UseBios
			;P4-Sel,P4-Strt,P3-Sel,P3-Strt,P2-Sel,P2-Strt,P1-Sel,P1-Strt
			move.b $10FDAC,d3	
								;Select Doesn't work on MVS
			move.b $10FD94+2,d4	;Joy1 - DCBARLDU
		else
			;AES/MVS, WritePro,CardIns 2, CardIns 1, P2-Sel,P2-Strt,P1-Sel,P1-Strt
			move.b $380000,d3	
			move.b $300000,d4	;Joy1 - DCBARLDU
		endif
			
		jsr Player_ReadControlsOne
		
		move.l d4,d0
			
		ifd NeoJoy_UseBios
			move.b $10FD9A+2,d4	;Joy2 - DCBARLDU
		else
			move.b $340000,d4	;Joy2 - DCBARLDU
		endif
		jsr Player_ReadControlsOne
		move.l d4,d1	
	moveM.l (sp)+,d1-d7
	rts
		
Player_ReadControlsOne:
	and.l #$000000FF,d4
	clr.l d2
	roxl.b #1,d4	;Shift off button D
	roxl.b #1,d2
	
	roxr.b #1,d3	;Get Start
	roxr.b #1,d4
	roxr.b #1,d3	;Skip select
	
	rol.l #8,d2
	or.l d2,d4		;Or in Button D to bit 8
	ifd NeoJoy_UseBios
		eor.l #$FFFFFFFF,d4	;Flip all bits if reading bios
	else
		eor.l #$FFFFFE00,d4	;Flip unused bits if reading direct
	endif
	
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
waitforfire:
	jsr dorandom			;reseed random numbers
	move.b	d0,$300001	;REG_DIPSW - Kick the watchdog
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	bne waitforfire

waitforfireb:
	jsr dorandom			;reseed random numbers
	move.b	d0,$300001	;REG_DIPSW - Kick the watchdog
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	beq waitforfireb
	rts

	

Palette:
    dc.w $0000; ;0  -RGB
    dc.w $00FF; ;1  -RGB
    dc.w $0F0F; ;2  -RGB
    dc.w $00F0; ;3  -RGB
    dc.w $0FF0; ;4  -RGB
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
	
	
	;include "\SrcALL\V1_Footer.asm"