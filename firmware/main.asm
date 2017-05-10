main:
	jsr ready
	lda #$00
	sta $2011

	jsr ready
	lda #$00
	sta $2013

	jsr ready
	lda #$FF
	sta $2013

	jsr ready
	lda #$00
	sta $2011
loop:
	jmp loop

ready:
	lda $2015
	cmp #$01
	bne ready
	rts