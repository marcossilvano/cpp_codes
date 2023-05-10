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
	move.l #$01800005,(a6)+		; color 00
	move.l #$01820FF0,(a6)+		; color 01
	move.l #$018400FF,(a6)+		; color 02
	move.l #$01860F00,(a6)+		; color 03
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
										
			 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;4 bitplanes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				 
			 
	move.b #3,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram (A6)
										
	move.l #Bitmap,(BLTAPTH)	;Sprite source
	move.l a6,(BLTDPTH)			;Screen Destination
	
; L=miniterms (Logical op) ABCD=enable dma SSSS= bitshift A
			;SSSSABCDLLLLLLLL
	move.w #%0000100111110000,(BLTCON0)	;MINTERM $F0 D=A
	
;B=Bitshift B   D=Descending mode L=Line mode E=Exclusive fill 
			;BBBB-------EICDL		;I=Inclusive fill C=fill Carry in
	move.w #%0000000000000000,(BLTCON1)	
	
	move.w #$FFFF,(BLTAFWM)	;First Word Mask for Source A
	move.w #$FFFF,(BLTALWM) ;Last Word Mask  for Source A
	
	move.w #0,(BLTAMOD)
	move.w #34,(BLTDMOD)	;40-width (6 bytes)=34
	
			;HHHHHHHHHHWWWWWW (Width in words - Height in lines * bitplanes)
	move.w #%0011000000000011,(BLTSIZE)			;(48*4=192)
	
	jsr WaitForBlit
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;XOR
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	move.b #1,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #Bitmap,(BLTAPTH)	;Sprite source
	move.l a6,(BLTCPTH)			;Background source for Xor
	move.l a6,(BLTDPTH)			;Screen Destination
	
			;SSSSABCDLLLLLLLL
	move.w #%0000101101011010,(BLTCON0)	;$5A = !AC+A!C
			;BBBB-------EICDL
	move.w #%0000000000000000,(BLTCON1)
	
	move.w #$FFFF,(BLTAFWM)	;First Mask for Source A
	move.w #$FFFF,(BLTALWM) ;Last Mask  for Source A
	
	move.w #0,(BLTAMOD)
	move.w #34,(BLTCMOD)	;40-width (6 bytes)=34
	move.w #34,(BLTDMOD)	;40-width (6 bytes)=34
	
			;HHHHHHHHHHWWWWWW (Width in words)
	move.w #%0011000000000011,(BLTSIZE)
	
	jsr WaitForBlit
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;4 bitplanes (to show shifter effect)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;				 
			 
	move.b #3,d1			;x
	move.b #64,d2			;y
	jsr GetScreenPos		;Get Position in Vram (A6)
										
	move.l #Bitmap,(BLTAPTH)	;Sprite source
	move.l a6,(BLTDPTH)			;Screen Destination
	
; L=miniterms (Logical op) ABCD=enable dma SSSS= bitshift A
			;SSSSABCDLLLLLLLL
	move.w #%0000100111110000,(BLTCON0)	;MINTERM $F0 D=A
	
;B=Bitshift B   D=Descending mode L=Line mode E=Exclusive fill 
			;BBBB-------EICDL		;I=Inclusive fill C=fill Carry in
	move.w #%0000000000000000,(BLTCON1)	
	
	move.w #$FFFF,(BLTAFWM)	;First Word Mask for Source A
	move.w #$FFFF,(BLTALWM) ;Last Word Mask  for Source A
	
	move.w #0,(BLTAMOD)
	move.w #34,(BLTDMOD)	;40-width (6 bytes)=34
	
			;HHHHHHHHHHWWWWWW (Width in words - Height in lines * bitplanes)
	move.w #%0011000000000011,(BLTSIZE)			;(48*4=192)
	
	jsr WaitForBlit
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Shifted
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
	move.b #3,d1			;x
	move.b #64,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #Bitmap,(BLTAPTH)	;Sprite source
	move.l a6,(BLTDPTH)			;Screen Destination

			;SSSSABCDLLLLLLLL
	move.w #%0010100111110000,(BLTCON0)	;Bitshift 8 bits
			;BBBB-------EICDL	
	move.w #%0000000000000000,(BLTCON1)
	
	move.w #%0111111111111111,(BLTAFWM)	;First Word Mask (A)
	move.w #%1000000000000000,(BLTALWM) ;Last Word Mask  (A)
	
	move.w #-2,(BLTAMOD)	;Move Sprite back 1 word (2 bytes)
	move.w #32,(BLTDMOD)	;6 bytes + 2 for shift
	
			;HHHHHHHHHHWWWWWW (Width in words)
	move.w #%0011000000000100,(BLTSIZE)	;4 
			;(3 word sprite +1 word for shift)
	
	jsr WaitForBlit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Via CPU
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	
	move.b #20,d1			;x
	move.b #0,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	add.l #40,a6			;Bitplane shift
	
	move.l #((48-1)*4),d2	;Height*Bitplanes
	lea Bitmap,a0
BmpNextLine:			
	move.l #(48/8)-1,d1		;Width = 48 - 8 bits per loop
	move.l a6,-(sp)
BmpNextPixel:
		move.b (a0)+,(a6)		;Do one Bitplane 
		addq.l #1,a6			;Move Across screen
		dbra d1,BmpNextPixel
	move.l (sp)+,a6				;Get the left Xpos back
	addA #40,a6					;Move Down a line
	dbra d2,BmpNextLine
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Mask
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	move.b #18,d1			;x
	move.b #20,d2			;y
	jsr GetScreenPos		;Get Position in Vram

	move.l #Bitmap,(BLTAPTH)	;Sprite

	move.l #Transp,(BLTBPTH)	;Mask
;Color 0= Use sprite / Color 15 = keep Background	
	
	move.l a6,(BLTCPTH)			;Background for mask
	move.l a6,(BLTDPTH)			;Screen Destination
	
			;SSSSABCDLLLLLLLL
	move.w #%0000111111111000,(BLTCON0)	;F8 = A + !B*C 
			;BBBB-------EICDL
	move.w #%0000000000000000,(BLTCON1)
	
	move.w #$FFFF,(BLTAFWM)	;First Mask
	move.w #$FFFF,(BLTALWM) ;Last Mask
	
	move.w #0,(BLTAMOD)		
	move.w #0,(BLTBMOD)
	move.w #34,(BLTCMOD)	;40-width (6 bytes)=34
	move.w #34,(BLTDMOD)	;40-width (6 bytes)=34
	
			;HHHHHHHHHHWWWWWW (Width in words)
	move.w #%0011000000000011,(BLTSIZE)
	
	
	jsr WaitForBlit
	; BLTSIZE equ $DFF058 ;Size of area

; BLTCPTH equ $DFF048 ;Address C H
; BLTCPTH equ $DFF04A ;Address C L

; BLTBPTH equ $DFF04C ;Address B H
; BLTBPTH equ $DFF04E ;Address B L

; BLTAPTH equ $DFF050 ;Address A H
; BLTAPTH equ $DFF052 ;Address A L

; BLTDPTH equ $DFF054 ;Address D H
; BLTDPTH equ $DFF056 ;Address D L

; BLTCMOD equ $DFF060 ;Modulo C
; BLTBMOD equ $DFF062 ;Modulo B
; BLTAMOD equ $DFF064 ;Modulo A
; BLTDMOD equ $DFF066 ;Modulo D
	
; BLTAFWM equ $DFF044	;First Word Mask for A
; BLTALWM equ $DFF046	;Last Word Mask for A
	
; BLTCON0 equ $DFF040 
; BLTCON1 equ $DFF042
	
	jmp *				;Halt Program
	
WaitForBlit:
	btst #14,(DMACONR);Wait for blit to complete
	bne WaitForBlit 
	
	move.l #$F,d2	;Wait so we can see the result (not needed!)
	move.l #$FFFF,d1	;Wait so we can see the result (not needed!)
Delay:	
	dbra d1,Delay
	dbra d2,Delay
	
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
		mulu #40*4,d2		;40 bytes per Y line (320 pixels)
		add.l d2,a6
	moveM.l (sp)+,d1-d2
	rts
		
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Chip Ram
		
	
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