smstranspose equ 1

DebugSong equ 1
DebugNotes equ 1

Cursor_X equ UserRam
Cursor_Y equ UserRam+2

;NeoJoy_UseBios equ 1

	ifd BuildSQL
chibisoundram equ UserRam+$100	
SQL_RelocateProg equ 1
	endif
	ifd BuildGEN
chibisoundram equ $00FF1000
	endif

	ifd BuildNEO
chibisoundram equ $101100
	endif

	ifd BuildAST
chibisoundram equ UserRam+$600
	endif
	
	ifd BuildX68
chibisoundram equ UserRam+$200	
	endif


SongOffset equ ChibiSoundRam+128 ; dc.l 0	;Remap internal addresses in song (eg compiled for $8000,loaded to $2000 = offsets of -$6000
SongBase  equ SongOffset+4 ; dc.l Song1
SongChannels equ SongBase+4 ; dc.b 0
SongSpeed equ  SongChannels+1 ; dc.b 0


	include "\SrcALL\BasicMacros.asm"
	include "\SrcALL\V1_Header.asm"
	
	jsr KeyboardScanner_AllowJoysticks	;Turn on joysticks on systems that need init
		
	move.l #Song1,a3
	move.l a3,(SongBase)
	
	jsr chibisoundpro_init
	
	jsr StartSong 
	
Loop:				
	
	jsr ChibiTracks_Play
	;jsr monitor
	move.l #$4000,d7
delay2:	
	dbra d7,delay2

	
	
	moveM.l d1-d7,-(sp)
		;jsr cls
		move.l #0,d3
		move.l #0,d6
		jsr Locate
	moveM.l (sp)+,d1-d7
	
	jmp Loop
;                                     



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
 
	macro DC_LittleEndianW
		dc.b (\1)&$FF
		dc.b (\1)/256
	endm


;H=Volume (0-255) 
;L=Channel Num (0-127 unused channels will wrap around) / Top Bit=Noise
;DE=Pitch (0-65535)
	even
Song1:
	;incbin "\ResAll\ChibiSoundPro\Song1000.cbt"
	;include "\ResAll\ChibiSoundPro\CBT1.asm"
	;incbin "\ResAll\ChibiSoundPro\song.cbt"
	;incbin "\ResAll\ChibiSoundPro\song2.cbt"
	incbin "\ResAll\ChibiSoundPro\ChibiAkumasTheme.cbt"
	;include "\ResAll\ChibiSoundPro\Song2.asm"
	even
	
	ifd NeedInstruments
Instrumentlist:
	DC_LittleEndianW InstCymbol-Song1 	;0
	
	DC_LittleEndianW InstKick-Song1 		;1
	DC_LittleEndianW InstSnare-Song1 	;2
	DC_LittleEndianW InstTone-Song1 		;3
	DC_LittleEndianW InstSilent-Song1 	;4
	DC_LittleEndianW InstEmpty-Song1 	;5
	DC_LittleEndianW InstToneLong-Song1 	;6
	DC_LittleEndianW InstToneWavy-Song1  ;7
	DC_LittleEndianW InstBass-Song1 	;8
	DC_LittleEndianW InstToneWavyShort-Song1  ;9
	
InstEmpty:
	dc.b 1,0
	dc.b 0

InstKick:
	dc.b 3,Cmd_Ptch,$00,Cmd_Note,10,Cmd_Nois+1,0
	dc.b 3,Cmd_Nois+0,0
	dc.b 0

InstSnare:
	dc.b 4,Cmd_Ptch,$00,Cmd_Note,30,Cmd_Nois+1,0
	dc.b 1,Cmd_Nois+0,0
	dc.b 0

InstCymbol:
	dc.b 1,Cmd_Ptch,$00,Cmd_Note,110,Cmd_Nois+1,0
	dc.b 1,Cmd_Nois+0,0
	dc.b 0

InstBass:
InstTone:
	dc.b 7,Cmd_Ptch,$00,0
	dc.b 0
	
InstToneWavy:
	dc.b 2,Cmd_Ptch,$00,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 0	
	
InstToneLong:
	dc.b 2,Cmd_Ptch,$00,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 2,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 2,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 2,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 0
	
InstToneWavyShort:
	dc.b 2,Cmd_Ptch,$00,Cmd_PtcU+4,0
	dc.b 2,Cmd_PtcD+4,0
	dc.b 0	
	
InstrumentScript:	
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 8,$FE,0
	dc.b 0


	dc.b 8,$FF,0	;Fx=Volume 
	dc.b 8,$C1,0	;Cx=Noise 
	dc.b 8,$D1,0	;Dx=Pitch up
	dc.b 8,$D4,0
	dc.b 8,$D8,0
	dc.b 8,$D4,0
	dc.b 8,$C0,0	;Cx=Noise 

	dc.b 8,$0F,32,0	;0F=8 bit pitch

	dc.b 8,$E1,0	;Ex=Pitch down
	dc.b 8,$E4,0
	dc.b 8,$E8,0

	endif
	
	include "\SrcALL\Multiplatform_ChibiTracks.asm"
	include "\SrcALL\Multiplatform_ChibiTracks_Tweener.asm"
	include "\SrcALL\Multiplatform_Fraction16.asm"
	include "\SrcALL\BasicFunctions.asm"
	include "\SrcALL\V1_ChibiSoundPro.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	include "\SrcALL\V1_ReadJoystick.asm"
	include "\SrcALL\V1_Palette.asm"
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
	
	
	even
Palette:
	;     -grb
	dc.w $0000	;0 - Background
	dc.w $0099	;1
	dc.w $0E0F	;2
	dc.w $0FFF	;3 - Last color in 4 color modes
	dc.w $000F	;4
	dc.w $004F	;5
	dc.w $008F	;6
	dc.w $00AF	;7
	dc.w $00FF	;8
	dc.w $04FF	;9
	dc.w $08FF	;10
	dc.w $0AFF	;11
	dc.w $0CCC	;12
	dc.w $0AAA	;13
	dc.w $0888	;14
	dc.w $0444	;15
	dc.w $0000	;Border
	even

	even
	include "\SrcALL\V1_RamArea.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Ram Area - May not be possible on all systems!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ifd BuildAMI
	
		Section ChipRAM,Data_c	
							
		even
		
wavTone:	;Square Wave
		dc.b 128,127,128,127,128,127,128,127
		dc.b 128,127,128,127,128,127,128,127
wavToneEnd:

wavNoise:	;Random noise
		dc.b 195,184, 71, 82,141,186, 62,131
		dc.b 195,184, 71, 82,141,186, 62,131
wavNoiseEnd:

ChibiSoundRam:	ds.b 256

	endif
	
	
	include "\SrcALL\V1_Footer.asm"