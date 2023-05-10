ChibiOctave:
	;   E     F     G      A     B     C     D   
	dc.w $1000,$2000,$3000,$3800,$4000,$4800,$5000 
	;   41.2  43.6   49    55   61.7  65.4  73.4
	dc.w $42c9,$4dc9,$60f6,$7236,$80F8,$8876,$95e9 ;1
	;   82.4  87.3  98    110   123    130   146
	dc.w $A14D,$A689,$B035,$B959,$C08F,$C44A,$CAC1 ;2
	;	  164   174    196   220 	246   261   293
	dc.w $D0A8,$D39E,$D84D,$DC7C,$E05B,$E21F,$E55E ;3
	;     329   349   392   440   493   523    587
	dc.w $e848,$EBEE,$EE21,$EE35,$F028,$F10E,$F2B0 ;4
	;    659  698   783   880   987   1046  1174
	dc.w $F41F,$F4CB,$F602,$F71C,$F80F,$F881,$F951 ;5
	;   1318  1396  1567  1760  1975  2093  2349
	dc.w $FA0B,$1404,$FB00,$FB86,$FC02,$fC3e,$FCA2 ;6
	dc.w $FD20,$FD80,$FE00,$FE80,$FF00,$FF80,$FFFF
	
;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)
	
chibisoundpro_set:
	
	;Turn off sound DMA
	;        FEDCBA9876543210 - DMACON - DMA control write
	move.w #%0000000000001111,$DFF096 ; Channels off

	move.b d6,d4			;%NCCCCCCC C=Channel N=Noise on/off
	and.l #%00000011,d4		;Channel number (0-3)
	lsl.l #4,d4				;*16
	add.l #$DFF0A0,d4		;Base address of first channel
	move.l d4,a2			;A2= base of channel registers
	
	
	eor.w #$FFFF,d2			;D2=Pitch (16 bit)
	move.w d2,(6,a2)		;AUD0PER - Audio channel period
		
		
	move.b d3,d0			;D3= Volume %VVVVVVVV
	and.w #%11111100,d0		;Volume (#64=max)
	ror.w #2,d0				;%--VVVVVV
	move.w d0,(8,a2)		;AUD0VOL - Audio channel volume
	
	
	move.w #(wavToneEnd-wavTone)/2,d0	;Load the length of the tone
	lea wavTone,a0			;Load the address of the tone
	
	btst #7,d6				;Jump if we're not making a noise 
	beq ChibiSoundProNoNoise						
		
	move.w #(wavNoiseEnd-wavNoise)/2,d0	;Load the length of the noise
	lea WavNoise,a0			;Load the address of the noise

ChibiSoundProNoNoise:

	move.l a0,(0,a2)		; AUD0LCH Audio channel location
	move.w d0,(4,a2)		; AUD0LEN Audio channel length (words)
	
	
	;Turn on sound DMA
	;        FEDCBA9876543210 DMACON - DMA control write
	move.w #%1000001000001111,$DFF096 ;All channels on
	
	rts

	
chibisoundpro_init:
	;Disable modulaton
	;        FEDCBA9876543210 - $ADKCON Audio, disk, UART control
	move.w #%0000000011111111,$DFF09E	
	
	
chibisoundpro_update:
	lea WavNoise,a0
	move.l #(WavNoiseEnd-WavNoise)-1,d1
	
ChibiSoundReRandomize:	;Need to update our random noize
	ifd getrandom
		jsr GetRandom	;Use the 'GetRandom' function to produce noise
	else
		addq.b #1,(a0)	;Mess with a bunch of registers to try
		eor.b d0,(a0)		;and make some random noise
		move.b (a0),d0
		roxr.b #3,d0
		move.b d0,(a0)
		eor.b d1,(a0)
		move.b (a3)+,d4
		eor.b d4,(a0)
		move.b (a0),d0
		roxr.b #3,d0
	endif
	move.b d0,(a0)+
	dbra d1,ChibiSoundReRandomize
	rts
	
	
; AUD0LCH $DFF0A0 	Audio channel 0 (L) location (high 3 bits, 5 if ECS)
; AUD0LCL $DFF0A2 	Audio channel 0 (L) location (low 15 bits)
; AUD0LEN $DFF0A4	Audio channel 0 (L) length
; AUD0PER $DFF0A6	Audio channel 0 (L) period
; AUD0VOL $DFF0A8	Audio channel 0 (L) volume (#64=max)
; AUD0DAT $DFF0AA	Audio channel 0 (L) data

; AUD1LCH $DFF0B0 	Audio channel 1 (R) location (high 3 bits, 5 if ECS)
; AUD1LCL $DFF0B2 	Audio channel 1 (R) location (low 15 bits)
; AUD1LEN $DFF0B4	Audio channel 1 (R) length
; AUD1PER $DFF0B6	Audio channel 1 (R) period
; AUD1VOL $DFF0B8	Audio channel 1 (R) volume (#64=max)
; AUD1DAT $DFF0BA	Audio channel 1 (R) data


