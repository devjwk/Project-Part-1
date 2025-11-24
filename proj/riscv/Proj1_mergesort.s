###############################################
# Proj1_mergesort.s - CPU 호환 bottom-up mergesort
###############################################

    .text
    .globl _start

# 레지스터 매핑:
# s0 = arr base
# s1 = tmp base
# s2 = N
# s3 = width
# t0 = left
# t1 = mid
# t2 = right
# t3 = i
# t4 = j
# t5 = k
# t6 = addr calc
# x10-x17 임시(extra) 사용

_start:
    la    s0, arr
    la    s1, tmp
    li    s2, 16          # N = 16

    li    s3, 1           # width = 1

###############################
# merge_pass
###############################
merge_pass:
    bge   s3, s2, done

    li    t0, 0           # left = 0

###############################
# merge_loop
###############################
merge_loop:
    add   t1, t0, s3      # mid
    bge   t1, s2, end_loop

    add   t2, t1, s3      # right
    bge   t2, s2, fix_r
    j     do_merge

fix_r:
    addi  t2, s2, 0

################################
# do_merge
################################
do_merge:
    addi  t3, t0, 0       # i = left
    addi  t4, t1, 0       # j = mid
    addi  t5, t0, 0       # k = left

################################
# merge_cmp
################################
merge_cmp:
    bge   t3, t1, take_right
    bge   t4, t2, take_left

    # arr[i] → x10
    slli  t6, t3, 2
    add   t6, t6, s0
    lw    x10, 0(t6)

    # arr[j] → x11
    slli  t6, t4, 2
    add   t6, t6, s0
    lw    x11, 0(t6)

    ble   x10, x11, ml_left

    # take arr[j]
    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x11, 0(t6)
    addi  t4, t4, 1
    addi  t5, t5, 1
    j     merge_cmp

ml_left:
    # take arr[i]
    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x10, 0(t6)
    addi  t3, t3, 1
    addi  t5, t5, 1
    j     merge_cmp

################################
# take_left
################################
take_left:
    bge   t3, t1, take_right_done

    slli  t6, t3, 2
    add   t6, t6, s0
    lw    x10, 0(t6)

    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x10, 0(t6)

    addi  t3, t3, 1
    addi  t5, t5, 1
    j     take_left

################################
# take_right
################################
take_right:
    bge   t4, t2, merge_copy

    slli  t6, t4, 2
    add   t6, t6, s0
    lw    x10, 0(t6)

    slli  t6, t5, 2
    add   t6, t6, s1
    sw    x10, 0(t6)

    addi  t4, t4, 1
    addi  t5, t5, 1
    j     take_right

take_right_done:
    j     merge_copy

################################
# merge_copy
################################
merge_copy:
    addi  x12, t0, 0      # k = left

copy_loop:
    bge   x12, t2, end_merge

    slli  t6, x12, 2
    add   t6, t6, s1
    lw    x10, 0(t6)

    slli  t6, x12, 2
    add   t6, t6, s0
    sw    x10, 0(t6)

    addi  x12, x12, 1
    j     copy_loop

################################
# next block
################################
end_merge:
    addi t0, t2, 0
    blt  t0, s2, merge_loop

################################
# width *= 2
################################
end_loop:
    slli  s3, s3, 1
    j     merge_pass

################################
# done
################################
done:
    wfi

################################
# data
################################
    .data

arr:
    .word 9,1,8,2,7,3,6,4,0,-1,5,12,-3,10,11,-2

tmp:
    .space 64
