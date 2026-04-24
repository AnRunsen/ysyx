`include "MACRO.v"
module WBU(
    input clk,
    input arstn,

    /*data to recv*/
    input [4:0] s_rd,
    input s_wb_en,
    input [2:0] s_wb_sel,
    input [1:0] s_brju,
    input [11:0] s_csr_addr,
    input [31:0] s_csr_data,
    input s_csr_wr_sel,
    input s_csr_wen,
    input s_ecall,
    input s_mret,
    input [31:0] s_srcR1,
    input [31:0] s_srcR2,
    input [31:0] s_result,
    input [31:0] s_rdata,
    input [31:0] s_PC,
    input [31:0] s_imm,

    input s_valid,
    output s_ready,
    /*data to recv end*/

    /*To GPR*/
    output wen,
    output reg [31:0] wdata,
    output [4:0] waddr,

    /*To CSR*/
    output [11:0] csr_addr_,
    output [31:0] csr_srcR1_,
    output [31:0] csr_alu_res_,
    output csr_wr_sel_,
    output csr_wen_,
    output csr_ecall_,
    output [31:0] csr_epc_,
    output [31:0] csr_cause_,

    /*data to send*/
    output m_valid,
    input m_ready
    /*data to send end*/
);
    /*logic to recv data*/
    reg [4:0] rd;
    reg wb_en;
    reg [2:0] wb_sel;
    reg [1:0] brju;
    reg [11:0] csr_addr;
    reg [31:0] csr_data;
    reg csr_wr_sel;
    reg csr_wen;
    reg csr_ecall;
    reg mret;
    reg [31:0] srcR1;
    reg [31:0] srcR2;
    reg [31:0] result;
    reg [31:0] rdata;
    reg [31:0] PC;
    reg [31:0] imm;
    assign s_ready = !m_valid || (m_valid && m_ready);
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            rd <= 5'b0;
            wb_en <= 1'b0;
            wb_sel <= 3'b0;
            brju <= 2'b0;
            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            csr_wr_sel <= 1'b0;
            csr_wen <= 1'b0;
            csr_ecall <= 1'b0;
            mret <= 1'b0;
            srcR1 <= 32'b0;
            srcR2 <= 32'b0;
            result <= 32'b0;
            rdata <= 32'b0;
            PC <= 32'b0;
            imm <= 32'b0;
        end

        else if(s_valid && s_ready) begin
            rd <= s_rd;
            wb_en <= s_wb_en;
            wb_sel <= s_wb_sel;
            brju <= s_brju;
            csr_addr <= s_csr_addr;
            csr_data <= s_csr_data;
            csr_wr_sel <= s_csr_wr_sel;
            csr_wen <= s_csr_wen;
            csr_ecall <= s_ecall;
            mret <= s_mret;
            srcR1 <= s_srcR1;
            srcR2 <= s_srcR2;
            result <= s_result;
            rdata <= s_rdata;
            PC <= s_PC;
            imm <= s_imm;
        end
    end


    assign wen = wb_en;
    assign waddr = rd;

    always @(*) begin
        case(wb_sel)
            `WB_SEL_IMM: wdata = imm;
            `WB_SEL_ALU: wdata = result;
            `WB_SEL_MEM: wdata = rdata;
            `WB_SEL_PC4: wdata = PC + 32'd4;
            `WB_SEL_CSR: wdata = csr_data;
            default: wdata = 32'b0;
        endcase
    end

    assign csr_addr_ = csr_addr;
    assign csr_srcR1_ = srcR1;
    assign csr_alu_res_ = result;
    assign csr_wr_sel_ = csr_wr_sel;
    assign csr_wen_ = csr_wen;
    assign csr_ecall_ = csr_ecall;
    assign csr_epc_ = PC;
    assign csr_cause_ = srcR1;

endmodule
