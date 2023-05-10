;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Random Number Generator (WORD)

doquickrandomword:
	move.l d6,-(sp)
	pushbc
	pushde
	
		move.w (randomseed),d1
		addq.w #1,d1
		move.w d1,(randomseed)
		and.l #$0000FFFF,d1
		jsr dorandomword
	
	popde
	popbc
	move.l (sp)+,d6
	rts

dorandomword:	;Return Random pair in D6,D3 from Seed D1
	clr.l d0
	move.l d1,d4
	and.l #$0000FF00,d4
	ror.l #8,d4
	jsr dorandombyte1			;Get 1st byte
	movem.l d0,-(sp)
		moveM.l d1/d4,-(sp)
			jsr dorandombyte2	;Get 2nd byte
		moveM.l (sp)+,d1/d4
		move.b d0,d6
	movem.l (sp)+,d3
	addq.w #1,d1
	rts
	
	
dorandombyte1:
	move.b d1,d0				;Get 1st seed
dorandombyte1b:
	ror.b #2,d0					;Rotate Right
	eor.b d1,d0					;Xor 1st Seed
	ror.b #2,d0					;Rotate Right
	eor.b d4,d0					;Xor 2nd Seed
	ror.b #1,d0					;Rotate Right
	eor.b #%10011101,d0			;Xor Constant
	eor.b d1,d0					;Xor 1st seed
	rts

dorandombyte2:
	move.l #randoms1,a3
	move.b d4,d0
	eor.b #%10101011,d0
	and.b #%00001111,d0			;Convert 2nd seed low nibble to Lookup
	and #$000000FF,d0
	add.l d0,a3
	move.b (a3),d2				;Get Byte from LUT 1

	jsr dorandombyte1
	and.b #%00001111,d0			;Convert random number from 
	move.l #randoms2,a3				;1st generator to Lookup
	and #$000000FF,d0
	add.l d0,a3
	move.b (a3),d0				;Get Byte from LUT2
	eor.b d2,d0					;Xor 1st lookup
	rts

	
dorandom:
	moveM.l d1-d6/a1-a3,-(sp)
		move.w (randomseed),d1
		addq.w #1,d1
		move.w d1,(randomseed)
		jsr dorandomword
		move.b d6,d0
		eor.b d3,d0
	moveM.l (sp)+,d1-d6/a1-a3
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dorangedrandomagain:
dorangedrandom:			;return d3 value between d1 and d2 (using mask d6)
	pushbc
		pushhl
			jsr doquickrandomword
		popbc
		;eor.w d1,d3
		and.w d6,d3
	popbc

	cmp.w d1,d3	
	bcs dorangedrandomagain

	cmp.w d2,d3
	bcc dorangedrandomagain
	and.l #$0000FFFF,d3
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


doxlineobj:	;object on horizontal plane

	move.l #8,d1
	move.l #screenwidth-8,d2	;full vertical range
	move.l #$1ff,d6				;ramdom mask

	jsr dorangedrandom			;return value between bc and de

	
	pushhl
		ifd screenwidth20
			move.l #0+32,d1
			move.l #screenheight-32,d2		;narrow horizontal range
		else
			move.l #0+64,d1
			move.l #screenheight-64,d2		;narrow horizontal range
		endif
		
		jsr dorangedrandom				;return value between bc and de

		exg d2,d3
	pophl

	jsr locate
	rts

	

doylineobj:						;object on vertical plane
	ifd screenwidth20
		move.l #0+32,d1

		move.l #screenwidth-32,d2	;narrow vertical range
	else
		move.l #0+64,d1

		move.l #screenwidth-64,d2	;narrow vertical range
	endif
	
	move.l #$1ff,d6			;ramdom mask

	jsr dorangedrandom		;return value between bc and de

	pushhl
		move.l #8,d1

		move.l #screenheight-8,d2	;full horizontal range

		jsr dorangedrandom		;return value between bc and de
		exg d2,d3
	pophl
	jsr locate
	rts


	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mainmenu:

	move.b #1,(level)			;reset game settings
	move.b #4,(lives)

	jsr cls
	
	jsr dotitlescreen		;show title

	jsr waitforfire

restart:

	jsr levelinit			;setup level
	jmp infloop

	
	
	
	
	
	
dotitlescreen:

	move.l #screenwidth/2,d3
	move.l #screenheight/2,d2
	jsr locate
	ifd screenwidth20
		move.b #0,(scale)
	else
		move.b #1,(scale)
	endif
	
	
	move.b #color2,(linecolor)

	move.l #vectitleb,a3		;title 3d depth
	jsr drawpacket

	move.l #vecball,a3		;ball torso
	jsr drawpacket

	move.l #vechands,a3		;ball hands
	jsr drawpacket

	move.l #veceyes,a3		;ball eyes
	jsr drawpacket

	move.l #vecmouth,a3		;ball mouth
	jsr drawpacket

	move.b #color3,(linecolor)

	move.l #vectitlef,a3
	jsr drawpacket

	move.b #color1,(linecolor)

	move.l #vectoung,a3
	jsr drawpacket

	ifd screenwidth20
		move.b #1,(scale)
	else
		move.b #2,(scale)

	endif
	
	move.l #vectitlezoom,a6		;speed lines of ball
	jsr drawcpacket
	

	move.b #color3,(linecolor)

	move.l #vectitlewall,a6
	jsr drawcpacket
	
 ;draw title text

	move.b #-1,(scale)
	move.b #color4,(linecolor)
	
;title split on small screen
	ifd screenwidth20
		move.l #24,d3		;Ypos
		move.l #8,d2		;Xpos
		jsr locate
	
		move.l #ttitle1,a3
		jsr printstring
		
		move.l #32,d3		;Ypos
		move.l #16,d2		;Xpos
		jsr locate
	
		move.l #ttitle2,a3
		jsr printstring
	else
		ifd screenwidth32
			move.l #15,d3
		else
			move.l #55,d3
		endif
			
		ifd ScreenHeight240
			move.l #75,d2
		else
			ifd ScreenHeight256
				move.l #85,d2
			else
				move.l #55,d2
			endif
		endif
		jsr locate

		move.l #ttitle,a3	;title message
		jsr printstring
	endif

	move.b #color1,(linecolor)
	
	move.b #-1,(scale)

	move.l #30,d3
	move.l #screenheight-16,d2
	jsr locate

	move.l #tbestlevel,a3
	jsr printstring			;'high score'

	move.b (bestlevel),d0
	jsr showdecimal
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;main level loop

levelinit:

	
	move.b (level),d0		;check current level
	and.b #%00000111,d0
	cmp.b #%00000111,d0
	bne noextralife

	addq.b #1,(lives)		;extra life every 8 levels
	
noextralife:

	ifd screenwidth20
		move.b #49*2+1,d0	;recharge boost power
	else
		move.b #99*2+1,d0
	endif
	
	move.b d0,(boostpower)

	move.b (level),d1		;calculate cpu ai

	asr.b #2,d1				;/4
	
	move.b #7,d0			;stupid=7 smart=0
	sub.b d1,d0
	bcc cpuaiok
		clr.b d0
cpuaiok:
	move.b d0,(cpuai)

	move.l #userrambak,a3	;reset level settings 
	move.l #userram,a2
	move.l #userrambakend-userrambak,d1

	jsr ldir 
	
;draw new level objects

	jsr cls			;clear screen

	move.b (level),d6	;calculate no of pairs of objects

	add.b #4,d6			;4 pair min
	move.b #10,d7		;max 10 pairs of square objects

	ifd screenwidth20
		move.b #0,(scale)
	else
		move.b #1,(scale)
	endif

	move.b #color4,(linecolor)

moreobject1:

	pushix
		jsr doxlineobj

		move.l #object1,a6		;square object h
		jsr drawcpacket

		jsr doylineobj

		move.l #object1,a6		;square object v
		jsr drawcpacket
	popix

	subq.b #1,d7
	beq doobject2		;10 obj pair limit for squares

	subq.b #1,d6
	bne moreobject1		;decrease obj count


	

doobject2:				;remainder are hollow objects
	tst.b d6
	beq objectsdone

moreobject2:
	pushix
		jsr doxlineobj
		
		move.l #object2,a6		;hollow object h
		jsr drawcpacket

		jsr doylineobj

		move.l #object2,a6		;hollow object v
		jsr drawcpacket
	popix

	subq.b #1,d6
	bne moreobject2

objectsdone:
	move.b #color1,(linecolor)

;draw screen borders

	move.w #screenwidth-1,d2

hlineagain:
	move.l #0,d3
	move.b #color1,d0
	jsr psethlde	;de=xpos hl=ypos a=color

	move.b #screenheight-1,d3
	move.b #color1,d0
	jsr psethlde	;de=xpos hl=ypos a=color

	subq.w #1,d2
	bne hlineagain

	move.l #screenheight-1,d3	;Ypos

vlineagain:
	move.l #0,d2	;Xpos

	move.b #color1,d0

	jsr psethlde	;d2=xpos d3=ypos d0=color

	move.l #screenwidth-1,d2

	move.b #color1,d0

	jsr psethlde	;d2=xpos d3=ypos d0=color

	subq.b #1,d3
	bne vlineagain

	ifd screenwidth20
		move.l #-1,d0
	else
		move.l #0,d0
	endif

	move.b d0,(scale)

	move.l #-4,d3			

	ifd screenwidth20
		move.l #4,d2
	else
		move.l #10,d2
	endif

	jsr locate

	move.b (lives),d0	;lives = topleft

	jsr showdecimal

	ifd screenwidth20
		move.l #screenwidth-19,d3
		move.l #screenheight-8,d2
	else
		move.l #screenwidth-38,d3
		move.l #screenheight-16,d2
	endif

	jsr locate

	move.b (level),d0	;level= bottomright

	jsr showdecimal

	ifd screenwidth20
		move.l #screenwidth-19,d3
		move.l #4,d2
	else
		move.l #screenwidth-38,d3
		move.l #10,d2
	endif

	jsr locate

	move.b (cpuai),d0		;ai=topright
	jsr showdecimal

	move.b (boostpower),d0
	jsr showboostpower		;boost=bottomleft

;draw corners around text

	ifd screenwidth20
		move.l #0,d6
		move.l #12,d7
		move.l #16,d3
		move.l #12,d2

	else
		move.l #0,d6
		move.l #24,d7
		move.l #32,d3
		move.l #24,d2
	endif
	
	jsr drawline	;start=ix,iy... dest hl,de=yoffset 

	move.l #0,d3

	ifd screenwidth20
		move.l #-12,d2
	else
		move.l #-24,d2
	endif

	jsr drawlinerelative

	ifd screenwidth20

		move.l #screenwidth-17,d6
		move.l #screenheight-1,d7
		move.l #screenwidth-17,d3
		move.l #screenheight-13,d2
	else
		move.l #screenwidth-33,d6
		move.l #screenheight-1,d7
		move.l #screenwidth-33,d3
		move.l #screenheight-25,d2
	endif
	
	

	jsr drawline	;start=d6,d7... dest d3,d2=yoffset 

	ifd screenwidth20
		move.l #16,d3
	else
		move.l #32,d3
	endif
	move.l #0,d2
	jsr drawlinerelative

	ifd screenwidth20
		move.l #16,d6
		move.l #screenheight-1,d7
		move.l #16,d3
		move.l #screenheight-13,d2
	else
		move.l #32,d6
		move.l #screenheight-1,d7
		move.l #32,d3
		move.l #screenheight-25,d2
	endif

	jsr drawline	;start=d6,d7... dest d3,d2=yoffset 

	ifd screenwidth20
		move.l #-16,d3
	else
		move.l #-32,d3
	endif

	move.l #0,d2

	jsr drawlinerelative

	ifd screenwidth20
		move.l #screenwidth-17,d6
		move.l #0,d7
		move.l #screenwidth-17,d3
		move.l #12,d2
	else
		move.l #screenwidth-33,d6
		move.l #0,d7
		move.l #screenwidth-33,d3
		move.l #24,d2

	endif

	jsr drawline		;start=ix,iy... dest hl,de=yoffset 

	ifd screenwidth20
		move.l #16,d3
	else
		move.l #32,d3
	endif
	move.l #0,d2
	jsr drawlinerelative

	rts

psethlde:	;d2=xpos d3=ypos d0=color
	pushhl
	pushbc
	pushde			
		move.l d3,d4

		move.l d2,d1
		move.l d0,d2

		jsr pset	;D1=X D4=Y	D2=Color
	popde
	popbc
	pophl
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                                     

showboostpower:
	movem.l d0,-(sp)
	move.w #-4,d3
	ifd screenwidth20
		move.w #screenheight-6,d2
	else
		move.w #screenheight-16,d2
	endif

	jsr locate

	movem.l (sp)+,d0

	lsr.b #1,d0			;halve boost
	jsr showdecimal
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gameover:
	jsr cls

	ifd screenwidth20
		move.b #0,(scale)
	else
		move.b #1,(scale)
	endif

	move.b #color1,(linecolor)

	ifd screenwidth40				;xpos
		move.l #50,d3
	else
		move.l #20,d3
	endif
	move.l #screenheight/2-20,d2		;ypos
	jsr locate

	move.l #tgameover,a3

	jsr printstring			;show gameover message
	ifd screenwidth20
		move.b #-1,d0
	else

		move.b #0,d0
	endif
		move.b d0,(scale)

	move.b (level),d0

	cmp.b (bestlevel),d0		;beat best level?
	bcs majorsuckage
	beq majorsuckage

newbest:						;yes? update best!
	move.b d0,(bestlevel)

	move.b #color3,(linecolor)

	ifd screenwidth40			;xpos
		move.l #40,d3
	else
		move.l #10,d3
	endif
	move.l #screenheight/2+20,d2		;ypos

	jsr locate

	move.l #tyourock,a3			;new highscore message

	jsr printstring
	bra waitrestart

majorsuckage:

	move.b #color2,(linecolor)

	ifd screenwidth40
		move.l #20,d3
	else
		move.l #0,d3
	endif
	move.l #screenheight/2+20,d2
	jsr locate

	move.l #tyousuck,a3			;no highscore message
	jsr printstring

waitrestart:
	jsr waitforfire

	jmp mainmenu				;new game

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

handleplayer:
	tst.b (boost)				;player using boost?
	bne noboost
	tst.b (boostpower)			;Boostpower remaining?
	beq noboost
	
	move.b (boostpower),d5
	and.b #%11111110,d5			;we only show boostpower/2 

	move.b (shownboostpower),d0
	and.b #%11111110,d0
	cmp.b d5,d0
	beq boostpowersame

	clr.b (linecolor)			;clear old boost power
	move.b (shownboostpower),d0
	jsr showboostpower

	subq.b #1,(boostpower)		;decrease boost power

	move.b #color1,(linecolor)

	move.b (boostpower),d0
	move.b d0,(shownboostpower)

	jsr showboostpower			;show new boost power

	bra noboost

boostpowersame:

	subq.b #1,(boostpower)		;decrease boost power

noboost:
	move.b (tick),d0			;no boost=move every other tick
	and.b (boost),d0			;boost=move every tick

	bne notplayertick

	move.w (playerx),d1			;move player x
	add.w (playerxacc),d1
	move.w d1,(playerx)

	move.w (playery),d4			;move player y
	add.w (playeryacc),d4
	move.w d4,(playery)

	pushbc
		jsr point				;has player collided?
		tst.b d0
		beq nothit

		subq.b #1,(lives)		;yes! depleat lives

		bne restart

		jmp gameover		;no lives left - player dead
		
nothit:
	popbc

	move.b #color2,d2		;draw player to screen
	
	jsr Pset 		;D1=X D4=Y	D2=Color

notplayertick:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setplayerdirection:		;rotate player in response to keypress
	pushhl
	pushix
	pushbc
	pushde
		move.w (a3),d1
		and.l #%00000011,d1		;wrap around 4 directions
		move.w d1,(a3)
		
		asl.l #2,d1				;4 bytes per direction

		move.l #directions,a3
		
		add.l d1,a3			;Source
		move.l #4,d1		;Bytes 
		move.l a6,a2		;Destination

		jsr ldir 			;Copy 4 bytes to player/cpu acceleration
	popde
	popbc
	popix
	pophl
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

handlecpu:								;computer playrt	

	move.B (tick),d0
	cmp.b #1,d0
	bne nocputick			;move every other other tick

	move.w (cpuxacc),D1
	move.w (cpux),D3
	add.w d1,d3
	jsr applyai				;look ahead for cpu responses

	move.l d3,d6			;store xpos for later

	exg d2,d3

	move.w (cpuyacc),d1
	move.w (cpuy),d3
	add.w d1,d3
	jsr applyai				;look ahead for cpu responses

	move.l d3,d7			;store ypos for later

	move.w d2,d1
	move.w d3,d4
	jsr point				;test cpu pos (for ai)

	tst.b d0
	beq notmovecpu			;cpu not about to collide

	jsr dorandom			;change cpu turn direction?

	cmp.b #240,d0

	bcs cpudirectionok

	neg.w (cputurn)			;flip rotation direction
	
cpudirectionok:
	move.b #3,d1			;find a direction we can turn.

nextcputest:

	move.w (cpudirection),d0
	add.w (cputurn),d0		;rotate once		
	and.w #%00000011,d0
	move.w d0,(cpudirection)

	cmp.b #2,d1		;facing opposited direction?

	beq testskip

	pushbc
		clr.l d1
		move.w (cpudirection),d1

		asl.l #2,d1
		pushix
			move.l #directions,a6	;get cpu direction
			add.l d1,a6
			move.w (2,a6),d3		;Ypos

			move.w (0,a6),d2		;Xpos
		popix
	jsr  cputest 	;d3=yacc ;d2=xacc - test direction
	popbc
	tst.b d0						;found a move
	beq foundcpumove
	
testskip:
	subq.b #1,d1					;repeat check
	bne nextcputest	

foundcpumove:
notmovecpu:
	move.w (cpux),d2				;update up x
	add.w (cpuxacc),d2
	move.w d2,(cpux)

	move.w (cpuy),d3				;update up y
	add.w (cpuyacc),d3
	move.w d3,(cpuy)

	move.w d2,d1
	move.w d3,d4
	movem.l d0,-(sp)
	pushbc
		jsr point				;check cpu position
		tst.b d0
		beq nothitcpu
		addq.b #1,(level)		;cpu dead - next level!
		jmp restart

nothitcpu:
	popbc
	movem.l (sp)+,d0
	move.b #color3,d2

	jsr pset					;draw cpu to screen

nocputick:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

applyai:						;look ahead level
	;lower=tighter reactions (better)
	
	move.b (cpuai),d0
	bne lbl35417
	rts
lbl35417

applyaiagain:
	add.w d1,d3			;shift cpu check pixel by 1 unit
	subq.b #1,d0
	bne applyaiagain
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;hl=yacc ;de=xacc	- test a possible turn
cputest:
	move.w d3,(cpuyacc)
	move.w d2,(cpuxacc)			;store the tested rotation
	pushhl
	pushde

		add.w d6,d2		;add x-offset
		add.l d7,d3		;add y-offset

		move.w d2,d1
		move.w d3,d4

		jsr point		;test point
	popde
	pophl
	tst.b d0
	bne lbl17898
	move.b #0,d0		;nocollide (=0)
	rts
lbl17898
	move.b #1,d0		;collide (!=0)
	rts
	
