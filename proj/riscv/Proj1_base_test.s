# Proj1_base_test.s
# - 기본 ALU, 즉시형 ALU, load/store, branch, jump, LUI/AUIPC, WFI 까지
#   한 번씩은 다 써보는 자기검사용 프로그램

########################
# 데이터 섹션
########################
.data
data_word:  .word 0              # sw / lw 테스트용
data_mix:   .word 0x11223344     # lb / lbu / lh / lhu 테스트용

########################
# 코드 섹션
########################
.text
main:
    ##################################
    # 1. 즉시형 연산 (addi, slti, slli, srli, srai)
    ##################################
    addi x1,  x0, 5          # x1 = 5
    addi x2,  x0, 10         # x2 = 10

    slti x3,  x1, 10         # x3 = 1 (5 < 10)

    slli x4,  x1, 1          # x4 = 5 << 1 = 10
    srli x5,  x2, 1          # x5 = 10 >> 1 = 5 (logical)
    srai x6,  x2, 1          # x6 = 10 >> 1 = 5 (arithmetic)

    ##################################
    # 2. 레지스터 ALU 연산 (add, sub, xor, or, and, slt)
    ##################################
    add x7,  x1, x2          # x7  = 15
    sub x8,  x2, x1          # x8  = 5
    xor x9,  x1, x2          # x9  = 5 ^ 10
    or  x10, x1, x2          # x10 = 5 | 10
    and x11, x1, x2          # x11 = 5 & 10
    slt x12, x1, x2          # x12 = 1 (5 < 10)

    ##################################
    # 3. 메모리 접근 (sw, lw, lb, lbu, lh, lhu)
    ##################################
    # word store / load
    la   x13, data_word      # x13 = &data_word
    sw   x7, 0(x13)          # MEM[data_word] = 15
    lw   x14, 0(x13)         # x14 = 15

    # byte/halfword load (sign/zero extend)
    la   x15, data_mix       # data_mix = 0x11 22 33 44 (빅엔디안/리틀엔디안은 상관 없음, 단지 패턴용)
    lb   x16, 0(x15)         # 가장 낮은 바이트를 부호 확장
    lbu  x17, 1(x15)         # 다음 바이트를 zero-extend
    lh   x18, 0(x15)         # 하위 halfword 부호 확장
    lhu  x19, 2(x15)         # 상위 halfword zero-extend

    ##################################
    # 4. Branch 계열 (beq, bne, blt, bge, bltu, bgeu)
    ##################################
    addi x20, x0, 0
    addi x21, x0, 1

    beq  x20, x20, beq_taken     # 항상 점프
    addi x21, x0, 99             # 실행되면 안 됨
beq_taken:
    bne  x20, x21, bne_taken     # 0 != 1 이라 점프
    addi x21, x0, 98             # 실행되면 안 됨
bne_taken:
    blt  x20, x21, blt_taken     # 0 < 1
    addi x21, x0, 97             # 실행되면 안 됨
blt_taken:
    bge  x21, x20, bge_taken     # 1 >= 0
    addi x21, x0, 96             # 실행되면 안 됨
bge_taken:
    bltu x20, x21, bltu_taken    # 0 < 1 (unsigned)
    addi x21, x0, 95             # 실행되면 안 됨
bltu_taken:
    bgeu x21, x20, bgeu_taken    # 1 >= 0 (unsigned)
    addi x21, x0, 94             # 실행되면 안 됨
bgeu_taken:

    ##################################
    # 5. JAL / JALR (텍스트 섹션 안의 라벨로만 점프!)
    ##################################
    jal  x22, jal_target         # x22 = return address
    addi x23, x0, 0              # 실행되면 안 됨
jal_target:
    addi x23, x0, 1              # x23 = 1 (JAL 테스트용)

    # jalr: 반드시 라벨 주소를 la 로 받아야 함
    la   x24, jalr_target        # x24 = &jalr_target (텍스트 섹션)
    jalr x25, 0(x24)             # x25 = return address
    addi x26, x0, 0              # 실행되면 안 됨
jalr_target:
    addi x26, x0, 1              # x26 = 1 (JALR 테스트용)

    ##################################
    # 6. LUI / AUIPC
    ##################################
    lui   x27, 0x12345           # 상위 20비트 로드
    auipc x28, 0                 # x28 = 현재 PC (PC-relative 테스트용)

    ##################################
    # 7. 종료 (WFI → HALT 신호)
    ##################################
end:
    wfi                          # 과제에서 말한 HALT 명령
