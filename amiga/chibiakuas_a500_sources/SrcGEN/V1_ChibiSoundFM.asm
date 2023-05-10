	;We're using Channel 2 xD - this is to match the ports of the NeoGeo (which has fewer channels)

ChibiSound:					;NVTTTTTT	Noise Volume Tone 
	
	; Disable the Z80
	move.w  #$100,$a11100	;Z80 Bus REQ
	move.w  #$100,$a11200	;Z80 Reset

	and.l #$000000FF,d0
	tst.b d0				;See if d0=0
	beq silent
	
	movem.l d0-d3/a1,-(sp)
		eor.b #%00111111,d0
		move.b d0,d3		

		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		

		move.b d3,d1		;Volume bit
		and.b #%01000000,d1
		eor.b #%01000000,d1
		ror.b #2,d1
		move.b #$4D,d0		;-TTTTTTT	T=Total Level (0=largest) 
		jsr SNDSetReg1				;Volume of Op4
				
			
		move.b d3,d1
		and.b #%00110000,d1
		ror.b #4,d1
		or.b #%00011100,d1
		move.b #$A5,d0		;--OOOPPP	O=Octave / P=Position H 
		jsr SNDSetReg1			;Frequency MSB
		
		move.b d3,d1
		and.b #%00001111,d1
		rol.b #4,d1
		move.b #$A1,d0		;PPPPPPPP	P=Frequency Position L
		jsr SNDSetReg1			;Frequency LSB
		
		
		move.b d3,d0
		and #%10000000,d0
		beq ChibiSoundNoNoise

ChibiSoundNoise:		
		move.b #$22,d0 
				;----EFFF	E=enable F=frequency
		move.b #%00001110,d1  ;Turn on LFO
		jsr SNDSetReg1
		
		move.b #$B5,d0
				;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity
		move.b #%11110100,d1  	;F=Frequency Mod Sensitivity
		jsr SNDSetReg1			;Stereo output - LFO Amplitude Mod ON
		
		bra ChibiSoundNoiseDone
		
ChibiSoundNoNoise:
		move.b #$22,d0 
				;----EFFF	E=enable F=frequency
		move.b #%00000000,d1  ;Global: LFO disable
		jsr SNDSetReg1
		
		move.b #$B5,d0
				;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity
		move.b #%11000000,d1  		;F=Frequency Mod Sensitivity
		jsr SNDSetReg1				;Stereo output
		
ChibiSoundNoiseDone:		

		move.b #$B1,d0
		move.b #%00110000,d1
			    ;--FFFAAA	F=Feedback / A=Algorithm	
		jsr SNDSetReg1	

		move.b #$3D,d0
				;-DDDMMMM	D=Detune / M=Multiplier
		move.b #%00000001,d1  ;Multiplier = 1 (tone)
		jsr SNDSetReg1
		
		move.b #$5D,d0
				;RR-AAAAA	R=Rate Scaling / A = Attack rate
		move.b #%00011111,d1  ;Attack Rate=31 (tone)
		jsr SNDSetReg1
		
		move.b #$6D,d0
				;A--DDDDD	A=Amplitude Mod Enable / D= Decay rate
		move.b #%10000000,d1  ;0= Keep tone constant (allow LFO)
		jsr SNDSetReg1
				
		move.b #$8D,d0
				;SSSSRRRR	S=Sustain Level / Release Rate
		move.b #%11111111,d1  ;Sustain=15 , Release=15
		jsr SNDSetReg1
		
		move.b #$28,d0
				;OOOO-CCC	O=operator / C=Channel (0=chn 1)
		move.b #%10000001,d1  ;KEY ON
		jsr SNDSetReg1
	
	movem.l (sp)+,d0-d3/a1
	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
silent:		;Mute Nosie and Tone (Vol 15=mute)

	move.b #$28,d0
			;OOOO-CCC	O=operator / C=Channel (0=chn 1)
	move.b #%00000001,d1  ;KEY ON
	jsr SNDSetReg1
	
	move.b #$B5,d0
			;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity / F=Frequency Mod Sensitivity
	move.b #%00000000,d1  ;Stereo output
	jsr SNDSetReg1
	
	rts
	
SNDSetReg1:					;Set Reg d0 to Val d1
	move.l #$A04000,a0		
	jsr SNDSetRegpause
	move.b d0,(a0)			;Write the register number to $A04000
	jsr SNDSetRegpause
	move.b d1,(1,a0)		;Write the new value to $A04001
	rts
	
SNDSetRegpause:
	move.b (a0),d2			;Read in from $A04000
	btst #7,d2			
	bne SNDSetRegpause		;Wait until Bit 7 is zero
	rts
	
	