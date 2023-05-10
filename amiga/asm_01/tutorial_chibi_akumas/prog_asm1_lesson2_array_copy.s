;------------------------------
; COPY ARRAY OF DATA
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

;---------- Main -----------
wait_mouse:
       btst #MBUTTON_1,MOUSE_REG
       bne wait_mouse

       clr.l d0
       lea TestData,a0             ; a0 points to TestData (source)

       lea UserRam+100,a1          ; a1 points to UseRam+100 (destination)
       move #31,d0                 ; TestData size (decrement counter)
       
       ; testing access to a0 pointer address
       move.l a0,d1                ; testing: copy a0 original address into d1
       move.l (16,a0),d2           ; testing: load 4 bytes from a0+16 (second line of TestData)

       move.l HelloWorld,a2           ; testing: just to load the effective address of HelloWorld

array_copy:
       move.b (a0)+,(a1)+          ; access and increase address by one byte (move.b)
       dbra d0,array_copy

       rts


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