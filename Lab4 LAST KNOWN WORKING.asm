; Names: Jonathan Peevy, Natalie Morningstar, Bruce Oshokoya
; Date: December 10, 2013
; Course: CMPE-310
; Assignment: Lab 4
; Version: 3
;
; This version of the lab 4 program builds on the functionality of the v2 program, which was able to display a message to LCD, and
; included programming of 8279 interface and 8259A interrupt controller.
; Version 3 adds the functionality of interrupts from key presses.


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

%define LED		0xFFCC

; Define States
; -----------------------------------

%define CRED_MENU	0
%define IR_ACCEPT	1
			
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
 	
	cli				; Turn off interrupts
	
	; Program 8279 - Keyboard/Display Interface
	mov dx, KBD_CMD
	mov al, 00001001b		; Program Mode command byte. 000 prefix, 01 - 16 key system, 001 - decoded
	out dx, al
	mov al, 00111001b		; Clock command byte. 001 prefix, 11001 to divide CLK by 2.
	out dx, al
	
	; Program 8259A - Interrupt Controller
	mov dx, INT_A0
	mov al, 00010011b		; ICW-1. 0001 prefix, 0 - edge triggered, 0 - don't care, 1 - single, - ICW-4 not needed.
	out dx, al
	mov dx, INT_A1
	mov al, 00001000b		; ICW-2.
	out dx, al
	mov al, 00000001b		; ICW-4. 000 prefix, 0 - non-nested, 00 - no buffer (no slave units), 0 - normal EOI, 1 - 8086 mode.
	out dx, al
	mov al, 11111101b		; OCW-1. Set on all lines, except line IR1.
	out dx, al
	
	
	call KEYPAD_INIT
	
	; Setup up interrupt vector table
   	; -------------------------------
	;;; EXAMPLE, take this code out when not using interrupts. This loads two interrupt vectors at vectors 0x09 and 0x0A 
	
;	mov bx, 0
;	mov es, bx
 ;   mov bx, 8H * 4		;Interrupt vector table 0x08 base address
  ;  mov cx, INTR1		;INTR1 service routine
   ; mov [es:bx+4], cx		;offset
    ;mov [es:bx+6], cs		;current code segment
	
	mov cx, word 0
	mov es, cx
	mov [es:36], word INTR1
	mov [es:38], word cs
	
	mov bx, 8
W2:	mov cx, 0xFFFF
W1:	dec cx
	jnz W1
	dec bx
	jnz W2
	
	call DISP_CRED_MENU
	
	;; When using interrupts use the following instruction (jmp $) to sit in a busy loop, turn on interrupts before that
	sti
	jmp $
	
INTR1:
		mov DX, KBD_DAT
		in AL, DX
		;; Translate raw key press byte contained in AL to ASCII character 
		and AL, 00011111b ; Remove first three bits
		mov BX, key_table ; Move key table address location to BX
		XLATB ; Translate
	
		mov [char],al
		call DISP_CONF
		mov ax, 1
		mov bx, char
		mov cx, 1
		mov dx, 14
		mov si, ds
		int 10h
		
;		cmp byte[state], CRED_MENU
;		jne IR_ACC
;		call DISP_IR_MENU
;		mov byte[state], IR_ACCEPT
;		jmp EXIT
;IR_ACC:	cmp byte[state], IR_ACCEPT
;		jne EXIT
;		call DISP_CRED_MENU
;		mov byte[state], CRED_MENU
;		jmp EXIT
;EXIT:	
	
		mov AL, 0x20
		mov dx, INT_A0
		out dx, AL
		iret
	
KEYPAD_INIT:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, welcome 
	mov cx, len1 
	mov dx, 0
	mov si, ds
	int 10H
	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;	popa
	ret
	
DISP_CRED_MENU:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, crd_menu 
	mov cx, crd_len 
	mov dx, 0
	mov si, ds
	int 10H
	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;	popa
	ret
	
DISP_IR_MENU:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, ir_menu 
	mov cx, ir_len 
	mov dx, 0
	mov si, ds
	int 10H
	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;	popa
	ret
	
DISP_CONF:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, int_conf
	mov cx, int_len
	mov dx, 0
	mov si, ds
	int 10H
	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;	popa
	ret
	
	
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
; RAM data section, align at 16 byte boundary, 16-bit
; --------------------------------------------------------------------------------------------------------------------------	
;;; THIS IS YOUR DATA SEGMENT

section CONSTSEG USE16 ALIGN=16 CLASS=CONST

	welcome: 	db " Welcome to CMPE 310" 	; 20 characters per line
				db "     Fall '13       " 
				db "     Final Lab      "
				db " Mortgage Calculator" 	
	len1: 		equ $ - welcome
	
	crd_menu:	db "1 - Excellent       "
				db "3 - Fair            "
				db "2 - Good            "
				db "4 - Poor            "
	crd_len:	equ $ - crd_menu
	
	ir_menu:	db "   Interest Rate:   "
				db "     Continue?      "
				db "       0.02%        "
				db "   1-Yes    2-No    "
	ir_len:		equ $ - ir_menu
	
	int_conf:	db "Key Pressed:        "
				db "                    "
				db "                    "
				db "                    "
	int_len:	equ $ - int_conf

	state:		db 0
	key_table:	db "01231XXX45672XXX89AB3XXXCDEF4" ; look up table
	char:		db 0