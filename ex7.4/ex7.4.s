.text
.set BASE, 0xFFFF0100

.align 4
int_handler:
	# apontando para a pilha do programa
	csrrw sp, mscratch, sp

	# salvando o que vou sujar
	addi sp, sp, -16
	sw t0, 0(sp)
	sw t1, 4(sp)
	sw t2, 8(sp)
	sw t3, 12(sp)

	# verificando comando dado
	li t0, 0
	beq t0, a7, sleeper
	ret_sleeper:

	li t0, 10
	beq t0, a7, syscall_set_engine_and_steering
	ret_syscall_set_engine_and_steering:

	# restaurando contexto
	csrr t0, mepc
	addi t0, t0, 4
	csrw mepc, t0

	addi sp, sp, -16
	lw t0, 0(sp)
	lw t1, 4(sp)
	lw t2, 8(sp)
	lw t3, 12(sp)
	addi sp, sp, 16

	mret

sleeper:
	1:
		addi a0, a0, -1
	bnez a0, 1b

	j ret_sleeper
	

syscall_set_engine_and_steering:
	# verificando se os parametros sao validos
	li t0, 2
	bge a0, t0, erro
	li t0, -1
	bge a0, t0, 1f
	j erro

	1:
	li t0, 128
	bge a1, t0, erro
	li t0, -127
	bge a1, t0, 1f
	j erro

	1:
	# setando motor
	li t0, BASE
	sb a0, 0x21(t0)
	# setando direcao
	sb a1, 0x20(t0)

	li a0, 0
	j ret_syscall_set_engine_and_steering

	erro:
		li a0, -1
		j ret_syscall_set_engine_and_steering

	
.globl _start
_start:

	la t0, int_handler  # Load the address of the routine that will handle interrupts
	csrw mtvec, t0      # (and syscalls) on the register MTVEC to set
						# the interrupt array.

	# configurando a pilha do programa
	la t0, end_isr_stack
	csrw mscratch, t0

	# configurando MPP
	csrr t0, mstatus
	li t1, ~0x1800
	or t0, t0, t1
	csrw mstatus, t0

	# configurando MEPC
	la t0, user_main
	csrw mepc, t0

	# configurando mstatus.MIE
	csrr t0, mstatus
	li t1, 4
	or t0, t0, t1
	csrw mstatus, t0

	mret

# Write here the code to change to user mode and call the function
# user_main (defined in another file). Remember to initialize
# the user stack so that your program can use it.

.globl control_logic
control_logic:
	li a3, 40
	1:
		addi a3, a3, -1

		# move
		li a0, 1
		li a1, -120
		li a7, 10
		ecall

		# espera
		li a0, 500 
		li a7, 0
		ecall
	bnez a3, 1b

	li a0, 1
	li a1, 0
	li a7, 10
	ecall

	li a0, 750000
	li a7, 0
	ecall


.bss
isr_stack: .skip 1024
end_isr_stack:
