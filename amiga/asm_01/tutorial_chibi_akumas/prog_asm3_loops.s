;------------------------------
; LOOPS & SWITCH
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

       jmp SwitchCaseLoop          ; skip first part of program

;--------- For-Loop ---------
       lea UserRam,a0
       lea HelloWorld,a1
       move.l a0,a2

       move.l #$FFFFFFFF,d0
       move.w #7,d0                ; d0=$FFFF0005
CopyStr:
       ; for-loop
       move.w (a1)+,(a2)+
       dbra d0,CopyStr             ; while d0 > 0, d0--, loop

;------- Switch-Case -------
SwitchCaseLoop
       move.l #4,d1
CaseAgain:
       cmp.l #3,d1
       beq Case3
       cmp.l #2,d1
       beq Case2
       cmp.l #1,d1
       beq Case1
       cmp.l #0,d1
       beq Case0
CaseDone:
       subq.l #1,d1
       jmp CaseAgain
Case3:
       move.l #$C,d0
       jmp CaseDone
Case2:
       move.l #$CB,d0
       jmp CaseDone
Case1:
       move.l #$CBA,d0
       jmp CaseDone
Case0:
       rts

HelloWorld:
       dc.b 'E','N','D',' ','O','F',' ','P','R','O','G','R','A','M'
       even 

;------- USER RAM --------
	ifnd UserRam
UserRam:
	ds $1000                    ; does position $1000 contain the address of user ram?
	endif