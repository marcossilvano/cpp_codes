;UseStackMisuse equ 1

VscreenMinX equ 48		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80

VscreenWid equ 160		;Visible Screen Size in logical units
VscreenHei equ 96

VscreenWidClip equ 8
VscreenHeiClip equ 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


DMACON  EQU $dff096 ;DMA control write (clear or set)
DMACONR  EQU $dff002 

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
;--Bz--P-- --------

;Blitter hardware
	
BLTCON0 equ $DFF040	;Blitter control register 0 
BLTCON1 equ $DFF042	;Blitter control register 1

BLTAFWM equ $DFF044	;First Word Mask for A
BLTALWM equ $DFF046	;Last Word Mask for A

BLTCPTH equ $DFF048 ;Address C H
BLTCPTL equ $DFF04A ;Address C L

BLTBPTH equ $DFF04C ;Address B H
BLTBPTL equ $DFF04E ;Address B L

BLTAPTH equ $DFF050 ;Address A H
BLTAPTL equ $DFF052 ;Address A L

BLTDPTH equ $DFF054 ;Address D H
BLTDPTL equ $DFF056 ;Address D L

BLTSIZE equ $DFF058 ;Size of area + START!

BLTCMOD equ $DFF060 ;Modulo C
BLTBMOD equ $DFF062 ;Modulo B
BLTAMOD equ $DFF064 ;Modulo A
BLTDMOD equ $DFF066 ;Modulo D
	
	
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
	
;4 bitplanes 
;40 bytes each - so skip 3 bitplanes (3*40=120) after each line
	move.w	#120,BPL1MOD				;Bitplane modulo (odd planes)
	move.w	#120,BPL2MOD				;Bitplane modulo (even planes)
	
	
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
   ;4 bitplanes are interleaved on concecutive Y lines 
   
	;Send the address of each bitplane in two parts
	move.l #Screen_Mem+(40*0),d0	;Bitplane 0
	move.w #$00e2,(a6)+			;Bitplane 0 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e0,(a6)+			;Bitplane 0 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*1),d0	;Bitplane 1
	move.w #$00e6,(a6)+			;Bitplane 1 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e4,(a6)+			;Bitplane 1 pointer (high 3 bits)
	move.w d0,(a6)+		

	move.l #Screen_Mem+(40*2),d0	;Bitplane 2
	move.w #$00ea,(a6)+			;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00e8,(a6)+			;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*3),d0	;Bitplane 3
	move.w #$00eE,(a6)+			;Bitplane 3 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00eC,(a6)+			;Bitplane 3 pointer (high 3 bits)
	move.w d0,(a6)+		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l a6,(a1)			;the copperlist into our pointer for easy changing
	       ; AAAA-RGB		;Address - RGB
	move.l #$01800000,(a6)+		; color 00
	move.l #$01820808,(a6)+		; color 01
	move.l #$018400FF,(a6)+		; color 02
	move.l #$01860FFF,(a6)+		; color 03
	move.l #$01880f53,(a6)+		; color 04
	move.l #$018a07ad,(a6)+		; color 05
	move.l #$018c0000,(a6)+		; color 06
	move.l #$018e0cef,(a6)+		; color 07
	move.l #$01900005,(a6)+		; color 08
	move.l #$01920FF0,(a6)+		; color 09
	move.l #$019400FF,(a6)+		; color 0A
	move.l #$01960F00,(a6)+		; color 0B
	move.l #$01980f53,(a6)+		; color 0C
	move.l #$019a07ad,(a6)+		; color 0D
	move.l #$019c0FF0,(a6)+		; color 0E
	move.l #$019e0FFF,(a6)+		; color 0F
	
	move.l #$01A00005,(a6)+		; color 10
	move.l #$01A20FF0,(a6)+		; color 11
	move.l #$01A400FF,(a6)+		; color 12
	move.l #$01A60F00,(a6)+		; color 13
	move.l #$01A80f53,(a6)+		; color 14
	move.l #$01Aa07ad,(a6)+		; color 15
	move.l #$01Ac0000,(a6)+		; color 16
	move.l #$01Ae0cef,(a6)+		; color 17
	move.l #$01B00005,(a6)+		; color 18
	move.l #$01B20FF0,(a6)+		; color 19
	move.l #$01B400FF,(a6)+		; color 1A
	move.l #$01B60F00,(a6)+		; color 1B
	move.l #$01B80f53,(a6)+		; color 1C
	move.l #$01Ba07ad,(a6)+		; color 1D
	move.l #$01Bc0000,(a6)+		; color 1E
	move.l #$01Be0FF0,(a6)+		; color 1F
	move.l #$fffffffe,(a6)+		; end of copperlist (COPPER_HALT)

	jsr waitVBlank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	;Enable Copperlist
	
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)

			 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Enable BLIT DMA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				 
			 
	;        FEDCBA9876543210
	move.w #%1000000001000000,(DMACON)  ;$DFF096 DMACON - DMA control write (clear or set)
										;S-----E- ---DCBA	S=Set/Clr E=enable ABCD=Channnels	
										
		
	
	move.l #VscreenMinX,d1		;x
	move.l #VscreenMinY,d4		;y
	
	move.b d1,(PlayerX)			;Back up X
	move.b d4,(PlayerY)			;Back up Y
	jsr DrawPlayer
	
	
	move.b #%00001111,d3
	jmp StartDraw				;Force sprite draw on first run
	
InfLoop:
	moveM.l d0-d2/d4-d7,-(sp)
		jsr Player_ReadControlsDual
		move.l d0,d3
	moveM.l (sp)+,d0-d2/d4-d7
	cmp.b #$FF,d3
	beq InfLoop					;Wait until player presses button
	
StartDraw:
	clr.l d1
	clr.l d4
	move.b (PlayerX),d1	;Back up X
	move.b (PlayerY),d4	;Back up Y
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr DrawPlayer
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	btst #0,d3
	bne JoyNotUp	;Jump if UP not pressed
	subq.b #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown	;Jump if DOWN not pressed
	addq.b #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft	;Jump if LEFT not pressed
	subq.b #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight	;Jump if RIGHT not pressed
	addq.b #1,d1		;Move X Right
JoyNotRight: 	
	move.b d1,(PlayerX)	;Update X
	move.b d4,(PlayerY)	;Update Y

	
PlayerPosYOk:	
	
	jsr DrawPlayer			;Draw Player Sprite
	
	move.l #$3FFF,d1
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
		 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
DrawPlayer:
	move.w #24,d3			;Width in logical units
	move.w #24,d6			;Height in logical units
	move.l #Bitmap,a6		;Bitmap source
	
	jsr docrop				;Do Crop
	
	bcs DrawSpriteAbort		;All offscreen?
	
	
	jsr WaitForBlit			;Wait for existing blit to finish
	
	move.w d1,d5			;Xpos in pixels
	
	lsr.w #2,d1				;Xpos to words
	lsl.w #1,d4				;Ypos to lines
	jsr GetScreenPos		;Get Position in Vram
	
	
	move.l a6,(BLTAPTH)		;Sprite source
	move.l a2,(BLTCPTH)		;Background source for Xor
	move.l a2,(BLTDPTH)		;Screen Destination
	
	move.w d5,d0	
	lsl.w #1,d0
	and.w #%00001111,d0		;Move shift from
	lsl.w #4,d0				;------------SSSS to
	lsl.w #8,d0				;SSSS------------
		  ;SSSSABCDLLLLLLLL
	or.w #%0000101101011010,d0
	move.w d0,(BLTCON0)		;$5A = !AC+A!C
			;BBBB-------EICDL
	move.w #%0000000000000000,(BLTCON1)
	
	move.w #$FFFF,d0
	move.w d0,(BLTAFWM)		;First Mask for Source A
	move.w #$0000,d0
	move.w d0,(BLTALWM) 	;Last Mask  for Source A
	
	move.b (spritehclip),d0
	and.l #%11111110,d0
	add.w #-2,d0
	move.w d0,(BLTAMOD)		;Amount to skip after each line
	
	move.w d3,d0
	lsr.w #2,d0
	move.w #40-2,d5			;Plus 2 for bitshift
	sub.w d0,d5
	move.w d5,(BLTCMOD)		;40-width (6 bytes)=34
	move.w d5,(BLTDMOD)		;40-width (6 bytes)=34
	
	move.w d3,d0			;Width 
	lsr.w #3,d0
	add.w #1,d0				;----------WWWWWW 
	
	lsl.w #8,d6				;Height
	lsl.w #1,d6
	add.w d6,d0				;HHHHHHHHHH------ 

	move.w d0,(BLTSIZE)		;Height + Width & start blit
DrawSpriteAbort:	
	rts
	
	
	
WaitForBlit:
	btst #14,(DMACONR)		;Wait for blit to complete
	bne WaitForBlit 
	rts

;Addr = ScreenMem + (Ypos * 40 * 4) + Xpos
GetScreenPos: 				;d1=x d2=y - returns screen address in A2
	moveM.l d1-d4,-(sp)
		and.l #$FF,d1		;Clear all but the bottom byte
		and.l #$FF,d4
		lea screen_mem,a2  	;Load address of screen (in chip ram) in A6
		add.l d1,a2			;Add X 
		mulu #40*4,d4		;40 bytes per Y line (320 pixels)
		add.l d4,a2
	moveM.l (sp)+,d1-d4
	rts
		
	
			
	
	
waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


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
	move.b d0,d5
	and.b  #%11111000,d5		;Round to words
	addq.b #%00001000,d5		
	and.b #%00000111,d0			;X offset for removed word
	eor.b #%00000111,d0
nolcrop:
	move.b d0,d1				;Draw Xpos
	
;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	and.b  #%11111000,d0		;Round to words
	move.b d0,d2
	
norcrop:
	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	beq nohclip					;nothing to crop?
	
	move.b d0,d2				;Amount to remove from left
	
	lsr #2,d0
	move.b d0,(spritehclip)		;Clip after each line
	
	sub.b d2,d3					;Update Width

;update start byte
	lsr #2,d5					;Convert to words
	add.l d5,a6					;move across 
	
nohclip:
	andi #%11111110,ccr			;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr			;set carry (nothing to draw)
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxbase:	dc.l 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Section ChipRAM,Data_c		;Request memory within the 'Chip Ram' base memory 
								;This is the only ram our screen and copperlist can use
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	CNOP 0,4					;Pad with NOP to next 32 bit boundary
	
Screen_Mem:						;This is our screen
	ds.b    320*200*4			;320x200 4 bitplanes (16 color)

	CNOP 0,4					;Pad with NOP to next 32 bit boundary
CopperList:
	dc.l $ffffffe 				;COPPER_HALT - end of list (new list)
	ds.b 1024					;Define 1024 bytes of chip ram for our copperlist
  
Bitmap:	;4 concecutive lines - each 1 of 4 bitplanes
	incbin "\ResALL\Sprites\RawAMI_Interleaved.RAW"
BitmapEnd:
Transp:	;4 bitplanes (Same as sprite - for BLIT)
	incbin "\ResALL\Sprites\RawAMI_InterleavedTransp.RAW"
TranspEnd:


PlayerX: ds 2 	;Ram for Cursor Xpos
PlayerY: ds 2	;Ram for Cursor Ypos
PlayerX2: ds 2 	;Ram for Cursor Xpos
PlayerY2: ds 2	;Ram for Cursor Ypos

spritehclip: dc.l 0