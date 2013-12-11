; Names: Jonathan Peevy, Natalie Morningstar, Bruce Oshokoya
; Date: December 10, 2013
; Course: CMPE-310
; Assignment: Lab 4
;
; This version of the lab 4 program builds on the functionality of the v1 program, which was able to display a message to LCD.
; Version 2 adds the functionality of programming the programmable IC's (only the 8279 in the case of the trainer board.


; Force 16-bit code and 8086 instruction set
; ------------------------------------------
	
BITS 16
CPU 8086

; Keyboard Display Controller Port Addresses (example)
; ------------------------------------------	

%define	KBD_CMD 0xFFF2		;keyboard command register
%define KBD_DAT 0xFFF0		;keyboard data register
	
; Interrupt Controller Port addresses (example)
; -----------------------------------
	
%define INT_A0  0xFFF4 		;8259 A0=0
%define INT_A1  0XFFF6		;8259 A0=1
			
; --------------------------------------------------------------------------------------------------------------------------
; 															      			
; ROM code section, align at 16 byte boundary, 16-bit code 								      	
; Code segment: PROGRAM, relocate using loc86 AD option to 0xF0000 size is variable, burn at location 0x18000 in the Flash    
; Use loc86 BS option to put a jump from 0xFFFF0 (reset location) to the code segment, burn at location 0x1FFF8 in the Flash  
; 															      
; --------------------------------------------------------------------------------------------------------------------------
;;THIS IS YOUR CODE SEGMENT, don't change anything till the cli instruction

section PROGRAM USE16 ALIGN=16 CLASS=CODE
	
..start
 	
	;cli				; Turn off interrupts
	
	; Program 8279 - Keyboard/Display Interface
	mov al, 00111001b		; Clock command byte. 001 prefix, 11001 to divide CLK by 2.
	out KBD_CMD, al
	mov al, 00001001b		; Program Mode command byte. 000 prefix, 01 - 16 key system, 001 - decoded
	out KBD_CMD, al
	
	; Program 8259A - Interrupt Controller
	mov al, 00010010b		; ICW-1. 0001 prefix, 0 - edge triggered, 0 - don't care, 1 - single, - ICW-4 not needed.
	out INT_A0, al
	mov al, 00001000b		; ICW-2.
	out INT_A1, al
	
	;; When using interrupts use the following instruction (jmp $) to sit in a busy loop, turn on interrupts before that
	;; jmp $
	
KEYPAD_INIT:
	mov ax, 0
	mov bx, welcome 
	mov cx, len1 
	mov dx, 0
	mov si, ds
	int 10H

KEYPAD_CHANGE_1:	
	mov ax, 4
	mov bx, change_project1
	mov cx, 8 
	mov dx, 8
	mov si, ds 
	int 10H

mov ax, 65535
mov cx, 0

WAIT_LOOP_P1:	
	inc cx
	nop
	nop
	nop
	cmp	cx, ax	
	jne WAIT_LOOP_P1
	

mov ax, 65535
mov cx, 0

WAIT_LOOP_P2:	
	inc cx
	nop
	nop
	nop
	cmp	cx, ax	
	jne WAIT_LOOP_P2
		
KEYPAD_CHANGE_2:	
	mov ax, 4
	mov bx, change_project2
	mov cx, 8 
	mov dx, 8
	mov si, ds 
	int 10H

	mov ax, 65535
	mov cx, 0

WAIT_LOOP2_P1:	
	inc cx
	nop
	nop
	nop
	cmp	cx, ax	
	jne WAIT_LOOP2_P1

mov ax, 65535
mov cx, 0

WAIT_LOOP2_P2:	
	inc cx
	nop
	nop
	nop
	cmp	cx, ax	
	jne WAIT_LOOP2_P2
	
jmp KEYPAD_CHANGE_1
	
	
   	; Setup up interrupt vector table
   	; -------------------------------
	;;; EXAMPLE, take this code out when not using interrupts. This loads two interrupt vectors at vectors 0x09 and 0x0A 
	
    ;mov bx, 8H * 4		;Interrupt vector table 0x08 base address
    ;mov cx, INTR1		;INTR1 service routine
    ;mov [es:bx+4], cx		;offset
    ;mov [es:bx+6], cs		;current code segment
    ;mov cx, INTR2		;INTR2 service routine
    ;mov [es:bx+8], cx		;offset
    ;mov [es:bx+10], cs		;segment

; --------------------------------------------------------------------------------------------------------------------------
; 													      			
; RAM data section, align at 16 byte boundry, 16-bit
; --------------------------------------------------------------------------------------------------------------------------	
;;; THIS IS YOUR DATA SEGMENT

section CONSTSEG USE16 ALIGN=16 CLASS=CONST

	welcome: 	db " Welcome to CMPE 310" 	; 20 characters per line
				db "     Fall '13       " 
				db "     Final Lab      "
				db " Mortgage Calculator" 	
	len1: 		equ $ - welcome

	change_project1: db " Project"				;8 characters, displayed starting at character 12 (offset+1)
	change_project2: db " is fun "				;8 characters, displayed starting at character 12 (offset+1)
