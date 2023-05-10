
chibiOctave:
		;   e     f     g      a     b     c     d   
	 dc.w $0800,$0C00,$1000,$1400,$1800,$1C00,$2000	;0
;     ;   41.2  43.6   49    55   61.7  65.4  73.4
    dc.w $0340,$0370,$03d8,$0458,$04d0,$0508,$05a8	;1
	  ;   82.4  87.3  98    110   123    130   146
	dc.w $0660,$06c8,$0790,$0880,$0998,$0a10,$0b50		;2
   	  ;   164   174    196   220 	246   261   293
	dc.w $0cb0,$0d90,$0f38,$10f8,$1308,$1430,$16a0		;3
      ;   329   349   392   440   493   523    587
	dc.w $1960,$1af0,$1e30,$21f0,$2618,$2858,$2d28		;4
   	  ;   659   698   783   880   987   1046  1174
	dc.w $32d8,$35c8,$3c50,$43b8,$4be0,$5080,$5a60		;5
	  ;   1318  1396  1567  1760  1975  2093  2349
	dc.w $6578,$6b60,$7888,$8748,$97e0,$a0f8,$b4a8		;6
	dc.w $BC00,$C400,$CC00,$D400,$E000,$F000,$ffff		;7
	
	even
	
;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)
	
chibisoundpro_set:
	jsr ChibiSoundPro_GetChannelAddr	;Get A1/A0 and D5

	cmp.b #0,d3			;%VVVVVVVV
	bne NotSilent		;Vol=0?
	
;silent		;Mute channel
	
	move.b 5(a1),d1  ;KEY ON
		   ;OOOO-CCC	O=operator (4321) / C=Channel (0=chn 1)
	and.b #%00000111,d1	;All ops off for this channel
	move.l #$A04000,a0	
	move.b #$28,d0		;Individual Operator Key On/Off	
	jmp SNDSetReg1			;Reg D0 = Val D1
	
NotSilent:	
	
;Set Frequency
	lsr.w #2+3,d2		;Pitch
		;  --BBBFFFffffffff
	or.w #%0011000000000000,d2
	
	move.l d2,d1		;Must write H first
	
	lsr.w #8,d1
	move.b #$A4,d0		;--OOOPPP	O=Octave / P=Position H
	jsr SNDSetReg1chn			;Frequency MSB
	
	move.w d2,d1
	move.b #$A0,d0		;PPPPPPPP	P=Frequency Position L
	jsr SNDSetReg1chn			;Frequency LSB	
	
	
	move.b 5(a1),d7  		;KEY ON command
	
;Clean Tone
			;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity
	move.b #%11000000,d1  		;F=Frequency Mod Sensitivity
	
	
	btst #7,d6				;%N-------
	beq chibisoundpro_NoNoise	;Noise off?
	
	and.b #%00000111,d7		;Turn off tone ops
	or.b  #%00110000,d7		;Turn on noise ops
	
;Distorted Tone
			;LRAA-FFF	Left / Right (1=on) / A=Amplitude Mod Sensitivity
	move.b #%11110111,d1  		;F=Frequency Mod Sensitivity
		
chibisoundpro_NoNoise:	
	move.b #$B4,d0
	jsr SNDSetReg1chn		;Stereo output
	
	
;Fix Volume
	clr.l d1
	lsr.b #4,d3				;Reorder Vol bits
	roxr.b d3				;%7654----  -> %----4567
	roxl.b d1
	roxr.b d3
	roxl.b d1
	roxr.b d3
	roxl.b d1
	roxr.b d3
	roxl.b d1
	eor.b #%00001111,d1		;Flip the bits
	
;Set Volume	
	move.b #$40+4,d0		;-TTTTTTT	T=Total Level (0=largest) 
	jsr SNDSetReg1chn				;Volume of Op 2
	
	move.b #$40+12,d0		;-TTTTTTT	T=Total Level (0=largest) 
	jsr SNDSetReg1chn				;Volume of Op 4
	
;Key On!
	move.l #$A04000,a0	
	
	move.b #$28,d0	;Individual Operator Key On/Off
	move.b d7,d1	;OOOO-CCC	O=operator / 
	jmp SNDSetReg1			;C=Channel (0/1/2=chn1/2/3 4/5/6=chn4/5/6)
		
chibisoundpro_update:
	rts
	
	
DoClearSoundRegs:		
	move.b #$20,d0
	clr.b d1
chibisoundpro_ClearAgain	
	jsr SNDSetReg1			;Reg D0 = Val D1
	addq.b #1,d0
	cmp.b #$b7,d0
	bne chibisoundpro_ClearAgain
	rts

chibisoundpro_init:
	; Disable the Z80 so we have control of sound
	move.w  #$100,$a11100	;Z80 Bus REQ
	move.w  #$100,$a11200	;Z80 Reset
	
	
	move.l #$A04002,a0		;Address Base
	jsr DoClearSoundRegs	;Clear all regs
	
	move.l #$A04000,a0		;Address Base
	jsr DoClearSoundRegs	;Clear all regs
		
	move.b #$29,d0
			;S--IIIII	S=Sixchannel / I=IRQ Enable
	move.b #%10000000,d1  ;6 channels
	jsr SNDSetReg1			;Reg D0 = Val D1
		
	move.b #$22,d0 
			;----EFFF	E=enable F=frequency
	move.b #%00001111,d1  ;Turn on LFO
	jsr SNDSetReg1			;Reg D0 = Val D1
	
	
	move.b #0,d6	;Chn num
chibisoundpro_initchn:		
		jsr ChibiSoundPro_GetChannelAddr
		
;One per channel
				;LRAA-FFF	Left / Right (1=on) / 
							;A=Amplitude Mod Sensitivity
		move.b #%11110111,d1  	;F=Frequency Mod Sensitivity
		move.b #$B4,d0
		jsr SNDSetReg1chn		;Stereo output
			
		move.b #$B0,d0
		move.b #%00100100,d1
				;--FFFAAA	F=Feedback / A=Algorithm
		jsr SNDSetReg1chn	
						
						
;Channel op Defaults

		move.b #0,d7	;Op num
	chibisoundpro_initOp:		
		
			move.b #$30,d0
					;-DDDMMMM	D=Detune / M=Multiplier
			move.b #%00000001,d1  ;Multiplier = 1 (pitch scale)
			jsr SNDSetReg1chn
			
			move.b #$40,d0	
					;-TTTTTTT	T=Total Level (0=largest) 
			move.b #%00000000,d1	
			jsr SNDSetReg1chn				;Volume of Op
					
			move.b #$50,d0
					;RR-AAAAA	R=Rate Scaling / A = Attack rate
			move.b #%00011111,d1  ;Attack Rate=31 
			jsr SNDSetReg1chn

			move.b #$60,d0
					;A--DDDDD	A=Amplitude Mod Enable / D= Decay rate
			move.b #%10011111,d1  ;0= Keep tone constant (allow LFO)
			jsr SNDSetReg1chn
					
			move.b #$70,d0
					;---SSSSS	S=Sustain Rate
			move.b #%00000000,d1  
			jsr SNDSetReg1chn		
					
			move.b #$80,d0
					;SSSSRRRR	S=Sustain Level / Release Rate
			move.b #%00001111,d1  ;Sustain=15 , Release=15
			jsr SNDSetReg1chn
			
			move.b #$90,d0
					;----EEEE	E=Envelope Gen
			move.b #%00000000,d1  
			jsr SNDSetReg1chn	
			
			addq.b #4,d5	;Next Op
			
		addq.b #1,d7
		cmp.b #4,d7
		bne chibisoundpro_initOp	;Next op
					
					
;Channel op Default overrides
			
		jsr ChibiSoundPro_GetChannelAddr
		
		move.b #$80+4,d0	;Op2 for channel
				;SSSSRRRR	S=Sustain Level / Release Rate
		move.b #%01001111,d1  ;Sustain=15 , Release=15
		jsr SNDSetReg1chn
				
		
	addq.b #1,d6
	cmp.b #6,d6
	bne chibisoundpro_initchn	;Next Channel
	
	rts

	
SNDSetReg1chn:				;Set Reg D5+D0 to Val D1

	add.b d5,d0				;Add channel offset
	
SNDSetReg1:					;Set Reg D0 to Val D1
			
	jsr SNDSetRegpause
	move.b d0,(a0)			;Write the register number to $A04000
	jsr SNDSetRegpause
	move.b d1,(1,a0)		;Write the new value to $A04001
	rts
	
SNDSetRegpause:
	move.b (a0),d4			;Read in from $A04000
	btst #7,d4
	bne SNDSetRegpause		;Wait until Bit 7 is zero
	rts
		
	

ChibiSoundPro_GetChannelAddr: ;D6=Channel number

	move.b d6,d0			;%-CCCCCCC
	and.l #%00000111,d0
	lsl.l #3,d0				;8 bytes per cnannel in lookup
	
	move.l #ChannelLookup,a0 ;Channel Map
	
	lea (0,a0,d0),a1		;Address of map->A1

	move.l (a1),a0			;Port Address
	
	clr.l d5
	move.b (4,a1),d5		;Channel Num
	;move.b 5(a1),d7 		;Key on command
	rts
	
	
	align 4
ChannelLookup:
	dc.l $A04000		;Port 				Chn1
	  dc.b 0			;Reg offset
	  dc.b %11100000	;Kon mask for tone (0)
	  dc.b 0,0	;Unused
	dc.l $A04000		;Port 				Chn2
	  dc.b 1			;Reg offset
	  dc.b %11100001	;Kon mask for tone (1)
	  dc.b 0,0	 
	dc.l $A04000		;Port 				Chn3
	  dc.b 2			;Reg offset
	  dc.b %11100010	;Kon mask for tone (2)
	  dc.b 0,0
	  
	dc.l $A04002		;Port 				Chn4
	  dc.b 0			;Reg offset
	  dc.b %11100100	;Kon mask for tone (4!)
	  dc.b 0,0			
	dc.l $A04002		;Port 				Chn5
	  dc.b 1			;Reg offset
	  dc.b %11100101	;Kon mask for tone (5!)
	  dc.b 0,0	 
	dc.l $A04002		;Port 				Chn6
	  dc.b 2			;Addr offset
	  dc.b %11100110	;Kon mask for tone (6!)
	  dc.b 0,0
	
	dc.l $A04002
	  dc.b 1
	  dc.b %11100100
	  dc.b 0,0	 
	dc.l $A04002
	  dc.b 2
	  dc.b %11100101
	  dc.b 0,0	
	  
	  even
	  

