`include "MACRO.v"

module EXU(
    input [31:0] srcR1,
    input [31:0] srcR2,
    input [31:0] imm,
    input [31:0] csr,
    input [31:0] PC,

    input [1:0] alu_sel0, //sel the ALU A port is srcR1(0) or PC(1)
    input [1:0] alu_sel1, //sel the ALU B port is srcR2(0) or imm(1) or csr(2)
    input [3:0] alu_op,
    output [31:0] result
);


    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    assign alu_src1 = (alu_sel0 == `ALU_SEL_RS1) ? srcR1 :
                      (alu_sel0 == `ALU_SEL_PC) ? PC : 32'b0;
    assign alu_src2 = (alu_sel1 == `ALU_SEL_RS2) ? srcR2 :
                      (alu_sel1 == `ALU_SEL_IMM) ? imm :
                      (alu_sel1 == `ALU_SEL_CSR) ? csr : 32'b0;

    ALU alu(
        .A(alu_src1),
        .B(alu_src2),
        .Opcode(alu_op),
        .Result(result)
    );

endmodule
