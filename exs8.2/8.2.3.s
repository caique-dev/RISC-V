.globl fill_array_int
.globl fill_array_short
.globl fill_array_char

fill_array_int:
    addi sp, sp, -4
    sw ra, (sp)

    addi sp, sp, -400

    # preenchendo vetor
    li t0, 0
    li t1, 100
    1:
        li t3, 4
        mul t3, t0, t3
        add t3, sp, t3
        sw t0, (t3)

        addi t1, t1, -1
        addi t0, t0, 1
    bnez t1, 1b

    mv a0, sp
    jal mystery_function_int
    
    lw ra, 400(sp)
    addi sp, sp, 404
    ret

fill_array_short:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi sp, sp, -200

    # preenchendo vetor
    li t0, 0
    li t1, 100
    1:
        li t3, 2
        mul t3, t0, t3
        add t3, sp, t3
        sw t0, (t3)

        addi t1, t1, -1
        addi t0, t0, 1
    bnez t1, 1b

    mv a0, sp
    jal mystery_function_short
    
    addi sp, sp, 200
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

fill_array_char:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi sp, sp, -100

    # preenchendo vetor
    li t0, 0
    li t1, 100
    1:
        add t3, sp, t0
        sw t0, (t3)

        addi t1, t1, -1
        addi t0, t0, 1
    bnez t1, 1b

    mv a0, sp
    jal mystery_function_char

    addi sp, sp, 100
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

