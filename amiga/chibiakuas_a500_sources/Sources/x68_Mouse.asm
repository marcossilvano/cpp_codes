
	include "\SrcALL\BasicMacros.asm"	;Needed by Monitor Tools

	;Press F12 to capture mouse in the emulator!
	
	move.l #$70,d0			;Init
	Trap #15
	
	move.l #$71,d0			;Cursor On
	Trap #15
	
	move.l #$72,d0			;Cursor Off
	;Trap #15
	
	move.l #$00400040,d1	;$XXXXYYYY	Min
	move.l #$03FF01FF,d2	;$XXXXYYYY	Max
	move.l #$77,d0			;Cursor Range
	Trap #15
	
	move.l #$00000000,d1	;$XXXXYYYY
	move.l #$76,d0			;Cursor pos
	Trap #15
	
	move.l #$7d,d0			;Soft Keyboard
	move.l #0,d1			;OFF!
	Trap #15
	
Again: 	
;Reset text cursor pos to top of screen
	move.w #0,d2			;Y 
	move.w d2,-(sp)
	move.w #0,d2			;X
	move.w d2,-(sp)
	move.w #3,d2			;Set Cursor Pos (Locate)
	move.w d2,-(sp)
	dc.w $ff23				;Move text cursor
	add #6,sp
	
;Read the mouse	

	move.l #$74,d0			;Get Buttons and move amount 
	Trap #15					;D0=$XXYYLLRR
	
	move.l d0,-(sp)
		move.l #$75,d0		;Cursor Pos
		Trap #15				; D0=$XXXXYYYY	
	move.l (sp)+,d1
	
;Show the results
	jsr Monitor				;Show Registers
	
	jmp Again
	
    dc.w $FF00        		;_EXIT - return to OS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
Message:    dc.b 'Hello World',255
	even	

PrintChar:
	moveM.l d0-d7/a0-a7,-(sp)
		and #$00FF,d0		;Keep only Low Byte
		move.w d0,-(a7)		;Char to print
		dc.w $FF02        	;_PUTCHAR - Show Character
		addq.l  #2,sp		;Remove pushed word
	moveM.l (sp)+,d0-d7/a0-a7
	rts

NewLine:
	move.b #$0D,d0			;Char 13 CR
	jsr PrintChar
	move.b #$0A,d0			;Char 10 LF
	jsr PrintChar
	rts

PrintString:
	move.b (a3)+,d0			;Read a character in from A3
	cmp.b #255,d0
	beq PrintString_Done	;return on 255
	jsr PrintChar			;Print the Character
	bra PrintString
PrintString_Done:		
	rts
	
	include "\SrcALL\Multiplatform_Monitor.asm"
	