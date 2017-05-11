
;;;
;;; Delay X / 10 milliseconds (about 2% off)
;;;
delay:
delay_outer:
	LDY #$FF
delay_inner:	
	TYA
	SBC #1
	TAY
	CMP #0
	BNE delay_inner

	TXA
	SBC #1
	TAX
	CMP #0
	BNE delay_outer

	RTS