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
	move.l #0,a1			;Null view
	jsr (-222,a6)			;LoadView - Use a (possibly freshly created) coprocessor 
							;	instruction list to create the current display.
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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

	
	
	lea CopperList,a6					;Copperlist (Commands run by Copper Coprocessor) -all addresses start DFFnnn
   ;Entry format:
   ;Change setting:
   ; %0000000n nnnnnnn0 DDDDDDDD DDDDDDDD	nnn= address to Change ($DFFnnn) DDDD=new value to set address
   
   ;wait for pos:
   ; $VVVVVVVV HHHHHHH1 1vvvvvvv hhhhhhh0   V=Vops H=Hpos v= Vpos Compare enable  h=hpos compare enable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l a6,(a1)			;the copperlist into our pointer for easy changing
	       ; AAAA-RGB		;Address - RGB
	move.l #$01800005,(a6)+		; color 0
	move.l #$01820FF0,(a6)+		; color 1
	move.l #$018400FF,(a6)+		; color 2
	move.l #$01860F00,(a6)+		; color 3
	move.l #$01880f53,(a6)+		; color 4
	move.l #$018a07ad,(a6)+		; color 5
	move.l #$018c0000,(a6)+		; color 6
	move.l #$018e0cef,(a6)+		; color 7
	move.l #$01900005,(a6)+		; color 8
	move.l #$01920FF0,(a6)+		; color 9
	move.l #$019400FF,(a6)+		; color A
	move.l #$01960F00,(a6)+		; color B
	move.l #$01980f53,(a6)+		; color C
	move.l #$019a07ad,(a6)+		; color D
	move.l #$019c0000,(a6)+		; color E
	move.l #$019e0FF0,(a6)+		; color F
	
	move.l #$01A00005,(a6)+		; color 0
	move.l #$01A20FF0,(a6)+		; color 1
	move.l #$01A400FF,(a6)+		; color 2
	move.l #$01A60F00,(a6)+		; color 3
	move.l #$01A80f53,(a6)+		; color 4
	move.l #$01Aa07ad,(a6)+		; color 5
	move.l #$01Ac0000,(a6)+		; color 6
	move.l #$01Ae0cef,(a6)+		; color 7
	move.l #$01B00005,(a6)+		; color 8
	move.l #$01B20FF0,(a6)+		; color 9
	move.l #$01B400FF,(a6)+		; color A
	move.l #$01B60F00,(a6)+		; color B
	move.l #$01B80f53,(a6)+		; color C
	move.l #$01Ba07ad,(a6)+		; color D
	move.l #$01Bc0000,(a6)+		; color E
	move.l #$01Be0FF0,(a6)+		; color F
	move.l #$fffffffe,(a6)+		; end of copperlist (COPPER_HALT)

	jsr waitVBlank

	;Enable Copperlist
	
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		 
			 
	move.w #3,(PlayerX)		;x
	move.w #32,(PlayerY)	;y
	
	move.b #%00001111,d3
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:
	moveM.l d0-d2/d4-d7,-(sp)
		jsr Player_ReadControlsDual
		move.l d0,d3
	moveM.l (sp)+,d0-d2/d4-d7
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
	bne JoyNotUp	;Jump if UP not pressed
	subq.w #8,d2		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown	;Jump if DOWN not pressed
	addq.w #8,d2		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft	;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight	;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerX)	;Update X
	move.w d2,(PlayerY)	;Update Y


;X Boundary Check - if we go <0 we will end up back at &FF
	
	cmp.w #40,d1
	bcs PlayerPosXOk		
	jmp PlayerReset		;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check - only need to check 1 byte
	cmp #200-7,d2
	bcs PlayerPosYOk	;Not Out of bounds
	
PlayerReset:
	clr.l d1

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
		move.b (a0)+,(a6)		
		move.b (a0)+,(40*200*1,a6)
		move.b (a0)+,(40*200*2,a6)	;4 bitplanes
		move.b (a0)+,(40*200*3,a6)
		addq.l #1,a6
		subq.l #3,d1
		dbra d1,BmpNextPixel
	move.l (sp)+,a6			;Get the left Xpos back
	addA #40,a6				;Move down a line
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
BitmapBlank
		ds 4*8	
	
	
waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

GetScreenPos: ; d1=x d2=y
	moveM.l d1-d2,-(sp)
		and.l #$FF,d1		;Clear all but the bottom byte
		and.l #$FF,d2
	
		lea  screen_mem,a6  ;Load address of screen (in chip ram) into A6

		add.l d1,a6			;Add X 
				
		mulu #40,d2			;40 bytes per Y line (32o pixels)
		add.l d2,a6

	moveM.l (sp)+,d1-d2
	rts

Player_ReadControlsDual:;---7654S321RLDU
	move.b #%00111111,$BFE201	;Direction for port A (BFE001)....0=in 1=out... 
								;(For fire buttons)

	move.w $dff00A,d2			;Joystick-mouse 0 data (vert,horiz) (Joy2)
	
	move.b $bfe001,d5			;/FIR1 /FIR0  /RDY /TK0  /WPRO /CHNG /LED  OVL
	rol.b #1,d5					;Fire0 for joy 2
	
	bsr Player_ReadControlsOne	;Process Joy2
	move.l d0,-(sp)
		move.w $dff00c,d2		;Joystick-mouse 1 data (vert,horiz) (Joy1)
		move.b $bfe001,d5		;/FIR1 /FIR0  /RDY /TK0  /WPRO /CHNG /LED  OVL
	
		bsr Player_ReadControlsOne ;Process Joy 1
	move.l (sp)+,d1
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
	
;Direction	Bit in $DFF0A/C
;Right		1
;Left		9
;Down		1 XOR 0
;UP 		9 XOR 8
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Chip Ram
		
	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxbase:	dc.l 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Section ChipRAM,Data_c	;Request memory within the 'Chip Ram' base memory 
							;This is the only ram our screen and copperlist can use
	CNOP 0,4				;Pad with NOP to next 32 bit boundary
Screen_Mem:					;This is our screen
	ds.b    320*200*4		;320x200 4 bitplanes (16 color)
	CNOP 0,4				;Pad with NOP to next 32 bit boundary	
CopperList:	dc.l $ffffffe 	;COPPER_HALT - end of list (new list)
	ds.b 1024				;Define 1024 bytes of chip ram for our copperlist
	
PlayerX: ds 2 	;Ram for Cursor Xpos
PlayerY: ds 2	;Ram for Cursor Ypos
PlayerX2:ds 2	;Ram for Cursor Xpos
PlayerY2:ds 2	;Ram for Cursor Ypos
	 