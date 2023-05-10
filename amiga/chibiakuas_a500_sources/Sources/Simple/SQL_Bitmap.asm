
	
	move.b #%00001000,$18063	;Force 8 color mode!
	
	move.b #3,d1			;Xpos
	move.b #32,d2			;Ypos
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #8-1,d2			;Height
	lea Bitmap,a0
BmpNextLine:
	move.l (a0)+,(a6)		;Copy 4 Bytes
	add.l #128,a6			;Add 128 to move down a line
	dbra d2,BmpNextLine
	
	jmp *

GetScreenPos: 			; d1=x d2=y - Returns address in a6
	moveM.l d1-d2,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2
		
		rol.l #1,d1		;Multiply X*2 (2 bytes per 4 pixels)
		rol.l #7,d2		;Multiply Y*128
		
		move.l #$00020000,a6	;Screen starts at $20000
		add.l d2,a6
		add.l d1,a6
	moveM.l (sp)+,d1-d2
	rts
	
		; Green / Flash / Blue / Red
Bitmap:	; GFGFGFGF  RBRBRBRB  GFGFGFGF  RBRBRBRB 
	DC.B %00000000,%00000101,%00000000,%01010000     ;  0
    DC.B %00000000,%00010101,%00000000,%01010100     ;  1
    DC.B %00000000,%01011101,%00000000,%01110101     ;  2
    DC.B %00000000,%01010101,%00000000,%01010101     ;  3
    DC.B %00000000,%01010101,%00000000,%01010101     ;  4
    DC.B %00000000,%01011001,%00000000,%01100101     ;  5
    DC.B %00000000,%00010110,%00000000,%10010100     ;  6
    DC.B %00000000,%00000101,%00000000,%01010000     ;  7
BitmapEnd:

