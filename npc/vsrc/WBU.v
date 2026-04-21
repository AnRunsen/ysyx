`include "MACRO.v"
module WBU(
    input [4:0] rd,
    input en,
    input [2:0] wb_sel,
    input [31:0] imm,
    input [31:0] exu_res,
    input [31:0] mem,
    input [31:0] PC,
    input [31:0] csr,

    output wen,
    output reg [31:0] wdata,
    output [4:0] waddr
);

    assign wen = en;
    assign waddr = rd;

    always @(*) begin
        case(wb_sel)
            `WB_SEL_IMM: wdata = imm;
            `WB_SEL_ALU: wdata = exu_res;
            `WB_SEL_MEM: wdata = mem;
            `WB_SEL_PC4: wdata = PC + 32'd4;
            `WB_SEL_CSR: wdata = csr;
            default: wdata = 32'b0;
        endcase
    end

endmodule
