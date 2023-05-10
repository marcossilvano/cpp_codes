
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Draw Line
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;start=ix (d6),iy (D7)... dest hl (D3),de (D2) =yoffset 

drawline:
	and.l #$0000FFFF,d3		;X
	and.l #$000000FF,d2		;Y
	and.l #$0000FFFF,d6		;X
	and.l #$000000FF,d7		;Y

	move.l d6,d1			;source x
	move.l d1,d0
	rol.l #8,d0
	move.l d0,(xpos24)
	sub.l d1,d3				;calculate difference x

	move.l d7,d1
	move.l d1,d0
	rol.l #8,d0
	move.l d0,(ypos24)		;dest y
	sub.w d1,d2				;calculate difference y

	;D3 hl=xoffset D2 de=yoffset 
drawlinerelative:
	and.l #$0000FFFF,d3
	and.l #$000000FF,d2
	ext.l d3
	ext.w d2

	move.w d3,d0
	or.w d2,d0
	bne drawlinerelativeok

	addq.w #1,d2			;draw at least 1 dot
	addq.w #1,d3

drawlinerelativeok:

	move.l #xposdir,a6		;xy flip markers
	move.b #0,(a6)

	btst #15,d3
	beq lbl49867
	jsr fliphl				;xpos is negative
lbl49867

	move.l #yposdir,a6
	clr.b (a6)
	btst #15,d2
	beq noflipde
		exg d3,d2
		jsr fliphl			;Ypos is negative
		exg d3,d2
noflipde:
	sub.w d2,d3
	bcc hlbigger			;X length > Ylength
	add.w d2,d3
	pushde
		rol.w #8,d3
		and.l #$FF00,d3
		
		move.b d2,d0
		and.l #$FF,d0
		divu d0,d3			
		and.l #$FFFF,d3
	popbc
	move.l #$0100,d2
	bra debigger			;1 Vpixel per draw

hlbigger:
	add.w d2,d3
	pushhl
			rol.w #8,d2
			and.l #$FF00,d2
		
			move.b d3,d0
			and.l #$FF,d0
			divu d0,d2
			and.l #$FFFF,d2
	popbc
	move.l #$0100,d3		;1 Hpixel per draw


debigger:
	and.l #$00FF,d1
	move.w d2,d7
	move.w d3,d6

lineagain:
	pushbc
		move.l (xpos24),d1
		ror.l #8,d1
		and.l #$FFF,d1
		
		move.l (ypos24),d4
		ror.l #8,d4
		and.l #$FF,d4

		move.b (linecolor),d2
		
		jsr pset
		
		move.w d6,d2					;Xmove
		move.l #xposdir,a3
		jsr add24
		
		move.w d7,d2					;Ymove
		jsr add24

	popbc
	subq.w #1,d1
	bne lineagain
	rts

;;;;;;;;;;;;;;;;;;

FlipHL:
	addq.b #1,(a6)		;Direction marker
	neg.l d3
	rts
	
;;;;;;;;;;;;;;;;;;

Add24:	;ADD DE to (HL) 24 bit UHL Little Endian (DLHU)
	and.l #$0000FFFF,d2

	cmp.b #0,(a3)
	bne Sub24		;Negative marker
		
	addq.l #2,a3	;skip marker
	
	
	move.l (a3),d0
	add.l d2,d0
	move.l d0,(a3)
	
	addq.l #4,a3
	rts
Sub24:				
	addq.l #2,a3	;skip marker

	ext.l d2		;Sign Extend DE
	
	move.l (a3),d0
	sub.l d2,d0
	move.l d0,(a3)
	
	addq.l #4,a3
	rts
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Font Driver
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
PrintString:
	move.b (a3)+,d0			;Read a character in from A3
	cmp.b #255,d0
	beq PrintString_Done	;return on 255
	jsr PrintChar			;Print the Character
	bra PrintString
PrintString_Done:		
	rts

	
printcharnum:
	sub.b #'!',d0
	move.l #vnumset,a3
	bra printcharactersb

printspace:
	move.b #' ',d0

printchar:					;Print Char DE
	
	and.l #$000000FF,d0
	movem.l d0,-(sp)
	pushbc
	pushde
	pushhl
		cmp.b #' ',d0
		beq printcharspace
		cmp.b #':'+1,d0

		bcs printcharnum	;numbers and symbols

		and.l #%11011111,d0	;convert lower-> upper
		sub.l #'A',d0
		move.l #vcharset,a3

		
		
printcharactersb:

		asl.l #2,d0			;2 bytes per address
	
		add.l d0,a3			;get address of cpacket for char
		
		
		ifd BuildSQL
			
			
								;Because we don't know the run address.
			move.l (a3),a6
			lea ProgramStart,a3
			add.l a3,a6		;load font address (Relative for Sinclair QL)
			
		else
			
			move.l (a3),a6
		endif
		jsr drawcpacket		;draw it

printcharspaceb:

		move.l #12,d4		;Size of char gap
		jsr doscale
		add.l d4,d3
		move.l d3,(xpos24)	;move to next char
	pophl
	popde
	popbc
	movem.l (sp)+,d0
	rts

printcharspace:				;print a space
	move.l (xpos24),d3
	bra printcharspaceb		;move right 1 char

locate:			;(d3,d2) = (x,y)
	asl.l #8,d3
	asl.l #8,d2
	move.l d3,(xpos24)		;postition drawing cursor
	move.l d2,(ypos24)

	clr.b (xpos24+3)
	clr.b (ypos24+3)	;set low byte of xy to zero
	jmp zerolow24byte

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Draw Vectrex Packet format A3

;	$CC,$YY,$XX ... CC 00=Move FF=Line 01=Done
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawpacket:
	move.l (xpos24),d2		;Back up XY Pos
	pushde
	move.l (ypos24),d2
	pushde
	
vtxagain:
	move.b (a3)+,d0			;check command
	beq vtxmove				;$00 = move 
	addq.b #1,d0			;$ff = draw line
	beq vtxline
	cmp.b #2,d0				;$01 = line done
	beq vtxdone				;update pos & return

vtxline:
	move.b (a3)+,d4			;get ypos
	neg.b d4				;Flip Y Axis
	jsr sexbc				;Sign extend
	move.l d4,d2
	
	move.b (a3)+,d4			;get xpos
	jsr sexbc				;Sign extend
	
	pushhl
		move.l d4,d3
		
		lsr.l #8,d3			;Remove bottom byte (Fraction)
		lsr.l #8,d2
		
		jsr drawlinerelative	;a3=xoffset a2=yoffset 
	pophl
	bra vtxagain

vtxmove:
	move.b (a3)+,d4			;ypos
	neg.b d4
	jsr sexbc
	add.l d4,(ypos24)

	move.b (a3)+,d4			;Xpos
	jsr sexbc
	add.l d4,(xpos24)
			
	bra vtxagain

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Draw CPacket format A6 - (7 bit per axis - 2 command bits)
;	%CYYYYYYY,%DXXXXXXX ... %CD %?0=Move %?1=Line %1?=End
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawcpacket:		;A6=Source data

	move.l (xpos24),d3		;back up X/Y pos
	pushhl
	move.l (ypos24),d3
	pushhl

	bra drawcpacketstart

drawcpacketagain:
	addq.l #2,a6			;move to next cmd

drawcpacketstart:			;cmd check

	btst.b #7,(1,a6)		;%cd=%?0 = move type

	beq cpacketmove

cpacketline:				;%cd=%?1 = line type

	move.b (0,a6),d4		;Y-pos
	neg.b d4
	jsr sexbc7bit			;Sign Extend
	move.l d4,d2
	
	move.b (1,a6),d4		;X-pos
	jsr sexbc7bit			;Sign Extend

	pushix
		move.l d4,d3

		lsr.l #8,d3			;Remove bottom byte (Fraction)
		lsr.l #8,d2
		jsr drawlinerelative ;hl=xoffset de=yoffset 
	popix

	btst #7,(a6)			;%cd=%1? = drawing done
	beq drawcpacketagain

vtxdone:
	pophl					;restore XY pos
	move.l d3,(ypos24)
	pophl
	move.l d3,(xpos24)

zerolow24byte:

	clr.b (xpos24+3)		;Clear low byte of 24 bit xy
	clr.b (ypos24+3)
	rts

cpacketmove:
	move.b (0,a6),d4		;get ypos
	neg.b d4				;Flip Y Axis
	jsr sexbc7bit			;Sign Extend
	add.l d4,(ypos24)		;move ypos

	move.b (1,a6),d4		;get xpos

	jsr sexbc7bit			;Sign Extend
	add.l d4,(xpos24)

	jmp drawcpacketagain	;back to start of cpacket processor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


sexbc7bit:		;sign extend 7bit D4-> 16 bit
	bclr #7,d4
	btst #6,d4
	beq sexbc
	bset #7,d4
sexbc:			;sign extend 8bit c-> bc
	and.l #$000000FF,d4
	
	btst #7,d4
	beq doscale				;Check sign bit
	
	or.l  #$FFFFFF00,d4		;Negative - so fill unused bits

doscale:
	move.b (scale),d0

doscaleagain:
	cmp.b #0,d0
	bne lbl5496
ScaleDone:
		asl.l #8,d4		
	rts
lbl5496
	cmp.b #128,d0			;-1 = 1/2 ... -2 =1/4 etc
	bcc scalenegative

scalepositive:				;>0 x2 x4 x8
	asl.l #1,d4
	subq.b #1,d0
	bra doscaleagain

scalenegative:				;<0 /2 /4 /8
	asr.l #1,d4
	addq.b #1,d0
	bra doscaleagain
	
	
