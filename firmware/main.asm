main:
	lda #$D4
	sta $2011
	
	jsr ready
	lda #$D4
	sta $2012

	jsr readyyy
	lda #$D1
	sta $2010
	

loop:
	jmp loop

ready:
	lda $2015
	cmp #$01
	bne ready
	rts

readyy:
	lda $2015
	cmp #$01
	bne readyy
	rts

readyyy:
	lda $2015
	cmp #$01
	bne readyyy
	rts