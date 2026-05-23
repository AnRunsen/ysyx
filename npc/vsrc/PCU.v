`include "MACRO.v"
import PKG::ftrace;

module PCU(
    input clk,
    input arstn,
    output reg [31:0] PC,
    input [31:0] exu_result,
    input [31:0] imm,
    input ecall,
    input mret,
    input [31:0] mtvec,
    input [31:0] mepc,
    input [1:0] behavior
);

    initial begin
        PC = 32'h8000_0000;
    end

    reg [31:0] PC_next;
    always @(*) begin
        if(ecall) PC_next = mtvec;
        else if(mret) PC_next = mepc;
        else begin
            case(behavior)
                `PC_NORMAL: PC_next = PC + 32'd4;
                `PC_NEAR: PC_next = PC + imm;
                `PC_FAR: PC_next = exu_result;
                `PC_BRANCH: PC_next = (exu_result == 32'b1) ? PC + imm : PC + 32'd4;
                default: PC_next = 32'hFFFF_FFFF;
            endcase
        end
        
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            PC <= 32'h8000_0000;
        end

        else begin
            PC <= PC_next;
            ftrace(PC, PC_next);
        end
    end

endmodule
