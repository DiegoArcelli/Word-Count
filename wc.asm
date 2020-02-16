;implementation of word count shell command in assembly x86_64

section .data
    NULL equ 0
    LF equ 10
    SPACE_CHAR equ 32
    OPZ_CHAR equ 45
    L_CHAR equ 108
    M_CHAR equ 109
    W_CHAR equ 119
    SYS_READ equ 0
    SYS_WRITE equ 1
    SYS_OPEN equ 2
    SYS_CLOSE equ 3
    SYS_EXIT equ 60
    O_RDONLY equ 000000q
    BUFF_SIZE equ 65536
    STDOUT equ 1
    EXIT_SUCCESS equ 0
    fileDesc dq 0
    newLine db LF,NULL
    spaceLine db SPACE_CHAR,NULL
    lineOpt db "-l"
    charOpt db "-m"
    wordOpt db "-w"
    lineOptFlag db 0
    charOptFlag db 0
    wordOptFlag db 0
    linesNum dq 0
    charsNum dq 0
    wordsNum dq 0
    fileName dq NULL

section .bss
    readBuffer resb BUFF_SIZE
    numberToPrint dq BUFF_SIZE

section .text
    global main
    global printString
    global checkArgs
    global countChars
    global countWords
    global CountsLine
    global copyFileName
    global printNumber



;function that print the number inside the rdi register
printNumber:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rcx,1
findDivisorLoop:
    mov rdx,0
    mov rax,rbx
    div rcx
    cmp rax,0
    je findDivisorLoopDone
    imul rcx,10
    jmp findDivisorLoop
findDivisorLoopDone:
    mov rax,0
    mov rax,rcx
    mov rdx,0
    mov rsi,10
    div rsi
    mov rsi,rax ;rsi contains the highest divisor
    mov rcx,numberToPrint ;rcx point to the array that will be load with the characters to print
printNumberLoop:
    cmp rsi,0 ;if the divisor is 0 end
    je printNumberLoopDone
    mov rax,rbx
    mov rdx,0
    div rsi
    add rax,48
    mov qword[rcx],rax
    inc rcx
    ;get the new number
    add rax,-48
    mov r10,rax
    mov rax,rbx
    imul r10,rsi
    sub rax,r10
    mov rbx,rax
    mov rax,0
    mov rdx,0
    mov rax,rsi
    mov rsi,10
    div rsi
    mov rsi,rax
    jmp printNumberLoop
printNumberLoopDone:
    mov qword[rcx],NULL
    pop rbx
    pop rbp
    ret





;function that copies the string inside the rdi register
copyFileName:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
    mov rcx,fileName
copyLoop:
    mov al,byte[rbx]
    mov byte[rcx],al
    cmp al,NULL
    je copyLoopDone
    inc rdx
    inc rbx
    inc rcx
    jmp copyLoop
copyLoopDone:
    pop rbx
    pop rbp
    ret





;function that counts the number of characters inside the rdi register 
countChars:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
countCharsLoop:
    cmp byte[rbx],NULL
    je countCharsLoopDone
    inc rdx
    inc rbx
    jmp countCharsLoop
countCharsLoopDone:
    mov rax,rdx
    pop rbx
    pop rbp  
    ret




;function that counts the number of words inside the rdi register 
countWords:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
countWordsLoop:
    cmp byte[rbx],NULL
    mov cl,byte[rbx]
    je countWordsLoopDone
    cmp byte[rbx],SPACE_CHAR
    je wordFound
    cmp byte[rbx],LF
    je wordFound
wordsAhead: 
    inc rbx
    jmp countWordsLoop
countWordsLoopDone:
    mov rax,rdx
    pop rbx
    pop rbp  
    ret
wordFound:
    inc rdx
    jmp wordsAhead




;function that counts the number of lines inside the rdi register 
countLines:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
countLinesLoop:
    cmp byte[rbx],NULL
    mov cl,byte[rbx]
    je countLinesLoopDone
    cmp byte[rbx],LF
    je lineFound
linesAhead: 
    inc rbx
    jmp countLinesLoop
countLinesLoopDone:
    mov rax,rdx
    pop rbx
    pop rbp  
    ret
lineFound:
    inc rdx
    jmp linesAhead




;print the string contained in the rdi register
printString:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
strCountLoop:
    cmp byte[rbx],NULL
    mov cl,byte[rbx]
    je strCountDone
    inc rdx
    inc rbx
    jmp strCountLoop
strCountDone:
    cmp rdx,0
    je prtDone
    mov rax,SYS_WRITE
    mov rsi,rdi
    mov rdi,STDOUT
    syscall
prtDone:
    pop rbx
    pop rbp
    ret



;check the command line arguments
checkArgs:
    push rbp
    mov rbp,rsp
    push rbx
    mov rbx,rdi
    mov rdx,0
checkArgsLoop:
    cmp byte[rbx],NULL
    je checkArgsLoopDone
    cmp byte[rbx],OPZ_CHAR
    je optionFound
checkDone:
    inc rdx
    inc rbx
    jmp checkArgsLoop
checkArgsLoopDone:
    cmp rdx,0
    je argsDone
argsDone:
    pop rbx
    pop rbp
    ret
optionFound:
    mov r9,rbx
    inc r9
    cmp byte[r9],L_CHAR
    je activeLineOption
    cmp byte[r9],W_CHAR
    je activeWordOption
    cmp byte[r9],M_CHAR
    je activeCharOption
    jmp checkDone
activeLineOption:
    mov byte[lineOptFlag],1
    jmp checkDone
activeWordOption:
    mov byte[wordOptFlag],1
    jmp checkDone
activeCharOption:
    mov byte[charOptFlag],1
    jmp checkDone
activeAll:
    mov byte[charOptFlag],1
    mov byte[wordOptFlag],1
    mov byte[lineOptFlag],1
    jmp activeAllEnd



;main function
main:
    mov r12, rdi
    mov r13, rsi
    ; mov rdi,newLine
    ; call printString
    ;the r13 register contains the arguments while the r12 registers contains the number of arguments
    mov rbx,0
    ;puts in rdi register the string to print on the terminal
    mov rdi,spaceLine
    call printString
readArgsLoop:
    mov rdi,qword[r13+rbx*8]
    call checkArgs
    inc rbx
    cmp rbx,r12
    jl readArgsLoop

    dec r12
    mov rdi,qword[r13+r12*8]
    call copyFileName

    mov rax,SYS_OPEN
    mov rdi,fileName
    mov rsi,O_RDONLY
    syscall

    cmp rax,0
    mov qword[fileDesc],rax
    mov rax,SYS_READ
    mov rdi,qword[fileDesc]
    mov rsi,readBuffer
    mov rdx,BUFF_SIZE
    syscall

activeAllEnd:
    mov r12,0
    mov r13,0
    mov r14,0
    mov r15,0
    mov r13b,byte[lineOptFlag]
    mov r14b,byte[wordOptFlag]
    mov r15b,byte[charOptFlag]
    add r12b,byte[lineOptFlag]
    add r12b,byte[lineOptFlag]
    add r12b,byte[wordOptFlag]
    cmp r12b,0
    je activeAll
    cmp r13b,1
    je callLineCount
callLineCountEnd:
    cmp r14b,1
    je callWordCount
callWordCountEnd:
    cmp r15b,1
    je callCharCount
callCharCountEnd:
    mov rdi,fileName
    call printString
    mov rdi,newLine
    call printString
    jmp end

callLineCount:
    mov rdi,readBuffer
    call countLines
    mov rdi,rax
    call printNumber
    mov rdi,numberToPrint
    call printString
    mov rdi,spaceLine
    call printString
    jmp callLineCountEnd
callWordCount:
    mov rdi,readBuffer
    call countWords
    mov rdi,rax
    call printNumber
    mov rdi,numberToPrint
    call printString
    mov rdi,spaceLine
    call printString
    jmp callWordCountEnd
callCharCount:
    mov rdi,readBuffer
    call countChars
    mov rdi,rax
    call printNumber
    mov rdi,numberToPrint
    call printString
    mov rdi,spaceLine
    call printString
    jmp callCharCountEnd

end:
    mov rax,SYS_CLOSE
    mov rdi,qword[fileDesc]
    syscall
    mov rax,SYS_EXIT
    mov rdi,EXIT_SUCCESS
    syscall