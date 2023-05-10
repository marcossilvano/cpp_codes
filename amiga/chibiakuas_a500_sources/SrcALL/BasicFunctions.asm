CLDIR0:
	clr.l d0
CLDIR:
	move.l a3,a2
	move.b d0,(a2)+
LDIR:
LDIRAgain:
	move.b (a3)+,(a2)+
	subq.l #1,d1
	bne LDIRAgain
	rts
