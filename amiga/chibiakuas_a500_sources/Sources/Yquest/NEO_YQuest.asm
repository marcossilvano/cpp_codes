	include "\SrcALL\BasicMacros.asm"

CollisionMaskY equ %11111000	;Masks for un-drawable co-ordinates 
CollisionMaskX equ %11111100

ScreenWidth40 equ 1
ScreenWidth equ 40
ScreenHeight equ 28
ScreenObjWidth equ 160-2
ScreenObjHeight equ 232-8

UserRam equ  $100100		;Game Ram Area

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
	
;CD VER
	ifd BuildNEO_CD
		dc.l	$00C00522		; Reserved
		dc.l	$00C00528		; Reserved
		dc.l	$00C0052E		; Reserved
		dc.l	$00C00534		; Reserved
		dc.l	$00C0053A		; Reserved
		dc.l	$00C004F2		; Reserved
		dc.l	$00C004EC		; Reserved
		dc.l	$00C004E6		; Reserved
		dc.l	$00C004E0		; Spurious Interrupt
	else
;Cart Ver
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00426		; Reserved
		dc.l	$00C00432		; Spurious Interrupt
	endif
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 									Interrupts

;CD VER
	ifd BuildNEO_CD
		dc.l	IRQ2			; Level 1 interrupt (HBlank)
		dc.l	VBlank			; Level 2 interrupt (VBlank)
	else
;Cart Ver
		dc.l	VBlank			; Level 1 interrupt (VBlank)
		dc.l	IRQ2			; Level 2 interrupt (HBlank)
	endif
	
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
	
	
	;        -RGB			
	move.w #$0000,$401FFE	;0 - Common Background color
	
	lea Palette,a3
	move.l #$400020,a2
	move.l #16-1,d0
PaletteAgain:	
	move.w (a3)+,(a2)+	
	dbra d0,PaletteAgain
	
	jsr $C004C2 			;FIX_CLEAR - clear fix layer
	jsr $C004C8				;LSP_1st   - clear first sprite

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	lea userram,a3
	move.l #$800,d1
	jsr cldir0				;Clear Game Ram
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
showtitle:
;init game defaults
	move.b #3,(lives)
									
	clr.l (Score)
	clr.b (level)

	clr.b (playerobject)	;player sprite
	clr.l d0
	
	jsr chibisound			;mute sound
	
	jsr cls					;scr clear

;show title screen	
	move.l #titlepic,a3
	move.l #0,d4
titlepixnexty:
	move.l #0,d1
titlepixnextx:
	moveM.l d1/d4/a3,-(sp)
		move.b (a3),d0
		beq titlenosprite
	
		jsr GetSpriteAddr
		add.l #1,d4		;Move down a line
		jsr showsprite
titlenosprite:
	moveM.l (sp)+,d1/d4/a3
	addq.l #1,a3
	addq.l #1,d1
	cmp.l #screenwidth,d1
	bne titlepixnextx
	
	addq.l #1,d4	
	cmp.l #24,d4
	bne titlepixnexty
	
;Text Messages
	move.l #$1202+1,d3
	jsr locate
	lea txtfire,a3			;show press fire
	jsr printstring

	move.l #$0018+1,d3
	jsr locate
	lea txturl,a3			;show url
	jsr printstring

	move.l #$1818+1,d3
	jsr locate
	lea txthiscore,a3
	jsr printstring 		;show the highscore
	lea HiScore,a0		
    move.l #3,d1
    jsr BCD_Show
	
	
startlevel:
	jsr waitforfire
	jsr cls
	jsr resetplayer			;Center Player
	jsr levelinit			;Set up enemies
	
infloop:
	move.b	d0,$300001	;REG_DIPSW - Kick the watchdog

	move.l #7000,d1			;Loop Delay
	move.l #%11111111,d2	;KeyPress
pausebc:
	jsr Player_ReadControlsDual
	
	cmp.b #%11111111,d0		;Key Pressed?
	beq pausenokey
	move.b d0,d2			;Save keypresses
pausenokey:
	dbra d1,pausebc
	
	
startdraw:
	move.l d2,-(sp)
		jsr drawui			;Show User Interface

		lea playerobject,a4
		jsr blanksprite		;Remove old player sprite
	move.l (sp)+,d2
	
	cmp.b #0,(keytimeout)	;ignore UDLR during key timeout
	beq processkeys
	subq.b #1,(keytimeout)
	jmp joyskip				;skip player input

processkeys:


	move.l #playeraccy,a3
	move.l #0,d5			;Key Timeout

	btst #0,d2				;4321RLDU
	bne joynotup
	move.b (a3),d0
	sub.b #1,d0				;Left
	move.b d0,(a3)
	move.l #5,d5
joynotup:
	btst #1,d2				;4321RLDU
	bne joynotdown
	move.b (a3),d0
	add.b #1,d0				;Right
	move.b d0,(a3)
	move.l #5,d5
joynotdown:
	move.l #playeraccx,a3
	btst #2,d2				;4321RLDU
	bne joynotleft
	move.b (a3),d0
	sub.b #1,d0				;Up
	move.b d0,(a3)
	move.l #5,d5
joynotleft:
	btst #3,d2				;4321RLDU
	bne joynotright
	move.b (a3),d0
	add.b #1,d0				;Down
	move.b d0,(a3)
	move.l #5,d5
joynotright:	
	btst #4,d2				;4321RLDU
	bne joynotfire
	jsr playerfirebullet	;Fire a bullet
joynotfire:
	btst #5,d2
	bne joynotfire2
	clr.b (playeraccx)		;Stop movement
	clr.b (playeraccy)
joynotfire2:
	move.b d5,(keytimeout)	;Update KeyTimeout
	
joyskip:
	jsr drawandmove			;Draw objects
	
	jmp infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Cls:
	move.w #$0001,$3C0004	;Set AutoInc amount (1 word)
	
	move.w #$7000,$3C0000 	;Fixmap starts at $7000
	move.l #40*32,d0
Cls_Again:	
	clr.w $3C0002			;Clear Tile
	dbra d0,Cls_Again
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0
		sub.l #32,d0		;Font has no Chars <32 
		clr.l d1
		clr.l d4
		move.b (CursorX),d1
		move.b (CursorY),d4
		
		jsr showsprite
		
		addq.b #1,(CursorX)
	moveM.l (sp)+,d0-d7/a3
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BlankSprite:	
	move.b (O_CollProg,A4),d0
	
	cmp.b #250,d0	;Objects with Coll>250 are dead or unused
	bcs BlankSpriteNoReturn
	rts
BlankSpriteNoReturn:
	moveM.l d0-d7,-(sp)
		move.l #0,d0	;Sprite Source (Space)
	jmp DrawBoth


GetSpriteAddr:
	and.l #$FF,d0
	;Skip over font tiles + other sample times
	
		add.l #768,d0		;768 * 32 (bytes per tile) = $6000
	
;Load Yquest Font at:
;<rom offset="0x010000" size="%size%" name="FontYQUEST.FIX" crc="%crc%" sha1="%sha%" />
;Load Yquest Tiles at:
;<rom offset="0x016000" size="%size%" name="Yquest.FIX" crc="%crc%" sha1="%sha%" />
	clr.l d7
	move.b (SpriteFrame),d7
	asl.l #4,d7
	add.l d7,d0			;16 tiles per bank
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
ShowSprite:
	moveM.l d0-d7,-(sp)
		jmp ShowSpriteB
	
DoGetSpriteObj:				;Get Settings from Object A4
	
	moveM.l d0-d7,-(sp)
		Move.b (O_SprNum,A4),d0	;Sprite Source
		
		jsr GetSpriteAddr
	
DrawBoth:
		move.b (O_Xpos,A4),d1
		move.b (O_Ypos,A4),d4
		lsr.b #2,d1
		lsr.b #3,d4
ShowSpriteB:	
	
	clr.l d6
	clr.l d7
	
		;	PTTT  - Palette / Tile	
	add.w #$1800,d0		;We're starting at tile $1800
						;   so load FIX into offset="0x010000"
						
	move.L  #$7000,d5	;Fixmap starts at $7000
	clr.L 	d7
	move.B 	d1,D7		;Xpos 
	rol.L 	#5,D7		;*32 - memory is ordered Cols/Rows 
	add.L 	D7,D5		;      32 Tiles per Y line
	
	clr.L 	d7
	move.b 	d4,D7		;Ypos
	addq.l 	#2,d7		;NEO doesn't recommend using top 2 columns
	add.L 	D7,D5

	move.w d5,$3C0000 	;address
	move.w d0,$3C0002	;tile data
		
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
Player_ReadControlsDual:	;---7654S321RLDU
;AES/MVS, WritePro,Card2, Card1, P2-Sel,P2-Strt,P1-Sel,P1-Strt
	;move.b $380000,d2
	
	move.b $300000,d0	;Joy1 - DCBARLDU
	
	;move.b $340000,d1	;Joy2 - DCBARLDU
	
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	
	
	
	

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



	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	include "YQ_Multiplatform.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\SrcALL\Multiplatform_BCD.asm"
	include "\SrcALL\BasicFunctions.asm"	
	include "\SrcALL\MultiPlatform_ShowDecimal.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "YQ_DataDefs.asm"
	even
	
	include "YQ_RamDefs.asm"
	even
	