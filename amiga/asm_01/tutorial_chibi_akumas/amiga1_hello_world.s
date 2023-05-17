
       ; Bcc Commands
       *******************************
       ;CMP D0,D1  	Signed Unsigned
       ;D0 >  D1	BLT	BCS
       ;D0 >= D1	BLE	BLS
       ;D0 == D1	BEQ	BEQ
       ;D0 != D1	BNE	BNE
       ;D0 <  D1	BGT	BHI
       ;D0 <= D1	BGE	BCC

**************************************************
* INCLUDES
**************************************************

       INCDIR      "include"
       INCLUDE     "hw.i"
       INCLUDE     "funcdef.i"
       INCLUDE     "exec/exec_lib.i"
       INCLUDE     "graphics/graphics_lib.i"
       INCLUDE     "hardware/cia.i"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Console INIT
		
	;SECTION TEXT		;CODE Section

;waitmouse:
;       btst   #6,$bfe001
;       bne    waitmouse     ; if bit 6 is 1 (Z=0)

	move.l	4.w,a6		       ;Load base for call from addr $4
	clr.l  d0		       ;Version

	move.l #gfxname,a1 		;'dos.library' defined in chip ram
       jsr	(-408,a6)		;Exec - OldOpenlibrary(library)(a1) - return DosBase in D0
;	move.l d0,(DosHandle)       ;Save DOS Base to handle name

;	move.l d0,a6		       ;Dos base
;	move.l #consolename,d1      ;'CONSOLE:'
;	move.l #1005,d2		;ModeOld
;	jsr	(-30,a6)		;Dos: Open (D0=Console Handle)

;	move.l d0,(ConsoleHandle)	;Save Console Handle

	;move.l	4.w,a6		       ;Load base for call from addr $4
       jsr    (-414,a6)            ;Exec - CloseLibrary(library)(a1)
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Program Starts here
	
	move.l #Message,a3
	;jsr PrintString		;Show String Message

	;jsr NewLine			;Start a new line	
	
       rts					;Return to OS
	;jmp *				;Halt Program
	
Message:    dc.b "Hello World",255
	even

PrintChar:
	moveM.l d0-d3/a0,-(sp)
		move.b d0,(CharBuffer)		;Save character into buffer
		
		move.l (DosHandle),a0		;Dos Handle
		move.l (ConsoleHandle),d1	;Console handle
		move.l #CharBuffer,d2		;Dosbase in a6
		move.l #1,d3				;buffer length (1 byte)
		jsr	(-48,a0)				;Call "Dos: Write"
		
	moveM.l (sp)+,d0-d3/a0
	rts
	


PrintString:
	move.b (a3)+,d0		;Read a character in from A3
	cmp.b #255,d0
	beq PrintString_Done;return on 255
	jsr PrintChar		;Print the Character
	bra PrintString
PrintString_Done:		
	rts

NewLine:
	move.b #$0D,d0		;Char 13 CR
	jsr PrintChar
	move.b #$0A,d0		;Char 10 LF
	jsr PrintChar
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
dosname: 		
       dc.b "dos.library",0	;Library name
gfxname:
       dc.b "graphics.library",0
consolename:  	
       dc.b  "CONSOLE:",0		;Console handle
	even

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;Chip Ram
		
	Section ChipRAM,DATA_C	;Request 'Chip Ram' area memory 

DosHandle: 		dc.l 0			;Dos Handle
ConsoleHandle: 	dc.l 0			;Console Handle
CharBuffer: 	dc.b 0			;Character we want to print