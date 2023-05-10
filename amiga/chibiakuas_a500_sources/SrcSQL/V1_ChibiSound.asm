	;NVPPPPPP	P=Pitch N=Noise	;V=Volume (Vol NOT AVAILABLE ON QL)
		
Chibisound:
	moveM.l d0-d7/a0-a7,-(sp)
		move.l d0,d1			;Back up regsiter for later
	
		cmp.b #0,d0				;See if we need to mute soun
		beq ChibiSoundSilent	
		
		lea SoundCommand,a3		;Load address of sounbd command
		
		and.b #%00111111,d0		; 6 pitch bits
		addq.b #1,d0
		move.b d0,(a3,6)		;Pitch 1
		
		move.b #$CC,d0			;Random noise byte
		
		btst #7,d1				;Check noise bit
		bne ChibiSoundNoise

		move.b #$00,d0			;No Noise byte
ChibiSoundNoise:		
		move.b  d0,(a3,13)		;Randomness 

ChibiSoundSilentB:		
		move.l #$11,d0			;Command 17
		Trap #1					;Send Keyrequest to the IO CPU
								;Returns row in D1
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
ChibiSoundSilent:
		lea     SilentCommand,a3   ; Sound Stop Command
    bra ChibiSoundSilentB
	
SoundCommand:
    dc.b $A			; 0 Command	byte (Initiate sound)	
	dc.b 8			; 1 Bytes to follow
	dc.l $0000AAAA	; 2 Byte Parameters
    dc.b 0          ; 6 Pitch 1
	dc.b 0          ; 7 Pitch 2
    dc.w 0			; 8 interval between steps (0,0)
	dc.w $FFFF     	; 10 Duration (65535)
    dc.b 0			; 12 step in pitch (4bit) / wrap (4bit)
	dc.b 0          ; 13 randomness of step (4bit) / fuzziness (4bit)
    dc.b 1          ; 14 No return parameters
        
SilentCommand:
    dc.b $B		 	; 0 Command byte (Kill Sound)
	dc.b 0			; 1 Bytes to follow
    dc.l $0     	; 2 Send no data
    dc.b 1 			; 6 No return parameters
		
	even
		
		
		