	include "\SrcALL\BasicMacros.asm"
	
	move.b #%00001000,$18063	;Force 8 color mode!
	
	move.b #3,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #48-1,d2			;Height
	lea Bitmap,a0
BmpNextLine:			
	move.l #(48/4)-1,d1		;4 pixels per word
	move.l a6,-(sp)
BmpNextPixel:
		move.w (a0)+,(a6)+	;Copy a word
		dbra d1,BmpNextPixel
	move.l (sp)+,a6			;Get the left Xpos back
	
	add.l #128,a6			;Add 128 to move down a line
	dbra d2,BmpNextLine
	
	jmp *

GetScreenPos: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2

		ifd ScrWid256
			add.l #4*8,d2		;Move Y down 32 lines to simulate
		endif					;	 a 256*192 screen 
		
		rol.l #1,d1				;Multiply X*2 (2 bytes per 4/8 pixels)
		rol.l #7,d2				;Multiply Y*128
		
		move.l #$00020000,a6	;Screen starts at $20000
		add.l d2,a6
		add.l d1,a6
	moveM.l (sp)+,d0-d7/a0-a5
	rts
	
	
Bitmap:
	incbin "\ResALL\Sprites\RawQL.raw"
BitmapEnd: