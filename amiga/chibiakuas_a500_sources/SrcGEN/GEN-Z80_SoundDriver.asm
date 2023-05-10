	org &0000
	jr StartOfCart		;RST 0
	ds 6,&C9			;RST 0
	
	ds 8,&C9			;RST 1
	ds 8,&C9			;RST 2
	ds 8,&C9			;RST 3
	ds 8,&C9			;RST 4
	ds 8,&C9			;RST 5
	ds 8,&C9			;RST 6
	ifdef	Interrupts_UseIM1 
		jp InterruptHandler	;RST 7
		ds 5,&C9			;RST 7
	else
		ds 8,&C9			;RST 7
	endif
	ds 32,&C9			;RST 6
StartOfCart:	
	di      ; disable interrupts
    im 1    ; Interrupt mode 1
    ld sp, &2000
	
	ld a,&69			;This is a marker to check the Z80 started correctly!
	ld (&1F80),a
	ld (&1F81),a
	;Check the marker from the 68000 with:
	;	move.l #$A01F80,a0
	;	moveq.l #1,d0
	;	jsr Monitor_MemDumpDirect
	
MainLoop:	
	ld a,(&1F01)	;Wait for a sound command
	or a
	jr z,MainLoop
	
	ld a,(&1F00)
	call ChibiSound	;Process the command
	
	xor a			;Clear sound command
	ld (&1F01),a	
	jp MainLoop
	
	include "GEN-Z80_V1_ChibiSoundFM.asm"
	
	
	