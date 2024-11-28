.globl puts
.globl itoa
.globl atoi
.globl gets
.globl exit
.globl reverse_str
.globl read

.data
msg: .ascii "123+456\0"

.text
.set WR_STS, 0xFFFF0100 # val 1 durante a escrita, val 0 quando ocioso
.set WR_DATA, 0xFFFF0101 # byte a ser escrito no stdout
.set RD_STS , 0xFFFF0102 # val 1 durante a leitura, val 0 quando ocioso
.set RD_DATA , 0xFFFF0103 # armazena byte lido
inicio:
    la a0, msg
    




    


    # lendo a operacao
    la a0, vet_aux
    jal read

    li t0, '1'
    lbu t1, (a0)
    bne t0, t1, 1f
    la a0, vet_aux
    jal read
    jal puts
    j exit

    1:
        li t0, '2'
        lbu t1, (a0)
        bne t0, t1, 1f
        la a0, vet_aux
        jal read
        jal reverse_str
    j exit

    1:
        li t0, '3'
        lbu t1, (a0)
        bne t0, t1, 1f
        la a0, vet_aux
        jal read
        jal atoi
        la a1, vet_aux
        li a2, 16
        jal itoa
        jal puts
    j exit

    1:
        li t0, '4'
        lbu t1, (a0)
        bne t0, t1, 1f
        la a0, vet_aux
        jal read

        lbu t0, (a0)

        addi t1, t0, -'-'
        beqz t1, 2f
        addi t1, t0, -'+'
        beqz t1, 2f

        # sem sinal no inicio
        la a0, vet_aux
        li a1, 0
        jal find_op

        j 3f
        # com sinal no inicio
        2:
        la a0, vet_aux
        li a1, 1
        jal find_op
        
        3:
        # colocando \n entre os números
        la t0, vet_aux
        add t0, t0, a0 
        sb zero, (t0)
        mv s0, a0 # pos \0 entre os numeros
        mv s1, a1 # operador

        # transformando em int
        la a0, vet_aux
        jal atoi
        mv s2, a0 # primeiro numero

        la a0, vet_aux
        addi a0, a0, 1
        add a0, a0, s0
        jal atoi
        mv s3, a0 # segundo numero

        # realizando a operacao
        li t0, '+'
        bne s1, t0, 4f
        add s0, s2, s3
        j resultado_op

        4:
        li t0, '-'
        bne s1, t0, 4f
        sub s0, s2, s3
        j resultado_op

        4:
        li t0, '*'
        bne s1, t0, 4f
        mul s0, s2, s3
        j resultado_op

        4:
        div s0, s2, s3
        j resultado_op

        resultado_op:
            mv a0, s0
            la a1, vet_aux
            li a2, 10
            jal itoa
            jal puts

    jal exit

# a0 str fonte
# a1 index inicial
find_op:
    mv t0, a0
    add t0, t0, a1
    addi t1, a1, -1

    1:
        addi t1, t1, 1
        
        lbu t2, (t0)
        beqz t2, not_found
        li t3, '+'
        beq t2, t3, fim_search
        li t3, '-'
        beq t2, t3, fim_search
        li t3, '*'
        beq t2, t3, fim_search
        li t3, '/'
        beq t2, t3, fim_search

        addi t0, t0, 1
    j 1b

    fim_search:
        add a0, a0, t1 
        lbu a1, (a0)
        mv a0, t1
        ret
    
    not_found:
        li a0, -1
        ret



# a0 str fonte
reverse_str:
    addi sp, sp, -8
    sw a0, 4(sp)
    sw ra, (sp)

    jal inverte_vetor
    lw a0, 4(sp)

    jal puts

    lw ra, (sp)
    addi sp, sp, 8

    ret

# a0 str fonte
conta_vetor:
    mv t0, a0
    li t2, 0 # contador

    # contando numero de caracteres
    1:
        lbu t1, (t0)
        beqz t1, fim_conta_vetor

        addi t0, t0, 1
        addi t2, t2, 1
    j 1b

    fim_conta_vetor:
        addi t2, t2, 1
        mv a0, t2
        ret

# a0 str fonte
inverte_vetor:
    addi sp, sp, -8
    sw a0, 4(sp)
    sw ra, (sp)

    jal conta_vetor
    mv t0, a0

    lw ra, (sp)
    lw a0, 4(sp)
    addi sp, sp, 8

    # invertendo
    mv t1, a0

    add t2, a0, t0
    addi t2, t2, -2 # fim do vetor

    1:
        lb t4, (t1)
        lb t5, (t2)

        sb t5, (t1)
        sb t4, (t2)

        addi t1, t1, 1
        addi t2, t2, -1
    blt t1, t2, 1b

    ff_inv:
    ret

    
# a0 vetor destino
read:
    # empilhando a0
    mv t6, a0

    # iniciando leitura
    ini_read:
        li t0, RD_STS
        li t1, 1
        sb t1, (t0)

        # esperando terminar leitura
        1:
            lbu t1, (t0)
        bnez t1, 1b

        # recuperando o valor lido
        dgb:
        li t0, RD_DATA
        lbu t1, (t0)

        # armazenando valor lido
        li t2, '\n'
        beq t1, t2, fim_read

        sb t1, (a0)
        addi a0, a0, 1

    j ini_read

    fim_read:
        sb zero, (a0)

        # recuperando a0
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

    # inverte_vetor:
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


# a0 ponteiro para a string fonte
puts:
    addi sp, sp, -8
    sw a0, 4(sp)
    sw ra, (sp)
    jal conta_vetor
    mv t2, a0

    print_puts:
        lw a0, 4(sp)
        add t0, a0, t2
        addi t0, t0, -1
        li t1, '\n'
        sb t1, (t0) # subst o \0 pelo \n
        
        1: # printando pela serial
            li t0, WR_DATA
            lbu t1, (a0)
            sb t1, (t0)

            addi a0, a0, 1
            addi t2, t2, -1
            
            li t0, WR_STS
            li t1, 1
            sb t1, (t0)

            # esperando terminar a escrita
            2:
                li t0, WR_STS
                lbu t1, (t0)
            bnez t1, 2b
        bnez t2, 1b

        li a0, 0
        lw ra, (sp)
        addi sp, sp, 8
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
vet_aux: .skip 30
vet_teste: .word 0,0
vteste2: .word 0,0
