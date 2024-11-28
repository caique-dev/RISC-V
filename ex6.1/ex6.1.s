# leitura do terminal
li a0, 0  # file descriptor = 0 (stdin)
la a1, input_address #  buffer to write the data
li a2, 21  # size (reads only 1 byte)
li a7, 63 # syscall read (63)
ecall

la s0, input_address # carrego o endereço do rótulo - inicio do vetor com os digitos
la s1, variavel # carrega o endereco do vetor de saida

# convertendo os numeros do input para inteiros
convertendo_char_int:
    mv a0, s0
    mv a3, s1
    addi a1, zero, 4 # quantidade de numeros a serem convertidos 
    addi a2, zero, 4 # quantidade de digitos por numero
    jal char_vet_to_num

# calculando raiz de cada numero
calculando_raiz:
    mv a0, s1 # endereco do vetor com os operandos
    la a1, sq_roots # carregando endereco do vetor que armazena as raizes
    li a3, 4 # definindo o numero de iteracoes
    sqrt_loop:
        jal sqrt # realizando operacao
        addi a0, a0, 4 # atualizando o operando
        addi a1, a1, 4 # atualizando a posicao de armazenamento do resultado
        addi a3, a3, -1 # decrementa contador
    bnez a3, sqrt_loop

# transformando os numeros em caracter novamente
to_string:
    la a0, sq_roots # numero a ser convertido
    la a1, output # espaco de armazenamento
    li a3, 4 # numero de iteracoes

    1: 
        jal num_vet_to_char
        addi a0, a0, 4
        addi a1, a1, 1
        li t1, ' '
        sb t1, 0(a1) # adicionando o espaco entre os numeros
        addi a1, a1, 1
        addi a3, a3, -1
    bnez a3, 1b

    li a3, '\n'
    sb a3, 0(a1) # adicionando o \n


# saida no terminal
print:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, output       # buffer
    li a2, 21           # size
    li a7, 64           # syscall write (64)
    ecall

# exit
exit:
    li a0, 0
    li a7, 93
    ecall

#transforma o caracter em digito
char_vet_to_num:
    mv t0, a3 # endereco do vetor de resultado
    addi t1, a0, 4 # index do digito no numero
    add t2, zero, a1 # index do numero no input
    mv a1, zero # zerando a1
    li t4, 0 # variavel que armazena o valor do inteiro
    li t5, 1000

    1: # convertendo cada digito do numero
        lbu t3, 0(a0)
        addi t3, t3, -'0' # conversao

        mul t6, t3, t5 # atribuindo valor posicional do digito 
        add t4, t4, t6 # armazenando o valor

        li t3, 10
        divu t5, t5, t3 # corrigindo o valor do fator

        addi a0, a0, 1 # incrementando contador
    blt a0, t1, 1b # passando pro proximo digito

    # salvando o numero no vetor de saida
    sw t4, 0(t0)

    # apontado para o prox num do vetor
    addi t0, t0, 4

    # resetando registradores
    li t4, 0
    li t5, 1000

    addi a1, a1, 1 # altera o numero alvo dentro do input
    addi a0, a0, 1 # pula o espaco
    add t1, t1, 5 # atualiza o index do digito dentro do numero
    blt a1, t2, 1b
    ret

# a0 end inicio do numero
# importantes: t1 numero original, t2=2, t3 limitador e t4 index, t5 valor anterior, t6 temporario
sqrt:
    lw t1, 0(a0) # carregando o numero
    srli t5, t1, 1 # dividindo por dois

    li t3, 10 # definindo o numero de iteracoes
    li t4, 0 # index das iteracoes

    1: # inicio do loop
        div t6, t1, t5 # y/kn
        add t6, t6, t5 # kn + (y/kn)
        srli t5, t6, 1 # (kn + (y/kn))/2
        addi t4, t4, 1
    blt t4, t3, 1b 

    # salvando a raiz na memoria
    raiz_num:
    sw t5, 0(a1)

    ret

#transforma o digito em caracter
# a0, end do numero
num_vet_to_char:
    lw t0, 0(a0) # carregando a raiz 
    mv t1, a1 # carregando o end de armazenamento
    li t2, 1000 
    li t3, 10

    # primeiro digito
    divu t4, t0, t2
    addi t4, t4, '0' # converao
    sb t4, 0(a1) # armazenamento
    
    # segundo digito
    remu t0, t0, t2
    divu t2, t2, t3 # atualizo a pot de dez
    divu t4, t0, t2
    addi t4, t4, '0' # converao
    addi a1, a1, 1 # atualizando o end de armazenamento
    sb t4, 0(a1)

    # terceiro digito
    remu t0, t0, t2
    divu t2, t2, t3 # atualizo a pot de dez
    divu t4, t0, t2
    addi t4, t4, '0' # converao
    addi a1, a1, 1 # atualizando o end de armazenamento
    sb t4, 0(a1)

    # quarto digito
    remu t0, t0, t2
    divu t2, t2, t3 # atualizo a pot de dez
    divu t4, t0, t2
    addi t4, t4, '0' # converao
    addi a1, a1, 1 # atualizando o end de armazenamento
    sb t4, 0(a1)

    ret

.bss    
input_address: .skip 0x15  # buffer
variavel: .word 0,0,0,0
sq_roots: .word 0,0,0,0
output: .skip 0x15