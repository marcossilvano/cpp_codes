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
			
			;move.w #$25,$EB080A		; Sprite H Total
			;move.w #$04,$EB080C		; Sprite H Disp
			;move.w #$10,$EB080E		; Sprite V Disp
			;move.w #$00,$EB0810		; Sprite Res %---FVVHH

;Palette	
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82000	;Color 0
	move.w #%0000001110011100,$e82002	;Color 1
	move.w #%1111100000111110,$e82004	;Color 2
	move.w #%1111111111111110,$e82006	;Color 3


	move.w #3,(PlayerX)		;x
	move.w #32,(PlayerY)	;y
	
	move.b #%00001111,d3
	jmp StartDraw				;Force sprite draw on first run
	
InfLoop:
	move.b #%00000000,$E9A005	;8255 Port C (Default Controls)
	clr.b d3
	move.b ($E9A001),d3			;-21-RLDU
	and #%00001111,d3
	cmp.b #%00001111,d3
	beq InfLoop					;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1			;Back up X
	move.w d1,(PlayerX2)

	move.w (PlayerY),d2			;Back up Y
	move.w d2,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr BlankPlayer			;Remove old sprite
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d2		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d2		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerX)	;Update X
	move.w d2,(PlayerY)	;Update Y


;X Boundary Check: if we go <0 we will end up back at $FFFF
	cmp.w #256-7,d1
	bcs PlayerPosXOk		
	jmp PlayerReset			;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check 
	cmp #240-7,d2
	bcs PlayerPosYOk		;Not Out of bounds
	
PlayerReset:
	Move.w (PlayerX2),d1	;Reset Xpos	
	Move.w d1,(PlayerX)
	
	Move.w (PlayerY2),d2	;Reset Ypos	
	Move.w d2,(PlayerY)
	
	
PlayerPosYOk:	
	jsr DrawPlayer			;Draw Player Sprite
	
	move.l #$FFF,d1
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
BlankPlayer:	
	lea BitmapBlank,a0		;Source bitmap
	jmp DrawSprite
	
DrawPlayer:	
	lea Bitmap,a0			;Source bitmap
DrawSprite:	
	jsr GetScreenPos		;Get Position in Vram
	move.l #8-1,d2			;Height
BmpNextLine:			
	move.l #(8/2)-1,d1		;2 pixels per word in 16 color mode
	move.l a6,-(sp)
BmpNextPixel:				;Note, each pixel is 2 bytes in ram
		move.b (a0),d0
		ror #4,d0			;Copy Top Nibble
		move.w d0,(a6)+
		move.b (a0)+,d0		;Copy Bottom Nibble
		move.w d0,(a6)+
		dbra d1,BmpNextPixel
	move.l (sp)+,a6			;Get the left Xpos back
	addA #1024,a6			;Move down a line
	dbra d2,BmpNextLine
	rts
	
Bitmap:
		DC.B $00,$11,$11,$00     ;  0
        DC.B $01,$11,$11,$10     ;  1
        DC.B $11,$31,$13,$11     ;  2
        DC.B $11,$11,$11,$11     ;  3
        DC.B $11,$11,$11,$11     ;  4
        DC.B $11,$21,$12,$11     ;  5
        DC.B $01,$12,$21,$10     ;  6
        DC.B $00,$11,$11,$00     ;  7
BitmapBlank:
		DS.B 4*8
BitmapEnd:
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

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
	

	
;Current player pos
PlayerX: dc.w $10
PlayerY: dc.w $10

;Last player pos (For clearing sprite)
PlayerX2: dc.w $10
PlayerY2: dc.w $10
