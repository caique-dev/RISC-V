.data
.set GPT_BASE, 0xFFFF0100
.set MIDI_BASE, 0xFFFF0300

.text
.globl _start
.globl isr_function
.globl play_note
.globl _system_time

_start:
    # configurando end da isr
    la t0, isr_function
    csrw mtvec, t0

    # config pilhas
    la t0, end_isr_stack
    csrw mscratch, t0

    # habilitando interrupts
    csrr t0, mie
    li t1, 2048
    or t0, t0, t1
    csrw mie, t0

    csrr t0, mstatus
    ori t0, t0, 8
    csrw mstatus, t0

    # config primeira int
    li t0, GPT_BASE
    addi t0, t0, 0x8
    li t1, 100
    sw t1, (t0)


    # chamando a main
    jal main

.align 2
isr_function:
    # trocando sp
    csrrw sp, mscratch, sp

    # salvando cntxt
    addi sp, sp, -16
    sw t0, (sp)
    sw t1, 4(sp)

    # somando 100 na v glob
    la t0, _system_time
    lw t1, (t0)
    addi t1, t1, 100
    sw t1, (t0)

    # configurando gpt
    li t0, GPT_BASE
    addi t0, t0, 8
    li t1, 100
    sw t1, (t0)

    # recuperando cntxt
    lw t0, (sp)
    lw t1, 4(sp)
    addi sp, sp, 16

    # recuperando sp
    # csrrw mscratch, sp, mscratch
    csrrw sp, mscratch, sp

    mret

# void play_note(int ch, int inst, int note, int vel, int dur)
play_note:
    li t0, MIDI_BASE

    sb a0, (t0) 

    sh a1, 0x2(t0)

    sb a2, 0x4(t0)

    sb a3, 0x5(t0)

    sh a4, 0x6(t0)

    ret


.bss
isr_stack: .skip 1024
end_isr_stack:
_system_time: .word 0