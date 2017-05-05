
message: .data 'hello world'

;;; Entry
main:
	JSR ay_init
	
	;; CH A - C4 fine
	LDX #$00
	LDY #$71
	JSR ay_send

	;; CH A - C4
	LDX #$01
	LDY #$02
	JSR ay_send

	;; Set color to black/white
	LDY #$F0

	;; Print SONIC BOOM
	LDX message
	JSR vga_put_char
	LDX #$0F
	JSR vga_put_char
	LDX #$0E
	JSR vga_put_char
	LDX #$09
	JSR vga_put_char
	LDX #$03
	JSR vga_put_char

	LDX #$00
	JSR vga_put_char

	LDX #$02
	JSR vga_put_char
	LDX #$0F
	JSR vga_put_char
	LDX #$0F
	JSR vga_put_char
	LDX #$0D
	JSR vga_put_char	
	
done:
	;; Hang
	JMP done