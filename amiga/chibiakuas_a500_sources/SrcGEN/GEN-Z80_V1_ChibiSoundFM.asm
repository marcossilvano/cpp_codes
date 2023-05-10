; This code is IDENTICAL to the NeoGeo one.


silent:
	ld a, &28
		  ;OOOO-CCC	O=operator / C=Channel (0=chn 1)
	ld c, %00000001 ;KEY ON
	call FMRegWrite
	
	ld a, &B5
		 ;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity 
	ld c,%00000000  ;/ F=Frequency Mod Sensitivity
	call FMRegWrite	;Stereo output
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ChibiSound:			;NVVTTTTT	Noise Volume Tone 
	or a
	jp z,silent		;Zero turns off sound
	
	xor %00111111	;Flip tone bits
	
	ld h,a			;Back up A
	and %01000000
	xor %01000000
	rrca
	rrca
	ld c,a	`		 ;Total Level (volume)
	ld a,&4d 		 ;-TTTTTTT	T=Total Level (0=largest)
	call FMRegWrite
	
	ld a,h
	and %00110000	 ;--PPpppp Get upper bits of tone
	rrca
	rrca
	rrca
	rrca
	or %00011100	 ;---111PP 
	ld c,a
	ld a,&A5		 ;--OOOPPP	O=Octave / P=Position H - Frequency H
	call FMRegWrite
	
	ld a,h
	and %00001111	 ;Rotate lowest 4 bits from --ppPPPP
	rlca
	rlca
	rlca
	rlca
	ld c,a			 ;PPPP----
	ld a,&A1		 ;PPPPPPPP	P=Frequency Position L - Frequency L
	call FMRegWrite

	
	bit 7,h
	jr z,ChibiSoundNoNoise

ChibiSoundNoise:		
		ld a,$22
			 ;----EFFF	E=enable F=frequency
		ld c,%00001110  ;Turn on LFO
		call FMRegWrite
		
		ld a,&B5
			; LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity 
		ld c,%11110100  		;F=Frequency Mod Sensitivity
		call FMRegWrite ;Stereo output - LFO Amplitude Mod ON
		
		jr ChibiSoundNoiseDone

ChibiSoundNoNoise:
		ld a,&22
			 ;----EFFF	E=enable F=frequency
		ld c,%00000000  ;Global: LFO disable
		call FMRegWrite
		
		ld a,&B5
			 ;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity 
		ld c,%11000000  		;F=Frequency Mod Sensitivity 
		call FMRegWrite ;Stereo output
		
ChibiSoundNoiseDone:		
		ld a,&B1
		ld c,%00000000
			; --FFFAAA	F=Feedback / A=Algorithm
		call FMRegWrite
	
		ld a,&3D
			 ;-DDDMMMM	D=Detune / M=Multiplier
		ld c,%00000011  ;Multiplier = 1 (tone)
		call FMRegWrite
		
		ld a,&5D
			 ;RR-AAAAA	R=Rate Scaling / A = Attack rate
		ld c,%00011111  ;Attack Rate=31 (tone)
		call FMRegWrite
		
		ld a,&6D
			 ;A--DDDDD	A=Amplitude Mod Enable / D= Decay rate
		ld c,%10000000  ;0= Keep tone constant (allow LFO)
		call FMRegWrite
		
		ld a,&8d
			 ;SSSSRRRR	S=Sustain Level / Release Rate
		ld c,%11111111  ;Sustain=15 , Release=15
		call FMRegWrite	
				
		ld a,&28
			 ;OOOO-GCC	O=operator / GCCC=Channel
		ld c,%10000001  	; (%010=chn 3 %100=Chn4)
		call FMRegWrite	;KEY ON (OP4 Tone)
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FMRegWrite:
	call FMRegWriteWait
	ld (&4000),a			;Reg Num
	ld a,c
	call FMRegWriteWait
	ld (&4001),a			;Reg Val
	ret
	
FMRegWriteWait:
	push af
FMRegWriteWaiting:
		ld a,(&4000)		;Check status
		bit 7,a			;is FM chip still busy?
		jr nz,FMRegWriteWaiting
	pop af
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;