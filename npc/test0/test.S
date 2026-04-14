# x1: return address
# x2: base register
.global _start
_start:
    addi x2, x0, 16     # x2 = 16 (函数地址)
    jalr x1, x2, 0      # 跳转到 16，x1 = 返回地址

    addi x3, x0, 111    # 如果 jalr 正确，这条不会执行
    addi x3, x0, 222    # 同上

# ===== 函数位置 (PC = 16) =====
func:
    addi x5, x0, 5      # x5 = 5
    addi x5, x5, 3      # x5 = 8

    jalr x0, x1, 0      # return（跳回去，不写 rd）

# ===== 返回后执行 =====
    addi x6, x0, 66     # 应该执行到这里