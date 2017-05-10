
;;; Entry
main:
	
	JSR vga_init
	
	
	JSR ay_init
	
	;; ;; CH A - C4 fine
	;; LDX #$00
	;; LDY #$71
	;; JSR ay_send

	;; ;; CH A - C4
	;; LDX #$01
	;; LDY #$02
	;; JSR ay_send	

	JSR tracker_init

loop:
	JSR tracker_update
	JMP loop


	