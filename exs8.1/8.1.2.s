.globl my_function

my_function:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw a2, 8(sp)
    sw a1, 4(sp)
    sw a0, (sp)

    add a0, a0, a1
    lw a1, (sp)
    jal mystery_function # CALL 1

    lw t1, 4(sp)
    sub t1, t1, a0
    
    lw t2, 8(sp)
    add a0, t1, t2 # aux

    add sp, sp, -4
    sw a0, (sp)

    lw a1, 8(sp) # b
    jal mystery_function # mystery_function(aux, b)

    lw t1, 12(sp)
    sub t3, t1, a0 # c - mystery_function(aux, b)

    lw a0, (sp) # aux
    add a0, a0, t3
    lw ra, 16(sp)
    addi sp, sp, 20
    ret




    