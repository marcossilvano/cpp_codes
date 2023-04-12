;------------------------------
; BOUNCING RASTER LINE
;------------------------------
; Assembly:
;  Ctrl + B

;---------- Const ----------
MOUSE_REG     = $bfe001  ; mouse button state register
MBUTTON_1     = 6        ; bit 6 in MOUSE_REG indicates button 1

VPOS_REG      = $dff006  ; raster vertical position register
BG_COLOR_ADR  = $dff180  ; background color address

;---------- Main -----------

init:
       move #$ac,d7               ; start y position
       move #2,d6                 ; speed y

****************************
main_loop:

wait_vblank:
       cmp.b #$2c,VPOS_REG        ; $2c-start, $ff-end
       bne wait_vblank
       move.w #$000,BG_COLOR_ADR

;-----Game Logic-------
       add d6,d7                  ; modify line position
       
       cmp #$f0,d7                ; bottom check
       blo ok1                    ; branch on less than
       neg d6
ok1:    
       cmp #$40,d7                ; top check
       bhi ok2                    ; branch on hight than
       neg d6
ok2:       

;-----Frame Start------

; waint until we reach the position $ac (middle of screen)
wait_until_raster:
       cmp.b VPOS_REG,d7          ; compare middle of screen pos with the value of RASTER_VPOS_REG
       bne wait_until_raster
       move.w #$fff,BG_COLOR_ADR  ; set background color to white

wait_in_raster:
       cmp.b VPOS_REG,d7
       beq wait_in_raster
       move.w #$126,BG_COLOR_ADR  ; restore background color

;-----Frame End--------

       btst #MBUTTON_1,MOUSE_REG
       bne main_loop
****************************
       rts