.globl operation

operation:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw fp, 0(sp)

    addi fp, sp, 8
    addi sp, sp, -24


    # empilhando a's
    sw a5, 0(sp)
    sw a4, 4(sp)
    sw a3, 8(sp)
    sw a2, 12(sp)
    sw a1, 16(sp)
    sw a0, 20(sp)

    # desempilhando valores anteriores
    mv t0, a7
    mv a7, a6
    mv a6, t0
    lw a5, 0(fp)
    lw a4, 4(fp) # fp -> parâmetros da pilha anterior
    lw a3, 8(fp)
    lw a2, 12(fp)
    lw a1, 16(fp)
    lw a0, 20(fp)

    jal mystery_function

    addi sp, sp, 24

    lw ra, 4(sp)
    lw fp, 0(sp)
    addi sp, sp, 8

    ret