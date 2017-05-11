;;;
;;; AY-3-8910 driver
;;;

;;; 
;;; Initialize AY
;;; 
ay_init:
	;; Reset AY
	JSR ay_reset	

	JSR ay_disable_all
	
	;; Disable noise
	LDX #$06
	LDY #$00
	JSR ay_send

	;; Set envelop to sawtooth
	LDX #$0D
	LDY #$0C
	JSR ay_send
	
	RTS

	
;;;
;;; Send data in Y to register X
;;; 
ay_send:
	JSR ay_address
	JSR ay_data
	RTS

	
;;; 
;;; Send reset to AY
;;; 
ay_reset:
	LDA #0
	STA $2001
	JSR ay_delay
	JSR ay_inactive
	RTS

;;; 
;;; Send data in X to AY
;;; 
ay_data:
	STY $2000
	LDA #$FE
	STA $2001
	JSR ay_delay
	JSR ay_inactive
	RTS
	
;;; 
;;; Send address in X to AY
;;; 
ay_address:
	STX $2000
	LDA #$FF
	STA $2001
	JSR ay_delay
	JSR ay_inactive
	RTS

	
;;; 
;;; Send inactive signal to AY
;;; 
ay_inactive:
	LDA #4
	STA $2001
	JSR ay_delay
	RTS

;;; 
;;; Write delay
;;; 
ay_delay:
	LDA #20
next:
	SBC #1
	BNE next
	RTS


;;;
;;; Set Ch A amplitude to Y
;;; 
ay_amplitude_a:
	LDX #$08
	JSR ay_send
	RTS

	
;;;
;;; Set Ch B amplitude to Y
;;; 
ay_amplitude_b:
	LDX #$09
	JSR ay_send
	RTS

	
;;;
;;; Set Ch C amplitude to Y
;;; 
ay_amplitude_c:
	LDX #$0A
	JSR ay_send
	RTS

	
;;;
;;; Set enable bits to Y
;;; 
ay_enable:
	LDX #$07
	JSR ay_send
	RTS

	
;;;
;;; Enable all channels
;;; 
ay_enable_all:
	LDX #$07
	LDY #$F8
	JSR ay_send
	RTS

	
;;;
;;; Disable all channels
;;; 
ay_disable_all:
	;; Enable A, B, C in mixer
	LDX #$07
	LDY #$FF
	JSR ay_send
	RTS