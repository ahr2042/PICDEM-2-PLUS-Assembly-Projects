;******************************************************************************
;   								              *
;                        16 Bit Multiplication and Division                   *
;                        ==================================                   *
;    In this project an algorithm is implemented for multiplying and          *
;    dividing two 16 bits numbers and the mathematical function               *
;    f(x) = ax + b.                                                           *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:        P18F4525Temp.ASM                                        *
;    Date:            24.05.2023                                              *
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
;Variables und Constants

;Constants for the multiplication

    #define		ZA_1		0x00
    #define		ZA_0		0xAD
    
    
    #define		ZB_1		0x00
    #define		ZB_0		0x0F

;Constants for the mathematical function f(x) = ax +b
    
    #define		BITS		D'8'
    #define		A_WERT		D'240'	    ;a in the function y = ax +b
    #define		B_HIGH		0x04	    ;b(high)in the function y = ax +b
    #define		B_LOW		0xc9	    ;b(low)in the function y = ax +b
    #define		MAXWERT		D'250'	    ;Max. value of x in the function y = ax +b
    
    #define		START_BANK3	0x300
    
    #define		OFFSET_X	0x05	    ;Offset for saving results of y= ax +b
    
 
    
    
; Variables     
    
x			equ			0x10	    ;x in the function y = ax +b
multiplikand_1		equ			0x11
multiplikand_0		equ			0x12
multiplikator_1		equ			0x13
multiplikator_0		equ			0x14
    
dividend_1		equ			0x15
dividend_0		equ			0x16
divisor_1		equ			0x17
divisor_0		equ			0x18
    
ACCdLO			equ			0x19
ACCdHI			equ			0x1A
    
counter			equ			0x1B
res_3			equ			0x1C
res_2			equ			0x1D
res_1			equ			0x1E
res_0			equ			0x1F
counter_func		equ			0x28

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
        
    ;call	division
    ;call	multiplication
    ;call	fucntion
     nop

    goto	$
    

;*********************************************
;Mathematical function
;*********************************************
    
fucntion
    
    clrf	res_3
    clrf	res_2
    clrf	res_1
    clrf	res_0
    
    clrf	x
    movlw	D'11'
    movwf	counter_func
    lfsr	0,START_BANK3
    
    ;x = 0 => y=b
    movlw	B_HIGH
    movwf	POSTINC0
    movlw	B_LOW
    movwf	POSTINC0
    decf	counter_func,F
    call	next_value
	return

    
next_value:
    movlw	OFFSET_X
    addwf	x
    call	multiplication_func
    call	addition_func
    call	into_table
    decfsz	counter_func,F
    bra		next_value    
    return
 
    
multiplication_func
    movlw	A_WERT
    mulwf	x
    movff	PRODL,res_0
    movff	PRODH,res_1   
    return
    
addition_func
    bcf		STATUS,C
    movlw	B_LOW
    addwf	res_0,F
    movlw	B_HIGH
    addwfc	res_1,F
    return
    
into_table
    movf	res_1,W
    movwf	POSTINC0
    movf	res_0,W
    movwf	POSTINC0
    return    
    
    
    
    
;************************************
    ;Multiplication
;************************************
multiplication
    
    clrf	res_3
    clrf	res_2
    
    movlw	0x10
    movwf	counter

Loop_mult
    rrcf	multiplikator_1, F
    rrcf	multiplikator_0, F
    btfsc	STATUS,C
    call	addition_mult
    
    rrcf	res_3,F
    rrcf	res_2,F
    rrcf	res_1,F
    rrcf	res_0,F
  
        
    decfsz	counter,F
    goto	Loop_mult
    
    return
	
    
addition_mult
    bcf		STATUS,C
    movf	multiplikand_0,W
    addwf	res_2
    movf	multiplikand_1,W
    addwfc	res_3    
    
    return
	


 
;*********************************************
    ;Division
;*********************************************
division       
    call	initilize
    ;reset Carry flag and Remainder   
    bcf	    	STATUS,C
    clrf	ACCdLO
    clrf	ACCdHI
    
    movlw	D'17'
    movwf	counter
    
Loop_div    
    rlcf	dividend_0
    rlcf	dividend_1
    

    dcfsnz	counter	
    return
    
    rlcf	ACCdLO
    rlcf	ACCdHI
    
    movf	divisor_0,W
    subwf	ACCdLO,F
    movf	divisor_1,W
    subwfb	ACCdHI,F
    btfsc	STATUS,N
    bra		addition_div
    
    bsf		STATUS,C
    bra		Loop_div
    
    
addition_div:
    movf	divisor_0,W
    addwf	ACCdLO,F
    movf	divisor_1,W
    addwfc	ACCdHI,F
    
    bcf		STATUS,C
    bra		Loop_div
    


    
    
    

    
    
;*********************************************
	    ;Init
;*********************************************
initilize
    movlw	ZA_1
    movwf	multiplikand_1
    movwf	dividend_1
    movlw	ZA_0
    movwf	multiplikand_0
    movwf	dividend_0
    
    movlw	ZB_1
    movwf	multiplikator_1
    movwf	divisor_1
    movlw	ZB_0
    movwf	multiplikator_0
    movwf	divisor_0
    return  
    
;******************************************************************************
;End of program

	END	
