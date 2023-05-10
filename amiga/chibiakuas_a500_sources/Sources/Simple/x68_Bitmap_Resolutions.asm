	clr.l d0			;0=Enable Supervisor mode
	move.l d0,-(sp)
	dc.w $FF20			;Switch Mode
	addq.l  #4,sp

Size1024 equ 1

;Colors256 equ 1				;Note... our test bitmap is only 16 color
;Colors64k equ 1


;**********************	
	
; Layer order
	;		 --SSTTGG33221100 SS=Sprite TT=Text GG=Bitmap graphics 33221100=layers
	;move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
	move.w #%0001000100011011,$e82500 ;R1 (Priority control) - Priority
	
;Turn on layers 0-3				
	;		 FEDCBA9876543210	
	;		 ------gtBST43210	0-3 = Layers 4=1024 screen T=Text S=Sprite B=Border tg=Translucency
	move.w #%0000000011001111,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
	
;**********************		
	
	;jsr ScreenInit_256x256
	;jsr ScreenInit_512x256
	;jsr ScreenInit_512x512
	
	ifd Size1024
		;jsr ScreenInit_512x512_Hires
		jsr ScreenInit_768x512_Hires
	endif
	
	ifd Colors256
		jsr Color256
	endif
	ifd Colors64k
		jsr Color64k		;GGGGGRRRRRBBBBBT 	T=Transparent?
	endif
		;dc.w $FF00	
;Sprites On
	;  	     FEDCBA9876543210	
	move.w #%0000001000000000,$eB0808 ;Disp/CPU 1=sprites on (slow writing)	
	
;Palette	
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82000	;Color 0
	move.w #%0000000000001110,$e82002	;Color 1
	move.w #%0000001110011100,$e82004	;Color 2
	move.w #%1111100000111110,$e82006	;Color 3
	move.w #%1111111111111110,$e82008	;Color 4

	
;Sprite Palettes
			;GGGGGRRRRRBBBBB- 5 bit per channel
	move.w #%0000000000000000,$e82200	;Color 0
	move.w #%1111100000000000,$e82202	;Color 1
	move.w #%0000011111000000,$e82204	;Color 2
	move.w #%0000000000111110,$e82206	;Color 3

	
	
	
;Hsprite Patterns	
	move.l #0,d0		;Tile Number
	lea HSprites,a3		;Sprite Address
	move.l #HSprites_end-HSprites,d2		;Sprite Address
	jsr DefineSprite	;Copy Sprite data to vram
	
	
	
	move.l #$C00000,a6
	move.l #$C00000,d6
	move.l #$000000,d1
	move.l #$000000,d2
FillAgain:
	move.w d1,(a6)+
	addq.w #1,d1
	addq.w #1,d2
	cmp.w #256,d2
	bne FillAgainOk
	ifd Size1024
		add.l #2048,d6
	else
		add.l #1024,d6
	endif
	move.l d6,a6
	clr.l d2
FillAgainOk:
	cmp.w #0,d1
	bne FillAgain
	
	
;Set The sprite	
	move.l #0,d0		;Hardware Sprite Number
	move.l #$20,d1	;Xpos
	move.l #$30,d2	;Ypos
	move.l #0,d3		;Sprite Pattern
	move.l #0,d4		;Palette
	move.l #3,d5		;Priority
	jsr SetSprite

	ifd Size1024
		move.w #400,d1			;x
		move.w #400,d2			;y
		jsr GetScreenPos1024	;Get Position in Vram
		jsr ShowBmp1024
		
	else
;Draw to the 4 bitmap layers
		move.w #3,d1			;x
		move.w #32,d2			;y
		jsr GetScreenPos0		;Get Position in Vram
		jsr ShowBmp
		
		ifnd Colors64k
			move.w #8,d1			;x
			move.w #35,d2			;y
			jsr GetScreenPos1		;Get Position in Vram
			jsr ShowBmp
			
			ifnd Colors256
				move.w #6,d1			;x
				move.w #28,d2			;y
				jsr GetScreenPos2		;Get Position in Vram
				jsr ShowBmp
			
				move.w #20,d1			;x
				move.w #48,d2			;y
				jsr GetScreenPos3		;Get Position in Vram
				jsr ShowBmp
			endif
		endif
	endif

	
InfLoop:
	
	addq.l #1,d1
	subq.l #2,d2
	
	ifd Colors64k

;Seems we need to move these together!
	
		move.w d1,$e80018		;Layer0-X
		move.w d1,$e8001a		;Layer0-Y
		move.w d1,$e8001c		;Layer1-X
		move.w d1,$e8001e		;Layer1-Y
		move.w d1,$e80020		;Layer2-X
		move.w d1,$e80022		;Layer2-Y
		move.w d1,$e80024		;Layer3-X
		move.w d1,$e80026		;Layer3-Y
	endif
	
	ifd Colors256
	
;Seems we need to move these together!
	
		move.w d1,$e80018		;Layer0-X
		move.w d1,$e8001a		;Layer0-Y
		move.w d1,$e8001c		;Layer1-X
		move.w d1,$e8001e		;Layer1-Y

		move.w d2,$e80020		;Layer2-X
		move.w d2,$e80022		;Layer2-Y
		move.w d2,$e80024		;Layer3-X
		move.w d2,$e80026		;Layer3-Y		
	endif
	
	ifnd Colors64k
	ifnd Colors256
		move.w d1,$e80018		;Layer0-X
		move.w d1,$e8001a		;Layer0-Y
		
		move.w d1,$e8001c		;Layer1-X
		;move.w d1,$e8001e		;Layer1-Y
	
		;move.w d1,$e80020		;Layer2-X
		move.w d1,$e80022		;Layer2-Y
		
		move.w d2,$e80024		;Layer3-X
		move.w d2,$e80026		;Layer3-Y
		
		
	endif
	endif
	jsr waitVBlank
	
	jmp InfLoop				;InfLoop

	

waitVBlank:
	move.w $e88000,d0			;MFP (MC68901)
	and.w #%00010000,d0			;Wait for vblank to start
	beq waitVBlank
waitVBlank2:	
	move.w $e88000,d0			;MFP (MC68901)
	and.w #%00010000,d0			;Wait for Vblank to end
	bne waitVBlank2
	rts
	
	
	
ShowBmp:	
	move.l #48-1,d2			;Height
	lea Bitmap,a0
BmpNextLine:			
	move.l #(48/2)-1,d1		;4 pixels per word in 8 color mode
	move.l a6,-(sp)
BmpNextPixel:
							;Note, each pixel is 2 bytes in ram
		move.b (a0),d0
		lsr.w #4,d0			;Copy Top Nibble
		addq.l #1,d0				;Colors +1
		move.w d0,(a6)+
		move.b (a0)+,d0		;Copy Bottom Nibble
		and #$F,d0
		addq.l #1,d0				;Colors +1
		move.w d0,(a6)+
	
		dbra d1,BmpNextPixel
	move.l (sp)+,a6			;Get the left Xpos back
	addA #1024,a6			;Move down a line
	dbra d2,BmpNextLine
	
	rts

ShowBmp1024:	
	move.l #48-1,d2			;Height
	lea Bitmap,a0
BmpNextLineB:			
	move.l #(48/2)-1,d1		;4 pixels per word in 8 color mode
	move.l a6,-(sp)
BmpNextPixelB:
		clr.w d0
							;Note, each pixel is 2 bytes in ram
		move.b (a0),d0
		lsr.w #4,d0			;Copy Top Nibble
		addq.l #1,d0				;Colors +1
		move.w d0,(a6)+
		move.b (a0)+,d0		;Copy Bottom Nibble
		and #$F,d0
		addq.l #1,d0				;Colors +1
		move.w d0,(a6)+
	
		dbra d1,BmpNextPixelB
	move.l (sp)+,a6			;Get the left Xpos back
	addA #2048,a6			;Move down a line
	dbra d2,BmpNextLineB
	rts
	
GetScreenPos1: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		move.l #$C80000,d7			;Layer1
		jmp GetScreenPosB
		
GetScreenPos2: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		move.l #$D00000,d7			;Layer1
		jmp GetScreenPosB
		
GetScreenPos3: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		move.l #$D80000,d7			;Layer1
		jmp GetScreenPosB
		
		
GetScreenPos0: ; d1=x d2=y
	moveM.l d0-d7/a0-a5,-(sp)
		move.l #$C00000,d7			;Layer0
GetScreenPosB:	
		and.l #$7FF,d1
		and.l #$7FF,d2
		
		rol.l #1,d1				;2 bytes per pixel		
		add.l d7,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a6
		
		rol.l #8,d2				;1024 bytes per Y line 
		rol.l #2,d2
		add.l d2,a6
	moveM.l (sp)+,d0-d7/a0-a5
	rts
	

GetScreenPos1024:	
	moveM.l d0-d7/a0-a5,-(sp)
		move.l #$C00000,d7			;Layer0
		and.l #$7FF,d1
		and.l #$7FF,d2
		
		rol.l #1,d1				;2 bytes per pixel		
		add.l d7,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a6
		
		rol.l #8,d2				;2048 bytes per Y line 
		rol.l #3,d2
		add.l d2,a6
	moveM.l (sp)+,d0-d7/a0-a5
	rts
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	;move.l #1,d0		;Tile Number
	;lea Sprite,a3		;Sprite Address
	;d2=ByteCount
DefineSprite:
	rol.l #7,d0			;Each sprite has 128 bytes of data (&80 bytes)
	add.l #$EB8000,d0	;Base address of sprite vram
	move.l d0,a0
	subq.l #1,d2
	clr.l d0
CopySpriteAgain:		;Copy the data from A3 to the Sprite ram
	move.w (a3)+,(a0)+
	dbra d2,CopySpriteAgain
	rts

	

	; move.l #0,d0		;Hardware Sprite Number
	; move.l #$50,d1	;Xpos
	; move.l #$30,d2	;Ypos
	; move.l #0,d3		;Sprite Pattern
	; move.l #0,d4		;Palette
	; move.l #3,d5		;Priority
	
	
	;D0=SprNum D1,D2=XY pos  D3=Spr Pattern D4= Palette D5 Priority (3=front)	
SetSprite:
	moveM.l d0-d2/a0,-(sp)	
		rol.l #3,d0			;8 bytes per sprite
		add.l #$EB0000,d0
		move.l d0,a0
		
		move.w d1,(a0)+		;------XX XXXXXXXX - X=Xpos
		move.w d2,(a0)+		;------YY YYYYYYYY - Y=Ypos
		
		rol.l #8,d4			;Shift palette into top byte
		add.l d4,d3
		
		move.w d3,(a0)+		;VH--CCCC SSSSSSSS - S=Sprite C=Color V=Vflip H=Hflip
		move.w d5,(a0)+		;-------- ------PP - P=Priority
	moveM.l (sp)+,d0-d2/a0
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ScreenInit_256x256:
	;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	
	move.w #$000,$e80028 	;R20 Memory mode/Display mode control
	
	move.w #$025,$E80000 	;R00 Horizontal total 
	move.w #$001,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$000,$E80004	;R02 Horizontal display start position
	move.w #$020,$E80006	;R03 Horizontal display end position
	move.w #$103,$E80008	;R04 Vertical total 
	move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$010,$E8000C	;R06 Vertical display start position
	move.w #$100,$E8000E	;R07 Vertical display end position
	move.w #$024,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
		
;Init Hsprites
	move.w #$25,$EB080A		; Sprite H Total
	move.w #$04,$EB080C		; Sprite H Disp
	move.w #$10,$EB080E		; Sprite V Disp
	move.w #$00,$EB0810		; Sprite Res %---FVVHH
	rts

ScreenInit_512x256:	
;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	
	move.w #$001,$e80028 ;R20 Memory mode/Display mode control

	move.w #$04B,$E80000 	;R00 Horizontal total 
	move.w #$003,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$004,$E80004	;R02 Horizontal display start position
	move.w #$045,$E80006	;R03 Horizontal display end position
	move.w #$103,$E80008	;R04 Vertical total 
	move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$010,$E8000C	;R06 Vertical display start position
	move.w #$100,$E8000E	;R07 Vertical display end position
	move.w #$02C,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
		
;Init Hsprites
	move.w #$ff,$EB080A		; Sprite H Total
	move.w #$09,$EB080C		; Sprite H Disp
	move.w #$10,$EB080E		; Sprite V Disp
	move.w #$0,$EB0810		; Sprite Res %---FVVHH
	rts	
	


ScreenInit_512x512:	
;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	
	move.w #$005,$e80028 ;R20 Memory mode/Display mode control

	move.w #$04B,$E80000 	;R00 Horizontal total 
	move.w #$003,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$004,$E80004	;R02 Horizontal display start position
	move.w #$045,$E80006	;R03 Horizontal display end position
	move.w #$103,$E80008	;R04 Vertical total 
	move.w #$002,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$010,$E8000C	;R06 Vertical display start position
	move.w #$100,$E8000E	;R07 Vertical display end position
	move.w #$02C,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
		
;Init Hsprites
	move.w #$ff,$EB080A		; Sprite H Total
	move.w #$09,$EB080C		; Sprite H Disp
	move.w #$10,$EB080E		; Sprite V Disp
	move.w #$05,$EB0810		; Sprite Res %---FVVHH
	rts
	
	
	
ScreenInit_512x512_Hires:	
	move.w #$015,$e80028 ;R20 Memory mode/Display mode control
	move.w #%0000000000000100,$e82400 ;1024x1024 mode

	move.w #$05b,$E80000 	;R00 Horizontal total 
	move.w #$009,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$011,$E80004	;R02 Horizontal display start position
	move.w #$051,$E80006	;R03 Horizontal display end position
	move.w #$237,$E80008	;R04 Vertical total 
	move.w #$005,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$028,$E8000C	;R06 Vertical display start position
	move.w #$228,$E8000E	;R07 Vertical display end position
	move.w #$01B,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
		
;Init Hsprites
	move.w #$ff,$EB080A		; Sprite H Total
	move.w #$15,$EB080C		; Sprite H Disp
	move.w #$28,$EB080E		; Sprite V Disp
	move.w #$15,$EB0810		; Sprite Res %---FVVHH

	;		 ------gtBST43210	0-3 = Layers 4=1024 screen T=Text S=Sprite B=Border tg=Translucency
	move.w #%0000000011111111,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
	rts
	
	
	
ScreenInit_768x512_Hires:	
	move.w #$416,$e80028 	;R20 Memory mode/Display mode control
	move.w #%0000000000000100,$e82400 ;1024x1024 mode

	move.w #$089,$E80000 	;R00 Horizontal total 
	move.w #$00E,$E80002	;R01 Horizontal synchronization end position timing
	move.w #$01C,$E80004	;R02 Horizontal display start position
	move.w #$07C,$E80006	;R03 Horizontal display end position
	move.w #$237,$E80008	;R04 Vertical total 
	move.w #$005,$E8000A	;R05 Vertical synchronization end position timing
	move.w #$028,$E8000C	;R06 Vertical display start position
	move.w #$228,$E8000E	;R07 Vertical display end position
	move.w #$01B,$E80010	;R08 External synchronization horizontal adjust: Horizontal position tuning
		
;Init Hsprites
	move.w #$ff,$EB080A		; Sprite H Total
	move.w #$15,$EB080C		; Sprite H Disp
	move.w #$28,$EB080E		; Sprite V Disp
	move.w #$15,$EB0810		; Sprite Res %---FVVHH
	
	;		 --------BST43210	0-3 = Layers 4=1024 screen T=Text S=Sprite B=Border
	move.w #%0000000011111111,$e82600 ;R2 (Special priority/screen display) - Screen On - sprites on
	
	rts
	
	
Color256:
	or.w #$100,$e80028 	;R20 Memory mode/Display mode control
	or.w #$001,$e82400	; R0 (Screen mode initialization) - Detail
	rts

Color64k:
	or.w #$300,$e80028	;R20 Memory mode/Display mode control
	or.w #$003,$e82400	;R0 (Screen mode initialization) - Detail
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
HSprites:
	incbin "\ResALL\Sprites\SpriteX68.RAW"
HSprites_End:
	
Bitmap:
	incbin "\ResALL\Sprites\RawMSX.RAW"
BitmapEnd:
