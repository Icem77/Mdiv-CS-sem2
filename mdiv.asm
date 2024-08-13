global mdiv

; PURPOSE OF REGISTERS:
; - rdi: holds pointer to array with dividend
; - rsi: holds number of 64 bit blocks of dividend
; - rcx: holds 64 bit divisor
; - r8: used to iterate over dividend array
; - r9: used to hold flags:
;   * least significant bit is set if division was already performed
;   * second least significant bit is set if dividend is signed
;   * third least significant bit is set if divisor is signed
; - rdx, rax: used to carry out the division process

mdiv:
    ; Move divisor from rdx to use it for proper division
    mov rcx, rdx
    ; Clear r9 to hold flags
    xor r9, r9
    ; Check if divisor is negative or not
    test rcx, rcx
    jns .checkDividendSign
    ; Negate divisor and update divisor sign flag
    neg rcx
    add r9, 0x4
    
.checkDividendSign:
    ; Check if dividend is negative or not
    cmp qword [rdi + (rsi - 1) * 8], 0
    jns .prepare
    ; Negate dividend and update dividend sign flag
    add r9, 0x2

.loadR8:
    ; Set iterator (r8) to proper value to perform negation
    mov r8, rsi

.notDividend:
    ; Perform not operation on all 64 bit blocks of dividend
    not qword [rdi + (r8 - 1) * 8]
    ; Handle loop
    dec r8
    test r8, r8
    jnz .notDividend
    ; After this loop r8 is 0

.addOneToDividend:
    inc r8
    inc qword [rdi + (r8 - 1) * 8]
    ; Add one to the next block if carry occured
    jz .addOneToDividend

.prepare:
    ; Check if we jumped here just to negate array
    ; In this case r9 is -1 or 1, so after shr CF will be set
    shr r9, 1
    jc .end
    ; Set iterator (r8) to proper value to perform division
    mov r8, rsi
    ; Clear rdx for proper division
    xor edx, edx

.division:
    ; Divide next block
    mov rax, [rdi + (r8 - 1) * 8]
    div rcx
    ; Update result in array
    mov [rdi + (r8 - 1) * 8], rax
    ; Handle loop
    dec r8
    test r8, r8
    jnz .division
    ; After this loop r8 is 0
    ; Check if dividend was signed (dividend sign flag goes to CF)
    shr r9, 1
    jnc .checkResultSign
    ; negate remainder and move the sign flag to r8
    neg rdx
    inc r8 

.checkResultSign:
    ; Check if result should be negative
    sub r9, r8
    ; Negate result if dividend and divisor had different signs
    jnz .loadR8
    ; The only case of overflow in this division is when we divide -MAX by -1.
    ; The division algorithm will be executed properly but the result will not
    ; be written in Two's Complement System but Natural Binary Code, so the
    ; sign bit will be set although the result is positive
    cmp qword [rdi + (rsi - 1) * 8], 0
    jns .end
    ; Call overflow (if we got to execution of this line r9 is 0 after line 66)
    div r9

.end:
    ; Move remainder to rax to return it as a function's result
    mov rax, rdx
    ret