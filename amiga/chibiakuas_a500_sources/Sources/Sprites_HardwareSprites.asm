;Mode4Color equ 1			;Sinclair QL Only

UseSprites equ 1 ;Amiga


Cursor_X equ UserRam
Cursor_Y equ UserRam+1

	include "\SrcALL\BasicMacros.asm"
	include "\SrcALL\V1_Header.asm"

	

	move.b #'A',d0
	jsr PrintChar
	
	move.b #'B',d0
	jsr PrintChar
	move.b #'C',d0
	jsr PrintChar
	
		jsr NewLine
	
	lea Message,a3
	jsr PrintString
	jsr NewLine
	
	
	
	
	ifd BuildAMI
BitmapMode equ 1
	endif
	ifd BuildAST
BitmapMode equ 1
	endif
	ifd BuildX68
BitmapMode equ 1
	endif
	ifd BuildSQL
BitmapMode equ 1
	endif
	ifd BuildNEO
TileMode equ 1
	endif
	ifd BuildGEN
TileMode equ 1
	endif
	
	ifd TileMode
		move.l #3,d0	;SX
		move.l #3,d1	;SY
	
		move.l #6,d2	;WID
		move.l #6,d3	;HEI
	
		move.l #256,d4	;TileStart Number
		jsr FillAreaWithTiles
	endif
	
	ifd BuildGEN
		lea Bitmap,a0					;Source data
		move.w #BitmapEnd-Bitmap,d1
		move.l #256*32,d2				;Dest... 32 bytes per tile
		jsr DefineTiles	
	endif
	
	ifd BitmapMode
	move.b #3,d1			;x
	move.b #32,d2			;y
	jsr GetScreenPos		;Get Position in Vram
	
	move.l #48-1,d2			;Height
	lea Bitmap,a0
BmpNextLine:			
	ifnd Mode4Color
		move.l #(48/2)-1,d1		;4 pixels per word in 8 color mode
	else
		move.l #(48/4)-1,d1		;8 pixels per word in 4 color mode
	endif
	move.l a6,-(sp)
BmpNextPixel:
	ifd BuildSQL
		move.b (a0)+,(a6)+		
		
	endif	
	ifd BuildX68			;Note, each pixel is 2 bytes in ram
		move.b (a0),d0
		ror #4,d0			;Copy Top Nibble
		move.w d0,(a6)+
		move.b (a0)+,d0		;Copy Bottom Nibble
		move.w d0,(a6)+
	endif
	
	ifd BuildAST				;Amiga Format (byte bitplanes)
		move.b (a0)+,(a6)		;Bitplane 0
		move.b (a0)+,(2,a6)		;Bitplane 1
		move.b (a0)+,(4,a6)		;Bitplane 2
		move.b (a0)+,(6,a6)		;Bitplane 3	
		
		move.l a6,d3
		addq.l #1,a6
		
		btst.l #0,d3			;We need to shift 7 pixels every 2 bytes because 4 word bitplanes are together in memory
		beq BmpNextPixelEven
		addq.l #6,a6
BmpNextPixelEven
		subq.l #3,d1			;Dbra wil sub 1 - but we need to sub another 3 as we do 4 bytes per update
	endif
	
	
	
	; ifd BuildAMI				;This will read the same file as the AST
		; move.b (a0)+,(a6)		;Read in word chunks!
		; move.b (a0)+,(1,a6)
		; move.b (a0)+,(40*200*2,a6)
		; move.b (a0)+,(40*200*2+1,a6)
		; move.b (a0)+,(40*200*3,a6)	;4 bitplanes
		; move.b (a0)+,(40*200*3+1,a6)
		; move.b (a0)+,(40*200*1,a6)
		; move.b (a0)+,(40*200*1+1,a6)
		; addq.l #2,a6
		; subq.l #7,d1
	; endif
	ifd BuildAMI				
		move.b (a0)+,(a6)		
		move.b (a0)+,(40*200*1,a6)
		move.b (a0)+,(40*200*2,a6)	;4 bitplanes
		move.b (a0)+,(40*200*3,a6)
		addq.l #1,a6
		subq.l #3,d1
	endif
		dbra d1,BmpNextPixel
	move.l (sp)+,a6				;Get the left Xpos back
	jsr GetNextLine
	dbra d2,BmpNextLine
	

	endif
	
	
	
	
	lea Palette,a0		;Source palette
	clr.l d0			;Color number
PaletteNext:
	move.w (a0)+,d1		;Read Definition
	jsr SetPalette		;Set Color D0 to D1 (-GRB)
	
	addq.b #1,d0
	ifd BuildAMI
		cmp.b #33,d0		;Repeat for other colors
	else
		cmp.b #17,d0		;Repeat for other colors
	endif
	bne PaletteNext
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;		NeoGeo Advanced Sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ifd BuildNEO
	
		;Simple 16x16 Sprite Example	
		
		move.l #0,d0		;Hard Sprite Number (10)
		move.l #$50,d1		;Xpos
		move.l #388,d2		;Ypos
		move.l #$2000,d3	;Pattern Num
		move.l #1,d4		;Palette
		jsr SetSprite
	
	;	jmp InfLoop
	
		move.l #10,d0		;Hard Sprite Number (11)
		move.l #380,d2		;Xpos
		move.l #$51,d1		;Ypos
		move.l #$2000,d3	;Pattern Num
		move.l #1,d4		;Palette
		jsr SetSprite
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Regular Yarita!		
	
;;;;;;;;;;;;;;;;; 1st Vertical Strip ;;;;;;;;;;;;;;;;; 
	
		;$3C0000=Select VRAM Address
		;$3C0002=Send data to VRAM
		
	;Sprite Select (1)
		move.w #$8000+1,$3C0000 	;Full size
		move.w #$0FFF,$3C0002		;----HHHH VVVVVVVV - Shrink
		 
		move.w #$8200+1,$3C0000 	;Top of screen - 4 tiles tall
		move.w #$F404,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
										;Chain Sprite Size (4 sprites)
		
		move.w #$8400+1,$3C0000 	;Left of screen
		move.w #$2800,$3C0002		;XXXXXXXX X------- Xpos
		
	;Attribs at $0040
	;Sprite (1) - Tile (1)
		move.w #$0040,$3C0000 		;Show Tile 1 from bank $100000
		move.w #$2001,$3C0002		;NNNNNNNN Tile - my tiles start at $2000
		
		move.w #$0041,$3C0000 		;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (1) - Tile (2)
		move.w #$0040+2,$3C0000 	;Show Tile 2 from bank $100000
		move.w #$2002,$3C0002		;NNNNNNNN Tile
		
		move.w #$0041+2,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (1) - Tile (3)	
		move.w #$0040+4,$3C0000 	;Show Tile 3 from bank $100000
		move.w #$2003,$3C0002		;NNNNNNNN Tile
		
		move.w #$0041+4,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (1) - Tile (4)
		move.w #$0040+6,$3C0000 	;Show Tile 4 from bank $100000
		move.w #$2004,$3C0002		;NNNNNNNN Tile
		
		move.w #$0041+6,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
		
;;;;;;;;;;;;;;;;; 2nd Vertical Strip ;;;;;;;;;;;;;;;;; 
	;Sprite Select (2)	
		move.w #$8000+2,$3C0000 	;Full size
		move.w #$0F00,$3C0002		;----HHHH VVVVVVVV - Shrink
		
		move.w #$8200+2,$3C0000 	;Chain Sprite - Ypos & size ignored
		move.w #$0040,$3C0002		;YYYYYYYY YCSSSSSS Ypos - Chain Sprite Size
		
		move.w #$8400+2,$3C0000 	;Xpos ignored due to Chain
		move.w #$0000,$3C0002		;XXXXXXXX X------- Xpos
	
	;Attribs at $0080
	;Sprite (2) - Tile (1)
		move.w #$0080,$3C0000 		;Show Tile 5 from bank $100000
		move.w #$2005,$3C0002		;NNNNNNNN Tile - my tiles start at $2000
		
		move.w #$0081,$3C0000 		;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (2) - Tile (2)
		move.w #$0080+2,$3C0000 	;Show Tile 6 from bank $100000
		move.w #$2006,$3C0002		;NNNNNNNN Tile
		
		move.w #$0081+2,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (2) - Tile (3)	
		move.w #$0080+4,$3C0000 	;Show Tile 7 from bank $100000
		move.w #$2007,$3C0002		;NNNNNNNN Tile
		
		move.w #$0081+4,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (2) - Tile (4)
		move.w #$0080+6,$3C0000 	;Show Tile 8 from bank $100000
		move.w #$2008,$3C0002		;NNNNNNNN Tile
		
		move.w #$0081+6,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Chibi-Chibi Yarita!	

;;;;;;;;;;;;;;;;; 1st Vertical Strip ;;;;;;;;;;;;;;;;; 

	;Sprite Select (3)		
		move.w #$8000+3,$3C0000 	;Small Size
		move.w #$0880,$3C0002		;----HHHH VVVVVVVV - Shrink
		 
		move.w #$8200+3,$3C0000 	;Top of screen - 4 tiles tall
		move.w #$F404,$3C0002		;YYYYYYYY YCSSSSSS Ypos 
										;Chain Sprite Size (4 sprites)
		
		move.w #$8400+3,$3C0000 	;Left of screen
		move.w #$4000,$3C0002		;XXXXXXXX X------- Xpos
	
	;Attribs at $00C0
	;Sprite (3) - Tile (1)
		move.w #$00C0,$3C0000 		;Show Tile 1 from bank $100000
		move.w #$2001,$3C0002		;NNNNNNNN Tile - my tiles start at $2000
		
		move.w #$00C1,$3C0000 		;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (3) - Tile (2)
		move.w #$00C0+2,$3C0000 	;Show Tile 2 from bank $100000
		move.w #$2002,$3C0002		;NNNNNNNN Tile
		
		move.w #$00C1+2,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (3) - Tile (3)
		move.w #$00C0+4,$3C0000 	;Show Tile 3 from bank $100000
		move.w #$2003,$3C0002		;NNNNNNNN Tile
		
		move.w #$00C1+4,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (3) - Tile (4)	
		move.w #$00C0+6,$3C0000 	;Show Tile 4 from bank $100000
		move.w #$2004,$3C0002		;NNNNNNNN Tile
		
		move.w #$00C1+6,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
		
;;;;;;;;;;;;;;;;; 2nd Vertical Strip ;;;;;;;;;;;;;;;;; 
	
	;Sprite Select (4)	
		move.w #$8000+4,$3C0000 	;Small Size
		move.w #$0800,$3C0002		;----HHHH VVVVVVVV - Shrink
		
		move.w #$8200+4,$3C0000 	;Chain Sprite - Ypos & size ignored
		move.w #$0040,$3C0002		;YYYYYYYY YCSSSSSS Ypos - Chain Sprite Size
		
		move.w #$8400+4,$3C0000 	;Xpos ignored due to Chain
		move.w #$0000,$3C0002		;XXXXXXXX X------- Xpos
	
	;Attribs at $0100
	;Sprite (4) - Tile (1)
		move.w #$0100,$3C0000 		;Show Tile 1 from bank $100000
		move.w #$2005,$3C0002		;NNNNNNNN Tile - my tiles start at $2000
		
		move.w #$0101,$3C0000 		;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (4) - Tile (2)
		move.w #$0100+2,$3C0000 	;Show Tile 2 from bank $100000
		move.w #$2006,$3C0002		;NNNNNNNN Tile
		
		move.w #$0101+2,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (4) - Tile (3)
		move.w #$0100+4,$3C0000 	;Show Tile 3 from bank $100000
		move.w #$2007,$3C0002		;NNNNNNNN Tile
		
		move.w #$0101+4,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip
	;Sprite (4) - Tile (4)
		move.w #$0100+6,$3C0000 	;Show Tile 4 from bank $100000
		move.w #$2008,$3C0002		;NNNNNNNN Tile
		
		move.w #$0101+6,$3C0000 	;Use Palette 1
		move.w #$0100,$3C0002		;PPPPPPPP NNNNAAVH Palette Tile, Autoanim Flip

	endif

	
	
	ifd BuildX68
		move.l #0,d0		;Tile Number
		lea Sprite,a3		;Sprite Address
		jsr DefineSprite	;Copy Sprite data to vram
		
		move.l #0,d0		;Hardware Sprite Number
		move.l #$50,d1		;Xpos
		move.l #$30,d2		;Ypos
		move.l #0,d3		;Sprite Pattern
		move.l #0,d4		;Palette
		move.l #3,d5		;Priority
;InfLoopy		
	;	jsr SetSprite 
	;	addq.b #1,d1		;Xpos
	;	jsr WaitVblank
	;	jmp InfLoopy
		
	endif
	
	ifd BuildGEN
		;Set up our sprite patterns in VRAM
	
		lea Sprite,a0				;Source data
		move.w #SpriteEnd-Sprite,d1	;Sprite Size
		move.l #512*32,d2			;Dest...Tile 512 - 32 bytes per tile
		jsr DefineTiles					
	
		;Yarita Character (64x32) - Head
	
		move.l #0,d0		;Sprite Num
		move.l #$C0,d1		;Xpos
		move.l #$80,d2		;Ypos
		move.l #$0210,d3 	;Tile (512+4)
		move.l #$0F01,d4 	;Link +WidthHeight (32x32)
		jsr SetSprite
		
		;Yarita Character (64x32) - Feet
		
		move.l #1,d0		;Sprite Num
		move.l #$C0,d1		;Xpos
		move.l #$A0,d2		;Ypos
		move.l #$0220,d3 	;Tile (512+4)
		move.l #$0F02,d4 	;Link +WidthHeight (32x32)
		jsr SetSprite
		
		
		;Crosshair (16x16)
		
		move.l #$140,d1		;Xpos
		move.l #$0200,d3 	;Tile (512) 
GensisSpriteTest:		
		move.l #2,d0		;Sprite Num
		
		move.l #$80,d2		;Ypos
		
		move.l #$0500,d4 	;Link +WidthHeight (16,16) - Last sprite links back to 0
		jsr SetSprite
		
		addq.l #2,d1		;increase Xpos
		and.l #$01FF,d1
		
		addq.l #4,d3		;Inc Sprite (4 tiles per 16x16 Sprite)
		and.l #$020F,d3		;Repeat at sprite 16
		
		jsr WaitVblank		;Delay
		jsr WaitVblank
		jsr WaitVblank
		
		jmp GensisSpriteTest
	endif
	
	
InfLoop:
	ifd BuildNEO
		jsr KickWatchdog
	endif
	
	jmp InfLoop

	
	
	

	;#$D800

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
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
Bitmap:
	ifd BuildX68
		incbin "\ResALL\Sprites\RawMSX.RAW"
	endif	
	ifd BuildGEN
		incbin "\ResALL\Sprites\RawMSXVdp.RAW"
	endif
	ifd BuildAST
		incbin "\ResALL\Sprites\RawAMI.RAW"
	endif
	ifd BuildAMI
		incbin "\ResALL\Sprites\RawAMI.RAW"
	endif
	ifd BuildSQL
		ifd Mode4Color
			incbin "\ResALL\Sprites\RawQL4.RAW"
		else
			incbin "\ResALL\Sprites\RawQL.raw"
		endif
	endif
BitmapEnd:

	
Sprite:
	ifd BuildX68
		incbin "\ResALL\Sprites\SpriteX68.RAW"
	endif
	ifd BuildGEN
		incbin "\ResALL\Sprites\SpriteGEN.RAW"
	endif
SpriteEnd:
	

	even
Palette:
	;     -grb
	dc.w $0000	;0 - Background
	dc.w $0099	;1
	dc.w $0E0F	;2
	dc.w $0FFF	;3
	dc.w $00FF;4  -GRB
	dc.w $0FF0;5  -GRB
	dc.w $060D;6  -GRB
	dc.w $0770;7  -GRB
	dc.w $0888;8  -GRB
	dc.w $0999;9  -GRB
	dc.w $0AAA;10  -GRB
	dc.w $0BBB;11  -GRB
	dc.w $0CCC;12  -GRB
	dc.w $0DDD;13  -GRB
	dc.w $0EEE;14  -GRB
	dc.w $0FFF;15  -GRB

	ifd BuildAMI
		dc.w $0000	;0 - Background
		dc.w $0099	;1
		dc.w $0E0F	;2
		dc.w $0FFF	;3
		dc.w $00FF;4  -GRB
		dc.w $0FF0;5  -GRB
		dc.w $060D;6  -GRB
		dc.w $0770;7  -GRB
		dc.w $0888;8  -GRB
		dc.w $0999;9  -GRB
		dc.w $0AAA;10  -GRB
		dc.w $0BBB;11  -GRB
		dc.w $0CCC;12  -GRB
		dc.w $0DDD;13  -GRB
		dc.w $0EEE;14  -GRB
		dc.w $0FFF;15  -GRB
	endif
	
	even

Message: dc.b 'Hello World!!!',255
	even
	include "\SrcALL\V1_RamArea.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Ram Area - May not be possible on all systems!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;				Amiga Sprites
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ifd BuildAMI
StartSprite0:	
	dc.w $804A ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $9000 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI.RAW"		;Crosshair (16x16) Bitplane 01
	
	dc.w $A070 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $B000  ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI.RAW"		;Crosshair (16x16) Bitplane 01
	
	dc.w $B070 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $C000  ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI.RAW.2"	;Crosshair (16x16) Bitplane 01
	dc.w 0,0				;End of Sprites
	
StartSprite1:	
	dc.w $804A ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $9080 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI.RAW.2" 	;Crosshair (16x16) Bitplane 23
	dc.w 0,0				;End of Sprites
	
	
StartSprite2:
	dc.w $4060 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $8000 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI2.RAW"		;Yarita Character L (16x64) Bitplane 01
	dc.w 0,0				;End of Sprites
StartSprite3:	
	dc.w $4060 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $8080 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI2.RAW.2"	;Yarita Character L (16x64) Bitplane 23
	dc.w 0,0				;End of Sprites
StartSprite4:
	dc.w $4068 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $8000 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI2B.RAW" 	;Yarita Character R (16x64) Bitplane 01
	dc.w 0,0				;End of Sprites
StartSprite5:	
	dc.w $4068 ;SSSSSSSS HHHHHHHH - S=Start Vert, H=Horiz
	dc.w $8080 ;EEEEEEEE A------- - E=End Vert, A=Attatch to prev sprite
	incbin "\ResALL\Sprites\SpriteAMI2B.RAW.2"	;Yarita Character L (16x64) Bitplane 23
	dc.w 0,0				;End of Sprites
	
StartSprite6:				;Unused Sprites
	dc.w 0,0				;End of Sprites
StartSprite7:	
	dc.w 0,0				;End of Sprites
	endif
	
	
	include "\SrcALL\V1_Footer.asm"