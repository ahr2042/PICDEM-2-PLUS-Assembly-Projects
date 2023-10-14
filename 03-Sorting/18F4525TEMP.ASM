;******************************************************************************
;   								              *
;                       	 Sorting          			      *
;                       	 =======				      *
;    In this project a sorting algorithm is implemented.                      *
;    					                                      *
;******************************************************************************
;                                                                             *
;    Filename:        P18F4525Temp.ASM                                        *
;    Date:            07.06.2023                                              *
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
;Variablen und Konstanten

;******************************************************************************
; Konstanten
    ;random numbers to be sorted
#define			A_0		0x12
#define			A_1		0x23
#define			A_2		0x01
#define			A_3		0x56
#define			A_4		0x99
#define			A_5		0xAB
#define			A_6		0x80
#define			A_7		0x34
#define			A_8		0xA2
#define			A_9		0x81
#define			A_10		0xC2
#define			A_11		0x02
#define			A_12		0x91
#define			A_13		0xF0
#define			A_14		0x11
#define			A_15		0x66
    
    ;number of elements to be sorted
#define			NUM_ELEMENTS	0x0F
    
; Variables
    
temp			equ		0x100
start			equ		0x110
sort_in_ctr		equ		0x50
sort_out_ctr		equ		0x51
pointer_high		equ		0x5E
pointer_low		equ		0x5F


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
    ;call		selection_sort_ascending
    ;call		selection_sort_descending
    
    nop
		
; Endless loop   
    goto	 $
    
    
;******************************************************************************
    ;init / or write directly into memory -> File Registers!
;******************************************************************************
init
	lfsr			0,start
	movlw			A_0
	movwf			POSTINC0
	movlw			A_1
	movwf			POSTINC0
	movlw			A_2
	movwf			POSTINC0
	movlw			A_3
	movwf			POSTINC0
	movlw			A_4
	movwf			POSTINC0
	movlw			A_5
	movwf			POSTINC0
	movlw			A_6
	movwf			POSTINC0
	movlw			A_7
	movwf			POSTINC0
	movlw			A_8
	movwf			POSTINC0
	movlw			A_9
	movwf			POSTINC0
	movlw			A_10
	movwf			POSTINC0
	movlw			A_11
	movwf			POSTINC0
	movlw			A_12
	movwf			POSTINC0
	movlw			A_13
	movwf			POSTINC0
	movlw			A_14
	movwf			POSTINC0
	movlw			A_15
	movwf			POSTINC0
    return
    
    
;******************************************************************************
    ;selection sort ascending
;******************************************************************************
selection_sort_ascending
	rcall			init
	lfsr			0,start
	lfsr			2,temp
    
	movlw			NUM_ELEMENTS
	movwf			sort_out_ctr

search_out_ascending:
	movff			sort_out_ctr,sort_in_ctr
	movff			FSR0H,FSR1H
	movff			FSR0L,FSR1L
	movff			PREINC1,WREG
    
search_in_ascending:					; iterate through the list
							; till smalles number found
							; and put in the next first position

	cpfslt			INDF0
	rcall			switch_ascending
	movff			PREINC1,WREG
	decfsz			sort_in_ctr,f
	bra			search_in_ascending
    
    
	movff			PREINC0,WREG
	decfsz			sort_out_ctr,f
	bra			search_out_ascending    
    
    return
    
switch_ascending
	
	movff			INDF0, INDF2		; store value of first element
	movff			INDF1,INDF0		; in temp, then save value 
	movff			INDF2,INDF1		; zero ptr in first element
    return						; save temp in zero ptr
	

    
;******************************************************************************
    ;selection sort descending
;******************************************************************************
selection_sort_descending
	rcall			init
	lfsr			0,start
	lfsr			2,temp
    
	movlw			NUM_ELEMENTS
	movwf			sort_out_ctr

search_out_descending:
	movff			sort_out_ctr,sort_in_ctr
	movff			FSR0H,FSR1H
	movff			FSR0L,FSR1L
	movff			PREINC1,WREG
    
search_in_descending:					; iterate through the list
							; till smalles number found
							; and put in the next first position

	cpfsgt			INDF0
	rcall			switch_descending
	movff			PREINC1,WREG
	decfsz			sort_in_ctr,f
	bra			search_in_descending
    
    
	movff			PREINC0,WREG
	decfsz			sort_out_ctr,f
	bra			search_out_descending    
    return
    
switch_descending
	
	movff			INDF0, INDF2		; store value of first element
	movff			INDF1,INDF0		; in temp, then save value 
	movff			INDF2,INDF1		; zero ptr in first element
    return						; save temp in zero ptr
    
;******************************************************************************
    ;End of program
;******************************************************************************     
    END
