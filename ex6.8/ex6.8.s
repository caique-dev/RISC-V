.globl puts
.globl itoa
.globl atoi
.globl gets
.globl exit
.globl recursive_tree_search

# a0 node
# a1 valor buscado
recursive_tree_search:
    mv t0, a0
    li t6, 0 # profundidade
    li a3, 0 # encontrou o no

    # empilhando no atual
    addi sp, sp, -4
    sw a0, (sp)

    # emplilhando ra
    addi sp, sp, -4
    sw ra, (sp)
    
    # verificando node atual
    lw t1, (t0)
    beq t1, a1, node_encontrado

    # buscando na arvore a esquerda
    lw t1, 4(t0)
    beqz t1, 1f
    mv a0, t1
    jal recursive_tree_search
    bnez a3, node_encontrado

    # buscando na arvore a direita
    1:
        # recuperando no pai
        lw t0, 4(sp)

        lw t1, 8(t0)
        beqz t1, node_nao_encontrado
        mv a0, t1
        jal recursive_tree_search
        bnez a3, node_encontrado

    node_nao_encontrado:
        # desempilhando ra
        lw ra, (sp)
        addi sp, sp, 4

        # desempilhando no atual
        lw zero, (sp) # esse no nao importa mais
        addi sp, sp, 4

        li a3, 0

        li a0, 0

        ret

    node_encontrado:
        # desempilhando ra
        lw ra, (sp)
        addi sp, sp, 4

        # desempilhando no atual
        lw zero, (sp) # esse no nao importa mais
        addi sp, sp, 4

        li a3, 1

        addi t6, t6, 1
        mv a0, t6
        ret

# a0 recebe o int a ser convertido
# a1 recebe o end do vetor de destino
# a2 recebe a base do numero
itoa:
    mv t2, a1
    mv t0, a0
    addi t2, t2, -1 # alterando o ponteiro para facilitar o loop
    li t6, 0 # contador numero de digitos
    li a3, 0 # numero positivo(0)/negativo(1)

    # empilhando ponteiro do vet destino
    addi sp, sp, -16
    sw a1, (sp)
    
    # verificando o sinal para decimais
    addi t1, a2, -10 
    bnez t1, loop_itoa

    bgez t0, loop_itoa

    # menor que zero
    li a3, 1
    addi t2, t2, 1
    li t1, '-'
    sb t1, (t2)

    # transformando em positivo
    li t1, -1
    mul t0, t0, t1

    # preenchendo o vetor
    loop_itoa: 
        addi t2, t2, 1

        # pegando o bit menos significativo
        remu t1, t0, a2

        # convertendo decimal
        addi t4, t1, '0'
        li t3, 0xa
        blt t1, t3, 1f

        # convertendo hexa
        addi t4, t1, 55

        1:
        # armazenando
        sb t4, (t2)

        # att t0
        divu t0, t0, a2

        # incrementando numero de digitos
        addi t6, t6, 1
    bnez t0, loop_itoa

    inverte_vetor:
        add t0, a1, a3 # inicio do vetor
        
        add t2, t0, t6
        add t2, t2, -1 # fim do vetor
        mv a3, t2 # guardando fim do vetor

        inv_itoa:
            lbu t4, (t0)
            lbu t5, (t2) # guardando valor do final

            # inversao
            sb t5, (t0)
            sb t4, (t2)

            # att indices
            addi t0, t0, 1
            addi t2, t2, -1

        blt t0, t2, inv_itoa

    fim_itoa:
        sb zero, 1(a3)

        lw a0, (sp)
        addi sp, sp, 16
        
        ret

        





# a0 ponteiro para a string fonte
atoi:
    mv t0, a0
    li a1, 1 # indica num pos: 1 p numero positivo e -1 para número negativo
    li a2, 0 # indica se algum char numerico foi encontrado
    li t1, 0 # acumulador

    addi t0, t0, -1
    loop_d_atoi:
        addi t0, t0, 1
        lbu t2, (t0) # carregando o byte

        # verificando
        li t3, '-'
        sub t4, t3, t2
        bnez t4, verifica_d_atoi

        ## numero negativo
        li a1, -1
        j loop_d_atoi

        ## digito
        verifica_d_atoi:
            addi t2, t2, -'0'
            li t3, 0

            bge t2, t3, num_g_zero
            
            j num_exists
            num_g_zero:
                li t3, 10
                blt t2, t3, num_l_10
            
            j num_exists
            num_l_10: # numero encontrado
                li t3, 10
                mul t1, t1, t3
                add t1, t2, t1
                li a2, 1 # encontrou um dig num

            j loop_d_atoi
            num_exists:
                # dig atual nn e numero
                ## nn encontrou nenhum numerico ainda => repete o loop => a2==0
                ## ja encontrou algum numerico => retorna o valor encontrado
                bnez a2, fim_atoi
    j loop_d_atoi

    fim_atoi:
        mul t1, t1, a1
        mv a0, t1

        ret


# a0 ponteiro para a string de destino
gets:
    addi sp, sp, -16
    sw a0, (sp)

    mv t0, a0
    la t1, vet_aux
    
    1: # lendo terminal
        li a0, 0
        mv a1, t1
        li a2, 1
        li a7, 63
        ecall

        # verificando byte lido
        lbu t2, (t1)
        li t3, '\n'
        beq t2, t3, gets_fim_leitura

        # armazenando caracter lido
        sb t2, (t0)
        addi t0, t0, 1
    j 1b

    gets_fim_leitura:
        # adicionando \0
        sb zero, (t0)

        lw a0, (sp)
        addi sp, sp, 16

        ret

# a0 ponteiro para a string fonte
puts:
    mv t0, a0
    li t2, 0 # contador

    # contando numero de caracteres
    1:
        lbu t1, (t0)
        beqz t1, print_puts

        addi t0, t0, 1
        addi t2, t2, 1
    j 1b

    print_puts:
        li t1, '\n'
        sb t1, (t0) # subst o \0 pelo \n

        addi t2, t2, 1

        mv a1, a0
        li a0, 1
        mv a2, t2
        li a7, 64
        ecall

        li a0, 0
        ret

exit:
    li a0, 0
    li a7, 93
    ecall

.data
str_aux: .asciz "c"
# teste: 2004
teste2: .asciz "aoiii\n"

.bss
vet_aux: .word 0
vet_teste: .word 0,0
vteste2: .word 0,0