;------------------------------
; BOUNCING RASTER LINE
; FULL SCREEN BG
;------------------------------
; Assembly:
;  Ctrl + B

;---------- Main -----------
       ;CMP D0,D1  	Signed Unsigned
       ;D0 >  D1	BLT	BCS BLO
       ;D0 >= D1	BLE	BLS
       ;D0 == D1	BEQ	BEQ
       ;D0 != D1	BNE	BNE
       ;D0 <  D1	BGT	BHI
       ;D0 <= D1	BGE	BCC BHS

;---------- Includes ----------
              INCDIR      "include"
              INCLUDE     "hw.i"
              INCLUDE     "funcdef.i"
              INCLUDE     "exec/exec_lib.i"
              INCLUDE     "graphics/graphics_lib.i"
              INCLUDE     "hardware/cia.i"

;---------- Const ----------
MOUSE_REG     = $bfe001  ; mouse button state register
MBUTTON_1     = 6        ; bit 6 in MOUSE_REG indicates button 1

VPOS_REG      = $dff006  ; raster vertical position register
BG_COLOR_ADR  = $dff180  ; background color address

INTS_WRITE = $dff09a
INTS_READ  = $dff01c

COPPER_ADR = $dff080

COL_WHITE  = $fff
COL_BLACK  = $000

;---------- Main -----------

init:
;------Loading Libraries------
       move.l 4.w,a6                      ; move 2 bytes (word) of execbase lib address to a6
       clr.l  d0                          ; make shure there will be no garbage in d0
       move.l #gfxname,a1                 ; OldOpenLibrary(libName)(a1) -> d0 (lib address)
       
       jsr    _LVOOldOpenLibrary(a6)      ; jsr (-408,a6)
       move.l d0,a1                       ; return: d0 -> graphics lib address
       move.l (38,a1),d4                  ; 38(a1) => copper list ptr / 50(a1) => second copper list ptr
       
       jsr    _LVOCloseLibrary(a6)        ; jsr (-414,a6)

;------Init Data--------------
       move   #$ac,d7                     ; start y position
       move   #2,d6                       ; speed y

       move   INTS_READ,d5                ; Interrupt enable bits read -> d5 (save interrupts state)
       move   #$7fff,INTS_WRITE           ; disable interrupts control (lower 15 bits) / clear or set bits

       move.l #copper_list,COPPER_ADR     ; set our own copper list, after disabling interrupts (system may interfer if ints are enabled)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main_loop:

wait_vblank:
       btst   #0,$dff005             
       bne    wait_vblank          ; 1 byte in $dff006 + 1 bit in $dff005

       cmp.b  #$2c,$dff006         ; $2c-screen start, $ff-screen end
       bne    wait_vblank
       
       move.w #$000,BG_COLOR_ADR   ; sets BLACK for background color

;-----Game Logic-------
       add    d6,d7                ; modify line position
       
       cmp    #$fe,d7              ; bottom check ($139 for full bottom - 9bits) old: $f0
       blo    not_at_bottom        ; branch when $fe > d7 (branch on less than)
       neg    d6                   ; reverse speed_y
not_at_bottom:    
       cmp    #$30,d7              ; top check ($0 for full top - 9bits) old: $40
       bhi    not_at_top           ; branch when $30 < d7 (branch on hight than)
       neg    d6
not_at_top:       

;-----Frame Start------

; waint until we reach the position $ac (middle of screen)
wait_until_raster:
       cmp.b  VPOS_REG,d7          ; compare middle of screen pos with the value of RASTER_VPOS_REG
       bne    wait_until_raster
       move.w #$fff,BG_COLOR_ADR   ; set background color to white

wait_in_raster:
       cmp.b  VPOS_REG,d7
       beq    wait_in_raster
       move.w #$000,BG_COLOR_ADR   ; restore background color $126

;-----Frame End--------

       btst   #MBUTTON_1,MOUSE_REG
       bne    main_loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

exit:
       move.l d4,COPPER_ADR        ; restore system's copper list
       
       ;bset #14,d5                ; 1 to bit turn on interrupts and 1 bit to switch all others to on (master switch)
       ;bset #15,d5                
       or     #$c000,d5            ; turn on interrupts (bits 14 and 15 $c=1100)
       move   d5,INTS_WRITE        ; restoure value back to interrupts controll register (turn on interrupts) / write only
       rts

gfxname:
       dc.b   "graphics.library",0 ; NULL terminated string (ASCII zero notation)

;-----Copper List------            ; sets how the screen is going to be drawn
       SECTION tut,DATA_C          ; tell the assembler to put this piece of data in NOT fast memory
copper_list:
       dc.w   $100,$0200           ; set number of bitplanes to zero (bitplane control register)
       dc.w   $ffff,$fffe          ; wait for scan line (at "impossible" position $ffff)
                                   ; bit mask: $fff + e=1110