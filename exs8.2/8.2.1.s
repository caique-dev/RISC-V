.globl swap_char
.globl swap_short
.globl swap_int

swap_int:
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    li a0, 0
    ret

swap_short:
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    li a0, 0
    ret

swap_char:
    lw t0, (a0)
    lw t1, (a1)
    sw t1, (a0)
    sw t0, (a1)
    li a0, 0
    ret

