main:
	jsr ready
	lda #$11
	sta $2010	

loop:
	jmp loop

ready:
	lda $2015
	cmp #$01
	bne ready
	rts