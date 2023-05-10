
ChibiOctave:
	;   E     F     G      A     B     C     D   
	dc.w $1000,$1800,$2000,$2800,$3000,$3800,$4000 
	;   41.2    43.6   49    55   61.7  65.4  73.4
	dc.w $431b,$4dc0,$60f8,$7290,$8198,$8890,$9588 ;1	
	;   82.4  87.3    98    110   123    130   146
	dc.w $a130,$A680,$b09a,$B908,$c0b8,$c438,$cab8 ;2
	;	  164   174    196   220 	246   261   293
	dc.w $c090,$d350,$d830,$dc80,$e058,$e220,$e558 ;3
	;     329   349   392   440   493   523    587
	dc.w $e848,$e998,$ec10,$ee38,$f030,$f108,$f480 ;4
	;    659    698   783   880   987   1046  1174
	dc.w $f430,$f4d0,$f608,$f720,$f810,$f888,$f958 ;5
	;     1318  1396  1567  1760  1975  2093  2349
	dc.w $fa10,$fa70,$fb00,$Fb88,$fc08,$fc40,$fcA8 ;6
	dc.w $FD20,$FD80,$FE00,$FE80,$FF00,$FF80,$FFFF
	
	
chibisoundpro_init:
	move.b #%10111111,d0		;set up port directions
	move.b d0,(aycache+7)

chibisoundpro_update:
	rts
	
;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)

chibisoundpro_set:
;channel remap
	move.b d6,d4
	and.b #%10000000,d4		;Get noise bit
	
	move.b d6,d0
	and.l #%00000111,d0		;Loop every 8 channels
	move.l #channelmap,a3
	move.b (a3,d0),d6		;channel mapping
	
	or.b d4,d6				;Or noise back in

;Check channel off?
	tst.b d3				;zero turns off sound
	bne notsilent
	
	jsr dochannelmask
	and.b #%00111111,d0		;Mask bits to set (silence channel)
	move.b (a1),d1			;Get current Mixer state
	or.b d0,d1
	move.l #7,d0			;mixer  --nnnttt (1=off) --cbacba
	jmp ayregwrite
	
notsilent:

;Set Pitch
	neg.w d2				;Pitch
	lsr.w #4,d2				;ditch bottom 4 bits
	
	move.b d6,d0			;Channel pitch regs
	and.b #%00000111,d0
	lsl.b #1,d0				;Pitch HL = 0+1 / 2+3 / 4+5
	
	move.w d2,d1			;Pitch
	and.w #$FF,d1			;TTTTTTTT Tone Lower 8 bits	B
	jsr ayregwrite			;Reg d0 = Val d1
	
	addq.b #1,d0			;regnum+1
	
	move.w d2,d1			;Pitch
	lsr.w #8,d1
	and.w #$0F,d1			;----TTTT Tone Upper 4 bits
	jsr ayregwrite			;Reg d0 = Val d1
	
	
	btst #7,d6
	beq aynonoise			;Is noise on?
	
;Mixer - Noise On
	move.l d2,d7
		jsr dochannelmask
		and.b #%00111111,d2
		not.b d2			;Mask to clear noise bit for channel
		
		move.b (a1),d1		;Get current Mixer state
		and.b d2,d1			;noise and tone on
		move.l #7,d0
		jsr ayregwrite		;Reg d0 = Val d1
	move.l d7,d1
	
	lsr.w #7,d1				;We backed D2 up in D1
	and.b #%00011111,d1		;Noise frequency

	move.l #6,d0			;noise ---nnnnn
	jsr ayregwrite			;Reg d0 = Val d1
	
	jmp aymaketone

;Mixer - Noise Off
aynonoise:
	jsr dochannelmask
	and.b #%00111000,d0		;Bits to set (noise)
	move.b d0,d5

	and.b #%00000111,d2		;Bits to clear (tone)
	not.b d2

	move.b (a1),d0			;Get current Mixer state
	
	and.b d2,d0				;tone on (Channel bit to 0)
	or.b d5,d0				;noise off	(Channel bit to 1)
	move.b d0,d1

	move.l #7,d0			;mixer  --nnnttt (1=off) --cbacba
	jsr ayregwrite			;Reg d0 = Val d1

; Volume 
aymaketone:
	move.l d3,d1			;vvvvvvvv = volume bits
	lsr.b #4,d1

	move.b d6,d0			;4-bit volume / 1-bit envelope select
	and.b #%00000011,d0			; for channel a ---evvvv
	add.b #8,d0				;channel num 8,9,10
	jmp ayregwrite			;Reg d0 = Val d1


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dochannelmask:	;A6 = Channel

	lea channelmask,a1		;Get Mask
	move.b d6,d0
	and.l #%00000011,d0		;Channel num
	clr.l d2
	move.b (a1,d0),d2		;D2+D0= Channel bit mask
	move.l d2,d0
	lea aycache+7,a1		;Mixer address
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ayregwrite:		;Reg d0 = Val d1

	move.l #aycache,a1		;Previous settings
	and.l #$0F,d0
	cmp.b (a1,d0),d1		;See what last setting was
	beq ayregnochange
	move.b d1,(a1,d0)		;Setting changed
	
	move.b d0,$FF8800		;Reg Num
	move.b d1,$FF8802		;Reg Val
	
ayregnochange:				;Already set correctly
	rts		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	align 4
	
	ifnd AYCache
		ifd ChibiSoundRam
AYCache equ ChibiSoundRam+256	;First 256 bytes reserved for tracker
		else
AYCache: 	ds.b 16
		endif 
	endif
	
ChannelMap:		dc.b 1,0,2,0,2,0,2,0		;Channel lookup

ChannelMask:	dc.b %00001001,%00010010,%00100100,0	;Mixer bits


