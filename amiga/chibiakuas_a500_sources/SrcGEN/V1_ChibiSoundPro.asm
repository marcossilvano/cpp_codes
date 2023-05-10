
;SmsSimpleNoise equ 1	;This limits noise frequency to 0-2
						;Otherwise we use channel 2 for frequency

;SmsTranspose equ 1		;The SMS can't do accurate low tones



chibiOctave:
		;   e     f     g      a     b     c     d   
	   dc.w $0020,$0030,$0040,$0080,$00c0,$0100,$0140	;0
;       ;   41.2  43.6   49    55   61.7  65.4  73.4
	ifnd smstranspose
	   dc.w $0180,$01c0,$0200,$0240,$0280,$02c0,$0300	;1
	endif
 	  ;   82.4  87.3  98    110   123    130   146
	dc.w $0340,$0380,$03c0,$03aa,$1d5e,$295a,$4161		;2
   	  ;   164   174    196   220 	246   261   293
	dc.w $562a,$6024,$717c,$80db,$8e9d,$9516,$a0a5		;3
      ;   329   349   392   440   493   523    587
	dc.w $ab17,$afc3,$b8a2,$c076,$c746,$ca8f,$d060		;4
   	  ;   659  698   783   880   987   1046  1174
	dc.w $d566,$d7de,$dc17,$e01a,$e3af,$e520,$e801		;5
	  ;   1318  1396  1567  1760  1975  2093  2349
	dc.w $eaae,$ebeb,$ee11,$f003,$f1c3,$f2b2,$f3d2		;6
	dc.w $f400,$f600,$f800,$facc,$fc00,$fe00,$ffff		;7
	even
	
	
;d3=volume (0-255) 
;d6=channel num (0-127 unused channels will wrap around) / top bit=noise
;d2=pitch (0-65535)

chibisoundpro_set:
	move.l #channelmask,a1		;Channel bit lookup
	clr.l d0
	move.b d6,d0
	and.b #%00000011,d0			;We only have 3 channels
	move.b (a1,d0),d1			;Lookup table for channel bits 

	btst #7,d6					;Noise Bit
	bne chibisoundpro_noise		;Noise on!
	
	
	move.l #channelnoise,a1
	cmp.b #0,(a1,d0)			;Get Noise state
	beq noisestilloff			;Check if we need to turn off noise

	move.b #%11111111,d4		;noise was on, now off
	move.b d4,$C00011

	clr.b (a1,d0)				;Clear Noise flag
	jmp noisestilloff
	
		
chibisoundpro_noise:
	move.b #%10011111,d0	;Mute Channel
	or.b d1,d0				;channelnum
	move.b d0,$C00011
	
	clr.l d0
	move.b d6,d0
	and.b #%00000011,d0			;We only have 3 channels
	move.l #channelnoise,a1
	move.b #1,(a1,d0)		;Set noise state of 'virtual channel' to on
	
	ifd smssimplenoise			;Only 2 bit noise
		move.w d2,d0
		and.w #%1100000000000000,d0	;Top two noise bits
		eor.w #%1100000000000000,d0
		rol.w #2,d0
		beq noisezero
		subq.b #1,d0
noisezero:
		or.b #%11100100,d0		;Enable our noise channel (3)
		move.b d0,$C00011
		
		move.b d3,d0			;Volume %VVVVVVVV
		lsr.b #4,d0				;Volume %----VVVV
		eor.b #%11111111,d0		;set volume (chn3)
		move.b d0,$C00011
		rts

	else				;Full Frequency noise, but use Chn2
	
		move.b #%11011111,d0	;1cctvvvv	(latch - channel type volume)
		move.b d0,$C00011		;mute tone 2 (Just need it's frequency)
			    ;1cct-mrr	(latch - channel type... noise mode
		move.b #%11100011,d0	;1cct-mrr	(latch - channel type... 
		move.b d0,$C00011		;noise mode (1=white) rate 
								;(rate 11= use tone channel 2)
	
		move.b #%01000000,d1	;noise channel uses tone 2
		
		lsr.w #3,d2				;Adjust frequency range for noise
		move.w d2,d0				;(Didn't need this on SMS!)
		lsr.w #1,d0
		add.w d0,d2
		add.w #$D000,d2
	endif

	
noisestilloff:
	not.w d2				;Flip Frequency bits
	lsr.w #2,d2				;Bitshift  %DDDDDDDD EEEEEEEE;
							;to 10 bit %--DDDDDD DDEE----
									
	move.b d2,d0	
	lsr.b #4,d0				;Low Tone 4-bits    %----DDEE
	
	or.b #%10000000,d0      ;1cctllll	(latch - channel type datal
	or.b d1,d0				;channelnum
	move.b d0,$C00011

	move.w d2,d0
	lsr.w #8,d0				;High Tone 6 bits   %--DDDDDD
	and.b #%00111111,d0		;high tone %--hhhhhh
	move.b d0,$C00011

	
	move.b d3,d0			;Volume
	lsr.b #4,d0	

	ifnd smssimplenoise
		btst #7,d6			;we're done if there is no noise
		beq noiseoff
		move.l #%01100000,d1	;Want to set volume of channel 3
noiseoff:		
	endif
	
	eor.b #%10011111,d0		;set volume %----VVVV
	or.b d1,d0				;channelnum
	move.b d0,$C00011
	
chibisoundpro_init:
chibisoundpro_update:
	rts


	align 4
channelmask:
	dc.b %00000000,%00100000,%01000000,%00000000 ;Chn4 will use Chn 0

				;First 64 chibisound bytes reseved for tracker
channelnoise equ chibisoundram+channeldatalengthtotal+16

