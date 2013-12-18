; Names: Jonathan Peevy, Natalie Morningstar, Bruce Oshokoya
; Date: December 10, 2013
; Course: CMPE-310
; Assignment: Lab 4
; Version: 5
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
%define ENTR_VAL	2
%define ENTR_TERM	3
%define ENTR_DATE	4
%define	ENTR_PURP	5
%define FINAL		6
			
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
		
		cmp byte[state], CRED_MENU
		jne IR_ACC
		call DISP_IR_MENU
		mov byte[state], IR_ACCEPT
		jmp EXIT
IR_ACC:	cmp byte[state], IR_ACCEPT
		jne VAL
		call DISP_VAL
		mov byte[state], ENTR_VAL
		jmp EXIT
VAL:	cmp byte[state], ENTR_VAL
		jne TERM
		call DISP_TERM
		mov byte[state], ENTR_TERM
		jmp EXIT
TERM:	cmp byte[state], ENTR_TERM
		jne DATE
		call DISP_CRED_MENU
		mov byte[state], ENTR_DATE
		jmp EXIT
DATE:	cmp byte[state], ENTR_DATE
		jne PURP
		call DISP_DATE
		mov byte[state], ENTR_PURP
		jmp EXIT
PURP:	cmp byte[state], ENTR_PURP
		jne FINAL_
		call DISP_PURP
		mov byte[state], FINAL
		jmp EXIT
FINAL_:	cmp byte[state], FINAL
		jne EXIT
		call DISP_FINAL
		mov byte[state], CRED_MENU
EXIT:	
	
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

DISP_PURP:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, purp_menu 
	mov cx, purp_len 
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
	
DISP_DATE:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, date_menu 
	mov cx, date_len 
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
	
DISP_TERM:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, term_menu 
	mov cx, term_len 
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
	
DISP_VAL:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, val_menu 
	mov cx, val_len 
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
	
CALC_STATS:
	push ax
	push bx
	push cx
	push dx
	push si
	pushf

	;caculation
	mov al, [term]
	mov bx, [credit]
	sbb al  ;assume they give you 1-4
	mov cl, 5
	mul al, cl
	add ax, bx
	
		
	;get index
	mov bx, array1D
	add ax, bx
	mov al, [ax]
	
	;actual loan amount
	mov cl, [loan]
	mov bx, al
	shr ax, bx
	mov [mP], ax
	
	mov al, [value]
	mov bl, 175
	mul bl
	mov bl, 10000
	div bl
	mov bl, [mP]
	add al, bl
	mov [realMP], al
	
	mov al, [mP]
	mov bl, [term]
	mul bl
	mov bx, [value]
	sub ax, bx
	mov [intPaid], ax
	
	mov al, [value]
	mov bl, 125
	mul bl
	mov bl, 10000
	div bl
	mov [taxPaid], al
	
	mov al, [value]
	mov bl, 5
	mul bl
	mov bl, 10000
	div bl
	mov [mortIns], al
	
	mov al, [term]
	mov [numPay], al
	
	mov al, [date]
	mov bl, [term]
	add al, bl
	mov [payDate], al

	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	ret
	
DISP_FINAL:
;	pusha
	push ax
	push bx
	push cx
	push dx
	push si
	pushf
	mov ax, 0
	mov bx, final_disp
	mov cx, final_len
	mov dx, 0
	mov si, ds
	int 10H
	
	mov ax, [realMP]
	mov [number], ax
	call TOSTRING
	mov cx, bx
	lea si, strRes
	;more stuff
	
	popf
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
;	popa
	ret
	
TOSTRING:
	mov ax, [number]
	mov cx, 10
	xor bx,bx

DIVIDE:	
	xor dx, dx
	div cx
	push dx
	inc bx
	test ax, ax
	jnz DIVIDE
	
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
	
	ir_menu:	db "    Rate:           "
				db "     Continue?      "
				db "                    "
				db "   1-Yes    2-No    "
	ir_len:		equ $ - ir_menu
	
	val_menu:	db "Enter Value:        "
				db "                    "
				db "                    "
				db "                    "
	val_len:	equ $ - val_menu
	
	term_menu:	db "Enter Term:         "
				db "                    "
				db "                    "
				db "                    "
	term_len:	equ $ - term_menu
	
	date_menu:	db "Enter Date:         "
				db "                    "
				db "                    "
				db "                    "
	date_len:	equ $ - date_menu
	
	purp_menu:	db "Purpose?            "
				db "2-Refinance         "
				db "1-New Purchase      "
				db "                    "
	purp_len:	equ $ - purp_menu
	
	final_disp:	db "RealMP:             "
				db "IntPaid:            "
				db "TaxPaid:            "
				db "Payments:           "
	final_len:	equ $ - final_disp

	state:		db 0
	key_table:	db "01231XXX45672XXX89AB3XXXCDEF4" ; look up table
	char:		db 0
	array1D     db 3,3,3,2,4,3,3,2,4,4,3,2,5,4,3,2    ; 4 Rows by 4 Columns
	date:		db 0
	term:		db 0
	credit:		db 0
	value:		db 0
	loan:		db 0
	mP:			db 0
	realMP:		db 0
	intPaid:	dw 0
	taxPaid:	db 0
	mortIns:	db 0
	numPay:		db 0
	payDate:	db 0
	strRes:		db 16, dup (0)
	number:		db 0