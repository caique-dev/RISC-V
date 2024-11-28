.globl middle_value_int
.globl middle_value_short
.globl middle_value_char
.globl value_matrix

middle_value_int:
    srli a1, a1, 1
    slli a1, a1, 2
    add t0, a1, a0
    lw a0, (t0)

    ret

middle_value_short:
    srli a1, a1, 1
    slli a1, a1, 1
    add t0, a1, a0
    lw a0, (t0)

    ret

middle_value_char:
    srli a1, a1, 1
    add t0, a1, a0
    lw a0, (t0)

    ret

value_matrix:
    li t0, 42
    mul a1, a1, t0
    add a1, a1, a2
    slli a1, a1, 2
    add a1, a0, a1

    lw a0, (a1)

    ret
    
