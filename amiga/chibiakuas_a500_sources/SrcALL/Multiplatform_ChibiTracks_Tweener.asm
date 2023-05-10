

TweenTone:	;D0= %ooooffff	o=offset -8 to +7 f=fraction 0-15

	move.l d0,-(sp)
		asr.b #4,d0				;Get signed Offset
		add.b d0,d2				;Add to note
		
		move.l d2,-(sp)
			jsr GetChibiTone	;D2=note (bit 1-6=note  bit0=flat)
			exg d3,d2
		move.l (sp)+,d2
	move.l (sp)+,d0
	
	and.b #%00001111,d0			;Any Fraction?
	beq TweenToneDone
	
	movem.l d0/d3,-(sp)			
			addq.l #1,d2		;Next Note
			jsr GetChibiTone	;D2=note (bit 1-6=note  bit0=flat)
	movem.l (sp)+,d0/d3
	
	jsr Tween16HLDE				;Get Fraction of next note
	
TweenToneDone:
	exg d3,d2			;result in D3
	rts
	
	

GetChibiTone:		;D2=note (8 bit val: bit 1-6=note  bit 0=flat) 
	move.l #chibiOctave,a3		;Returns 16 bit D2 frequency
	
	move.b d2,d0	
	and.l #%11111110,d2			;Clear Sharp/Flat
	add.l d2,a3					
	move.w (a3)+,d2				;First note
	
	btst #0,d0					;Sharp/Flat?
	beq ChibiToneGotNote		;No? we're done!

	lsr.w #1,d2					;Halve first value

	move.w (a3),d3				;Get second value
	lsr.w #1,d3					;Halve second value

	add.l d3,d2					;Add two halves
ChibiToneGotNote:
	rts							;Result in D2

	
	
	