	;; 
MAIN:

	;; disable noise
	LDX #0
	LDY #6
	JSR raw

	;; Amplitud A
	LDX #$0F
	LDY #8
	JSR raw

	;; Amplitud B
	LDX #$0F
	LDY #9
	JSR raw

	;; Amplitud C
	LDX #$00
	LDY #10
	JSR raw

	;; Channel enable
	LDX #$FE
	LDY #7
	JSR raw
	


	;; Note #9, Octave #4 to CH B
	JSR ready
	LDA #$49
	STA $2010

	;; LDX #$8E
	;; LDY #$00
	;; JSR raw

	;; LDX #$00
	;; LDY #$01
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

init:
	JSR ay_init 		;INIT part
	LDY #$0F		;ampl for a
	JSR ay_amplitude_a
	LDY #$00		;zero for others
	JSR ay_amplitude_b
	JSR ay_amplitude_c
	LDY #$FE		;enable a only
	JSR ay_enable
	RTS