
    SECTION TEXT		;CODE Section

    pea    ST_Start     ;Push address to call to onto stack
    move.w  #$26,-(sp)  ;Supexec (38: set supervisor execution)
    trap    #14         ;XBIOS Trap
    addq.w  #6,sp       ;remove item from stack
	jmp *				;Wait for Supervisor mode to start
ST_Start:

	move.b #$00,$ff8260		;Screen Mode: 00=320x200 4 planes
	
    move.l #screen_mem,d0  	;Move address to screen mem to d0
    add.l #$ff,d0      		;Add 255 d0 address
    clr.b d0           		;Clear lowest byte in address
    move.l d0,ScreenBase	;Save screen start
	
    lsr.w #8,d0       		;we need to convert $00ABCD?? into $00AB00CD
    move.l d0,$ff8200		;store the resulting 16 bits into the screen start register
							;&FF8201 = High byte
							;&FF8203 = Mid  byte
							;Low byte cannot be specified
			;-RGB
	move.w #$0000,$ff8240 	;Color 0 - Black
	move.w #$0505,$ff8242 	;Color 1 - Purple
	move.w #$0077,$ff8244 	;Color 2 - Cyan
	move.w #$0777,$ff8246 	;Color 3 - White
	
	move.b #3,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #8-1,d2			;Height
	lea Bitmap,a0
BmpNextLine:			
	move.b (a0)+,(a6)	;Bitplane 0
	move.b (a0)+,(2,a6)	;Bitplane 1
	move.b (a0)+,(4,a6)	;Bitplane 2
	move.b (a0)+,(6,a6)	;Bitplane 3	
	move.l a6,d3
	add.l #160,a6			;Move down a line
	dbra d2,BmpNextLine
	
	jmp *
	


GetScreenPos: ; d1=x d2=y
	moveM.l d1-d3,-(sp)
		and.l #$FF,d1
		and.l #$FF,d2
		move.l ScreenBase,a6 ;Get screen pointer into a6
		move.l d1,d3	
		and.l #%11111110,d1
		and.l #%00000001,d3	 ;shift along 1 byte each 4 pixel pairs
		rol.l #2,d1			 ;*4 Bitplane words consecutive in memory
		add.l d1,a6
		add.l d3,a6
		
		mulu #160,d2		 ;160 bytes per Y line
		add.l d2,a6
	moveM.l (sp)+,d1-d3
	rts
	
	
Bitmap:	;Bitplanes are in words, 16 bits
		;we only have half a bitplane per line. (8 bits)
        DC.B $3C,$00,$00,$00     ;  0
        DC.B $7E,$00,$00,$00     ;  1
        DC.B $FF,$24,$00,$00     ;  2
        DC.B $FF,$00,$00,$00     ;  3
        DC.B $FF,$00,$00,$00     ;  4
        DC.B $DB,$24,$00,$00     ;  5
        DC.B $66,$18,$00,$00     ;  6
        DC.B $3C,$00,$00,$00     ;  7
BitmapEnd:
	

	even

    SECTION BSS ;Block Started by Symbol - Data initialised to Zero
;dc.l won't work in BSS - use DS commands instead
	
screen_mem:				;Reserve screen memory 
    ds.b    32256

ScreenBase: ds.l 1		;Var for base of screen ram
		
UserRam:				;Data area for Vars (4k)
	ds 1024
	
