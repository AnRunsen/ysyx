`define ALU_OP_ADD 4'b0000
`define ALU_OP_SUB 4'b0001
`define ALU_OP_AND 4'b0010
`define ALU_OP_OR  4'b0011
`define ALU_OP_XOR 4'b0100
`define ALU_OP_LT 4'b0101
`define ALU_OP_GE 4'b0110
`define ALU_OP_EQ 4'b0111
`define ALU_OP_SLL 4'b1000
`define ALU_OP_SRL 4'b1001
`define ALU_OP_SRA 4'b1010

`define WB_SEL_IMM 2'b00
`define WB_SEL_ALU 2'b01
`define WB_SEL_MEM 2'b10
`define WB_SEL_PC4 2'b11

`define OP_WIDTH_BYTE 2'b00
`define OP_WIDTH_HALF 2'b01
`define OP_WIDTH_WORD 2'b10

`define ALU_SEL_RS2 0
`define ALU_SEL_IMM 1

`define PC_NORMAL 2'b00
`define PC_NEAR 2'b01
`define PC_FAR 2'b10

