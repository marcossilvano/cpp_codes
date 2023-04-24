;------------------------------
; WAIT MOUSE CLICK
;------------------------------
; Assembly:
;  Ctrl + B

;---------- Const ----------
MOUSE_REG = $bfe001
MBUTTON_1 = 6

;---------- Main -----------
waitmouse_loop:
       btst #MBUTTON_1,MOUSE_REG
       bne waitmouse_loop
       rts