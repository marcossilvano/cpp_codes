;------------------------------
; STACK and SUBROUTINES
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
       ;D1 <  D0	BLT	BCS
       ;D1 <= D0	BLE	BLS
       ;D1 =  D0	BEQ	BEQ
       ;D1 <> D0	BNE	BNE
       ;D1 >  D0	BGT	BHI
       ;D1 >= D0	BGE	BCC

wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       ; stack pointers: SP/A7

       ; pushing bytes into stack: -(sp) pre-increment
       move.w #$1234,-(sp)         ; push 2 bytes (sp is decremented by 2 bytes)
       move.l #$12345678,-(sp)     ; push 4 bytos (sp is decremented by 4 bytes)
       move.b #$12,-(sp)           ; push 1 byte  (sp is decremented by 2 bytes) **cannot address odd bytes**
       
       ; popping bytes from stack: (sp)+ post-increment
       move.b (sp)+,d0
       move.l (sp)+,d1
       move.w (sp)+,d2

       ;jsr sub1

       move.l #$ABCDEF,d2

       ; using move.m
       jsr resetRegs
       move.w #$1000,d4
       move.w #$2000,d5
       move.w #$3000,d6
       movem.w d4-d6,-(sp)          ; push 3 registers into stack

       jsr resetRegs
       movem.w (sp)+,d4-d6          ; pop 3 registers from stack

       movem.w d4/d6,-(sp)
       
       jsr resetRegs
       movem.w (sp)+,d4/d6

       rts

resetRegs:
       clr.l d4
       clr.l d5
       clr.l d6
       rts

sub1:
       move.l #$ABC,d0
       jsr sub2
       rts

sub2:
       move.l #$DEF,d1
       
       ;lea sub3,a1                ; manually push address of sub3 into stack
       ;move.l a1,-(sp)
       ;jmp sub3

       pea sub3                    ; manually push address of sub3 into stack

       rts 

sub3:
       move.l #$12121212,d3
       rts

;------- USER DATA -------

HelloWorld:
       dc.b 'E','N','D',' ','O','F',' ','P','R','O','G','R','A','M'
       even 

;------- USER RAM --------
	ifnd UserRam
UserRam:
	ds $1000                    ; does position $1000 contain the address of user ram?
	endif