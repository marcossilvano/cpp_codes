	include "\SrcALL\BasicMacros.asm"

;CollisionMaskY equ %11111000	;Masks for un-drawable co-ordinates 
;CollisionMaskX equ %11111100

ScreenWidth40 equ 1
ScreenWidth equ 40
ScreenHeight equ 25
ScreenObjWidth equ 160-2
ScreenObjHeight equ 200-8



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

	move.l #$ff8240,a1
	lea Palette,a0
	move.l #16-1,d0
	
PaletteAgain:						
	move.w (a0)+,(a1)+	;-RGB
	dbra d0,PaletteAgain
	
	jsr KeyboardScanner_AllowJoysticks
	
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
		lsl.b #2,d1
		jsr GetSpriteAddr
	
		;asl.l #2,d1
		asl.l #3,d4
		;add.l #16,d4
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
	move.l #$1202,d3
	jsr locate
	lea txtfire,a3			;show press fire
	jsr printstring

	move.l #$0018,d3
	jsr locate
	lea txturl,a3			;show url
	jsr printstring

	move.l #$1818,d3
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
	move.l #300,d1			;Loop Delay
	move.l #%11111111,d2	;KeyPress
pausebc:

	jsr Player_ReadControlsDual
	
	cmp.b #%11111111,d0		;Key Pressed?
	beq pausenokey
	move.b d0,d2			;Save keypresses
pausenokey:
	dbra d1,pausebc
	
startdraw:
	movem.l d2,-(sp)
		jsr drawui			;Show User Interface

		lea playerobject,a4
		jsr blanksprite		;Remove old player sprite
	movem.l (sp)+,d2
	
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
	lea Screen_Mem,a3
	move.l #32256,d1
	jsr cldir0
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0
		sub.l #32,d0
		asl.l #5,d0
		lea FontData,a3
		add.l d0,a3
		
		clr.l d1
		clr.l d4
		move.b (CursorX),d1
		lsl.b #2,d1
		move.b (CursorY),d4
		
		asl.l #3,d4			;Ypos *8
		jsr showsprite
		
		addq.b #1,(CursorX)
		
	moveM.l (sp)+,d0-d7/a3
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BlankSprite:	
	move.b (O_CollProg,A4),d0
	
	cmp.b #250,d0
	bcs BlankSpriteNoReturn
	rts
BlankSpriteNoReturn:
	moveM.l d0-d7,-(sp)
		lea FontData,a3	;Sprite Source (Space)
	jmp DrawBoth


GetSpriteAddr:
	moveM.l d0-d7,-(sp)
		and.l #$FF,d0
		asl.l #5,d0
		lea SpriteData,a3
		add.l d0,a3
		
		clr.l d0
		move.b (SpriteFrame),d0
		asl.l #8,d0
		asl.l #1,d0
		add.l d0,a3
		
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
ShowSprite:
	moveM.l d0-d7,-(sp)
		jmp ShowSpriteB
	
DoGetSpriteObj:				;Get Settings from Object IX
	moveM.l d0-d7,-(sp)
		Move.b (O_SprNum,A4),d0	;Sprite Source
		jsr GetSpriteAddr
	
DrawBoth:
		move.b (O_Xpos,A4),d1
		
		move.b (O_Ypos,A4),d4
		
		

;We need to 'chop up' our 8 pixel sprite into 2 parts... 
;EG

;Sprite bits         ------12 345678--
;Mask to keep bg:    11111100 00000011
;Screen Byte  :      AAAAAAAA BBBBBBBB
		
		
ShowSpriteB:	
		move.l d1,-(sp)
			lsr.b #2,d1
			jsr GetScreenPos ;Get Position in Vram XY=(D1,D4)
		move.l (sp)+,d1

		move.l #4,d6		;Pixel offset 
		and.l #%0000011,d1	;2 bits of co-ordinate are not used for byte xpos
		sub.l d1,d6
		
		lsl.l #1,d6			;Virtual co-ordinates are in pixel pairs
		
		move.l #8,d7
		sub.l d6,d7			
		
		move.b #%11111111,d1 ;Sprite Bits to keep for 1st byte %------12
		lsr.b d7,d1			 ;Screen bits to replace for 2nd   %11111100
		
		move.b #%11111111,d4 ;Sprite Bits to keep for 2nd byte %345678--
		lsl.b d6,d4			 ;Screen bits to replace for 1st   %00000011
					
		move.l #8-1,d2			;Height
BmpNextLine:			
		move.l a2,a0
			move.l #3,d3		;Bitplane
NextBitplane:
		;First Byte
			and.b d4,(a2)		;Remove bits we're going to write 11111100
			move.b (a3),d5		;Get bitmap
			lsr.b d7,d5			;Shift into position			  ------12
			or.b d5,(a2)		;Or in to background
			move.l a2,a1
				move.l a2,d0
				addq.l #1,a2
				btst.l #0,d0		;We need to shift 7 pixels every 2 bytes 
				beq BmpNextPixelEven;because 4 word bitplanes are together 
				addq.l #6,a2
BmpNextPixelEven:
			;2nd Byte
				and.b d1,(a2)		;Remove bits we're going to write 00000011
				move.b (a3)+,d5		;Get bitmap
				lsl.b d6,d5			;Shift into position			  345678--
				or.b d5,(a2)		;Or in			
			move.l a1,a2			;Get the left Xpos back	
				
			add.l #2,a2
			dbra d3,NextBitplane	;Move to next bitplane
				
			move.l a0,a2			;Get the left Xpos back
			add.l #160,a2			;Move down a line
			dbra d2,BmpNextLine
	moveM.l (sp)+,d0-d7
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos: ; d1=x d2=y
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		move.l ScreenBase,a2 ;Get screen pointer into a6
		move.l d1,d3	
		and.l #%11111110,d1
		and.l #%00000001,d3	 ;shift along 1 byte each 4 pixel pairs
		rol.l #2,d1			 ;4 Bitplane words consecutive in memory
		add.l d1,a2
		add.l d3,a2
		
		mulu #160,d4		 ;160 bytes per Y line
		add.l d4,a2
	moveM.l (sp)+,d1-d4
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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


BitmapData:
FontData:
	incbin "\ResALL\Yquest\FontAST.raw"

SpriteData:
	incbin "\ResALL\Yquest\AST_YQuest.RAW"
	incbin "\ResALL\Yquest\AST_YQuest2.RAW"
	incbin "\ResALL\Yquest\AST_YQuest3.RAW"
	incbin "\ResALL\Yquest\AST_YQuest4.RAW"
BitmapDataEnd:	
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

Palette:
    dc.w %0000000000000000; ;0  %-----RRR-GGG-BBB
    dc.w %0000000001110000; ;1  %-----RRR-GGG-BBB
    dc.w %0000001000100010; ;2  %-----RRR-GGG-BBB
    dc.w %0000010101010101; ;3  %-----RRR-GGG-BBB
    dc.w %0000011101110111; ;4  %-----RRR-GGG-BBB
    dc.w %0000000101000011; ;5  %-----RRR-GGG-BBB
    dc.w %0000000101100001; ;6  %-----RRR-GGG-BBB
    dc.w %0000011100010001; ;7  %-----RRR-GGG-BBB
    dc.w %0000011100110011; ;8  %-----RRR-GGG-BBB
    dc.w %0000011101010010; ;9  %-----RRR-GGG-BBB
    dc.w %0000011101110010; ;10  %-----RRR-GGG-BBB
    dc.w %0000010100010101; ;11  %-----RRR-GGG-BBB
    dc.w %0000011100000111; ;12  %-----RRR-GGG-BBB
    dc.w %0000000000010110; ;13  %-----RRR-GGG-BBB
    dc.w %0000000100110101; ;14  %-----RRR-GGG-BBB
    dc.w %0000000001100111; ;15  %-----RRR-GGG-BBB

	
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
	
    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
Screen_Mem:				;Reserve screen memory 
    ds.b    32256
ScreenBase: ds.l 1		;Var for base of screen ram
		
UserRam:
	ds $800