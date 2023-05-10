ScreenINIT:	
		ifd Res256x256	
			;		 FEDCBA9876543210	
			move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
			move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
			;		 --SSTTGG44332211
			move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
			;		 FEDCBA9876543210	
			;				  ST43210		
			move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
			
			move.w #$025,$E80000 	;R00 Horizontal total 
			move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
			move.w #$000,$E80004	;R02 Horizontal display start position
			move.w #$020,$E80006	;R03 Horizontal display end position
			move.w #$103,$E80008	;R04 Vertical total 
			move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
			move.w #$010,$E8000C	;R06 Vertical display start position
			move.w #$100,$E8000E	;R07 Vertical display end position
			move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
			
			move.w #$25,$EB080A		; Sprite H Total
			move.w #$04,$EB080C		; Sprite H Disp
			move.w #$10,$EB080E		; Sprite V Disp
			move.w #$00,$EB0810		; Sprite Res %---FVVHH
			
		endif
		ifd Res512x256
			;		 FEDCBA9876543210	
			move.w #%0000000000000001,$e80028 ;R20 Memory mode/Display mode control
			move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
			;		 --SSTTGG44332211
			move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
			;				  ST43210		
			move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On	/ sprite on
			
			move.w #$4B,$E80000		;R00 Horizontal total 
			move.w #$03,$E80002		;R01 Horizontal synchronization end position timing
			move.w #$05,$E80004		;R02 Horizontal display start position
			move.w #$45,$E80006		;R03 Horizontal display end position
			move.w #$103,$E80008	;R04 Vertical total 
			move.w #$2,$E8000A		;R05 Vertical synchronization end position timing
			move.w #$10,$E8000C		;R06 Vertical display start position
			move.w #$100,$E8000E	;R07 Vertical display end position
			move.w #$44,$E80010		;R08 External synchronization horizontal adjust: Horizontal position tuning
			
			move.w #$FF,$EB080A		; Sprite H Total
			move.w #$09,$EB080C		; Sprite H Disp
			move.w #$10,$EB080E		; Sprite V Disp
			move.w #$01,$EB0810		; Sprite Res %---FVVHH
			
		endif
		ifd Res512x512
			;		 FEDCBA9876543210	
			move.w #%0000000000000101,$e80028 ;R20 Memory mode/Display mode control
			move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
			move.w #%0000001111100100,$e82500 ;R1 (Priority control) - Priority
			;		 FEDCBA9876543210	
			;				  ST43210		
			move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
			
			move.w #$04B,$E80000	;R00 Horizontal total 
			move.w #$003,$E80002	;R01 Horizontal synchronization end position timing
			move.w #$005,$E80004	;R02 Horizontal display start position
			move.w #$045,$E80006	;R03 Horizontal display end position
			move.w #$103,$E80008	;R04 Vertical total 
			move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
			move.w #$010,$E8000C	;R06 Vertical display start position
			move.w #$100,$E8000E	;R07 Vertical display end position
			move.w #$044,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
			
			move.w #$FF,$EB080A		; Sprite H Total
			move.w #$09,$EB080C		; Sprite H Disp
			move.w #$10,$EB080E		; Sprite V Disp
			move.w #$05,$EB0810		; Sprite Res %---FVVHH
		endif

		;  	     FEDCBA9876543210	
		move.w #%0000001000000000,$eB0808 ;Disp/CPU 1=sprites on (slow writing)
				
		
		;        GGGGGRRRRRBBBBB-
		move.w #%0000000000011110,$e82000		;Palette Entry 0
		move.w #%1111111100000000,$e82002		;Palette Entry 1
		move.w #%1111100000111110,$e82004		;Palette Entry 2
		move.w #%0000011111000000,$e82006		;Palette Entry 3
		move.w #%1111111100000000,$e8201E		;Palette Entry 15
	rts
	
	

GetScreenPos: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2
		
		rol.l #1,d1				;2 bytes per pixel		
		add.l #$c00000,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a6
		
		rol.l #8,d2				;1024 bytes per Y line 
		rol.l #2,d2
		add.l d2,a6
	moveM.l (sp)+,d0-d7/a0-a5
	rts
	
GetNextLine:	
	addA #1024,a6
	rts
	
	
	
	;move.l #1,d0		;Tile Number
	;lea Sprite,a3		;Sprite Address

DefineSprite:
	rol.l #7,d0				;Each sprite has 128 bytes of data (&80 bytes)
	add.l #$EB8000,d0		;Base address of sprite vram
	move.l d0,a0
	
	move.l #$80-1,d2
	clr.l d0
CopySpriteAgain:			;Copy the data from A3 to the Sprite ram
	move.w (a3)+,(a0)+
	dbra d2,CopySpriteAgain
	rts

	

	; move.l #0,d0		;Hardware Sprite Number
	; move.l #$50,d1	;Xpos
	; move.l #$30,d2	;Ypos
	; move.l #0,d3		;Sprite Pattern
	; move.l #0,d4		;Palette
	; move.l #3,d5		;Priority
	
SetSprite:
	moveM.l d0-d2/a0,-(sp)	
		rol.l #3,d0			;4 bytes per sprite
		add.l #$EB0000,d0
		move.l d0,a0
		
		move.w d1,(a0)+		;------XX XXXXXXXX - X=Xpos
		move.w d2,(a0)+		;------YY YYYYYYYY - Y=Ypos
		
		rol.l #8,d4			;Shift palette into top byte
		add.l d4,d3
		
		move.w d3,(a0)+		;VH--CCCC SSSSSSSS - S=Sprite C=Color V=Vflip H=Hflip
		move.w d5,(a0)+		;-------- ------PP - P=Priority
	moveM.l (sp)+,d0-d2/a0
	rts


	
waitVBlank:
	move.w $e88000,d0			;MFP (MC68901)
	and.w #%00010000,d0			;Wait for vblank to start
	beq waitVBlank
waitVBlank2:	
	move.w $e88000,d0			;MFP (MC68901)
	and.w #%00010000,d0			;Wait for Vblank to end
	bne waitVBlank2
	rts

	
;#define GPIP_ALARM    (1 << 0)
;#define GPIP_EXPON    (1 << 1)
;#define GPIP_POWSW    (1 << 2)
;#define GPIP_OPMIRQ   (1 << 3)
;#define GPIP_VDISP    (1 << 4)
;#define GPIP_CRTC     (1 << 6)
;#define GPIP_HSYNC    (1 << 7)