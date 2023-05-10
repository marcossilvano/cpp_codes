
;NeoJoy_UseBios equ 1
channeldatalengthtotal equ 128 

	ifd BuildSQL
SQL_RelocateProg equ 1
chibisoundram equ UserRam+$200	
	endif 
	ifd BuildGEN 
chibisoundram equ $00FF1000
	endif

	ifd BuildAST
chibisoundram equ UserRam+$800
	endif

	ifd BuildX68
chibisoundram equ UserRam+$200	
	endif



Cursor_X equ UserRam
Cursor_Y equ UserRam+2

	include "\SrcALL\BasicMacros.asm"
	include "\SrcALL\V1_Header.asm"
	
	jsr chibisoundpro_init
	
	
	jsr KeyboardScanner_AllowJoysticks	;Turn on joysticks on systems that need init
	
	move.l #$1000,d2
KAgain:	
	moveM.l d2,-(sp)
		move.l #0,d3
		move.l #0,d6
		jsr Locate
	
		jsr Player_ReadControlsDual		;Get Joystick state	
		move.l d0,d3
	moveM.l (sp)+,d2
	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	sub.w #256,d2		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	add.w #256,d2		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #8,d2		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #8,d2		;Move X Right
JoyNotRight: 	
	move.l #$00,d6		;Channel
	
	btst #4,d3
	bne JoyNotFire		;Jump if RIGHT not pressed
	move.l #$80,d6		;Channel + Noise
JoyNotFire	
	
	
	move.l #255,d3		;Vol
	
	
	moveM.l d1-d5,-(sp)
		jsr chibisoundpro_set
	moveM.l (sp)+,d1-d5
	
	moveM.l d1-d5,-(sp)
		;move.l #$0,d6		;Channel
		;jsr chibisoundpro_set
		jsr chibisoundpro_Update
	moveM.l (sp)+,d1-d5
	
	move.l #$FF,d0
delay2:	
;	dbra d0,delay2
	
	jsr monitor
	
	jmp KAgain


tweentone:	;a= ooooffff	o=offset -8 to +7 f=fraction 0-15
;                                     		push af		
	move.l d0,-(sp)
		lsr.b #4,d0
		add.b d5,d0

		move.b d0,d5

		pushde

			jsr getchibitone	;e=note (bit 1-6=note  bit0=flat)
			exg d3,d2
		popde
		pushhl
			addq.l #1,d2
			jsr getchibitone	;e=note (bit 1-6=note  bit0=flat)
		pophl
	move.l (sp)+,d0
	and.b #%00001111,d0
	jsr tween16hlde
	exg d3,d2			;result in de
	rts

getchibitone:;e=note (bit 1-6=note  bit0=flat) - returns de frequency
;                                     	;e-f-g-a-b-c-d-... Octave 0-6

;                                     			ld hl,chibiOctave
	move.l #chibiOctave,a3
;                                     			ld d,0
	
;                                     			ld a,e
	move.b d2,d0
;                                     			res 0,e
	and.l #$00FE,d2
	add.l d2,a3
;                                     

;                                     			ld e,(hl)
	move.w (a3),d2
	btst #0,d0
	beq chibitonegotnote
	addq.l #2,a3
	lsr.w #1,d2

	move.w (a3),d3
	lsr.w #1,d3

;                                     			add hl,de		;add two halves
	add.l d3,d2
chibitonegotnote:
	rts

	
;                                     ;fraction 16... return between values 0-15

;                                     

;                                     

;                                     

;                                     		;16 steps between hl and de

;                                     tween16hlde:	;a/16 of de, 16-a/16 of hl  hl----a----de
tween16hlde:
;                                     	push af
	movem.l d0,-(sp)
;                                     	push hl
	pushhl
;                                     		z_ex_dehl ;ex de,hl
		exg d2,d3	;z_ex_dehl
;                                     		call fraction16
		jsr fraction16
;                                     		z_ex_dehl ;ex de,hl
		exg d2,d3	;z_ex_dehl
;                                     	pop hl
	pophl
;                                     	pop af
	movem.l (sp)+,d0
;                                     	z_neg
	neg.b d0
;                                     	add 16
	add.b #16,d0
;                                     	call fraction16
	jsr fraction16
;                                     	add hl,de
	add.l d2,d3
;                                     	ret
	rts
;                                     


fraction16:	;return hl=hl* a/16 (devide by 16, mutlt by a
	cmp.b #0,d0
	beq fraction16_0

	cmp.b #16,d0
	bcs lbl63117
	rts
lbl63117
	lsr.w #1,d3 ;1/2
	cmp.b #8,d0
	bne lbl51508
	rts
lbl51508
	lsr.w #1,d3 ;1/4
	cmp.b #4,d0
;                                     	ret z
	bne lbl29759
	rts
lbl29759
	lsr.w #1,d3 ;1/8
	cmp.b #2,d0
;                                     	ret z
	bne lbl54214
	rts
lbl54214
	lsr.w #1,d3 ;1/16
	cmp.b #1,d0
	bne lbl20034
	rts
lbl20034
;                                    	push de
	pushde
		exg d2,d3
		clr.l d3
fraction16a:
		add.w d2,d3
		subq.b #1,d0
		bne fraction16a
	popde
	rts

fraction16_0:
	clr.l d3
	rts

z	include "\SrcALL\V1_ChibiSoundPro.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	include "\SrcALL\V1_ReadJoystick.asm"
	include "\SrcALL\V1_Palette.asm"
	include "\SrcALL\V1_BitmapMemory.asm"
	include "\SrcALL\V1_VdpMemory.asm"
	include "\SrcALL\V1_Functions.asm"
	include "\SrcALL\Multiplatform_Monitor.asm"
	
	include "\SrcALL\V1_DataArea.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Data Area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ifnd BuildNEO			;NeoGeo Doesn't use font
Font:
	incbin "\ResALL\Font96.FNT"
	endif
Bitmap:
	ifd BuildX68
		incbin "\ResALL\Sprites\RawMSX.RAW"
	endif	
	ifd BuildGEN
		incbin "\ResALL\Sprites\RawMSXVdp.RAW"
		
	endif
	ifd BuildAST
		incbin "\ResALL\Sprites\SpriteAMI.RAW"
	endif
	ifd BuildAMI
		incbin "\ResALL\Sprites\SpriteAMI.RAW"
	endif
	ifd BuildSQL
		
		incbin "\ResALL\Sprites\RawQL.raw"
	endif
BitmapEnd:
	even
Palette:
	;     -grb
	dc.w $0000	;0 - Background
	dc.w $0099	;1
	dc.w $0E0F	;2
	dc.w $0FFF	;3 - Last color in 4 color modes
	dc.w $000F	;4
	dc.w $004F	;5
	dc.w $008F	;6
	dc.w $00AF	;7
	dc.w $00FF	;8
	dc.w $04FF	;9
	dc.w $08FF	;10
	dc.w $0AFF	;11
	dc.w $0CCC	;12
	dc.w $0AAA	;13
	dc.w $0888	;14
	dc.w $0444	;15
	dc.w $0000	;Border
	even

Message: dc.b 'Hello World?!!',255
	even
	include "\SrcALL\V1_RamArea.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Ram Area - May not be possible on all systems!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ifd BuildAMI
		even
		
wavTone:	;Square Wave
		dc.b 	128,		127,		128,		127
		;dc.b 	0,64,127,64,0,192,128,192
wavToneEnd	
wavNoise:	;Random noise
		dc.b	195,184, 71, 82,141,186, 62,131
		dc.b	135,217,250,193, 80,152,194,  2
wavNoiseEnd:

	endif
	
	
	include "\SrcALL\V1_Footer.asm"