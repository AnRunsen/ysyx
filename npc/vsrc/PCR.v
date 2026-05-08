`include "MACRO.v"
`ifndef SYNTHESIS
    import PKG::ftrace;
`endif

module PCR(
    input clk,
    input reset,
    input [31:0] exu_result,
    input [31:0] imm,
    input ecall,
    input mret,
    input [31:0] mtvec,
    input [31:0] mepc,
    input [1:0] behavior,
    input pc_en,
    output reg [31:0] PC
);

    initial begin
        PC = 32'h3000_0000;
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

    always @(posedge clk) begin
        if(reset) begin
            PC <= 32'h3000_0000;
        end

        else begin
            if(pc_en) begin
                PC <= PC_next;
                `ifndef SYNTHESIS
                    ftrace(PC, PC_next);
                `endif
            end

        end
    end

endmodule
