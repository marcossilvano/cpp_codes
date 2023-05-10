	include "\SrcALL\BasicMacros.asm"

CollisionMaskX equ %11111100

ScreenWidth40 equ 1
ScreenWidth equ 40
ScreenHeight equ 25
ScreenObjWidth equ 160-2
ScreenObjHeight equ 200-8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


DMACON  EQU $dff096 ;DMA control write (clear or set)
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

	SECTION TEXT		;CODE Section
	
;Enable the screen display	
	move.l	#gfxname,a1 	;'graphics.library' defined in chip ram
	moveq.l	#0,d0
	move.l	$4,a6
	jsr	(-552,a6)			;Exec - Openlibrary
	
	move.l	d0,gfxbase
	move.l 	d0,a6
	move.l #0,a1			
	jsr (-222,a6)			
	;Start defining our screen layout
; 		      FEDCBA9876543210
; 			  RPPPHDCG----PIE-	 		;four bitPlanes (16 color) Color on
	move.w	#%0100001000000000,BPLCON0	;Bitplane control register (misc. control bits)
	
	move.w	#$0000,BPLCON1				;Horizontal scroll 0 - Bitplane control reg. (scroll value PF1, PF2)
	move.w	#$0000,BPL1MOD				;Bitplane modulo (odd planes)
	move.w	#$0000,BPL2MOD				;Bitplane modulo (even planes)
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


   ;Entry format:
   ;Change setting:
   ; %0000000n nnnnnnn0 DDDDDDDD DDDDDDDD	nnn= address to Change ($DFFnnn) DDDD=new value to set address
   
   ;wait for pos:
   ; $VVVVVVVV HHHHHHH1 1vvvvvvv hhhhhhh0   V=Vops H=Hpos v= Vpos Compare enable  h=hpos compare enable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   	lea CopperList,a6					;Copperlist (Commands run by Copper Coprocessor) -all addresses start DFFnnn
   
   ;Define Memory layout
	;Send the address of each bitplane in two parts
	move.l #Screen_Mem+(40*200*0),d0	;Bitplane 1
	move.w #$00e2,(a6)+					;Bitplane 1 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e0,(a6)+					;Bitplane 1 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*200*1),d0	;Bitplane 2
	move.w #$00e6,(a6)+					;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e4,(a6)+					;Bitplane 2 pointer (high 3 bits)
	move.w d0,(a6)+		

	move.l #Screen_Mem+(40*200*2),d0	;Bitplane 3
	move.w #$00ea,(a6)+					;Bitplane 3 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e8,(a6)+					;Bitplane 4 pointer (low 15 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*200*3),d0	;Bitplane 4
	move.w #$00eE,(a6)+					;Bitplane 4 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00eC,(a6)+					;Bitplane 4 pointer (high 3 bits)
	move.w d0,(a6)+	
	
;Define Palette
	       ; AAAA-RGB		;Address - RGB
    move.l #$01800000,(a6)+ ;0  -RGB   0
    move.l #$018201F0,(a6)+ ;1  -RGB   1
    move.l #$01840555,(a6)+ ;2  -RGB   2
    move.l #$01860AAA,(a6)+ ;3  -RGB   3
    move.l #$01880FFF,(a6)+ ;4  -RGB   4
    move.l #$018A0286,(a6)+ ;5  -RGB   5
    move.l #$018C03D3,(a6)+ ;6  -RGB   6
    move.l #$018E0E33,(a6)+ ;7  -RGB   7
    move.l #$01900E76,(a6)+ ;8  -RGB   8
    move.l #$01920EA5,(a6)+ ;9  -RGB   9
    move.l #$01940FF4,(a6)+ ;10  -RGB   10
    move.l #$01960A2A,(a6)+ ;11  -RGB   11
    move.l #$01980F0F,(a6)+ ;12  -RGB   12
    move.l #$019A003D,(a6)+ ;13  -RGB   13
    move.l #$019C036B,(a6)+ ;14  -RGB   14
    move.l #$019E00DF,(a6)+ ;15  -RGB   15
	
	move.l #$fffffffe,(a6)+		; end of copperlist (COPPER_HALT)

;Enable Copperlist	
	jsr waitVBlank
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		 
			 

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
	
		jsr GetSpriteAddr	;Calculate Tile Ram location
		asl.l #3,d4			;Y * 8
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
	move.l #600,d1			;Loop Delay
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
	move.l #(320*200/2),d1
	jsr cldir0
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PrintSpace:	
	move.l #' ',d0
PrintChar:
	moveM.l d0-d7/a3,-(sp)
		and.l #$FF,d0
		sub.l #32,d0		;No Chars <32
		asl.l #5,d0			;32 bytes per char
		lea FontData,a3
		add.l d0,a3			;Add offset to font base
		
		clr.l d1
		clr.l d4
		move.b (CursorX),d1
		move.b (CursorY),d4
		
		asl.l #3,d4			;Ypos *8
		jsr showsprite
		
		addq.b #1,(CursorX)	;Move to next char position
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
	
DoGetSpriteObj:				;Get Settings from Object A4
	moveM.l d0-d7,-(sp)
		Move.b (O_SprNum,A4),d0	;Sprite Source
		jsr GetSpriteAddr
	
DrawBoth:
		move.b (O_Xpos,A4),d1
		lsr.b #2,d1
		move.b (O_Ypos,A4),d4
		
ShowSpriteB:	
		jsr GetScreenPos		;Get Position in Vram	
		move.l #8-1,d2			;Height
	BmpNextLine:			
		move.l #(8/2)-1,d1		;4 pixels per word in 8 color mode
		move.l a2,-(sp)
	BmpNextPixel:
			move.b (a3)+,(a2)		
			move.b (a3)+,(40*200*1,a2)
			move.b (a3)+,(40*200*2,a2)	;4 bitplanes
			move.b (a3)+,(40*200*3,a2)
			addq.l #1,a2
			subq.l #3,d1
			dbra d1,BmpNextPixel
		move.l (sp)+,a2			;Get the left Xpos back
		addA #40,a2				;Move down a line
		dbra d2,BmpNextLine
	moveM.l (sp)+,d0-d7
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


GetScreenPos: ; d1=x d4=y
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1		;Clear all but the bottom byte
		and.l #$FF,d4
	
		lea  screen_mem,a2  ;Load address of screen (in chip ram) into A6

		add.l d1,a2			;Add X 
				
		mulu #40,d4			;40 bytes per Y line (32o pixels)
		add.l d4,a2

	moveM.l (sp)+,d1-d4
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Player_ReadControlsDual:;---7654S321RLDU
	moveM.l d1-d5,-(sp)
		move.b #%00111111,$BFE201;Direction for port A (BFE001)....0=in 1=out.
								;(For fire buttons)

		move.w $dff00c,d2		;Joystick-mouse 1 data (vert,horiz) (Joy1)
		move.b $bfe001,d5		;/FIR1 /FIR0  /RDY /TK0  /WPRO /CHNG /LED  OVL

		bsr Player_ReadControlsOne ;Process Joy 1
	moveM.l (sp)+,d1-d5
	rts	
	
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

waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Chip Ram
		
	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxbase:	dc.l 0

	Section ChipRAM,Data_c	;Request memory within the 'Chip Ram' base memory 
							;This is the only ram our screen and copperlist can use
	CNOP 0,4				;Pad with NOP to next 32 bit boundary
Screen_Mem:					;This is our screen
	ds.b    320*200*4		;320x200 4 bitplanes (16 color)
	CNOP 0,4				;Pad with NOP to next 32 bit boundary	
CopperList:	dc.l $ffffffe 	;COPPER_HALT - end of list (new list)
	ds.b 1024				;Define 1024 bytes of chip ram for our copperlist
	
WavNoise:
	dc.b	195,	184,	71,	82,	141,	186,	62,	131
	dc.b	135,	217,	250,	193,	80,	152,	194,	2
	dc.b	228,	51,	171,	121,	73,	117,	107,	210
	dc.b	106,	228,	241,	131,	229,	150,	118,	81
	dc.b	195,	184,	71,	82,	141,	186,	62,	131
	dc.b	195,	184,	71,	82,	141,	186,	62,	131
	dc.b	135,	217,	250,	193,	80,	152,	194,	2
	dc.b	228,	51,	171,	121,	73,	117,	107,	210
	dc.b	106,	228,	241,	131,	229,	150,	118,	81
	dc.b	195,	184,	71,	82,	141,	186,	62,	131
WavNoiseEnd:

WavTone:
	;dc.b 127,-127,127,-127,127,-127,127,-127,127,-127,127,-127,127,-127,127,-127
	dc.b 0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90,0,90
WavToneEnd:	
	
UserRam:
	ds $800
	
	
	