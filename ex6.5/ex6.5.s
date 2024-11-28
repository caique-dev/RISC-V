open_image:
    la a0, input_file    # pegando o fd da imagem
    li a1, 0             # flags (0: rdonly, 1: wronly, 2: rdwr)
    li a2, 0             # mode
    li a7, 1024          # syscall open
    ecall

read_image: # colocando os dados da imagem dentro do vetor
    la a1, image #  buffer to read the data
    li a2, 262459  # size (reads only 1 byte)
    li a7, 63 # syscall read (63)
    ecall

printando_img:
    li a0, 1            # file descriptor = 1 (stdout)
    la a1, image       # buffer
    li a2, 262459           # size
    li a7, 64           # syscall write (64)
    ecall

extraindo_informacoes:
    la a0, image
    la a1, vet_aux
    la a2, image_infos

    # largura
    num1:
        addi a0, a0, 3
        jal unpack
        sw a0, 0(a2)

    # altura
    num2:
        mv a0, a1
        addi a0, a0, 1
        jal unpack
        sw a0, 4(a2)

    # maxval
    num3:
        mv a0, a1
        addi a0, a0, 1
        jal unpack
        sw a0, 8(a2)

    mv s0, a1

setando_canvas:
    lw a0, 0(a2) # largura
    lw a1, 4(a2) # altura
    li a7, 2201 # syscall
    ecall

# s0 armazena o endereco do primeiro pixel da imagem
# s1 armazena o end de infos da img
# s2 armazena o numero total de pixels da imagem
# a0 armazena a posicao X do pixel a ser desenhado
# a1 arm a pos Y do pixel a ser desenhado
# a2 arm o valor do pixel a ser desenhado
# a3 arm a offset do pixel em rel ao inicio do vet img
# t0 armazena a largura da imagem
# t1 armazena a altura da imagem
# t3 armazena o indice do pixel atual
# t6 armazena o quantas iteracoes ainda restam
desenhando_pixel:
    addi s0, s0, 1 # s0 aponta pro primeiro pixel da imagem

    # total de pixels
    la s1, image_infos
    lw t0, 0(s1) # largura
    lw t1, 4(s1) # altura
    mul s2, t0, t1 # tot pixels img
    li a7, 2200 # syscall

    # loop
    mv t6, s2
    loop_pixels:
        # definindo o pixel
        sub t3, s2, t6 # indice do pixel atual
        
        remu a0, t3, t0 # X resto(pos%largura) 
        divu a1, t3, t0 # Y pos/largura

        verifica_borda:
            beqz a0, borda # borda esquerda
            
            # borda direita
            addi a3, t0, -1
            beq a0, a3, borda

            # borda superior
            beqz a1, borda

            # borda inferior
            addi a3, t1, -1
            beq a1, a3, borda
        
        pixel_centro:
            add a3, s0, t3 # offset em rel ao file

            # empilhando dados importantes
            addi sp, sp, -40
            sw s0, 0(sp)
            sw s2, 4(sp)
            sw a0, 8(sp)
            sw a1, 12(sp)
            sw t0, 16(sp)
            sw t1, 20(sp)
            sw t3, 24(sp)
            sw t6, 28(sp)
            sw s1, 32(sp)
            sw a3, 36(sp)
            sw ra, 40(sp) # empilhando ra

            mv a0, a3
            mv a1, t0
            jal filtro
            mv a2, a0

            lw s0, 0(sp)
            lw s2, 4(sp)
            lw a0, 8(sp)
            lw a1, 12(sp)
            lw t0, 16(sp)
            lw t1, 20(sp)
            lw t3, 24(sp)
            lw t6, 28(sp)
            lw s1, 32(sp)
            lw a3, 36(sp)
            lw ra, 40(sp) # desempilhando ra
            addi sp, sp, 40
        
        j pinta
        borda:
            li a2, 0xff # pixel preto

        pinta:
            ecall
            addi t6, t6, -1
    bnez t6, loop_pixels
    
# exit
exit:
    li a0, 0
    li a7, 93
    ecall

# a0 pos pixel no vetor
# t0 carrega o valor do pixel atual * 8
# t1 carrega a largura da imagem
# t2 carrega a posicao do pixel em analise
# t3 carrega o valor do pixel em analise
# t4 carrega a soma do valor dos pixels vizinhos
filtro:
    li t4, 0

    # val_att*8
    lbu t0, 0(a0)
    slli t0, t0, 3

    # pixels vizinhos da mesma linha
    same_line:
        lbu t3, -1(a0)
        add t4, t4, t3

        lbu t3, 1(a0)
        add t4, t4, t3

    # pixels da linha acima
    sup_line:
        mv t1, a1 # pegando largura
        sub t2, a0, t1 # selecionando pixel vizinho

        lbu t3, 0(t2)
        add t4, t4, t3

        lbu t3, -1(t2)
        add t4, t4, t3

        lbu t3, 1(t2)
        add t4, t4, t3

    # pixels da linha abaixo
    inf_line:
        add t2, a0, t1 # selecionando pixel vizinho

        lbu t3, 0(t2)
        add t4, t4, t3

        lbu t3, -1(t2)
        add t4, t4, t3

        lbu t3, 1(t2)
        add t4, t4, t3

    # definindo valor do pixel atual
    ver_range_pixel:
        sub t0, t0, t4
        mv a0, t0

        li t0, 256
        bge a0, t0, maior
        blt a0, zero, menor

    range_correto: # setando R=G=B
    mv t0, a0
    li a0, 0xff
    slli t1, t0, 8
    slli t2, t0, 16
    slli t3, t0, 24

    or a0, t1, a0
    or a0, t2, a0
    or a0, t3, a0

    j retorno_filtro

    j retorno_filtro
    maior:
        li a0, 0xffffffff

    j retorno_filtro
    menor:
        li a0, 0xff

    retorno_filtro:
        ret

# desempacota um range de bytes(1 a 4) e o transforma em int
# a0 armazena o endereco do vetor de origem dos dados
# a1, t2 armazena o endereco do vetor destino do int convertido
# t3 armazena o indice dentro do sub vet
# t4 numero de digitos do numero
unpack:
    la t2, vet_aux
    mv t3, a0 # indice do digt
    li t4, 0 # qntd de digts

    digito:
        lbu t0, 0(t3)

        addi t1, t0, -' '
        beqz t1, conversao

        addi t1, t0, -'\n'
        beqz t1, conversao

        # salvando byte numerico
        addi t0, t0, -'0'
        sb t0, 0(t2)
        addi t2, t2, 1 # incrementa indice no vet aux

        # voltando pro inicio do loop
        addi t3, t3, 1
        addi t4, t4, 1 # incrementando numero de digitos do numero
    j digito

    conversao:
        la t2, vet_aux
        li t0, 0 # acumulador
        li t1, 1 # pot

        mv t3, t4
        addi t3, t3, -1
        potencia:
            li t5, 10
            mul t1, t1, t5
            addi t3, t3, -1
        bnez t3, potencia

        mv t5, t4
        1:
            # pegando o dig
            lbu t3, 0(t2)
            
            # valor posicional
            mul t3, t3, t1
            add t0, t0, t3

            # reduzindo potencia
            li t3, 10
            divu t1, t1, t3

            # att indices
            addi t5, t5, -1
            addi t2, t2, 1
        bnez t5, 1b

        retorno_unpack:
            add a1, a0, t4 # ret numero de digitos encontrados
            mv a0, t0 # retornando int encontrado
            
            la t0, vet_aux
            sw zero, 0(t0) # zerando vet_aux

            ret

input_file: .asciz "image.pgm"

.bss
image: .skip 262159
image_infos: .word 0,0,0
vet_aux: .word 0