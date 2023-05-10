
VscreenMinX equ 48		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80

VscreenWid equ 160+4	;Visible Screen Size in logical units
VscreenHei equ 96

VscreenWidClip equ 0
VscreenHeiClip equ 0



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
	
	move.w #VscreenMinX,(PlayerX)		;x
	;move.w #160+48,(PlayerX)		;x
	move.w #VscreenMinY,(PlayerY)	;y
	
	move.w (PlayerX),d1	;Back up X
	move.w (PlayerY),d4	;Back up Y
	jsr DrawPlayer			;Draw Player Sprite
	
	move.b #%00001111,d3
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:
	move.b (Joystickdata+1),d3	;Process Joy 1
	beq InfLoop					;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1	;Back up X
	move.w (PlayerY),d4	;Back up Y
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr DrawPlayer
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	btst #0,d3
	beq JoyNotUp	;Jump if UP not pressed
	subq.b #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	beq JoyNotDown	;Jump if DOWN not pressed
	addq.b #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	beq JoyNotLeft	;Jump if LEFT not pressed
	subq.b #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	beq JoyNotRight	;Jump if RIGHT not pressed
	addq.b #1,d1		;Move X Right
JoyNotRight: 	
	Move.w d1,(PlayerX)
	Move.w d4,(PlayerY)
	
	
PlayerPosYOk:	
	jsr DrawPlayer			;Draw Player Sprite
	
	move.l #$3FFF,d1
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
DrawPlayer:	
	move.w #24+8,d3			;Width in logical units
	move.w #24,d6			;Height in logical units
	move.l #Bitmap,a6		;Bitmap source
	
	jsr docrop				;Do Crop
	
	bcs DrawSpriteAbort		;All offscreen?
	

	addq.b #4,(spritehclip)	;Reduce draw width by 1 byte (4 LU)
	sub.b #4,d3					;(Screen logical width also +4 LU)
	bcs DrawSpriteAbort		;All offscreen?
	
		
	and.l #%11111110,d3		;Round Width in bytes
	beq DrawSpriteAbort			
	subq.l #1,d3			;For dbra
	bcs DrawSpriteAbort			
	
	asl.l #1,d6				;height to lines
	
	asl.l #1,d4				;Ypos to lines
	
	move.l d1,d5			;Calculate bit shift.
	and.l #%00000011,d5	
	rol.l #1,d5				;0-7 bit horizontal shift 
	
	
	lsr.l #2,d1				;Xpos to bytes
	move.l d1,-(sp)
		jsr GetScreenPos	;Get Position in Vram
	move.l (sp)+,d1
		
	
	move.l d3,d7			;Width in bytes
BmpNextLine:			
	
	move.l a2,-(sp)
	move.l d7,-(sp)
	
BmpNextPixel:
		move.b (0,a6),d0	;Src BMP   AA--
		lsl.w #8,d0
		move.b (4,a6),d0	;Src BMP+1 --BB
		lsr.w d5,d0			;Bitshift AABB >> D5 = HHLL
		eor.b d0,(0,a2)		;Low byte --LL to Bitplane 0 
							;High byte discarded HH--
			
		move.b (1,a6),d0	;Repeat for Bitplane 1
		lsl.w #8,d0
		move.b (5,a6),d0
		lsr.w d5,d0
		eor.b d0,(2,a2)		;Bitplane 1
		
		move.b (2,a6),d0	;Repeat for Bitplane 2
		lsl.w #8,d0
		move.b (6,a6),d0
		lsr.w d5,d0
		eor.b d0,(4,a2)		;Bitplane 2
		
		move.b (3,a6),d0	;Repeat for Bitplane 3
		lsl.w #8,d0
		move.b (7,a6),d0
		lsr.w d5,d0
		eor.b d0,(6,a2)		;Bitplane 3
		
		add.l #4,a6
		jsr NextScreenByte
		subq.l #3,d7		;Dbra wil sub 1 - but we need to sub another 
		dbra d7,BmpNextPixel	;3 as we do 4 bytes per update	
		
		clr.l d0
		move.b (spritehclip),d0	;Skip unneeded sprite bytes
		ext.w d0
		ext.l d0
		add.l d0,a6
	move.l (sp)+,d7
	move.l (sp)+,a2			;Get the left Xpos back
	add.l #160,a2			;Move down a line
	
	dbra d6,BmpNextLine
DrawSpriteAbort:	
	rts

NextScreenByte:

		move.l a2,d0
		addq.l #1,a2	
		btst.l #0,d0		;We need to shift 7 pixels every 2 bytes 
		beq BmpNextPixelEven	;because 4 word bitplanes are together in memory
		addq.l #6,a2	
BmpNextPixelEven:
		
		
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
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d5				;amount to remove from top of source
	clr.l d0					;Draw from Y=0
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
	beq novclip					;nothing to remove?
	sub.b d0,d6					;subtract from old height
	
;remove lines from source bitmap (A6)

	lsl.b #1,d5					;Amount to remove from top
	
	mulu d3,d5					;Calculate amount to remove 
								;(Lines*BytesPerLine)
								
	add.l d5,a6					;Remove from source bitmap
	
	
NoVClip:
	clr.l d2					;D5=left D2=right crop
	clr.l d5

;crop left hand side
	move.b d1,d0
	sub.b #vscreenminx,d0		;remove left virtual border
	bcc nolcrop					;nc=nothing needs cropping
	neg.b d0					;Amount to remove
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	addq.b #4,d0				;Round up to word
	move.b d0,d5
	
;New smooth move code added!	**********************************************************	
	and.b #%00000011,d0			;X offset for removed word
	eor.b #%00000011,d0
	
nolcrop:
	move.b d0,d1				;Draw Xpos
		
		
;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	move.b d0,d2				

	
norcrop:
	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	beq nohclip					;nothing to crop?
	and #%11111100,d0		;Working in quads of bytes (8 pixels)
	move.b d0,(spritehclip)

	move.b d0,d2			;amount to subtract from width (right)

	sub.b d2,d3					;Update Width

	;amount to subtract from left
	and.l #%11111100,d5		;Working in quads of bytes (8 pixels)

;update start byte
	add.l d5,a6					;move across 
	
	
nohclip:
	andi #%11111110,ccr			;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr			;set carry (nothing to draw)
	rts


	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos:			 ;d1=X (bytes) d2=Y (Lines) result in A2
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		move.l ScreenBase,a2 ;Get screen pointer into a6
		move.l d1,d3	
		and.l #%11111110,d1
		rol.l #2,d1			 ;4 Bitplane words consecutive in memory
		add.l d1,a2
		and.l #%00000001,d3	 ;shift along 1 byte each 8 pixels
		add.l d3,a2
		
		mulu #160,d4		 ;160 bytes per Y line
		add.l d4,a2
	moveM.l (sp)+,d1-d4
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


	
Bitmap:
	incbin "\ResALL\Sprites\RawASTpadded.RAW"
BitmapEnd:
	even

    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
	
screen_mem:				;Reserve screen memory 
    ds.b    32256

ScreenBase: ds.l 1		;Var for base of screen ram
		
UserRam:				;Data area for Vars (4k)
	ds 1024
	
PlayerX: ds 2 	;Ram for Cursor Xpos
PlayerY: ds 2	;Ram for Cursor Ypos
PlayerX2:ds 2	;Ram for Cursor Xpos
PlayerY2:ds 2	;Ram for Cursor Ypos

spritehclip: ds 1