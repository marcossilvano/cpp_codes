;UseStackMisuse equ 1

VscreenMinX equ 64		;Top left of visible screen in logical co-ordinates
VscreenMinY equ 64

VscreenWid equ 128		;Visible Screen Size in logical units
VscreenHei equ 128

VscreenWidClip equ 0
VscreenHeiClip equ 0

	
	move.b #%00001000,$18063	;Force 8 color mode!
		

	move.w #VscreenMinX,(PlayerX)		;x
	move.w #VscreenMinY,(PlayerY)	;y
	
	
	move.w (PlayerX),d1			;Back up X
	move.w (PlayerY),d4			;Back up Y
	jsr DrawPlayer			;Draw Player Sprite
	
	move.b #%00000000,d3	;Dummy Keypresses for first run
	jmp StartDraw			;Force sprite draw on first run
	
InfLoop:;Row 1: Enter Left Up	Esc	Right \	Space Down
	lea QLJoycommand,a3	 
	move.b #$11,d0		;Command 17
	Trap #1				;Send Keyrequest to the IO CPU
						;Returns row in D1
	move.b d1,d3
	
	cmp.b #%0000000,d3
	beq InfLoop			;Wait until player presses button
	
StartDraw:
	move.w (PlayerX),d1	;Back up X

	move.w (PlayerY),d4	;Back up Y

	
	moveM.l d0-d7/a0-a5,-(sp)
		jsr DrawPlayer
	moveM.l (sp)+,d0-d7/a0-a5
	

	btst #2,d3
	beq JoyNotUp	;Jump if UP not pressed
	subq.w #1,d4		;Move Y Up the screen
JoyNotUp: 	
	btst #7,d3
	beq JoyNotDown	;Jump if DOWN not pressed
	addq.w #1,d4		;Move Y DOWN the screen
JoyNotDown: 	
	btst #1,d3
	beq JoyNotLeft	;Jump if LEFT not pressed
	subq.w #1,d1		;Move X Left
JoyNotLeft: 	
	btst #4,d3
	beq JoyNotRight	;Jump if RIGHT not pressed
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
	
	
DrawPlayer:	
	lea Bitmap,a6			;Source bitmap
DrawSprite:	
	move.l #24,d3
	move.l #24,d6

	;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6	
	jsr docrop
	bcs DrawSpriteAbort		;All offscreen?
		
		
	jsr GetScreenPos		;Get Position in Vram
	
	subq.l #1,d6			;Fix for DBRA
	subq.l #1,d3
	
	move.l d3,d1			;Height
BmpNextLine:
	move.l d3,d1		;2 pixels per word in 16 color mode
	move.l a2,-(sp)
BmpNextWord:
		move.w (a6)+,d0		;Get 4 pixels
		eor.w d0,(a2)+		;XOR with screen
	
		dbra d1,BmpNextWord
		
		clr.l d0
		move.b (spritehclip),d0
		add.l d0,a6			;Add bytes to skip
		
	move.l (sp)+,a2			;Get the left Xpos back
	add.l #128,a2			;Add 128 to move down a line
	dbra d6,BmpNextLine
DrawSpriteAbort:
	rts
	

Bitmap:
	incbin "\ResALL\Sprites\RawQL.raw"
BitmapEnd:


;VRAM = $20000+ (Xpos * 2) + Ypos * 128)
GetScreenPos: 					; d1=x d2=y
	moveM.l d1-d2,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		rol.l #1,d1				;Multiply X*2 (2 bytes per 4/8 pixels)
		rol.l #7,d4				;Multiply Y*128
		
		move.l #$00020000,a2	;Screen starts at $20000
		add.l d4,a2
		add.l d1,a2
	moveM.l (sp)+,d1-d2
	rts


QLJoycommand:
	dc.b $09	;0 - Command
	dc.b $01	;1 - parameter bytes
	dc.l 0		;2345 - send option (%00=low nibble)
	dc.b 1		;6 - Parameter: Row
	dc.b 2		;7 - length of reply (%10=8 bits)
	even
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

	
	;X,Y=D1,D4  W,H=D3,D6   BmpSrc=A6
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
	move.b d0,d5
	clr.l d0	
nolcrop:
	move.b d0,d1				;Draw Xpos
		
		
;crop right hand side
	add.b d3,d0					;Add Width
	sub.b #vscreenwid-vscreenwidclip,d0	;logical width of screen
	bcs norcrop					;c=nothing needs cropping
	cmp.b d3,d0					;no pixels onscreen?
	bcc docrop_alloffscreen		;offscreen
	move.b d0,d2				

norcrop:
	move.b d2,d0				;units to remove from left
	add.b d5,d0					;units to remove from right
	beq nohclip					;nothing to crop?
	and #%11111110,d0		;Working in pairs of bytes (4 pixels)
	move.b d0,(spritehclip)

	move.b d0,d2			;amount to subtract from width (right)

	sub.b d2,d3					;Update Width

	;amount to subtract from left
	and.l #%11111110,d5		;Working in quads of bytes (8 pixels)

;update start byte
	add.l d5,a6					;move across 
	
nohclip:
	lsr.b #1,d3				;Halve Width (4 pixel Words)
	beq docrop_alloffscreen
	lsr.b #1,d1				;Halve Xpos  (4 pixel Words)

	asl.l #1,d6				;Double Height (Pixels)
	asl.l #1,d4				;Double Ypos (Pixels)
	
	andi #%11111110,ccr		;Clear carry
	rts

docrop_alloffscreen:
	ori #%00000001,ccr		;set carry (nothing to draw)
	rts


	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
UserRam equ $30000		;Ram for data
		
PlayerX   equ UserRam+0	;Ram for Player Xpos
PlayerY   equ UserRam+2	;Ram for Player Ypos


spritehclip equ UserRam+4