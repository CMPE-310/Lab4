
extern printf
BITS 16
8086
section .data                   ;section declaration
	array1D     db 3,3,3,2,4,3,3,2,4,4,3,2,5,4,3,2    ; 4 Rows by 4 Columns
	
	printmessage db "monthly payment:" mP, 10,0
        len equ $ - printmessage
	
	section .bss
        short1: resb 4
        input1: resb 255                ;take in a string of at most 255
        len3: equ $ - input1
        input2: resb 255          ;take in a string of at most 255
        len4: equ $ - input2
        credit: resb 4
        len5: equ $ - credit
        term: resb 4
        len6: equ $ - term
		loan: resb 4
        len7: equ $ - loan
        mP: resb 4
        len8: equ $ - mP

;extern printf

section .text

global _start

_start:
		;input1; Get credit(1-4)
        mov al, 3
        mov bl, 0
        mov cx, input1
        mov dx, len3
        int 0x80    ;cant use int i think so take it out
		
		mov ax, [input1]
		mov [credit], ax 
		
		;input1; Get term
        mov ax, 3
        mov bx, 0
        mov cx, input2
        mov dx, len4
        int 0x80
		
		mov ax, [input2]
		mov [term], ax 
		
		;input1; Get loan
        mov ax, 3
        mov bx, 0
        mov cx, input1
        mov dx, len3
        int 0x80
		
		mov ax, [input1]
		mov [loan], ax 
		
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
	
	jmp finalmessage
	
	finalmessage:   ;cant use C take it out
        
        push dword printmessage
        call printf
        add esp, byte 8
		
	jmp exitJmp
	
	exitJmp:

        mov eax,1       ;system call number (sys_exit)
        xor ebx,ebx     ;first sys call argument: exit code

        int 0x80        ;call kernel			