module EXU(
    input [31:0] srcR1,
    input [31:0] srcR2,
    input [31:0] imm,

    input alu_sel, //sel the ALU B port is srcR2(0) or imm(1)
    input [3:0] alu_op,
    output [31:0] result
);


    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    assign alu_src1 = srcR1;
    assign alu_src2 = (alu_sel) ? imm : srcR2;

    ALU alu(
        .A(alu_src1),
        .B(alu_src2),
        .Opcode(alu_op),
        .Result(result)
    );

endmodule
