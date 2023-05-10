

Spr_TileL equ 0
Spr_TileH equ 1

Spr_PattL equ 2
Spr_PattH equ 3

Spr_Width equ 4
Spr_Height equ 5

Spr_Xpos equ 6
Spr_Ypos equ 7

Spr_RefreshTile equ 8
Spr_RefreshSprite equ 9


Spr_OldXpos equ 10
Spr_OldYpos equ 11

Spr_Flags equ 12
;Spr_OldFlags equ 13


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FlagSpriteForRefresh:				;Mark sprite needs
	ld a,1
	ld (ix+Spr_RefreshTile),a
	ld (ix+Spr_RefreshSprite),a
	ret		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawSprite:
	ld a,(ix+Spr_RefreshSprite)		;Check if we need to do redeaw
	or a
	ret z
	xor a
	ld (ix+Spr_RefreshSprite),a
DrawSpriteAlways:					;Force redraw

	ld c,(ix+Spr_TileL)
	ld b,(ix+Spr_TileH)
	push bc
	pop iy							;Tile Map source

	ld b,(ix+Spr_Xpos)				;Sprite Position
	ld c,(ix+Spr_Ypos)

	ifdef LowResX
		ld a,b
		and %11111100
		ld b,a
	endif
	ifdef LowResY
		ld a,c
		and %11111100
		ld c,a
	endif
	
	ld (ix+Spr_OldXpos),b
	ld (ix+Spr_OldYpos),c			;Update Lastpos

	exx
		ld e,(ix+Spr_PattL)			;Sprite pattern data
		ld d,(ix+Spr_PattH)
	exx

	ld a,(ix+Spr_Flags)			;Flip flag
	push af

		ld d,(ix+Spr_Width)
		ld e,(ix+Spr_Height)
		ex de,hl				;HL=Width,Height
		push hl
			ld a,(ix+Spr_Flags)
			call DoCrop			;Crop the sprite BC=XY pos 
								;HL=WidthHeigh, IY=source data
								
			jr c,DrawAbort		;Nothing to draw
		
		
			srl l
			srl l				;Convert to tile width

			srl h				;convert to tile height
			srl h
			
			push hl
				call GetScreenPos
			pop ix				;Width Height

			push iy		;Tilemap source
			pop de
	
		pop af
		srl a
		srl a
		ld iyh,a	;Tilemap Width
	pop af
	bit 0,a
	jp z,DrawTilemap

	jp DrawTilemapRev
DrawAbort:
	pop af
	pop af
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;DE=Tilemap DE'=Pattern data IX=WH IYH=Tilemap Width HL=Vram Dest

DrawTilemap:			
NextLine:
	push de			
	exx
		pop bc			;BC' = Tilemap Source
	exx

	ld a,ixh
	ld iyl,a			;Draw Width 
	
	push hl
	push de
	ifdef StripRoutine
		ld a,(StripRoutine)		;Draw type?
		or a
		jr nz,DoStripRevver		;Reverse
		call DoStrip			;Normal
		jp DoStripDone
DoStripRevver:		
		call DoStripRev
DoStripDone:
	else
		Call DoStrip	;Draw a Hline
StripRoutine_Plus2:  ;<-- Use Self modifying code to switch routine
	endif
	pop de				;Tilemap Source
	pop hl				;Screen Pos
	
;Platform specific NextLine Commands
	
	ifdef BuildZXN
		ld a,h
		add 8
		ld h,a
		
		cp &40
		jr c,NextLine2b
		sub &20
		ld h,a
		
		GetNextReg &51
		inc a			;8k banks	
		nextregA &51	;Page in B+1 to &2000-&3FFF range
NextLine2b:
	else
		ifdef BuildZXS
			ld a,l
			add %00100000
			ld l,a
			jr nc,NextLine2b
			ld a,h
			add %00001000;8
			ld h,a
NextLine2b:
		endif
	endif
	ifdef BuildCPC
		ld a,64			;Fix up Ypos for next line
		add l
		ld l,a
		jr nc,NoUpper
		inc h
NoUpper:
	endif
	ifdef BuildENT
		inc h
		inc h
NoUpper:
	endif
	ifdef BuildSAM
		inc h			;Fix up Ypos for next line
		inc h
		inc h
		inc h
	endif
	ifdef BuildSMS
		ld a,l
		add 64
		ld l,a
		jr nc,NoUpper
		inc h
NoUpper:
	endif
	ifdef BuildMSX
		ifdef MinTileMSX2
			ld a,8
			add l
			ld l,a
		else
			inc h
		endif
	endif
	
	ld a,iyh			;Update Tilemap source (Add width)
	add e
	ld e,a
	jr nc,NoUpper2
	inc d
NoUpper2:

	dec ixl
	jr nz,NextLine		;Repeat for next line
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawTilemapRev:			;Draw a flipped tilemap
	ld a,ixh			;Width of tilemap
	dec a
	add e
	ld e,a				;Move to right hand of tilemap
	jr nc,DoStripRevTopOk	
		inc d
DoStripRevTopOk:

	ifdef StripRoutine
		ld a,1
		ld (StripRoutine),a		;Switch drawing routins on ROM
	else
		ld bc,DoStripRev
		ld (StripRoutine_Plus2-2),bc	;Patch in new draw engine
	endif
	call DrawTilemap			;Do the draw
	ifdef StripRoutine
		xor a ;ld a,0
		ld (StripRoutine),a		;Reset the drawingroutine
	else
		ld bc,DoStrip
		ld (StripRoutine_Plus2-2),bc	;Restore old engine
	endif
	ret
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;DE=Tilemap
	;HL=Pattern Data
	
cls:			;Redraw Entire screen
	push hl
	push de
	exx
		pop bc			;Tilemap
		pop de			;Pattern Data
	exx
		
	ld ixl,&18			;Draw Height (24 tiles)
	ld hl,ScreenBase	;Vram Destination
	
	ifdef BuildZXN
		ld a,16
		nextregA &51	;Page in B+1 to &2000-&3FFF range
	endif
	
NextLineF:
	ld iyl,32			;Draw Width
	
	Call DoStrip		;Platform specific draw routine to draw one
						;8 pixel tall line
				
;Platform specific NextLine Commands to correct HL after a full 32 tile strip

	ifdef BuildZXN
		ld a,h
		add 8
		ld h,a
		cp &40
		jr c,NextLine2
		sub &20			;Roll back to &2000-3FFF range
		ld h,a
		GetNextReg &51
		inc a			;8k banks	
		nextregA &51	;Page in B+1 to &2000-&3FFF range
NextLine2:
	else
		ifdef BuildZXS
			ld a,l
			and %11100000;32
			jr nz,NextLine2
			ld a,h
			add %00001000;8
			ld h,a
NextLine2:
		endif
	endif
	ifdef BuildSAM
		inc h
		inc h
		inc h
		inc h
	endif
	ifdef BuildENT
		ld l,0
		inc h
		inc h
	endif
	ifdef BuildCPC
		ld a,l
		or a
		jr nz,NoUpperF
		inc h
NoUpperF:
	endif
	ifdef BuildSMS
		ld a,l
		or a
		jr nz,NoUpperF
		inc h
NoUpperF:
	endif
	ifdef BuildMSX
		ifdef MinTileMSX2
			ld a,8
			add l
			ld l,a
		else
			inc h
		endif
	endif
	
	dec ixl			;Repeat for next vertical line
	jr nz,NextLineF
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;X,Y pos = BC / Width+Height = HL   IY=Source
;A= Sprite Flags

DoCrop:
	bit 0,a
	jr z,DoCropNoRev

;The Source recalc routine won't work right for flipped sprites
;so we flip the Xpos before running the crop routine	
	
	ld a,h
	add b
	neg						;Flip Xpos
	ld b,a			

	call DoCropNoRev
	ret c
	
	ld a,VscreenWid+1
	ifdef BuildSAM
		ld a,VscreenWid	;Correct Xpos
	endif	
	ifdef BuildCPC
		ld a,VscreenWid+1
	endif
	ifdef BuildENT
		ld a,VscreenWid+1
	endif
	ifdef BuildSMS
		ld a,VscreenWid+1
	endif
	ifdef BuildZXN
		ld a,VscreenWid+4
	else
		ifdef BuildZXS
			ld a,VscreenWid+1
		endif
	endif
	
	sub h			;Flip to opposite side of screen.
	sub b
	ld b,a

	or a			;Clear Carry
	ret
	
DoCropNoRev:
	;xor a
	;ld (SpriteHClip),a		;Clear sprite Clipping
	
	ld de,0				;Temp Vars (E=Top Crop D=Bottom Crop)

;Crop Top side
	ld a,c
	sub VscreenMinY		;Logical top of the screen
	jr nc,NoTCrop
	
	neg
	inc a				;Round Up
	inc a

	cp l				;No pixels onscreen?
	jp nc,DoCrop_AllOffscreen	;All Offscreen
	ld e,a				;Top Crop

	and %00000011
	xor %00000011		;Shift amount
NoTCrop:


;Crop Bottom side
	ld c,a
	add l
	sub VscreenHei-VscreenHeiClip	;Logical height of screen
	jr c,NoBCrop
	and %11111100
	
	cp l				;No pixels onscreen?
	jp nc,DoCrop_AllOffscreen	;All Offscreen
	ld d,a				;Bottom Crop
NoBCrop:


;Calculate New Height
	ld a,e
	and %11111100		;Convert to tile count
	add d
	jr z,NoVClip
	neg
	add l
	ld l,a				;Height
	
	
;Remove lines from top
	ld d,e
	
	ld e,h				;Bytes per line	
	srl e
	srl e
	
	ld a,d				;Lines to remove from top
	srl a
	srl a				;Convert to tiles
	jr z,NoVClip
	
	ld d,0
MoveDownALine:
	add iy,de			;Update Start Byte
	dec a
	jr nz,MoveDownALine		


NoVClip:
	ld de,0			;Temp Vars (E=Right Crop D=Left Crop)

;Crop Left hand side
	ld a,b
	sub VscreenMinX 	;64 = Leftmost visible tile
	jr nc,NoLCrop
	neg
	inc a
	inc a

	cp h				;No pixels onscreen?
	jr nc,DoCrop_AllOffscreen		;Offscreen
	ld e,a

	and %00000011		
	xor %00000011		;Shift amount
NoLCrop:
	ld b,a

;Crop Right hand side
	add h
	sub VscreenWid-VscreenWidClip	;Logical Width of screen
	jr c,NoRCrop
	cp h				;No pixels onscreen?
	jr nc,DoCrop_AllOffscreen	;Offscreen
	ld d,a		
NoRCrop:


;Calculate new width
	ld a,d
	add e				
	srl a
	srl a				;Total Crop amount in tiles
	jr z,NoHClip
	;ld (SpriteHClip),a		;Amount to skip after each line

	sla a
	sla a
	ld d,a				;Amount to subtract from width (Right)

	ld a,h
	sub d
	ld h,a				;Updated Width

	
;Caclulate start byte
	ld a,e				;Amount to subtract from left
	
	srl a
	srl a				;Convert to tile count (/4)
	
	ld d,0
	ld e,a

	add iy,de			;Move Across 
	
NoHClip:	
	or a				;Clear Carry
	ret

	
DoCrop_AllOffscreen:
	scf					;Set Carry (nothing to draw)
	ret
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;Redraw the background under a sprite

RemoveSprite:	;BC= X,Y pos	;A=Sprite flags
	ld a,(ix+Spr_RefreshTile)
	or a
	ret z

	ld b,(ix+Spr_OldXpos)
	ld c,(ix+Spr_OldYpos)
	
	ifdef LowResX
		ld a,b
		and %11111100
		ld b,a
	endif
	ifdef LowResY
		ld a,c
		and %11111100i
		ld c,a
	endif
	
	ifdef TileSmoothXmove
		ifdef Spr_OldWidth
			ld a,(ix+Spr_OldWidth)		;Do we allow 2/4 pixel moves?
		else
			ld a,(ix+Spr_Width)		;Do we allow 2/4 pixel moves?		
		endif 
		add 4
		ld d,a
	else
		ifdef Spr_OldWidth
			ld d,(ix+Spr_OldWidth)		;Do we allow 2/4 pixel moves?
		else
			ld d,(ix+Spr_Width)		;Do we allow 2/4 pixel moves?		
		endif 
	endif
	ifdef TileSmoothYmove
		ifdef Spr_OldHeight
			ld a,(ix+Spr_OldHeight)
		else 
			ld a,(ix+Spr_Height)
		endif
		add 4
		ld e,a
	else
		ifdef Spr_OldHeight
			ld e,(ix+Spr_OldHeight)
		else 
			ld e,(ix+Spr_Height)
		endif
	endif
	ex de,hl
	
	
	call DoCropNoRev	;Crop the sprite BC=XY pos 
						;HL=WidthHeigh, IY=source data
	ret c				;Nothing to draw

	call DoCropLogicalToTile	;Convert to tile co-ords
	ret z

	push hl
	pop ix					;Width/Height
	
	ld iyh,&20				;Tilemap Width
	ld de,TileCache
	call ShiftTilemap		;Uses IYH only

	push hl
		ld iyh,&24			;Tilemap Width
		ld de,Tilemap2
		ld a,(offset)		;X Scroll position
		and %00000011		;4 tile 'scroll area'
		ld h,0
		ld l,a
		add hl,de			;Shift source Tilemap by offset
		ex de,hl
		call ShiftTilemap	;Alter tilemap pos for current sprite position
	pop de
	
	
	ld iyl,&20	;Tilemap Width (32 tiles in cache)
UpdateTileCache:		;HL=Source tilemap   DE=Tile cache dest
	ld b,0				;IXL=Spr Height  IXH=Spr Width
UpdateTileCacheB:
	push hl
		push de
			ld c,ixh
			ldir		;Copy bytes of tilemap to cache
UpdateTileCacheA:
		pop hl
		ld c,iyl		;Width of sprite
		add hl,bc		;B=0
		ex de,hl
	pop hl

	ld c,iyh			;Width of tilemap
	add hl,bc	

	dec ixl
	jr nz,UpdateTileCacheB
	ret





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;			DE=Tilemap	BC=XY pos  IYH=Width
;Returns 	HL=New Tilemap Pos

ShiftTilemap:
	ex de,hl

	ld d,0
	ld e,iyh		;Tilemap width
	
	ld a,c			;Y
	or a
	jr z,NoAdd
ReAdd:
	add hl,de		;Move down C lines 
	dec a
	jr nz,ReAdd
NoAdd:
	ld e,b
	add hl,de		;Move across B tiles

	ret				;HL=New Tilemap Pos

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert Logical pos to Tilemap tile pos 
; Z=True if size is zero


DoCropLogicalToTile:	;Z= Invalid Width/Height
	srl b
	srl b		;Xpos /4

	srl c		;Ypos /4
	srl c
	
	srl l		;Height /4
	srl l

	srl h		;Width /4
	srl h

	ld a,h		;Is width or height zero?
	or a 
	ret z
	ld a,l
	or a 
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Compare tilemap BC to HL and copy tiles to cache DE if different

;BC and HL (Source Tilemap) must be &24 tiles wide... DE (Cache) must be &20
;IXH = Width    IXL=Height 

ChangeScroll:
	push ix
ChangeScrollAgain:
		ld a,(bc)			;Get source Tile
		cp (hl)				;Is Dest Correct?
		jr z,ChangeScrollOk
		ld (de),a			;No! Request an update
ChangeScrollOk:
		inc hl				;Source Tilemap 1
		inc bc				;Source Tilemap 2
		inc de				;Dest Tilemap
		dec ixh
		jr nz,ChangeScrollAgain
	pop ix

	inc hl					;Skip 4 unused tiles in tilemap
	inc hl
	inc hl
	inc hl

	inc bc
	inc bc
	inc bc
	inc bc

	dec ixl
	jr nz,ChangeScroll
	ret






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Remove a sprite from the cache (Stops sprite flickering)

ZeroSpriteInCache:	;BC= X,Y pos   IX=Sprite Source
	
	ld a,(ix+Spr_RefreshTile)	;Check if we need to zero the sprite
	or a
	ret z
	
	xor a
	ld (ix+Spr_RefreshTile),a

	
	ld b,(ix+Spr_Xpos)
	ld c,(ix+Spr_Ypos)

	ifdef LowResX
		ld a,b
		and %11111100
		ld b,a
	endif
	ifdef LowResY
		ld a,c
		and %11111100
		ld c,a
	endif

	ld d,(ix+Spr_Width)
	ld e,(ix+Spr_Height)
	ex de,hl

	ifdef TileSmoothXmove
		ld a,b
		and %00000010	;Shift Xpos one half tile
		jr z,NoHalf		;& reduce width 1/2 tile
		ld a,b
		inc a
		inc a
		and %11111100	
		ret z
		ld b,a			;Alter Xpos
		dec h			;Alter Width
		dec h
NoHalf:	
	endif
	
	ifdef TileSmoothYmove
		ld a,c
		and %00000010	;Shift Xpos one half tile
		jr z,NoHalf2	;& reduce width 1/2 tile
		ld a,c
		inc a
		inc a
		and %11111100	
		ret z
		ld c,a			;Alter Ypos
		dec l			;Alter Height
		dec l			
NoHalf2:	
	endif
	ld a,(ix+Spr_TileL)		;Tilemap
	ld iyl,a
	ld a,(ix+Spr_TileH)
	ld iyh,a
	
	ld a,(ix+Spr_Flags)
	call DoCrop	;Crop the sprite BC=XY pos HL=WidthHeight
				;IY=source data
				
	ret c		;Nothing to draw

	bit 0,(ix+Spr_Flags)
	jr z,DoCropLogicalToTileB
		inc b					;Shift Xpos if X-flipped
		inc b
DoCropLogicalToTileB:
	call DoCropLogicalToTile	;Convert XYWH to tile numbers
	ret z

	
	ld a,(ix+Spr_Flags)
	push af
		ld a,(ix+Spr_Width)		;Width of source tilemap
		push af
			push iy				;Source Tilemap
				push hl
				pop ix			;Width/Height of draw
				
				ld iyh,&20		;Cache Tilemap Width
				ld de,TileCache
				call ShiftTilemap	;Shift the tilecache
				ex de,hl			; to match sprite
			pop hl
		pop af
		srl a
		srl a
		ld iyh,a			;Sprite Tilemap Width
		
		ld iyl,&20			;Cache Tilemap Width
	pop af
	
	
	
	bit 0,a
	jr z,ZeroTileCache		;Not Xflipped
	
ZeroTileCacheRev:
	ld a,ixh				;Width
	dec a
	add l
	ld l,a					;Shift Tilemap by width
	jr nc,ZeroTileCache2
	inc h
ZeroTileCache2:

	ld a,&2B				;DEC HL - Reverse 
	ifdef ZeroTileCacheRevM
		ld (ZeroTileCacheRevM),a
	else
		ld (ZeroTileCacheRev_Plus1-1),a
	endif

	call ZeroTileCache		;Perform the Zero

	ld a,&23				;INC HL - Restore Defaults
	ifdef ZeroTileCacheRevM
		ld (ZeroTileCacheRevM),a
	else
		ld (ZeroTileCacheRev_Plus1-1),a
	endif
	ret

	
ZeroTileCache:
	push hl
		push de
			ld b,ixh		;Width of sprite
zeroCachec:
			ld a,(hl)		;Check sprite tile
			or a
			jr z,zeroCacheb
			xor a
			ld (de),a		;Zero Cache (unused tile)
zeroCacheb:
			inc de			;Inc Cache address
			
			ifdef ZeroTileCacheRevM
				ld a,(ZeroTileCacheRevM)
				cp &2B		;&2B = Dec HL
				jr z,zerodec
				inc hl
				jr zerodone
zerodec:				
				dec hl
zerodone:
			else
				inc hl		;Inc Sprite address
ZeroTileCacheRev_Plus1:			
			endif

			djnz zeroCachec
		pop hl
		ld c,iyl			;&20
		add hl,bc			;Move Cache down a line (B=0)
		ex de,hl
	pop hl

	ld c,iyh				;Sprite Tilemap width
	add hl,bc				;Move Sprite down a line (B=0)

	dec ixl
	jr nz,ZeroTileCache
	ret











