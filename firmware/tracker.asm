;;; 
;;; Tracker
;;; Reserves addresses $50-$6F and $1000-$12FF
;;; 
	
col_labels:
	.data 'Ch A    Ch B    Ch C'


;;;
;;; Initialize tracker
;;; 
tracker_init:
	;; Clear tracker cursor position
	LDA #0
	STA $60
	STA $61

	LDY #$0F
	JSR ay_amplitude_a
	JSR ay_amplitude_b
	JSR ay_amplitude_c

	LDX #$0B		; Set color to black/light cyan
	LDY <col_labels
	LDA >col_labels
	JSR vga_put_str

	JSR tracker_draw_a
	JSR tracker_draw_b
	JSR tracker_draw_c

	;; Set cursor to (0, 1)
	LDX #0
	LDY #1
	JSR vga_set_cursor
	LDA #$0F 		; Invert color
	STA ($2006)
	
	RTS

;;;
;;; Handle dpad keypresses
;;; 
tracker_handle_dpad:
	LDA $2008
	AND #8
	CMP #0
	BEQ tracker_handle_right
tracker_handle_up_wait:
	LDA $2008
	AND #8
	CMP #0
	BNE tracker_handle_up_wait

	JSR tracker_up

tracker_handle_right:
	LDA $2008
	AND #4
	CMP #0
	BEQ tracker_handle_down
tracker_handle_right_wait:
	LDA $2008
	AND #4
	CMP #0
	BNE tracker_handle_right_wait

	JSR tracker_right

tracker_handle_down:
	LDA $2008
	AND #2
	CMP #0
	BEQ tracker_handle_left
tracker_handle_down_wait:
	LDA $2008
	AND #2
	CMP #0
	BNE tracker_handle_down_wait

	JSR tracker_down
	
tracker_handle_left:	
	LDA $2008
	AND #1
	CMP #0
	BEQ tracker_handle_done
tracker_handle_left_wait:
	LDA $2008
	AND #1
	CMP #0
	BNE tracker_handle_left_wait

	JSR tracker_left

tracker_handle_done:
	RTS


;;;
;;; Cursor functions
;;; Cursor position for the tracker: (Channel, Line) = ($60, $61)
;;; 

	
;;;
;;; Set vga cursor to tracker cursor position
;;; 
tracker_update_cursor:
	JSR tracker_validate_cursor
	
	LDA $60
	ASL #3
	TAX	
	
	LDA $61
	ADC #1
	TAY

	JSR vga_set_cursor
	RTS

	
;;;
;;; Wrap cursor inside bounds
;;; 
tracker_validate_cursor:
	LDA $61
	CMP #0
	BPL tracker_validate_down
	
	LDA #38
	STA $61
	JMP tracker_validate_left
tracker_validate_down:
	CMP #38
	BMI tracker_validate_left

	LDA #0			; Wrap around
	STA $61
tracker_validate_left:
	LDA $60
	CMP #0
	BPL tracker_validate_right
	
	LDA #2
	STA $60
	JMP tracker_validate_end
tracker_validate_right:
	CMP #3
	BMI tracker_validate_end

	LDA #0			; Wrap around
	STA $60
tracker_validate_end:
	RTS

	
;;;
;;; Move cursor up
;;; 
tracker_up:
	LDA #$F0
	STA ($2006)
	
	LDA $61
	SBC #1
	STA $61

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;;
;;; Move cursor right
;;; 
tracker_right:
	LDA #$F0
	STA ($2006)
	
	LDA $60
	ADC #1
	STA $60

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	RTS

	
;;;
;;; Move cursor down
;;; 
tracker_down:
	LDA #$F0
	STA ($2006)
	
	LDA $61
	ADC #1
	STA $61

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;;
;;; Move cursor left
;;; 
tracker_left:

	;; FIXME: REMOVE
	JSR tracker_play
	RTS
	
	LDA #$F0
	STA ($2006)
	
	LDA $60
	SBC #1
	STA $60

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;;
;;; Read 8 bit word from keypad
;;; 
tracker_read_keypad:
	JSR keypad_avail
	CMP #1
	BEQ tracker_read_keypad_avail
	RTS
tracker_read_keypad_avail:
	;; Key is pressed, read most significant digit
	JSR keypad_read
	ASL #4 			; Shift most significant digit
	STA $6F			; Store A in $6F
	
	JSR keypad_read
	;; Or the most and least significant digit producing final 8-bit word.
	ORA $6F
	TAY
	
	LDX $61 		; Load current row to X
	
	LDA $60
	CMP #0
	BEQ tracker_read_keypad_store_a
	CMP #1
	BEQ tracker_read_keypad_store_b
	CMP #2
	BEQ tracker_read_keypad_store_c
	
	;; Update memory containing notes and redraw current column
tracker_read_keypad_store_a:
	STY $1000, X
	JSR tracker_draw_a
	JMP tracker_read_keypad_store_end
tracker_read_keypad_store_b:	
	STY $1100, X
	JSR tracker_draw_b
	JMP tracker_read_keypad_store_end
tracker_read_keypad_store_c:	
	STY $1200, X
	JSR tracker_draw_c
	
tracker_read_keypad_store_end:

	JSR tracker_update_cursor
	
	RTS

	
;;;
;;; Update
;;; 
tracker_update:
	JSR tracker_handle_dpad
	JSR tracker_read_keypad
	RTS

	
;;;
;;; Draw channel A
;;; 
tracker_draw_a:
	LDX #0
	LDY #1
	JSR vga_set_cursor
	
	LDY #$10
	LDA #$00
	JSR tracker_draw_col

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;;
;;; Draw channel B
;;; 
tracker_draw_b:
	LDX #8
	LDY #1
	JSR vga_set_cursor
	
	LDY #$11
	LDA #$00
	JSR tracker_draw_col

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;;
;;; Draw channel C
;;; 
tracker_draw_c:
	LDX #16
	LDY #1
	JSR vga_set_cursor
	
	LDY #$12
	LDA #$00
	JSR tracker_draw_col

	JSR tracker_update_cursor

	LDA #$0F
	STA ($2006)
	
	RTS

	
;;; 
;;; Draw column stored in A(lsb) and Y(msb)
;;; 
tracker_draw_col:
	STA $50
	STY $51
	
	LDX #0
tracker_draw_col_line:	
	LDA ($50), X
	JSR vga_put_hex

	;; Carrage return
	LDA $2002
	SBC #2
	STA $2002

	;; New line
	LDA $2003
	ADC #1
	STA $2003
	
	INX
	TXA
	CMP #39
	BNE tracker_draw_col_line
	RTS


;;;
;;; Play song
;;; 
tracker_play:
	JSR ay_enable_all
	
	LDA #0
	PHA
tracker_play_loop:
	PLA
	TAX

	PHA
	JSR tracker_play_a
	PLA
	TAX

	PHA
	JSR tracker_play_b
	PLA
	TAX

	PHA
	JSR tracker_play_c
	PLA
	
	ADC #1
	
	CMP #39
	BEQ tracker_play_end
	
	PHA
	JSR tracker_beat_delay
	JMP tracker_play_loop
	
tracker_play_end:

	JSR ay_disable_all
	
	RTS

	
;;; 
;;; Play note in Ch A at position X
;;; 
tracker_play_a:
	;; Store fine value
	LDA $1000, X
	ASL #4
	STA $6A

	;; Store course value
	LDA $1000, X
	LSR #4
	STA $6B

	LDX #$00
	LDY $6A
	JSR ay_send
	
	LDX #$01
	LDY $6B
	JSR ay_send

	RTS

;;; 
;;; Play note in Ch B at position X
;;; 
tracker_play_b:
	;; Store fine value
	LDA $1100, X
	ASL #4
	STA $6A

	;; Store course value
	LDA $1100, X
	LSR #4
	STA $6B

	LDX #$02
	LDY $6A
	JSR ay_send
	
	LDX #$03
	LDY $6B
	JSR ay_send

	RTS

;;; 
;;; Play note in Ch C at position X
;;; 
tracker_play_c:
	;; Store fine value
	LDA $1200, X
	ASL #4
	STA $6A

	;; Store course value
	LDA $1200, X
	LSR #4
	STA $6B

	LDX #$04
	LDY $6A
	JSR ay_send
	
	LDX #$05
	LDY $6B
	JSR ay_send

	RTS
	

;;;
;;; Delay one beat (500ms = 120BPM)
;;; 
tracker_beat_delay:
	LDA #20
	LDX #250 		; Do 20 delays * 25ms = 500ms = 120BPM
tracker_beat_delay_loop:
	PHA
	JSR delay
	PLA
	SBC #1
	CMP #0
	BNE tracker_beat_delay_loop
	RTS

	
	