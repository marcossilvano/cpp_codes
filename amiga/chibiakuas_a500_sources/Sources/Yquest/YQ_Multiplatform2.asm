
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


dorangedrandom:			;return a value between d1 and d4
	jsr dorandom
	cmp.b d1,d0
	bcs dorangedrandom
	cmp.b d4,d0
	bcc dorangedrandom
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


randomxpos:				;pick a random horizontal location
	move.b #$02,d1				;Min
	move.b #screenobjwidth,d4	;Max
	jsr dorangedrandom
	move.b d0,(o_xpos,a4)
	rts

randomypos:				;pick a random vertical position
	move.b #$08,d1
	move.b #screenobjheight,d4	;Min
	jsr dorangedrandom			;Max
	move.b d0,(o_ypos,a4)
	rts

randomizeobjectposition:;randomize location of object (both)
	moveM.l d1/d4,-(sp)
		jsr randomxpos
		jsr randomypos
	moveM.l (sp)+,d1/d4
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



randomizeedgeobjectposition:		;put an enemy at the edge of the screen
	
	moveM.l d1/d4,-(sp)
		jsr dorandom
		and.b #%00000011,d0
		beq randomtop
		cmp.b #1,d0
		beq randombottom
		cmp.b #2,d0
		beq randomleft
		cmp.b #3,d0
		beq randomright
	
randomtop:
		jsr randomxpos
		move.b #8,(o_ypos,a4)				;put enemy at top of screen
		bra randomizeedge

randombottom:
		jsr randomxpos
		move.b #screenobjheight-8,(o_ypos,a4)	;put enemy at bottom of screen
		bra randomizeedge
randomleft:
		jsr randomypos
		move.b #4,(o_xpos,a4)				;put enemy on left of screen
		bra randomizeedge
randomright:
		jsr randomypos
		move.b #screenobjwidth-6,(o_xpos,a4) ;put enemy on right of screen
randomizeedge:
	moveM.l (sp)+,d1/d4
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

;randomly position an object ix without colliding with any other objects 
;test a4 objects

saferandomizeobjectposition:
	move.l a5,-(sp)
nextobjectinitrerandomize:
		moveM.l d1/d4,-(sp)
			jsr randomizeobjectposition	;select a new position
		
			lea objectarray,a5		;we need to check if an object is colliding				
nextobjectinittextnext:			
			cmp.l a4,a5				;don't compare object to itself!
			beq checknextobject		;comparing an object to itself!		

			moveM.l d1/d4,-(sp)
				move.b (o_xpos,a4),d2
				move.b (o_ypos,a4),d5
		
				move.b (o_xpos,a5),d1
				move.b (o_ypos,a5),d4
		
				jsr rangetestw
			moveM.l (sp)+,d1/d4
			bcs nextobjectinitrerandomize2
checknextobject:
			add.l #objectbytesize,a5
			subq.l #1,d4

			bne nextobjectinittextnext
		moveM.l (sp)+,d1/d4
	move.l (sp)+,a5
	rts

nextobjectinitrerandomize2:	
	moveM.l (sp)+,d1/d4				;reset enemy count and restart
	bra nextobjectinitrerandomize


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


rangetestw:				;object range check
	moveM.l d1/d4/d3/d6,-(sp)
		move.b #5,d3
		move.b #10,d6
		bra rangetest2

rangetest:				;bullet range check
	moveM.l d1/d4/d3/d6,-(sp)
		move.b #3,d3
		move.b #6,d6
rangetest2:				;see if object xy pos de hits object bc (with radius hl)
		move.b d1,d0
		sub.b d3,d0
		bcs rangetestb
		cmp.b d2,d0
		bcc rangetestoutofrange
rangetestb:
		add.b d3,d0
		add.b d3,d0
		bcs rangetestd
		cmp.b d2,d0
		bcs rangetestoutofrange
rangetestd:
		move.b d4,d0
		sub.b d6,d0
		bcs rangetestc
		cmp.b d5,d0
		bcc rangetestoutofrange
rangetestc:
	
		add.b d6,d0
		add.b d6,d0
		bcs rangeteste
		cmp.b d5,d0
		bcs rangetestoutofrange
rangeteste:
		or #$01,CCR				;Carry Set=Collided
	moveM.l (sp)+,d1/d4/d3/d6
	rts

rangetestoutofrange:
		and #$FE,CCR				;CC=No Collision
	moveM.l (sp)+,d1/d4/d3/d6
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Locate:
	move.w d3,(CursorX)		;Set XY from D3 $XXYY
	rts
LocateXY:
	move.b d3,(CursorX)
	move.b d6,(CursorY)
	rts

PrintString:
	move.b (a3)+,d0			;Read a character in from A3
	cmp.b #255,d0
	beq PrintString_Done	;return on 255
	jsr PrintChar			;Pritn the Character
	bra PrintString
PrintString_Done:		
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawui:
	move.b (SpriteFrame),d0
	addq.b #1,d0
	and.b #%00000011,d0				;4 frames of animation!
	move.b d0,(SpriteFrame)
	move.l #$0000,d3
	jsr locate
	lea txtlives,a3					;show lives
	jsr printstring
	move.b (lives),d0
	add.b #'0',d0
	jsr printchar

	ifd screenwidth20
		move.l #screenwidth-5,d3
	else
		move.l #screenwidth-12,d3
	endif
	move.l #0,d6
	jsr locateXY
	move.l #txtcrystals,a3
	jsr printstring					;show crystals
	move.b (crystals),d0
	jsr showdecimal
	ifd screenwidth20
		move.l #screenwidth-5,d3
	else
		move.l #screenwidth-10,d3
	endif
	move.l #screenheight-1,d6
	jsr locateXY
	move.l #txtlevel,a3
	jsr printstring					;show level
	move.b (level),d0
	addq.l #1,d0
	jsr showdecimal

	move.l #$00,d3
	move.l #screenheight-1,d6
	jsr locateXY
	move.l #txtscore,a3
	jsr printstring			
	lea Score,a0					;Show the highscore
    move.l #3,d1
    jsr BCD_Show                                      
	rts
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



levelinit:				;define the new level data
	lea levelmap,a3

	move.b (level),d0
	and.l #%00001111,d0		;levels cycle after 16 levels

	asl.l #2,d0				;4 bytes per pointer
	add.l d0,a3
	
	ifd BuildSQL
		lea ProgramStart,a5
		add.l (a3),a5		;load levelmap address (Relative for Sinclair QL)
							;Because we don't know the run address.
	else
		move.l (a3),a5		;load levelmap address
	endif
	
	move.b (a5)+,d0

	move.b d0,(crystals)	;get crystal count from levelmap
	addq.l #1,a5			;Skip unused byte
	
	move.l #enemies,d1		;populate enemies
	lea objectarray,a4

nextobjecttype:

	move.l a5,-(sp)
		clr.l d2

		move.b (1,a5),d2						;enemy count
		addq.b #1,d2
	
		moveM.l d2/d5/a2,-(sp)
			clr.l d0
			move.b (0,a5),d0	;enemy number
			asl.l #3,d0			;8 bytes per object def
			
			lea enemydefinitions,a5
			add.l d0,a5			;get enemy definition offset
		moveM.l (sp)+,d2/d5/a2

	
nextobjectinitloop:

		subq.b #1,d2
	
		beq lastobject			;last object of this type?
	
		moveM.l d1/d4/d2/d5,-(sp)
	
			;fill settings from enemy def
			move.b (d_sprnum,a5),(o_sprnum,a4)
			move.b (d_collprog,a5),(o_collprog,a4)
			move.b (d_program,a5),(o_program,a4)
			move.b (d_xacc,a5),(o_xacc,a4)
			move.b (d_yacc,a5),(o_yacc,a4)
		
			move.l a5,-(sp)
				jsr randomizeobjectposition	;position object
			
				move.b d5,d0
				sub.b d1,d0
				beq testnextobposok			;don't check 1st object
				
				move.b d0,d4
				jsr saferandomizeobjectposition	;check if object collides with existing
testnextobposok:
				add.l #objectbytesize,a4	;move to next object
			move.l (sp)+,a5
		moveM.l (sp)+,d1/d4/d2/d5
		subq.l #1,d1
		bne nextobjectinitloop				;do next object

	move.l (sp)+,a5

	lea bulletarray,a3		;clear bullet array
	move.b #255,d0			;unused bullet
	move.l #bulletcount*objectbytesize*2,d1	 ;bulletarray+enemybulletarray

	jsr cldir 			;Fill D1 bytes from A3 with D0
	rts


lastobject:
	move.l (sp)+,a5
		addq.l #2,a5
	jmp nextobjecttype


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

resetplayer:

	move.b #48,(invincibility)		;set invincibility time

	clr.b (playingsfx)			;silence sound

	move.l #playerobjectbak,a3		;default player state
	move.l #playerobject,a2			;current player state
	move.l #objectbytesize,d1
	jsr ldir 						;reset player params
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

drawplayer:
	lea playerobject,a4
	move.b (invincibility),d0		;flash player if invincible
	beq invok	
	subq.b #1,d0
	move.b d0,(invincibility)
invok:
	and.b #%00000010,d0
	bne drawplayer_DontShow
	jsr drawobject					;draw player sprite
drawplayer_DontShow:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drawandmove:				;handle player and enemies
	move.l #bulletcount,d1
	lea bulletarray,a4		;do player bullets
nextbulletdrawloop:
	moveM.l d1/d4,-(sp)
		jsr blanksprite
		jsr drawobject
		add.l #objectbytesize,a4
	moveM.l (sp)+,d1/d4
	subq.b #1,d1
	bne nextbulletdrawloop

	jsr drawplayer			;show player
	
;Do Player Bullets
	move.l #bulletcount,d1
	lea bulletarray,a4
nextbulletloop:

	moveM.l d1/d4/a1,-(sp)
		move.b (o_collprog,a4),d0
		cmp.b #250,d0
		bcc enemynotest		;bullet left screen?

		move.l #enemies,d4	;collision detection of bullet and enemy
		lea objectarray,a5
enemycollideloop:
		moveM.l d1/d4/a1,-(sp)
			move.b (o_collprog,a5),d0
			cmp.b #1,d0
			beq enemynocollide		;shot crystal
			cmp.b #250,d0
			bcc enemynocollide		;shot dead/uninitialized object
			move.b (o_sprnum,a5),d0
			cmp.b #4,d0
			beq enemynocollide		;shot mine
		
			move.b (o_xpos,a4),d2	;bullet xy
			move.b (o_ypos,a4),d5
		
			move.b (o_xpos,a5),d1	;enemy xy
			move.b (o_ypos,a5),d4
		
			jsr rangetest			;return CS if collided limit
			bcc enemynocollide
		
			move.l #bcd5,a1
			jsr applyscore			;player has shot enemy
		
				move.l a4,-(sp)
					move.l a5,a4
					jsr blanksprite ;remove sprite from screen
				move.l (sp)+,a4
				move.b #254,(o_collprog,a5)		;dead enemy
			move.l #%11011111,d0
			move.b d0,(playingsfx)
enemynocollide:
			add.l #objectbytesize,a5;move to next enemy
		moveM.l (sp)+,d1/d4/a1
		subq.l #1,d4
		bne enemycollideloop
	
enemynotest:		;move to the next bullet	
		add.l  #objectbytesize,a4
	moveM.l (sp)+,d1/d4/a1

	subq.b #1,d1
	bne nextbulletloop

	move.l #enemies,d1
	lea objectarray,a4

nextobjectloop:
	moveM.l d1/d4/a1,-(sp)
		move.b (o_xacc,a4),d0
		or.b (o_yacc,a4),d0
	
		beq lbl6842
		jsr blanksprite				;only blank sprite if accel!=0
lbl6842:
		jsr drawobject				;draw enemy	
		jsr objectcollision			;see if player collided
	
		move.b (o_collprog,a4),d0
		cmp.b #254,d0				;254=killed enemy
		bne objectnotdead
	
		jsr dorandom
	
		and.b #%00111111,d0
	
		bne objectnotdead
		move.b #0,(o_collprog,a4)	;respawn enemy
		jsr randomizeedgeobjectposition
		move.l #%01000011,d0
		move.b d0,(playingsfx)
objectnotdead:
		add.l #objectbytesize,a4
	moveM.l (sp)+,d1/d4/a1

	subq.b #1,d1
	bne nextobjectloop

	move.l #bulletcount,d1
	lea enemybulletarray,a4
nextenemybulletloop:
	moveM.l d1/d4/a1,-(sp)
		move.b (o_collprog,a4),d0
		cmp.b #250,d0
		bcc bulletplayernocollide	;bullet left screen?
	
		jsr blanksprite
	
		jsr drawobject
	
		move.b (o_xpos,a4),d2		;collision detection
	
		ifd collisionmaskx
			and.b #collisionmaskx,d2	;strip a few bits (for tile systems)
		endif
		
		move.b (o_ypos,a4),d5
		ifd collisionmasky
			and.b #collisionmasky,d5	;strip a few bits (for tile systems)
		endif
		
		move.b (playerx),d1				;player pos
		ifd collisionmaskx
			and.b #collisionmaskx,d1	;strip a few bits (for tile systems)
		endif
	
		move.b (playery),d4
		ifd collisionmasky
			and.b #collisionmasky,d4	;strip a few bits (for tile systems)
		endif
	
		jsr rangetest					;return cs if collided limit
		bcc bulletplayernocollide
		jsr playerhurt					;kill player
	
bulletplayernocollide:	
		add.l #objectbytesize,a4
	moveM.l (sp)+,d1/d4/a1

	subq.b #1,d1
	bne nextenemybulletloop

	move.b (playingsfx),d0				;play the current soundeffect (0=nosound)
	cmp.b (playingsfx2),d0
	beq nosound							;see if sound has changed?
	move.b d0,(playingsfx2)

	jsr chibisound						;if it has - update sound.

nosound:
	clr.b (playingsfx)					;mute sound
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

ApplyScore:			;Add A1
	lea Score,a0
	move.l #3,d1
	jsr BCD_Add				;Add the score
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



drawobject:						;a4=object
	move.b (o_collprog,a4),d0	;255 = object unused

	cmp.b #250,d0
	bcs drawobject_needsdrawing
	rts
drawobject_needsdrawing:
	move.b (o_program,a4),d0	;check animation routine for object

	beq programok				;0= Static
	cmp.b #1,d0					;1= Regular
	beq program1
	cmp.b #2,d0					;2= Faster Change
	beq program2
	cmp.b #3,d0					;3=shooting
	beq program3
	cmp.b #4,d0					;4=indecisive
	beq program4
	cmp.b #5,d0					;5=waiter
	beq program5
	cmp.b #6,d0					;6=seeker
	beq program6

program6:
	jsr dorandom
	and.b #%11000000,d0
	beq program6nomove			;move 3 times in 4

	move.b (playerx),d3			;get player pos
	move.b (playery),d6
	
	move.b (o_xpos,a4),d1		;get object xpos
	cmp.b d3,d1
	beq program6_xok
	bcs program6_xlow
	subq.b #1,d1				;Move Left
	bra program6_xok
program6_xlow:
	addq.b #1,d1				;Move Right
program6_xok:
	move.b d1,(o_xpos,a4)		;save xpos

	move.b (o_ypos,a4),d4		;Get object ypos
	cmp.b d6,d4
	beq program6_yok
	bcs program6_ylow
	subq.l #1,d4				;Move Up
	bra program6_yok
program6_ylow:
	addq.l #1,d4				;Move Down
program6_yok:
	move.b d4,(o_ypos,a4)		;save ypos

	jmp programnomoveb

program6nomove:

	jsr dorandom				;randomize fire direction
	move.b d0,(o_yacc,a4)

	jsr dorandom
	move.b d0,(o_xacc,a4)

	and.b #%00000001,d0			;randomly fire a bullet
	bne Program6NoFire
	jsr enemyfirebullet
Program6NoFire:
	jmp programnomove

program5:						;5=waiter
	jsr dorandom
	move.b d0,d1
	and.b #%10000000,d0
	beq program5b				;maybe fire, maybe wait

	move.b d1,d0
	and.b #%00011100,d0			;chance of continued movement
	bne programok
	
	move.b d1,d0
	and.b #%00000011,d0			;chance of direction change
	bne programnewdir

program5b:
	jsr dorandom
	move.b d0,d1
	and.b #%00000011,d0			;chance of firing

	bne program5_NoFire
	jsr enemyfirebullet
program5_NoFire:
	jmp programnomove

program4:						;4=indecisive
	jsr dorandom
	move.b d0,d1
	and.b #%00011100,d0			;chance of direction change

	beq programok
	bra programnewdir


program3:						;3=shooting
	jsr dorandom
	move.b d0,d1
	and.b #%00001111,d0			;Firing probability
	bne program3_NoFire
	jsr enemyfirebullet
program3_NoFire:
	jsr dorandom
	move.b d0,d1

	and.b #%11111100,d0			;chance of direction change
	bne programok
	bra programnewdir

program2:						;2=rarely change direction
	jsr dorandom
	move.b d0,d1

	and.b #%11111100,d0			;chance of direction change
	bne programok
	bra programnewdir

program1:
	jsr dorandom
	move.b d0,d1
	and.b #%00110000,d0			;chance of direction change
	bne programok


programnewdir:
	move.b d1,d0
	and.b #%00000001,d0
	beq dontflipy
	neg.b (o_yacc,a4)			;flip y speed

dontflipy:
	move.b d1,d0
	and.b #%00000010,d0
	beq dontflipx

	neg.b (o_xacc,a4)			;flip x speed
dontflipx:
	bra programok

programnomove:					;static object

	move.b (o_xpos,a4),d1
	move.b (o_ypos,a4),d4
	bra programnomoveb


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

programok:						;finished handling movement code
	move.b (o_xpos,a4),d1
	move.b d1,(lastposx)
	add.b (o_xacc,a4),d1
	move.b d1,(o_xpos,a4)		;update x

	move.b (o_ypos,a4),d4
	move.b d4,(lastposy)
	add.b (o_yacc,a4),d4
	move.b d4,(o_ypos,a4)		;update y

programnomoveb:	 		;X boundary check - if we go <0 we will end up back at &ff
	move.b d1,d0
	cmp.b #screenobjwidth,d0		
	bcs objectposXok			;not out of bounds x
	
	neg.b (o_xacc,a4)
	bra objectreset				;player out of bounds - reset!

objectposXok:	  		;y boundary check - only need to check 1 byte
	move.b d4,d0
	cmp.b #screenobjheight,d0
	bcs objectposyok			;not out of bounds y

	neg.b (o_yacc,a4)
	
;player out of bounds - reset!
objectreset:					
	move.b (lastposx),d1		;reset xpos	
	move.b d1,(o_xpos,a4)

	move.b (lastposy),d4		;reset ypos
	move.b d4,(o_ypos,a4)

	
	cmp.b #3,(o_collprog,a4)	;is object bullet?
	bne objectnotbullet

;object is a bullet	
	jsr blanksprite				;bullet offscreen - clear sprite
	move.l #255,d0

	move.b d0,(o_collprog,a4)	;kill the bullet
	rts

objectnotbullet:
objectposyok:
	clr.l d0
	move.b (O_HSprNum,a4),d0	
	
	subq.b #1,d0				;0 = Software Tile
	cmp.b #128,d0
	bcc DoGetSpriteObj			;255 = Software Tile
	cmp.b #255,d0
	bne DoGetHSpriteObj			;0-127 = Hardware sprite
	jmp DoGetSpriteObj
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


objectcollision:	;see if object has hit the player (object in ix)
;1=crystal 0=anything 3=bullet (player) 255=nothing 254=dead	

	cmp.b #250,(o_collprog,a4)	;collision routine >250 = disabled object
	bcs objectcollision_Collidable
		rts
objectcollision_Collidable:
	moveM.l d1/d4/d2/d5,-(sp)
		move.b (playerx),d1
		ifd collisionmaskx
			and.b #collisionmaskx,d1
		endif
	
		move.b (playery),d4
		ifd collisionmasky
			and.b #collisionmasky,d4
		endif
		
		move.b (o_xpos,a4),d2
		ifd collisionmaskx
			and.b #collisionmaskx,d2
		endif
	
		move.b (o_ypos,a4),d5
		ifd collisionmasky
			and.b #collisionmasky,d5
		endif
		
		jsr rangetest			;see if player has hit object? CS=Collide
		bcs objectcollision_Collided
	moveM.l (sp)+,d1/d4/d2/d5	;no collision	
	rts
	
objectcollision_Collided:
	
	moveM.l (sp)+,d1/d4/d2/d5
	cmp.b #0,(o_collprog,a4)
	beq playerhurt	;0=player has been hurt by enemy 
	
playercrystal:					;prog 1=got crystal
	jsr blanksprite
	lea bcd1,a1
	jsr applyscore
	move.b #%00001111,(playingsfx)
	
	subq.b #1,(crystals)		;decrease remaining crystals
	beq nextlevel				;level complete
	
	cmp.b #onscreencrystals,(crystals)	;only 5 max crystals shown onscreen
	bcs clearcrystal
;if we've still got more crystals to collect, respawn crystal	

	move.l #enemies,d4
	jsr saferandomizeobjectposition	;give crystal a new position
	rts

clearcrystal:
	move.b #255,(o_collprog,a4)
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;prog 0=hurts player
playerhurt:
	cmp.b #0,(invincibility)	;is player invincible?
	beq playerhurt_NotInvincible
	rts
playerhurt_NotInvincible:
	clr.b (playeraccx)			;Stop Movement
	clr.b (playeraccy)

	move.l a4,-(sp)
		lea playerobject,a4
		move.b #5,(playerobject)	;deathanim sprite 5
		move.l #0,d0				;frame num
playerdeathanim:
		movem.l d0,-(sp)
			move.b d0,(spriteframe)	;set frame of explosion
			jsr drawobject			;show player
			
		movem.l (sp)+,d0			;Get Back Frame
		movem.l d0,-(sp)
	
			asl #3,d0				;Noise Pitch
			or.b #%11000111,d0		;loud noise
			jsr chibisound
			
			move.l #$f000,d1		;delay
playerdeathanimloop:
			subq.l #1,d1
			bne playerdeathanimloop	
		movem.l (sp)+,d0
		addq.l #1,d0				;next anim frame
		cmp.b #4,d0
		bne playerdeathanim
		jsr blanksprite				;remove old player sprite
	move.l (sp)+,a4
	jsr resetplayer					;reset player to centre
	move.b #0,d0
	jsr chibisound					;silence sound

	cmp.b #0,(lives)				;any lives left?
	beq playerdead					;no then game over.
	subq.b #1,(lives)				;decrease life count
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
playerdead:
	ifd screenwidth32
		move.l #$020b,d3		;text position
	endif
	ifd screenwidth40
		move.l #$060c,d3
	endif
	ifd screenwidth20
		move.l #$0609,d3
	endif
	jsr locate

	move.l #txtdead,a3
	jsr printstring				;show player dead message
	
	move.l (Score),d0
	cmp.l (HiScore),d0
	bcs gameoverwaitforfire		;jump if no highscore

;new highscore
	ifd screenwidth32			;new highscore message pos
		move.l #$0a0d,d3
	endif
	ifd screenwidth40
		move.l #$0e10,d3
	endif
	ifd screenwidth20
		move.l #$050b,d3
	endif
	jsr locate

	move.l #txtnewhiscore,a3
	jsr printstring				;show the 'new highscore' message

	move.l (score),(hiscore) 	;transfer score to highscore

gameoverwaitforfire:
	jsr waitforfire
	jmp showtitle

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
nextlevel:
	ifd screenwidth32
		move.l #$090b,d3	;level complete message pos
	endif
	ifd screenwidth40
		move.l #$0d0c,d3
	endif
	ifd screenwidth20
		move.l #$0309,d3
	endif

	jsr locate
	move.l #txtcomplete,a3	;showlevelcomplete
	jsr printstring

	addq.b #1,(lives)		;extra life every game

	addq.b #1,(level)
	jmp startlevel			;init new level	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

playerfirebullet:
	moveM.l d1-d6,-(sp)
		lea bulletarray,a5	;check if there are any spare bullets
		move.b #bulletcount,d1
checknextbullet:
		cmp.b #250,(o_collprog,a5)
		bcc foundbullet		;yes! - create a bullet

		add.l #objectbytesize,a5
		subq.b #1,d1
		bne checknextbullet
checkbulletreturn:
	moveM.l (sp)+,d1-d6
	rts

foundbullet:	;player can fire
	move.b #%00000001,d0	;make bullet sound
	move.b d0,(playingsfx)

	clr.b d1		;X
	clr.b d4		;Y

	move.b (playeraccx),d0	;fire bullet depending on player direction
	beq xzero
	move.b #-4,d1			;left
	
	cmp.b #127,d0
	bcc xnegative
	move.b #4,d1			;right
xnegative:
xzero:
	move.b (playeraccy),d0
	beq yzero
	move.b #-8,d4			;up
	cmp.b #127,d0
	bcc ynegative
	move.b #8,d4			;down

ynegative:
yzero:

	move.b d1,d0			;x and y=0? no bullet
	or.b d4,d0
	beq checkbulletreturn

;bullet starts at player position
	move.b (playerx),(o_xpos,a5)		
	move.b (playery),(o_ypos,a5)

;bullet acceleration
	move.b d1,(+o_xacc,a5)
	move.b d4,(o_yacc,a5)
	
	move.b #6,(o_sprnum,a5)		;bullet sprite
	clr.b (o_program,a5)	;bullet program
	move.b #3,(o_collprog,a5)	;bullet collision routine  

	bra checkbulletreturn


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	



enemyfirebullet:
	moveM.l d1-d6,-(sp)	
		lea enemybulletarray,a5		;check if there are any spare bullets
		move.b #bulletcount,d1
enemychecknextbullet:
		cmp.b #250,(o_collprog,a5)
		bcc enemyfoundbullet		;yes! - create a bullet
	
		add.l #objectbytesize,a5
		subq.b #1,d1
		bne enemychecknextbullet
enemycheckbulletreturn:
	moveM.l (sp)+,d1-d6
	rts

	
enemyfoundbullet:

	move.b #%11000011,(playingsfx)	;make bullet sound
	clr.b d1		;X
	clr.b d4		;Y
	
	move.b (o_xacc,a4),d0	;convert enemy accel to bullet accel (x)
	beq enemyxzero
	move.b #-2,d1				;left

	cmp.b #127,d0
	bcc enemyxnegative
	move.b #2,d1				;right
enemyxnegative:
enemyxzero:
	move.b (o_yacc,a4),d0	;convert enemy accel to bullet accel (y)
	beq enemyyzero
	move.b #-2,d4				;up
	
	cmp.b #127,d0
	bcc enemyynegative
	move.b #2,d4				;down
enemyynegative:

enemyyzero:

	move.b d1,d0				;x and y=0? no bullet
	or.b d4,d0
	beq enemycheckbulletreturn

;Set Bullet Pos to enemy pos
	move.b (o_xpos,a4),(o_xpos,a5)
	move.b (o_ypos,a4),(o_ypos,a5)

	move.b d1,(o_xacc,a5)		;movement speed
	move.b d4,(o_yacc,a5)

	move.b #7,(o_sprnum,a5)		;bullet sprite
	clr.b (o_program,a5)		;Program
	move.b #3,(o_collprog,a5)	;Collision prog
	bra enemycheckbulletreturn
                       

sethardwaresprites:		; a4=object d1=count d4=spritenum
	move.b d4,(o_hsprnum,a4)	;Set Hsprite
	add.l #objectbytesize,a4	;Move to next object
	addq.l #1,d4				;Move to next Hsprite
	subq.l #1,d1				;Decrease counter
	bne sethardwaresprites
	rts

