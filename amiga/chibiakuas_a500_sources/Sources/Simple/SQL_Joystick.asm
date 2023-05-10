	
	move.b #%00001000,$18063	;Force 8 color mode!
		
	move.w #3,(PlayerX)		;x
	move.w #3,(PlayerY)		;y
	
	move.b #%00000000,d3	;Dummy Keypresses for first run
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:;Row 1: Enter Left Up	Esc	Right \	Space Down
	lea QLJoycommand,a3	 
	move.b #$11,d0		;Command 17
	Trap #1				;Send Keyrequest to the IO CPU
						;Returns row in D1
	move.b d1,d3
	
	cmp.b #%0000000,d3
	beq InfLoop			;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1	;Back up X
	move.w d1,(PlayerX2)

	move.w (PlayerY),d2	;Back up Y
	move.w d2,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr BlankPlayer
	moveM.l (sp)+,d0-d7/a0-a5
	

	btst #2,d3
	beq JoyNotUp	;Jump if UP not pressed
	subq.w #4,d2		;Move Y Up the screen
JoyNotUp: 	
	btst #7,d3
	beq JoyNotDown	;Jump if DOWN not pressed
	addq.w #4,d2		;Move Y DOWN the screen
JoyNotDown: 	
	btst #1,d3
	beq JoyNotLeft	;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #4,d3
	beq JoyNotRight	;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerX)	;Update X
	move.w d2,(PlayerY)	;Update Y

;X Boundary Check - if we go <0 we will end up back at FFFF
	cmp.w #64-1,d1
	bcs PlayerPosXOk		
	jmp PlayerReset		;Player out of bounds - Reset!
PlayerPosXOk

;Y Boundary Check - only need to check 1 byte
	cmp #256-7,d2
	bcs PlayerPosYOk	;Not Out of bounds
	
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
	
	
BlankPlayer:	
	lea BitmapBlank,a0		;Source bitmap
	jmp DrawSprite
DrawPlayer:	
	lea Bitmap,a0			;Source bitmap
DrawSprite:	
	jsr GetScreenPos		;Get Position in Vram
	move.l #8-1,d2			;Height
BmpNextLine:
	move.l (a0)+,(a6)		
	add.l #128,a6			;Add 128 to move down a line
	dbra d2,BmpNextLine
	rts
	
Bitmap:
        DC.B %00000000,%00000101,%00000000,%01010000     ;  0
        DC.B %00000000,%00010101,%00000000,%01010100     ;  1
        DC.B %00000000,%01011101,%00000000,%01110101     ;  2
        DC.B %00000000,%01010101,%00000000,%01010101     ;  3
        DC.B %00000000,%01010101,%00000000,%01010101     ;  4
        DC.B %00000000,%01011001,%00000000,%01100101     ;  5
        DC.B %00000000,%00010110,%00000000,%10010100     ;  6
        DC.B %00000000,%00000101,%00000000,%01010000     ;  7
BitmapEnd:
BitmapBlank:
		ds 4*8	;16 zero bytes
		

GetScreenPos: ; d1=x d2=y
	moveM.l d1-d2,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2
		
		rol.l #1,d1				;Multiply X*2 (2 bytes per 4/8 pixels)
		rol.l #7,d2				;Multiply Y*128
		
		move.l #$00020000,a6	;Screen starts at $20000
		add.l d2,a6
		add.l d1,a6
	moveM.l (sp)+,d1-d2
	rts


QLJoycommand:
	dc.b $09	;0 - Command
	dc.b $01	;1 - parameter bytes
	dc.l 0		;2345 - send option (%00=low nibble)
	dc.b 1		;6 - Parameter: Row
	dc.b 2		;7 - length of reply (%10=8 bits)
	even
	

	
UserRam equ $30000		;Ram for data
		
PlayerX   equ UserRam+0	;Ram for Player Xpos
PlayerY   equ UserRam+2	;Ram for Player Ypos

;Last position
PlayerX2  equ UserRam+4
PlayerY2  equ UserRam+6
	