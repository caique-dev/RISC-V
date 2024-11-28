.globl node_creation

node_creation:
    addi sp, sp, -16
    sw ra, 12(sp)

    addi sp, sp, -16
    li t0, 30
    sw t0, (sp)

    li t0, 25
    sw t0, 4(sp)

    li t0, 64
    sw t0, 5(sp)

    li t0, -12
    sw t0, 6(sp)

    mv a0, sp
    jal mystery_function

    addi sp, sp, 16
    lw ra, 12(sp)
    addi sp, sp, 16

    ret