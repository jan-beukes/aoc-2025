%define SYS_READ  0
%define SYS_WRITE 1
%define SYS_OPEN  2
%define SYS_CLOSE 3
%define SYS_EXIT 60

%define TRUE  1
%define FALSE 0

%macro exit 1
    mov rdi, %1
    mov rax, SYS_EXIT
    syscall
%endmacro

section .text
global _start

; read file into file_buf
; No error checking at all
read_entire_file:
    mov rsi, 0
    mov rdx, 0
    mov rax, SYS_OPEN
    syscall

    push rax
    mov rdi, rax
    mov rsi, file_buf
    mov rdx, BUF_SIZE
    mov rax, SYS_READ
    syscall

    mov [file_size], rax

    pop rdi
    mov rax, SYS_CLOSE
    syscall

    mov rax, file_buf
    ret

abs_value:

print_int:
    push rbp
    mov rbp, rsp
    sub rsp, 16 ; print buffer
    
    mov byte [rbp-1], 10 ; LF
    mov byte [rbp-2], '0'

    mov rcx, 1 << 63
    test rdi, rcx
    jz .positive
    neg rdi
.positive:
    ; counter
    mov rcx, 1
    ; current value
    mov rax, rdi
    mov rdi, 10
.loop:
    inc rcx
    ; dividend in rax
    xor rdx, rdx
    div rdi
    ; convert remainder to char
    add rdx, '0'

    ; current byte
    mov rsi, rbp
    sub rsi, rcx
    mov byte [rsi], dl

    test rax, rax
    jnz .loop
;end

    mov rdi, 1
    mov rsi, rbp
    sub rsi, rcx
    mov rdx, rcx
    mov rax, SYS_WRITE
    syscall

    mov rsp, rbp
    pop rbp
    ret

; returns (rdi + rsi) mod 100
add_modulus:
    mov rax, rdi
    add rax, rsi
    mov rcx, 100
    cqo ; sign extend rax
    idiv rcx
    mov rax, rdx
    add rax, 100
    cqo
    idiv rcx
    mov rax, rdx
    ret

; solve
%define idx         [rbp-8]
%define dial        [rbp-16]
%define zero_count  [rbp-24]
%define click_count [rbp-32]
%define left        [rbp-36]
solve:
    push rbp
    mov rbp, rsp
    sub rsp, 36
    
    mov qword dial, 50
    mov qword zero_count, 0
    mov qword click_count, 0
    mov qword idx, 0
.loop:
    mov rdi, [file_size]
    dec rdi
    cmp idx, rdi
    jg .end

    mov rcx, idx
    mov dil, [file_buf+rcx]

    cmp dil, 'L'
    jne .right
    mov dword left, TRUE
    jmp .turn_dial
.right:
    cmp dil, 'R'
    jne .continue

    mov dword left, FALSE
.turn_dial:
    xor rax, rax

.parse_loop:
    xor rdx, rdx
    inc rcx
    mov dl, [file_buf+rcx]
    cmp dl, 10
    je .end_parse_loop

    sub dl, '0'
    imul rax, 10
    add rax, rdx

    jmp .parse_loop
.end_parse_loop:
    mov idx, rcx

    mov rdi, dial
    mov rsi, rax
    mov eax, left
    test eax, eax
    jz .add
    neg rsi
.add:
    push rsi
    push rdi
    call add_modulus
    mov rdx, dial
    mov dial, rax

; clicks
    pop rax
    pop rsi
    add rax, rsi

    xor rdi, rdi

; positive value => value / 100
; negative value => if dial = 0 then value / 100 else 1 + value / 100
    cmp rax, 0
    jg .positive

    neg rax
    test rdx, rdx
    jz .positive
    inc rdi
.positive:
    mov rcx, 100
    xor rdx, rdx
    div rcx
    add rax, rdi
    add click_count, rax

    cmp qword dial, 0
    jne .continue
    inc qword zero_count

.continue:
    inc dword idx
    jmp .loop

.end:
    ; print results
    mov rdi, 1
    mov rsi, part_one_msg
    mov rdx, part_one_msg_len
    mov rax, SYS_WRITE
    syscall
    mov rdi, zero_count
    call print_int

    mov rdi, 1
    mov rsi, part_two_msg
    mov rdx, part_two_msg_len
    mov rax, SYS_WRITE
    syscall
    mov rdi, click_count
    call print_int

    mov rsp, rbp
    pop rbp
    ret

_start:
    mov rdi, file_name
    call read_entire_file

    call solve

    exit 0

section .data
file_name db "input.txt", 0

part_one_msg db "part one: "
part_one_msg_len equ $ - part_one_msg
part_two_msg db "part two: "
part_two_msg_len equ $ - part_two_msg

BUF_SIZE equ 1024*1024
section .bss
file_buf  resb BUF_SIZE
file_size resq 1
