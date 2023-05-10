
	clr.l d0			;0=Enable Supervisor mode
	move.l d0,-(sp)
	dc.w $FF20			;Switch Mode
	addq.l  #4,sp
	
;Turn on the screen.

	;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	;		 --SSTTGG44332211
	move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
	;		 FEDCBA9876543210	
	;				  ST43210		
	move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) 
	
	move.w #$025,$E80000 	;R00 Horizontal total 
	move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$000,$E80004	;R02 Horizontal display start position
	move.w #$020,$E80006	;R03 Horizontal display end position
	move.w #$103,$E80008	;R04 Vertical total 
	move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$010,$E8000C	;R06 Vertical display start position
	move.w #$100,$E8000E	;R07 Vertical display end position
	move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
	
	;move.w #$25,$EB080A		; Sprite H Total
	;move.w #$04,$EB080C		; Sprite H Disp
	;move.w #$10,$EB080E		; Sprite V Disp
	;move.w #$00,$EB0810		; Sprite Res %---FVVHH

;Palette	
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82000	;Color 0 Black
	move.w #%0000001110011100,$e82002	;Color 1 Purple
	move.w #%1111100000111110,$e82004	;Color 2 Cyan
	move.w #%1111111111111110,$e82006	;Color 3 White


	move.b #3,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #8-1,d2		;Height
	lea Bitmap,a0
BmpNextLine:			
	move.l #(8/2)-1,d1	;Width: 2 pixels per word in 16 color mode
	move.l a6,-(sp)
BmpNextPixel:
							;Note, each pixel is 2 bytes in ram
		move.b (a0),d0
		ror #4,d0			;Copy Top Nibble
		move.w d0,(a6)+
		move.b (a0)+,d0		;Copy Bottom Nibble
		move.w d0,(a6)+
	
		dbra d1,BmpNextPixel
	move.l (sp)+,a6			;Get the left Xpos back
	addA #1024,a6			;Move down a line
	dbra d2,BmpNextLine
	
	jmp *					;InfLoop
	


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
	

	
	
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
Bitmap:
		DC.B $00,$11,$11,$00     ;  0
        DC.B $01,$11,$11,$10     ;  1
        DC.B $11,$31,$13,$11     ;  2
        DC.B $11,$11,$11,$11     ;  3
        DC.B $11,$11,$11,$11     ;  4
        DC.B $11,$21,$12,$11     ;  5
        DC.B $01,$12,$21,$10     ;  6
        DC.B $00,$11,$11,$00     ;  7
BitmapEnd:
	even
