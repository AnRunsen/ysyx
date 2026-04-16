    .section .text
    .globl _start

_start:
    # 默认失败
    addi a0, x0, 1

    # -------------------------
    # 构造 0x12345678
    # -------------------------
    lui   t0, 0x12345        # t0 = 0x12345000
    addi  t0, t0, 0x678      # t0 = 0x12345678

    # base addr (用 sp)
    addi  t1, sp, 0

    # -------------------------
    # sw / lw 测试
    # -------------------------
    sw    t0, 0(t1)
    lw    t2, 0(t1)

    # 关键 trick：
    # 如果 lw 错了，t2 ≠ t0
    # 我们构造跳转地址依赖 t2
    # 正确 → 跳到 pass
    # 错误 → 跳飞

    lui   t1, %hi(pass)
    addi  t1, t1, %lo(pass)

    # t2 == t0 时：
    #   t2 - t0 = 0 → 不影响跳转
    add   t2, t2, x0         # 保持形式
    add   t2, t2, x0

    # 构造偏移（错误时会污染地址）
    add   t1, t1, t2         # ❗关键点（错误会跳飞）

    jalr  x0, t1, 0

    # 如果没跳走，说明有问题
fail:
    addi a0, x0, 1
    ebreak

# -------------------------
# pass 路径
# -------------------------
pass:
    # 再测 byte
    sb    t0, 4(sp)
    lbu   t1, 4(sp)

    # 正确应为 0x78
    addi  t2, x0, 0x78
    addi  t1, t1, -0x78      # t1 = 0 才正确

    # 再用 jalr 技巧
    lui   t0, %hi(done)
    addi  t0, t0, %lo(done)
    add   t0, t0, t1         # 错误 → 跳飞

    jalr  x0, t0, 0

    # 出问题就到这里
    addi a0, x0, 1
    ebreak

done:
    addi a0, x0, 0
    ebreak