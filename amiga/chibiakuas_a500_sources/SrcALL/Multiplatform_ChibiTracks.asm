;Note: As addresses in ChibiTracks songs are 16 bit 
;Relocation support is MANDATORY on systems with a >16 bit address bus


chibitracks_allowspeedchange equ 1
;chibitracks_allowspeedchange_inst equ 1		;affect instruments too
;command byte definitions

Cmd_Ptch equ $0F	;&0F,n
Cmd_Volu equ $0E	;&0E,n - Absolute volume n
Cmd_Note equ $0D	;&0D,n - Play Note pitch n
Cmd_Loop equ $0C	;&0C,n - Jump back n bytes
Cmd_Inst equ $0B	;&0B,n - select instrument n

Cmd_VolA equ $F0	;&F0+n - Volume Adjust
Cmd_VolD equ $00	;&F0+ -n - Volume Adjust

Cmd_PtcD equ $E0	;&E0+n
Cmd_PtcU equ $D0	;&D0+n
Cmd_Nois equ $C0	;&C0+n (1/0) - Noise On/Off

Cmd_Pend equ $10	;&10 - Pattern End

Seq_Repeat equ 255


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	ifd chibitracks_allowspeedchange
speedmult:						;Multiply D0 by songspeed
		and.l #$FF,d0
		clr.l d1
		move.b (songspeed),d1
		mulu d1,d0		
		rts
	endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
startsong:		;Init song (set 'songbase' first)

	move.l #channelstate0,a2			;channel ram
	move.l #channeldatalengthtotal-1,d1	;Byte count

StartSong_ClearAgain:	
	clr.b (a2)+							;Zero Channel Data
	dbra d1,StartSong_ClearAgain
	
	move.b #0,(channelstate0+chn_Cnum)	;Set default channel numbers
	move.b #1,(channelstate1+chn_Cnum)
	move.b #2,(channelstate2+chn_Cnum)
	
			
	clr.l d0					;start with pattern 0 in sequence
startsongagain:
	move.l d0,-(sp)
		move.l (songbase),a3

		move.b (a3)+,d0			;get channel count
		move.b d0,(songchannels)
		move.b d0,d1			;Count
	
		addq.l #1,a3			;skip Repeat point
		
		move.b (a3)+,d0			;get Song Speed
		move.b d0,(SongSpeed)
;Base address of song - NOTE: All addresses are 16 bit little endian,
;and MUST be treated as offsets on >16 bit systems
		clr.l d2
		move.b (1,a3),d2		;Load Base address H
		rol.w #8,d2
		move.b (a3),d2			;Load Base address L
		
		move.l (SongBase),d0	;Calc offset
		sub.l d2,d0
		move.l d0,(songoffset)
		
	move.l (sp)+,d0				;D0= first Sequence Number
	
	addq.l #2+2+2,a3			;skip to sequence pointers 
								;(Skip SongAddr,PatternList,InstList)
								
								
	move.l #channelstate0,a4	;First Channel to init
startnextseq:
	movem.l d1/d3,-(sp)	;pushbc

		jsr initsongsequence			;init a channel
		add.l #channeldatalength,a4		;move to next channel
		
	movem.l (sp)+,d1/d3 ;popbc
	subq.b #1,d1				;repeat for other channels
	bne startnextseq
	rts

	
initsongsequence:	;D0= start pattern point

	move.l d0,-(sp)				;get address of sequence
		clr.l d1
		move.b (1,a3),d1		;Load Sequence address H
		rol.w #8,d1
		move.b (a3),d1			;Load Sequence address L
		addq.l #2,a3
		
		move.l (songoffset),a2		;add offset to Sequence address
		add.l d1,a2
				
		move.l a3,-(sp) ;push hl
			and.l #$FF,d0
			add.l d0,a2			;Add DO loop point
			
			jsr getnextsequence		;Load in the Pattern from the seq

			move.l a3,(chn_patL,a4)	;Save next sequence addr
			
			
			move.b #1,(chn_insT,a4)	;Force Instrument update
											 ;Play silent instrument
			move.l #instsilent,(chn_insl,a4) ;Save instrument address
		move.l (sp)+,a3 ;pop hl
	move.l (sp)+,d0
	rts

	
	
patternend:
	move.l (chn_seql,a4),a2		;Get Next sequence address
;	jmp getnextsequence
	
getnextsequence:
	move.b (a2),d0				;Next sequence
	cmp.b #255,d0
	beq restartsong				;255=End of sequence (restart)

	ifd debugsong
		move.l d0,-(sp)
			jsr newline
			jsr showhex			;Show new pattern for debug
			jsr newline
		move.l (sp)+,d0
	endif
	
	addq.l #1,a2				;move to next pattern
	move.l a2,(chn_seql,a4)		;save new pattern address
	
;Get pattern list address
	move.l (songbase),a2	
	addq.l #5,a2		;skip channels / loop point / Speed / Songbase

	clr.l d1
	move.b (1,a2),d1			;Load PatternList address H
	rol.w #8,d1
	move.b (a2),d1				;Load PatternList address L
;Add the offset
	move.l (songoffset),a2		;add offset to PatternList address
	add.l d1,a2
	
;Add PatternNum D0 to address
	and.l #$FF,d0
	lsl.l #1,d0					;2 bytes per pattern address
	add.l d0,a2					;get pattern address
	
;Get Pattern address
	clr.l d1
	move.b (1,a2),d1			;Load pattern address H
	rol.w #8,d1
	move.b (a2),d1				;Load pattern address L
;Add the offset	
	move.l (songoffset),a3		;add offset to pattern address
	add.l d1,a3
	
	move.b #1,(chn_patT,a4)		;Force an update
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

restartsong:					;at the end of pattern list
	add.l #4*5,sp				;clear down the stack

	move.l (songbase),a3
	addq.l #1,a3				;Skip channel count

	move.b (a3),d0				;get pattern repeat point (0=beginning)
	
	jsr startsongagain			;Reset sequence point
;	jmp chibitracks_play


;Play uses D0-D6 and A2-A4

chibitracks_play:
	move.l #channelstate0,a4		;Pointer to Channel Data
	move.b (songchannels),d1		;channel count

updatenextseq:
	movem.l d1/d3,-(sp) ;pushbc
		subq.b #1,(chn_patt,a4)		;pattern needs updating?
		bne NoPatternRead				;0=yes... process pattern
			jsr ReadPattern
NoPatternRead:


		move.b (chn_inst,a4),d0		;no delay (no more commands)
		beq updatenextseq_nochange
		
		Subq.b #1,(chn_inst,a4)
		bne NoChannelUpdate
			jsr UpdateChannel		;process channel instrument
NoChannelUpdate:


updatenextseq_nochange:
		add.l #channeldatalength,a4	;move to next channel
	movem.l (sp)+,d1/d3 ;popbc
	
	subq.b #1,d1					;Repeat for other channels
	bne updatenextseq
	jmp chibisoundpro_update		;Update hardware
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ReadPattern:
	move.l (chn_patl,a4),a3			;Load current pattern point
	
	move.b (a3),d0					;Get next pattern line time	
		ifd chibitracks_allowspeedchange
			jsr speedmult
		endif
	move.b d0,(chn_patt,a4)			;Update pattern line time
	addq.l #1,a3
	jsr processsoundcommands		;Read this lines commands

	move.l a3,(chn_patl,a4)			;Update current pattern point
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


UpdateChannel:					;Update instrument
	move.l (chn_insl,a4),a3		;Get instrument point

	move.b (a3),d0				;Get next inst delay
	cmp.b #0,d0
	beq stopinst				;0= Instrument ends
	
	ifd chibitracks_allowspeedchange_inst
		jsr speedmult
	endif

	move.b d0,(chn_inst,a4)		;update instrument delay
	addq.l #1,a3

	jsr processsoundcommands	;process instrument command line

	move.l a3,(chn_insl,a4)		;update instrument address
			
			
			
;We need to play the current tone

	move.b (chn_note,a4),d2		;Channel Note number
	move.b (chn_pitc,a4),d0		;pitch shift
	
	jsr tweentone				;a= ooooffff
								;o=offset -16 to +15 f=fraction 0-15
	ifd debugnotes
		move.b d2,d0			;show frequency for debug
		jsr showhex
		move.w d2,d0
		lsr.w #8,d0
		jsr showhex
	endif

	move.b (chn_volu,a4),d3		;Volume
stopinst2:

	move.b (chn_cnum,a4),d6		;Channel + noise state (bit 7)
	jmp chibisoundpro_set
	
stopinst:
	clr.l d3					;Instrument ended - silence channel
	jmp stopinst2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ProcessSoundCommands:		;process instrument/pattern commands

	move.b (a3)+,d0			;Get command

	cmp.b #0,d0
	beq instendb			;0=end of commands

	clr.l d1
	move.b d0,d1			;Back up byte for later
	
	and.b #$f0,d0			;Top nibble=command
	beq InstMultibyte		;0x=Multibyte commands

	cmp.b #$f0,d0			;xn commands x=command n=param
	beq InstVol
	cmp.b #$d0,d0
	beq InstPitchUp
	cmp.b #$e0,d0
	beq InstPitchDown
	cmp.b #$c0,d0
	beq InstNoise
	cmp.b #$10,d0
	beq PatternEnd
	
instendb:
	rts						;unknown! (shrug)
	
	;&B0 A0 90 80 70 60 50 40 30 20 spare!
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InstPitchDown:
	and.b #%00001111,d1			;pitch bend
	eor.b #%11111110,d1
	move.b d1,(chn_pitc,a4)		;bend down
	bra processsoundcommands

InstPitchUp:
	and.b #%00001111,d1			;pitch bend
	move.b d1,(chn_pitc,a4)		;bend up
	jmp processsoundcommands

	
InstVol:
	and.b #%00001111,d1			;volume shift
	rol.b #4,d1					;%VVVV----
	btst #7,d1
	bne InstVolDown
	add.b (chn_volu,a4),d1
	bcc InstVolDone
	move.l #255,d1				;over max vol
	
InstVolDone:
	move.b d1,(chn_volu,a4)		;volume
	jmp processsoundcommands

InstVolDown:
	add.b (chn_volu,a4),d1
	bcs instvoldone
	clr.l d1					;Under min vol
	move.b d1,(chn_volu,a4)
	jmp processsoundcommands

	
InstNoise:
	move.l #%01111111,d4		;Keep Channel Number
	and.b (chn_cnum,a4),d4		;%-CCCCCCC
	
	and.b #%00000001,d1			;noise
	ror.b #1,d1					;%N-------
	or.b d4,d1
	move.b d1,(chn_cnum,a4)		;Save New Noise/Channel setting
	jmp processsoundcommands

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InstMultibyte:			;0x,n commands x=command n=parameter 
	clr.l d4
	move.b (a3)+,d4		;Get parameter byte

	cmp.b #$0f,d1		;Check command
	beq InstBytePitch
	cmp.b #$0e,d1
	beq InstByteVol
	cmp.b #$0d,d1
	beq InstByteNote
	cmp.b #$0c,d1
	beq InstLoop
	cmp.b #$0b,d1
	beq InstPlayInstrument
	
	rts						;unknown! (shrug)
	
	;$0a 09 08 07 06 05 04 03 02 01 spare!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

InstByteNote:
	move.b d4,(chn_note,a4)		;note
	bra processsoundcommands

InstByteVol:
	move.b d4,(chn_volu,a4)		;vol byte
	bra processsoundcommands

InstBytePitch:
	move.b d4,(chn_pitc,a4)		;Bend byte
	bra processsoundcommands
	
	
InstLoop:
	or.l #$FFFFFF00,d4			;Sign extend as negative
	add.l d4,a3					;Jump back to previous script pos
	bra processsoundcommands

	
InstPlayInstrument:
	lsl.l #1,d4					;2 bytes per inst address
		
	move.l (songbase),a2
	addq.l #5+2,a2				;Jump to instrument list
	
	clr.l d1
	move.b (1,a2),d1			;Get Address of Inst Table H
	rol.w #8,d1
	move.b (a2),d1				;Get Address of Inst Table L

	move.l (songoffset),a2		;Get offset

	add.l d1,a2					;Add Instrument table address
	add.l d4,a2					;Add required Instrument number
	
	clr.l d1
	move.b (1,a2),d1			;Load Inst address H
	rol.w #8,d1
	move.b (a2),d1				;Load Inst address L
	add.l (songoffset),d1		;Add offset
	
	move.b #1,(chn_inst,a4)		;Trigger sound
	move.l d1,(chn_insl,a4)		;Address of instrument script
	bra processsoundcommands

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Unlike Z80, 68000 uses 32 bytes per channel due to 24 bit addresses
channeldatalength equ 32	


;96 bytes - but should allocate at least 64+32 (32 for platform vars)
channeldatalengthtotal equ 32*3

channelstate0 equ chibisoundram
channelstate1 equ chibisoundram+32
channelstate2 equ chibisoundram+32+32

;                                     


;Channel data layout
chn_Note equ 0
chn_Volu equ 1
chn_Cnum equ 2
chn_Pitc equ 3
chn_InsL equ 4		;4 bytes
chn_InsT equ 8
chn_PatT equ 9	
chn_PatL equ 10		;4 bytes
chn_SeqL equ 14		;4 bytes

	; align 8
; dchannelstate0:
	; dc.b 0				;note (0-55) 0
	; dc.b 255			;volume 1
	; dc.b 0				;channel/noise state 2
	; dc.b 0				;pitch shift 3 
	; dc.l instsilent		 ;4 5 6 7
	; dc.b 1				;timeout for current inst state 8
	; dc.b 0				;9 timeout
	; dc.l 0				;10 11 12 13 pattern 
	; dc.l 0 				;14 15 16 17 sequence
	; ds.b 14
	
; dchannelstate1:
	; dc.b 0				;note (0-55) 0
	; dc.b 255			;volume 1
	; dc.b 1				;channel/noise state 2
	; dc.b 0				;pitch shift 3 
	; dc.l instsilent		 ;4 5 6 7
	; dc.b 1				;timeout for current inst state 8
	; dc.b 0				;9 timeout
	; dc.l 0				;10 11 12 13 pattern 
	; dc.l 0 				;14 15 16 17 sequence
	; ds.b 14
	
; dchannelstate2:
	; dc.b 0				;note (0-55) 0
	; dc.b 255			;volume 1
	; dc.b 2				;channel/noise state 2
	; dc.b 0				;pitch shift 3 
	; dc.l instsilent		 ;4 5 6 7
	; dc.b 1				;timeout for current inst state 8
	; dc.b 0				;9 timeout
	; dc.l 0				;10 11 12 13 pattern 
	; dc.l 0 				;14 15 16 17 sequence
	; ds.b 14
	
InstSilent:
	dc.b 0
	
	even
	
	