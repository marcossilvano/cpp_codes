

VecTitleWall:
    dc.b %00000100,%01100000		
    dc.b %00000010,%10001111		
    dc.b %01111101,%10000100
    dc.b %01101111,%10000000
    dc.b %01111110,%11101101
    dc.b %00010011,%00010010
    dc.b %01111110,%11101110
    dc.b %00000010,%00100001
    dc.b %00000101,%10000000
    dc.b %01111101,%10000100
    dc.b %00000011,%10011010
    dc.b %01111101,%01100110
    dc.b %01111101,%10000000
    dc.b %01110101,%00010011
    dc.b %10000001,%10000111



VecTitleZoom:
	;   CYYYYYYY, DXXXXXXX  CD=Command 
    dc.b %00000100,%01110110	;Move Command
    dc.b %01111100,%10010001	; Line Command
    dc.b %01111100,%01101101	;Move Command
    dc.b %01111101,%10001100	; LINE Command
    dc.b %01111010,%01110100	;Move Command
    dc.b %11111010,%10010001	; Line Command + End


VecTitleChibi:
;Body
    dc.b %01110100,%00000001
    dc.b %01111100,%10000010
    dc.b %01111101,%10000011
    dc.b %01111111,%10000101
    dc.b %00000000,%10000100
    dc.b %00000010,%10000011
    dc.b %00000011,%10000010
    dc.b %00000100,%10000010
    dc.b %00000010,%10000000
    dc.b %00000100,%11111111
    dc.b %00000100,%11111101
    dc.b %00000001,%01111110
    dc.b %00000001,%11111101
    dc.b %00000000,%11111011
    dc.b %01111110,%11111101
    dc.b %01111110,%11111110
    dc.b %01111101,%11111110
    dc.b %11111100,%11111111

VecTitleChibiHands:
;hands
    dc.b %01110110,%00000011
    dc.b %00000000,%11111011
    dc.b %00000000,%10000001
    dc.b %00000011,%11111101
    dc.b %01111111,%11111110
    dc.b %01111110,%10000010
    dc.b %00000000,%11111101
    dc.b %01111110,%10000000
    dc.b %00000001,%10000100
    dc.b %01111101,%11111101
    dc.b %00000000,%10000010
    dc.b %00000011,%10000010
    dc.b %01111100,%10000000
    dc.b %00000000,%10000001
    dc.b %00000011,%10000001
    dc.b %00000001,%10000100
    dc.b %00001010,%00001101
    dc.b %00000001,%10000001
    dc.b %00000001,%11111110
    dc.b %00000010,%10000000
    dc.b %01111111,%10000010
    dc.b %00000010,%10000000
    dc.b %00000001,%10000001
    dc.b %01111101,%10000000
    dc.b %00000010,%10000001
    dc.b %01111111,%10000001
    dc.b %01111110,%11111111
    dc.b %00000001,%10000010
    dc.b %01111110,%10000000
    dc.b %01111111,%11111101
    dc.b %11111111,%11111111

VecTitleChibiEyes:
    dc.b %01111010,%00000101
    dc.b %00000001,%10000010
    dc.b %00000000,%10000010
    dc.b %01111111,%10000001
    dc.b %01111111,%10000001
    dc.b %01111110,%10000000
    dc.b %01111110,%11111111
    dc.b %01111111,%11111110
    dc.b %00000010,%11111101
    dc.b %00000100,%10000000
    dc.b %01111111,%00001000
    dc.b %00000010,%10000001
    dc.b %00000000,%10000011
    dc.b %01111111,%10000010
    dc.b %01111101,%10000000
    dc.b %01111110,%11111110
    dc.b %00000000,%11111110
    dc.b %00000010,%11111110
    dc.b %00000010,%10000000
    dc.b %00000001,%00000100
    dc.b %00000000,%11111111
    dc.b %01111111,%11111111
    dc.b %01111111,%10000001
    dc.b %00000000,%10000001
    dc.b %00000001,%10000001
    dc.b %00000001,%11111111
    dc.b %01111110,%01110111
    dc.b %01111111,%11111111
    dc.b %01111111,%10000000
    dc.b %01111111,%10000001
    dc.b %00000001,%10000001
    dc.b %00000001,%10000000
    dc.b %10000001,%11111111


VecTitleChibiMouth:
    dc.b %01110010,%00000111
    dc.b %00000001,%11111111
    dc.b %01111111,%10000000
    dc.b %01111101,%10000010
    dc.b %01111110,%10000100
    dc.b %00000001,%10000010
    dc.b %00000011,%00000100
    dc.b %00000001,%10000000
    dc.b %00000010,%10000001
    dc.b %11111110,%11111011


VecTitleChibiToung:
    dc.b %01110010,%00001000
    dc.b %00000000,%10000001
    dc.b %00000001,%10000100
    dc.b %01111111,%10000011
    dc.b %01111110,%10000010
    dc.b %01111110,%11111111
    dc.b %00000001,%11111101
    dc.b %00000010,%11111111
    dc.b %00000000,%11111110
    dc.b %01111110,%11111110
    dc.b %00000011,%00000100
    dc.b %01111111,%10000010
    dc.b %11111111,%10000001



VecBall:
    dc.b $00,$EB,$02
    dc.b $FF,$04,$01
    dc.b $FF,$04,$01
    dc.b $FF,$05,$04
    dc.b $FF,$05,$04
    dc.b $FF,$03,$07
    dc.b $FF,$00,$0A
    dc.b $FF,$FE,$05
    dc.b $FF,$FC,$05
    dc.b $FF,$FB,$04
    dc.b $FF,$FA,$02
    dc.b $FF,$FA,$00
    dc.b $FF,$FA,$FF
    dc.b $FF,$F9,$FC
    dc.b $FF,$FC,$FA
    dc.b $FF,$FE,$F9
    dc.b $FF,$00,$FB
    dc.b $FF,$02,$FA
    dc.b $FF,$03,$FA
    dc.b $FF,$07,$FB
    dc.b $FF,$05,$FE
    dc.b $01



VecHands:
    dc.b $00,$EB,$06
    dc.b $FF,$00,$F8
    dc.b $FF,$04,$FC
    dc.b $FF,$01,$FD
    dc.b $FF,$FF,$00
    dc.b $FF,$FC,$03
    dc.b $FF,$FF,$FA
    dc.b $FF,$FE,$FE
    dc.b $FF,$FF,$08
    dc.b $FF,$FD,$FB
    dc.b $FF,$FE,$02
    dc.b $FF,$04,$04
    dc.b $FF,$FB,$02
    dc.b $FF,$00,$02
    dc.b $FF,$05,$00
    dc.b $FF,$02,$09
    dc.b $00,$16,$1C
    dc.b $FF,$02,$02
    dc.b $FF,$02,$FC
    dc.b $FF,$03,$00
    dc.b $FF,$FD,$05
    dc.b $FF,$05,$FF
    dc.b $FF,$00,$02
    dc.b $FF,$FD,$01
    dc.b $FF,$03,$01
    dc.b $FF,$FF,$02
    dc.b $FF,$FC,$FE
    dc.b $FF,$02,$03
    dc.b $FF,$FC,$01
    dc.b $FF,$FF,$FB
    dc.b $FF,$FD,$FC
    dc.b $01


VecEyes:
    dc.b $00,$F6,$12
    dc.b $FF,$00,$FC
    dc.b $FF,$FD,$FC
    dc.b $FF,$FA,$00
    dc.b $FF,$FC,$05
    dc.b $FF,$01,$04
    dc.b $FF,$02,$02
    dc.b $FF,$03,$02
    dc.b $FF,$05,$FE
    dc.b $FF,$02,$FD
    dc.b $00,$FA,$FF
    dc.b $FF,$FF,$FD
    dc.b $FF,$FE,$00
    dc.b $FF,$FE,$02
    dc.b $FF,$02,$03
    dc.b $FF,$03,$FE
    dc.b $00,$06,$11
    dc.b $FF,$00,$FE
    dc.b $FF,$FD,$FC
    dc.b $FF,$FC,$FF
    dc.b $FF,$FC,$02
    dc.b $FF,$FE,$05
    dc.b $FF,$02,$05
    dc.b $FF,$05,$01
    dc.b $FF,$04,$FE
    dc.b $FF,$02,$FC
    dc.b $00,$FE,$01
    dc.b $FF,$FE,$FD
    dc.b $FF,$FE,$02
    dc.b $FF,$01,$03
    dc.b $FF,$03,$FE
    dc.b $01

VecMouth:
	;   CC  YY  XX  	CC=Command  YY=Ypos  XX=Xpos
    dc.b $00,$E5,$0D		;Move
    dc.b $FF,$FE,$04		; Line
    dc.b $FF,$00,$07		; Line
    dc.b $00,$02,$08		;Move
    dc.b $FF,$03,$08		; Line
    dc.b $FF,$FA,$FC		; Line
    dc.b $00,$FB,$F9		;Move
    dc.b $FF,$FE,$FA		; Line
    dc.b $FF,$01,$FB		; Line
    dc.b $FF,$0A,$FA		; Line
    dc.b $01				;  End


VecToung:
    dc.b $00,$E3,$12
    dc.b $FF,$FE,$02
    dc.b $FF,$03,$08
    dc.b $FF,$00,$03
    dc.b $FF,$FD,$05
    dc.b $FF,$FD,$02
    dc.b $FF,$FE,$FF
    dc.b $FF,$FE,$FD
    dc.b $FF,$03,$FC
    dc.b $FF,$03,$FE
    dc.b $FF,$00,$FC
    dc.b $FF,$FC,$FD
    dc.b $00,$06,$06
    dc.b $FF,$FE,$05
    dc.b $FF,$FD,$02
    dc.b $01


VecTitleF:
    dc.b $00,$2A,$C5
    dc.b $FF,$00,$0E
    dc.b $FF,$FD,$00
    dc.b $FF,$00,$02
    dc.b $FF,$FC,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$FD,$00
    dc.b $FF,$00,$F9
    dc.b $FF,$FB,$00
    dc.b $FF,$00,$02
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$F7
    dc.b $FF,$02,$00
    dc.b $FF,$00,$02
    dc.b $FF,$0C,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$03,$00
    dc.b $00,$FE,$06
    dc.b $FF,$00,$06
    dc.b $FF,$FB,$00
    dc.b $FF,$00,$FA
    dc.b $FF,$05,$00
    dc.b $00,$02,$0D
    dc.b $FF,$EF,$00
    dc.b $FF,$00,$05
    dc.b $FF,$07,$00
    dc.b $FF,$00,$05
    dc.b $FF,$F9,$00
    dc.b $FF,$00,$05
    dc.b $FF,$11,$00
    dc.b $FF,$00,$FB
    dc.b $FF,$F9,$00
    dc.b $FF,$00,$FB
    dc.b $FF,$07,$00
    dc.b $FF,$00,$FB
    dc.b $00,$00,$19
    dc.b $FF,$00,$07
    dc.b $FF,$FA,$05
    dc.b $FF,$FA,$00
    dc.b $FF,$FB,$FB
    dc.b $FF,$00,$FA
    dc.b $FF,$00,$FF
    dc.b $FF,$05,$FC
    dc.b $FF,$07,$00
    dc.b $FF,$05,$04
    dc.b $00,$FD,$02
    dc.b $FF,$00,$03
    dc.b $FF,$FE,$02
    dc.b $FF,$F9,$00
    dc.b $FF,$FD,$FE
    dc.b $FF,$00,$FD
    dc.b $FF,$03,$FE
    dc.b $FF,$07,$00
    dc.b $FF,$02,$02
    dc.b $00,$03,$0E
    dc.b $FF,$00,$0F
    dc.b $FF,$FB,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$02,$00
    dc.b $FF,$00,$FD
    dc.b $FF,$F4,$00
    dc.b $FF,$00,$02
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$F8
    dc.b $FF,$00,$FF
    dc.b $FF,$02,$00
    dc.b $FF,$00,$02
    dc.b $FF,$0C,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FD
    dc.b $FF,$05,$00
    dc.b $00,$FB,$14
    dc.b $FF,$05,$06
    dc.b $FF,$00,$06
    dc.b $FF,$FB,$05
    dc.b $FF,$F8,$00
    dc.b $FF,$FC,$FB
    dc.b $FF,$00,$FA
    dc.b $FF,$05,$FA
    dc.b $FF,$07,$00
    dc.b $00,$00,$05
    dc.b $FF,$02,$03
    dc.b $FF,$00,$02
    dc.b $FF,$FE,$03
    dc.b $FF,$F9,$00
    dc.b $FF,$FD,$FC
    dc.b $FF,$00,$FE
    dc.b $FF,$03,$FD
    dc.b $FF,$07,$00
    dc.b $00,$F4,$10
    dc.b $00,$01,$00
    dc.b $FF,$10,$00
    dc.b $FF,$00,$05
    dc.b $FF,$F9,$07
    dc.b $FF,$07,$00
    dc.b $FF,$00,$05
    dc.b $FF,$EF,$00
    dc.b $FF,$00,$FC
    dc.b $FF,$09,$F8
    dc.b $FF,$F7,$00
    dc.b $FF,$00,$FB
    dc.b $01


VecTitleB:
    dc.b $00,$0,$FE
    dc.b $00,$1B,$C6
    dc.b $FF,$00,$FF
    dc.b $FF,$02,$00
    dc.b $FF,$00,$01
    dc.b $FF,$0D,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$02,$00
    dc.b $FF,$00,$0E
    dc.b $FF,$FE,$03
    dc.b $00,$02,$EF
    dc.b $FF,$FE,$03
    dc.b $00,$FD,$0A
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FD
    dc.b $00,$01,$02
    dc.b $FF,$FD,$03
    dc.b $00,$07,$09
    dc.b $00,$00,$01
    dc.b $FF,$02,$00
    dc.b $FF,$00,$FB
    dc.b $FF,$EF,$00
    dc.b $FF,$FE,$02
    dc.b $00,$13,$FE
    dc.b $FF,$FE,$02
    dc.b $00,$01,$0D
    dc.b $00,$FA,$F9
    dc.b $FF,$00,$02
    dc.b $FF,$07,$00
    dc.b $FF,$00,$04
    dc.b $FF,$FE,$03
    dc.b $00,$02,$F9
    dc.b $FF,$FE,$02
    dc.b $00,$FC,$FE
    dc.b $FF,$FD,$02
    dc.b $00,$FD,$FE
    dc.b $FF,$FB,$00
    dc.b $FF,$FE,$02
    dc.b $00,$11,$16
    dc.b $FF,$02,$FE
    dc.b $FF,$00,$F9
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FD
    dc.b $FF,$F8,$00
    dc.b $FF,$F9,$07
    dc.b $00,$0F,$FB
    dc.b $00,$04,$03
    dc.b $FF,$FE,$02
    dc.b $00,$FE,$F9
    dc.b $FF,$FE,$02
    dc.b $00,$00,$0A
    dc.b $00,$FF,$00
    dc.b $FF,$FB,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$FE,$00
    dc.b $00,$02,$02
    dc.b $FF,$FE,$03
    dc.b $00,$08,$08
    dc.b $FF,$02,$FE
    dc.b $FF,$04,$00
    dc.b $FF,$00,$0E
    dc.b $FF,$FE,$03
    dc.b $00,$02,$EE
    dc.b $00,$00,$01
    dc.b $FF,$FE,$02
    dc.b $00,$FB,$02
    dc.b $FF,$F8,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$FE,$00
    dc.b $FF,$FE,$02
    dc.b $00,$04,$00
    dc.b $FF,$FF,$02
    dc.b $00,$09,$1A
    dc.b $FF,$FB,$00
    dc.b $FF,$00,$FD
    dc.b $FF,$FD,$00
    dc.b $00,$04,$03
    dc.b $FF,$FD,$02
    dc.b $00,$0C,$00
    dc.b $FF,$02,$FD
    dc.b $FF,$00,$FA
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FD
    dc.b $FF,$FE,$00
    dc.b $FF,$00,$FE
    dc.b $FF,$F8,$00
    dc.b $FF,$F9,$06
    dc.b $00,$0F,$FA
    dc.b $FF,$FE,$03
    dc.b $00,$06,$02
    dc.b $FF,$FE,$02
    dc.b $00,$EF,$0E
    dc.b $FF,$03,$FF
    dc.b $FF,$10,$00
    dc.b $FF,$00,$04
    dc.b $FF,$FE,$02
    dc.b $00,$02,$FA
    dc.b $FF,$FE,$02
    dc.b $00,$FC,$0A
    dc.b $FF,$06,$00
    dc.b $FF,$00,$05
    dc.b $FF,$FE,$02
    dc.b $00,$02,$F9
    dc.b $FF,$FE,$02
    dc.b $00,$F9,$F9
    dc.b $FF,$FB,$05
    dc.b $FF,$FD,$00
    dc.b $FF,$FE,$02
    dc.b $01
