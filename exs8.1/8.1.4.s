.globl operation

operation:
    add a0, a1, a2 # b+c
    sub a0, a0, a5 # (b+c) - f
    add a0, a0, a7#((b+c) - f) + h

    #(((b+c) - f) + h) + k
    lw t0, 8(sp)
    add a0, a0, t0

    #((((b+c) - f) + h) + k) - m
    lw t0, 16(sp)
    sub a0, a0, t0

    ret

    
