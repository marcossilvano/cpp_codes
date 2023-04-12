;------------------------------
; Assembly:
;  Ctrl + B

;---------- Const ----------
MOUSE_REG     = $bfe001  ; mouse button state register
MBUTTON_1     = 6        ; bit 6 in MOUSE_REG indicates button 1

VPOS_REG      = $dff006  ; raster vertical position register
BG_COLOR_ADR  = $dff180  ; background color address

;---------- Main -----------

main_loop:

wait_vblank_loop:
       cmp.b #$ff,VPOS_REG
       bne wait_vblank_loop

; waint until we reach the position $ac (middle of screen)
wait_raster1_loop:
       cmp.b #$ac,VPOS_REG   ; compare middle of screen pos with the value of RASTER_VPOS_REG
       bne wait_raster1_loop
       move.w #$fff,BG_COLOR_ADR  ; set background color to white

wait_raster2_loop:
       cmp.b #$ac,VPOS_REG
       beq wait_raster2_loop
       move.w #$126,BG_COLOR_ADR  ; restore background color

       btst #MBUTTON_1,MOUSE_REG
       bne main_loop
       rts