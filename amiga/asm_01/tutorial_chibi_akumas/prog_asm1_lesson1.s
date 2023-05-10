;------------------------------
; BASIC ASM 68000
;------------------------------
; Assembly:
;  Ctrl + B
;
; Debug:
;  fs-aue --hard_drive_0=uae/hd0 --console_debugger=1
;
;  F12 + D (ativar debugger)
;  >g (cotinua execução)
;  >z (executa próxima linha)

;---------- Const ----------
MOUSE_REG = $bfe001
MBUTTON_1 = 6

;---------- Main -----------
waitmouse1:
       btst #MBUTTON_1,MOUSE_REG
       bne waitmouse1

       clr.l d0
       move #$1,d0

       lea UserRam+100,a0          ; init array
       move d0,(a0)
count_loop:
       addq #1,d0                  ; add quick (0-7 only)
       
       move.b d0,(a0,d0)           ; store counter d0 into address (a0)

       cmp.b #$7f,d0
       bne count_loop
       rts


;------- USER RAM --------
	ifnd UserRam
UserRam:
	ds $1000                    ; position $1000 contains the address of user ram?
	endif