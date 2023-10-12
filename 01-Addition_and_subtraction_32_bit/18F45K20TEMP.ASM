;******************************************************************************
;									      *
;                          32 Bit Addition and Subtraction                    *
;   		           ===============================                    *
;   In this project a algorithm for 32 Bit addition and subtraction is        *
;   implemented.                                                              *
;                                                                             *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Filename:         18F45K20TEMP.asm                                       *
;    Date:             05.05.2023                                             *
;    File Version:                                                            *
;    Author:           Ahmad Rashed                                           *
;    Company:          University of Applied Sciences Aschaffenburg           *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Files Required:   P18F45K20.INC                                          *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Notes:            Implemented on the simulator in MPLAP X 5.30           *
;                                                                             *
;******************************************************************************
;                                                                             *
;    Revision History:                                                        *
;                                                                             *
;******************************************************************************

;------------------------------------------------------------------------------
; PROCESSOR DECLARATION
;------------------------------------------------------------------------------

     LIST      P=PIC18F45K20          ; list directive to define processor
     #INCLUDE <P18F45K20.INC>         ; processor specific variable definitions

;------------------------------------------------------------------------------
;
; CONFIGURATION WORD SETUP
;
; The 'CONFIG' directive is used to embed the configuration word within the 
; .asm file. The lables following the directive are located in the respective 
; .inc file.  See the data sheet for additional information on configuration 
; word settings.
;
;------------------------------------------------------------------------------

     CONFIG FOSC = INTIO7, FCMEN = OFF, IESO = OFF, PWRT = OFF, BOREN = OFF
     CONFIG BORV = 18, WDTEN = OFF, WDTPS = 1, MCLRE = ON, HFOFST = ON
     CONFIG LPT1OSC = OFF, PBADEN = OFF, CCP2MX = PORTC, STVREN = OFF
     CONFIG LVP = OFF,  XINST = OFF, CP0 = OFF, CP1 = OFF, CP2 = OFF
     CONFIG CP3 = OFF, CPB = OFF, CPD = OFF, WRT0 = OFF, WRT1 = OFF
     CONFIG WRT2 = OFF, WRT3 = OFF, WRTB = OFF, WRTC = OFF, WRTD = OFF
     CONFIG EBTR0 = OFF, EBTR1 = OFF, EBTR2 = OFF, EBTR3 = OFF
     CONFIG EBTRB = OFF

;------------------------------------------------------------------------------
;
; VARIABLES and CONSTANTS DEFINITIONS
;
;------------------------------------------------------------------------------

     
;Constants    
#define	    ZA_3	0x00
#define	    ZA_2	0x00
#define	    ZA_1	0x00
#define	    ZA_0	0xFF

#define	    ZB_3	0x00
#define	    ZB_2	0x00
#define	    ZB_1	0x01
#define	    ZB_0	0x00


;Variabels     
     
za_0	    equ		0x60
za_1	    equ		0x61
za_2	    equ		0x62
za_3	    equ		0x63
	    
zb_0	    equ		0x64
zb_1	    equ		0x65
zb_2	    equ		0x66
zb_3	    equ		0x67

	    
;------------------------------------------------------------------------------
; EEPROM INITIALIZATION
;
; The 18F45K20 has non-volatile EEPROM starting at 0xF00000
; 
;------------------------------------------------------------------------------

DATAEE    ORG  0xF00000 ; Starting address for EEPROM for 18F45K20

    DE    "MCHP"        ; Place 'M' 'C' 'H' 'P' at address 0,1,2,3

;------------------------------------------------------------------------------
; RESET VECTOR
;------------------------------------------------------------------------------

RES_VECT  ORG     0x0000            ; processor reset vector
          GOTO    MAIN             ; go to beginning of program

;------------------------------------------------------------------------------
; HIGH PRIORITY INTERRUPT VECTOR
;------------------------------------------------------------------------------

ISRH      ORG     0x0008

          ; Run the High Priority Interrupt Service Routine
          GOTO    HIGH_ISR             

;------------------------------------------------------------------------------
; LOW PRIORITY INTERRUPT VECTOR
;------------------------------------------------------------------------------

ISRL      ORG     0x0018
          
          ; Run the High Priority Interrupt Service Routine
          GOTO    LOW_ISR             

;------------------------------------------------------------------------------
; HIGH PRIORITY INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------

HIGH_ISR  

          ; Insert High Priority ISR Here

          RETFIE  FAST

;------------------------------------------------------------------------------
; LOW PRIORITY INTERRUPT SERVICE ROUTINE
;------------------------------------------------------------------------------

LOW_ISR
          ; Context Saving for Low ISR

          RETFIE

;------------------------------------------------------------------------------
; MAIN PROGRAM
;------------------------------------------------------------------------------

MAIN
	
	;rcall		sub1	;Addition	z_a += z_b
	;rcall		sub2	;Subtraction	z_b -= z_a
	
        ; end of program
        goto    $               ; infinite loop	
	
	
	
	;initializaion
sub0:	
	movlw		ZA_0
	movwf		za_0
	movlw		ZA_1
	movwf		za_1
	movlw		ZA_2
	movwf		za_2
	movlw		ZA_3
	movwf		za_3
	
	movlw		ZB_0
	movwf		zb_0
	movlw		ZB_1
	movwf		zb_1
	movlw		ZB_2
	movwf		zb_2
	movlw		ZB_3
	movwf		zb_3
	
	return
	
	;function to add zahl_a to zahl_b
sub1:	
	rcall		sub0	    ;initialize variables
	lfsr		0, za_0
	lfsr		1, zb_0
	lfsr		2, za_3
	
	movf		INDF0,w
	addwf		POSTINC1,w
	movwf		POSTINC0
	
Addition:
	movf		INDF0,w
	addwfc		POSTINC1,w
	movwf		POSTINC0
	movf		FSR0L,w
	cpfslt		FSR2L
	bra		Addition
	
	return
	
	;function to subtract zahl_a from zahl_b
sub2:	
	rcall		sub0	    ;initialize variables 
	lfsr		0,za_0
	lfsr		1,zb_0
	lfsr		2,za_3
	
	movf		POSTINC0,w
	subwf		POSTINC1,f
	
Subtraction:
	movf		POSTINC0,w
	subwfb		POSTINC1,f
	movf		FSR0L,w
	cpfslt		FSR2L
	bra		Subtraction
	
	return
	


          END