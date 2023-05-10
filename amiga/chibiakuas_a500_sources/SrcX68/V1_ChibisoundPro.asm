
	even

chibiOctave:
		;   e     f     g      a     b     c     d   
	 dc.w $0000,$0400,$0800,$0C00,$1000,$1300,$1600	;0
;     ;   41.2  43.6   49    55   61.7  65.4  73.4
    dc.w $18D0,$2600,$2be0,$30e8,$36b0,$38b0,$3e30	;1
	  ;   82.4  87.3  98    110   123    130   146
	dc.w $4358,$4648,$4b38,$6100,$5600,$5870,$5de0		;2
   	  ;   164   174    196   220 	246   261   293
	dc.w $62e8,$6580,$6b00,$7038,$7590,$7838,$7d90		;3
      ;   329   349   392   440   493   523    587
	dc.w $82e8,$8590,$8ae8,$9040,$9590,$9838,$9d90		;4
   	  ;   659   698   783   880   987   1046  1174
	dc.w $a2e8,$a590,$aae0,$b040,$b598,$b838,$bd90		;5
	  ;   1318  1396  1567  1760  1975  2093  2349
	dc.w $c2e8,$c590,$cae0,$d038,$d590,$d838,$dd90		;6
	dc.w $E000,$E600,$EC00,$F000,$f600,$FA00,$ffff		;7
	even

;$E90001		FM Synthesizer (YM2151) - Register Address Write port
;$E90003		FM Synthesizer (YM2151) - Data R/W port
	
	
	
chibisoundpro_init:
	move.b #$1B,$E90001				;Setwave used by PM/AM Modulation
		   ;DC----WW	D=Disk state C=CT  (4mhz/8mhz) W=Waveform 
	move.b #%0000011,$E90003		;(0=Saw 1=Square,2=Tri, 3=Noise) 
chibisoundpro_update:
	rts
	
;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)

chibisoundpro_set:			
	move.l d6,d4
	and.l #%00000111,d4		;Channel num
	
	
	btst #7,d6
	beq ChibiSoundNoiseOff	;Enable niose

	lea ChannelNoise,a0
	move.b #1,(a0,d4)		;Set noise on
	
	move.b #$60+8,d1 	
	add.b d4,d1
			;-VVVVVVV - [Slot] Volume (0=Max)
	move.b #%01111111,d0
	jsr SetOneSlot
	add.b #16,d1
	jsr SetOneSlot
	
	;lsr.b #1,d2			;Pitch shift
	
	move.l #7,d4			;Noise only works on Chn 7 (slot 32)
	bra ChibiSoundNoiseReady
	
ChibiSoundNoiseOff:	


	lea ChannelNoise,a0
	cmp.b #1,(a0,d4)		;Was noise on before?
	bne ChibiSoundNoiseReady
	
	clr.b (a0,d4)			;Set off
	
	move.b #$0F,$E90001			
			;E--FFFFF - Noise Enable Freq 
	move.b #%00000000,$E90003
	
	move.b #$60+7,d1 	
			;-VVVVVVV - [Slot] Volume (0=Max)
	move.b #%01111111,d0
	jsr SetAllSlots
	
ChibiSoundNoiseReady:


	cmp.b #0,d3
	bne NotSilent

	move.b #$08,$E90001	
		;   ;-SSSSCCC - Channel / Slot
	move.b #%00000000,d0
	add.b d4,d0
	move.b d0,$E90003	
	rts
	
NotSilent:

;Set Channel Connection
	move.b #$20,d0
	add.b d4,d0				;Chn num
	move.b d0,$E90001
			;LRFFFCCC - Left/Right Feedback,Connection
	move.b #%11000001,$E90003	

	
;Remap Octave
	and.l #$FFFF,d2
	move.l d2,d5
	mulu #96,d5				;Effectively divide by 255/96
	lsr.l #8,d5
	;move.l d5,d7			;For testing
		
	move.b #$28,d0
	add.b d4,d0				;Chn num
	move.b d0,$E90001 	
	
	lea OctaveRemap,a0	
	move.l d5,d0
	lsr.l #8,d0
	and.l #$FF,d0
	move.b (a0,d0),d0	;Get byte from lookup
		  ;%-OOONNNN - Key Octave + Note
	move.b d0,$E90003

	move.b #$30,d0
	add.b d4,d0			;Chn num
	move.b d0,$E90001 
	move.w d5,d0
		   ;%FFFFFF-- Chn1-7… Key Fraction	F=Fraction
	and.l #%11111100,d0		
	move.b d0,$E90003

	
;Fixed Settings
	move.b #$40,d1
	add.b d4,d1			;Chn num
		   ;%-DDDMMMM	Slot1-32. Decay/Mult	D=Decay D1T, M=Mult
	move.b #%00000001,d0
	jsr SetAllSlots
		
	move.b #$80,d1
	add.b d4,d1			;Chn num
		   ;%KK-AAAAA	Slot1-32. Keyscale / Attack	K=Keycale, A=attack
	move.b #%11011111,d0
	jsr SetAllSlots
	
	move.b #$E0,d1
	add.b d4,d1			;Chn num
		  ; %DDDDRRRR - [Slot] Decay Level / Release rate
	move.b #%00001111,d0				;(15=Constant tone)
	jsr SetAllSlots
	
	move.b #$C0,d1
	add.b d4,d1			;Chn num
		  ;%TT-DDDDD	Slot1-32. DeTune / Decay
	move.b #%00000000,d0	;T=Detune DT2, D=Decay D2R
	jsr SetAllSlots
	
	move.b #$A0,d1
	add.b d4,d1			;Chn num
		   ;%A--DDDDD	Slot1-32. AMS / Decay	A=AMS-EN, D=Decay D1R
	move.b #%10000000,d0
	jsr SetAllSlots
	
	move.b #$38,d0
	add.b d4,d0			;Chn num
	move.b d0,$E90001
		   ;%-PPP--AA	PMS / AMS	P=PMS , A=AMS
	move.b #%00000000,$E90003
		

;Set the volume	
	move.b #$60+8+16,d1
	add.b d4,d1			;Chn num
	move.l d3,d0
		 ;%-VVVVVVV	Slot1-32. Volume	V=Volume (TL) (0=max) 
	or.b #%00001111,d0	;<only use top 4 bits, volume gets quiet fast!

	lsr.b #1,d0
		  ;%-VVVVVVV	Slot1-32. Volume	V=Volume (TL) (0=max) 
	eor.b #%01111111,d0
	jsr SetOneSlot
	
	sub.b #16,d1
	or.b #%00001111,d0
	jsr SetOneSlot
	
	
;Key On!
	move.b #$08,$E90001	
		   ;%-SSSSCCC   Channel / Slot
	move.b #%01111000,d0
	add.b d4,d0
	move.b d0,$E90003	
	
	
;Sound Noise?
	btst #7,d6
	bne ChibiSoundNoiseOn		;Enable niose
	rts
	
ChibiSoundNoiseOn:
	move.b #$0F,$E90001				;Noise setting
	move.l d5,d0					;(Slot 3 - channel 7)
	and.l #$FF00,d0
	lsr.l #8,d0
	lsr.l #3,d0
		   ;E--FFFFF - Noise Enable Freq 
	or.b  #%10000000,d0			;Top bit turns on noise
	move.b d0,$E90003
	rts

	
SetAllSlots: 			;Set all slots from D1 to val D0
	move.b d1,$E90001 		;Set slot 1
	move.b d0,$E90003
	addq.b #8,d1
	move.b d1,$E90001 		;Set slot 2
	move.b d0,$E90003
	addq.b #8,d1
	move.b d1,$E90001 		;Set slot 3
	move.b d0,$E90003
	addq.b #8,d1
SetOneSlot: 
	move.b d1,$E90001 		;Set Slot 4
	move.b d0,$E90003
	rts
	

;Each Octave contains 12 notes not 16, so we have to skip numbers GRR!
OctaveRemap:
	dc.b 0,1,2,4,5,6,8,9,10,12,13,14
	dc.b 16,17,18,20,21,22,24,25,26,28,29,30
	dc.b 32,33,34,36,37,38,40,41,42,44,45,46
	dc.b 48,49,50,52,53,54,56,57,58,60,61,62
	dc.b 64,65,66,68,69,70,72,73,74,76,77,78
	dc.b 80,81,82,84,85,86,88,89,90,92,93,94
	dc.b 96,97,98,100,101,102,104,105,106,108,109,110
	dc.b 112,113,114,116,117,118,120,121,122,124,125,126
	
ChannelNoise equ chibisoundram+256	;Ram to mark noise channel


	