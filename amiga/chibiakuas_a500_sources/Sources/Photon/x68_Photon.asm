	include "\SrcALL\BasicMacros.asm"

Color1 equ 1				;Color palette
Color2 equ 2				;These are color attributes
Color3 equ 3				
Color4 equ 4

ScreenWidth32 equ 1			;Screen Size Settings
ScreenWidth equ 256
ScreenHeight equ 240
ScreenHeight240 equ 1
	

;Turn on the screen.

	;		 FEDCBA9876543210	
	move.w #%0000000000000000,$e80028 ;R20 Memory mode/Display mode control
	move.w #%0000000000000000,$e82400 ;R0 (Screen mode initialization) - Detail
	;		 --SSTTGG44332211
	move.w #%0000001011100100,$e82500 ;R1 (Priority control) - Priority
	;		 FEDCBA9876543210	
	;				  ST43210		
	move.w #%0000000011000001,$e82600 ;R2 (Special priority/screen display) 
	
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
	move.w #%0000000000000000,$e82000	;Color 0 Black
	move.w #%1111100000111110,$e82002	;Color 1 Cyan
	move.w #%0000011111111110,$e82004	;Color 2 Magenta
	move.w #%1111100000000000,$e82006	;Color 3 White
	move.w #%1111111111000000,$e82008	;Color 4 Yellow

	
	lea userram,a3
	move.l #$100,d1
	jsr cldir0				;Clear Game Ram
	
	jsr mainmenu			;show main menu

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


infloop:					;main loop	
	move.b (tick),d0
	addq.b #1,d0
	and.b #%00000001,d0		;Update the game tick
	move.b d0,(tick)

	move.l #300,d1			;slow down delay

	move.b (boost),d0
	bne boostoff			;boost - no delay 

	move.l #200,d1			;(compensate for font draw)

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
	tst.b (keytimeout)
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
	btst #4,d2					;4321RLDU
	bne joynotfire
	tst.b (boostpower)		;check if boost power remains
	beq joynotfire

	clr.b (boost)		;turn on boost
joynotfire:
joyskip:
	jsr handleplayer		;draw and update player
	jsr handlecpu			;draw and update cpu
	jmp infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Pset: 		;D1=X D4=Y	D2=Color
	moveM.l d2/a3,-(sp)
		jsr GetScreenPos		;Calculate ram address
		and.l #$0F,d2			;only 16 color
		move.w d2,(a3)			;update pixel
	moveM.l (sp)+,d2/a3
	rts
	
Point:
	moveM.l a3,-(sp)
		jsr GetScreenPos		;Calculate ram address
		move.w (a3),d0			;Get pixel color
	moveM.l (sp)+,a3
	rts

GetScreenPos: ; d1=x d4=y
	moveM.l d0-d4,-(sp)
		and.l #$FF,d1
		and.l #$FF,d4
		
		rol.l #1,d1				;2 bytes per pixel		
		add.l #$c00000,d1		;Graphics Vram – Page 0
		bclr.l #0,d1			;Clear Bit 0
		move.l d1,a3
		
		rol.l #8,d4				;1024 bytes per Y line 
		rol.l #2,d4
		add.l d4,a3
	moveM.l (sp)+,d0-d4
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Cls:
	move.l #$c00000,a3	  ;Screen Base
	move.l #(1024*256/4)-1,d1 ;We have to fill the full width of the maximum screen (1024)
	
ClsAgain:	
	clr.l (a3)+			;4 bytes per iteration
	dbra d1,ClsAgain
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Player_ReadControlsDual:		;Returns: ---7654S321RLDU
	moveM.l d1-d7/a0-a7,-(sp)
		move.l #$E9A001,a0		;Select Joystick # 1
		jsr JoystickProcessOne	;Process buttons
	moveM.l (sp)+,d1-d7/a0-a7
	rts
	
JoystickProcessOne:			;Returns: ---7654S321RLDU
	clr.l d0	
;	         76543210
	move.b #%00000000,$E9A005	;8255 Port C (Default Controls)
	move.b (a0),d1				;-21-RLDU
	roxr.b d1
	roxr.b d0	;U
	roxr.b d1
	roxr.b d0	;D
	roxr.b d1
	roxr.b d0	;L
	roxr.b d1
	roxr.b d0	;R
	roxr.b #2,d1				;skip -
	roxr.b d0	;F1
	roxr.b d1
	roxr.b d0	;F2
	
	;	     76543210
	move.b #%00110000,$E9A005	;8255 Port C (Get Extra Controls)
	move.b (a0),d1				;-S3-M654 ?
	move.b d1,d3
	roxr.b #6,d1				;-------S 3	
	roxr.b d0	;F3
	roxr.b d1
	roxr.b d0	;Start
	
	and.l #$0000000F,d3			;____M654
	rol.l #8,d3
	
	or.l d3,d0
	or.l #$FFFFF000,d0
	rts	
	
	
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
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
UserRam:
	ds $100
	even