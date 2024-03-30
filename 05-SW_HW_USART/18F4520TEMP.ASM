;******************************************************************************
;                       	 SW/HW UART      			      *
;                       	 ===========				      *
;    This program showcases serial communication on the PICDEM2+ board,	      *
;    with two main tasks: firstly, it sends "Hello World" to a PC through     *
;    UART, employing both hardware UART and manual signal generation        *
;    with delay functions. Secondly, it receives a character from "HTerm"     *
;    or "PuTTY" via UART, utilizing both hardware UART and manual signal    *
;    polling with delay functions, providing insights into various serial     *
;    communication methods.     			                      *
;    					                                      *
;******************************************************************************
;                                                                             *
;    Filename:        P18F4525Temp.ASM                                        *
;    Date:            21.06.2023                                              *
;    File Version:                                                            *
;                                                                             *
;    Author:          Ahmad Rashed                                            *
;    Company:         University of Applied Sciences Aschaffenburg            *
;                                                                             * 
;******************************************************************************
;                                                                             *
;    Files Required: P18F4525.INC                                             *
;                                                                             *
;******************************************************************************

	LIST P=18F4520		;directive to define processor
	#include <P18F4520.INC>	;processor specific variable definitions

;******************************************************************************
;Configuration bits
;Microchip has changed the format for defining the configuration bits, please 
;see the .inc file for futher details on notation.  Below are a few examples.



;   Oscillator Selection:
    CONFIG	OSC = XT             
    CONFIG	WDT = OFF
    CONFIG	LVP = OFF

;******************************************************************************
;Variables and constants

    ;constants
#define		N_BITS		0x08
#define		T_X		LATC,6	    ;Sende Port-Bit
#define		R_X		LATC,7	    ;Empfangs-Port-Bit
#define		TRIS_Uart_TX	TRISC,6	    ;Richtung des Sende-bit
#define		TRIS_Uart_RX	TRISC,7	    ;Richtung des Empfangs-Port-bit
	
	
    ;Variables
tx_buffer	equ		0x20	    ;UART Sende-BUffer
rx_buffer	equ		0x21	    ;UART Empfangs-Buffer
sw_count	equ		0x22	    ;Zaehler fuer Software-UART
counter_l	equ		0x24
	
	
;******************************************************************************
;EEPROM data
; Data to be programmed into the Data EEPROM is defined here

		ORG	0xf00000
		DE	"Test Data",0,1,2,3,4,5

;******************************************************************************
;Reset vector
; This code will start executing when a reset occurs.

		ORG	0x0000
		goto	Main		;go to start of main code

;******************************************************************************
;High priority interrupt vector
; This code will start executing when a high priority interrupt occurs or
; when any interrupt occurs if interrupt priorities are not enabled.

		ORG	0x0008
		bra	HighInt		;go to high priority interrupt routine

;******************************************************************************
;Low priority interrupt vector and routine
; This code will start executing when a low priority interrupt occurs.
; This code can be removed if low priority interrupts are not used.

		ORG	0x0018
		retfie

;******************************************************************************
;High priority interrupt routine
; The high priority interrupt code is placed here to avoid conflicting with
; the low priority interrupt vector.

HighInt:

;	*** high priority interrupt code goes here ***
		retfie	FAST

;******************************************************************************
;Start of main program
; The main program code is placed here.

Main:    
    ;call	    sw_sending_UART		;sending a string using sw_UART
    ;call	    sw_sending_UART		;sending chars using hw_UART
    
    
    ;clrf	    rx_buffer
    ;call	    sw_recieving_UART		;recieving a char using sw_UART
    ;call	    hw_recieving_UART		;recieving a char using hw_UART

	   

	;Endless loop
	goto	$


;*****************************************************************************
	; Recieving UART HARDWARE! 9600N81 @ 4MHz
;*****************************************************************************   

hw_recieving_UART
	
; Port configuration
    movlw	    0x00	    		; setting the Baud rate generators
    movwf	    SPBRGH			; initialize SPBRGH, SPBRG for baud rate
    movlw	    d'25'			; 
    movwf	    SPBRG
    
    bcf		    TXSTA,2			; set or clear BRGH =0 , BRGH16= 1
    bsf		    BAUDCON,3
    
    bcf		    TXSTA,4			;SYNC = 0, SPEN =1  enable 
    bsf		    RCSTA,7			;asynchronous serial port 
    
    bsf		    RCSTA,4			; CREN = 1 , enable reception
    
    
    
check_inter_flag:
    btfss	    PIR1,5			; check interrupt flag => all Bits are received?
    bra		    check_inter_flag		; no, check again    
    movff	    RCREG,rx_buffer		; yes, copy the received 8 Bits into Buffer
    
    ;create a loop to read all upconing data
    retlw	    0x00
    
 
;*****************************************************************************
	; Recieving UART SOFTWARE! 9600N81 @ 4MHz
;*****************************************************************************   
 
sw_recieving_UART
    
; PORT configuration
    bsf		    TRIS_Uart_RX	;setting pin 7 PORTC as input
 
    movlw	    N_BITS		; Number of Bits to be recieved
    movwf	    sw_count		
   
; Recieving process
check_start:
    btfsc	    R_X			; is there a start bit?
    bra		    check_start		; no, start over
    call	    delay_rec_h		; yes, wait for 54us and check again 
    btfsc	    R_X			; if indeed there is a start bit?
    bra		    check_start		; no, start over
    call	    delay_sending	; yes, wait for 104us and start
rec:    
    bsf		    STATUS,C		; assume that 1 is recieved
    btfss	    R_X			; was it really 1?
    bcf		    STATUS,C		; no, recieve 0
    rrcf	    rx_buffer		; read recieved Bit into buffer 
    call	    delay_sending	; wait for 104us 
    decfsz	    sw_count		; is MSB recieved?
    bra		    rec			; no, read next Bit
    
    btfss	    R_X			; check if the Stop-Bit is sent?
    retlw	    0x01		; no, trash data has been recieved
    
    
    ;try to create a loop to keep on reading chars from input, see if it works?
    
    retlw	    0x00		; yes, everything is okey
    
    
delay_rec_h				;54 us= 16*3+  2 +2+2
    movlw	    0xA0
    movwf	    counter_l
inner_h:
    decfsz	    counter_l
    bra		    inner_h
    return
    

	
;*****************************************************************************
	; Sending UART HARDWARE! 9600N81 @ 4MHz
;*****************************************************************************
	
hw_sending_UART	
	
; Port configuration
    movlw	    0x00	    		; setting the Baud rate generators
    movwf	    SPBRGH			
    movlw	    d'25'
    movwf	    SPBRG
    
    bcf		    TXSTA,4			; SYNC = 0 Enable the asynchronous serial
    bsf		    RCSTA,7			; SPEN = 1 serial port
    
    bsf		    TXSTA,2			; BRGH = 1
    bcf		    BAUDCON,3			; BRG16 = 1
    
    bsf		    TXSTA,5			; TXEN =1 enable transmission
						; which also enables TXIE =1 
						; Interrupts 
	  
; Sending process						
						
    movlw		0x41			; sending the letter A		    
    movwf		TXREG 
    movlw		0x42			; sending the letter B		    
    movwf		TXREG
    movlw		0x43			; sending the letter C		    
    movwf		TXREG
	  
	  return
	  	

	
	
	
	
;*****************************************************************************
	; Sending UART Software! 9600N81 @ 4MHz
;*****************************************************************************
sw_sending_UART
	
	   bcf		    TRIS_Uart_TX	;setting pin 6 PORTC output
	   bsf		    T_X			;pulling output to high
	   call		    delay_sending	;making sure that it is high
	   call		    delay_sending	;making sure that it is high
	   call		    table_read
	
	return
	
output_func
	    movlw	    N_BITS		;setting the number of bits 
	    movwf	    sw_count		;that will be sent
	    bcf		    T_X			;sending Start-Bit
	    call	    delay_sending	;104us delay
sending_char:
	    rrcf	    tx_buffer,F
	    btfsc	    STATUS,C
	    bsf		    T_X
	    btfss	    STATUS,C
	    bcf		    T_X
	    call	    delay_sending	;104us delay
	    decfsz	    sw_count
	    bra		    sending_char
	    bsf		    T_X			;sending End-Bit
	    call	    delay_sending	
	    call	    delay_sending
	    
	return

table_read
	    movlw	    LOW	string_Table
	    movwf	    TBLPTRL
	    movlw	    HIGH string_Table
	    movwf	    TBLPTRH
	    movlw	    UPPER string_Table
	    movwf	    TBLPTRU
loop_table:
		tblrd*+
		movff	    TABLAT,tx_buffer
		btfsc	    STATUS,Z
		return
		call	    output_func
		bra	    loop_table
	
delay_sending			;104us   34*3 = 104
	    movlw	    0x1D
	    movwf	    counter_l
inner:
	    decfsz	    counter_l
	    bra		    inner
		
	return
	
	
	
	org		0x7000
string_Table
	    DW		"Hello World\0"

;******************************************************************************
;End of program
		END
