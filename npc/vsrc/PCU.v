`include "MACRO.v"

module PCU(
    input clk,
    input arstn,
    output reg [31:0] PC,
    input [31:0] exu_result,
    input [31:0] imm,
    input [1:0] behavior
);

    initial begin
        PC = 32'h8000_0000;
    end

    reg [31:0] PC_next;
    always @(*) begin
        case(behavior)
            `PC_NORMAL: PC_next = PC + 32'd4;
            `PC_NEAR: PC_next = PC + imm;
            `PC_FAR: PC_next = exu_result;
            default: PC_next = 32'hFFFF_FFFF;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            PC <= 32'h8000_0000;
        end

        else begin
            PC <= PC_next;
        end
    end

endmodule
