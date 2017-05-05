
hello:
	.data 'hello world'
	
;;; Entry
main:
	LDY <hello
	LDA >hello
	JSR vga_put_str
	
	JSR ay_init
	
	;; CH A - C4 fine
	LDX #$00
	LDY #$71
	JSR ay_send

	;; CH A - C4
	LDX #$01
	LDY #$02
	JSR ay_send
	
	;; ;; Print SONIC BOOM
	;; LDA #$0A
	;; JSR vga_put_char
	;; LDA #$0F
	;; JSR vga_put_char
	;; LDA #$0E
	;; JSR vga_put_char
	;; LDA #$09
	;; JSR vga_put_char
	;; LDA #$03
	;; JSR vga_put_char

	;; LDA #$00
	;; JSR vga_put_char

	;; LDA #$02
	;; JSR vga_put_char
	;; LDA #$0F
	;; JSR vga_put_char
	;; LDA #$0F
	;; JSR vga_put_char
	;; LDA #$0D
	;; JSR vga_put_char	
	
done:
	;; Hang
	JMP done