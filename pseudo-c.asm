section .rodata
    L1 db "Hello world",0
    E1 equ $ - L1

    L2 db "Signal SIGINT Recieved",0x0A,0
    E2 equ $ - L2

    sigsegv db "Signal SIGSEGV recieved",0x0A,0
    siglen equ $ - sigsegv

    fname db "libasm3.so",0

section .text
    global _start
    
_start:

    xor rbp,rbp
    and rsp,-16
    xor rbx,rbx
    xor r9,r9
    xor rdi,rdi
    xor rsi,rsi
    
    sub rsp,128
    
    mov dword [rsp],handler
    mov qword [rsp + 8],0x10000000 | 0x04000000
    mov dword [rsp + 16],restorer
    mov qword [rsp + 128],0

    mov rbx,rsp

    mov rax,13
    mov rdi,11
    lea rsi,[rbx]
    xor rdx,rdx
    mov r10,8
    syscall

    pop rbx
    xor rbx,rbx
    push rbx
    
    sub rsp,128

    mov dword [rsp],sigint_handler
    mov qword [rsp + 8],0x10000000 | 0x04000000
    mov dword [rsp + 16],restorer
    mov qword [rsp + 128],0

    mov rbx,rsp

    mov rax,13
    mov rdi,2
    lea rsi,[rbx]
    xor rdx,rdx
    mov r10,8
    syscall

    pop rbx

    mov rax,21
    lea rdi,[rel fname]
    mov rsi,7
    syscall

    push rbp
    mov rbp,rsp
    sub rsp,8

    call main
    
    leave
    mov rdi,rax
    mov rax,60
    syscall

sigint_handler:

    mov rax,1
    mov rdi,1
    lea rsi,[rel L2]
    mov rdx,E2
    syscall
    
    mov rax,60
    mov rdi,11
    syscall

handler:
    
    mov rax,1
    mov rdi,1
    lea rsi,[rel sigsegv]
    mov rdx,siglen
    syscall

    mov rax,60
    mov rdi,1
    syscall

restorer:

    mov rax,15
    xor rdi,rdi
    syscall

;-----main----

main:

    push rbp
    mov rbp,rsp
    sub rsp,1024
    
    mov rdi,100
    call itoa

    mov rbx,rax

    mov rdi,rax
    call strlen

    mov rcx,rax

    mov rax,1
    mov rdi,1
    lea rsi,[rbx]
    mov rdx,rcx
    syscall
    
    mov rax,0
    leave
    ret

;------ function------

strlen:

    push rbp
    mov rbp,rsp
    push rdi
    push rsi
    push rcx
    xor rax,rax

    test rdi, rdi
    jz .null_pointer

.strlen:

    cmp byte [rdi + rax],0
    je .done
    inc rax
    jmp .strlen

.done:
    pop rsi
    pop rcx
    pop rdi
    leave
    ret

.null_pointer:
    mov rax, -1
    pop rsi
    pop rcx
    pop rdi
    leave
    ret

fflush:
    push rbp
    mov rbp, rsp

    test rdi, rdi
    jz .error
    test rsi, rsi
    jz .error

    mov rax, 1
    mov rdx, rsi
    mov rsi, rdi
    mov rdi, 1
    syscall

    jmp .done

.error:
    mov eax, -1

.done:
    pop rbp
    ret


strcpy:
    
    push rbp
    mov rbp,rsp
    push rdi
    push rsi
    
.strcpy:

    mov al,[rdi]
    mov [rsi],al
    cmp al,0
    jz .done
    cmp al,0x0A
    jz .done
    inc rdi
    inc rsi
    jmp .strcpy

.done:

    pop rdi
    pop rsi
    leave
    ret

itoa:

    push rbp
    mov rbp,rsp
    sub rsp,8
    push rdi
    push rsi
    push rcx
    
    xor rax,rax
    
    xchg rax,rdi

    lea rdi,[rbp -1]
    mov byte [rdi],0
    
    mov rcx,10

.itoa:

    xor rdx,rdx
    div rcx
    dec rdi
    add dl,'0'
    mov [rdi],dl

    test rax,rax
    jnz .itoa

    mov rax,rdi
    pop rdi
    pop rsi
    pop rcx
    leave
    ret
