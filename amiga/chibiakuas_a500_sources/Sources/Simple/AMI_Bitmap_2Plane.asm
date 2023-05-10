;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


DMACON  EQU $dff096 ;DMA control write (clear or set)
INTENA  EQU $dff09a ;Interrupt enable bits (clear or set bits)
BPLCON0 EQU $dff100 ;Bitplane control register (misc. control bits)
BPLCON1 EQU $dff102 ;Bitplane control reg. (scroll value PF1, PF2)
BPLCON2 EQU $dff104 ;Bitplane control reg. (Priority PF12 / Sprite)
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
	
	
	;Specify 6 Bitplanes - Dual mode 2x 3 bitplanes
	
;PPP=Bitplanes (0-6) D=Double playfield (2 layers)	
	
; 		      FEDCBA9876543210
; 			  RPPPHDCG----PIE-	 		
	move.w	#%0110011000000000,BPLCON0	;Bitplane control register (misc. control bits)
	
;Horizontal scroll 0 - Bitplane control reg. (scroll value PF1, PF2)	
	move.w	#$0000,BPLCON1				
	
;Foreground Background Playfield priority	
			;---------PSSSSSS	P=Playfield Priority / S=Sprite priority
	move.w #%0000000001000000,BPLCON2
	
;Bytes to skip after each line (For hscroll)
	move.w	#$0000,BPL1MOD				;Bitplane modulo (odd planes)
	move.w	#$0000,BPL2MOD				;Bitplane modulo (even planes)
	
;Skip every other line
	;move.w	#$0028,BPL1MOD				;Bitplane modulo (odd planes)
	;move.w	#$0028,BPL2MOD				;Bitplane modulo (even planes)
	
	
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

	
	
	;Copperlist (Commands run by Copper Coprocessor) -all addresses start DFFnnn
   ;Entry format:
   ;Change setting:
   ; %0000000n nnnnnnn0 DDDDDDDD DDDDDDDD	nnn= address to Change ($DFFnnn) DDDD=new value to set address
   
   ;wait for pos:
   ; $VVVVVVVV HHHHHHH1 1vvvvvvv hhhhhhh0   V=Vops H=Hpos v= Vpos Compare enable  h=hpos compare enable
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
   ;Define Memory layout
   
   ;Odd bitplanes are Layer 0 (Playfield 1)
   ;Even bitplanes are Layer 1 (Playfield 2)
	clr.l d2
	clr.l d3
	jsr SetBitplanePos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	move.l a6,(a1)			;the copperlist into our pointer for easy changing
	       ; AAAA-RGB		;Address - RGB
    move.l #$01800000,(a6)+ ;0  -RGB
    move.l #$0182080F,(a6)+ ;1  -RGB
    move.l #$018400FF,(a6)+ ;2  -RGB
    move.l #$01860FFF,(a6)+ ;3  -RGB
    move.l #$01880444,(a6)+ ;4  -RGB
    move.l #$018A0555,(a6)+ ;5  -RGB
    move.l #$018C0666,(a6)+ ;6  -RGB
    move.l #$018E0777,(a6)+ ;7  -RGB
    move.l #$01900888,(a6)+ ;8  -RGB
    move.l #$01920999,(a6)+ ;9  -RGB
    move.l #$01940AAA,(a6)+ ;10  -RGB
    move.l #$01960BBB,(a6)+ ;11  -RGB
    move.l #$01980CCC,(a6)+ ;12  -RGB
    move.l #$019A0DDD,(a6)+ ;13  -RGB
    move.l #$019C0EEE,(a6)+ ;14  -RGB
    move.l #$019E0FFF,(a6)+ ;15  -RGB
    move.l #$01A00F0F,(a6)+ ;16  -RGB
    move.l #$01A20000,(a6)+ ;17  -RGB
    move.l #$01A40111,(a6)+ ;18  -RGB
    move.l #$01A60111,(a6)+ ;19  -RGB
    move.l #$01A80222,(a6)+ ;20  -RGB
    move.l #$01AA0222,(a6)+ ;21  -RGB
    move.l #$01AC0333,(a6)+ ;22  -RGB
    move.l #$01AE0333,(a6)+ ;23  -RGB
    move.l #$01B00444,(a6)+ ;24  -RGB
    move.l #$01B20444,(a6)+ ;25  -RGB
    move.l #$01B40555,(a6)+ ;26  -RGB
    move.l #$01B60555,(a6)+ ;27  -RGB
    move.l #$01B80666,(a6)+ ;28  -RGB
    move.l #$01BA0666,(a6)+ ;29  -RGB
    move.l #$01BC0777,(a6)+ ;30  -RGB
    move.l #$01BE0777,(a6)+ ;31  -RGB

	move.l #$fffffffe,(a6)+		; end of copperlist (COPPER_HALT)

	jsr waitVBlank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	;Enable Copperlist
	
	lea CopperList,a6	;Enable the CopperList
	move.l a6,COP1LCH 	;Coprocessor first location register (high 3 bits, high 5 bits if ECS)
			 ;COP1LCL	;Coprocessor first location register (low 15 bits)

			 
			 
;Layer 1 - Bitplane 0,1,2 (Colors 1-7)
	move.b #3,d1			;x
	move.b #96,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #48-1,d2			;Height
	move.l #(48/8)-1,d3		;Width = 48 - 8 bits per loop
	lea Bitmap,a0
	jsr DrawBitmap
	
;Layer 2
	move.b #3,d1			;x
	move.b #64,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	add.l #40*200*3,a6	;Jump to bitplane 3,4,5 (Colors 9-15)
	
	move.l #48-1,d2			;Height
	move.l #(48/8)-1,d3		;Width = 48 - 8 bits per loop
	lea Bitmap,a0
	jsr DrawBitmap
	
	
	move.l #Screen_Mem+(40*200*0),a0
	move.l #40*200,d0
FillAgain:
	move.b d0,(a0)+
	subq.l #1,d0
	bne FillAgain
	
	
	
	clr.l d1
	clr.l d2
	clr.l d3
	
InfLoop	
	

	move.w	d1,BPLCON1		;--------22221111 	Playfield 1/2 delay (Scroll)

	addq.w #1,d1			;X scroll
	
	add.w #40,d2			;Y Scroll
	
	cmp.w #2000,d2
	bcs NoOverflow
	clr.l d2
NoOverflow:	
	jsr SetBitplanePos		;Update Ypos 
	
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	jsr waitVBlank
	
	jmp InfLoop				;Halt Program

	
DrawBitmap:		
BmpNextLine:			
	move.l d3,d1		;Width = 48 - 8 bits per loop
	move.l a6,-(sp)
BmpNextPixel:
		move.b (a0)+,(40*200*0,a6)	;Bitplane 0		
		move.b (a0)+,(40*200*1,a6)	;Bitplane 1
		move.b (a0)+,(40*200*2,a6)	;Bitplane 2
		addq.l #1,a6				;Move Across screen
		dbra d1,BmpNextPixel
	move.l (sp)+,a6					;Get the left Xpos back
	addA #40,a6						;Move Down a line
	dbra d2,BmpNextLine
	rts	
	
	
waitVBlank:
	move.l ($DFF004),d0		;VPOSR - Read vert most signif. bit (and frame flop)
	and.l #$1ff00,d0
	cmp.l #$12C00,d0		;Test to see if we're in Vblank
	bne waitVBlank
VblankDone:		
	rts

;Addr = ScreenMem + (Ypos * 40) + Xpos
GetScreenPos: ; d1=x d2=y - returns screen address in A6
	moveM.l d1-d2,-(sp)
		and.l #$FF,d1		;Clear all but the bottom byte
		and.l #$FF,d2
		lea screen_mem,a6  ;Load address of screen (in chip ram) into A6
		add.l d1,a6			;Add X 
		mulu #40,d2			;40 bytes per Y line (320 pixels)
		add.l d2,a6
	moveM.l (sp)+,d1-d2
	rts
		
SetBitplanePos:
	;d2/d3=Yoffset (Vertical Scroll position)
;Layer 0  
    lea CopperList,a6					
	;Send the address of each bitplane in two parts
	move.l #Screen_Mem+(40*200*0),d0	;Bitplane 0
	add.l d2,d0
	move.w #$00e2,(a6)+					;Bitplane 0 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00E0,(a6)+					;Bitplane 0 pointer (high 3 bits)
	move.w d0,(a6)+		

	move.l #Screen_Mem+(40*200*1),d0	;Bitplane 2
	add.l d2,d0
	move.w #$00EA,(a6)+					;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00E8,(a6)+					;Bitplane 2 pointer (low 15 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*200*2),d0	;Bitplane 4
	add.l d2,d0
	move.w #$00F2,(a6)+					;Bitplane 4 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00F0,(a6)+					;Bitplane 4 pointer (high 3 bits)
	move.w d0,(a6)+		
	
;Layer 1
	
	move.l #Screen_Mem+(40*200*3),d0	;Bitplane 1
	add.l d3,d0
	move.w #$00E6,(a6)+					;Bitplane 1 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00E4,(a6)+					;Bitplane 1 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*200*4),d0	;Bitplane 3
	add.l d3,d0
	move.w #$00EE,(a6)+					;Bitplane 3 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00EC,(a6)+					;Bitplane 3 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	move.l #Screen_Mem+(40*200*5),d0	;Bitplane 5
	add.l d3,d0
	move.w #$00F6,(a6)+					;Bitplane 5 pointer (low 15 bits)
	move.w d0,(a6)+		
	swap d0
	move.w #$00F4,(a6)+					;Bitplane 5 pointer (high 3 bits)
	move.w d0,(a6)+		
	
	rts	
	
Bitmap:
	incbin "\ResALL\Sprites\RawAMI_8col.RAW"
BitmapEnd:
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Chip Ram
		
	
	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxname dc.b 'graphics.library',0

	CNOP 0,4	; Pad with NOP to next 32 bit boundary
gfxbase:	dc.l 0


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	Section ChipRAM,Data_c		;Request memory within the 'Chip Ram' base memory 
								;This is the only ram our screen and copperlist can use
	
	CNOP 0,4					;Pad with NOP to next 32 bit boundary
	
Screen_Mem:						;This is our screen
	ds.b    320*200*6			;320x200 4 bitplanes (16 color)

	CNOP 0,4					;Pad with NOP to next 32 bit boundary
CopperList:
	dc.l $ffffffe 				;COPPER_HALT - end of list (new list)
	ds.b 1024					;Define 1024 bytes of chip ram for our copperlist
  