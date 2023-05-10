;------------------------------
; CONDITIONS
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
wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       move.l #$10101000,d0

       jsr AddTwo

       lea A2Test,a1
       move.w (a1),d3

       move.w #Symboltest,d4       ; using symbol

;---------- CMP ------------
       ;CMP D0,D1  	Signed Unsigned
       ;D1 <  D0	BLT	BCS
       ;D1 <= D0	BLE	BLS
       ;D1 =  D0	BEQ	BEQ
       ;D1 <> D0	BNE	BNE
       ;D1 >  D0	BGT	BHI
       ;D1 >= D0	BGE	BCC

       clr.l d0
       clr.l d1
       move.b #3,d0
       move.b #2,d1
       ;     #2<#3 -> bhs
       cmp.b d1,d0
       blo IsLower                 ; d0 <  d1? (d0-d1) Branch Carry Set   BCS
       bhs IsHigherOrEqual         ; d0 >= d1? (d0-d1) Branch Carry Clear BCC

IsLower:
       move.b #$A0,d0
       jmp EndOfProgram

IsHigherOrEqual:
       move.b #$F0,d0

       jmp EndOfProgram
       move.l #$9ABCDEF0,d1

EndOfProgram:
       move.l #$12344321,d2
       rts

AddTwo:
       addq #2,d0
       rts

A2Test:
       dc.b $32,$23  ; 2 bytes

;------- DATA ------------
TestData:
	dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F ; 16 bytes
	dc.b $F0,$F1,$F2,$F3,$F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB,$FC,$FD,$FE,$FF ; 16 bytes
       ; even << if data is not 16bit aligned, wev need to use 'even' command to fill the data

HelloWorld:
       dc.b 'H','E','L','L','O'
       even 

;------- USER RAM --------
	ifnd UserRam
UserRam:
	ds $1000                    ; does position $1000 contain the address of user ram?
	endif