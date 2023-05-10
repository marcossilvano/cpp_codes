
ChibiOctave:
	;   E     F     G      A     B     C     D   
	dc.w $0800,$1000,$2000,$2800,$3000,$3800,$4000 
	;     41.2  43.6   49    55   61.7  65.4  73.4
	dc.w $4300,$4dbd,$60fa,$723a,$818a,$888a,$95ca ;1
	;     82.4  87.3  98    110   123    130   146
	dc.w $a10a,$a6ca,$b8a,$b90a,$c0c7,$c437,$cac3 ;2
	;     164   174    196   220 	246   261   293
	dc.w $d090,$d346,$d82c,$dc72,$E054,$e219,$e559 ;3
	;     329   349   392   440   493   523    587
	dc.w $e84b,$e992,$ec06,$ee3f,$f029,$f10c,$f2ab ;4
	;     659   698   783   880   987   1046  1174
	dc.w $f41d,$F4CD,$f605,$f717,$F80F,$F994,$f953 ;5
	;     1318  1396  1567  1760  1975  2093  2349
	dc.w $FA01,$fa61,$FAF4,$FB87,$FC05,$FC3E,$FCA4 ;6
	dc.w $FD00,$FD80,$FE00,$FE80,$FF00,$FF80,$FFFF
	

;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)
	
	
;We have to send our byte in 2 parts because the NeoGeo Z80 uses commands 0-31 as system commands

chibisoundpro_set:				;NVVTTTTT	Noise Volume Tone 
	moveM.l d0-d7,-(sp)
	
		jsr ChibiSoundInit		;Reset Z80 Driver 
		
;Frequency
		move.w d2,d0
		jsr ChibiSoundSendLow			;E1
		move.w d2,d0
		jsr ChibiSoundSendHigh			;E2
		
		move.w d2,d0
		lsr.w #8,d0
		jsr ChibiSoundSendLow			;D1
		move.w d2,d0
		lsr.w #8,d0
		jsr ChibiSoundSendHigh			;D2
		
;Channel / Noise
		move.w d6,d0
		jsr ChibiSoundSendLow			;H1
		move.w d6,d0
		jsr ChibiSoundSendHigh			;H2

;Volume
		move.w d3,d0
		jsr ChibiSoundSendLow			;L1
		move.w d3,d0
		jsr ChibiSoundSendHigh			;L2
		
;Done
		jsr ChibiSoundExecute	;Execute command
		
	moveM.l (sp)+,d0-d7

ChibiSoundPro_Init:	
ChibiSoundPro_Update:	
	rts
	

ChibiSoundInit:	
	move.b #%10010000,d0
	move.b	d0,$320000 		;Send a byte to the Z80
	
	clr.l d7				;First command!
	jmp ChibiSoundwait
	
	
ChibiSoundExecute:	
	move.b #%10110000,d0
	move.b	d0,$320000 		;Send a byte to the Z80
	jmp ChibiSoundwait		
	
	
	
ChibiSoundSendLow:
	and.b #%00001111,d0		;Send Low nibble
	or.b  #%10100000,d0		;1010DDDD	=DDDD is bottom nibble
	move.b	d0,$320000 		;Send a byte to the Z80
	jmp ChibiSoundwait
	
ChibiSoundSendHigh:	
	and.b #%11110000,d0		;Send High nibble
	ror.b #4,d0
	or.b  #%10100000,d0		;1010DDDD	=DDDD is top nibble
	move.b	d0,$320000 		;Send a byte to the Z80 
	jmp ChibiSoundwait

	
ChibiSoundWait:		
	move.b	$320000,d0 		;Get byte from Z80
	cmp.b d0,d7
	bne ChibiSoundWait		;Wait until procesed (Returns CMD num)
	addq.l #1,d7			;Inc command num
	rts
	
	
	