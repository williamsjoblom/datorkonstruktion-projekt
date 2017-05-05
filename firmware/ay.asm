;;;
;;; AY-3-8910 driver
;;; 

;;; Initialize AY
ay_init:
	;; Reset AY
	JSR ay_reset	
	
	;; Disable noise
	LDX #$06
	LDY #$00
	JSR ay_send

	;; Enable A, B, C in mixer
	LDX #$07
	LDY #$f8
	JSR ay_send
	
	;; Set Channel A amplitude to max
	LDX #$08
	LDY #$0f
	JSR ay_send

	;; Set Channel A amplitude to max
	LDX #$09
	LDY #$0f
	JSR ay_send
	RTS
	
	
;;; Send data in Y to register X
ay_send:
	JSR ay_address
	JSR ay_data
	RTS

;;; Send reset to AY
ay_reset:
	LDA #0
	STA $2001
	JSR delay
	JSR ay_inactive
	RTS

;;; Send data in X to AY
ay_data:
	STY $2000
	LDA #$FE
	STA $2001
	JSR delay
	JSR ay_inactive
	RTS

;;; Send address in X to AY
ay_address:
	STX $2000
	LDA #$FF
	STA $2001
	JSR delay
	JSR ay_inactive
	RTS

;;; Send inactive signal to AY
ay_inactive:
	LDA #4
	STA $2001
	JSR delay
	RTS

;;; Delay
delay:
	LDA #40
next:
	SBC #1
	BNE next
	RTS