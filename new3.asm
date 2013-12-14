
extern printf

sectio .data                   ;neiction declaration

        prompt1 db "Credit Score? "
        len1 equ $ - prompt1                  ;length of our dear string
        prompt2 db "Continue? "
        len2 equ $ - prompt2
	prompt3 db "Home Value? "
        len3 equ $ - prompt3                  ;length of our dear string
        prompt4 db "Loan Amount? "
        len4 equ $ - prompt4
	prompt5 db "Loan Purpose? "
        len5 equ $ - prompt5                  ;length of our dear string
        prompt6 db "Loan Term? "
        len6 equ $ - prompt6
	prompt7 db "Balance Left? "
        len7 equ $ - prompt7                  ;length of our dear string
        prompt8 db "Start Date? "
        len8 equ $ - prompt8
	prompt9 db "New Loan Term Left? "
        len9 equ $ - prompt9                  ;length of our dear string
        prompt10 db "New Start Date? "
        len10 equ $ - prompt10


        printmessage11 db "1-Excelent, 2-Good, 3-Fair, 4-Poor: %d", 10,0
        len11 equ $ - printmessage11
	printmessage12 db "1-Yes, 2- No: %d", 10,0
        len12 equ $ - printmessage12
	printmessage13 db "1-New Purchase, 2-Refinance: %d", 10,0
        len13 equ $ - printmessage13
	printmessage14 db "1-30yrs, 2-20yrs, 3-15yrs, 4-10yrs: %d", 10,0
        len14 equ $ - printmessage14
	printmessage15 db "Mortgage Repayment Summary: %d", 10,0
        len15 equ $ - printmessage15
	printmessage16 db "Balance Left?: %d", 10,0
        len16 equ $ - printmessage16
	printmessage17 db "New Loan Term Left?: %d", 10,0
        len17 equ $ - printmessage17
	printmessage18 db "End of Caculation?: %d", 10,0
        len18 equ $ - printmessage18





        fmt: db 10, "hello %d"
section .bss
        short1: resb 4
        input1: resb 255                ;take in a string of at most 255
        len3: equ $ - input1
        input2: resb 255          ;take in a string of at most 255
        len4: equ $ - input2
        lenString: resb 4
        len5: equ $ - lenString
        lenString2: resb 4
        len6: equ $ - lenString2

;extern printf

section .text

global _start

_start:
        ;;  Print question
        mov eax, 4
        mov ebx, 1
        mov ecx, prompt1
        mov edx, len1
        int 0x80

        ;nput1; Get input
        mov eax, 3
        mov ebx, 0
        mov ecx, input1
        mov edx, len3
        int 0x80
	
	mov [lenString], eax
        ;jmp testPrint

        ;; Print to screen
        mov eax, 4
        mov ebx, 1
        mov ecx, prompt2
        mov edx, len2
        int 0x80

        ;; Prompt for input
        mov eax, 3
        mov ebx, 0
        mov ecx, input2
        mov edx, len4
        int 0x80

        mov [lenString2], eax
        ;mov eax, [lenString]
        ;mov ebx, [lenString2]
        ;jmp finalmessage
        jmp compare

compare:
        ;looks for the shortest string
        mov eax, [lenString2]
        cmp [lenString], eax
        jg move1
        mov eax, [lenString]
        mov [short1], eax
        jmp next

move1:

        mov [short1], eax

next:
        ;initializes all the variables, counters, registers that we will use
        mov esi, input1
        mov edi, input2
        mov bh, [short1]
        mov ch, 8 ;counter for the bits
        mov ecx, 0 ; counter
        ;jmp finalmessage
 mov [lenString], eax
        ;jmp testPrint

        ;; Print to screen
        mov eax, 4
        mov ebx, 1
        mov ecx, prompt2
        mov edx, len2
        int 0x80

        ;; Prompt for input
        mov eax, 3
        mov ebx, 0
        mov ecx, input2
        mov edx, len4
 mov [lenString], eax
        ;jmp testPrint

        ;; Print to screen
        mov eax, 4
        mov ebx, 1
        mov ecx, prompt2
        mov edx, len2
        int 0x80

        ;; Prompt for input
        mov eax, 3
        mov ebx, 0
        mov ecx, input2
        mov edx, len4
        int 0x80

        mov [lenString2], eax
        ;mov eax, [lenString]
        ;mov ebx, [lenString2]
        ;jmp finalmessage
        jmp compare

compare:
        ;looks for the shortest string
        mov eax, [lenString2]
        cmp [lenString], eax
        jg move1
        mov eax, [lenString]
        mov [short1], eax
        jmp next

move1:

        mov [short1], eax

next:
        ;initializes all the variables, counters, registers that we will use
        mov esi, input1
        mov edi, input2
        mov bh, [short1]
        mov ch, 8 ;counter for the bits
        mov ecx, 0 ; counter
        ;jmp finalmessage
        jmp loop
loop:

        mov ah, [esi]

        mov al, [edi]

        inc esi ; shift the part of string
        inc edi ; shift part of string2
        xor ah, al ;xor to find bits that are different
        dec bh
        cmp bh, 0
        ;jmp finalmessage
        jne analyze ;look throuugh the register at each bit
        jmp finalmessage ;end program

analyze:
        ;decrease counter for bits until the end
        dec ch
        shr ah, 1

        jnc move4 ;if the carry is not there then do nothing
        inc ecx ;increase the counter
        jmp endgame

move4:
        ;inc ecx
        ;jmp finalmessage
        jmp endgame ;end of the loop

endgame:
        ;compare
        cmp ch, -1
        jne analyze
        jmp loop

finalmessage:
        sub ecx, 65279
        push ecx
        push dword printmessage
        call printf
        add esp, byte 8
	
	
	jmp exitJmp

exitJmp:

        mov eax,1       ;system call number (sys_exit)
        xor ebx,ebx     ;first syscall argument: exit code

        int 0x80        ;call kernel

