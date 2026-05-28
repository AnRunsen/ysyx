`define ysyx_26040125_ALU_OP_ADD 4'b0000
`define ysyx_26040125_ALU_OP_SUB 4'b0001
`define ysyx_26040125_ALU_OP_AND 4'b0010
`define ysyx_26040125_ALU_OP_OR  4'b0011
`define ysyx_26040125_ALU_OP_XOR 4'b0100
`define ysyx_26040125_ALU_OP_LT 4'b0101
`define ysyx_26040125_ALU_OP_GE 4'b0110
`define ysyx_26040125_ALU_OP_EQ 4'b0111
`define ysyx_26040125_ALU_OP_SLL 4'b1000
`define ysyx_26040125_ALU_OP_SRL 4'b1001
`define ysyx_26040125_ALU_OP_SRA 4'b1010
`define ysyx_26040125_ALU_OP_LTU 4'b1011
`define ysyx_26040125_ALU_OP_GEU 4'b1100
`define ysyx_26040125_ALU_OP_NE 4'b1101

`define ysyx_26040125_WB_SEL_IMM 3'b000
`define ysyx_26040125_WB_SEL_ALU 3'b001
`define ysyx_26040125_WB_SEL_MEM 3'b010
`define ysyx_26040125_WB_SEL_PC4 3'b011
`define ysyx_26040125_WB_SEL_CSR 3'b100

`define ysyx_26040125_OP_WIDTH_BYTE 2'b00
`define ysyx_26040125_OP_WIDTH_HALF 2'b01
`define ysyx_26040125_OP_WIDTH_WORD 2'b10

`define ysyx_26040125_ALU_SEL_RS1 2'b00
`define ysyx_26040125_ALU_SEL_PC 2'b01

`define ysyx_26040125_ALU_SEL_RS2 2'b00
`define ysyx_26040125_ALU_SEL_IMM 2'b01
`define ysyx_26040125_ALU_SEL_CSR 2'b10

`define ysyx_26040125_PC_NORMAL 3'b000
`define ysyx_26040125_PC_NEAR 3'b001
`define ysyx_26040125_PC_FAR 3'b010
`define ysyx_26040125_PC_BRANCH 3'b011
`define ysyx_26040125_PC_MRET 3'b100

`define ysyx_26040125_CSR_SEL_RS1 1'b0
`define ysyx_26040125_CSR_SEL_ALU 1'b1


import "DPI-C" function void sim_exit();
import "DPI-C" function void itrace(input int inst, input int pc);
import "DPI-C" function void ftrace(input int pc, input int npc);
import "DPI-C" function void uart_write(input int waddr, input int wdata, input byte wmask);
import "DPI-C" function int mtime_read(input int raddr);
import "DPI-C" function void perf_cnt_update(input byte target);
import "DPI-C" function void flush_num();
import "DPI-C" function void branch_num();
import "DPI-C" function void enter_userapp(input int npc);
import "DPI-C" function void ihit_num();
import "DPI-C" function void ifetch_num();



module ysyx_26040125_ALU(
        input signed [31:0] A, //srcR1 or PC
        input signed [31:0] B, //srcR2 or imm
        input [3:0] Opcode,
        output reg [31:0] Result
    );

    wire [31:0] add_res;
    wire [31:0] sub_res;
    wire [31:0] and_res;
    wire [31:0] or_res;
    wire [31:0] xor_res;
    wire [31:0] lt_res;
    wire [31:0] ge_res;
    wire [31:0] ltu_res;
    wire [31:0] geu_res;
    wire [31:0] eq_res;
    wire [31:0] ne_res;
    wire [31:0] sll_res;
    wire [31:0] srl_res;
    wire [31:0] sra_res;

    assign {add_res} = A + B;
    assign {sub_res} = A - B;
    assign and_res = A & B;
    assign or_res = A | B;
    assign xor_res = A ^ B;
    assign lt_res = (A < B) ? 32'h0000_0001 : 32'h0000_0000;
    assign ge_res = (A >= B) ? 32'h0000_0001 : 32'h0000_0000;
    assign eq_res = (A == B) ? 32'h0000_0001 : 32'h0000_0000;
    assign ne_res = (A != B) ? 32'h0000_0001 : 32'h0000_0000;
    assign sll_res = A << B[4:0];
    assign srl_res = A >> B[4:0];
    assign sra_res = A >>> B[4:0];
    assign ltu_res = ($unsigned(A) < $unsigned(B)) ? 32'h0000_0001 : 32'h0000_0000;
    assign geu_res = ($unsigned(A) >= $unsigned(B)) ? 32'h0000_0001 : 32'h0000_0000;

    always @(*) begin
        case (Opcode)
            `ysyx_26040125_ALU_OP_ADD:
                Result = add_res;
            `ysyx_26040125_ALU_OP_SUB:
                Result = sub_res;
            `ysyx_26040125_ALU_OP_AND:
                Result = and_res;
            `ysyx_26040125_ALU_OP_OR:
                Result = or_res;
            `ysyx_26040125_ALU_OP_XOR:
                Result = xor_res;
            `ysyx_26040125_ALU_OP_LT:
                Result = lt_res;
            `ysyx_26040125_ALU_OP_LTU:
                Result = ltu_res;
            `ysyx_26040125_ALU_OP_GE:
                Result = ge_res;
            `ysyx_26040125_ALU_OP_GEU:
                Result = geu_res;
            `ysyx_26040125_ALU_OP_EQ:
                Result = eq_res;
            `ysyx_26040125_ALU_OP_SLL:
                Result = sll_res;
            `ysyx_26040125_ALU_OP_SRL:
                Result = srl_res;
            `ysyx_26040125_ALU_OP_SRA:
                Result = sra_res;
            `ysyx_26040125_ALU_OP_NE:
                Result = ne_res;
            default:
                Result = 32'h0000_0000;
        endcase
    end
endmodule

module ysyx_26040125_ARB(
    input clk,
    input reset,

    /*axi lite port A*/
    input [31:0] s_axi_araddr_A,
    input s_axi_arvalid_A,
    output s_axi_arready_A,
    input [3:0] s_axi_arid_A,
    input [7:0] s_axi_arlen_A,
    input [2:0] s_axi_arsize_A,
    input [1:0] s_axi_arburst_A,

    output [31:0] s_axi_rdata_A,
    output [1:0] s_axi_rresp_A,
    output s_axi_rvalid_A,
    input s_axi_rready_A,
    output [3:0] s_axi_rid_A,
    output s_axi_rlast_A,

    input [31:0] s_axi_awaddr_A,
    input s_axi_awvalid_A,
    output s_axi_awready_A,
    input [3:0] s_axi_awid_A,
    input [7:0] s_axi_awlen_A,
    input [2:0] s_axi_awsize_A,
    input [1:0] s_axi_awburst_A,

    input [31:0] s_axi_wdata_A,
    input [3:0] s_axi_wstrb_A,
    input s_axi_wvalid_A,
    output s_axi_wready_A,
    input s_axi_wlast_A,

    output [1:0] s_axi_bresp_A,
    output s_axi_bvalid_A,
    input s_axi_bready_A,
    output [3:0] s_axi_bid_A,

    /*axi lite port B*/
    input [31:0] s_axi_araddr_B,
    input s_axi_arvalid_B,
    output s_axi_arready_B,
    input [3:0] s_axi_arid_B,
    input [7:0] s_axi_arlen_B,
    input [2:0] s_axi_arsize_B,
    input [1:0] s_axi_arburst_B,


    output [31:0] s_axi_rdata_B,
    output [1:0] s_axi_rresp_B,
    output s_axi_rvalid_B,
    input s_axi_rready_B,
    output [3:0] s_axi_rid_B,
    output s_axi_rlast_B,


    input [31:0] s_axi_awaddr_B,
    input s_axi_awvalid_B,
    output s_axi_awready_B,
    input [3:0] s_axi_awid_B,
    input [7:0] s_axi_awlen_B,
    input [2:0] s_axi_awsize_B,
    input [1:0] s_axi_awburst_B,

    input [31:0] s_axi_wdata_B,
    input [3:0] s_axi_wstrb_B,
    input s_axi_wvalid_B,
    output s_axi_wready_B,
    input s_axi_wlast_B,

    output [1:0] s_axi_bresp_B,
    output s_axi_bvalid_B,
    input s_axi_bready_B,
    output [3:0] s_axi_bid_B,

    /*axi lite output*/
    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,
    output [3:0] m_axi_arid,
    output [7:0] m_axi_arlen,
    output [2:0] m_axi_arsize,
    output [1:0] m_axi_arburst,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    input [3:0] m_axi_rid,
    input m_axi_rlast,
    input m_axi_rvalid,
    output m_axi_rready,

    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,
    output [3:0] m_axi_awid,
    output [7:0] m_axi_awlen,
    output [2:0] m_axi_awsize,
    output [1:0] m_axi_awburst,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    output m_axi_wlast,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
    input [3:0] m_axi_bid,
    output m_axi_bready
);

    localparam R_POLLINGA = 2'b00, R_POLLINGB = 2'b01, R_WORKINGA = 2'b10, R_WORKINGB = 2'b11;
    reg [1:0] r_state, r_next_state;

    always @(*) begin
        case(r_state)
            R_POLLINGA: begin
                if(s_axi_arvalid_A && s_axi_arready_A) begin
                    r_next_state = R_WORKINGA;
                end
                else begin
                    r_next_state = R_POLLINGB;
                end
            end

            R_POLLINGB: begin
                if(s_axi_arvalid_B && s_axi_arready_B) begin
                    r_next_state = R_WORKINGB;
                end
                else begin
                    r_next_state = R_POLLINGA;
                end
            end

            R_WORKINGA: begin
                if(s_axi_rvalid_A && s_axi_rready_A && s_axi_rlast_A) begin
                    r_next_state = R_POLLINGB;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            R_WORKINGB: begin
                if(s_axi_rvalid_B && s_axi_rready_B && s_axi_rlast_B) begin
                    r_next_state = R_POLLINGA;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            default: r_next_state = R_POLLINGA;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            r_state <= R_POLLINGA;
        end
        else begin
            r_state <= r_next_state;
        end
    end


    /*read addr channel*/
    assign s_axi_arready_A = (r_state == R_POLLINGA || r_state == R_WORKINGA) && m_axi_arready;
    assign s_axi_arready_B = (r_state == R_POLLINGB || r_state == R_WORKINGB) && m_axi_arready;
    assign m_axi_araddr = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_araddr_A : s_axi_araddr_B;
    assign m_axi_arvalid = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_arvalid_A : s_axi_arvalid_B;
    assign m_axi_arid = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_arid_A : s_axi_arid_B;
    assign m_axi_arlen = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_arlen_A : s_axi_arlen_B;
    assign m_axi_arsize = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_arsize_A : s_axi_arsize_B;
    assign m_axi_arburst = (r_state == R_POLLINGA || r_state == R_WORKINGA) ? s_axi_arburst_A : s_axi_arburst_B;

    /*read data channel*/
    assign s_axi_rdata_A = m_axi_rdata;
    assign s_axi_rresp_A = m_axi_rresp;
    assign s_axi_rvalid_A = (r_state == R_WORKINGA) && m_axi_rvalid;
    assign s_axi_rid_A = m_axi_rid;
    assign s_axi_rlast_A = m_axi_rlast;
    assign s_axi_rdata_B = m_axi_rdata;
    assign s_axi_rresp_B = m_axi_rresp;
    assign s_axi_rvalid_B = (r_state == R_WORKINGB) && m_axi_rvalid;
    assign s_axi_rid_B = m_axi_rid;
    assign s_axi_rlast_B = m_axi_rlast;
    assign m_axi_rready = (r_state == R_WORKINGA) ? s_axi_rready_A : s_axi_rready_B;


    localparam W_POLLINGA = 2'b00, W_POLLINGB = 2'b01, W_WORKINGA = 2'b10, W_WORKINGB = 2'b11;
    reg [1:0] w_state, w_next_state;

    always @(*) begin
        case(w_state)
            W_POLLINGA: begin
                if((s_axi_awvalid_A && s_axi_awready_A)||(s_axi_wvalid_A && s_axi_wready_A)) begin
                    w_next_state = W_WORKINGA;
                end
                else begin
                    w_next_state = W_POLLINGB;
                end
            end
            W_POLLINGB: begin
                if((s_axi_awvalid_B && s_axi_awready_B)||(s_axi_wvalid_B && s_axi_wready_B)) begin
                    w_next_state = W_WORKINGB;
                end
                else begin
                    w_next_state = W_POLLINGA;
                end
            end
            W_WORKINGA: begin
                if(s_axi_bvalid_A && s_axi_bready_A) begin
                    w_next_state = W_POLLINGB;
                end
                else begin
                    w_next_state = w_state;
                end
            end
            W_WORKINGB: begin
                if(s_axi_bvalid_B && s_axi_bready_B) begin
                    w_next_state = W_POLLINGA;
                end
                else begin
                    w_next_state = w_state;
                end
            end
            default: w_next_state = W_POLLINGA;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            w_state <= W_POLLINGA;
        end
        else begin
            w_state <= w_next_state;
        end
    end

    /*write addr channel*/
    assign s_axi_awready_A = (w_state == W_POLLINGA || w_state == W_WORKINGA) && m_axi_awready;
    assign s_axi_awready_B = (w_state == W_POLLINGB || w_state == W_WORKINGB) && m_axi_awready;
    assign m_axi_awaddr = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awaddr_A : s_axi_awaddr_B;
    assign m_axi_awvalid = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awvalid_A : s_axi_awvalid_B;
    assign m_axi_awid = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awid_A : s_axi_awid_B;
    assign m_axi_awlen = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awlen_A : s_axi_awlen_B;
    assign m_axi_awsize = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awsize_A : s_axi_awsize_B;
    assign m_axi_awburst = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_awburst_A : s_axi_awburst_B;

    /*write data channel*/
    assign s_axi_wready_A = (w_state == W_POLLINGA || w_state == W_WORKINGA) && m_axi_wready;
    assign s_axi_wready_B = (w_state == W_POLLINGB || w_state == W_WORKINGB) && m_axi_wready;
    assign m_axi_wdata = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wdata_A : s_axi_wdata_B;
    assign m_axi_wstrb = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wstrb_A : s_axi_wstrb_B;
    assign m_axi_wvalid = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wvalid_A : s_axi_wvalid_B;
    assign m_axi_wlast = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wlast_A : s_axi_wlast_B;
    
    /*write response channel*/
    assign s_axi_bresp_A = m_axi_bresp;
    assign s_axi_bresp_B = m_axi_bresp;
    assign s_axi_bvalid_A = (w_state == W_WORKINGA) && m_axi_bvalid;
    assign s_axi_bvalid_B = (w_state == W_WORKINGB) && m_axi_bvalid;
    assign s_axi_bid_A = m_axi_bid;
    assign s_axi_bid_B = m_axi_bid;
    assign m_axi_bready = (w_state == W_WORKINGA) ? s_axi_bready_A : s_axi_bready_B;
endmodule
    
module ysyx_26040125_BTB
#(
    parameter ENTRY_NUM = 8
)(
    input clk,
    input reset,

    input [31:0] PC_r,

    input [31:0] PC_w,
    input [31:0] target,
    input [1:0] meta_data, //bit1 for branch/jump, bit0 for taken/not taken
    input write_en,

    output reg [31:0] target_BTB,
    output reg [1:0] meta_data_BTB,
    output reg hit_BTB
);

    reg [31:0] PC_reg [ENTRY_NUM-1:0];
    reg [31:0] target_reg [ENTRY_NUM-1:0];
    reg [1:0] meta_data_reg [ENTRY_NUM-1:0];

    reg [$clog2(ENTRY_NUM)-1:0] wptr;

    always @(posedge clk) begin
        if(reset) begin
            for(integer i = 0; i < ENTRY_NUM; i = i + 1) begin
                PC_reg[i] <= 32'b0;
                target_reg[i] <= 32'b0;
                meta_data_reg[i] <= 2'b0;
            end

            wptr <= {$clog2(ENTRY_NUM){1'b0}};
        end
        else if(write_en) begin
            PC_reg[wptr] <= PC_w;
            target_reg[wptr] <= target;
            meta_data_reg[wptr] <= meta_data;
            wptr <= wptr + 1;
        end
    end

    always @(*) begin
        hit_BTB = 1'b0;
        target_BTB = 32'b0;
        meta_data_BTB = 2'b0;
        for(integer i = 0; i < ENTRY_NUM; i = i + 1) begin
            if(PC_reg[i] == PC_r) begin
                hit_BTB = 1'b1;
                target_BTB = target_reg[i];
                meta_data_BTB = meta_data_reg[i];
            end
        end
    end
endmodule

module ysyx_26040125_CSR(
    input clk,
    input reset,
    input [11:0] waddr, //write addr
    input [11:0] raddr, //read addr
    input [31:0] srcR1,
    input [31:0] alu_res,
    input wr_sel, //0: write srcR1, 1: write alu_res
    input wen,

    input exception,

    input [31:0] w_epc,
    input [31:0] w_cause,

    output reg [31:0] rdata,
    output [31:0] mtvec_out,
    output [31:0] mepc_out
);

    reg [31:0] mcycle;
    reg [31:0] mcycleh;
    reg [31:0] mvendorid;
    reg [31:0] marchid;
    reg [31:0] mtvec;
    reg [31:0] mepc;
    reg [31:0] mcause;

    //a combinational logic to read CSR, only take the mycle(h) into account
    always @(*) begin
        if(raddr == 12'hc00) rdata = mcycle; //mcycle
        else if(raddr == 12'hc80) rdata = mcycleh; //mcycleh
        else if(raddr == 12'hf11) rdata = mvendorid; //mvendorid
        else if(raddr == 12'hf12) rdata = marchid; //marchid
        else if(raddr == 12'h305) rdata = mtvec; //mtvec
        else if(raddr == 12'h341) rdata = mepc; //mepc
        else if(raddr == 12'h342) rdata = mcause; //mcause
        else rdata = 32'b0;
    end

    always @(posedge clk) begin
        if(reset) mtvec <= 32'b0;
        else if(wen && waddr == 12'h305) mtvec <= (wr_sel) ? alu_res : srcR1; //mtvec
    end

    always @(posedge clk) begin
        if(reset) mepc <= 32'b0;
        else if(exception) mepc <= w_epc; //write mepc with the current PC when exception happens
        else if(wen && waddr == 12'h341) mepc <= (wr_sel) ? alu_res : srcR1; //mepc
    end

    always @(posedge clk) begin
        if(reset) mcause <= 32'b0;
        else if(exception) mcause <= w_cause; //write mcause with the current cause when exception happens
        else if(wen && waddr == 12'h342) mcause <= (wr_sel) ? alu_res : srcR1; //mcause
    end

    always @(posedge clk) begin
        if(reset) mcycle <= 32'b0;
        else mcycle <= mcycle + 1;
    end
    
    always @(posedge clk) begin
        if(reset) mcycleh <= 32'b0;
        else if(mcycle == 32'hffff_ffff) mcycleh <= mcycleh + 1;
    end

    always @(posedge clk) begin
        if(reset) mvendorid <= 32'b0;
        else mvendorid <= 32'h79737978; //just a random value
    end

    always @(posedge clk) begin
        if(reset) marchid <= 32'b0;
        else marchid <= 32'h018D573D; //26040125 in hex
    end

    assign mtvec_out = mtvec;
    assign mepc_out = mepc;
endmodule

module ysyx_26040125_EXU(
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

    input [2:0] s_brju,
    input s_mem_signext,

    input [11:0] s_csr_addr,
    input [31:0] s_csr_data,
    input s_csr_wr_sel, //0: write srcR1, 1: write alu_res
    input s_csr_wen,

    input [31:0] s_PC,
    input s_fencei,
    input s_has_exception,
    input [3:0] s_exception_code,

    input [1:0] s_meta_data_BTB,
    input s_hit_BTB,

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
    output [31:0] m_srcR1,
    output [31:0] m_srcR2,
    output [31:0] m_result,
    output [31:0] m_PC,
    output [31:0] m_imm,
    output m_has_exception,
    output [3:0] m_exception_code,

    output m_valid,
    input m_ready,
    /*send data end*/

    output [4:0] rd_exu,
    output rd_valid_exu,
    output [11:0] csr_exu,
    output csr_valid_exu,

    output reg [31:0] forward_data_exu,
    output forward_ready_exu,
    output reg [31:0] csr_forward_data_exu,
    output csr_forward_ready_exu,

    /*To PCR*/
    output [31:0] pcr_exu_result,
    output [31:0] pcr_imm,
    output [2:0] pcr_behavior,
    output [31:0] pcr_pc_now,

    output reg flush,
    output cache_flush,
    input exception_flush,

    /*To the update of the BTB*/
    output [31:0] PC_w,
    output reg [31:0] target,
    output reg [1:0] meta_data,
    output reg write_en
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid & m_ready) begin
            perf_cnt_update(2);
            if(flush) begin
                flush_num();
            end
            if(brju != `ysyx_26040125_PC_NORMAL) begin
                branch_num();
            end
        end
    end
`endif

    /*logic to flush*/
    always @(*) begin
        if(m_valid && m_ready) begin
            if(hit_BTB) begin
                // if is jal, not flush
                if(meta_data_BTB[1]) begin
                    flush = 1'b0;
                end
                // if is branch
                else begin
                    // if predicted taken, but actually not taken, then flush
                    if(meta_data_BTB[0]) begin
                        flush = (m_result == 32'b0);
                    end

                    // if predicted not taken, but actually taken, then flush
                    else begin
                        flush = (m_result == 32'b1);
                    end
                end
            end

            else begin
                flush = fencei || (brju == `ysyx_26040125_PC_BRANCH && m_result == 32'b1) || (brju == `ysyx_26040125_PC_FAR) || (brju == `ysyx_26040125_PC_NEAR) || (brju == `ysyx_26040125_PC_MRET);
            end
        end

        else begin
            flush = 1'b0;
        end
    end

    /*logic to update BTB*/
    assign PC_w = PC_reg;
    always @(*) begin
        write_en = 1'b0;
        target = 32'b0;
        meta_data = 2'b0;
        if(m_valid && m_ready && !hit_BTB && (brju == `ysyx_26040125_PC_BRANCH || brju == `ysyx_26040125_PC_NEAR)) begin
            write_en = 1'b1;
            if(brju == `ysyx_26040125_PC_BRANCH) begin
                /*Use the BTFN(Backward Taken, Forward Not-taken)*/
                target = imm[31] ? PC_reg + imm : PC_reg + 32'd4;
                meta_data[1] = 1'b0;
                meta_data[0] = imm[31] ? 1'b1 : 1'b0;
            end

            else begin
                target = PC_reg + imm;
                meta_data[1] = 1'b1;
                meta_data[0] = 1'b1; // near jump is always taken
            end
        end
    end

    
    assign cache_flush = m_valid && m_ready && fencei;

    assign pcr_exu_result = m_result;
    assign pcr_imm = imm;
    assign pcr_behavior = brju;
    assign pcr_pc_now = PC_reg;

    assign rd_exu = rd;
    assign rd_valid_exu = valid_reg && wb_en && (rd != 5'b0);
    assign csr_exu = csr_addr;
    assign csr_valid_exu = valid_reg && csr_wen;

    always @(*) begin
        case(ysyx_26040125_WB_SEL)
            `ysyx_26040125_WB_SEL_IMM: forward_data_exu = imm;
            `ysyx_26040125_WB_SEL_ALU: forward_data_exu = m_result;
            `ysyx_26040125_WB_SEL_PC4: forward_data_exu = PC_reg + 4;
            `ysyx_26040125_WB_SEL_CSR: forward_data_exu = csr_data;
            default: forward_data_exu = 32'b0;
        endcase
    end

    always @(*) begin
        case(csr_wr_sel)
            `ysyx_26040125_CSR_SEL_RS1: csr_forward_data_exu = srcR1;
            `ysyx_26040125_CSR_SEL_ALU: csr_forward_data_exu = m_result;
            default: csr_forward_data_exu = 32'b0;
        endcase
    end
    assign forward_ready_exu = m_valid && (ysyx_26040125_WB_SEL != `ysyx_26040125_WB_SEL_MEM); //load instruction need to wait for MEM stage
    assign csr_forward_ready_exu = m_valid;

    reg [4:0] rd;
    reg [31:0] srcR1;
    reg [31:0] srcR2;
    reg [31:0] imm;

    reg [3:0] alu_op;
    reg [1:0] ysyx_26040125_ALU_SEL0; //sel the ALU A port is srcR1(0) or PC(1)
    reg [1:0] ysyx_26040125_ALU_SEL1; //sel the ALU B port is srcR2(0) or imm(1) or csr(2)

    reg wb_en;
    reg mem_en;
    reg mem_write_en;

    reg [1:0] ysyx_26040125_OP_WIDTH;
    reg [2:0] ysyx_26040125_WB_SEL; //imm; alu; mem; PC+4

    reg [2:0] brju;
    reg mem_signext;

    reg [11:0] csr_addr;
    reg [31:0] csr_data;
    reg csr_wr_sel; //0: write srcR1; 1: write alu_res
    reg csr_wen;

    reg [31:0] PC_reg;
    reg fencei;
    reg has_exception_reg;
    reg [3:0] exception_code_reg;

    reg [1:0] meta_data_BTB;
    reg hit_BTB;

    /*logic to recv data*/
    assign s_ready = !m_valid || (m_valid & m_ready);
    always @(posedge clk) begin
        if(reset) begin
            rd <= 5'b0;
            srcR1 <= 32'b0;
            srcR2 <= 32'b0;
            imm <= 32'b0;

            alu_op <= 4'b0;
            ysyx_26040125_ALU_SEL0 <= 2'b0; //sel the ALU A port is srcR1(0) or PC(1)
            ysyx_26040125_ALU_SEL1 <= 2'b0; //sel the ALU B port is srcR2(0) or imm(1) or csr(2)

            wb_en <= 1'b0;
            mem_en <= 1'b0;
            mem_write_en <= 1'b0;

            ysyx_26040125_OP_WIDTH <= 2'b0;
            ysyx_26040125_WB_SEL <= 3'b0; //imm; alu; mem; PC+4

            brju <= 3'b0;
            mem_signext <= 1'b0;

            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            csr_wr_sel <= 1'b0; //0: write srcR1; 1: write alu_res
            csr_wen <= 1'b0;

            PC_reg <= 32'b0;
            fencei <= 1'b0;
            has_exception_reg <= 1'b0;
            exception_code_reg <= 4'b0;

            meta_data_BTB <= 2'b0;
            hit_BTB <= 1'b0;
        end

        else if(s_valid && s_ready) begin
            rd <= s_rd;
            srcR1 <= s_srcR1;
            srcR2 <= s_srcR2;
            imm <= s_imm;

            alu_op <= s_alu_op;
            ysyx_26040125_ALU_SEL0 <= s_alu_sel0;
            ysyx_26040125_ALU_SEL1 <= s_alu_sel1;

            wb_en <= s_wb_en;
            mem_en <= s_mem_en;
            mem_write_en <= s_mem_write_en;

            ysyx_26040125_OP_WIDTH <= s_op_width;
            ysyx_26040125_WB_SEL <= s_wb_sel;

            brju <= s_brju;
            mem_signext <= s_mem_signext;

            csr_addr <= s_csr_addr;
            csr_data <= s_csr_data;
            csr_wr_sel <= s_csr_wr_sel;
            csr_wen <= s_csr_wen;

            PC_reg <= s_PC;
            fencei <= s_fencei;
            has_exception_reg <= s_has_exception;
            exception_code_reg <= s_exception_code;

            meta_data_BTB <= s_meta_data_BTB;
            hit_BTB <= s_hit_BTB;
        end
    end


    /*logic to send data*/
    assign m_rd = rd;
    assign m_wb_en = wb_en;
    assign m_mem_en = mem_en;
    assign m_mem_write_en = mem_write_en;
    assign m_op_width = ysyx_26040125_OP_WIDTH;
    assign m_wb_sel = ysyx_26040125_WB_SEL;
    assign m_mem_signext = mem_signext;
    assign m_csr_addr = csr_addr;
    assign m_csr_data = csr_data;
    assign m_csr_wr_sel = csr_wr_sel;
    assign m_csr_wen = csr_wen;
    assign m_srcR1 = srcR1;
    assign m_srcR2 = srcR2;
    assign m_PC = PC_reg;
    assign m_imm = imm;
    assign m_exception_code = exception_code_reg;
    assign m_has_exception = has_exception_reg;

    reg valid_reg;
    assign m_valid = valid_reg;

    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end
        else if(flush || exception_flush) begin
            valid_reg <= 1'b0;
        end
        else if(s_valid && s_ready) begin
            valid_reg <= 1'b1;
        end
        else if(m_ready && m_valid) begin
            valid_reg <= 1'b0;
        end

    end

    wire [31:0] alu_src1;
    wire [31:0] alu_src2;

    assign alu_src1 = (ysyx_26040125_ALU_SEL0 == `ysyx_26040125_ALU_SEL_RS1) ? srcR1 :
                      (ysyx_26040125_ALU_SEL0 == `ysyx_26040125_ALU_SEL_PC) ? PC_reg : 32'b0;
    assign alu_src2 = (ysyx_26040125_ALU_SEL1 == `ysyx_26040125_ALU_SEL_RS2) ? srcR2 :
                      (ysyx_26040125_ALU_SEL1 == `ysyx_26040125_ALU_SEL_IMM) ? imm :
                      (ysyx_26040125_ALU_SEL1 == `ysyx_26040125_ALU_SEL_CSR) ? csr_data : 32'b0;

    ysyx_26040125_ALU alu(
        .A(alu_src1),
        .B(alu_src2),
        .Opcode(alu_op),
        .Result(m_result)
    );

endmodule

module ysyx_26040125_GPR #(ADDR_WIDTH = 4, DATA_WIDTH = 32) (
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] wdata,
    input [ADDR_WIDTH-1:0] waddr,
    input wen,
    input [ADDR_WIDTH-1:0] raddr1,
    output [DATA_WIDTH-1:0]rdata1,
    input [ADDR_WIDTH-1:0] raddr2,
    output [DATA_WIDTH-1:0]rdata2
);
    reg [DATA_WIDTH-1:0] gpr [2**ADDR_WIDTH-1:0];
    integer i;

    always @(posedge clk) begin
        if(reset) begin
            for(i=0; i<2**ADDR_WIDTH; i=i+1) begin
                gpr[i] <= {DATA_WIDTH{1'b0}};
            end
        end
        else if(wen) gpr[waddr] <= (waddr == 4'b0) ? {DATA_WIDTH{1'b0}} : wdata;
    end

    assign rdata1 = gpr[raddr1];
    assign rdata2 = gpr[raddr2];
endmodule

module ysyx_26040125_ICACHE#(
    parameter LINE_NUM = 4,
    parameter LINE_SIZE = 16
)(
    input clk,
    input reset,

    input cache_flush,
    input flush,
    input exception_flush,

    /*axi stream bus*/
    input  [31:0] s_raddr,
    input  [1:0]  s_meta_data_BTB,
    input         s_hit_BTB,
    input         s_valid,
    output        s_ready,

    output [31:0] m_data,
    output [31:0] m_pc,
    output [1:0]  m_meta_data_BTB,
    output        m_hit_BTB,
    output        m_has_exception,
    output reg [3:0] m_exception_code,
    output        m_valid,
    input         m_ready,


    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,
    output [3:0] m_axi_arid,
    output [7:0] m_axi_arlen,
    output [2:0] m_axi_arsize,
    output [1:0] m_axi_arburst,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    /*verilator lint_off UNUSED */
    input [3:0] m_axi_rid,
    /*verilator lint_on UNUSED */
    input m_axi_rlast,
    input m_axi_rvalid,
    output m_axi_rready,

    /*verilator lint_off UNUSED */
    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,
    output [3:0] m_axi_awid,
    output [7:0] m_axi_awlen,
    output [2:0] m_axi_awsize,
    output [1:0] m_axi_awburst,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    output m_axi_wlast,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
    input [3:0] m_axi_bid,
    output m_axi_bready
    /*verilator lint_on UNUSED */
);

    `ifndef SYNTHESIS
        always @(posedge clk) begin
            if(s_valid && s_ready) begin
                if(hit) begin
                    ihit_num();
                end
                ifetch_num();
            end
        end
    `endif


    localparam TAG_SIZE = 32 - $clog2(LINE_NUM) - $clog2(LINE_SIZE);
    localparam WORDS_PER_LINE = LINE_SIZE / 4;
    localparam WORDS_SEL_SIZE = $clog2(WORDS_PER_LINE);
    /*unused axi signal(write channel)*/
    assign m_axi_awaddr = 32'b0;
    assign m_axi_awvalid = 1'b0;
    assign m_axi_awid = 4'b0000;
    assign m_axi_awlen = 8'b0;
    assign m_axi_awsize = 3'b0;
    assign m_axi_awburst = 2'b0;
    assign m_axi_wdata = 32'b0;
    assign m_axi_wstrb = 4'b0;
    assign m_axi_wvalid = 1'b0;
    assign m_axi_wlast = 1'b0;
    assign m_axi_bready = 1'b0;

    reg [LINE_SIZE*8-1:0] cache [LINE_NUM-1:0];
    reg [TAG_SIZE-1:0] tags [LINE_NUM-1:0];
    reg valid [LINE_NUM-1:0];

    wire [$clog2(LINE_NUM)-1:0] index = s_raddr[$clog2(LINE_SIZE)+$clog2(LINE_NUM)-1:$clog2(LINE_SIZE)];
    wire [TAG_SIZE-1:0] tag = s_raddr[31:$clog2(LINE_SIZE)+$clog2(LINE_NUM)];
    wire hit = valid[index] && tags[index] == tag;
    wire misaligned = s_raddr[1:0] != 2'b00;

    localparam HIT = 2'd0, REQ = 2'd1, WAIT = 2'd2, EXCEPTION = 2'd3;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            HIT: begin
                if(s_valid & s_ready) begin
                    if(misaligned) begin
                        next_state = EXCEPTION;
                    end
                    else if(hit) begin
                        next_state = HIT;
                    end
                    else begin
                        next_state = REQ;
                    end
                end
                else begin
                    next_state = state;
                end
            end
            
            REQ: begin
                if(flush || exception_flush) begin
                    next_state = HIT;
                end
                else if(m_axi_arvalid && m_axi_arready) begin
                    next_state = WAIT;
                end
                else begin
                    next_state = state;
                end
            end
            WAIT: begin
                if(m_axi_rvalid && m_axi_rready) begin
                    if(m_axi_rresp != 2'b00) begin
                        next_state = EXCEPTION;
                    end
                    else if(m_axi_rlast) begin
                        next_state = HIT;
                    end
                    else begin
                        next_state = state;
                    end
                end
                else begin
                    next_state = state;
                end
            end
            
            EXCEPTION: begin
                if(s_valid & s_ready) begin
                    if(misaligned) begin
                        next_state = EXCEPTION;
                    end
                    else if(hit) begin
                        next_state = HIT;
                    end
                    else begin
                        next_state = REQ;
                    end
                end
                else begin
                    next_state = state;
                end
            end
            default: next_state = HIT;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            state <= HIT;
        end
        else begin
            state <= next_state;
        end
    end

    /*handle the exception*/
    always @(posedge clk) begin
        if(reset) begin
            m_exception_code <= 4'b0;
        end
        
        else if(s_valid && s_ready && misaligned) begin
            m_exception_code <= 4'd0; // fetch address misaligned
        end

        else if(m_axi_rvalid && m_axi_rready && m_axi_rresp != 2'b00) begin
            m_exception_code <= 4'd1; // fetch access fault
        end
    end


    /*logic to latch data*/
    reg valid_reg;

    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end

        else if(flush || exception_flush) begin
            valid_reg <= 1'b0;
        end

        else if(s_valid && s_ready) begin
            valid_reg <= 1'b1;
        end

        else if(m_valid && m_ready) begin
            valid_reg <= 1'b0;
        end
    end

    reg [31:0] addr_reg;
    reg [1:0] meta_data_BTB_reg;
    reg hit_BTB_reg;
    wire [$clog2(LINE_NUM)-1:0] index_reg = addr_reg[$clog2(LINE_SIZE)+$clog2(LINE_NUM)-1:$clog2(LINE_SIZE)];
    wire [TAG_SIZE-1:0] tag_reg = addr_reg[31:$clog2(LINE_SIZE)+$clog2(LINE_NUM)];
    wire [WORDS_SEL_SIZE-1:0] word_sel = addr_reg[$clog2(LINE_SIZE)-1:2];
    always @(posedge clk) begin
        if(reset) begin
            addr_reg <= 32'b0;
            meta_data_BTB_reg <= 2'b0;
            hit_BTB_reg <= 1'b0;
        end
        else if(s_valid && s_ready) begin
            addr_reg <= s_raddr;
            meta_data_BTB_reg <= s_meta_data_BTB;
            hit_BTB_reg <= s_hit_BTB;
        end
    end


    /*logic to update cache*/
    integer i;
    reg [3:0] recv_counter;
    always @(posedge clk) begin
        if(reset || cache_flush) begin
            for(i = 0; i < LINE_NUM; i = i + 1) begin
                valid[i] <= 1'b0;
                tags[i] <= {TAG_SIZE{1'b0}};
                cache[i] <= {(LINE_SIZE*8){1'b0}};
            end
            recv_counter <= 4'b0;
        end
        else if(m_axi_rvalid && m_axi_rready) begin
            cache[index_reg][recv_counter*32 +: 32] <= m_axi_rdata;
            tags[index_reg] <= tag_reg;
            valid[index_reg] <= 1'b1;
            if(m_axi_rlast) begin
                recv_counter <= 4'b0;
            end
            else begin
                recv_counter <= recv_counter + 1;
            end
        end
    end

    assign s_ready = (state == HIT || state == EXCEPTION) && (!valid_reg || (m_valid && m_ready));
    assign m_data = cache[index_reg][word_sel*32 +: 32];
    assign m_has_exception = state == EXCEPTION;
    assign m_valid = (state == HIT || state == EXCEPTION) && valid_reg;
    assign m_pc = addr_reg;
    assign m_meta_data_BTB = meta_data_BTB_reg;
    assign m_hit_BTB = hit_BTB_reg;

    assign m_axi_araddr = {addr_reg[31:4], 4'b0};
    assign m_axi_arvalid = (state == REQ) && !flush && !exception_flush;
    assign m_axi_arid = 4'b0;
    assign m_axi_arlen = WORDS_PER_LINE-1;
    assign m_axi_arsize = 3'd2;
    assign m_axi_arburst = 2'b01; // INCR
    assign m_axi_rready = state == WAIT;
endmodule

module ysyx_26040125_IDU(
    input clk,
    input reset,

    input flush,
    input exception_flush,

    /* explict ports*/
    input [31:0] s_Inst,
    input [31:0] s_PC,
    input [1:0] s_meta_data_BTB,
    input s_hit_BTB,
    input s_has_exception,
    input [3:0] s_exception_code,
    input s_valid,
    output s_ready,

    output [1:0] m_meta_data_BTB,
    output m_hit_BTB,
    output [4:0] m_rd,
    output reg [31:0] m_srcR1,
    output reg [31:0] m_srcR2,
    output reg [31:0] m_imm,

    output reg [3:0] m_alu_op,
    output reg [1:0] m_alu_sel0, //sel the ALU A port is m_srcR1(0) or PC(1)
    output reg [1:0] m_alu_sel1, //sel the ALU B port is m_srcR2(0) or m_imm(1) or csr(2)

    output m_wb_en,
    output m_mem_en,
    output m_mem_write_en,

    output [1:0] m_op_width,
    output [2:0] m_wb_sel, //m_imm, alu, mem, PC+4

    output reg [2:0] m_brju,
    output reg m_mem_signext,

    output reg [11:0] m_csr_addr,
    output reg [31:0] m_csr_data,
    output reg m_csr_wr_sel, //0: write m_srcR1, 1: write alu_res
    output reg m_csr_wen,

    output [31:0] m_PC,

    output m_fencei,
    output m_has_exception,
    output reg [3:0] m_exception_code,

    output m_valid,
    input m_ready,

    /*implict ports for read GPRs and CSRs*/
    output [4:0] rs1,
    output [4:0] rs2,
    output [11:0] csr_addr,
    input [31:0] srcR1_in,
    input [31:0] srcR2_in,
    input [31:0] csr_data,

    /*handle the RAW*/
    input [4:0] rd_exu,
    input [11:0] csr_exu,
    input rd_valid_exu,
    input csr_valid_exu,
    input [4:0] rd_lsu,
    input [11:0] csr_lsu,
    input rd_valid_lsu,
    input csr_valid_lsu,
    input [4:0] rd_wbu,
    input [11:0] csr_wbu,
    input rd_valid_wbu,
    input csr_valid_wbu,

    /*for load-use*/
    input [31:0] forward_data_exu,
    input forward_ready_exu,
    input [31:0] csr_forward_data_exu,
    input csr_forward_ready_exu,
    input [31:0] forward_data_lsu,
    input forward_ready_lsu,
    input [31:0] csr_forward_data_lsu,
    input csr_forward_ready_lsu,
    input [31:0] forward_data_wbu,
    input forward_ready_wbu,
    input [31:0] csr_forward_data_wbu,
    input csr_forward_ready_wbu
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid & m_ready) begin
            perf_cnt_update(1);
            itrace(inst_reg, pc_reg);
        end
    end
`endif


    wire stall;
    reg need_rs2;

    ysyx_26040125_RAW u_RAW(
        .rs1                   	( rs1                    ),
        .rs2                   	( rs2                    ),
        .need_rs2              	( need_rs2               ),
        .csr_addr              	( csr_addr               ),
        .rd_exu                	( rd_exu                 ),
        .rd_valid_exu          	( rd_valid_exu           ),
        .forward_ready_exu     	( forward_ready_exu      ),
        .csr_exu               	( csr_exu                ),
        .csr_valid_exu         	( csr_valid_exu          ),
        .csr_forward_ready_exu 	( csr_forward_ready_exu  ),
        .rd_lsu                	( rd_lsu                 ),
        .rd_valid_lsu          	( rd_valid_lsu           ),
        .forward_ready_lsu     	( forward_ready_lsu      ),
        .csr_lsu               	( csr_lsu                ),
        .csr_valid_lsu         	( csr_valid_lsu          ),
        .csr_forward_ready_lsu 	( csr_forward_ready_lsu  ),
        .rd_wbu                	( rd_wbu                 ),
        .rd_valid_wbu          	( rd_valid_wbu           ),
        .forward_ready_wbu     	( forward_ready_wbu      ),
        .csr_wbu               	( csr_wbu                ),
        .csr_valid_wbu         	( csr_valid_wbu          ),
        .csr_forward_ready_wbu 	( csr_forward_ready_wbu  ),
        .stall                 	( stall                  )
    );



    /*logic to recv data*/
    reg [31:0] inst_reg;
    reg [31:0] pc_reg;
    reg [1:0] meta_data_BTB_reg;
    reg hit_BTB_reg;
    reg has_exception_reg;
    reg [3:0] exception_code_reg;
    assign s_ready = (!m_valid || (m_valid & m_ready)) && !stall;
    always @(posedge clk) begin
        if(reset) begin
            inst_reg <= 32'b0;
            pc_reg <= 32'b0;
            meta_data_BTB_reg <= 2'b0;
            hit_BTB_reg <= 1'b0;
            has_exception_reg <= 1'b0;
            exception_code_reg <= 4'b0;
        end
        else begin
            if(s_ready & s_valid) begin
                inst_reg <= s_Inst;
                pc_reg <= s_PC;
                meta_data_BTB_reg <= s_meta_data_BTB;
                hit_BTB_reg <= s_hit_BTB;
                has_exception_reg <= s_has_exception;
                exception_code_reg <= s_exception_code;
            end
        end
    end

    /*logic to send data*/
    assign m_PC = pc_reg;
    //***_reg is to the value recv from last module, and *** is this module's exception
    assign m_has_exception = has_exception_reg || has_exception;
    always @(*) begin
        if(has_exception_reg) begin
            m_exception_code = exception_code_reg;
        end
        else begin
            m_exception_code = exception_code;
        end
    end
    reg valid_reg;
    assign m_valid = valid_reg && !stall;
    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end

        else begin
            if(flush || exception_flush) begin
                valid_reg <= 1'b0;
            end
            else if(s_valid & s_ready) begin
                valid_reg <= 1'b1;
            end
            else if(m_valid & m_ready) begin
                valid_reg <= 1'b0;
            end
        end
    end


    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    /*all of the m_imm are sign-extended to 32 bits*/
    wire [31:0] immI;
    wire [31:0] immS;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immJ;

    assign csr_addr = m_csr_addr;

    always @(*) begin
        if(csr_addr == csr_exu && csr_valid_exu && csr_forward_ready_exu) begin
            m_csr_data = csr_forward_data_exu;
        end
        else if(csr_addr == csr_lsu && csr_valid_lsu && csr_forward_ready_lsu) begin
            m_csr_data = csr_forward_data_lsu;
        end
        else if(csr_addr == csr_wbu && csr_valid_wbu && csr_forward_ready_wbu) begin
            m_csr_data = csr_forward_data_wbu;
        end
        else begin
            m_csr_data = csr_data;
        end
    end


    always @(*) begin
        if(rs1 == rd_exu && rd_valid_exu && forward_ready_exu) begin
            m_srcR1 = forward_data_exu;
        end
        else if(rs1 == rd_lsu && rd_valid_lsu && forward_ready_lsu) begin
            m_srcR1 = forward_data_lsu;
        end
        else if(rs1 == rd_wbu && rd_valid_wbu && forward_ready_wbu) begin
            m_srcR1 = forward_data_wbu;
        end
        else begin
            m_srcR1 = srcR1_in;
        end
    end

    always @(*) begin
        if(rs2 == rd_exu && rd_valid_exu && forward_ready_exu) begin
            m_srcR2 = forward_data_exu;
        end
        else if(rs2 == rd_lsu && rd_valid_lsu && forward_ready_lsu) begin
            m_srcR2 = forward_data_lsu;
        end
        else if(rs2 == rd_wbu && rd_valid_wbu && forward_ready_wbu) begin
            m_srcR2 = forward_data_wbu;
        end
        else begin
            m_srcR2 = srcR2_in;
        end
    end



    assign rs1 = inst_reg[19:15];
    assign rs2 = inst_reg[24:20];
    assign m_rd = inst_reg[11:7];
    assign opcode = inst_reg[6:0];
    assign funct3 = inst_reg[14:12];
    assign funct7 = inst_reg[31:25];

    assign m_meta_data_BTB = meta_data_BTB_reg;
    assign m_hit_BTB = hit_BTB_reg;


    assign immI = { {20{inst_reg[31]}}, inst_reg[31:20] };
    assign immS = { {20{inst_reg[31]}}, inst_reg[31:25], inst_reg[11:7] };
    assign immB = { {19{inst_reg[31]}}, inst_reg[31], inst_reg[7], inst_reg[30:25], inst_reg[11:8], 1'b0 };
    assign immU = { inst_reg[31:12], 12'b0 };
    assign immJ = { {11{inst_reg[31]}}, inst_reg[31], inst_reg[19:12], inst_reg[20], inst_reg[30:21], 1'b0 };


    reg has_exception;
    reg [3:0] exception_code;

    always @(*) begin
        // --- safe defaults (all zeros, which map to ysyx_26040125_PC_NORMAL / ysyx_26040125_ALU_SEL_RS1 / ysyx_26040125_ALU_SEL_RS2) ---
        m_imm          = 0;
        m_alu_op       = 0;
        m_wb_en        = 0;
        m_mem_write_en = 0;
        m_op_width     = 0;
        m_wb_sel       = 0;
        m_alu_sel0     = 0;
        m_alu_sel1     = 0;
        m_brju         = `ysyx_26040125_PC_NORMAL;
        m_mem_signext  = 0;
        m_mem_en       = 0;
        m_csr_wr_sel   = 0;
        m_csr_wen      = 0;
        m_csr_addr     = 0;
        m_fencei       = 0;
        need_rs2       = 0;
        has_exception  = 0;
        exception_code = 0;

        case(opcode)
            7'b1100011: begin //branch  — all share immB / RS1 vs RS2 / ysyx_26040125_PC_BRANCH
                m_imm      = immB;
                m_alu_sel0 = `ysyx_26040125_ALU_SEL_RS1;
                m_alu_sel1 = `ysyx_26040125_ALU_SEL_RS2;
                m_brju     = `ysyx_26040125_PC_BRANCH;
                need_rs2   = 1;
                case(funct3)
                    3'b000: m_alu_op = `ysyx_26040125_ALU_OP_EQ;   //beq
                    3'b001: m_alu_op = `ysyx_26040125_ALU_OP_NE;   //bne
                    3'b100: m_alu_op = `ysyx_26040125_ALU_OP_LT;   //blt
                    3'b101: m_alu_op = `ysyx_26040125_ALU_OP_GE;   //bge
                    3'b110: m_alu_op = `ysyx_26040125_ALU_OP_LTU;  //bltu
                    3'b111: m_alu_op = `ysyx_26040125_ALU_OP_GEU;  //bgeu
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b1101111: begin //jal
                m_imm    = immJ;
                m_wb_en  = 1;
                m_wb_sel = `ysyx_26040125_WB_SEL_PC4;
                m_brju   = `ysyx_26040125_PC_NEAR;
            end

            7'b1100111: begin //jalr
                case(funct3)
                    3'b000: begin
                        m_imm      = immI;
                        m_alu_op   = `ysyx_26040125_ALU_OP_ADD;
                        m_wb_en    = 1;
                        m_wb_sel   = `ysyx_26040125_WB_SEL_PC4;
                        m_alu_sel0 = `ysyx_26040125_ALU_SEL_RS1;
                        m_alu_sel1 = `ysyx_26040125_ALU_SEL_IMM;
                        m_brju     = `ysyx_26040125_PC_FAR;
                    end
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b0110111: begin //lui
                m_imm    = immU;
                m_wb_en  = 1;
                m_wb_sel = `ysyx_26040125_WB_SEL_IMM;
            end

            7'b0010111: begin //auipc
                m_imm      = immU;
                m_alu_op   = `ysyx_26040125_ALU_OP_ADD;
                m_wb_en    = 1;
                m_wb_sel   = `ysyx_26040125_WB_SEL_ALU;
                m_alu_sel0 = `ysyx_26040125_ALU_SEL_PC;
                m_alu_sel1 = `ysyx_26040125_ALU_SEL_IMM;
            end

            7'b0110011: begin //OP  — all share m_wb_en=1 / ysyx_26040125_WB_SEL_ALU / RS1 vs RS2
                m_wb_en    = 1;
                m_wb_sel   = `ysyx_26040125_WB_SEL_ALU;
                m_alu_sel0 = `ysyx_26040125_ALU_SEL_RS1;
                m_alu_sel1 = `ysyx_26040125_ALU_SEL_RS2;
                need_rs2   = 1;
                case(funct3)
                    3'b000: m_alu_op = (funct7 == 7'b0100000) ? `ysyx_26040125_ALU_OP_SUB : `ysyx_26040125_ALU_OP_ADD; //add/sub
                    3'b001: m_alu_op = `ysyx_26040125_ALU_OP_SLL;  //sll
                    3'b010: m_alu_op = `ysyx_26040125_ALU_OP_LT;   //slt
                    3'b011: m_alu_op = `ysyx_26040125_ALU_OP_LTU;  //sltu
                    3'b100: m_alu_op = `ysyx_26040125_ALU_OP_XOR;  //xor
                    3'b101: m_alu_op = (funct7 == 7'b0100000) ? `ysyx_26040125_ALU_OP_SRA : `ysyx_26040125_ALU_OP_SRL; //srl/sra
                    3'b110: m_alu_op = `ysyx_26040125_ALU_OP_OR;   //or
                    3'b111: m_alu_op = `ysyx_26040125_ALU_OP_AND;  //and
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b0010011: begin //OP-IMM  — all share immI / m_wb_en=1 / ysyx_26040125_WB_SEL_ALU / RS1 / IMM
                m_imm      = immI;
                m_wb_en    = 1;
                m_wb_sel   = `ysyx_26040125_WB_SEL_ALU;
                m_alu_sel0 = `ysyx_26040125_ALU_SEL_RS1;
                m_alu_sel1 = `ysyx_26040125_ALU_SEL_IMM;
                case(funct3)
                    3'b000: m_alu_op = `ysyx_26040125_ALU_OP_ADD;  //addi
                    3'b001: m_alu_op = `ysyx_26040125_ALU_OP_SLL;  //slli
                    3'b010: m_alu_op = `ysyx_26040125_ALU_OP_LT;   //slti
                    3'b011: m_alu_op = `ysyx_26040125_ALU_OP_LTU;  //sltiu
                    3'b100: m_alu_op = `ysyx_26040125_ALU_OP_XOR;  //xori
                    3'b101: m_alu_op = (funct7 == 7'b0100000) ? `ysyx_26040125_ALU_OP_SRA : `ysyx_26040125_ALU_OP_SRL; //srli/srai
                    3'b110: m_alu_op = `ysyx_26040125_ALU_OP_OR;   //ori
                    3'b111: m_alu_op = `ysyx_26040125_ALU_OP_AND;  //andi
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b0000011: begin //LOAD  — all share immI / ADD / m_wb_en=1 / ysyx_26040125_WB_SEL_MEM / RS1 / IMM / m_mem_en=1
                m_imm      = immI;
                m_alu_op   = `ysyx_26040125_ALU_OP_ADD;
                m_wb_en    = 1;
                m_wb_sel   = `ysyx_26040125_WB_SEL_MEM;
                m_alu_sel0 = `ysyx_26040125_ALU_SEL_RS1;
                m_alu_sel1 = `ysyx_26040125_ALU_SEL_IMM;
                m_mem_en   = 1;
                case(funct3)
                    3'b000: begin m_op_width = `ysyx_26040125_OP_WIDTH_BYTE; m_mem_signext = 1; end //lb
                    3'b001: begin m_op_width = `ysyx_26040125_OP_WIDTH_HALF; m_mem_signext = 1; end //lh
                    3'b010: begin m_op_width = `ysyx_26040125_OP_WIDTH_WORD; m_mem_signext = 1; end //lw
                    3'b100: begin m_op_width = `ysyx_26040125_OP_WIDTH_BYTE; m_mem_signext = 0; end //lbu
                    3'b101: begin m_op_width = `ysyx_26040125_OP_WIDTH_HALF; m_mem_signext = 0; end //lhu
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b0100011: begin //STORE  — all share immS / ADD / m_mem_write_en=1 / RS1 / IMM / m_mem_en=1
                m_imm          = immS;
                m_alu_op       = `ysyx_26040125_ALU_OP_ADD;
                m_mem_write_en = 1;
                m_alu_sel0     = `ysyx_26040125_ALU_SEL_RS1;
                m_alu_sel1     = `ysyx_26040125_ALU_SEL_IMM;
                m_mem_en       = 1;
                need_rs2       = 1;
                case(funct3)
                    3'b000: m_op_width = `ysyx_26040125_OP_WIDTH_BYTE; //sb
                    3'b001: m_op_width = `ysyx_26040125_OP_WIDTH_HALF; //sh
                    3'b010: m_op_width = `ysyx_26040125_OP_WIDTH_WORD; //sw
                    default:begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b1110011: begin //SYSTEM
                case(funct3)
                    3'b000: begin
                        if(funct7 == 7'b0000000 && rs2 == 5'b00001) begin
                            has_exception = 1;
                            exception_code = 4'd3; // breakpoint
                        end
                        else if(funct7 == 7'b0000000 && rs2 == 5'b00000) begin //m_ecall
                            has_exception = 1;
                            exception_code = 4'd11; // ecall from M-mode
                        end
                        else if(funct7 == 7'b0011000 && rs2 == 5'b00010) begin //m_mret
                            m_brju = `ysyx_26040125_PC_MRET;
                        end
                        else begin
                            has_exception = 1;
                            exception_code = 4'd2; // illegal instruction
                        end
                        
                    end

                    3'b001: begin //csrrw
                        m_wb_en      = 1;
                        m_wb_sel     = `ysyx_26040125_WB_SEL_CSR;
                        m_csr_wr_sel = `ysyx_26040125_CSR_SEL_RS1;
                        m_csr_wen    = 1;
                        m_csr_addr = inst_reg[31:20];
                    end

                    3'b010: begin //csrrs
                        m_alu_op     = `ysyx_26040125_ALU_OP_OR;
                        m_wb_en      = 1;
                        m_wb_sel     = `ysyx_26040125_WB_SEL_CSR;
                        m_alu_sel0   = `ysyx_26040125_ALU_SEL_RS1;
                        m_alu_sel1   = `ysyx_26040125_ALU_SEL_CSR;
                        m_csr_wr_sel = `ysyx_26040125_CSR_SEL_ALU;
                        m_csr_wen    = 1;
                        m_csr_addr = inst_reg[31:20];
                    end
                    default: begin
                        has_exception = 1;
                        exception_code = 4'd2; // illegal instruction
                    end
                endcase
            end

            7'b0001111: begin //FENCE
                m_fencei = (funct3 == 3'b001);
            end

            default:begin
                has_exception = 1;
                exception_code = 4'd2; // illegal instruction
            end
        endcase 
    end

endmodule

module ysyx_26040125_IFU(
    input clk,
    input reset,

    output [31:0] m_Inst,
    output [31:0] m_PC,
    output [1:0] m_meta_data_BTB,
    output m_hit_BTB,
    output m_has_exception,
    output [3:0] m_exception_code,
    output m_valid,
    input m_ready,

    input [31:0] PC,
    input [1:0] meta_data_BTB,
    input hit_BTB,

    input flush,
    input cache_flush,
    input exception_flush,

    //axi interface to RAM
    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,
    output [3:0] m_axi_arid,
    output [7:0] m_axi_arlen,
    output [2:0] m_axi_arsize,
    output [1:0] m_axi_arburst,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    input [3:0] m_axi_rid,
    input m_axi_rlast,
    input m_axi_rvalid,
    output m_axi_rready,

    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,
    output [3:0] m_axi_awid,
    output [7:0] m_axi_awlen,
    output [2:0] m_axi_awsize,
    output [1:0] m_axi_awburst,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    output m_axi_wlast,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
    input [3:0] m_axi_bid,
    output m_axi_bready,
    /*verilator lint_on UNUSED*/

    output pc_en
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid && m_ready) begin
            perf_cnt_update(0);
        end
    end

    always @(*) begin
        if(PC==32'h00000010) begin
            sim_exit();
        end
    end
`endif


    wire s_ready;
    wire s_valid = 1'b1;

    ysyx_26040125_ICACHE #(
        .LINE_NUM  	( 4  ),
        .LINE_SIZE 	( 16  ))
    u_ICACHE(
        .clk            	( clk             ),
        .reset          	( reset           ),
        .cache_flush    	( cache_flush     ),
        .flush          	( flush           ),
        .exception_flush    ( exception_flush ),

        .s_raddr            ( PC    ),
        .s_meta_data_BTB    ( meta_data_BTB    ),
        .s_hit_BTB          ( hit_BTB         ),
        .s_valid            ( s_valid   ),
        .s_ready            ( s_ready   ),
        .m_data             ( m_Inst     ),
        .m_pc               ( m_PC  ),
        .m_meta_data_BTB    ( m_meta_data_BTB ),
        .m_hit_BTB          ( m_hit_BTB         ),
        .m_has_exception    ( m_has_exception ),
        .m_exception_code   ( m_exception_code ),
        .m_valid            ( m_valid    ),
        .m_ready            ( m_ready    ),

        .m_axi_araddr   	( m_axi_araddr    ),
        .m_axi_arvalid  	( m_axi_arvalid   ),
        .m_axi_arready  	( m_axi_arready   ),
        .m_axi_arid     	( m_axi_arid      ),
        .m_axi_arlen    	( m_axi_arlen     ),
        .m_axi_arsize   	( m_axi_arsize    ),
        .m_axi_arburst  	( m_axi_arburst   ),
        .m_axi_rdata    	( m_axi_rdata     ),
        .m_axi_rresp    	( m_axi_rresp     ),
        .m_axi_rid      	( m_axi_rid       ),
        .m_axi_rlast    	( m_axi_rlast     ),
        .m_axi_rvalid   	( m_axi_rvalid    ),
        .m_axi_rready   	( m_axi_rready    ),
        .m_axi_awaddr   	( m_axi_awaddr    ),
        .m_axi_awvalid  	( m_axi_awvalid   ),
        .m_axi_awready  	( m_axi_awready   ),
        .m_axi_awid     	( m_axi_awid      ),
        .m_axi_awlen    	( m_axi_awlen     ),
        .m_axi_awsize   	( m_axi_awsize    ),
        .m_axi_awburst  	( m_axi_awburst   ),
        .m_axi_wdata    	( m_axi_wdata     ),
        .m_axi_wstrb    	( m_axi_wstrb     ),
        .m_axi_wvalid   	( m_axi_wvalid    ),
        .m_axi_wlast    	( m_axi_wlast     ),
        .m_axi_wready   	( m_axi_wready    ),
        .m_axi_bresp    	( m_axi_bresp     ),
        .m_axi_bvalid   	( m_axi_bvalid    ),
        .m_axi_bid      	( m_axi_bid       ),
        .m_axi_bready   	( m_axi_bready    )
    );


    assign pc_en = s_valid && s_ready;



endmodule

module ysyx_26040125_LSU(
    input clk,
    input reset,

    /*data to recv*/
    input [4:0] s_rd,
    input s_wb_en,
    input s_mem_en,
    input s_mem_write_en,
    input [1:0] s_op_width,
    input [2:0] s_wb_sel,
    input s_mem_signext,
    input [11:0] s_csr_addr,
    input [31:0] s_csr_data,
    input s_csr_wr_sel,
    input s_csr_wen,
    input [31:0] s_srcR1,
    input [31:0] s_srcR2,
    input [31:0] s_result,
    input [31:0] s_PC,
    input [31:0] s_imm,
    input s_has_exception,
    input [3:0] s_exception_code,

    input s_valid,
    output s_ready,
    /*data to recv end*/

    /*data to send*/
    output [4:0] m_rd,
    output m_wb_en,
    output [2:0] m_wb_sel,
    output [11:0] m_csr_addr,
    output [31:0] m_csr_data,
    output m_csr_wr_sel,
    output m_csr_wen,
    output [31:0] m_srcR1,
    output [31:0] m_result,
    output [31:0] m_rdata,
    output [31:0] m_PC,
    output [31:0] m_imm,
    output m_has_exception,
    output reg [3:0] m_exception_code,

    output m_valid,
    input m_ready,
    /*data to send end*/

    //bus to interact with RAM
    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,
    output [3:0] m_axi_arid,
    output [7:0] m_axi_arlen,
    output [2:0] m_axi_arsize,
    output [1:0] m_axi_arburst,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    /*verilator lint_off UNUSED */
    input [3:0] m_axi_rid,
    input m_axi_rlast,
    /*verilator lint_on UNUSED */
    input m_axi_rvalid,
    output m_axi_rready,

    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,
    output [3:0] m_axi_awid,
    output [7:0] m_axi_awlen,
    output [2:0] m_axi_awsize,
    output [1:0] m_axi_awburst,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    output m_axi_wlast,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
    /*verilator lint_off UNUSED */
    input [3:0] m_axi_bid,
    output m_axi_bready,
    /*verilator lint_on UNUSED */

    /*To the RAW module*/
    output [4:0] rd_lsu,
    output rd_valid_lsu,
    output [11:0] csr_lsu,
    output csr_valid_lsu,

    /*For the load-use*/
    output reg [31:0] forward_data_lsu,
    output forward_ready_lsu,
    output reg [31:0] csr_forward_data_lsu,
    output csr_forward_ready_lsu,

    input exception_flush
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid & m_ready) begin
            perf_cnt_update(3);
        end
    end
`endif

    reg [3:0] exception_code;
    /*handle the exception*/
    always @(posedge clk) begin
        if(reset) begin
            exception_code <= 4'b0;
        end
        
        else if(s_mem_en && 
            ((s_op_width == `ysyx_26040125_OP_WIDTH_HALF && s_result[0] != 1'b0) || 
            (s_op_width == `ysyx_26040125_OP_WIDTH_WORD && s_result[1:0] != 2'b00))) begin
            if(s_mem_write_en) exception_code <= 4'd6;
            else exception_code <= 4'd4;
        end

        else if(m_axi_rvalid && m_axi_rready && m_axi_rresp != 2'b00) begin
            exception_code <= 4'd5; // load access fault
        end

        else if(m_axi_bvalid && m_axi_bready && m_axi_bresp != 2'b00) begin
            exception_code <= 4'd7; //store access fault
        end
    end

    reg valid_reg;
    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end

        else if(exception_flush) begin
            valid_reg <= 1'b0;
        end
        else if(s_valid && s_ready) begin
            valid_reg <= 1'b1;
        end
        else if(m_ready && m_valid) begin
            valid_reg <= 1'b0;
        end
    end

    assign rd_lsu = rd;
    assign rd_valid_lsu = valid_reg && wb_en && (rd != 5'b0);
    assign csr_lsu = csr_addr;
    assign csr_valid_lsu = valid_reg && csr_wen;

    always @(*) begin
        case(ysyx_26040125_WB_SEL)
            `ysyx_26040125_WB_SEL_IMM: forward_data_lsu = imm;
            `ysyx_26040125_WB_SEL_ALU: forward_data_lsu = m_result;
            `ysyx_26040125_WB_SEL_PC4: forward_data_lsu = PC + 4;
            `ysyx_26040125_WB_SEL_MEM: forward_data_lsu = m_rdata;
            `ysyx_26040125_WB_SEL_CSR: forward_data_lsu = csr_data;
            default: forward_data_lsu = 32'b0;
        endcase
    end

    always @(*) begin
        case(csr_wr_sel)
            `ysyx_26040125_CSR_SEL_RS1: csr_forward_data_lsu = srcR1;
            `ysyx_26040125_CSR_SEL_ALU: csr_forward_data_lsu = m_result;
            default: csr_forward_data_lsu = 32'b0;
        endcase
    end

    assign forward_ready_lsu = m_valid;
    assign csr_forward_ready_lsu = m_valid;


    localparam EXCEPTION = 3'b000, PASS = 3'b001, READ_WAIT = 3'b010, WRITE_WAIT = 3'b011,
                READ_REQ = 3'b100, WRITE_ADDR_REQ = 3'b101, WRITE_DATA_REQ = 3'b110, 
                WRITE_REQ = 3'b111;
    reg [2:0] state, next_state;

    always @(*) begin
        case(state)
            EXCEPTION: begin
                if(s_valid && s_ready) begin
                    if(s_has_exception) begin
                        next_state = EXCEPTION;
                    end
                    else if(s_mem_en) begin
                        if((s_op_width == `ysyx_26040125_OP_WIDTH_HALF && s_result[0] != 1'b0) || 
                        (s_op_width == `ysyx_26040125_OP_WIDTH_WORD && s_result[1:0] != 2'b00)) begin
                            next_state = EXCEPTION;
                        end
                        else if(s_mem_write_en) begin
                            next_state = WRITE_REQ;
                        end
                        else begin
                            next_state = READ_REQ;
                        end
                    end
                    else begin
                        next_state = PASS;
                    end
                end
                else begin
                    next_state = state;
                end
            end

            PASS: begin
                if(s_valid && s_ready) begin
                    if(s_has_exception) begin
                        next_state = EXCEPTION;
                    end
                    else if(s_mem_en) begin
                        if((s_op_width == `ysyx_26040125_OP_WIDTH_HALF && s_result[0] != 1'b0) || 
                        (s_op_width == `ysyx_26040125_OP_WIDTH_WORD && s_result[1:0] != 2'b00)) begin
                            next_state = EXCEPTION;
                        end
                        else if(s_mem_write_en) begin
                            next_state = WRITE_REQ;
                        end
                        else begin
                            next_state = READ_REQ;
                        end
                    end
                    else begin
                        next_state = PASS;
                    end
                end
                
                else begin
                    next_state = state;
                end
            end

            READ_WAIT: begin
                if(m_axi_rvalid && m_axi_rready) begin
                    if(m_axi_rresp != 2'b00) begin
                        next_state = EXCEPTION;
                    end
                    else begin
                        next_state = PASS;
                    end
                end
                else begin
                    next_state = READ_WAIT;
                end
            end

            WRITE_WAIT: begin
                if(m_axi_bvalid && m_axi_bready) begin
                    if(m_axi_bresp != 2'b00) begin
                        next_state = EXCEPTION;
                    end
                    else begin
                        next_state = PASS;
                    end
                end
                else begin
                    next_state = WRITE_WAIT;
                end
            end

            READ_REQ: begin
                if(exception_flush) begin
                    next_state = PASS;
                end
                else if(m_axi_arvalid && m_axi_arready) begin
                    next_state = READ_WAIT;
                end
                else begin
                    next_state = state;
                end
            end

            WRITE_REQ: begin
                if(exception_flush) begin
                    next_state = PASS;
                end
                else if(m_axi_awvalid && m_axi_awready && m_axi_wvalid && m_axi_wready) begin
                    next_state = WRITE_WAIT;
                end

                else if(m_axi_awvalid && m_axi_awready) begin
                    next_state = WRITE_DATA_REQ;
                end

                else if(m_axi_wvalid && m_axi_wready) begin
                    next_state = WRITE_ADDR_REQ;
                end

                else begin
                    next_state = state;
                end
            end

            WRITE_ADDR_REQ: begin
                if(m_axi_awvalid && m_axi_awready) begin
                    next_state = WRITE_WAIT;
                end

                else begin
                    next_state = state;
                end
            end

            WRITE_DATA_REQ: begin
                if(m_axi_wvalid && m_axi_wready) begin
                    next_state = WRITE_WAIT;
                end

                else begin
                    next_state = state;
                end
            end

            default: next_state = PASS;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            state <= PASS;
        end
        else begin
            state <= next_state;
        end
    end

    reg [4:0] rd;
    reg wb_en;
    reg [1:0] ysyx_26040125_OP_WIDTH;
    reg [2:0] ysyx_26040125_WB_SEL;
    reg mem_signext;
    reg [11:0] csr_addr;
    reg [31:0] csr_data;
    reg csr_wr_sel;
    reg csr_wen;
    reg [31:0] srcR1;
    reg [31:0] srcR2;
    reg [31:0] result;
    reg [31:0] PC;
    reg [31:0] imm;
    reg has_exception_reg;
    reg [3:0] exception_code_reg;
    
    /*logic to recv data*/
    assign s_ready = !valid_reg || (m_ready && m_valid);
    always @(posedge clk) begin
        if(reset) begin
            rd <= 5'b0;
            wb_en <= 1'b0;
            ysyx_26040125_OP_WIDTH <= 2'b0;
            ysyx_26040125_WB_SEL <= 3'b0;
            mem_signext <= 1'b0;
            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            csr_wr_sel <= 1'b0;
            csr_wen <= 1'b0;
            srcR1 <= 32'b0;
            srcR2 <= 32'b0;
            result <= 32'b0;
            PC <= 32'b0;
            imm <= 32'b0;
            has_exception_reg <= 1'b0;
            exception_code_reg <= 4'b0;
        end

        else if(s_valid && s_ready) begin
            rd <= s_rd;
            wb_en <= s_wb_en;
            ysyx_26040125_OP_WIDTH <= s_op_width;
            ysyx_26040125_WB_SEL <= s_wb_sel;
            mem_signext <= s_mem_signext;
            csr_addr <= s_csr_addr;
            csr_data <= s_csr_data;
            csr_wr_sel <= s_csr_wr_sel;
            csr_wen <= s_csr_wen;
            srcR1 <= s_srcR1;
            srcR2 <= s_srcR2;
            result <= s_result;
            PC <= s_PC;
            imm <= s_imm;
            has_exception_reg <= s_has_exception;
            exception_code_reg <= s_exception_code;
        end
    end

    /*logic to send data*/
    assign m_rd = rd;
    assign m_wb_en = wb_en;
    assign m_wb_sel = ysyx_26040125_WB_SEL;
    assign m_csr_addr = csr_addr;
    assign m_csr_data = csr_data;
    assign m_csr_wr_sel = csr_wr_sel;
    assign m_csr_wen = csr_wen;
    assign m_srcR1 = srcR1;
    assign m_result = result;
    assign m_PC = PC;
    assign m_imm = imm;
    assign m_valid = (state == PASS || state == EXCEPTION) && valid_reg;
    assign m_has_exception = (state == EXCEPTION);
    always @(*) begin
        if(has_exception_reg) begin
            m_exception_code = exception_code_reg;
        end
        else begin
            m_exception_code = exception_code;
        end
    end
    

    /*logic to send read addr*/
    assign m_axi_araddr = result;
    assign m_axi_arvalid = (state == READ_REQ) && !exception_flush;
    assign m_axi_arid = 4'b0;
    assign m_axi_arlen = 8'b0;
    assign m_axi_arsize = {1'b0, ysyx_26040125_OP_WIDTH}; //4 bytes
    assign m_axi_arburst = 2'b01; //INCR

    /*logic to send write addr*/
    assign m_axi_awaddr = result;
    assign m_axi_awvalid = (state == WRITE_ADDR_REQ || state == WRITE_REQ) && !exception_flush;
    assign m_axi_awid = 4'b0;
    assign m_axi_awlen = 8'b0;
    assign m_axi_awsize = {1'b0, ysyx_26040125_OP_WIDTH}; //4 bytes
    assign m_axi_awburst = 2'b01; //INCR

    /*logic to send write data*/
    wire [31:0] wdata_ = srcR2 << (result[1:0]*8);
    assign m_axi_wdata = wdata_;
    assign m_axi_wstrb = (ysyx_26040125_OP_WIDTH == `ysyx_26040125_OP_WIDTH_BYTE) ? 4'b0001 << result[1:0] :
                         (ysyx_26040125_OP_WIDTH == `ysyx_26040125_OP_WIDTH_HALF) ? 4'b0011 << result[1:0] : 4'b1111;
    assign m_axi_wvalid = (state == WRITE_DATA_REQ || state == WRITE_REQ) && !exception_flush;
    assign m_axi_wlast = (state == WRITE_DATA_REQ || state == WRITE_REQ);

    /*logic to recv read data*/
    assign m_axi_rready = (state == READ_WAIT);
    reg [31:0] rdata_reg;
    always @(posedge clk) begin
        if(reset) begin
            rdata_reg <= 32'b0;
        end
        else if(m_axi_rvalid && m_axi_rready) begin
            rdata_reg <= m_axi_rdata;
        end
    end


    reg [7:0] data8;
    reg [15:0] data16;

    always @(*) begin
        case(result[1:0])
            2'b00: data8 = rdata_reg[7:0];
            2'b01: data8 = rdata_reg[15:8];
            2'b10: data8 = rdata_reg[23:16];
            2'b11: data8 = rdata_reg[31:24];
        endcase
    end

    always @(*) begin
        case(result[1])
            1'b0: data16 = rdata_reg[15:0];
            1'b1: data16 = rdata_reg[31:16];
        endcase
    end

    wire [31:0] rdata_ext8;
    wire [31:0] rdata_ext16;


    ysyx_26040125_ext8 u_ext8(
        .data_i 	( data8  ),
        .sign   	( mem_signext    ),
        .data_o 	( rdata_ext8  )
    );

    ysyx_26040125_ext16 u_ext16(
        .data_i 	( data16  ),
        .sign   	( mem_signext    ),
        .data_o 	( rdata_ext16  )
    );
    wire [31:0] rdata_ext;
    assign rdata_ext = (ysyx_26040125_OP_WIDTH == `ysyx_26040125_OP_WIDTH_BYTE) ? rdata_ext8 :
                       (ysyx_26040125_OP_WIDTH == `ysyx_26040125_OP_WIDTH_HALF) ? rdata_ext16 :
                       (ysyx_26040125_OP_WIDTH == `ysyx_26040125_OP_WIDTH_WORD) ? rdata_reg :
                       32'b0;

    assign m_rdata = rdata_ext;

    /*logic to recv write response*/
    assign m_axi_bready = (state == WRITE_WAIT);

endmodule


module ysyx_26040125_ext8(
    input [7:0] data_i,
    input sign,
    output [31:0] data_o
);

   assign data_o = sign ? {{24{data_i[7]}}, data_i} : {24'b0, data_i};
    
endmodule

module ysyx_26040125_ext16(
    input [15:0] data_i,
    input sign,
    output [31:0] data_o
);

   assign data_o = sign ? {{16{data_i[15]}}, data_i} : {16'b0, data_i};
    
endmodule


module ysyx_26040125_MTIME(
    input clk,
    input reset,

    input  [3:0]  s_axi_arid,
    input  [31:0] s_axi_araddr,
    input  [7:0]  s_axi_arlen,
    input  [2:0]  s_axi_arsize,
    input  [1:0]  s_axi_arburst,
    input         s_axi_arvalid,
    output        s_axi_arready,

    output [3:0] s_axi_rid,
    output reg [31:0] s_axi_rdata,
    output [1:0]  s_axi_rresp,
    output        s_axi_rlast,
    output        s_axi_rvalid,
    input         s_axi_rready,

    input  [3:0]  s_axi_awid,
    input  [31:0] s_axi_awaddr,
    input  [7:0]  s_axi_awlen,
    input  [2:0]  s_axi_awsize,
    input  [1:0]  s_axi_awburst,
    input         s_axi_awvalid,
    output        s_axi_awready,

    input  [31:0] s_axi_wdata,
    input  [3:0]  s_axi_wstrb,
    input         s_axi_wlast,
    input         s_axi_wvalid,
    output        s_axi_wready,

    output [3:0]  s_axi_bid,
    output [1:0]  s_axi_bresp,
    output        s_axi_bvalid,
    input         s_axi_bready
);

    /*write port unused*/
    assign s_axi_awready = 1'b0;
    assign s_axi_wready  = 1'b0;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_bvalid  = 1'b0;

    localparam IDLE = 2'd0, RESP = 2'd1;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            IDLE: begin
                if (s_axi_arvalid && s_axi_arready) begin
                    next_state = RESP;
                end else begin
                    next_state = IDLE;
                end
            end
            RESP: begin
                if (s_axi_rready && s_axi_rvalid) begin
                    next_state = IDLE;
                end else begin
                    next_state = RESP;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            s_axi_rdata <= 32'b0;
        end
        else if (s_axi_arready && s_axi_arvalid) begin
            `ifndef SYNTHESIS
                s_axi_rdata <= mtime_read(s_axi_araddr);
            `else
                s_axi_rdata <= 32'b0; // During synthesis, we cannot call DPI function, so we return 0
            `endif
        end
    end

    assign s_axi_arready = (state == IDLE);
    assign s_axi_rvalid  = (state == RESP);
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rlast   = 1'b1;
    assign s_axi_rid     = 4'b0;
    assign s_axi_bid     = 4'b0;

endmodule


module ysyx_26040125_PCR(
    input clk,
    input reset,
    input [31:0] exu_result,
    input [31:0] imm,
    input [31:0] mtvec,
    input [31:0] mepc,
    input [2:0] behavior,
    input [31:0] pc_now,
    input pc_en,
    input flush,
    input exception,
    output reg [31:0] PC,
    output [1:0] meta_data_BTB_o,
    output hit_BTB_o,

    /*port for BTB*/
    input [31:0] target_BTB,
    input [1:0] meta_data_BTB,
    input hit_BTB
);
    initial begin
        PC = 32'h3000_0000;
    end

    assign meta_data_BTB_o = meta_data_BTB;
    assign hit_BTB_o = hit_BTB;

    reg [31:0] PC_next;
    always @(*) begin
        if(flush) begin
            case(behavior)
                `ysyx_26040125_PC_NORMAL: PC_next = pc_now + 32'd4;
                `ysyx_26040125_PC_MRET: PC_next = mepc;
                `ysyx_26040125_PC_NEAR: PC_next = pc_now + imm;
                `ysyx_26040125_PC_FAR: PC_next = exu_result;
                `ysyx_26040125_PC_BRANCH: PC_next = (exu_result == 32'b1) ? pc_now + imm : pc_now + 32'd4;
                default: PC_next = 32'hFFFF_FFFF;
            endcase
        end

        else if(exception) begin
            PC_next = mtvec;
        end

        else if(hit_BTB) begin
            PC_next = target_BTB;
        end

        else begin
            PC_next = PC + 32'd4;
        end
        
        
    end

    always @(posedge clk) begin
        if(reset) begin
            PC <= 32'h3000_0000;
        end

        else begin
            if(pc_en || flush || exception) begin
                PC <= PC_next;
                `ifndef SYNTHESIS
                    ftrace(PC, PC_next);
                    enter_userapp(PC_next);
                `endif
            end

        end
    end

endmodule

module ysyx_26040125_RAW(
    input [4:0] rs1,
    input [4:0] rs2,
    input need_rs2,
    input [11:0] csr_addr,

    input [4:0] rd_exu,
    input rd_valid_exu,
    input forward_ready_exu,
    input [11:0] csr_exu,
    input csr_valid_exu,
    input csr_forward_ready_exu,
    
    input [4:0] rd_lsu,
    input rd_valid_lsu,
    input forward_ready_lsu,
    input [11:0] csr_lsu,
    input csr_valid_lsu,
    input csr_forward_ready_lsu,

    input [4:0] rd_wbu,
    input rd_valid_wbu,
    input forward_ready_wbu,
    input [11:0] csr_wbu,
    input csr_valid_wbu,
    input csr_forward_ready_wbu,
    
    output reg stall
);

    /*handle the stall, if can't load use, then stall*/
    always @(*) begin
        stall = 1'b0;
        if(rd_valid_exu && !forward_ready_exu) begin
            if(rd_exu != 5'b0 && (rd_exu == rs1 || (need_rs2 && rd_exu == rs2))) begin
                stall = 1'b1;
            end
        end

        if(csr_valid_exu && !csr_forward_ready_exu) begin
            if(csr_exu == csr_addr) begin
                stall = 1'b1;
            end
        end

        if(rd_valid_lsu && !forward_ready_lsu) begin
            if(rd_lsu != 5'b0 && (rd_lsu == rs1 || (need_rs2 && rd_lsu == rs2))) begin
                stall = 1'b1;
            end
        end

        if(csr_valid_lsu && !csr_forward_ready_lsu) begin
            if(csr_lsu == csr_addr) begin
                stall = 1'b1;
            end
        end

        if(rd_valid_wbu && !forward_ready_wbu) begin
            if(rd_wbu != 5'b0 && (rd_wbu == rs1 || (need_rs2 && rd_wbu == rs2))) begin
                stall = 1'b1;
            end
        end

        if(csr_valid_wbu && !csr_forward_ready_wbu) begin
            if(csr_wbu == csr_addr) begin
                stall = 1'b1;
            end
        end
    end

endmodule


module ysyx_26040125_WBU(
    input clk,
    input reset,

    /*data to recv*/
    input [4:0] s_rd,
    input s_wb_en,
    input [2:0] s_wb_sel,
    input [11:0] s_csr_addr,
    input [31:0] s_csr_data,
    input s_csr_wr_sel,
    input s_csr_wen,
    input [31:0] s_srcR1,
    input [31:0] s_result,
    input [31:0] s_rdata,
    input [31:0] s_PC,
    input [31:0] s_imm,
    input s_has_exception,
    input [3:0] s_exception_code,

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
    output csr_exception,
    output [31:0] csr_epc_,
    output [31:0] csr_cause_,

    /*To the RAW module*/
    output [4:0] rd_wbu,
    output rd_valid_wbu,
    output [11:0] csr_wbu,
    output csr_valid_wbu,

    /*For the load-use*/
    output [31:0] forward_data_wbu,
    output forward_ready_wbu,
    output [31:0] csr_forward_data_wbu,
    output csr_forward_ready_wbu,

    output exception_flush
);


    reg valid_reg;
    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end
        
        else if(exception_flush) begin
            valid_reg <= 1'b0;
        end

        else if(s_valid && s_ready) begin
            valid_reg <= 1'b1;
        end
        else begin
            valid_reg <= 1'b0;
        end
    end

    assign rd_wbu = rd;
    assign rd_valid_wbu = valid_reg && wb_en && (rd != 5'b0);
    assign csr_wbu = csr_addr;
    assign csr_valid_wbu = valid_reg && csr_wen;

    assign forward_data_wbu = wdata;

    always @(*) begin
        case(csr_wr_sel)
            `ysyx_26040125_CSR_SEL_RS1: csr_forward_data_wbu = srcR1;
            `ysyx_26040125_CSR_SEL_ALU: csr_forward_data_wbu = result;
            default: csr_forward_data_wbu = 32'b0;
        endcase
    end

    assign forward_ready_wbu = valid_reg;
    assign csr_forward_ready_wbu = valid_reg;

    /*logic to recv data*/
    reg [4:0] rd;
    reg wb_en;
    reg [2:0] ysyx_26040125_WB_SEL;
    reg [11:0] csr_addr;
    reg [31:0] csr_data;
    reg csr_wr_sel;
    reg csr_wen;
    reg [31:0] srcR1;
    reg [31:0] result;
    reg [31:0] rdata;
    reg [31:0] PC;
    reg [31:0] imm;
    reg has_exception_reg;
    reg [3:0] exception_code_reg;
    assign s_ready = 1'b1;
    always @(posedge clk) begin
        if(reset) begin
            rd <= 5'b0;
            wb_en <= 1'b0;
            ysyx_26040125_WB_SEL <= 3'b0;
            csr_addr <= 12'b0;
            csr_data <= 32'b0;
            csr_wr_sel <= 1'b0;
            csr_wen <= 1'b0;
            srcR1 <= 32'b0;
            result <= 32'b0;
            rdata <= 32'b0;
            PC <= 32'b0;
            imm <= 32'b0;
            has_exception_reg <= 1'b0;
            exception_code_reg <= 4'b0;
        end

        else if(s_valid && s_ready) begin
            rd <= s_rd;
            wb_en <= s_wb_en;
            ysyx_26040125_WB_SEL <= s_wb_sel;
            csr_addr <= s_csr_addr;
            csr_data <= s_csr_data;
            csr_wr_sel <= s_csr_wr_sel;
            csr_wen <= s_csr_wen;
            srcR1 <= s_srcR1;
            result <= s_result;
            rdata <= s_rdata;
            PC <= s_PC;
            imm <= s_imm;
            has_exception_reg <= s_has_exception;
            exception_code_reg <= s_exception_code;
        end
    end

    /*interact with GPR*/
    assign wen = wb_en & valid_reg & !has_exception_reg;
    assign waddr = rd;
    always @(*) begin
        case(ysyx_26040125_WB_SEL)
            `ysyx_26040125_WB_SEL_IMM: wdata = imm;
            `ysyx_26040125_WB_SEL_ALU: wdata = result;
            `ysyx_26040125_WB_SEL_MEM: wdata = rdata;
            `ysyx_26040125_WB_SEL_PC4: wdata = PC + 32'd4;
            `ysyx_26040125_WB_SEL_CSR: wdata = csr_data;
            default: wdata = 32'b0;
        endcase
    end


    /*interact with CSR*/
    assign csr_addr_ = csr_addr;
    assign csr_srcR1_ = srcR1;
    assign csr_alu_res_ = result;
    assign csr_wr_sel_ = csr_wr_sel;
    assign csr_wen_ = csr_wen & valid_reg & !has_exception_reg;

    assign csr_exception = has_exception_reg & valid_reg;
    assign csr_epc_ = PC;
    assign csr_cause_ = {28'b0, exception_code_reg};

    assign exception_flush = has_exception_reg & valid_reg;


endmodule
module ysyx_26040125_XBAR(
    input clk,
    input reset,

    /* slave AXI full port */
    input  [3:0] s_axi_arid,
    input  [31:0] s_axi_araddr,
    input  [7:0]  s_axi_arlen,
    input  [2:0]  s_axi_arsize,
    input  [1:0]  s_axi_arburst,
    input         s_axi_arvalid,
    output        s_axi_arready,

    output [3:0] s_axi_rid,
    output [31:0] s_axi_rdata,
    output [1:0]  s_axi_rresp,
    output        s_axi_rlast,
    output        s_axi_rvalid,
    input         s_axi_rready,

    input  [3:0] s_axi_awid,
    input  [31:0] s_axi_awaddr,
    input  [7:0]  s_axi_awlen,
    input  [2:0]  s_axi_awsize,
    input  [1:0]  s_axi_awburst,
    input         s_axi_awvalid,
    output        s_axi_awready,

    input  [31:0] s_axi_wdata,
    input  [3:0]  s_axi_wstrb,
    input         s_axi_wlast,
    input         s_axi_wvalid,
    output        s_axi_wready,

    output [3:0] s_axi_bid,
    output [1:0]  s_axi_bresp,
    output        s_axi_bvalid,
    input         s_axi_bready,

    /* master AXI full port A (0x0200_0000 ~ 0x0200_ffff) */
    output [3:0] m_axi_arid_A,
    output [31:0] m_axi_araddr_A,
    output [7:0]  m_axi_arlen_A,
    output [2:0]  m_axi_arsize_A,
    output [1:0]  m_axi_arburst_A,
    output        m_axi_arvalid_A,
    input         m_axi_arready_A,

    input  [3:0] m_axi_rid_A,
    input  [31:0] m_axi_rdata_A,
    input  [1:0]  m_axi_rresp_A,
    input         m_axi_rlast_A,
    input         m_axi_rvalid_A,
    output        m_axi_rready_A,

    output [3:0] m_axi_awid_A,
    output [31:0] m_axi_awaddr_A,
    output [7:0]  m_axi_awlen_A,
    output [2:0]  m_axi_awsize_A,
    output [1:0]  m_axi_awburst_A,
    output        m_axi_awvalid_A,
    input         m_axi_awready_A,

    output [31:0] m_axi_wdata_A,
    output [3:0]  m_axi_wstrb_A,
    output        m_axi_wlast_A,
    output        m_axi_wvalid_A,
    input         m_axi_wready_A,

    input  [3:0] m_axi_bid_A,
    input  [1:0]  m_axi_bresp_A,
    input         m_axi_bvalid_A,
    output        m_axi_bready_A,

    /* master AXI full port B*/
    output [3:0] m_axi_arid_B,
    output [31:0] m_axi_araddr_B,
    output [7:0]  m_axi_arlen_B,
    output [2:0]  m_axi_arsize_B,
    output [1:0]  m_axi_arburst_B,
    output        m_axi_arvalid_B,
    input         m_axi_arready_B,

    input  [3:0] m_axi_rid_B,
    input  [31:0] m_axi_rdata_B,
    input  [1:0]  m_axi_rresp_B,
    input         m_axi_rlast_B,
    input         m_axi_rvalid_B,
    output        m_axi_rready_B,

    output [3:0] m_axi_awid_B,
    output [31:0] m_axi_awaddr_B,
    output [7:0]  m_axi_awlen_B,
    output [2:0]  m_axi_awsize_B,
    output [1:0]  m_axi_awburst_B,
    output        m_axi_awvalid_B,
    input         m_axi_awready_B,

    output [31:0] m_axi_wdata_B,
    output [3:0]  m_axi_wstrb_B,
    output        m_axi_wlast_B,
    output        m_axi_wvalid_B,
    input         m_axi_wready_B,

    input  [3:0] m_axi_bid_B,
    input  [1:0]  m_axi_bresp_B,
    input         m_axi_bvalid_B,
    output        m_axi_bready_B
);

    // 0x0200_0000 ~ 0x0200_ffff -> port A (0), else -> port B (1)
    function addr_sel;
        input [31:0] addr;
        begin
            addr_sel = (addr >= 32'h0200_0000 && addr <= 32'h0200_ffff) ? 1'b0 : 1'b1;
        end
    endfunction

    /*Read Channel*/
    localparam READ_IDLE = 2'b00, READ_REQ = 2'b01, READ_WAIT = 2'b10;
    reg [1:0] r_state, r_next_state;
    reg r_sel;

    always @(*) begin
        case (r_state)
            READ_IDLE: r_next_state = (s_axi_arvalid && s_axi_arready) ? READ_REQ  : READ_IDLE;
            READ_REQ:  r_next_state = (r_sel == 1'b0 ? m_axi_arready_A : m_axi_arready_B) ? READ_WAIT : READ_REQ;
            READ_WAIT: r_next_state = (s_axi_rvalid && s_axi_rready && s_axi_rlast) ? READ_IDLE : READ_WAIT;
            default:   r_next_state = READ_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) r_state <= READ_IDLE;
        else        r_state <= r_next_state;
    end

    assign s_axi_arready = (r_state == READ_IDLE);

    reg [3:0] r_id;
    reg [31:0] raddr;
    reg [7:0]  rlen;
    reg [2:0]  rsize;
    reg [1:0]  rburst;

    always @(posedge clk) begin
        if (reset) begin
            r_id   <= 4'b0;
            raddr  <= 32'b0;
            rlen   <= 8'b0;
            rsize  <= 3'b0;
            rburst <= 2'b0;
            r_sel  <= 1'b0;
        end else if (s_axi_arvalid && s_axi_arready) begin
            r_id   <= s_axi_arid;
            raddr  <= s_axi_araddr;
            rlen   <= s_axi_arlen;
            rsize  <= s_axi_arsize;
            rburst <= s_axi_arburst;
            r_sel  <= addr_sel(s_axi_araddr);
        end
    end

    assign m_axi_arid_A    = r_id;
    assign m_axi_araddr_A  = raddr;
    assign m_axi_arlen_A   = rlen;
    assign m_axi_arsize_A  = rsize;
    assign m_axi_arburst_A = rburst;
    assign m_axi_arvalid_A = (r_state == READ_REQ) && (r_sel == 1'b0);

    assign m_axi_arid_B    = r_id;
    assign m_axi_araddr_B  = raddr;
    assign m_axi_arlen_B   = rlen;
    assign m_axi_arsize_B  = rsize;
    assign m_axi_arburst_B = rburst;
    assign m_axi_arvalid_B = (r_state == READ_REQ) && (r_sel == 1'b1);

    assign m_axi_rready_A  = (r_state == READ_WAIT) && (r_sel == 1'b0) && s_axi_rready;
    assign m_axi_rready_B  = (r_state == READ_WAIT) && (r_sel == 1'b1) && s_axi_rready;

    assign s_axi_rid    = (r_state == READ_WAIT) ? (r_sel == 1'b0 ? m_axi_rid_A    : m_axi_rid_B)    : 4'b0;
    assign s_axi_rdata  = (r_state == READ_WAIT) ? (r_sel == 1'b0 ? m_axi_rdata_A  : m_axi_rdata_B)  : 32'b0;
    assign s_axi_rresp  = (r_state == READ_WAIT) ? (r_sel == 1'b0 ? m_axi_rresp_A  : m_axi_rresp_B)  : 2'b0;
    assign s_axi_rlast  = (r_state == READ_WAIT) ? (r_sel == 1'b0 ? m_axi_rlast_A  : m_axi_rlast_B)  : 1'b0;
    assign s_axi_rvalid = (r_state == READ_WAIT) ? (r_sel == 1'b0 ? m_axi_rvalid_A : m_axi_rvalid_B) : 1'b0;

    /*Write Channel*/
    localparam WRITE_IDLE      = 3'b000,
               WRITE_WAIT_ADDR = 3'b001,
               WRITE_WAIT_DATA = 3'b010,
               WRITE_REQ       = 3'b011,
               WRITE_REQ_ADDR  = 3'b100,
               WRITE_REQ_DATA  = 3'b101,
               WRITE_RESP      = 3'b110;
    reg [2:0] w_state, w_next_state;
    reg w_sel;

    always @(*) begin
        case (w_state)
            WRITE_IDLE: begin
                if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready)
                    w_next_state = WRITE_REQ;
                else if (s_axi_awvalid && s_axi_awready)
                    w_next_state = WRITE_WAIT_DATA;
                else if (s_axi_wvalid && s_axi_wready)
                    w_next_state = WRITE_WAIT_ADDR;
                else
                    w_next_state = WRITE_IDLE;
            end
            WRITE_WAIT_DATA: w_next_state = (s_axi_wvalid  && s_axi_wready)  ? WRITE_REQ : WRITE_WAIT_DATA;
            WRITE_WAIT_ADDR: w_next_state = (s_axi_awvalid && s_axi_awready) ? WRITE_REQ : WRITE_WAIT_ADDR;
            WRITE_REQ      : begin
                if (w_sel == 1'b0) begin
                    if (m_axi_awready_A && m_axi_wready_A && m_axi_awvalid_A && m_axi_wvalid_A)
                        w_next_state = WRITE_RESP;
                    else if (m_axi_awready_A && m_axi_awvalid_A)
                        w_next_state = WRITE_REQ_DATA;
                    else if (m_axi_wready_A && m_axi_wvalid_A)
                        w_next_state = WRITE_REQ_ADDR;
                    else
                        w_next_state = WRITE_REQ;
                end
                else begin
                    if (m_axi_awready_B && m_axi_wready_B && m_axi_awvalid_B && m_axi_wvalid_B)
                        w_next_state = WRITE_RESP;
                    else if (m_axi_awready_B && m_axi_awvalid_B)
                        w_next_state = WRITE_REQ_DATA;
                    else if (m_axi_wready_B && m_axi_wvalid_B)
                        w_next_state = WRITE_REQ_ADDR;
                    else
                        w_next_state = WRITE_REQ;
                end
            end
            WRITE_REQ_ADDR:  w_next_state = (w_sel == 1'b0 ? m_axi_awready_A : m_axi_awready_B) ? WRITE_REQ_DATA : WRITE_REQ_ADDR;
            WRITE_REQ_DATA:  w_next_state = (w_sel == 1'b0 ? m_axi_wready_A  : m_axi_wready_B)  ? WRITE_RESP     : WRITE_REQ_DATA;
            WRITE_RESP:      w_next_state = (s_axi_bvalid  && s_axi_bready)  ? WRITE_IDLE       : WRITE_RESP;
            default:         w_next_state = WRITE_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) w_state <= WRITE_IDLE;
        else        w_state <= w_next_state;
    end

    assign s_axi_awready = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_ADDR);
    assign s_axi_wready  = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_DATA);

    reg [3:0] w_id;
    reg [31:0] waddr;
    reg [7:0]  wlen;
    reg [2:0]  wsize;
    reg [1:0]  wburst;
    reg [31:0] wdata;
    reg [3:0]  wstrb;
    reg        wlast;

    always @(posedge clk) begin
        if (reset) begin
            w_id   <= 4'b0;
            waddr  <= 32'b0;
            wlen   <= 8'b0;
            wsize  <= 3'b0;
            wburst <= 2'b0;
            w_sel  <= 1'b0;
        end else if (s_axi_awvalid && s_axi_awready) begin
            w_id   <= s_axi_awid;
            waddr  <= s_axi_awaddr;
            wlen   <= s_axi_awlen;
            wsize  <= s_axi_awsize;
            wburst <= s_axi_awburst;
            w_sel  <= addr_sel(s_axi_awaddr);
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            wdata <= 32'b0;
            wstrb <= 4'b0;
            wlast <= 1'b0;
        end else if (s_axi_wvalid && s_axi_wready) begin
            wdata <= s_axi_wdata;
            wstrb <= s_axi_wstrb;
            wlast <= s_axi_wlast;
        end
    end

    assign m_axi_awid_A    = w_id;
    assign m_axi_awaddr_A  = waddr;
    assign m_axi_awlen_A   = wlen;
    assign m_axi_awsize_A  = wsize;
    assign m_axi_awburst_A = wburst;
    assign m_axi_awvalid_A = (w_state == WRITE_REQ_ADDR || w_state == WRITE_REQ) && (w_sel == 1'b0);
    assign m_axi_wdata_A   = wdata;
    assign m_axi_wstrb_A   = wstrb;
    assign m_axi_wlast_A   = wlast;
    assign m_axi_wvalid_A  = (w_state == WRITE_REQ_DATA || w_state == WRITE_REQ) && (w_sel == 1'b0);
    assign m_axi_bready_A  = (w_state == WRITE_RESP)     && (w_sel == 1'b0) && s_axi_bready;

    assign m_axi_awid_B    = w_id;
    assign m_axi_awaddr_B  = waddr;
    assign m_axi_awlen_B   = wlen;
    assign m_axi_awsize_B  = wsize;
    assign m_axi_awburst_B = wburst;
    assign m_axi_awvalid_B = (w_state == WRITE_REQ_ADDR || w_state == WRITE_REQ) && (w_sel == 1'b1);
    assign m_axi_wdata_B   = wdata;
    assign m_axi_wstrb_B   = wstrb;
    assign m_axi_wlast_B   = wlast;
    assign m_axi_wvalid_B  = (w_state == WRITE_REQ_DATA || w_state == WRITE_REQ) && (w_sel == 1'b1);
    assign m_axi_bready_B  = (w_state == WRITE_RESP)     && (w_sel == 1'b1) && s_axi_bready;

    assign s_axi_bid    = (w_state == WRITE_RESP) ? (w_sel == 1'b0 ? m_axi_bid_A    : m_axi_bid_B)    : 4'b0;
    assign s_axi_bresp  = (w_state == WRITE_RESP) ? (w_sel == 1'b0 ? m_axi_bresp_A  : m_axi_bresp_B)  : 2'b0;
    assign s_axi_bvalid = (w_state == WRITE_RESP) ? (w_sel == 1'b0 ? m_axi_bvalid_A : m_axi_bvalid_B) : 1'b0;

endmodule
module ysyx_26040125(
        input  clock,
        input  reset,

        /*verilator lint_off UNUSED*/
        input io_interrupt,
        /*verilator lint_on UNUSED*/

        // AXI4 Master port
        input         io_master_awready,
        output        io_master_awvalid,
        output [31:0] io_master_awaddr,
        output [3:0]  io_master_awid,
        output [7:0]  io_master_awlen,
        output [2:0]  io_master_awsize,
        output [1:0]  io_master_awburst,
        input         io_master_wready,
        output        io_master_wvalid,
        output [31:0] io_master_wdata,
        output [3:0]  io_master_wstrb,
        output        io_master_wlast,
        output        io_master_bready,
        input         io_master_bvalid,
        input  [1:0]  io_master_bresp,
        input  [3:0]  io_master_bid,
        input         io_master_arready,
        output        io_master_arvalid,
        output [31:0] io_master_araddr,
        output [3:0]  io_master_arid,
        output [7:0]  io_master_arlen,
        output [2:0]  io_master_arsize,
        output [1:0]  io_master_arburst,
        output        io_master_rready,
        input         io_master_rvalid,
        input  [1:0]  io_master_rresp,
        input  [31:0] io_master_rdata,
        input         io_master_rlast,
        input  [3:0]  io_master_rid,

        // AXI4 Slave port
        /*verilator lint_off UNUSED */
        output        io_slave_awready,
        input         io_slave_awvalid,
        input  [31:0] io_slave_awaddr,
        input  [3:0]  io_slave_awid,
        input  [7:0]  io_slave_awlen,
        input  [2:0]  io_slave_awsize,
        input  [1:0]  io_slave_awburst,
        output        io_slave_wready,
        input         io_slave_wvalid,
        input  [31:0] io_slave_wdata,
        input  [3:0]  io_slave_wstrb,
        input         io_slave_wlast,
        input         io_slave_bready,
        output        io_slave_bvalid,
        output [1:0]  io_slave_bresp,
        output [3:0]  io_slave_bid,
        output        io_slave_arready,
        input         io_slave_arvalid,
        input  [31:0] io_slave_araddr,
        input  [3:0]  io_slave_arid,
        input  [7:0]  io_slave_arlen,
        input  [2:0]  io_slave_arsize,
        input  [1:0]  io_slave_arburst,
        input         io_slave_rready,
        output        io_slave_rvalid,
        output [1:0]  io_slave_rresp,
        output [31:0] io_slave_rdata,
        output        io_slave_rlast,
        output [3:0]  io_slave_rid
        /*verilator lint_on UNUSED */
    );

    // Slave port: outputs = 0, inputs left unconnected
    assign io_slave_awready = 1'b0;
    assign io_slave_wready  = 1'b0;
    assign io_slave_bvalid  = 1'b0;
    assign io_slave_bresp   = 2'b0;
    assign io_slave_bid     = 4'b0;
    assign io_slave_arready = 1'b0;
    assign io_slave_rvalid  = 1'b0;
    assign io_slave_rresp   = 2'b0;
    assign io_slave_rdata   = 32'b0;
    assign io_slave_rlast   = 1'b0;
    assign io_slave_rid     = 4'b0;

    // PCR outputs
    wire [31:0] PCR_PC;
    wire [1:0]  PCR_meta_data_BTB_o;
    wire        PCR_hit_BTB_o;

    // IFU outputs
    wire [31:0] IFU_m_Inst;
    wire [31:0] IFU_m_PC;
    wire        IFU_m_valid;
    wire [31:0] IFU_m_axi_araddr;
    wire        IFU_m_axi_arvalid;
    wire [3:0]  IFU_m_axi_arid;
    wire [7:0]  IFU_m_axi_arlen;
    wire [2:0]  IFU_m_axi_arsize;
    wire [1:0]  IFU_m_axi_arburst;
    wire        IFU_m_axi_rready;
    wire [31:0] IFU_m_axi_awaddr;
    wire        IFU_m_axi_awvalid;
    wire [3:0]  IFU_m_axi_awid;
    wire [7:0]  IFU_m_axi_awlen;
    wire [2:0]  IFU_m_axi_awsize;
    wire [1:0]  IFU_m_axi_awburst;
    wire [31:0] IFU_m_axi_wdata;
    wire [3:0]  IFU_m_axi_wstrb;
    wire        IFU_m_axi_wvalid;
    wire        IFU_m_axi_wlast;
    wire        IFU_m_axi_bready;
    wire        IFU_pc_en;
    wire        IFU_m_has_exception;
    wire [3:0]  IFU_m_exception_code;
    wire [1:0]  IFU_m_meta_data_BTB;
    wire        IFU_m_hit_BTB;

    // GPR outputs
    wire [31:0] GPR_rdata1;
    wire [31:0] GPR_rdata2;

    // IDU outputs
    wire        IDU_s_ready;
    wire [4:0]  IDU_m_rd;
    wire [31:0] IDU_m_srcR1;
    wire [31:0] IDU_m_srcR2;
    wire [31:0] IDU_m_imm;
    wire [3:0]  IDU_m_alu_op;
    wire [1:0]  IDU_m_alu_sel0;
    wire [1:0]  IDU_m_alu_sel1;
    wire        IDU_m_wb_en;
    wire        IDU_m_mem_en;
    wire        IDU_m_mem_write_en;
    wire [1:0]  IDU_m_op_width;
    wire [2:0]  IDU_m_wb_sel;
    wire [2:0]  IDU_m_brju;
    wire        IDU_m_mem_signext;
    wire [11:0] IDU_m_csr_addr;
    wire [11:0] IDU_csr_addr;
    wire [31:0] IDU_m_csr_data;
    wire        IDU_m_csr_wr_sel;
    wire        IDU_m_csr_wen;
    wire [31:0] IDU_m_PC;
    wire        IDU_m_valid;
    wire        IDU_m_fencei;
    wire        IDU_m_has_exception;
    wire [3:0]  IDU_m_exception_code;
    wire [1:0]  IDU_m_meta_data_BTB;
    wire        IDU_m_hit_BTB;

    /*verilator lint_off UNUSED */
    wire [4:0]  IDU_rs1;
    wire [4:0]  IDU_rs2;
    /*verilator lint_on UNUSED */

    // EXU outputs
    wire        EXU_s_ready;
    wire [4:0]  EXU_m_rd;
    wire        EXU_m_wb_en;
    wire        EXU_m_mem_en;
    wire        EXU_m_mem_write_en;
    wire [1:0]  EXU_m_op_width;
    wire [2:0]  EXU_m_wb_sel;
    wire        EXU_m_mem_signext;
    wire [11:0] EXU_m_csr_addr;
    wire [31:0] EXU_m_csr_data;
    wire        EXU_m_csr_wr_sel;
    wire        EXU_m_csr_wen;
    wire [31:0] EXU_m_srcR1;
    wire [31:0] EXU_m_srcR2;
    wire [31:0] EXU_m_result;
    wire [31:0] EXU_m_PC;
    wire [31:0] EXU_m_imm;
    wire        EXU_m_valid;
    wire        EXU_cache_flush;
    wire        EXU_m_has_exception;
    wire [3:0]  EXU_m_exception_code;
    wire [4:0]  EXU_rd_exu;
    wire [11:0] EXU_csr_exu;
    wire        EXU_rd_valid_exu;
    wire        EXU_csr_valid_exu;
    wire [31:0] EXU_pcr_exu_result;
    wire [31:0] EXU_pcr_imm;
    wire [2:0]  EXU_pcr_behavior;
    wire        EXU_flush;
    wire [31:0] EXU_pcr_pc_now;
    wire [31:0] EXU_forward_data_exu;
    wire        EXU_forward_ready_exu;
    wire [31:0] EXU_csr_forward_data_exu;
    wire        EXU_csr_forward_ready_exu;
    wire [31:0] EXU_PC_w;
    wire [31:0] EXU_target;
    wire [1:0]  EXU_meta_data;
    wire        EXU_write_en;


    // LSU outputs
    wire        LSU_s_ready;
    wire [4:0]  LSU_m_rd;
    wire        LSU_m_wb_en;
    wire [2:0]  LSU_m_wb_sel;
    wire [11:0] LSU_m_csr_addr;
    wire [31:0] LSU_m_csr_data;
    wire        LSU_m_csr_wr_sel;
    wire        LSU_m_csr_wen;
    wire [31:0] LSU_m_srcR1;
    wire [31:0] LSU_m_result;
    wire [31:0] LSU_m_rdata;
    wire [31:0] LSU_m_PC;
    wire [31:0] LSU_m_imm;
    wire        LSU_m_valid;
    wire [31:0] LSU_m_axi_araddr;
    wire        LSU_m_axi_arvalid;
    wire [3:0]  LSU_m_axi_arid;
    wire [7:0]  LSU_m_axi_arlen;
    wire [2:0]  LSU_m_axi_arsize;
    wire [1:0]  LSU_m_axi_arburst;
    wire        LSU_m_axi_rready;
    wire [31:0] LSU_m_axi_awaddr;
    wire        LSU_m_axi_awvalid;
    wire [3:0]  LSU_m_axi_awid;
    wire [7:0]  LSU_m_axi_awlen;
    wire [2:0]  LSU_m_axi_awsize;
    wire [1:0]  LSU_m_axi_awburst;
    wire [31:0] LSU_m_axi_wdata;
    wire [3:0]  LSU_m_axi_wstrb;
    wire        LSU_m_axi_wvalid;
    wire        LSU_m_axi_wlast;
    wire        LSU_m_axi_bready;
    wire [4:0]  LSU_rd_lsu;
    wire [11:0] LSU_csr_lsu;
    wire        LSU_rd_valid_lsu;
    wire        LSU_csr_valid_lsu;
    wire        LSU_m_has_exception;
    wire [3:0]  LSU_m_exception_code;
    wire [31:0] LSU_forward_data_lsu;
    wire        LSU_forward_ready_lsu;
    wire [31:0] LSU_csr_forward_data_lsu;
    wire        LSU_csr_forward_ready_lsu;
    

    // WBU outputs
    wire        WBU_s_ready;
    wire        WBU_wen;
    wire [31:0] WBU_wdata;
    /*verilator lint_off UNUSED */
    wire [4:0]  WBU_waddr;
    /*verilator lint_on UNUSED */
    wire [11:0] WBU_csr_addr_;
    wire [31:0] WBU_csr_srcR1_;
    wire [31:0] WBU_csr_alu_res_;
    wire        WBU_csr_wr_sel_;
    wire        WBU_csr_wen_;
    wire [31:0] WBU_csr_epc_;
    wire [31:0] WBU_csr_cause_;
    wire [4:0]  WBU_rd_wbu;
    wire [11:0] WBU_csr_wbu;
    wire        WBU_rd_valid_wbu;
    wire        WBU_csr_valid_wbu;
    wire        WBU_csr_exception;
    wire        WBU_exception_flush;
    wire [31:0] WBU_forward_data_wbu;
    wire        WBU_forward_ready_wbu;
    wire [31:0] WBU_csr_forward_data_wbu;
    wire        WBU_csr_forward_ready_wbu;

    // CSR outputs
    wire [31:0] CSR_rdata;
    wire [31:0] CSR_mtvec_out;
    wire [31:0] CSR_mepc_out;

    // ARB outputs (slave side, responses back to IFU/LSU)
    wire        ARB_s_axi_arready_A;
    wire [31:0] ARB_s_axi_rdata_A;
    wire [1:0]  ARB_s_axi_rresp_A;
    wire        ARB_s_axi_rvalid_A;
    wire [3:0]  ARB_s_axi_rid_A;
    wire        ARB_s_axi_rlast_A;
    wire        ARB_s_axi_awready_A;
    wire        ARB_s_axi_wready_A;
    wire [1:0]  ARB_s_axi_bresp_A;
    wire        ARB_s_axi_bvalid_A;
    wire [3:0]  ARB_s_axi_bid_A;
    wire        ARB_s_axi_arready_B;
    wire [31:0] ARB_s_axi_rdata_B;
    wire [1:0]  ARB_s_axi_rresp_B;
    wire        ARB_s_axi_rvalid_B;
    wire [3:0]  ARB_s_axi_rid_B;
    wire        ARB_s_axi_rlast_B;
    wire        ARB_s_axi_awready_B;
    wire        ARB_s_axi_wready_B;
    wire [1:0]  ARB_s_axi_bresp_B;
    wire        ARB_s_axi_bvalid_B;
    wire [3:0]  ARB_s_axi_bid_B;
    // ARB outputs (master side, to XBAR slave)
    wire [31:0] ARB_m_axi_araddr;
    wire        ARB_m_axi_arvalid;
    wire [3:0]  ARB_m_axi_arid;
    wire [7:0]  ARB_m_axi_arlen;
    wire [2:0]  ARB_m_axi_arsize;
    wire [1:0]  ARB_m_axi_arburst;
    wire        ARB_m_axi_rready;
    wire [31:0] ARB_m_axi_awaddr;
    wire        ARB_m_axi_awvalid;
    wire [3:0]  ARB_m_axi_awid;
    wire [7:0]  ARB_m_axi_awlen;
    wire [2:0]  ARB_m_axi_awsize;
    wire [1:0]  ARB_m_axi_awburst;
    wire [31:0] ARB_m_axi_wdata;
    wire [3:0]  ARB_m_axi_wstrb;
    wire        ARB_m_axi_wvalid;
    wire        ARB_m_axi_wlast;
    wire        ARB_m_axi_bready;

    // XBAR outputs (slave side, responses back to ARB)
    wire        XBAR_s_axi_arready;
    wire [31:0] XBAR_s_axi_rdata;
    wire [1:0]  XBAR_s_axi_rresp;
    wire        XBAR_s_axi_rvalid;
    wire [3:0]  XBAR_s_axi_rid;
    wire        XBAR_s_axi_rlast;
    wire        XBAR_s_axi_awready;
    wire        XBAR_s_axi_wready;
    wire [1:0]  XBAR_s_axi_bresp;
    wire        XBAR_s_axi_bvalid;
    wire [3:0]  XBAR_s_axi_bid;
    // XBAR outputs (master A, to MTIME)
    wire [3:0]  XBAR_m_axi_arid_A;
    wire [31:0] XBAR_m_axi_araddr_A;
    wire [7:0]  XBAR_m_axi_arlen_A;
    wire [2:0]  XBAR_m_axi_arsize_A;
    wire [1:0]  XBAR_m_axi_arburst_A;
    wire        XBAR_m_axi_arvalid_A;
    wire        XBAR_m_axi_rready_A;
    wire [3:0]  XBAR_m_axi_awid_A;
    wire [31:0] XBAR_m_axi_awaddr_A;
    wire [7:0]  XBAR_m_axi_awlen_A;
    wire [2:0]  XBAR_m_axi_awsize_A;
    wire [1:0]  XBAR_m_axi_awburst_A;
    wire        XBAR_m_axi_awvalid_A;
    wire [31:0] XBAR_m_axi_wdata_A;
    wire [3:0]  XBAR_m_axi_wstrb_A;
    wire        XBAR_m_axi_wlast_A;
    wire        XBAR_m_axi_wvalid_A;
    wire        XBAR_m_axi_bready_A;
    // XBAR outputs (master B, to external io_master)
    wire [3:0]  XBAR_m_axi_arid_B;
    wire [31:0] XBAR_m_axi_araddr_B;
    wire [7:0]  XBAR_m_axi_arlen_B;
    wire [2:0]  XBAR_m_axi_arsize_B;
    wire [1:0]  XBAR_m_axi_arburst_B;
    wire        XBAR_m_axi_arvalid_B;
    wire        XBAR_m_axi_rready_B;
    wire [3:0]  XBAR_m_axi_awid_B;
    wire [31:0] XBAR_m_axi_awaddr_B;
    wire [7:0]  XBAR_m_axi_awlen_B;
    wire [2:0]  XBAR_m_axi_awsize_B;
    wire [1:0]  XBAR_m_axi_awburst_B;
    wire        XBAR_m_axi_awvalid_B;
    wire [31:0] XBAR_m_axi_wdata_B;
    wire [3:0]  XBAR_m_axi_wstrb_B;
    wire        XBAR_m_axi_wlast_B;
    wire        XBAR_m_axi_wvalid_B;
    wire        XBAR_m_axi_bready_B;

    // MTIME outputs
    wire        MTIME_s_axi_arready;
    wire [3:0]  MTIME_s_axi_rid;
    wire [31:0] MTIME_s_axi_rdata;
    wire [1:0]  MTIME_s_axi_rresp;
    wire        MTIME_s_axi_rlast;
    wire        MTIME_s_axi_rvalid;
    wire        MTIME_s_axi_awready;
    wire        MTIME_s_axi_wready;
    wire [3:0]  MTIME_s_axi_bid;
    wire [1:0]  MTIME_s_axi_bresp;
    wire        MTIME_s_axi_bvalid;

    // BTB outputs
    wire [31:0] BTB_target_BTB;
    wire [1:0]  BTB_meta_data_BTB;
    wire        BTB_hit_BTB;

    // Connect io_master to XBAR master B
    assign io_master_arvalid  = XBAR_m_axi_arvalid_B;
    assign io_master_araddr   = XBAR_m_axi_araddr_B;
    assign io_master_arid     = XBAR_m_axi_arid_B;
    assign io_master_arlen    = XBAR_m_axi_arlen_B;
    assign io_master_arsize   = XBAR_m_axi_arsize_B;
    assign io_master_arburst  = XBAR_m_axi_arburst_B;
    assign io_master_rready   = XBAR_m_axi_rready_B;
    assign io_master_awvalid  = XBAR_m_axi_awvalid_B;
    assign io_master_awaddr   = XBAR_m_axi_awaddr_B;
    assign io_master_awid     = XBAR_m_axi_awid_B;
    assign io_master_awlen    = XBAR_m_axi_awlen_B;
    assign io_master_awsize   = XBAR_m_axi_awsize_B;
    assign io_master_awburst  = XBAR_m_axi_awburst_B;
    assign io_master_wvalid   = XBAR_m_axi_wvalid_B;
    assign io_master_wdata    = XBAR_m_axi_wdata_B;
    assign io_master_wstrb    = XBAR_m_axi_wstrb_B;
    assign io_master_wlast    = XBAR_m_axi_wlast_B;
    assign io_master_bready   = XBAR_m_axi_bready_B;


    ysyx_26040125_PCR ysyx_26040125_PCR(
            .clk             (clock),
            .reset           (reset),
            .exu_result      (EXU_pcr_exu_result),
            .imm             (EXU_pcr_imm),
            .mtvec           (CSR_mtvec_out),
            .mepc            (CSR_mepc_out),
            .behavior        (EXU_pcr_behavior),
            .pc_en           (IFU_pc_en),
            .PC              (PCR_PC),
            .pc_now          (EXU_pcr_pc_now),
            .flush           (EXU_flush),
            .exception       (WBU_exception_flush),
            .meta_data_BTB_o (PCR_meta_data_BTB_o),
            .hit_BTB_o       (PCR_hit_BTB_o),
            .target_BTB      (BTB_target_BTB),
            .meta_data_BTB   (BTB_meta_data_BTB),
            .hit_BTB         (BTB_hit_BTB)
        );

    ysyx_26040125_IFU ysyx_26040125_IFU(
            .clk            (clock),
            .reset          (reset),
            .m_Inst            (IFU_m_Inst),
            .m_PC              (IFU_m_PC),
            .m_meta_data_BTB   (IFU_m_meta_data_BTB),
            .m_hit_BTB         (IFU_m_hit_BTB),
            .m_has_exception   (IFU_m_has_exception),
            .m_exception_code  (IFU_m_exception_code),
            .m_valid           (IFU_m_valid),
            .m_ready           (IDU_s_ready),
            .PC                (PCR_PC),
            .meta_data_BTB     (PCR_meta_data_BTB_o),
            .hit_BTB           (PCR_hit_BTB_o),
            .cache_flush       (EXU_cache_flush),
            .exception_flush   (WBU_exception_flush),
            .m_axi_araddr   (IFU_m_axi_araddr),
            .m_axi_arvalid  (IFU_m_axi_arvalid),
            .m_axi_arready  (ARB_s_axi_arready_A),
            .m_axi_arid     (IFU_m_axi_arid),
            .m_axi_arlen    (IFU_m_axi_arlen),
            .m_axi_arsize   (IFU_m_axi_arsize),
            .m_axi_arburst  (IFU_m_axi_arburst),
            .m_axi_rdata    (ARB_s_axi_rdata_A),
            .m_axi_rresp    (ARB_s_axi_rresp_A),
            .m_axi_rid      (ARB_s_axi_rid_A),
            .m_axi_rlast    (ARB_s_axi_rlast_A),
            .m_axi_rvalid   (ARB_s_axi_rvalid_A),
            .m_axi_rready   (IFU_m_axi_rready),
            .m_axi_awaddr   (IFU_m_axi_awaddr),
            .m_axi_awvalid  (IFU_m_axi_awvalid),
            .m_axi_awready  (ARB_s_axi_awready_A),
            .m_axi_awid     (IFU_m_axi_awid),
            .m_axi_awlen    (IFU_m_axi_awlen),
            .m_axi_awsize   (IFU_m_axi_awsize),
            .m_axi_awburst  (IFU_m_axi_awburst),
            .m_axi_wdata    (IFU_m_axi_wdata),
            .m_axi_wstrb    (IFU_m_axi_wstrb),
            .m_axi_wvalid   (IFU_m_axi_wvalid),
            .m_axi_wlast    (IFU_m_axi_wlast),
            .m_axi_wready   (ARB_s_axi_wready_A),
            .m_axi_bresp    (ARB_s_axi_bresp_A),
            .m_axi_bvalid   (ARB_s_axi_bvalid_A),
            .m_axi_bid      (ARB_s_axi_bid_A),
            .m_axi_bready   (IFU_m_axi_bready),
            .flush          (EXU_flush),
            .pc_en          (IFU_pc_en)
        );

    ysyx_26040125_GPR ysyx_26040125_GPR(
            .clk    (clock),
            .reset  (reset),
            .wdata  (WBU_wdata),
            .waddr  (WBU_waddr[3:0]),
            .wen    (WBU_wen),
            .raddr1 (IDU_rs1[3:0]),
            .rdata1 (GPR_rdata1),
            .raddr2 (IDU_rs2[3:0]),
            .rdata2 (GPR_rdata2)
        );

    ysyx_26040125_IDU ysyx_26040125_IDU(
            .clk            (clock),
            .reset          (reset),
            .s_Inst              (IFU_m_Inst),
            .s_PC                (IFU_m_PC),
            .s_meta_data_BTB     (IFU_m_meta_data_BTB),
            .s_hit_BTB           (IFU_m_hit_BTB),
            .s_has_exception     (IFU_m_has_exception),
            .s_exception_code    (IFU_m_exception_code),
            .s_valid             (IFU_m_valid),
            .s_ready             (IDU_s_ready),
            .m_meta_data_BTB     (IDU_m_meta_data_BTB),
            .m_hit_BTB           (IDU_m_hit_BTB),
            .m_rd                (IDU_m_rd),
            .m_srcR1        (IDU_m_srcR1),
            .m_srcR2        (IDU_m_srcR2),
            .m_imm          (IDU_m_imm),
            .m_alu_op       (IDU_m_alu_op),
            .m_alu_sel0     (IDU_m_alu_sel0),
            .m_alu_sel1     (IDU_m_alu_sel1),
            .m_wb_en        (IDU_m_wb_en),
            .m_mem_en       (IDU_m_mem_en),
            .m_mem_write_en (IDU_m_mem_write_en),
            .m_op_width     (IDU_m_op_width),
            .m_wb_sel       (IDU_m_wb_sel),
            .m_brju         (IDU_m_brju),
            .m_mem_signext  (IDU_m_mem_signext),
            .m_csr_addr     (IDU_m_csr_addr),
            .m_csr_data     (IDU_m_csr_data),
            .m_csr_wr_sel   (IDU_m_csr_wr_sel),
            .m_csr_wen      (IDU_m_csr_wen),
            .m_PC           (IDU_m_PC),
            .m_fencei       (IDU_m_fencei),
            .m_has_exception (IDU_m_has_exception),
            .m_exception_code (IDU_m_exception_code),
            .m_valid        (IDU_m_valid),
            .m_ready        (EXU_s_ready),
            .rs1            (IDU_rs1),
            .rs2            (IDU_rs2),
            .srcR1_in       (GPR_rdata1),
            .srcR2_in       (GPR_rdata2),
            .csr_data       (CSR_rdata),
            .csr_addr       (IDU_csr_addr),
            .rd_exu         (EXU_rd_exu),
            .csr_exu        (EXU_csr_exu),
            .rd_valid_exu   (EXU_rd_valid_exu),
            .csr_valid_exu  (EXU_csr_valid_exu),
            .rd_lsu         (LSU_rd_lsu),
            .csr_lsu        (LSU_csr_lsu),
            .rd_valid_lsu   (LSU_rd_valid_lsu),
            .csr_valid_lsu  (LSU_csr_valid_lsu),
            .rd_wbu         (WBU_rd_wbu),
            .csr_wbu        (WBU_csr_wbu),
            .rd_valid_wbu   (WBU_rd_valid_wbu),
            .csr_valid_wbu  (WBU_csr_valid_wbu),
            .flush          (EXU_flush),
            .exception_flush  (WBU_exception_flush),

            .forward_data_exu (EXU_forward_data_exu),
            .forward_ready_exu (EXU_forward_ready_exu),
            .csr_forward_data_exu (EXU_csr_forward_data_exu),
            .csr_forward_ready_exu (EXU_csr_forward_ready_exu),
            .forward_data_lsu (LSU_forward_data_lsu),
            .forward_ready_lsu (LSU_forward_ready_lsu),
            .csr_forward_data_lsu (LSU_csr_forward_data_lsu),
            .csr_forward_ready_lsu (LSU_csr_forward_ready_lsu),
            .forward_data_wbu (WBU_forward_data_wbu),
            .forward_ready_wbu (WBU_forward_ready_wbu),
            .csr_forward_data_wbu (WBU_csr_forward_data_wbu),
            .csr_forward_ready_wbu (WBU_csr_forward_ready_wbu)
        );

    ysyx_26040125_EXU ysyx_26040125_EXU(
            .clk            (clock),
            .reset          (reset),
            .s_rd           (IDU_m_rd),
            .s_srcR1        (IDU_m_srcR1),
            .s_srcR2        (IDU_m_srcR2),
            .s_imm          (IDU_m_imm),
            .s_alu_op       (IDU_m_alu_op),
            .s_alu_sel0     (IDU_m_alu_sel0),
            .s_alu_sel1     (IDU_m_alu_sel1),
            .s_wb_en        (IDU_m_wb_en),
            .s_mem_en       (IDU_m_mem_en),
            .s_mem_write_en (IDU_m_mem_write_en),
            .s_op_width     (IDU_m_op_width),
            .s_wb_sel       (IDU_m_wb_sel),
            .s_brju         (IDU_m_brju),
            .s_mem_signext  (IDU_m_mem_signext),
            .s_csr_addr     (IDU_m_csr_addr),
            .s_csr_data     (IDU_m_csr_data),
            .s_csr_wr_sel   (IDU_m_csr_wr_sel),
            .s_csr_wen      (IDU_m_csr_wen),
            .s_PC           (IDU_m_PC),
            .s_fencei       (IDU_m_fencei),
            .s_has_exception(IDU_m_has_exception),
            .s_exception_code(IDU_m_exception_code),
            .s_meta_data_BTB (IDU_m_meta_data_BTB),
            .s_hit_BTB       (IDU_m_hit_BTB),
            .s_valid        (IDU_m_valid),
            .s_ready        (EXU_s_ready),
            .m_rd           (EXU_m_rd),
            .m_wb_en        (EXU_m_wb_en),
            .m_mem_en       (EXU_m_mem_en),
            .m_mem_write_en (EXU_m_mem_write_en),
            .m_op_width     (EXU_m_op_width),
            .m_wb_sel       (EXU_m_wb_sel),
            .m_mem_signext  (EXU_m_mem_signext),
            .m_csr_addr     (EXU_m_csr_addr),
            .m_csr_data     (EXU_m_csr_data),
            .m_csr_wr_sel   (EXU_m_csr_wr_sel),
            .m_csr_wen      (EXU_m_csr_wen),
            .m_srcR1        (EXU_m_srcR1),
            .m_srcR2        (EXU_m_srcR2),
            .m_result       (EXU_m_result),
            .m_PC           (EXU_m_PC),
            .m_imm          (EXU_m_imm),
            .m_valid        (EXU_m_valid),
            .m_ready        (LSU_s_ready),
            .m_has_exception (EXU_m_has_exception),
            .m_exception_code (EXU_m_exception_code),
            .rd_exu         (EXU_rd_exu),
            .csr_exu        (EXU_csr_exu),
            .rd_valid_exu   (EXU_rd_valid_exu),
            .csr_valid_exu  (EXU_csr_valid_exu),
            .pcr_exu_result (EXU_pcr_exu_result),
            .pcr_imm        (EXU_pcr_imm       ),
            .pcr_behavior   (EXU_pcr_behavior  ),
            .pcr_pc_now     (EXU_pcr_pc_now    ),
            .flush          (EXU_flush         ),
            .cache_flush      (EXU_cache_flush   ),
            .exception_flush  (WBU_exception_flush),
            .forward_data_exu (EXU_forward_data_exu),
            .forward_ready_exu (EXU_forward_ready_exu),
            .csr_forward_data_exu (EXU_csr_forward_data_exu),
            .csr_forward_ready_exu (EXU_csr_forward_ready_exu),
            .PC_w            (EXU_PC_w),
            .target          (EXU_target),
            .meta_data       (EXU_meta_data),
            .write_en        (EXU_write_en)
        );

    ysyx_26040125_LSU ysyx_26040125_LSU(
            .clk            (clock),
            .reset          (reset),
            .s_rd           (EXU_m_rd),
            .s_wb_en        (EXU_m_wb_en),
            .s_mem_en       (EXU_m_mem_en),
            .s_mem_write_en (EXU_m_mem_write_en),
            .s_op_width     (EXU_m_op_width),
            .s_wb_sel       (EXU_m_wb_sel),
            .s_mem_signext  (EXU_m_mem_signext),
            .s_csr_addr     (EXU_m_csr_addr),
            .s_csr_data     (EXU_m_csr_data),
            .s_csr_wr_sel   (EXU_m_csr_wr_sel),
            .s_csr_wen      (EXU_m_csr_wen),
            .s_srcR1        (EXU_m_srcR1),
            .s_srcR2        (EXU_m_srcR2),
            .s_result       (EXU_m_result),
            .s_PC           (EXU_m_PC),
            .s_imm          (EXU_m_imm),
            .s_has_exception (EXU_m_has_exception),
            .s_exception_code (EXU_m_exception_code),
            .s_valid        (EXU_m_valid),
            .s_ready        (LSU_s_ready),
            .m_rd           (LSU_m_rd),
            .m_wb_en        (LSU_m_wb_en),
            .m_wb_sel       (LSU_m_wb_sel),
            .m_csr_addr     (LSU_m_csr_addr),
            .m_csr_data     (LSU_m_csr_data),
            .m_csr_wr_sel   (LSU_m_csr_wr_sel),
            .m_csr_wen      (LSU_m_csr_wen),
            .m_srcR1        (LSU_m_srcR1),
            .m_result       (LSU_m_result),
            .m_rdata        (LSU_m_rdata),
            .m_PC           (LSU_m_PC),
            .m_imm          (LSU_m_imm),
            .m_has_exception (LSU_m_has_exception),
            .m_exception_code (LSU_m_exception_code),
            .m_valid        (LSU_m_valid),
            .m_ready        (WBU_s_ready),
            .m_axi_araddr   (LSU_m_axi_araddr),
            .m_axi_arvalid  (LSU_m_axi_arvalid),
            .m_axi_arready  (ARB_s_axi_arready_B),
            .m_axi_arid     (LSU_m_axi_arid),
            .m_axi_arlen    (LSU_m_axi_arlen),
            .m_axi_arsize   (LSU_m_axi_arsize),
            .m_axi_arburst  (LSU_m_axi_arburst),
            .m_axi_rdata    (ARB_s_axi_rdata_B),
            .m_axi_rresp    (ARB_s_axi_rresp_B),
            .m_axi_rid      (ARB_s_axi_rid_B),
            .m_axi_rlast    (ARB_s_axi_rlast_B),
            .m_axi_rvalid   (ARB_s_axi_rvalid_B),
            .m_axi_rready   (LSU_m_axi_rready),
            .m_axi_awaddr   (LSU_m_axi_awaddr),
            .m_axi_awvalid  (LSU_m_axi_awvalid),
            .m_axi_awready  (ARB_s_axi_awready_B),
            .m_axi_awid     (LSU_m_axi_awid),
            .m_axi_awlen    (LSU_m_axi_awlen),
            .m_axi_awsize   (LSU_m_axi_awsize),
            .m_axi_awburst  (LSU_m_axi_awburst),
            .m_axi_wdata    (LSU_m_axi_wdata),
            .m_axi_wstrb    (LSU_m_axi_wstrb),
            .m_axi_wvalid   (LSU_m_axi_wvalid),
            .m_axi_wlast    (LSU_m_axi_wlast),
            .m_axi_wready   (ARB_s_axi_wready_B),
            .m_axi_bresp    (ARB_s_axi_bresp_B),
            .m_axi_bvalid   (ARB_s_axi_bvalid_B),
            .m_axi_bid      (ARB_s_axi_bid_B),
            .m_axi_bready   (LSU_m_axi_bready),
            .rd_lsu         (LSU_rd_lsu),
            .csr_lsu        (LSU_csr_lsu),
            .rd_valid_lsu   (LSU_rd_valid_lsu),
            .csr_valid_lsu  (LSU_csr_valid_lsu),
            .exception_flush  (WBU_exception_flush),
            .forward_data_lsu (LSU_forward_data_lsu),
            .forward_ready_lsu (LSU_forward_ready_lsu),
            .csr_forward_data_lsu (LSU_csr_forward_data_lsu),
            .csr_forward_ready_lsu (LSU_csr_forward_ready_lsu)
        );

    ysyx_26040125_WBU ysyx_26040125_WBU(
            .clk            (clock),
            .reset          (reset),
            .s_rd           (LSU_m_rd),
            .s_wb_en        (LSU_m_wb_en),
            .s_wb_sel       (LSU_m_wb_sel),
            .s_csr_addr     (LSU_m_csr_addr),
            .s_csr_data     (LSU_m_csr_data),
            .s_csr_wr_sel   (LSU_m_csr_wr_sel),
            .s_csr_wen      (LSU_m_csr_wen),
            .s_srcR1        (LSU_m_srcR1),
            .s_result       (LSU_m_result),
            .s_rdata        (LSU_m_rdata),
            .s_PC           (LSU_m_PC),
            .s_imm          (LSU_m_imm),
            .s_has_exception (LSU_m_has_exception),
            .s_exception_code (LSU_m_exception_code),
            .s_valid        (LSU_m_valid),
            .s_ready        (WBU_s_ready),
            .wen            (WBU_wen),
            .wdata          (WBU_wdata),
            .waddr          (WBU_waddr),
            .csr_addr_      (WBU_csr_addr_),
            .csr_srcR1_     (WBU_csr_srcR1_),
            .csr_alu_res_   (WBU_csr_alu_res_),
            .csr_wr_sel_    (WBU_csr_wr_sel_),
            .csr_wen_       (WBU_csr_wen_),
            .csr_exception   (WBU_csr_exception),
            .csr_epc_       (WBU_csr_epc_),
            .csr_cause_     (WBU_csr_cause_),
            .rd_wbu         (WBU_rd_wbu),
            .csr_wbu        (WBU_csr_wbu),
            .rd_valid_wbu   (WBU_rd_valid_wbu),
            .csr_valid_wbu  (WBU_csr_valid_wbu),
            .exception_flush  (WBU_exception_flush),
            .forward_data_wbu (WBU_forward_data_wbu),
            .forward_ready_wbu (WBU_forward_ready_wbu),
            .csr_forward_data_wbu (WBU_csr_forward_data_wbu),
            .csr_forward_ready_wbu (WBU_csr_forward_ready_wbu)
        );

    ysyx_26040125_CSR ysyx_26040125_CSR(
            .clk     (clock),
            .reset   (reset),
            .waddr    (WBU_csr_addr_),
            .raddr    (IDU_csr_addr),
            .srcR1   (WBU_csr_srcR1_),
            .alu_res (WBU_csr_alu_res_),
            .wr_sel  (WBU_csr_wr_sel_),
            .wen     (WBU_csr_wen_),
            .exception (WBU_csr_exception),
            .w_epc   (WBU_csr_epc_),
            .w_cause (WBU_csr_cause_),
            .rdata   (CSR_rdata),
            .mtvec_out (CSR_mtvec_out),
            .mepc_out (CSR_mepc_out)
        );



    ysyx_26040125_ARB ysyx_26040125_ARB(
            .clk               ( clock                ),
            .reset             ( reset                ),
            .s_axi_araddr_A    ( IFU_m_axi_araddr     ),
            .s_axi_arvalid_A   ( IFU_m_axi_arvalid    ),
            .s_axi_arready_A   ( ARB_s_axi_arready_A  ),
            .s_axi_arid_A      ( IFU_m_axi_arid       ),
            .s_axi_arlen_A     ( IFU_m_axi_arlen      ),
            .s_axi_arsize_A    ( IFU_m_axi_arsize     ),
            .s_axi_arburst_A   ( IFU_m_axi_arburst    ),
            .s_axi_rdata_A     ( ARB_s_axi_rdata_A    ),
            .s_axi_rresp_A     ( ARB_s_axi_rresp_A    ),
            .s_axi_rvalid_A    ( ARB_s_axi_rvalid_A   ),
            .s_axi_rready_A    ( IFU_m_axi_rready     ),
            .s_axi_rid_A       ( ARB_s_axi_rid_A      ),
            .s_axi_rlast_A     ( ARB_s_axi_rlast_A    ),
            .s_axi_awaddr_A    ( IFU_m_axi_awaddr     ),
            .s_axi_awvalid_A   ( IFU_m_axi_awvalid    ),
            .s_axi_awready_A   ( ARB_s_axi_awready_A  ),
            .s_axi_awid_A      ( IFU_m_axi_awid       ),
            .s_axi_awlen_A     ( IFU_m_axi_awlen      ),
            .s_axi_awsize_A    ( IFU_m_axi_awsize     ),
            .s_axi_awburst_A   ( IFU_m_axi_awburst    ),
            .s_axi_wdata_A     ( IFU_m_axi_wdata      ),
            .s_axi_wstrb_A     ( IFU_m_axi_wstrb      ),
            .s_axi_wvalid_A    ( IFU_m_axi_wvalid     ),
            .s_axi_wready_A    ( ARB_s_axi_wready_A   ),
            .s_axi_wlast_A     ( IFU_m_axi_wlast      ),
            .s_axi_bresp_A     ( ARB_s_axi_bresp_A    ),
            .s_axi_bvalid_A    ( ARB_s_axi_bvalid_A   ),
            .s_axi_bready_A    ( IFU_m_axi_bready     ),
            .s_axi_bid_A       ( ARB_s_axi_bid_A      ),

            .s_axi_araddr_B    ( LSU_m_axi_araddr     ),
            .s_axi_arvalid_B   ( LSU_m_axi_arvalid    ),
            .s_axi_arready_B   ( ARB_s_axi_arready_B  ),
            .s_axi_arid_B      ( LSU_m_axi_arid       ),
            .s_axi_arlen_B     ( LSU_m_axi_arlen      ),
            .s_axi_arsize_B    ( LSU_m_axi_arsize     ),
            .s_axi_arburst_B   ( LSU_m_axi_arburst    ),
            .s_axi_rdata_B     ( ARB_s_axi_rdata_B    ),
            .s_axi_rresp_B     ( ARB_s_axi_rresp_B    ),
            .s_axi_rvalid_B    ( ARB_s_axi_rvalid_B   ),
            .s_axi_rready_B    ( LSU_m_axi_rready     ),
            .s_axi_rid_B       ( ARB_s_axi_rid_B      ),
            .s_axi_rlast_B     ( ARB_s_axi_rlast_B    ),
            .s_axi_awaddr_B    ( LSU_m_axi_awaddr     ),
            .s_axi_awvalid_B   ( LSU_m_axi_awvalid    ),
            .s_axi_awready_B   ( ARB_s_axi_awready_B  ),
            .s_axi_awid_B      ( LSU_m_axi_awid       ),
            .s_axi_awlen_B     ( LSU_m_axi_awlen      ),
            .s_axi_awsize_B    ( LSU_m_axi_awsize     ),
            .s_axi_awburst_B   ( LSU_m_axi_awburst    ),
            .s_axi_wdata_B     ( LSU_m_axi_wdata      ),
            .s_axi_wstrb_B     ( LSU_m_axi_wstrb      ),
            .s_axi_wvalid_B    ( LSU_m_axi_wvalid     ),
            .s_axi_wready_B    ( ARB_s_axi_wready_B   ),
            .s_axi_wlast_B     ( LSU_m_axi_wlast      ),
            .s_axi_bresp_B     ( ARB_s_axi_bresp_B    ),
            .s_axi_bvalid_B    ( ARB_s_axi_bvalid_B   ),
            .s_axi_bready_B    ( LSU_m_axi_bready     ),
            .s_axi_bid_B       ( ARB_s_axi_bid_B      ),

            .m_axi_araddr      ( ARB_m_axi_araddr     ),
            .m_axi_arvalid     ( ARB_m_axi_arvalid    ),
            .m_axi_arready     ( XBAR_s_axi_arready   ),
            .m_axi_arid        ( ARB_m_axi_arid       ),
            .m_axi_arlen       ( ARB_m_axi_arlen      ),
            .m_axi_arsize      ( ARB_m_axi_arsize     ),
            .m_axi_arburst     ( ARB_m_axi_arburst    ),
            .m_axi_rdata       ( XBAR_s_axi_rdata     ),
            .m_axi_rresp       ( XBAR_s_axi_rresp     ),
            .m_axi_rid         ( XBAR_s_axi_rid       ),
            .m_axi_rlast       ( XBAR_s_axi_rlast     ),
            .m_axi_rvalid      ( XBAR_s_axi_rvalid    ),
            .m_axi_rready      ( ARB_m_axi_rready     ),
            .m_axi_awaddr      ( ARB_m_axi_awaddr     ),
            .m_axi_awvalid     ( ARB_m_axi_awvalid    ),
            .m_axi_awready     ( XBAR_s_axi_awready   ),
            .m_axi_awid        ( ARB_m_axi_awid       ),
            .m_axi_awlen       ( ARB_m_axi_awlen      ),
            .m_axi_awsize      ( ARB_m_axi_awsize     ),
            .m_axi_awburst     ( ARB_m_axi_awburst    ),
            .m_axi_wdata       ( ARB_m_axi_wdata      ),
            .m_axi_wstrb       ( ARB_m_axi_wstrb      ),
            .m_axi_wvalid      ( ARB_m_axi_wvalid     ),
            .m_axi_wlast       ( ARB_m_axi_wlast      ),
            .m_axi_wready      ( XBAR_s_axi_wready    ),
            .m_axi_bresp       ( XBAR_s_axi_bresp     ),
            .m_axi_bvalid      ( XBAR_s_axi_bvalid    ),
            .m_axi_bid         ( XBAR_s_axi_bid       ),
            .m_axi_bready      ( ARB_m_axi_bready     )
        );

    ysyx_26040125_XBAR ysyx_26040125_XBAR(
            .clk               (clock),
            .reset             (reset),

            .s_axi_arid        (ARB_m_axi_arid),
            .s_axi_araddr      (ARB_m_axi_araddr),
            .s_axi_arlen       (ARB_m_axi_arlen),
            .s_axi_arsize      (ARB_m_axi_arsize),
            .s_axi_arburst     (ARB_m_axi_arburst),
            .s_axi_arvalid     (ARB_m_axi_arvalid),
            .s_axi_arready     (XBAR_s_axi_arready),
            .s_axi_rid         (XBAR_s_axi_rid),
            .s_axi_rdata       (XBAR_s_axi_rdata),
            .s_axi_rresp       (XBAR_s_axi_rresp),
            .s_axi_rlast       (XBAR_s_axi_rlast),
            .s_axi_rvalid      (XBAR_s_axi_rvalid),
            .s_axi_rready      (ARB_m_axi_rready),
            .s_axi_awid        (ARB_m_axi_awid),
            .s_axi_awaddr      (ARB_m_axi_awaddr),
            .s_axi_awlen       (ARB_m_axi_awlen),
            .s_axi_awsize      (ARB_m_axi_awsize),
            .s_axi_awburst     (ARB_m_axi_awburst),
            .s_axi_awvalid     (ARB_m_axi_awvalid),
            .s_axi_awready     (XBAR_s_axi_awready),
            .s_axi_wdata       (ARB_m_axi_wdata),
            .s_axi_wstrb       (ARB_m_axi_wstrb),
            .s_axi_wlast       (ARB_m_axi_wlast),
            .s_axi_wvalid      (ARB_m_axi_wvalid),
            .s_axi_wready      (XBAR_s_axi_wready),
            .s_axi_bid         (XBAR_s_axi_bid),
            .s_axi_bresp       (XBAR_s_axi_bresp),
            .s_axi_bvalid      (XBAR_s_axi_bvalid),
            .s_axi_bready      (ARB_m_axi_bready),

            // Master A -> MTIME
            .m_axi_arid_A      (XBAR_m_axi_arid_A),
            .m_axi_araddr_A    (XBAR_m_axi_araddr_A),
            .m_axi_arlen_A     (XBAR_m_axi_arlen_A),
            .m_axi_arsize_A    (XBAR_m_axi_arsize_A),
            .m_axi_arburst_A   (XBAR_m_axi_arburst_A),
            .m_axi_arvalid_A   (XBAR_m_axi_arvalid_A),
            .m_axi_arready_A   (MTIME_s_axi_arready),
            .m_axi_rid_A       (MTIME_s_axi_rid),
            .m_axi_rdata_A     (MTIME_s_axi_rdata),
            .m_axi_rresp_A     (MTIME_s_axi_rresp),
            .m_axi_rlast_A     (MTIME_s_axi_rlast),
            .m_axi_rvalid_A    (MTIME_s_axi_rvalid),
            .m_axi_rready_A    (XBAR_m_axi_rready_A),
            .m_axi_awid_A      (XBAR_m_axi_awid_A),
            .m_axi_awaddr_A    (XBAR_m_axi_awaddr_A),
            .m_axi_awlen_A     (XBAR_m_axi_awlen_A),
            .m_axi_awsize_A    (XBAR_m_axi_awsize_A),
            .m_axi_awburst_A   (XBAR_m_axi_awburst_A),
            .m_axi_awvalid_A   (XBAR_m_axi_awvalid_A),
            .m_axi_awready_A   (MTIME_s_axi_awready),
            .m_axi_wdata_A     (XBAR_m_axi_wdata_A),
            .m_axi_wstrb_A     (XBAR_m_axi_wstrb_A),
            .m_axi_wlast_A     (XBAR_m_axi_wlast_A),
            .m_axi_wvalid_A    (XBAR_m_axi_wvalid_A),
            .m_axi_wready_A    (MTIME_s_axi_wready),
            .m_axi_bid_A       (MTIME_s_axi_bid),
            .m_axi_bresp_A     (MTIME_s_axi_bresp),
            .m_axi_bvalid_A    (MTIME_s_axi_bvalid),
            .m_axi_bready_A    (XBAR_m_axi_bready_A),

            // Master B -> external io_master
            .m_axi_arid_B      (XBAR_m_axi_arid_B),
            .m_axi_araddr_B    (XBAR_m_axi_araddr_B),
            .m_axi_arlen_B     (XBAR_m_axi_arlen_B),
            .m_axi_arsize_B    (XBAR_m_axi_arsize_B),
            .m_axi_arburst_B   (XBAR_m_axi_arburst_B),
            .m_axi_arvalid_B   (XBAR_m_axi_arvalid_B),
            .m_axi_arready_B   (io_master_arready),
            .m_axi_rid_B       (io_master_rid),
            .m_axi_rdata_B     (io_master_rdata),
            .m_axi_rresp_B     (io_master_rresp),
            .m_axi_rlast_B     (io_master_rlast),
            .m_axi_rvalid_B    (io_master_rvalid),
            .m_axi_rready_B    (XBAR_m_axi_rready_B),
            .m_axi_awid_B      (XBAR_m_axi_awid_B),
            .m_axi_awaddr_B    (XBAR_m_axi_awaddr_B),
            .m_axi_awlen_B     (XBAR_m_axi_awlen_B),
            .m_axi_awsize_B    (XBAR_m_axi_awsize_B),
            .m_axi_awburst_B   (XBAR_m_axi_awburst_B),
            .m_axi_awvalid_B   (XBAR_m_axi_awvalid_B),
            .m_axi_awready_B   (io_master_awready),
            .m_axi_wdata_B     (XBAR_m_axi_wdata_B),
            .m_axi_wstrb_B     (XBAR_m_axi_wstrb_B),
            .m_axi_wlast_B     (XBAR_m_axi_wlast_B),
            .m_axi_wvalid_B    (XBAR_m_axi_wvalid_B),
            .m_axi_wready_B    (io_master_wready),
            .m_axi_bid_B       (io_master_bid),
            .m_axi_bresp_B     (io_master_bresp),
            .m_axi_bvalid_B    (io_master_bvalid),
            .m_axi_bready_B    (XBAR_m_axi_bready_B)
        );

    ysyx_26040125_MTIME ysyx_26040125_MTIME(
            .clk           ( clock                  ),
            .reset         ( reset                  ),
            .s_axi_arid    ( XBAR_m_axi_arid_A      ),
            .s_axi_araddr  ( XBAR_m_axi_araddr_A    ),
            .s_axi_arlen   ( XBAR_m_axi_arlen_A     ),
            .s_axi_arsize  ( XBAR_m_axi_arsize_A    ),
            .s_axi_arburst ( XBAR_m_axi_arburst_A   ),
            .s_axi_arvalid ( XBAR_m_axi_arvalid_A   ),
            .s_axi_arready ( MTIME_s_axi_arready     ),
            .s_axi_rid     ( MTIME_s_axi_rid         ),
            .s_axi_rdata   ( MTIME_s_axi_rdata       ),
            .s_axi_rresp   ( MTIME_s_axi_rresp       ),
            .s_axi_rlast   ( MTIME_s_axi_rlast       ),
            .s_axi_rvalid  ( MTIME_s_axi_rvalid      ),
            .s_axi_rready  ( XBAR_m_axi_rready_A    ),
            .s_axi_awid    ( XBAR_m_axi_awid_A      ),
            .s_axi_awaddr  ( XBAR_m_axi_awaddr_A    ),
            .s_axi_awlen   ( XBAR_m_axi_awlen_A     ),
            .s_axi_awsize  ( XBAR_m_axi_awsize_A    ),
            .s_axi_awburst ( XBAR_m_axi_awburst_A   ),
            .s_axi_awvalid ( XBAR_m_axi_awvalid_A   ),
            .s_axi_awready ( MTIME_s_axi_awready     ),
            .s_axi_wdata   ( XBAR_m_axi_wdata_A     ),
            .s_axi_wstrb   ( XBAR_m_axi_wstrb_A     ),
            .s_axi_wlast   ( XBAR_m_axi_wlast_A     ),
            .s_axi_wvalid  ( XBAR_m_axi_wvalid_A    ),
            .s_axi_wready  ( MTIME_s_axi_wready      ),
            .s_axi_bid     ( MTIME_s_axi_bid         ),
            .s_axi_bresp   ( MTIME_s_axi_bresp       ),
            .s_axi_bvalid  ( MTIME_s_axi_bvalid      ),
            .s_axi_bready  ( XBAR_m_axi_bready_A    )
        );

    ysyx_26040125_BTB#(
        .ENTRY_NUM(8)
    )ysyx_26040125_BTB(
            .clk         (clock),
            .reset       (reset),
            .PC_r        (PCR_PC),
            .PC_w        (EXU_PC_w),
            .target      (EXU_target),
            .meta_data   (EXU_meta_data),
            .write_en    (EXU_write_en),
            .target_BTB    (BTB_target_BTB),
            .meta_data_BTB (BTB_meta_data_BTB),
            .hit_BTB       (BTB_hit_BTB)
        );

endmodule
