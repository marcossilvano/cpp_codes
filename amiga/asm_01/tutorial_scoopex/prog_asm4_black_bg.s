;------------------------------
; BOUNCING RASTER LINE
; WITH BLACK BACKGROUND
;------------------------------
; Assembly:
;  Ctrl + B

;---------- Const ----------
MOUSE_REG     = $bfe001  ; mouse button state register
MBUTTON_1     = 6        ; bit 6 in MOUSE_REG indicates button 1

VPOS_REG      = $dff006  ; raster vertical position register
BG_COLOR_ADR  = $dff180  ; background color address

INTS_WRITE = $dff09a
INTS_READ  = $dff01c

;---------- Main -----------

init:
       move #$ac,d7                ; start y position
       move #2,d6                  ; speed y

       move INTS_READ,d5          ; save interrupts control reg in d5 data reg / read only
       move #$7fff,INTS_WRITE     ; disable interrupts control (lower 15 bits) in INTNENA / write only

****************************
main_loop:

wait_vblank:
       btst #0,$dff005             ; most significant bit of $dff005 is the 9th bit of raster position
       bne wait_vblank             ; 1 byte in $dff006 + 1 bit in $dff005

       cmp.b #$2c,$dff006          ; $2c-start, $ff-end
       bne wait_vblank
       
       move.w #$000,BG_COLOR_ADR   ; sets BLACK for background color

;-----Game Logic-------
       add d6,d7                   ; modify line position
       
       cmp #$fe,d7                 ; bottom check ($139 for full bottom - 9bits) $f0
       blo ok1                     ; branch on less than
       neg d6
ok1:    
       cmp #$30,d7                 ; top check ($0 for full top - 9bits) $40
       bhi ok2                     ; branch on hight than
       neg d6
ok2:       

;-----Frame Start------

; waint until we reach the position $ac (middle of screen)
wait_until_raster:
       cmp.b VPOS_REG,d7           ; compare middle of screen pos with the value of RASTER_VPOS_REG
       bne wait_until_raster
       move.w #$fff,BG_COLOR_ADR   ; set background color to white

wait_in_raster:
       cmp.b VPOS_REG,d7
       beq wait_in_raster
       move.w #$126,BG_COLOR_ADR   ; restore background color

;-----Frame End--------

       btst #MBUTTON_1,MOUSE_REG
       bne main_loop
****************************
exit:
       ;bset #14,d5                ; 1 to bit turn on interrupts and 1 bit to switch all others to on (master switch)
       ;bset #15,d5
       or #$c000,d5                ; turn-on bits 14 and 15
       move d5,INTS_WRITE          ; restoure value back to interrupts controll register (turn on interrupts) / write only
       rts