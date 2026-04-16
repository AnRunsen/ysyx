# full_test.S - NPC CPU 指令测试
# 测试指令：add, addi, lui, lw, lbu, sw, sb, jalr
# 终止方式：全部通过时 a0=0 执行 ebreak，任意失败时 a0=1 执行 ebreak

.section entry, "ax"
.globl _start

_start:
    la   s0, scratch         # s0 = 暂存内存基地址（用于 sw/lw/sb/lbu 测试）

    #------------------------------------------------------------------
    # 1. addi：将 12 位符号数立即数加到寄存器
    #------------------------------------------------------------------

    # 基本正数：42
    addi t0, zero, 42
    addi t1, zero, 42
    bne  t0, t1, fail

    # 负立即数：-1 -> 0xFFFFFFFF
    addi t0, zero, -1
    addi t1, zero, -1
    bne  t0, t1, fail

    # 链式：100 + (-60) = 40
    addi t0, zero, 100
    addi t0, t0, -60
    addi t1, zero, 40
    bne  t0, t1, fail

    # 最大正立即数：0x7FF = 2047
    addi t0, zero, 0x7FF
    addi t1, zero, 0x7FF
    bne  t0, t1, fail

    #------------------------------------------------------------------
    # 2. add：两个寄存器相加
    #------------------------------------------------------------------

    # 30 + 70 = 100
    addi t0, zero, 30
    addi t1, zero, 70
    add  t2, t0, t1
    addi t3, zero, 100
    bne  t2, t3, fail

    # 负数加法：(-20) + 5 = -15
    addi t0, zero, -20
    addi t1, zero, 5
    add  t2, t0, t1
    addi t3, zero, -15
    bne  t2, t3, fail

    # x + 0 = x（加零恒等）
    addi t0, zero, 0x7FF
    add  t2, t0, zero
    bne  t2, t0, fail

    # 0 + 0 = 0
    add  t2, zero, zero
    bne  t2, zero, fail

    #------------------------------------------------------------------
    # 3. lui：将 20 位立即数加载到高位，低 12 位清零
    #------------------------------------------------------------------

    # lui t0, 1 -> t0 = 0x00001000
    # 用 sw + lbu 逐字节验证各位域
    lui  t0, 1               # t0 = 0x00001000
    sw   t0, 0(s0)
    lbu  t1, 0(s0)           # byte[0] = bits[7:0]  = 0x00
    bne  t1, zero, fail
    lbu  t1, 1(s0)           # byte[1] = bits[15:8] = 0x10
    addi t2, zero, 0x10
    bne  t1, t2, fail
    lbu  t1, 2(s0)           # byte[2] = bits[23:16] = 0x00
    bne  t1, zero, fail
    lbu  t1, 3(s0)           # byte[3] = bits[31:24] = 0x00
    bne  t1, zero, fail

    # lui + addi 拼接 32 位常数：0x12345678
    # 0x12345678 = (0x12345 << 12) | 0x678，且 0x678 = 1656 < 2048（无符号）
    lui  t0, 0x12345
    addi t0, t0, 0x678
    lui  t1, 0x12345
    addi t1, t1, 0x678
    bne  t0, t1, fail        # 两次相同构造必须相等

    #------------------------------------------------------------------
    # 4. sw + lw：存储字 / 加载字（32 位往返）
    #------------------------------------------------------------------

    # 写入 0x12345678，读回比较
    lui  t0, 0x12345
    addi t0, t0, 0x678       # t0 = 0x12345678
    sw   t0, 0(s0)
    lw   t1, 0(s0)
    bne  t0, t1, fail

    # 不同偏移：offset=4，值 = 0x7FF
    addi t0, zero, 0x7FF
    sw   t0, 4(s0)
    lw   t1, 4(s0)
    bne  t0, t1, fail

    # 写零并验证
    sw   zero, 8(s0)
    lw   t1, 8(s0)
    bne  t1, zero, fail

    #------------------------------------------------------------------
    # 5. sb + lbu：存储字节 / 无符号加载字节
    #------------------------------------------------------------------

    # 存 0xAB (171)，无符号加载回
    addi t0, zero, 0xAB      # 0xAB = 171
    sb   t0, 0(s0)
    lbu  t1, 0(s0)
    addi t2, zero, 0xAB
    bne  t1, t2, fail

    # 不同偏移：offset=1，值 = 0x7F
    addi t0, zero, 0x7F
    sb   t0, 1(s0)
    lbu  t1, 1(s0)
    addi t2, zero, 0x7F
    bne  t1, t2, fail

    # sb 只写 1 字节：offset=0 的值仍应为 0xAB
    lbu  t1, 0(s0)
    addi t2, zero, 0xAB
    bne  t1, t2, fail

    # lbu 零扩展验证：存 0xFF，读回应为 0x000000FF（非符号扩展）
    addi t0, zero, -1        # t0 = 0xFFFFFFFF（低位字节 = 0xFF）
    sb   t0, 2(s0)           # 仅写最低字节 0xFF
    lbu  t1, 2(s0)           # 读回：高 24 位应全 0
    addi t2, zero, 0xFF      # 0xFF = 255，12 位立即数范围内
    bne  t1, t2, fail

    #------------------------------------------------------------------
    # 6. jalr：跳转到 rs1+imm，返回地址写入 rd
    #------------------------------------------------------------------

    # 子程序调用（偏移 = 0）
    addi t4, zero, 0         # t4 = 0（未访问标志）
    la   t0, jalr_sub1
    jalr ra, 0(t0)           # rd=ra 保存返回地址，跳到 jalr_sub1
    # ——返回点——
    addi t3, zero, 99
    bne  t4, t3, fail        # 子程序应将 t4 设为 99

    # jalr 非零偏移测试：jalr ra, 4(t0) 跳到 (t0+4) = jalr_sub2
    addi t5, zero, 0         # t5 = 0
    la   t0, jalr_sub2_pad   # t0 = jalr_sub2_pad 地址（jalr_sub2 前 4 字节）
    jalr ra, 4(t0)           # 跳到 jalr_sub2_pad + 4 = jalr_sub2
    # ——返回点——
    addi t3, zero, 77
    bne  t5, t3, fail        # 子程序应将 t5 设为 77

    #------------------------------------------------------------------
    # 全部测试通过
    #------------------------------------------------------------------
    addi a0, zero, 0
    ebreak

fail:
    addi a0, zero, 1
    ebreak

    #------------------------------------------------------------------
    # 子程序
    #------------------------------------------------------------------

jalr_sub1:
    addi t4, zero, 99        # 设置访问标志 = 99
    jalr zero, 0(ra)         # 返回调用者（rd=zero 丢弃返回地址）

jalr_sub2_pad:
    addi zero, zero, 0       # nop：4 字节占位，使 jalr_sub2 正好在偏移 4 处

jalr_sub2:
    addi t5, zero, 77        # 设置访问标志 = 77
    jalr zero, 0(ra)         # 返回调用者

    #------------------------------------------------------------------
    # 暂存内存区（BSS 段，由构建系统写入 0）
    #------------------------------------------------------------------
.section .bss
.align 4
scratch:
    .zero 32                 # 32 字节归零暂存空间
