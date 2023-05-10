

Tween16hlde:	;a/16 of D2, 16- D0/16 of D3  D3----D0----D2

	tst.b d0
	beq tween16hlde_Done	;D0=0 ?
	
	movem.l d0,-(sp)
	pushhl
		exg d2,d3	
		jsr fraction16		;Fraction of D2
		exg d2,d3	
	pophl
	movem.l (sp)+,d0
	
	neg.b d0				;Amount of D3 to use
	add.b #16,d0
	
	jsr fraction16			;Fraction of D3
	add.l d2,d3
tween16hlde_Done:
	rts


fraction16:	;Return A3=A3*(D0/16) (Divide by 16, mutlt by D0)
	cmp.b #0,d0
	bne fraction16_Not0

	clr.l d3		;D0 = 0
fraction16_Done:
	rts
	
fraction16_Not0:	
	cmp.b #16,d0
	bcc fraction16_Done
	
	movem.l d2,-(sp)
		move.l d3,d2
		and.l #$0000FFFF,d2
		clr.l d3

		lsr.w #1,d2 ;1/2
		btst #3,d0
		beq fraction16_8
		add.l d2,d3
fraction16_8:

		lsr.w #1,d2 ;1/4
		btst #2,d0
		beq fraction16_4
		add.l d2,d3
fraction16_4:

		lsr.w #1,d2 ;1/8
		btst #1,d0
		beq fraction16_2
		add.l d2,d3
fraction16_2:

		lsr.w #1,d2 ;1/16
		btst #0,d0
		beq fraction16_1
		add.l d2,d3
fraction16_1:
	movem.l (sp)+,d2
	rts

	