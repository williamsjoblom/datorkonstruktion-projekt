main:
	jsr ready
	lda #$00
	sta $2011

loop:
	jmp loop