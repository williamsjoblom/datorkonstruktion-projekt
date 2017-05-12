	;; 
MAIN:

;;; disable noise
	LDX #0
	LDY #6
	JSR raw
	
	LDX #$0F
	LDY #8
	JSR raw

	LDX #$0F
	LDY #9
	JSR raw

	LDX #$00
	LDY #10
	JSR raw
	
	LDX #$F8
	LDY #7
	JSR raw
	
	;; CH A, Coarse = 1111
	;; LDX #$0F
	;; LDY #$01
	;; JSR raw
	
	;; CH B, Fine = 1111 0000
	;; LDX #$F0
	;; LDY #$00
	;; JSR raw

	;; Note #9, Octave #4 to CH B
	JSR ready
	LDA #$94
	STA $2011

	;; LDX #$8E
	;; LDY #$00
	;; JSR raw

	;; LDX #$00
	;; LDY #$01
	;; JSR raw

	;; LDX #$8E
	;; LDY #$02
	;; JSR raw

	;; LDX #$00
	;; LDY #$03
	;; JSR raw
	

loop:
	JMP loop

ready:
	LDA $2015
	CMP #$01
	BNE ready
	RTS

;;;
;;; X => Y
;;; 
raw:
	JSR ready
	STY $2013
	JSR ready
	STX $2013
	RTS