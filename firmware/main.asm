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

	;; LDX #$0F
	;; LDY #$01
	;; JSR raw

	;; LDX #$F0
	;; LDY #$00
	;; JSR raw
	
	JSR ready
	LDA #$94
	STA $2011

	JSR ready
	LDA #$94
	STA $2010
	

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