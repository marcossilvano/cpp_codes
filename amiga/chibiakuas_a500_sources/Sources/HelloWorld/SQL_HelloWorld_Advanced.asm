	include "\SrcALL\BasicMacros.asm"
	

	lea Message,a3
	jsr PrintString			;Show String Message
    
	jsr NewLine				;Move down a line
    
	jsr Monitor				;Show Registers

	jsr Monitor_MemDump		;Dump 6 lines from  $00000000
	dc.l $00008000
	dc.w $6
	
	clr.l d0	;Zero D0 before return to stop basic whining
	rts
	
Message:    dc.b 'Hello World',255
	even		;68000 needs commands to be even aligned
	
NewLine:
	move.b #$0A,d0				;Char 10 LF
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
	

printchar:
	moveM.l d0-d7/a0-a7,-(sp)
		move.l d0,d1			;Move Character into D1
		and #$00FF,d0			;Keep only Low Byte
		move.l #$00010001,A0	;Console ChannelID (internal QDOS code)
		
		moveq.l #-1,D3			;Timeout
		moveq.l #5,D0			;IO.SBYTE	Send a byte
		trap #3					;IO TRAP
	moveM.l (sp)+,d0-d7/a0-a7
	rts



	include "\SrcALL\Multiplatform_Monitor.asm"
    	
