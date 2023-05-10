;------------------------------
; BITS OPERATIONS/MANIPULATIONS
;------------------------------
; Assembly:
;  Ctrl + B
;
; Debug:
;  fs-aue --hard_drive_0=uae/dh0 --console_debugger=1
;
;  F12 + D (ativar debugger)
;  >g (cotinua execução)
;  >z (executa próxima linha)
;  >m address lines (dump memory)

;---------- Const ----------
MOUSE_REG = $bfe001
MBUTTON_1 = 6

Symboltest equ $9876

;---------- Main -----------
       ;CMP D0,D1  	Signed Unsigned
       ;D0 >  D1	BLT	BCS
       ;D0 >= D1	BLE	BLS
       ;D0 == D1	BEQ	BEQ
       ;D0 != D1	BNE	BNE
       ;D0 <  D1	BGT	BHI
       ;D0 <= D1	BGE	BCC

       MACRO EightNoOps
              nop
              nop
              nop
              nop
              nop
              nop
              nop
              nop
       ENDM

wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       move.l #$FFFFFFFF,d0
       move.l #$00000000,d1
again:
       move.b #0,d3
       move.b #0,d6
       exg d0,d1

       move.w #$F000,d7
slowdown:
       EightNoOps
       EightNoOps
       EightNoOps
       EightNoOps
       dbra d7,slowdown

       jmp again
       rts

;------- USER DATA -------

HelloWorld:
       dc.b 'E','N','D',' ','O','F',' ','P','R','O','G','R','A','M', 0
       even 

;------- USER RAM --------
	ifnd UserRam
UserRam:
	ds $1000                    ; does position $1000 contain the address of user ram?
	endif