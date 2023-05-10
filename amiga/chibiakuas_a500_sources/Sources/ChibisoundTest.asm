Cursor_X equ UserRam
Cursor_Y equ UserRam+1
	
ChibiSoundUseFM equ 1 	;Only for genesis
;ChibiSoundUseFMZ80 equ 1	;only for genesis
	
	include "\SrcALL\V1_Header.asm"
	include "\SrcALL\BasicMacros.asm"
	
	ifd ChibiSoundUseFMZ80		;Need Init on SNS
		jsr ChibiSound_INIT
		
		move.l #$A01F80,a0		;Test to see if Z80 code is running
		moveq.l #1,d0
		jsr Monitor_MemDumpDirect
	endif
	
	move.l #$80,d0
infloop:
	move.b #0,d3
	move.b #0,d6
	jsr Locate
	
	move.l d0,-(sp)
	jsr Monitor_PushedRegister
	
	ifd BuildAMI
		move.l #$0000FFFF,d2
	else
		ifd BuildSQL
			move.l #$00004FFF,d2
		else
			move.l #$0000FFFF,d2
		endif
	endif
	
Pauser:	
	dbra d2,Pauser
	subq.l #1,d0
	move.l d0,-(sp)
		jsr ChibiSound
	move.l (sp)+,d0
	

	ifd BuildNEO
		jsr KickWatchdog
	endif
	
	jmp infloop
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	include "\SrcAll\V1_ChibiSound.asm"
	
	include "\SrcALL\V1_BitmapMemory.asm"
	include "\SrcALL\V1_VdpMemory.asm"
	include "\SrcALL\V1_Functions.asm"
	include "\SrcALL\Multiplatform_Monitor.asm"
	
	include "\SrcALL\V1_DataArea.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Data Area
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	ifnd BuildNEO			;NeoGeo Doesn't use font
Font:
	incbin "\ResALL\Font96.FNT"
	endif
Message: dc.b 'Hello World!!!',255
	even


	include "\SrcALL\V1_RamArea.asm"
	
wavNoise:	;Random noise
	dc.b	195,184, 71, 82,141,186, 62,131
	dc.b	135,217,250,193, 80,152,194,  2
	dc.b	228, 51,171,121, 73,117,107,210
	dc.b	106,228,241,131,229,150,118, 81
wavNoiseEnd:

wavTone:	;Square Wave
	dc.b 	0,		90,		0,		90
wavToneEnd	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Ram Area - May not be possible on all systems!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\SrcALL\V1_Footer.asm"