	include "\SrcALL\BasicMacros.asm"

Color1 equ 1				;Color palette
Color2 equ 2				;These are color attributes
Color3 equ 3				
Color4 equ 4

ScreenWidth40 equ 1			;Screen Size Settings
ScreenWidth equ 320
ScreenHeight equ 200

	

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
	
	move.w	#$0000,BPLCON1	;Horizontal scroll 0 - Bitplane control reg. (scroll value PF1, PF2)
	move.w	#$0000,BPL1MOD	;Bitplane modulo (odd planes)
	move.w	#$0000,BPL2MOD	;Bitplane modulo (even planes)
	move.w	#$2c81,DIWSTRT	;Display window start (upper left vert-horiz position)
	move.w	#$F4C1,DIWSTOP	;Display window stop (lower right vert.-horiz. Position)
	move.w	#$0038,DDFSTRT	;Display bitplane data fetch start (horiz. Position)
	move.w	#$00d0,DDFSTOP	;Display bitplane data fetch stop (horiz. position)
	
		  	; FEDCBA9876543210
			;-------DbCBSDAAAA
	move.w  #%1000000110000000,DMACON   ;DMA set ON  - DMA control (and blitter status) read 
										;	(Bit 15 defines set/clear for other bits)
			;-------DbCBSDAAAA
	move.w 	#%0000000001011111,DMACON	;DMA set OFF - Turn off sound
	move.w 	#%1100000000000000,INTENA	;IRQ set ON - Interrupt enable bits read, Turn on master
	move.w 	#%0011111111111111,INTENA	;IRQ set OFF - Turn off all others

	

   ;Entry format:
   ;Change setting:
   ; %0000000n nnnnnnn0 DDDDDDDD DDDDDDDD	nnn= address to Change ($DFFnnn) DDDD=new value to set address
   
   ;wait for pos:
   ; $VVVVVVVV HHHHHHH1 1vvvvvvv hhhhhhh0   V=Vops H=Hpos v= Vpos Compare enable  h=hpos compare enable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copperlist (Commands run by Copper Coprocessor) -all addresses start DFFnnn
	lea CopperList,a6				
   
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
	
	       ; AAAA-RGB	Address - RGB
	move.l #$01800000,(a6)+		; color 0
	move.l #$018200FF,(a6)+		; color 1
	move.l #$01840F0F,(a6)+		; color 2
	move.l #$018600F0,(a6)+		; color 3
	move.l #$01880FF0,(a6)+		; color 4
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



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	jsr waitVBlank
	
	;Enable Copperlist
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)

	
	lea userram,a3
	move.l #$100,d1
	jsr cldir0				;Clear Game Ram
	
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


infloop:					;main loop	
	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0
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
	tst.b (keytimeout)			;See if Keytimeout is set
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

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

waitVBlank:
	move.l ($DFF004),d0	;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0	;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
Pset: 		;D1=X D4=Y	D2=Color
	moveM.l d0-d4/a3-a4,-(sp)
		and.l #$01FF,d1			;Mask X,Y pos
		and.l #$00FF,d4
		
		jsr GetScreenPos		;Calculate Vram address in A3 for 
									;pos (D1,D4)
		and.l #$07,d1
		move.l #PixelLookup,a4	;Get Pixel mask from lookup
		add.l d1,a4
		
		move.b (a4),d1			
		eor.b #$ff,d1			;Save Background mask
		move.b (a4),d3			;Save Pixel Mask
		
								;Process bitplane 0
		move.b (a3),d0			;Get Bitplane 0
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 0
		bcc NoBit0
		or.b d3,d0				;Set Color bit 0
NoBit0:
		move.b d0,(a3)			;Update Bitplane 0
		
		add.l #40*200,a3		;Move To bitplane 1
		move.b (a3),d0			;Get Bitplane 1
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 1
		bcc NoBit1
		or.b d3,d0				;Set Color bit 1
NoBit1:
		move.b d0,(a3)			;Update Bitplane 1
		
		add.l #40*200,a3		;Move To bitplane 2
		move.b (a3),d0			;Get Bitplane 2
		and.b d1,d0				;Mask Background
		roxr.b d2				;Test Color bit 2
		bcc NoBit2
		or.b d3,d0				;Set Color bit 2
NoBit2:
		move.b d0,(a3)			;Update Bitplane 2
		
		add.l #40*200,a3		;Move To bitplane 3
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
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
		
		add.l #40*200*1,a3		;Move To bitplane 1
		move.b (a3),d2			;Get Bitplane 1
		and.b d1,d2				;Mask Pixel
		beq NoBit1b
		or.b #2,d0				;Bitplane 1=1
NoBit1b:

		add.l #40*200*1,a3		;Move To bitplane 2
		move.b (a3),d2			;Get Bitplane 2
		and.b d1,d2
		beq NoBit2b
		or.b #4,d0				;Bitplane 2=1
NoBit2b:

		add.l #40*200*1,a3		;Move To bitplane 3
		move.b (a3),d2			;Get Bitplane 3
		and.b d1,d2
		beq NoBit3b
		or.b #8,d0				;Bitplane 3=1
NoBit3b:
	moveM.l (sp)+,d1-d4/a3-a4
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Addr = ScreenMem + (Ypos * 40) + Xpos
GetScreenPos:
	moveM.l d1-d2,-(sp)
		and.l #$1F8,d1		;0-320
		lsr.l #3,d1
		and.l #$FF,d4
		lea screen_mem,a3  ;Load address of screen (in chip ram) into A6
		add.l d1,a3			;Add X 
		mulu #40,d4			;40 bytes per Y line (320 pixels)
		add.l d4,a3
	moveM.l (sp)+,d1-d2
	rts
		
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Cls:
	lea Screen_Mem,a3
	move.l #(320*200/2),d1
	jsr cldir0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

	Section ChipRAM,Data_c
;Request memory within the 'Chip Ram' base memory 
;This is the only ram our screen and copperlist can use	
								
	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,	4	
gfxbase:	dc.l 0

	CNOP 0,4	
Screen_Mem:				;This is our screen
	ds.b    320*200*4	;320x200 4 bitplanes (16 color)

	CNOP 0,4			;Pad with NOP to next 32 bit boundary
CopperList:
	dc.l $ffffffe 		;COPPER_HALT - end of list (new list)
	ds.b 1024	;Define 1024 bytes of chip ram for our copperlist
  
  
 
UserRam:
	ds $100
	