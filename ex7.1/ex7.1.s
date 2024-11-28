.data
msg: .ascii "iterando\nfim_iter\n"
coord_alvo: .word 73, 1, -19

.text
.set BASE, 0xFFFF0100

inicio:
    # movimentando
    li s0, 40
    loop_z:
        li a0, -120
        jal volante

        jal anda_pra_frente
        li a0, 1
        jal sleeper
        addi s0, s0, -1
    bnez s0, loop_z

    li a0, -0
    jal volante
    jal anda_pra_frente
    li a0, 150
    jal sleeper
    jal para_de_andar

    j exit

# a0 angulo
volante:
    li t0, BASE
    addi t0, t0, 0x20

    sb a0, (t0) 
    ret


atualiza_distancias:
    addi sp, sp, -4
    sw ra, (sp)

    jal atualiza_coordenadas

    la a0, coordenadas
    la a1, coord_alvo
    la a2, distancias
    jal calcula_distancias

    lw ra, (sp)
    addi sp, sp, 4

    la t0, distancias

    lw a0, (t0)
    lw a1, 4(t0)
    lw a2, 8(t0)

    fim_att_dists:
        ret

# a0 pos inicial
# a1 pos final
# a2 distancias
calcula_distancias:
    # x
    lw t0, (a0)
    lw t1, (a1)

    sub t3, t1, t0
    sw t3, (a2)

    # y
    lw t0, 4(a0)
    lw t1, 4(a1)

    sub t3, t1, t0
    sw t3, 4(a2)

    # z
    lw t0, 8(a0)
    lw t1, 8(a1)

    sub t3, t1, t0
    sw t3, 8(a2)

    fim_calc_dist:
        ret

atualiza_coordenadas:
    li t0, BASE
    li t1, 1
    sb t1, (t0)

    1:
        lbu t1, (t0)
    bnez t1, 1b

    la t6, coordenadas
    addi t0, t0, 0x10

    lw t2, (t0) 
    sw t2, (t6) # coord x

    lw t2, 4(t0)
    sw t2, 4(t6) # coord y

    lw t2, 8(t0)
    sw t2, 8(t6) # coord z

    coord_att:
        ret

anda_pra_frente:
    li t0, BASE
    addi t0, t0, 0x21
    li t1, 1
    sb t1, (t0)
    ret

anda_pra_tras:
    li t0, BASE
    addi t0, t0, 0x21
    li t1, -1
    sb t1, (t0)
    ret

para_de_andar:
    # desliga motor
    li t0, BASE
    addi t0, t0, 0x21
    li t1, 0
    sb t1, (t0)

    # breve freada
    li t0, BASE
    addi t0, t0, 0x22

    li t1, 1
    sb t1, (t0)

    addi sp, sp, -4
    sw ra, (sp) 
    li a0, 1
    jal sleeper
    lw ra, (sp)
    addi sp, sp, 4

    li t0, BASE
    addi t0, t0, 0x22

    li t1, 0
    sb t1, (t0)
    ret
        
# a0 angulo da direcao
direcao:
    li t0, BASE
    addi t0, t0, 0x20

    sb a0, (t0)

# a0 tempo de pausa
sleeper:
    li t6, 500
    mul t6, a0, t6


    la a1, msg

    li a0, 1
    li a2, 9
    li a7, 64
    ecall

    1:
        addi t6, t6, -1
    bnez t6, 1b

    la a1, msg
    addi a1, a1, 9
    li a0, 1
    li a2, 9
    li a7, 64
    ecall

    ret

exit:
    li a0, 0
    li a7, 93
    ecall

.bss
coordenadas: .word 0,0,0
distancias: .word 0,0,0
