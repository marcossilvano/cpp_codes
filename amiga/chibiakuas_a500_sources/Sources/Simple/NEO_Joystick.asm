

;Ram Variables
PlayerX  equ $100010	;Ram for Cursor Xpos
PlayerY  equ $100010+2	;Ram for Cursor Ypos
PlayerX2 equ $100010+4	;Ram for Cursor Xpos
PlayerY2 equ $100010+6	;Ram for Cursor Ypos

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
	move.w #$0007,$401FFE	;0 - Background color
	move.w #$0FF0,$400022	;1
	move.w #$00FF,$400024	;2
	move.w #$0F00,$400026	;3
	move.w #$0FF0,$40003E	;15 - Font
	
	jsr $C004C2 			;FIX_CLEAR - clear fix layer
	jsr $C004C8				;LSP_1st   - clear first sprite

	move.l #3,d0		;Start-X
	move.l #3,d1		;Start-Y
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	move.w #3,(PlayerX)		;x
	move.w #3,(PlayerY)		;y
	
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
	move.w (PlayerX),d0		;Back up X
	move.w d0,(PlayerX2)

	move.w (PlayerY),d1		;Back up Y
	move.w d1,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr BlankPlayer		;Remove old sprite
	moveM.l (sp)+,d0-d7/a0-a5
		
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d1		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d1		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d0		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d0		;Move X Right
JoyNotRight: 	
	
	move.w d1,(PlayerY)
	move.w d0,(PlayerX)
	
;X Boundary Check - if we go <0 we will end up back at &FF
	
	cmp.w #40,d0
	bcs PlayerPosXOk		
	jmp PlayerReset		;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check - only need to check 1 byte
	cmp #28,d1
	bcs PlayerPosYOk	;Not Out of bounds
	
PlayerReset:
	Move.w (PlayerX2),d0	;Reset Xpos	
	Move.w d0,(PlayerX)
	
	Move.w (PlayerY2),d1	;Reset Ypos	
	Move.w d1,(PlayerY)
	
PlayerPosYOk:	
	jsr DrawPlayer			;Show new player position
	
	move.l #$FFFFFFFF,d1	;Delay
	jsr PauseD1
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	

BlankPlayer:	
	move.l #513,d4		;TileStart Number
	jmp DrawSprite
DrawPlayer:		
	move.l #512,d4		;TileStart Number
DrawSprite:	
	clr.l d6
	clr.l d7
		;	PTTT  - Palette / Tile	
	add.w #$1800,d4		;We're starting at tile $1800
						;   so load FIX into offset="0x012000"
						
	move.L  #$7000,d5	;Fixmap starts at $7000
	clr.L 	d7
	move.B 	d0,D7		;Xpos 
	rol.L 	#5,D7		;*32 - memory is ordered Cols/Rows 
	add.L 	D7,D5		;      32 cols per X line
	
	clr.L 	d7
	move.b 	d1,D7		;Ypos
	addq.l 	#2,d7		;NEO doesn't recommend using top 2 columns
	add.L 	D7,D5

	move.w d5,$3C0000 	;address
	move.w d4,$3C0002	;tile data

	move.b	d0,$300001	;REG_DIPSW - Kick the watchdog
	rts
	

	
Player_ReadControlsDual:
;AES/MVS, WritePro,Card2, Card1, P2-Sel,P2-Strt,P1-Sel,P1-Strt
	move.b $380000,d2
	
	move.b $300000,d0	;Joy1 - DCBARLDU
	
	move.b $340000,d1	;Joy2 - DCBARLDU
	
	rts
	
	
	