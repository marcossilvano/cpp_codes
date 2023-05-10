;UseStackMisuse equ 1

VscreenMinX equ 64		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 80

VscreenWid equ 128		;Visible Screen Size in logical units
VscreenHei equ 128 ;96

VscreenWidClip equ 0
VscreenHeiClip equ 0


			;		 FEDCBA9876543210	
			move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
			move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
			;		 --SSTTGG44332211
			move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
			;		 FEDCBA9876543210	
			;				  ST43210		
			move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
			
			move.w #$025,$E80000 	;R00 Horizontal total 
			move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
			move.w #$000,$E80004	;R02 Horizontal display start position
			move.w #$020,$E80006	;R03 Horizontal display end position
			move.w #$103,$E80008	;R04 Vertical total 
			move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
			move.w #$010,$E8000C	;R06 Vertical display start position
			move.w #$100,$E8000E	;R07 Vertical display end position
			move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
			
			;move.w #$25,$EB080A		; Sprite H Total
			;move.w #$04,$EB080C		; Sprite H Disp
			;move.w #$10,$EB080E		; Sprite V Disp
			;move.w #$00,$EB0810		; Sprite Res %---FVVHH

;Palette	
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82000	;Color 0
	move.w #%0000001110011100,$e82002	;Color 1
	move.w #%1111100000111110,$e82004	;Color 2
	move.w #%1111111111111110,$e82006	;Color 3


	move.w #VscreenMinX,(PlayerX)		;x
	move.w #VscreenMinY,(PlayerY)	;y
	
	move.w (PlayerX),d1			;Back up X
	move.w (PlayerY),d4			;Back up Y
	jsr DrawPlayer			;Draw Player Sprite
	
	
	
	move.b #%00001111,d3
	jmp StartDraw				;Force sprite draw on first run
	
InfLoop:
	move.b #%00000000,$E9A005	;8255 Port C (Default Controls)
	clr.b d3
	move.b ($E9A001),d3			;-21-RLDU
	and #%00001111,d3
	cmp.b #%00001111,d3
	beq InfLoop					;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1			;Back up X
	move.w d1,(PlayerX2)

	move.w (PlayerY),d4			;Back up Y
	move.w d4,(PlayerY2)
	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr DrawPlayer			;Draw Player Sprite
	moveM.l (sp)+,d0-d7/a0-a5
	
	
	btst #0,d3
	bne JoyNotUp		;Jump if UP not pressed
	subq.w #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #1,d3
	bne JoyNotDown		;Jump if DOWN not pressed
	addq.w #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #2,d3
	bne JoyNotLeft		;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #3,d3
	bne JoyNotRight		;Jump if RIGHT not pressed
	addq.w #1,d1		;Move X Right
JoyNotRight: 	
	move.w d1,(PlayerX)	;Update X
	move.w d4,(PlayerY)	;Update Y

	
	jsr DrawPlayer			;Draw Player Sprite
	
	move.l #$FFF,d1
	jsr PauseD1				;Wait a bit!
	
	jmp InfLoop
PauseD1:
	dbra d1,PauseD1
	rts
	
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
DrawPlayer:	
	lea Bitmap,a6			;Source bitmap
DrawSprite:	
	move.l #24,d3			;Width
	move.l #24,d6			;Height
	
	jsr docrop				;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6
	
	bcs DrawSpriteAbort		;CarrySet=All offscreen
		
	jsr GetScreenPos		;Get Position in Vram
	
	subq.l #1,d6
	subq.l #1,d3
BmpNextLine:			
	move.l d3,d1			;2 pixels per word in 16 color mode
	move.l a2,-(sp)
BmpNextPixel:				;Note, each pixel is 2 bytes in ram
		move.b (a6),d0
		ror #4,d0			;Copy Top Nibble
		eor.w d0,(a2)+
		move.b (a6)+,d0		;Copy Bottom Nibble
		eor.w d0,(a2)+
		dbra d1,BmpNextPixel
		
		clr.l d0
		move.b (spritehclip),d0		;Skip H bytes
		add.l d0,a6
		
	move.l (sp)+,a2			;Get the left Xpos back
	addA #1024,a2			;Move down a line
	dbra d6,BmpNextLine
DrawSpriteAbort:
	rts
	

Bitmap:
	incbin "\ResALL\Sprites\RawMSX.RAW"

BitmapBlank:
		DS.B 24*48
BitmapEnd:
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

GetScreenPos: ; d1=X d4=Y  VRAM Dest in A2
	moveM.l d0-d7,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		rol.l #1,d1				;2 bytes per pixel
		add.l #$c00000,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a2
		
		rol.l #8,d4				;1024 bytes per Y line 
		rol.l #2,d4
		add.l d4,a2
	moveM.l (sp)+,d0-d7
	rts
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	;;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6
docrop:
	clr.l d2					;D5=top D2=bottom crop
	clr.l d5
	clr.b (spritehclip)			;H-clip
	
;crop top side
	clr.l d0
	move.b d4,d0				;X-pos
	sub.b #vscreenminy,d0		;>minimum co-odinate
	bcc notcrop					;nc=nothing needs cropping
	neg.b d0
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d5				;amount to remove from top of source
	clr.l d0					;Draw from Y=0
notcrop:
	move.b d0,d4				;Draw Ypos
	
;crop bottom hand side
	add.b d6,d0					;Add Height
	sub.b #vscreenhei-vscreenheiclip,d0	;logical height of screen
	bcs nobcrop					;c=nothing needs cropping
	cmp.b d6,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d2				;amount to remove from bottom 
nobcrop:

;Calculate new height
	clr.l d0
	move.b d5,d0				;units to remove from top
	add.b d2,d0					;units to remove from bottom
	beq novclip					;nothing to remove?
	sub.b d0,d6					;subtract from old height
	
	
;remove lines from source bitmap (A6)

	lsl.b #1,d5					;Amount to remove from top
	
	mulu d3,d5					;Calculate amount to remove 
								;(Lines*BytesPerLine)
								
	add.l d5,a6					;Remove from source bitmap
	
NoVClip:
	clr.l d2					;D5=left D2=right crop
	clr.l d5

;crop left hand side
	move.b d1,d0
	sub.b #vscreenminx,d0		;remove left virtual border
	bcc nolcrop					;nc=nothing needs cropping
	neg.b d0					;Amount to remove
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	move.b d0,d5				;Amount to remove from Left
	clr.l d0					;Draw from X=0
nolcrop:
	move.b d0,d1				;Draw Xpos

;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;all offscreen
	move.b d0,d2				;right crop
norcrop:

	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	beq nohclip					;nothing to crop?

	move.b d0,(spritehclip)		;number of horizontal bytes to skip
									;after each line
	sub.b d0,d3					;Update Width

	add.l d5,a6					;move source bitmap address across
nohclip:
		
;Convert Logical units
	asl.l #1,d6					;Double Height

	asl.l #1,d1					;Double Xpos
	asl.l #1,d4					;Double Ypos

	andi #%11111110,ccr			;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr			;set carry (nothing to draw)
	rts


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	
;Current player pos
PlayerX: dc.w $10
PlayerY: dc.w $10

;Last player pos (For clearing sprite)
PlayerX2: dc.w $10
PlayerY2: dc.w $10

spritehclip: dc.l 0