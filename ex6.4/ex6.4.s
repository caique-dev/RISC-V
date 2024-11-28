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
        divu a1, t3, t0 # Y pos/altura
        
        add a3, s0, t3 # offset em rel ao file

        lbu a4, 0(a3)
        slli a5, a4, 24
        slli a6, a4, 16
        slli a4, a4, 8

        ori a4, a4, 255
        or a4, a4, a5
        or a2, a4, a6 # definindo cor do pixel

        pinta:
        ecall
        addi t6, t6, -1
    bnez t6, loop_pixels
    








fim:




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

# exit
exit:
    li a0, 0
    li a7, 93
    ecall

input_file: .asciz "image.pgm"

.bss
image: .skip 262159
image_infos: .word 0,0,0
vet_aux: .word 0

