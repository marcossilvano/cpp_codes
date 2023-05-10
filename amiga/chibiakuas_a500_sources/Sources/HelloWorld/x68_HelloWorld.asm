
	lea Message,a3
	jsr PrintString			;Show String Message
    
	jsr NewLine				;Move down a line
	
    dc.w $FF00        		;_EXIT - return to OS
	
Message:    dc.b 'Hello World',255
	even	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

PrintChar:
	moveM.l d0-d7/a0-a7,-(sp)
		and #$00FF,d0		;Keep only Low Byte
		move.w d0,-(a7)		;Char to print
		dc.w $FF02        	;_PUTCHAR - Show Character
		addq.l  #2,sp		;Remove pushed word
	moveM.l (sp)+,d0-d7/a0-a7
	rts


PrintString:
	move.b (a3)+,d0			;Read a character in from A3
	cmp.b #255,d0
	beq PrintString_Done	;return on 255
	jsr PrintChar			;Print the Character
	bra PrintString
PrintString_Done:		
	rts
	
NewLine:
	move.b #$0D,d0			;Char 13 CR
	jsr PrintChar
	move.b #$0A,d0			;Char 10 LF
	jsr PrintChar
	rts

	
	