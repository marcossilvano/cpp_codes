
ChibiSoundNoise:					;Rerandomize the noise sound
	lea WavNoise,a0
	move.l #WavNoiseEnd-WavNoise-1,d3
	
ChibiSoundReRandomize:				;Need to update our random noize
	ifd getrandom
		jsr GetRandom				;Use the 'GetRandom' function to produce noise
	else
		addq.b #1,(a0)				;Mess with a bunch of registers to try
		eor.b d0,(a0)					; and make some random noise
		move.b (a0),d0
		roxr.b #3,d0
		move.b d0,(a0)
		eor.b d1,(a0)
		move.b (a6)+,d5
		eor.b d5,(a0)
		move.b (a0),d0
		roxr.b #3,d0
	endif
	move.b d0,(a0)+
	dbra d3,ChibiSoundReRandomize
	rts


silent:
	clr.w ($DFF0A8)			; AUD0VOL $DFF0A8	Audio channel 0 (L) volume (#64=max)
	clr.w ($DFF0A8+16)		; AUD1VOL $DFF0B8	Audio channel 1 (R) volume (#64=max)
	rts

ChibiSound:					;NVVTTTTT	Noise Volume Tone 
	
	and.l #$000000FF,d0
	tst.b d0				
	beq silent				;Silence the sound CPU
	
	move.b d0,d3 			;Backup for later
		
	and.l #%00111111,d0		;pitch
	rol.l #5,d0
	move.w d0,($DFF0A6)		; AUD0PER $DFF0A6	Audio channel 0 (L) period
	move.w d0,($DFF0A6+16)	; AUD1PER $DFF0B6	Audio channel 1 (R) period
		
	move.b d3,d0
	and.b #%01000000,d0		;Volume
	ror.b #1,d0
	eor.b #%00011111,d0 
	move.w d0,($DFF0A8)		; AUD0VOL $DFF0A8	Audio channel 0 (L) volume (#64=max)
	move.w d0,($DFF0A8+16)	; AUD0VOL $DFF0A8	Audio channel 0 (L) volume (#64=max)
	
	move.w #wavToneEnd-wavTone,a1	;Load the length of the tone
	lea wavTone,a0			;Load the address of the tone
	
	btst #7,d3				;Jump if we're not making a noise 
	beq ChibiSoundNoNoise						
	
	;jsr ChibiSoundNoise		;Update the noise sound
	
	move.w #wavNoiseEnd-wavNoise,a1	;Load the length of the noise
	lea WavNoise,a0			;Load the address of the noise

ChibiSoundNoNoise:

	move.l a0,($DFF0A0)		; AUD0LCH $DFF0A0 	Audio channel 0 (L) location
	move.l a0,($DFF0A0+16)	; AUD1LCH $DFF0B0 	Audio channel 1 (R) location

	move.w a1,($DFF0A4)		; AUD0LEN $DFF0A4	Audio channel 0 (L) length
	move.w a1,($DFF0A4+16)	; AUD1LEN $DFF0B4	Audio channel 1 (R) length
	
							;Turn on sound DMA
	
	;        FEDCBA9876543210
	move.w #%1000001000000011,$DFF096	; $DFF096 DMACON - DMA control write (clear or set)
										;S-----E- ---DCBA	S=Set/Clr E=enable ABCD=Channnels
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