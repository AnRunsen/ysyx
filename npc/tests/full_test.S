# full_test.S — 测试: add, addi, lui, lw, lbu, sw, sb, jalr
# ABI: ilp32e（仅使用 x0–x15: zero ra sp gp tp t0 t1 t2 s0 s1 a0–a5）
#
# 策略:
#   由于 CPU 尚未实现 beq/bne，无法用条件分支。
#   采用"误差累加"：每项测试计算 (实际结果 - 期望值)，累加到 a0。
#   全部正确 → a0 = 0 → ebreak Good Trap
#   任意出错 → a0 ≠ 0 → ebreak Bad/Unknown Trap
#
#   jalr 测试：进入子程序前置 t2=1，子程序将 t2 清零后返回；
#             若 jalr 未跳转，t2 仍为 1 且被累加进 a0。
#
# 构建示例（riscv64-linux-gnu 工具链兼容 rv32e）:
#   riscv64-linux-gnu-as  -march=rv32e -mabi=ilp32e full_test.S -o full_test.o
#   riscv64-linux-gnu-ld  -melf32lriscv -Ttext=0x80000000 full_test.o -o full_test
#   riscv64-linux-gnu-objcopy -O binary full_test full_test.bin

.section .text
.globl _start
_start:
    addi  a0, zero,  0          # a0 = 误差累加器，初始 0

    # 暂存区: 0x80001000
    lui   sp,   0x80001         # sp = 0x80001000

    # ── addi ─────────────────────────────────────────────────────────────
    # 正数立即数
    addi  t0, zero,  37
    addi  t1, zero, -37
    add   t0, t0, t1            # = 0 若 addi 正确
    add   a0, a0,  t0

    # 负数立即数（测试符号扩展）
    addi  t0, zero, -10
    addi  t1, zero,  10
    add   t0, t0, t1            # = 0 若符号扩展正确
    add   a0, a0,  t0

    # ── lui ──────────────────────────────────────────────────────────────
    # lui t0, 3  →  t0 = 0x0000_3000
    # 用 sw+lbu 逐字节验证（避免依赖 12 位之外的立即数取反）
    lui   t0, 3                 # t0 = 0x00003000
    sw    t0, 0(sp)

    lbu   t1, 0(sp)             # byte[0] = 0x00
    add   a0, a0, t1

    lbu   t1, 1(sp)             # byte[1] = 0x30 = 48
    addi  t2, zero, -48
    add   t1, t1, t2            # = 0 若正确
    add   a0, a0, t1

    lbu   t1, 2(sp)             # byte[2] = 0x00
    add   a0, a0, t1

    lbu   t1, 3(sp)             # byte[3] = 0x00
    add   a0, a0, t1

    # ── add ──────────────────────────────────────────────────────────────
    # 正数相加: 25 + 17 = 42
    addi  t0, zero, 25
    addi  t1, zero, 17
    add   t0, t0, t1            # t0 = 42
    addi  t1, zero, -42
    add   t0, t0, t1            # = 0 若正确
    add   a0, a0, t0

    # 含负数: (-5) + 8 = 3
    addi  t0, zero, -5
    addi  t1, zero,  8
    add   t0, t0, t1            # t0 = 3
    addi  t1, zero, -3
    add   t0, t0, t1            # = 0 若正确
    add   a0, a0, t0

    # ── sw + lw ──────────────────────────────────────────────────────────
    # 正数回写
    addi  t0, zero, 100
    sw    t0, 4(sp)
    lw    t1, 4(sp)             # 应加载 100
    addi  t2, zero, -100
    add   t1, t1, t2            # = 0 若正确
    add   a0, a0, t1

    # 负数回写（验证 lw 保留符号）
    addi  t0, zero, -55
    sw    t0, 8(sp)
    lw    t1, 8(sp)             # 应加载 -55
    addi  t2, zero,  55
    add   t1, t1, t2            # = 0 若正确
    add   a0, a0, t1

    # ── sb + lbu ─────────────────────────────────────────────────────────
    # 普通字节
    addi  t0, zero, 90          # 0x5A
    sb    t0, 12(sp)
    lbu   t1, 12(sp)            # = 90，零扩展
    addi  t2, zero, -90
    add   t1, t1, t2            # = 0 若正确
    add   a0, a0, t1

    # 高位为 1 的字节：lbu 必须零扩展（不做符号扩展）
    addi  t0, zero, 255         # 0xFF
    sb    t0, 13(sp)
    lbu   t1, 13(sp)            # = 255，NOT -1
    addi  t2, zero, -255
    add   t1, t1, t2            # = 0 若零扩展正确
    add   a0, a0, t1

    # sb 只写最低字节：0x00001000 的最低字节 = 0x00
    lui   t0, 0x1               # t0 = 0x00001000
    sb    t0, 14(sp)
    lbu   t1, 14(sp)            # 应为 0x00
    add   a0, a0, t1

    # ── jalr ─────────────────────────────────────────────────────────────
    # 置 t2=1（失败标志）；子程序将其清零后通过 jalr 返回。
    # 若 jalr 未跳转：t2 仍为 1，add 将 1 累加进 a0。
    addi  t2, zero, 1
    lui   t0, %hi(jalr_sub)
    addi  t0, t0, %lo(jalr_sub)
    jalr  ra, 0(t0)             # 调用 jalr_sub；ra = 下一条指令地址
    # ← jalr 返回或（若未跳转）顺序执行均到达此处
    add   a0, a0, t2            # t2=0 则 jalr 正常；t2=1 则计入误差

    ebreak                      # a0=0 → Good Trap；a0≠0 → 失败

jalr_sub:
    addi  t2, zero, 0           # 已进入子程序，清除失败标志
    jalr  zero, 0(ra)           # 返回调用处
