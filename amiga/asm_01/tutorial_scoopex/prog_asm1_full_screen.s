;------------------------------
; BOUNCING RASTER LINE
; FULL SCREEN BG
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

COPPER_LIST = $dff080

;---------- Main -----------

init:
;------Loading Libraries------
       move.l 4.w,a6               ; move execbase lib address to a6 address register
                                   ; move the content (word) of the address 4 into a6
       clr.l d0                    ; clear version number
       move.l #gfxname,a1
       jsr -408(a6)                ; call oldopenlibrary() (jump to subroutine)
                                   ; -408(a6) => -408 is the offset to base pointer a6
       move.l d0,a1                ; register d0 contains the data returned from function
       move.l 38(a1),d4            ; use a1 as a pointer and save function return into d4
                                   ; 38(a1) => original copper ptr / 50(a1) => second copper list
       jsr -414(a6)                ; call closelibrary() function

;------Init Data--------------
       move #$ac,d7                ; start y position
       move #2,d6                  ; speed y

       move INTS_READ,d5           ; save interrupts control reg in d5 data reg / read only
       move #$7fff,INTS_WRITE      ; disable interrupts control (lower 15 bits) in INTNENA / write only

       move.l #copper,COPPER_LIST  ; set our own copper list, after disabling interrupts (system may interfer if ints are enabled)
                                   ; must restore it when finished
                                   ; The copper controls how things are drawn into the screen
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
       move.w #$000,BG_COLOR_ADR   ; restore background color $126

;-----Frame End--------

       btst #MBUTTON_1,MOUSE_REG
       bne main_loop
****************************
exit:
       move.l d4,COPPER_LIST       ; restore system's copper list
       
       ;bset #14,d5                ; 1 to bit turn on interrupts and 1 bit to switch all others to on (master switch)
       ;bset #15,d5                
       or #$c000,d5                ; turn on interrupts (bits 14 and 15 $c=1100)
       move d5,INTS_WRITE          ; restoure value back to interrupts controll register (turn on interrupts) / write only
       rts

gfxname:
       dc.b "graphics.library",0   ; NULL terminated string (ASCII zero notation)

;-----Copper List------            ; sets how the screen is going to be drawn
       SECTION tut,DATA_C          ; tell the assembler to put this piece of data in NOT fast memory
copper:
       dc.w $100,$0200             ; set number of bitplanes to zero (bitplane control register)
       dc.w $ffff,$fffe            ; wait for scan line (at "impossible" position $ffff)
                                   ; bit mask: $fff + e=1110
