;We have to send our byte in 2 parts because the NeoGeo Z80 uses commands 0-31 as system commands

ChibiSound:					;NVVTTTTT	Noise Volume Tone 
	moveM.l d0-d1,-(sp)
		move.b d0,d1
		and.b #%00001111,d0		;Send Low nibble
		or.b #%10000000,d0		;10--DDDD	=DDDD is bottom nibble
		move.b	d0,$320000 		;Send a byte to the Z80 
		
ChibiSoundWait:	
		move.b	$320000,d0 		;Get byte from Z80
		cmp.b #255,d0
		bne ChibiSoundWait		;Wait until procesed
		
		move.b d1,d0
		and.b #%11110000,d0		;Send High nibble
		ror #4,d0
		or.b #%11000000,d0		;11--DDDD	=DDDD is top nibble
		move.b	d0,$320000 		;Send a byte to the Z80 
	moveM.l (sp)+,d0-d1
	rts
	
	