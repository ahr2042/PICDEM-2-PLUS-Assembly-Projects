;******************************************************************************
;                       	 I2C with EEPROM      			      *
;                       	 ===============			      *
;    I2C protocol is used to communicate with an EEPROM on the PICDEM 2	      *
;    Board.     
;    					                                      *
;******************************************************************************
;                                                                             *
;    Filename:        P18F4525Temp.ASM                                        *
;    Date:            07.07.2023                                              *
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

	LIST P=18F4525	;directive to define processor
	#include <P18F4525.INC>	;processor specific variable definitions

;******************************************************************************
;Configuration bits
;Microchip has changed the format for defining the configuration bits, please 
;see the .inc file for futher details on notation.  Below are a few examples.



;   Oscillator Selection:
    CONFIG	OSC = XT             ;LP
    CONFIG	WDT = OFF
    CONFIG	LVP = OFF

;******************************************************************************
;Variable & CONSTANTS definitions
#define		    DATA_EE_ADDR	    0xFF
#define		    DATA_EE_DATA	    0x41
    

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
;	*** main code goes here ***



    ;configure pins
    bcf		    TRISC,RC3
    bcf		    TRISC,RC4
    
    ;configuration
    
    bsf		    SSPCON1,5
    bcf		    SSPCON1,0
    bcf		    SSPCON1,1
    bcf		    SSPCON1,2
    bsf		    SSPCON1,3
    
    
    bcf		    PIR1,3
    
    
    
    movlw	    d'10100000'
    movwf	    SSPADD
    
    
    movlw	    0x00
    movwf	    SSPBUF
    
loop:
    btfss	    PIR1,3
    bra		    loop
    
    bcf		    PIR1,3
    
    movlw	    0x41		; A = 0x41 
    movwf	    SSPBUF
    
loop2:
    btfss	    PIR1,3
    bra		    loop2
   
    
    nop
    
    

    
;******************************************************************************
;Internal EEPROM
;******************************************************************************
    ;call	write_Intern_EEPROM
    ;call	read_Intern_EEPROM
    
    
;endless loop    
    goto $
   

;******************************************************************************
;Write in Internal EEPROM
;******************************************************************************
write_Intern_EEPROM
    MOVLW	    DATA_EE_ADDR    ;
    MOVWF	    EEADR	    ; Data Memory Address to write
    MOVLW	    DATA_EE_DATA    ;
    MOVWF	    EEDATA	    ; Data Memory Value to write
    BCF		    EECON1, EEPGD   ; Point to DATA memory
    BCF		    EECON1, CFGS    ; Access EEPROM
    BSF		    EECON1, WREN    ; Enable writes
    BCF		    INTCON, GIE	    ; Disable Interrupts
    MOVLW	    55h		    ;
Required    MOVWF   EECON2	    ; Write 55h
Sequence    MOVLW   0AAh	    ;
    MOVWF	    EECON2	    ; Write 0AAh
    BSF		    EECON1, WR	    ; Set WR bit to begin write
    BSF		    INTCON, GIE	    ; Enable Interrupts
    ; User code execution
    BCF		    EECON1, WREN    ; Disable writes on write complete (EEIF set)	
    
    return    
    

    
;******************************************************************************
;Read from Internal EEPROM
;******************************************************************************
read_Intern_EEPROM
    MOVLW	DATA_EE_ADDR    ;
    MOVWF	EEADR		; Data Memory Address to read
    BCF		EECON1, EEPGD	; Point to DATA memory
    BCF		EECON1, CFGS	; Access EEPROM
    BSF		EECON1, RD	; EEPROM Read
    MOVF	EEDATA, W	; W = EEDATA    
    return
    
;******************************************************************************
;End of program
    
		END
