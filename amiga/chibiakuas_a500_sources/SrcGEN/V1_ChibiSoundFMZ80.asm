ChibiSound_INIT:

	; Disable the Z80
	move.w  #$100,$a11100		;Z80 Bus REQ
	move.w  #$100,$a11200		;Z80 Reset

	jsr ChibiSound_Z80Wait		;Wait for Z80 ram to be available

	move.l #$A00000,a1			;Destination (&0000 in the Z80)
	move.l #ChibiSoundDriver,a0	;Source
	move.l #ChibiSoundDriverEnd-ChibiSoundDriver,d1	;Length

ChibiSound_Copy:	
	move.b (a0)+,(a1)+			;Send the program to the Z80
	dbra d1,ChibiSound_Copy
	
	;Restart the Z80
	move.w  #$000,$a11100	;Z80 Bus REQ
	move.w  #$000,$a11200	;Z80 Reset
	move.w  #$100,$a11200	;Z80 Reset
	
	rts
	
ChibiSound_Z80Wait:
	move.w $a11100,d1
	btst #8,d1				;Bit 8...0- Z80 stop / 1 = Z80 running
	bne ChibiSound_Z80Wait	
	rts
	
ChibiSound:					;NVTTTTTT	Noise Volume Tone 
	
	move.w  #$100,$a11100	;Z80 Bus REQ
	
	jsr ChibiSound_Z80Wait
	
	move.b  d0,$A01F00		;Sound Byte
	move.b  #$FF,$A01F01	;NonZero=Change sound
	move.w  #$000,$a11100	;Z80 Bus REQ
	
	rts
	
	
ChibiSoundDriver:	
	incbin "\BldGEN\z80prog.bin"
ChibiSoundDriverEnd:	
	even
	
; _ Z80 BUSREQ _
	; When accessing the Z80 memory from the 68000,
	; first stop the Z80 by using BUSREQ. At the time
	; of POWER ON RESET, the 68000 has access to the
	; Z80 bus.
	; $A11100 D8 ( W) O: BUSREQ CANCEL
	; 1: BUSREQ REQUEST
	; ( R ) 0: CPU FUNCTION STOP ACCESSIBLE
	; 1: FUNCTIONING
	; Access to Z80 AREA in the following manner.
	; (1) Write $0100 in $A11100 by using a WORD access.
	; (2) Check to see that D8 of $A111OO becomes O.
	; (3) Access to Z80 AREA.
	; (4) Write $0000 in $A111O0 by using a WORD access.
	; Access to $A111O0 can also be based on BYTE.
; _ Z80 RESET _
	; The 68000 may also reset the Z80. The Z80 is automatically reset during the
	; MEGA DRIVE hardware's POWER ON RESET sequence.
	; $A11200 DS ( W) O: RESET REQUEST
	; 1: RESET CANCEL
	; Access to $A111O0 can also be based on BYTE.