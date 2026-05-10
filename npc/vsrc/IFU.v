import PKG::itrace;
module IFU(
    input clk,
    input reset,

    input next_inst,

    output [31:0] m_Inst,
    output [31:0] m_PC,
    output m_valid,
    input m_ready,

    input [31:0] PC,

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
    output m_axi_bready
);

    localparam IDLE = 2'b00, REQ = 2'b01, WAIT = 2'b10, PASS = 2'b11;
    reg [1:0] state, next_state;
    always @(*) begin
        case(state)
            IDLE: next_state = next_inst ? REQ : state;
            REQ: next_state = m_axi_arvalid && m_axi_arready ? WAIT : state;
            WAIT: next_state = m_axi_rvalid && m_axi_rready ? PASS : state;
            PASS: next_state = m_valid && m_ready ? IDLE : state;
            default: next_state = REQ;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            state <= REQ;
        end
        else begin
            state <= next_state;
        end
    end

    /*Unused AXI signals*/
    assign m_axi_awaddr = 32'b0;
    assign m_axi_awvalid = 1'b0;
    assign m_axi_wdata = 32'b0;
    assign m_axi_wstrb = 4'b0;
    assign m_axi_wvalid = 1'b0;
    assign m_axi_bready = 1'b0;
    assign m_axi_awid = 4'b0;
    assign m_axi_awlen = 8'b0;
    assign m_axi_awsize = 3'b0;
    assign m_axi_awburst = 2'b0;
    assign m_axi_wlast = 1'b0;


    /*logic to recv rdata*/
    reg [31:0] m_axi_rdata_reg;
    assign m_axi_rready = state == WAIT;
    always @(posedge clk) begin
        if(reset) begin
            m_axi_rdata_reg <= 32'b0;
        end

        else begin
            if(m_axi_rready && m_axi_rvalid) begin
                m_axi_rdata_reg <= m_axi_rdata;
                itrace(m_axi_rdata, PC);
            end
        end
    end


    /*logic to send ardata*/
    assign m_axi_araddr = PC;
    assign m_axi_arvalid = state == REQ;
    assign m_axi_arid = 4'b0;
    assign m_axi_arlen = 8'b0;
    assign m_axi_arsize = 3'b010; //4 bytes
    assign m_axi_arburst = 2'b01; //INCR


    /*logic to send data*/
    assign m_Inst = m_axi_rdata_reg;
    assign m_PC = PC;
    assign m_valid = state == PASS;


endmodule
