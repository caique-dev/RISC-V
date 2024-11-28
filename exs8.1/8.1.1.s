.globl increment_my_var
.globl my_var

.data
my_var: .word 10

.text
increment_my_var:
    la t1, my_var
    lw t0, (t1)
    addi t0, t0, 1
    sw t0, (t1)
    ret

