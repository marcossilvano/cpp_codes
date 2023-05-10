;A	d0
;BC D1,D4	A1
;DE	D2,D5	A2
;HL D3,D6	A3

;IX			A4
;IY			A5

	macro PushBc
		moveM.l d1/d4/a1,-(sp)
		;move.l d1,-(sp)
		;move.l d4,-(sp)
	endm
	
	macro PopBc
		moveM.l (sp)+,d1/d4/a1
		;move.l (sp)+,d4
		;move.l (sp)+,d1
	endm
	
	macro PushDe
		moveM.l d2/d5/a2,-(sp)
		;move.l d2,-(sp)
		;move.l d5,-(sp)
	endm
	
	macro PopDe
		moveM.l (sp)+,d2/d5/a2
		;move.l (sp)+,d5
		;move.l (sp)+,d2
	endm
	
	macro PushHl
		moveM.l d3/d6/a3,-(sp)
		;move.l d3,-(sp)
		;move.l d6,-(sp)
		;move.l a3,-(sp)
	endm
	
	macro PopHl
		moveM.l (sp)+,d3/d6/a3
		;move.l (sp)+,a3
		;move.l (sp)+,d6
		;move.l (sp)+,d3
	endm
	
	macro PushIX
		moveM.l d6/a6,-(sp)
	endm
	
	macro PopIX
		moveM.l (sp)+,d6/a6
	endm
	
	
	macro PushIY
		moveM.l d6/a6,-(sp)
	endm
	
	macro PopIY
		moveM.l (sp)+,d6/a6
	endm
	
	
	macro PushAf
		move.l d0,-(sp)
		
	endm
	
	macro PopAf
		move.l (sp)+,d0
	endm
	
	
	macro PushAll
		moveM.l d0-d7/a0-a7,-(sp)
	endm
	macro PopAll
		moveM.l (sp)+,d0-d7/a0-a7
	endm