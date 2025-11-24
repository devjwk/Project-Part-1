
    .text
    .globl _start
_start:
    la    t0, stack_top
    addi  sp, t0, 0

    addi  s0, x0, 5         # n = 5 levels
    jal   ra, level1
    j     exit

level1:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    s0,  8(sp)
    addi  s0, s0, -1
    bge   s0, x0, level1_go
    j     level1_unwind
level1_go:
    jal   ra, level2
level1_unwind:
    lw    ra, 12(sp)
    lw    s0,  8(sp)
    addi  sp, sp, 16
    jalr  x0, ra, 0

level2:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    s0,  8(sp)
    blt   x0, s0, level2_go
    j     level2_unwind
level2_go:
    jal   ra, level3
level2_unwind:
    lw    ra, 12(sp)
    lw    s0,  8(sp)
    addi  sp, sp, 16
    jalr  x0, ra, 0

level3:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    s0,  8(sp)
    addi  t1, x0, 2
    beq   s0, t1, level3_go    # touch beq
    bne   s0, t1, level3_go    # touch bne
level3_go:
    jal   ra, level4
    lw    ra, 12(sp)
    lw    s0,  8(sp)
    addi  sp, sp, 16
    jalr  x0, ra, 0

level4:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    s0,  8(sp)
    addi  t2, x0, -1
    bltu  t2, s0, level4_go    # unsigned compare
    addi  t3, x0, 0
level4_go:
    jal   ra, level5
    lw    ra, 12(sp)
    lw    s0,  8(sp)
    addi  sp, sp, 16
    jalr  x0, ra, 0

level5:
    addi  sp, sp, -16
    sw    ra, 12(sp)
    sw    s0,  8(sp)
    bgeu  s0, x0, level5_go
    addi  t4, x0, 0
level5_go:
    lw    ra, 12(sp)
    lw    s0,  8(sp)
    addi  sp, sp, 16
    jalr  x0, ra, 0

exit:
    wfi

# ---------------- Data section for stack buffer ----------------
    .data
    .align 4
stack_mem:
    .space 512
stack_top:

