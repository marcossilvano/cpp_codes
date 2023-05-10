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

wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       ; Rotate             ROL, ROR    (circle bits when moved off the limits)
       ; Rotate with extend ROXL, ROXR
       ; Logical Shift      LSL, LSR    (cut bits when moved off the limits)
       ; Arithmetic Shift   ASL, ASR    (support for negative numbers when shi ftting)

       ; SWAP and EXG
       move.l #$11111111,d0
       move.l #$22222222,d1
       exg d0,d1              ; exchange the values of the registers

       move.l #$12345678,d0
       swap d0                ; swap the low and high words

       ; AND, OR, EOR (XOR), NOT
       clr.l d0
       clr.l d1
       clr.l d2
       clr.l d3
       
       move.b #%10101010,d0
       move.b #%10101010,d1
       move.b #%10101010,d2
       move.b #%10101010,d3

       and.b  #%11110000,d0
       or.b   #%11110000,d1
       eor.b  #%11110000,d2
       not.b  d3

       ; All set ZERO flag
       ; BTST Test a bit
       ; BSET Test and set(1)
       ; BCLR Test and clear(0)
       ; BCHG Test a bit and change(flip)

       move.l #%00000010,d0
       btst #0,d0    ; is zero? yes Z=1 (true)
       btst #1,d0    ; is zero? no  Z=0 (false)

       bset #0,d0    ; 00000011 $3 Z=1
       bset #1,d0    ; 00000011 $3 Z=0
       bset #2,d0    ; 00000111 $7 Z=1

       bclr #0,d0    ; 00000110 $6 Z=0
       bclr #1,d0    ; 00000100 $4 Z=1

       bchg #1,d0    ; 00000110 $6 Z=1
       bchg #2,d0    ; 00000010 $2 Z=0

       ; set each bit of d1
       clr.l d1
       move.l #7,d0
setbit_loop:
       bset d0,d1
       dbra d0,setbit_loop

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