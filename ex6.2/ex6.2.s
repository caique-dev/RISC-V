# recebendo Yb e Xc
entrada_coordenadas:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, coord_vet #  buffer to write the data
    li a2, 12  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

# transformando em inteiros
convertendo_coordenadas:
    la a0, coord_vet
    la a1, coord_vet_int

    li a2, 1 # habilitando a verificacao de sinal
    
    # converte Yb
    jal string_to_int

    # converte Xc
    addi a0, a0, 6
    addi a1, a1, 4
    jal string_to_int

# recebendo Ta, Tb, Tc, Tr
entrada_tempos:
    li a0, 0  # file descriptor = 0 (stdin)
    la a1, time_vet #  buffer to write the data
    li a2, 20  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

# transformando em inteiros
convertendo_tempos:
    la a0, time_vet
    la a1, time_vet_int
    li a3, 4 #iteracoes

    li a2, 0 # desabilitando a verificacao de sinais

    1:
        jal string_to_int

        addi a0, a0, 5 # apontando para o prox numero a ser convertido
        addi a1, a1, 4 # apontando para o prox endereco de armazenamento
        addi a3, a3, -1 # decremento
    bnez a3, 1b

# calculando distancias
calc_distancias:
    # armazenando Tr em a0
    la a0, time_vet_int
    addi a0, a0, 12

    la a1, sq_dist_vet
    la a2, time_vet_int 
    li a3, 3

    1:
        jal calc_sq_dist

        addi a1, a1, 4
        addi a2, a2, 4
        addi a3, a3, -1
    bnez a3, 1b

# calculando X e Y
calc_x:
    la a0, sq_dist_vet
    la a1, coord_xy
    la a2, coord_vet_int
    li t1, 0 # acumulador

    lw t0, 4(a2) # xc
    mul t0, t0, t0 # xc^2
    add t1, t1, t0

    lw t0, 0(a0) # da^2
    add t1, t1, t0 # da^2 + xc^2

    lw t0, 8(a0) # dc^2
    li t2, -1
    mul t0, t0, t2 # -dc^2
    add t1, t1, t0 # da^2 + xc^2 + (-dc^2)
    
    lw t0, 4(a2) # xc
    slli t0, t0, 1 # 2*xc
    div t1, t1, t0 # (da^2 + xc^2 + (-dc^2)) / 2*xc

    sw t1, 0(a1)

calc_y:
    la a0, sq_dist_vet
    la a1, coord_xy
    la a2, coord_vet_int
    li t1, 0 # acumulador

    lw t0, 0(a0) # da^2
    add t1, t1, t0

    lw t0, 0(a2) # yb
    mul t0, t0, t0 # yb^2
    add t1, t1, t0 # da^2 + yb^2

    lw t0, 4(a0) # db^2
    li t2, -1
    mul t0, t0, t2 # -db^2
    add t1, t1, t0 # da^2 + yb^2 + (-db^2)

    lw t0, 0(a2) # yb
    slli t0, t0, 1 # 2*yb
    div t1, t1, t0 # (da^2 + yb^2 + (-dc^2)) / 2*yb

    sw t1, 4(a1)

# transformando as coordenadas em string
coordenadas_to_string:
    la a0, coord_xy
    la a1, coord_vet

    # convertendo x
    jal int_to_string

    # convertendo y
    addi a0, a0, 4

    addi a1, a1, 1 # adicionando o espaco entre as coord
    li t0, ' '
    sb t0, 0(a1)
    addi a1, a1, 1

    jal int_to_string

    addi a1, a1, 1 # adicionando o \n
    li t0, '\n'
    sb t0, 0(a1)

# imprimindo na tela
print:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, coord_vet       # buffer
    li a2, 12           # size
    li a7, 64           # syscall write (64)
    ecall
# exit
exit:
    li a0, 0
    li a7, 93
    ecall

# transforma o caracter em digito
# a0 armazena o inicio da string
# a1 armazena o inicio do vetor de armazenamento
# a2 habilita a verificacao do sinal
# t2 armazena o numero correspondente
string_to_int:
    mv t0, a0

    beqz a2, 1f
        addi t0, t0, 1 # ignorando o sinal

    1:
        li t1, 1000 
        li t2, 0 # acumulador

    1:
        lbu t3, 0(t0) # carregando o caracter
        addi t3, t3, -'0' # convertendo
        
        mul t3, t1, t3 # valor posicional
        add t2, t2, t3 # somando ao acumulador

        addi t0, t0, 1 # atualizando posicao do byte analizado

        li t3, 10
        divu t1, t1, t3 # atualizando valor posicional
    bnez t1, 1b

    # verificando sinal
    beqz a2, retorno_conversao
        lbu t3, 0(a0)
        li t1, '-'
        bne t1, t3, retorno_conversao

    # numero negativo
    li t3, -1
    mul t2, t2, t3

    retorno_conversao:
        sw t2, 0(a1)
        ret

# transforma um inteiro em uma string
# a0 armazena o endereco do inteiro
# a1 armazena o endereco do vetor de armazenamento
int_to_string:
    lw t0, 0(a0)
    mv t1, a1
    li t2, 1000
    li t4, 10

    # setando sinal str
    blt t0, zero, n_neg
    
    # numeros > 0
    li t3, '+'
    sb t3, 0(t1)
    j conv_str

    n_neg:
        li t3, '-'
        sb t3, 0(t1)
        li t3, -1
        mul t0, t0, t3

    conv_str:
        addi t1, t1, 1 # att local de armazenamento

        divu t3, t0, t2 
        addi t3, t3, '0' 
        sb t3, 0(t1) # armazenando dig convertido

        remu t0, t0, t2 # 

        divu t2, t2, t4 # att divisor
    bnez t2, conv_str
    mv a1, t1
    ret

# calcula a distancia entre o ponto de ref e o satelite desejado
# a0 armazena o tempo de recebimento
# a1 armazena o vetor de armazenamento
# a2 armazena o tempo de envio pelo sat desejado
# t4 armazena a distancia calculada
calc_sq_dist:
    # carregando os tempos
    lw t0, 0(a0) # tempo de recebimento
    lw t1, 0(a2) # tempo de envio

    # calculando intervalo de tempo
    sub t3, t0, t1 

    # separando as constantes
    li t4, 3
    li t5, 10

    mul t4, t4, t3 # multiplicando o intervalo por 3
    divu t4, t4, t5 # dividindo o resultado por 10

    mul t4, t4, t4 # calculando o quadrado da distancia

    retorno_dist:
        sw t4, 0(a1)
        ret


.bss    
coord_vet: .skip 0xc 
coord_vet_int: .word 0,0
time_vet: .skip 0x14
time_vet_int: .word 0,0,0,0
sq_dist_vet: .word 0,0,0
coord_xy: .word 0,0