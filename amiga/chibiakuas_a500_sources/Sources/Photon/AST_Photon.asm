	include "\SrcALL\BasicMacros.asm"

Color1 equ 1				;Color palette
Color2 equ 2				;These are color attributes
Color3 equ 3				
Color4 equ 4

ScreenWidth40 equ 1			;Screen Size Settings
ScreenWidth equ 320
ScreenHeight equ 200

	

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
			;-RGB
	move.w #$0000,$ff8240 	;Color 0 - Black
	move.w #$0077,$ff8242 	;Color 1 - Purple
	move.w #$0707,$ff8244 	;Color 2 - Cyan
	move.w #$0070,$ff8246 	;Color 3 - White
	move.w #$0770,$ff8248 	;Color 3 - Yellow
	
	jsr KeyboardScanner_AllowJoysticks		;Turn on joystick
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	lea userram,a3		
	move.l #$100,d1
	jsr cldir0				;Clear Game Ram
	
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;main loop	
infloop:	
	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0		;Update Game Tick
	move.b d0,(tick)

	move.l #300,d1			;slow down delay

	move.b (boost),d0
	bne boostoff			;boost - no delay 
	move.l #200,d1			;(compensate for font draw)

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
	tst.b (keytimeout)			;Check if keytimeout is set?
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
	tst.b (boostpower)			;check if boost power remains
	beq joynotfire
	clr.b (boost)				;turn on boost
joynotfire:
joyskip:
	jsr handleplayer			;draw and update player
	jsr handlecpu				;draw and update cpu
	jmp infloop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
Pset: 		;D1=X D4=Y	D2=Color
	moveM.l d0-d4/a3-a4,-(sp)
		and.l #$01FF,d1			;Mask X,Y pos
		and.l #$00FF,d4
		
		jsr GetScreenPos		;Calculate Vram address in A3 for 
									;pos (D1,D4)
		and.l #$07,d1
		move.l #PixelLookup,a4	;Get Pixel mask from lookup
		add.l d1,a4
		
		move.b (a4),d1			;Save Background mask
		eor.b #$ff,d1
		move.b (a4),d3			;Save Pixel Mask
		
								;Process bitplane 0
		move.b (a3),d0			;Get Bitplane 0
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 0
		bcc NoBit0
		or.b d3,d0				;Set Color bit 0
NoBit0:
		move.b d0,(a3)			;Update Bitplane 0
		
		addq.l #2,a3			;Move To bitplane 1
		move.b (a3),d0			;Get Bitplane 1
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 1
		bcc NoBit1
		or.b d3,d0				;Set Color bit 1
NoBit1:
		move.b d0,(a3)			;Update Bitplane 1
		
		addq.l #2,a3			;Move To bitplane 2
		move.b (a3),d0			;Get Bitplane 2
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 2
		bcc NoBit2
		or.b d3,d0				;Set Color bit 2
NoBit2:
		move.b d0,(a3)			;Update Bitplane 2
		
		addq.l #2,a3			;Move To bitplane 3
		move.b (a3),d0			;Get Bitplane 3
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 3
		bcc NoBit3
		or.b d3,d0				;Set Color bit 3
NoBit3:
		move.b d0,(a3)			;Update Bitplane 3	
	moveM.l (sp)+,d0-d4/a3-a4
	rts
	
PixelLookup:
	dc.b %10000000,%01000000,%00100000,%00010000
	dc.b %00001000,%00000100,%00000010,%00000001

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetScreenPos: 
	moveM.l d1-d4,-(sp)
		and.l #$1F8,d1		;0-320
		lsr.l #3,d1
		and.l #$FF,d4
		move.l ScreenBase,a3 ;Get screen pointer into a3
		move.l d1,d3	
		and.l #%11111110,d1
		and.l #%00000001,d3	 ;shift along 1 byte each 4 pixel pairs
		rol.l #2,d1			 ;*4 Bitplane words consecutive in memory
		add.l d1,a3
		add.l d3,a3
		
		mulu #160,d4		 ;160 bytes per Y line
		add.l d4,a3
	moveM.l (sp)+,d1-d4
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Point:
	moveM.l d1-d4/a3-a4,-(sp)
		and.l #$01FF,d1			;Mask X,Y pos
		and.l #$00FF,d4
				
		jsr GetScreenPos		;Calculate Vram address in A3 
									;for pos (D1,D4)
		and.l #$07,d1
		move.l #PixelLookup,a4	;Get Pixel mask from lookup
		add.l d1,a4
		
		move.b (a4),d1			;Save Pixel Mask
		
		clr.l d0				;Buildup for screen byte
		move.b (a3),d2			;Get Bitplane 0
		and.b d1,d2				;Mask Pixel
		beq NoBit0b
		or.b #1,d0				;Bitplane 0=1
NoBit0b:
		
		addq.l #2,a3			;Move To bitplane 1
		move.b (a3),d2			;Get Bitplane 1
		and.b d1,d2				;Mask Pixel
		beq NoBit1b
		or.b #2,d0				;Bitplane 1=1
NoBit1b:

		addq.l #2,a3			;Move To bitplane 2
		move.b (a3),d2			;Get Bitplane 2
		and.b d1,d2
		beq NoBit2b
		or.b #4,d0				;Bitplane 2=1
NoBit2b:

		addq.l #2,a3			;Move To bitplane 3
		move.b (a3),d2			;Get Bitplane 3
		and.b d1,d2
		beq NoBit3b
		or.b #8,d0				;Bitplane 3=1
NoBit3b:
	moveM.l (sp)+,d1-d4/a3-a4
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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


Player_ReadControlsDual:	;---7654S321RLDU
	
	;move.b (Joystickdata),d0		;Process Joy 2
	;jsr Player_ReadControlsProcessOne
	;move.l d0,d1
	
	move.b (Joystickdata+1),d0	;Process Joy 1
	
Player_ReadControlsProcessOne:;Joypad bits 			F---RLDU  	?
	or.l #$FFFFFF00,d0
	roxl.b #1,d0			;Fire -> eXtend flag	---RLDU-   	F 
	rol.b #3,d0				;skip Unused bits		RLDU----   	F 
	roxr.b #1,d0			;Get back F				FRLDU---   	- 
	ror.b #3,d0				;Move needed bits back	---FRLDU   	- 
	eor.b #$FF,d0			;Flip the bits of the bottom byte
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
waitforfire:
	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	bne waitforfire

waitforfireb:
	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	beq waitforfireb
	rts


	
Cls:
	lea Screen_Mem,a3
	move.l #32256,d1
	jsr cldir0				;Zero D1 bytes at address a3
	rts


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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	even

    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
	
screen_mem:				;Reserve screen memory 
    ds.b    32256

ScreenBase: ds.l 1		;Var for base of screen ram
		
UserRam:				;Data area for Vars (4k)
	ds 1024
	
