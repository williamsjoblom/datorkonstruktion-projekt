;;; 
;;; Tracker
;;; Reserves addresses $50-$6F and $1000-$12FF
;;; 

;;;
;;; Column labels
;;; 
col_labels:
	.data 'Ch A    Ch B    Ch C'

;;;
;;; Note labels
;;;
c_label:
	.data 'C '
cs_label:
	.data 'C#'
d_label:
	.data 'D '
ds_label:
	.data 'D#'
e_label:
	.data 'E '
f_label:
	.data 'F '
fs_label:
	.data 'F#'
g_label:
	.data 'G '
gs_label:
	.data 'G#'
a_label:
	.data 'A '
as_label:
	.data 'A#'
b_label:
	.data 'B '

mute_label:
	.data '-- '

err_label:
	.data 'err'


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
;;; Channel enable/disable functions
;;; 	
tracker_enable_all:
	LDY #$F8
	STY $6C
	JSR ay_enable
	RTS
	
tracker_disable_all:
	LDY #$FF
	STY $6C
	JSR ay_enable
	RTS
	
tracker_enable_a:
	LDA $6C
	AND #$FE
	STA $6C
	TAY
	JSR ay_enable
	RTS
	
tracker_enable_b:
	LDA $6C
	AND #$FD
	STA $6C
	TAY
	JSR ay_enable
	RTS

tracker_enable_c:
	LDA $6C
	AND #$FB
	STA $6C
	TAY
	JSR ay_enable
	RTS

tracker_disable_a:
	LDA $6C
	ORA #$01
	STA $6C
	TAY
	JSR ay_enable
	RTS
	
tracker_disable_b:
	LDA $6C
	ORA #$02
	STA $6C
	TAY
	JSR ay_enable
	RTS
	
tracker_disable_c:
	LDA $6C
	ORA #$04
	STA $6C
	TAY
	JSR ay_enable
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
	CMP #39
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

	;; Compensate for note lookup table offset, ie do not accept octave 0
	CMP #1
	BMI tracker_read_keypad_avail
	
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
;;; Print tone in A
;;; (ex C#4)
;;; 
tracker_put_tone:
	CMP #$FF
	BEQ tracker_put_tone_mute
	
	PHA
	LSR #4 			; Discard note
	JSR vga_put_hex_digit	; Print octave
	PLA

	LDX #$F0		; Set color to black/white
	AND #$0F		; Discard octave
	JSR tracker_put_note	; Print note
	RTS
tracker_put_tone_mute:
	LDX #$F0		; Set color to black/white cyan
	LDY <mute_label
	LDA >mute_label
	JSR vga_put_str
	RTS

	
;;;
;;; Print note in A
;;; (ex A#)
;;; 
tracker_put_note:	
	CMP #0
	BNE tracker_put_note_cs
	
	LDY <c_label
	LDA >c_label
	JSR vga_put_str
	RTS
tracker_put_note_cs:	
	CMP #1
	BNE tracker_put_note_d
	
	LDY <cs_label
	LDA >cs_label
	JSR vga_put_str
	RTS
tracker_put_note_d:	
	CMP #2
	BNE tracker_put_note_ds
	
	LDY <d_label
	LDA >d_label
	JSR vga_put_str
	RTS
tracker_put_note_ds:	
	CMP #3
	BNE tracker_put_note_e
	
	LDY <ds_label
	LDA >ds_label
	JSR vga_put_str
	RTS
tracker_put_note_e:	
	CMP #4
	BNE tracker_put_note_f
	
	LDY <e_label
	LDA >e_label
	JSR vga_put_str
	RTS
tracker_put_note_f:	
	CMP #5
	BNE tracker_put_note_fs
	
	LDY <f_label
	LDA >f_label
	JSR vga_put_str
	RTS
tracker_put_note_fs:	
	CMP #6
	BNE tracker_put_note_g
	
	LDY <fs_label
	LDA >fs_label
	JSR vga_put_str
	RTS
tracker_put_note_g:	
	CMP #7
	BNE tracker_put_note_gs
	
	LDY <g_label
	LDA >g_label
	JSR vga_put_str
	RTS
tracker_put_note_gs:	
	CMP #8
	BNE tracker_put_note_a
	
	LDY <gs_label
	LDA >gs_label
	JSR vga_put_str
	RTS
tracker_put_note_a:	
	CMP #9
	BNE tracker_put_note_as
	
	LDY <a_label
	LDA >a_label
	JSR vga_put_str
	RTS
tracker_put_note_as:	
	CMP #10
	BNE tracker_put_note_b
	
	LDY <as_label
	LDA >as_label
	JSR vga_put_str
	RTS
tracker_put_note_b:	
	CMP #11
	BNE tracker_put_note_other
	
	LDY <b_label
	LDA >b_label
	JSR vga_put_str
	RTS
tracker_put_note_other:
	LDY <err_label
	LDA >err_label
	JSR vga_put_str
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
	TXA
	PHA
	
	LDA ($50), X
	JSR tracker_put_tone
	
	PLA
	TAX

	;; Carrage return
	LDA $2002
	SBC #3
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
	LDA #0
	PHA
tracker_play_loop:
	JSR tracker_enable_all
	
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

	JSR tracker_disable_all
	
	RTS

;;; 
;;; Play note in Ch A at position X
;;; 
tracker_play_a:
	;; Load note/octave
	LDX $1000, X
	TXA
	CMP #$FF
	BNE tracker_play_a_note

	JSR tracker_disable_a
	
	RTS
	
tracker_play_a_note:	
	JSR ay_wait
	STX $2010
	RTS
;;; 
;;; Play note in Ch B at position X
;;; 
tracker_play_b:
	;; Load note/octave
	LDX $1100, X
	TXA
	CMP #$FF
	BNE tracker_play_b_note

	JSR tracker_disable_b
	
	RTS
	
tracker_play_b_note:	
	JSR ay_wait
	STX $2011
	RTS
	
;;; 
;;; Play note in Ch C at position X
;;; 
tracker_play_c:
	;; Load note/octave
	LDX $1200, X
	TXA
	CMP #$FF
	BNE tracker_play_c_note

	JSR tracker_disable_c
	
	RTS
	
tracker_play_c_note:	
	JSR ay_wait
	STX $2012
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

	
	