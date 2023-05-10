
ChibiOctave:
	;   E     F     G      A     B     C     D   
	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0000 
	;   41.2  43.6   49    55   61.7  65.4  73.4
	dc.w $0000,$0400,$2200,$3b00,$5000,$5900,$6c00 ;1
	;   82.4  87.3  98    110   123    130   146
	dc.w $7d00,$8500,$9300,$a000,$ab00,$b000,$b900 ;2
	;	  164   174    196   220 	246   261   293
	dc.w $c200,$c600,$cd00,$d300,$d900,$db00,$e000 ;3
	;     329   349   392   440   493   523    587
	dc.w $e400,$3600,$ea00,$ed00,$f000,$f100,$f300 ;4
	;    659  698   783   880   987   1046  1174
	dc.w $FE00,$FE00,$FE00,$FE00,$FE00,$FE00,$FE00 ;5
	
	;   1318  1396  1567  1760  1975  2093  2349
	dc.w $FE00,$FE00,$FE00,$FE00,$FE00,$FE00,$FE00 ;6
	dc.w $FE00,$FE00,$FE00,$FE00,$FE00,$FE00,$FE00
	
;d3=volume (0-255) 
;d6=channel num / top bit=noise
;d2=pitch (0-65535)

chibisoundpro_Set:
	move.l #ChannelCache,a0
	move.b d6,d0
	and.l #%00000011,d0		;Simulate 4 channels
	lsl.l #2,d0				;4 bytes per cache entry
	add.l d0,a0
	
;Update the cache
	move.b d6,(0,a0)		;Chn num (1)
	move.b d3,(1,a0)		;Vol 	 (1)
	move.w d2,(2,a0)		;Pitch   (2)

	
;Check the cache for loudest channel
	moveM.l a3-a6,-(sp)
		clr.b d3
		move.l #3,d0
		move.l #ChannelCache,a0
NextChannel:		
		cmp.b (1,a0),d3			;Loudest channel?
		bcc NextChannelB
		beq NextChannelB		;Nope... Next!
	
		move.b (0,a0),d6		;Yes - get settings!
		move.b (1,a0),d3
		move.w (2,a0),d2
	
NextChannelB:		
		addq.l #4,a0			;Last Channel?
		dbra d0,NextChannel
		
	
		move.b d3,d0				;See if we need to mute sound
		and.l #%11110000,d0
		bne ChibiSoundNotSilent	
		
;Silent
		lea SilentCommand,a3   ; Sound Stop Command
		bra ChibiSoundSilentB
ChibiSoundNotSilent:	
		
		
		lea SoundCommand,a3		;Load address of sound command
		
;Pitch
		eor.w #$FFFF,d2			;Fix pitch
		
		move.w d2,d0
		lsr.w #8,d0
		move.b d0,(6,a3)		;Pitch 1 H
		
		move.b d2,(7,a3)		;Pitch 2 L
		
		
;Noise
		move.b #$CC,d0			;Random noise byte
		
		btst #7,d6				;Check noise bit
		bne ChibiSoundNoise

		move.b #$00,d0			;No Noise byte
		
ChibiSoundNoise:		
		move.b  d0,(13,a3)		;Randomness 

		
ChibiSoundSilentB:		

;Send Data
		move.l #$11,d0			;Command 17
		Trap #1					;Send Keyrequest to the IO CPU
								;Returns row in D1
	moveM.l (sp)+,a3-a6
chibisoundpro_init:
chibisoundpro_update:
	rts
	
	
	
ChannelCache equ chibisoundram+256	;Channel Cache
	
	
SoundCommand:
    dc.b $A			; 0 Command	byte (Initiate sound)	
	dc.b 8			; 1 Bytes to follow
	dc.l $0000AAAA	; 2 Byte Parameters
    dc.b 0          ; 6 Pitch 1 H
	dc.b 0          ; 7 Pitch 2 L
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
		
		
		