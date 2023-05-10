;                                     showdecimal:
showdecimal:
;                                     drawtext_decimal:	;draw a 3 digit decimal number (non-bcd)
drawtext_decimal:
;                                     	ld hl,&640a
	move.l #$64,d3
	move.l #$0a,d6
;                                     	ld b,a		
	move.b d0,d1
;                                     	

;                                     	cp h
	cmp.b d3,d0
;                                     	jr nc,decthreedigit
	bcc decthreedigit
;                                     	

;                                     	call printspace
	jsr printspace
;                                     	cp l 
	cmp.b d6,d0
;                                     	jr nc,skipdigit100
	bcc skipdigit100
;                                     	call printspace
	jsr printspace
;                                     	jr skipdigit10
	bra skipdigit10
;                                     	

;                                     decthreedigit:
decthreedigit:
;                                     

;                                     	call drawtextdecimalsub
	jsr drawtextdecimalsub
;                                     skipdigit100:
skipdigit100:
;                                     	ld h,l
	move.l d6,d3
;                                     	call drawtextdecimalsub
	jsr drawtextdecimalsub
;                                     

;                                     skipdigit10:
skipdigit10:
;                                     	ld a,b
	move.b d1,d0
;                                     drawtext_charsprite48:
drawtext_charsprite48:
;                                     	add 48
	add.b #48,d0
;                                     drawtext_charspriteprotectbc:
drawtext_charspriteprotectbc:
;                                     	jp printchar; draw char
	jmp printchar
;                                     

;                                     drawtextdecimalsub:
drawtextdecimalsub:
;                                     	ld a,b
	move.b d1,d0
;                                     	ld c,0
	move.l #0,d4
;                                     drawtext_decimalsubagain:
drawtext_decimalsubagain:
;                                     	cp h
	cmp.b d3,d0
;                                     	jr c,drawtext_decimallessthan	;devide by 100
	bcs drawtext_decimallessthan
;                                     	inc c
	addq.l #1,d4
;                                     	sub h
	sub.b d3,d0
;                                     	jr drawtext_decimalsubagain
	jmp drawtext_decimalsubagain
;                                     drawtext_decimallessthan:
drawtext_decimallessthan:
;                                     	ld b,a
	move.b d0,d1
;                                     	ld a,c
	move.b d4,d0
;                                     	or a		;we're going to do a compare as soon as we return
	;nop
;                                     	jr drawtext_charsprite48
	bra drawtext_charsprite48
;                                     	

;                                     

