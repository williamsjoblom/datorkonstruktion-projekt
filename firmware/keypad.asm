;;;
;;; Keypad driver
;;; 

;;;
;;; Read keypress from keypad
;;; Returns pressed key in A
;;; 
keypad_read:	
keypad_wait_for_down:
	LDA $2009
	AND #$F0
	CMP #0
	BNE keypad_wait_for_down

	LDX $2009
	
keypad_wait_for_up:
	LDA $2009
	AND #$F0
	CMP #0
	BEQ keypad_wait_for_up

	TXA
	RTS


;;;
;;; Returns 1 in A if a key is pressed, otherwise 0
;;; 
keypad_avail:
	LDA $2009
	AND #$F0
	CMP #0
	BEQ keypad_avail_true
	LDA #0
	RTS
keypad_avail_true:
	LDA #1
	RTS
	
	

	
