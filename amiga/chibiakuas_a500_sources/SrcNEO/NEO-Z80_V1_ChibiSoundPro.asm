
ChibiOctave:
	;   E     F     G      A     B     C     D   
	;   E     F     G      A     B     C     D   
	dw &0800,&1000,&2000,&3000,&4000,&4C00,&5400 
	;   41.2  43.6   49    55   61.7  65.4  73.4
	dw &5A80,&6550,&7400,&8438,&917A,&96E5,&A261 ;1
	;   82.4  87.3  98    110   123    130   146
	dw &AC78,&B12E,&B1FF,&C109,&C85A,&CB2D,&D108 ;2
	;	164   174    196   220 	246   261   293
	dw &D633,&D88D,&DCD2,&E08C,&E407,&E58E,&E864 ;3
	;   329   349   392   440   493   523    587
	dw &EB01,&EC2D,&EE53,&F040,&F1F5,&F2CA,&F434 ;4
	;    659  698   783   880   987   1046  1174
	dw &F57A,&F61A,&F712,&F820,&F8F6,&F952,&FA1A ;5
	;   1318  1396  1567  1760  1975  2093  2349
	dw &FAB4,&FB0A,&FB90,&FC0D,&FC7C,&FCA6,&FD03 ;6
	dw &FD80,&FE00,&FE80,&FEC0,&FF00,&FF80,&FFFF

	
	
;Rules for a ChibiSound V1 Driver:
; No use of shadow registers	
; IX,IY must not be used
; AF/BC/DE/HL all can change during function
; Set may update sound directly, or Update may depending on system
; Octicve lookup mist be provided
; Must function for channel numbers 0-7 (0=highest priority)
	;Channel 1+ can be ignored if preferred
	
;Rules for a ChibiSound V1.2 Driver:
; IX/IY can be used for platform specific functions like Envelope
	
ChibiSoundPro_Init:	
	ld a,%10111111		;Set up port directions
	ld (AYCache+7),a
	ret
	
;H=Volume (0-255) 
;L=Channel Num (0-127 unused channels will wrap around) / Top Bit=Noise
;DE=Pitch (0-65535)

ChibiSoundPro_Set:			

;Channel Remap
	ld a,l
	and %10000000		;Noise bit
	ld c,a
	push hl
		ld a,l
		and %00000111	;Remap 7 virtual channels to 3 physical
		ld hl,ChannelMap
		add l
		ld l,a
		ld a,(hl)		;Channel mapping
	pop hl
	or c
	ld l,a

	
	ld a,h
	or a
	jp nz,NotsilentPro	;Zero turns off sound

;Silence 
	call DoChannelMask	;Get Mixer mask for channel
	and %00111111
	ld d,a

	ld a,(bc)
	or d				;Set channel bits to 1
	
	ld c,a
	ld a,7				;Mixer  --NNNTTT (1=off) --CBACBA
	jp AYRegWritePro		
	
NotsilentPro:	
	
	
	ifdef ChibiSound_Envelopes
		ld a,ixl
		bit 7,a
		jr z,ChibiSoundProNoEnv

		and %00001111
		ld c,a
		ld a,13
		call AYRegWritePro	
		ld c,0
		ld a,12
		call AYRegWritePro
		ld a,ixh
		ld c,a
		ld a,11
		call AYRegWritePro
	
		ld l,2
		jr ChibiSoundProChannelOK
ChibiSoundProNoEnv:				
	endif

;Frequency 
	ld a,d 			;Flip frequency bits
	cpl
	ld d,a
	ld a,e
	cpl
 	ld e,a
	inc de

	srl d		;Ditch bottom 4 bits %DDDDDDDD EEEEEEEE
	rr e
	srl d
	rr e
	srl d
	rr e
	srl d
	rr e		;					 %----DDDD DDDDEEEE

	ld c,e
	ld a,l			
	and %00000011
	rlca			;0/2/4 - Tone L
	push af
		call AYRegWritePro ;TTTTTTTT Tone Lower 8 bits

		ld c,d
	pop af	
				
	inc a			;1/3/5 - Tone H
	call AYRegWritePro		;----TTTT Tone Upper 4 bits
	
	
	
	bit 7,l			;Noise bit N-------
	jr z,AYNoNoisePro

;Noise ON
	push de
		call DoChannelMask
		and %00111111
		cpl
		ld d,a
		ld a,(bc)	;Previous Mixer Value
		and d		;noise and tone on (clear to 0)
		ld c,a
		ld a,7
		call AYRegWritePro
	pop de

	sla e
	rl d
	ld a,d
	and %00011111
	ld c,a
	ld a,6			;Noise Frequency ---NNNNN
	call AYRegWritePro

	jr AYMakeTonePro
	
	
;Tone On
	
AYNoNoisePro:
	call DoChannelMask
 	and %00111000
	ld e,a			;Mask to set noise off

	ld a,d
	and %00000111	;Mask to clear Tone bit on
	cpl
	ld d,a

	ld a,(bc)		;Previous Mixer Value
	and d			;Tone on
	or e			;Noise Off
	ld c,a

	ld a,7			;Mixer  --NNNTTT (1=off) --CBACBA
	call AYRegWritePro
	

AYMakeTonePro:

;Volume

	ld c,h			;%VVVVVVVV = Volume bits
	srl c
	srl c
	srl c
	srl c			;%----VVVV

	ifdef ChibiSound_Envelopes	
		ld a,ixl
		bit 7,a
		jr z,AYMakeTone_EnvOff
		set 4,c			;Turn Envelope on
AYMakeTone_EnvOff:
	endif
	
	ld a,l			;4-bit Volume / 1-bit Envelope Select
	and %00000011		;for channel  ---EVVVV
	
	add 8			;Channel num 8,9,10
	jp AYRegWritePro



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoChannelMask:			;get Mixer bits in D for channel L
	ld bc,ChannelMask	
	ld a,l
	and %00000011		;Get Channel Mask for Mixer
	add c
	ld c,a
	ld a,(bc)
	ld d,a
	ld bc,AYCache+7		;Point BC to previous mixer value in ram
	ret

			
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

AYRegWritePro:			;Set Channel A to value C
	push hl
	push af
		ld hl,AYCache
		add l
		ld l,a
		ld a,(hl)		;Get current value
		cp c
		jr z,AYRegNochange	;No Change! Give up
		ld (hl),c
	pop af
	pop hl

	out (4),a	;Set regnum
	ld a,c
	out (5),a	;Set value
	ret

AYRegNochange:
	pop af
	pop hl
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifdef VASM
		align 4
	else
		align 16
	endif

	ifndef AYCache
		ifdef ChibiSoundRam		;AY reg Cache
AYCache equ ChibiSoundRam+64	;First 64 bytes reserved for tracker
		else
AYCache: ds 16
		endif 
	endif

ChannelMap:	db 1,0,2,0,2,0,2,0	;Remap to physical channels

ChannelMask:	db %00001001,%00010010,%00100100,0 ;Mixer bits


