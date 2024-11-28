# recebendo numero procurado
entrada:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, input #  buffer to write the data
    li a2, 12  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

tratando_entrada:
    la a0, input
    jal str2int

    la a2, target_num
    sw a0, (a2)
    sw a1, 4(a2)
    

busca:
    la a0, head_node
    lw a1, target_num # inteiro desejado
    li a2, 0 # contador

    loop_busca:
        lw t0, 0(a0)
        lw t1, 4(a0)
        add t0, t0, t1

        # verificando se a soma bate
        beq t0, a1, resultado_busca

        # nao encontrou ainda
        lw a0, 8(a0) # a0 aponta para o prox no
        addi a2, a2, 1 # incremento

        beqz a0, busca_falhou

    j loop_busca

    resultado_busca:
        mv a0, a2
    
    j convertendo_saida
    busca_falhou:
        # node nao encontrado
    la t1, out_vet
    li t3, '-'
    sb t3, (t1)
    addi t1, t1, 1

    li t3, '1'
    sb t3, (t1)
    addi t1, t1, 1

    li t3, '\n'
    sb t3, (t1)

    li a0, 1
    la a1, out_vet
    li a2, 3
    li a7, 64 # syscall write (64)
    ecall
    j exit

convertendo_saida:
    # empilhando a0
    addi sp, sp, -4
    sw a0, (sp)

    # convertendo resultado busca pra str
    mv a0, sp # end do numero
    la t0, target_num
    la a2, out_vet
    jal int2str

print:    
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, out_vet       # buffer
    lw a2, 4(a1)           # size
    li a7, 64           # syscall write (64)
    ecall

# exit
exit:
    li a0, 0
    li a7, 93
    ecall

# a0 end do str
str2int:
    mv t0, a0
    la t1, vet_aux
    li t3, 0 # contador de dígitos
    li t6, 1 # fator de correcao sinal

    testando_sinal:
        lbu t2, 0(t0)

        li t4, '-'
        bne t2, t4, loop_b_num

        # numero negativo
        li t6, -1
        addi t0, t0, 1

    loop_b_num:
        lbu t2, 0(t0)

        li t4, ' '
        beq t2, t4, conversao

        li t4, '\n'
        beq t2, t4, conversao
        
        add t2, t2, -'0'

        sb t2, (t1)

        addi t0, t0, 1
        addi t1, t1, 1
        addi t3, t3, 1 # encontrou +1 byte numerico
    j loop_b_num


    conversao:
        addi sp, sp, -4
        sw t3, (sp)
        mv t2, t3
        li t4, 1 # potencia
        li t5, 10
        li t3, 1

        beq t2, t3, passando_pra_inteiro
        li t3, 2
        1:
            mul t4, t4, t5
            addi t2, t2, -1
        bge t2, t3, 1b
        
        passando_pra_inteiro:
            la t1, vet_aux
            li t5, 10

            li t2, 0 # acumulador

            1:
                lbu t3, (t1)
                
                mul t3, t3, t4
                div t4, t4, t5

                add t2, t2, t3
                addi t1, t1, 1
            bnez t4, 1b

        resultado_conversao:
            mul t2, t2, t6 # atribuindo sinal
            mv a0, t2
            lw a1, (sp)
            add sp, sp, 4
            ret

# a0 end do int
# a2 end de arm
int2str:
    mv t0, a0
    mv t1, a2

    conversao_str:
        mv t1, a2
        lw t2, (t0)
        li t5, 10

        # verificando range do resultado
        li t4, 100
        bge t2, t4, _3dig

        li t4, 10
        bge t2, t4, _2dig

        _1dig:
            li a3, 2
            addi t2, t2, '0'
            sb t2, (t1)

        j retorno_int2str
        _2dig:
            li a3, 3
            li t3, 10

            # dig mais sig
            divu t4, t2, t3
            addi t4, t4, '0'
            sb t4, (t1)
            addi t1, t1, 1
            
            remu t2, t2, t3
            divu t3, t3, t5

            # dig menos sig
            divu t4, t2, t3
            addi t4, t4, '0'
            sb t4, (t1)

        j retorno_int2str
        _3dig:
            li a3, 4
            li t3, 100

            # dig mais sig
            divu t4, t2, t3
            addi t4, t4, '0'
            sb t4, (t1)
            addi t1, t1, 1
            
            remu t2, t2, t3
            divu t3, t3, t5

            # dig meio
            divu t4, t2, t3
            addi t4, t4, '0'
            sb t4, (t1)
            addi t1, t1, 1
            
            remu t2, t2, t3
            divu t3, t3, t5

            # dig menos sig
            divu t4, t2, t3
            addi t4, t4, '0'
            sb t4, (t1)

    retorno_int2str:
        addi t1, t1, 1
        li t5, '\n'
        sb t5, (t1)
        
        sw a3, 4(a2)

        ret


    

    


.bss
input: .word 0
target_num: .word 0,0
vet_aux: .word 0,0
out_vet: .word 0,0
