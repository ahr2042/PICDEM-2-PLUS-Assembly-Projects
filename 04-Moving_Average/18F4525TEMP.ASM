;******************************************************************************
;                       	 Moving Average      			      *
;                       	 ==============				      *
;    This assembler program calculates the mean of the contents of two        *
;    adjacent registers. The mean is stored in consecutive registers          *
;    starting at 70h. The values of registers 60h to 6Fh are not changed.     *
;    					                                      *
;******************************************************************************
;                                                                             *
;    Filename:        P18F4525Temp.ASM                                        *
;    Date:            14.06.2023                                              *
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
;                                                                             *
;    Notes:            Implemented on the simulator in MPLAP X 5.30           *
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

;******************************************************************************
    ;Constants
#define			    N_TIMES		0x10
#define			    MITTEL		0x02    

    ;Variables 
saving_addr		    equ			0x70
my_data			    equ			0x60	 
tmp			    equ			0x50
counter			    equ			0x51


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

    ;add the two next numbers save the result in a 8 bit temp variable
    ;divide it by 2 and save the result in adresses starting 0x70.
    
    movlw		N_TIMES
    movwf		counter
    
    lfsr		0, my_data
    lfsr		1, my_data
    lfsr		2, saving_addr
    
mittelwert:
    movff		PREINC1, WREG
    addwf		POSTINC0, WREG
    rrcf		WREG,W
    movff		WREG, POSTINC2
    decfsz		counter
    bra			mittelwert

; Endless loop    
	goto	$

;******************************************************************************
;End of program
		END
