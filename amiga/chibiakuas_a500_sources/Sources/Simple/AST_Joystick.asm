
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
	move.w #$0000,$ff8240 	;Color 0
	move.w #$0505,$ff8242 	;Color 1
	move.w #$0077,$ff8244 	;Color 2
	move.w #$0777,$ff8246 	;Color 3
	
	jsr KeyboardScanner_AllowJoysticks
	
	move.w #3,(PlayerX)		;x
	move.w #32,(PlayerY)	;y
	
	move.b #%00001111,d3
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:
	move.b (Joystickdata+1),d3	;Process Joy 1
	beq InfLoop					;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1	;Back up X
	move.w d1,(PlayerX2)

	move.w (PlayerY),d2	;Back up Y
	move.w d2,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr BlankPlayer
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	btst #0,d3
	beq JoyNotUp	;Jump if UP not pressed
	subq.w #8,d2		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	beq JoyNotDown	;Jump if DOWN not pressed
	addq.w #8,d2		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	beq JoyNotLeft	;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	beq JoyNotRight	;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerX)	;Update X
	move.w d2,(PlayerY)	;Update Y


;X Boundary Check - if we go <0 we will end up back at &FFFF
	cmp.w #40,d1
	bcs PlayerPosXOk		
	jmp PlayerReset		;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check - only need to check 1 byte
	cmp #200-7,d2
	bcs PlayerPosYOk	;Not Out of bounds
	
PlayerReset:
	Move.w (PlayerX2),d1	;Reset Xpos	
	Move.w d1,(PlayerX)
	
	Move.w (PlayerY2),d2	;Reset Ypos	
	Move.w d2,(PlayerY)
	
	
PlayerPosYOk:	
	jsr DrawPlayer			;Draw Player Sprite
	
	move.l #$FFFF,d1
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	

	
BlankPlayer:	
	lea BitmapBlank,a0		;Source bitmap
	jmp DrawSprite
DrawPlayer:	
	lea Bitmap,a0			;Source bitmap	
DrawSprite:	
	jsr GetScreenPos		;Get Position in Vram
	move.l #8-1,d2			;Height
BmpNextLine:			
	move.l #(8/2)-1,d1		;4 pixels per word in 8 color mode
	move.l a6,-(sp)
BmpNextPixel:
		move.b (a0)+,(a6)	;Bitplane 0
		move.b (a0)+,(2,a6)	;Bitplane 1
		move.b (a0)+,(4,a6)	;Bitplane 2
		move.b (a0)+,(6,a6)	;Bitplane 3	
		move.l a6,d3
		addq.l #1,a6
		btst.l #0,d3		;We need to shift 7 pixels every 2 bytes 
		beq BmpNextPixelEven	;because 4 word bitplanes are together in memory
		addq.l #6,a6
BmpNextPixelEven
		subq.l #3,d1		;Dbra wil sub 1 - but we need to sub another 
		dbra d1,BmpNextPixel	;3 as we do 4 bytes per update
	move.l (sp)+,a6			;Get the left Xpos back
	add.l #160,a6			;Move down a line

	dbra d2,BmpNextLine
	rts
	
Bitmap:
        DC.B $3C,$00,$00,$00     ;  0
        DC.B $7E,$00,$00,$00     ;  1
        DC.B $FF,$24,$00,$00     ;  2
        DC.B $FF,$00,$00,$00     ;  3
        DC.B $FF,$00,$00,$00     ;  4
        DC.B $DB,$24,$00,$00     ;  5
        DC.B $66,$18,$00,$00     ;  6
        DC.B $3C,$00,$00,$00     ;  7
BitmapEnd:
BitmapBlank:	
		ds 4*8


GetScreenPos: ; d1=x d2=y
	moveM.l d1-d3,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2
		move.l ScreenBase,a6 ;Get screen pointer into a6
		move.l d1,d3	
		and.l #%11111110,d1
		and.l #%00000001,d3	 ;shift along 1 byte each 4 pixel pairs
		rol.l #2,d1			 ;4 Bitplane words consecutive in memory
		add.l d1,a6
		add.l d3,a6
		
		mulu #160,d2		 ;160 bytes per Y line
		add.l d2,a6
	moveM.l (sp)+,d1-d3
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


	rts

		
		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	even

    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
screen_mem:				;Reserve screen memory 
    ds.b    32256
ScreenBase: ds.l 1		;Var for base of screen ram
		
PlayerX: ds 2 	;Ram for Cursor Xpos
PlayerY: ds 2	;Ram for Cursor Ypos
PlayerX2:ds 2	;Ram for Cursor Xpos
PlayerY2:ds 2	;Ram for Cursor Ypos
	