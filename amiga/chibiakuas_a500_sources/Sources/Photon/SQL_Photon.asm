	include "\SrcALL\BasicMacros.asm"

;Game Colors 
Color1 equ 5				;Cyan
Color2 equ 6				;Magenta
Color3 equ 1				;Green
Color4 equ 3				;Yellow

ScreenWidth32 equ 1			;Screen Size Settings
ScreenWidth equ 256
ScreenHeight equ 256
ScreenHeight256 equ 1

UserRam equ $30000			;Game ram address


ProgramStart:	
	
	move.b #%00001000,$18063	;Force 8 color mode!
	
	lea userram,a3
	move.l #$100,d1
	jsr cldir0				;Clear Game Ram
	
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


infloop:					;main loop	
	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0		;Update Game Tick
	move.b d0,(tick)

	move.l #50,d1			;slow down delay

	move.b (boost),d0
	bne boostoff			;boost - no delay 
	move.l #1,d1			;(compensate for font draw)

	
boostoff:
	move.b #%11111111,d2	;key buffer
pausebc:
	pushbc
		pushde
			jsr Player_ReadControlsDual		;Get Joystick
		popde
		cmp.b #%11111111,d0
		beq pausenokey
		move.b d0,d2		;store any pressed joystick buttons
		bra keysdown

pausenokey:		;released - nuke key, and relese keypress
		clr.b (keytimeout)	
		move.b #%11111111,d2
keysdown:
	popbc
	subq.l #1,d1
	bne pausebc

startdraw:
	tst.b (keytimeout)			;See if keys still down?
	bne joyskip					;yes, skip keypresses

	move.b #1,(boost)			;boost off

processkeys:
	move.l #playerdirection,a3
	move.l #playerxacc,a6		;point a6 to player accelerations 

	btst #2,d2					;4321RLDU - L
	bne joynotleft

	subq.w #1,(a3)
	jsr setplayerdirection
	move.b #1,(keytimeout)		;ignore keypresses

joynotleft:
	btst #3,d2					;4321RLDU - R
	bne joynotright

	addq.w #1,(a3)
	jsr setplayerdirection
	move.b #1,(keytimeout)		;ignore keypresses

joynotright:
	btst #4,d2					;4321RLDU - F
	bne joynotfire
	tst.b (boostpower)		;check if boost power remains
	beq joynotfire

	clr.b (boost)			;turn on boost
joynotfire:
joyskip:
	jsr handleplayer		;draw and update player
	jsr handlecpu			;draw and update cpu
	jmp infloop

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	
Pset: 		;D1=X D4=Y	D2=Color
	moveM.l d0-d4/a3-a4,-(sp)
		and.l #$00FF,d1
		and.l #$00FF,d4
		jsr GetScreenPos		;Calculate address of pixel
		
		and.l #$03,d1
		move.l #PixelLookup,a4	;Get mask for pixel in bytes
		add.l d1,a4
		move.b (a4),d1
		eor.b #$ff,d1			;Get mask for background
		
		move.b (a4),d3			;Get mask for pixel
		
		move.b (a3),d0			;Get first byte (Flashing/Green)
		and.b d1,d0				;Green Bit
		roxr.b d2
		bcc NoBit0				;Test Color
		or.b d3,d0
NoBit0:
		move.b d0,(a3)			;Update it 
		
		add.l #1,a3
		move.b (a3),d0			;Get second byte (Red/Blue)
		and.b d1,d0				;Red Bit
		roxr.b d2
		bcc NoBit1				;Test Color
		or.b d3,d0
NoBit1:
		move.b d0,(a3)			;Update it 
		
		ror.b #1,d1				;Shift Masks
		ror.b #1,d3				
		
		move.b (a3),d0			;Get second byte (Red/Blue)
		and.b d1,d0				;Blue Bit
		roxr.b d2
		bcc NoBit2				;Test Color
		or.b d3,d0
NoBit2:
		move.b d0,(a3)			;Update it 
	moveM.l (sp)+,d0-d4/a3-a4
	rts
	
	
		; Green / Flash 	 Red / Blue
PixelLookup:
		; GFGFGFGF  GFGFGFGF  GFGFGFGF  GFGFGFGF
	dc.b %10000000,%00100000,%00001000,%00000010


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
GetScreenPos: 			; d1=x d2=y - Returns address in a6
	moveM.l d1-d2,-(sp)
		and.l #$FC,d1
		lsr.l #2,d1		;4 pixels per pair of bytes
		and.l #$FF,d4
		
		rol.l #1,d1		;Multiply X*2 (2 bytes per 4 pixels)
		rol.l #7,d4		;Multiply Y*128
		
		move.l #$00020000,a3	;Screen starts at $20000
		add.l d4,a3
		add.l d1,a3
	moveM.l (sp)+,d1-d2
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Point:							;D1=X D4=Y
	moveM.l d1-d4/a3-a4,-(sp)
		and.l #$00FF,d1
		and.l #$00FF,d4
		jsr GetScreenPos		;Calculate address of pixel
		
		and.l #$03,d1
		move.l #PixelLookup,a4	;Get mask for pixel in bytes
		add.l d1,a4
		move.b (a4),d1
		
		clr.l d0				;Buildup for the pixel color
		
		move.b (a3),d2
		and.b d1,d2
		beq NoBit0b
		or.b #1,d0				;Green Bit
NoBit0b:
		add.l #1,a3
		move.b (a3),d2
		and.b d1,d2
		beq NoBit1b
		or.b #2,d0				;Red Bit
NoBit1b:
		ror.b #1,d1				;Shift Masks
		ror.b #1,d3			
		
		move.b (a3),d2
		and.b d1,d2
		beq NoBit2b
		or.b #4,d0				;Blue Bit
NoBit2b:
	moveM.l (sp)+,d1-d4/a3-a4
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
		
Cls:
	move.l #$00020000,a3	;Address to clear
	move.l #(256*128),d1	;Bytes to clear
	jsr cldir0
	rts

	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Player_ReadControlsDual:;---7654S321RLDU
	moveM.l d1-d2,-(sp)	
		 lea QLJoycommand,a3
		 move.b #$11,d0	;Command 17
		 Trap #1		;Send Keyrequest to the IO CPU
						;Returns row in D1
		
		clr.l d0		;D0 is our result
		move.b d1,d2
		roxr.b #4,d2	; ESC
		roxl.b #1,d0	;Start (4)
		
		roxr.b #2,d2	; \ 
		roxl.b #1,d0	;Fire 3 (6)
		
		move.b d1,d2
		roxr.b #1,d2	; Enter (1)
		roxl.b #1,d0	;Fire 2
		
		roxr.b #6,d2	;Space (7)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #5,d2	;Right (5)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #2,d2	;Left (2)
		roxl.b #1,d0
		
		roxr.b #6,d2	;Down (8)
		roxl.b #1,d0
		
		move.b d1,d2
		roxr.b #3,d2	;Up   (3)
		roxl.b #1,d0
		
		move.l #$FFFFFFFF,d1	;Dummy player2
		eor.l d1,d0		;Flip Player 1 bits
	moveM.l (sp)+,d1-d2
	rts
	
QLJoycommand:
	dc.b $09	;0 - Command
	dc.b $01	;1 - parameter bytes
	dc.l 0		;2345 - send option (%00=low nibble)
	dc.b 1		;6 - Parameter: Row
	dc.b 2		;7 - length of reply (%10=8 bits)
	even
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
waitforfire:

	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	bne waitforfire

waitforfireb:
	jsr dorandom			;reseed random numbers
	jsr Player_ReadControlsDual
	and.b #%00010000,d0		;Fire Button
	beq waitforfireb
	rts


	even
	include "\ResAll\Vector\VectorFont.asm"
	
	include "PH_Title.asm"
	even
	
	include "\SrcALL\BasicFunctions.asm"	
	include "\SrcALL\MultiPlatform_ShowDecimal.asm"
	include "PH_DataDefs.asm"
	include "PH_RamDefs.asm"
	
	even
	include "PH_Multiplatform.asm"
	include "PH_Vector.asm"
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
