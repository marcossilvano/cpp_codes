	ifd ScrWid256
Res256x256 equ 1
	endif
	ifnd Res256x256
	ifnd Res512x256
	ifnd Res512x512
Res256x256 equ 1
	endif
	endif
	endif
;Res256x256 equ 1
;Res512x256 equ 1
;Res512x512 equ 1

Start:


	clr.l d0			;0=Enable Supervisor mode
	move.l d0,-(sp)
	dc.w $FF20			;Switch Mode
	addq.l  #4,sp
	

	jsr ScreenINIT		;init the graphics screen
	jsr cls
	