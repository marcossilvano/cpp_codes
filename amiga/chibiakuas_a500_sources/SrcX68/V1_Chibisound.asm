;$E90001		FM Synthesizer (YM2151) - Register Address Write port
;$E90003		FM Synthesizer (YM2151) - Data R/W port

;We're using Channel 7 and slot 3 (3*8=24)
	
ChibiSoundSilent:
	move.b #$60+24+7,$E90001	;-VVVVVVV	[Slot] Volume (0=Max)
	move.l #%01111111,d0		;Mute sound
	move.b d0,$E90003
ChibiSound_INIT:
	rts
	
ChibiSound:						;NVPPPPPP	Noise, Volume, Pitch

	and.l #$000000FF,d0			;Check if D0=zero
	beq ChibiSoundSilent
	
	eor.b #%00111111,d0			;Flip pitch bits
	move.l d0,d1				;Save for later

	move.b #$20+7,$E90001			;LRFFFCCC - Left/Right Feedback,Connection
	move.b #%11000000,$E90003	

	move.b #$28+7,$E90001		;-OOONNNN - Key Octive + Note
	move.l d1,d0
	and.b #%00111111,d0
	rol #1,d0
	move.b d0,$E90003
	
	move.b #$60+24+7,$E90001 	;-VVVVVVV - [Slot] Volume (0=Max)
	move.l d1,d0
	and.b #%01000000,d0
	eor.b #%01000000,d0
	ror #2,d0
	move.b d0,$E90003

	move.b #$E0+24+7,$E90001	;DDDDRRRR - [Slot] Decay / Release rate
	move.b #%00001111,$E90003				;(15=Constant tone)
	
	move.b #$1B,$E90001			;DC----WW - D=fdD force ready, C=Clock (4mhz/8mhz) 
	move.b #%01000001,$E90003				;W=Waveform (0=Saw 1=Square,2=Tri, 3=Noise)
	
	move.b #$0F,$E90001			;E--FFFFF - Noise Enable Freq 
	move.b #%00000000,$E90003				;(Slot 3 - channel 7)
	
	move.b #$08,$E90001			;-SSSSCCC - Channel / Slot
	move.b #%01000111,$E90003				;(Channel 7 - Slot 3)
	
	move.l d1,d0
	and.b #%10000000,d0
	bne ChibiSoundNoiseOn		;Enable niose
	rts
	
ChibiSoundNoiseOn:
	move.b #$0F,$E90001			;E--FFFFF - Noise Enable Freq 
	move.l d1,d0					;(Slot 3 - channel 7)
	and.b #%00111110,d0
	ror #1,d0
	or.b  #%10000000,d0			;Top bit turns on noise
	move.b d0,$E90003
	rts
