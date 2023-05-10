;------------------------------
; MULTI/DIV/NEG OPERATIONS
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

wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       ;movem.w d0-d4,-(sp) ; push 4 registers
       ;move.b #4,-(sp)     ; push number of registers
       ;jsr fn_clear
       ;movem.w (sp)+,d0-d4 ; get 4 values from stack (function return)

       ; division
       move.l #$34,d0
       mulu.w #$100,d0        ; $34 x $100   = $00003400

       move.l #$3401,d0       ; $3401 / $100 = $00010034
       divu.w #$100,d0        ;                 RRRRQQQQ (remainder + quotient)

       move.l #-$3401,d1      ; -$3401/ $100 = $FFFFFFCC (-1,-34)
       divs.w #$100,d1
       neg.w d1               ; $FFFF0034

       ; multiplication
       move.w #-64,d0
       neg.w d0

       move.w #$34,d1
       mulu.w #$10,d1       ; multiply unsigned

       move.w #-$34,d2
       muls.w #$10,d2       ; multiply signed
       cmp #0,d2            
       blt if_negative     ; 0 > d2
       bge if_positive     ; 0 <= d2
if_positive:
       move.w #$AABB,d3
if_negative:
       neg.w d2
       move.w #$EEFF,d3

       rts

fn_clear:
       move.b (sp)+,d0      ; number of registers to clear
       move.l sp,a0

clear_loop:
       move.w #0,-(a0)
       dbra d0,clear_loop
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