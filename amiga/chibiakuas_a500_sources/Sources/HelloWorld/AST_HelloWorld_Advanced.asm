
	include "\SrcALL\BasicMacros.asm" ;Needed for Monitor
	
	SECTION TEXT		;CODE Section
	
	lea Message,a3
	jsr PrintString		;Show String Message
    
	jsr NewLine			;Move down a line
    	
	jsr Monitor			;Show Registers

	jsr Monitor_MemDump	;Dump 6 lines from  $00010000
	dc.l $00010000
	dc.w $6
		
	;Wait for a key before returning
	move.w #1,-(sp) 	;$01 - ConIn	
	trap #1				;Call GemDos
	addq.l #2,sp		;Remove 1 word from stack	
	
 	clr.w -(sp)
	trap #1					;Return to OS
	
PrintChar:
	moveM.l d0-d7/a0-a7,-(sp)
		and.l #$00FF,d0	;Keep only Low Byte
		move.w d0,-(sp) ;Char (W) to show to screen
		move.w #2,-(sp) ;$02 - ConOut (c_conout)
		trap #1			;Call GemDos
		addq.l #4,sp	;Remove 2 words from stack
	moveM.l (sp)+,d0-d7/a0-a7
	rts
	
Message:    dc.b 'Hello World',255
	even

NewLine:
	move.b #$0D,d0		;Char 13 CR
	jsr PrintChar
	move.b #$0A,d0		;Char 10 LF
	jsr PrintChar
	rts

PrintString:
		move.b (a3)+,d0		;Read a character in from A3
		cmp.b #255,d0
		beq PrintString_Done;return on 255
		jsr PrintChar		;Print the Character
		bra PrintString
PrintString_Done:		
	rts
	

	include "\SrcALL\Multiplatform_Monitor.asm"
	