main:
	JSR ready
	LDA #$11
	STA $2010

	JSR ready
	LDA #$00
	STA $2013

	JSR ready
	LDA #$FF
	STA $2013

	JSR ready
	LDA #$94
	STA $2011

loop:
	JMP loop

ready:
	LDA $2015
	CMP #$01
	BNE ready
	RTS