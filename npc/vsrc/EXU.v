`include "MACRO.v"
`ifndef SYNTHESIS
    import PKG::perf_cnt_update;
    import PKG::stage_update;
`endif
module EXU(
    input clk,
    input reset,

    /*recv data*/
    input [4:0] s_rd,
    input [31:0] s_srcR1,
    input [31:0] s_srcR2,
    input [31:0] s_imm,

    input [3:0] s_alu_op,
    input [1:0] s_alu_sel0, //sel the ALU A port is srcR1(0) or PC(1)
    input [1:0] s_alu_sel1, //sel the ALU B port is srcR2(0) or imm(1) or csr(2)

    input s_wb_en,
    input s_mem_en,
    input s_mem_write_en,

    input [1:0] s_op_width,
    input [2:0] s_wb_sel, //imm, alu, mem, PC+4

    input [1:0] s_brju,
    input s_mem_signext,

    input [11:0] s_csr_addr,
    input [31:0] s_csr_data,
    input s_csr_wr_sel, //0: write srcR1, 1: write alu_res
    input s_csr_wen,

    input s_ecall,
    input s_mret,
    input [31:0] s_PC,
    input s_fencei,

    input s_valid,
    output s_ready,
    /*recv data end*/


    /*send data*/
    output [4:0] m_rd,
    output m_wb_en,
    output m_mem_en,
    output m_mem_write_en,
    output [1:0] m_op_width,
    output [2:0] m_wb_sel,
    output m_mem_signext,
    output [11:0] m_csr_addr,
    output [31:0] m_csr_data,
    output m_csr_wr_sel,
    output m_csr_wen,
    output m_ecall,
    output [31:0] m_srcR1,
    output [31:0] m_srcR2,
    output [31:0] m_result,
    output [31:0] m_PC,
    output [31:0] m_imm,
    output m_fencei,

    output m_valid,
    input m_ready,
    /*send data end*/

    /*To the RAW module*/
    output [4:0] rd_exu,
    output working_exu,


    /*To PCR*/
    output [31:0] pcr_exu_result,
    output [31:0] pcr_imm,
    output pcr_ecall,
    output pcr_mret,
    output [31:0] pcr_mtvec,
    output [31:0] pcr_mepc,
    output [1:0] pcr_behavior,
    output [31:0] pcr_pc_now,
    output flush
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid & m_ready) begin
            perf_cnt_update(2);
            stage_update(3);
        end
    end
`endif

    assign flush = working_exu && ((brju == `PC_BRANCH && m_result == 32'b1) || (brju == `PC_FAR) || (brju == `PC_NEAR) || ecall || mret);
    assign pcr_exu_result = m_result;
    assign pcr_imm = imm;
    assign pcr_ecall = ecall;
    assign pcr_mret = mret;
    assign pcr_mtvec = csr_data;
    assign pcr_mepc = csr_data;
    assign pcr_behavior = brju;
    assign pcr_pc_now = PC_reg;
    assign rd_exu = rd;
    assign working_exu = valid_reg;


    reg [4:0] rd;
    reg [31:0] srcR1;
    reg [31:0] srcR2;
    reg [31:0] imm;

    reg [3:0] alu_op;
    reg [1:0] alu_sel0; //sel the ALU A port is srcR1(0) or PC(1)
    reg [1:0] alu_sel1; //sel the ALU B port is srcR2(0) or imm(1) or csr(2)

    reg wb_en;
    reg mem_en;
    reg mem_write_en;

    reg [1:0] op_width;
    reg [2:0] wb_sel; //imm; alu; mem; PC+4

    reg [1:0] brju;
    reg mem_signext;

    reg [11:0] csr_addr;
    reg [31:0] csr_data;
    reg csr_wr_sel; //0: write srcR1; 1: write alu_res
    reg csr_wen;

    reg ecall;
    reg mret;
    reg [31:0] PC_reg;
    reg fencei;

    /*logic to recv data*/
    assign s_ready = !m_valid || (m_valid & m_ready);
    always @(posedge clk) begin
        if(reset) begin
            rd <= 5'b0;
            srcR1 <= 32'b0;
            srcR2 <= 32'b0;
            imm <= 32'b0;

            alu_op <= 4'b0;
            alu_sel0 <= 2'b0; //sel the ALU A port is srcR1(0) or PC(1)
            alu_sel1 <= 2'b0; //sel the ALU B port is srcR2(0) or imm(1) or csr(2)

            wb_en <= 1'b0;
            mem_en <= 1'b0;
            mem_write_en <= 1'b0;

            op_width <= 2'b0;
            wb_sel <= 3'b0; //imm; alu; mem; PC+4

            brju <= 2'b0;
            mem_signext <= 1'b0;

            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            csr_wr_sel <= 1'b0; //0: write srcR1; 1: write alu_res
            csr_wen <= 1'b0;

            ecall <= 1'b0;
            mret <= 1'b0;
            PC_reg <= 32'b0;
            fencei <= 1'b0;
        end

        else if(s_valid && s_ready) begin
            rd <= s_rd;
            srcR1 <= s_srcR1;
            srcR2 <= s_srcR2;
            imm <= s_imm;

            alu_op <= s_alu_op;
            alu_sel0 <= s_alu_sel0;
            alu_sel1 <= s_alu_sel1;

            wb_en <= s_wb_en;
            mem_en <= s_mem_en;
            mem_write_en <= s_mem_write_en;

            op_width <= s_op_width;
            wb_sel <= s_wb_sel;

            brju <= s_brju;
            mem_signext <= s_mem_signext;

            csr_addr <= s_csr_addr;
            csr_data <= s_csr_data;
            csr_wr_sel <= s_csr_wr_sel;
            csr_wen <= s_csr_wen;

            ecall <= s_ecall;
            mret <= s_mret;
            PC_reg <= s_PC;
            fencei <= s_fencei;
        end
    end


    /*logic to send data*/
    assign m_rd = rd;
    assign m_wb_en = wb_en;
    assign m_mem_en = mem_en;
    assign m_mem_write_en = mem_write_en;
    assign m_op_width = op_width;
    assign m_wb_sel = wb_sel;
    assign m_mem_signext = mem_signext;
    assign m_csr_addr = csr_addr;
    assign m_csr_data = csr_data;
    assign m_csr_wr_sel = csr_wr_sel;
    assign m_csr_wen = csr_wen;
    assign m_ecall = ecall;
    assign m_srcR1 = srcR1;
    assign m_srcR2 = srcR2;
    assign m_PC = PC_reg;
    assign m_imm = imm;
    assign m_fencei = fencei;

    reg valid_reg;
    assign m_valid = valid_reg;

    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end
        else begin
            if(flush) begin
                valid_reg <= 1'b0;
            end
            else if(s_valid && s_ready) begin
                valid_reg <= 1'b1;
            end
            else if(m_ready && m_valid) begin
                valid_reg <= 1'b0;
            end
        end

    end

    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    assign alu_src1 = (alu_sel0 == `ALU_SEL_RS1) ? srcR1 :
                      (alu_sel0 == `ALU_SEL_PC) ? PC_reg : 32'b0;
    assign alu_src2 = (alu_sel1 == `ALU_SEL_RS2) ? srcR2 :
                      (alu_sel1 == `ALU_SEL_IMM) ? imm :
                      (alu_sel1 == `ALU_SEL_CSR) ? csr_data : 32'b0;

    ALU alu(
        .A(alu_src1),
        .B(alu_src2),
        .Opcode(alu_op),
        .Result(m_result)
    );

endmodule
