module ICACHE#(
    parameter LINE_NUM = 16,
    parameter LINE_SIZE = 4
)(
    input clk,
    input reset,

    input  [3:0]  s_axi_arid,
    input  [31:0] s_axi_araddr,
    input  [7:0]  s_axi_arlen,
    input  [2:0]  s_axi_arsize,
    input  [1:0]  s_axi_arburst,
    input         s_axi_arvalid,
    output        s_axi_arready,

    output [3:0]  s_axi_rid,
    output [31:0] s_axi_rdata,
    output [1:0]  s_axi_rresp,
    output        s_axi_rlast,
    output        s_axi_rvalid,
    input         s_axi_rready,


    /*verilator lint_off UNUSED */
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

    output [3:0]  s_axi_bid,
    output [1:0]  s_axi_bresp,
    output        s_axi_bvalid,
    input         s_axi_bready,
    /*verilator lint_on UNUSED */


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
    localparam TAG_SIZE = 32 - $clog2(LINE_NUM) - $clog2(LINE_SIZE);
    /*unused axi signal(write channel)*/
    assign s_axi_awready = 1'b0;
    assign s_axi_wready = 1'b0;
    assign s_axi_bresp = 2'b00;
    assign s_axi_bvalid = 1'b0;
    assign s_axi_bid = 4'b0000;
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

    wire [$clog2(LINE_NUM)-1:0] index = addr_reg[$clog2(LINE_SIZE)+$clog2(LINE_NUM)-1:$clog2(LINE_SIZE)];
    wire [TAG_SIZE-1:0] tag = addr_reg[31:$clog2(LINE_SIZE)+$clog2(LINE_NUM)];
    wire hit = valid[index] && tags[index] == tag;

    localparam IDLE = 3'd0, JUDGE = 3'd1, REQ = 3'd2, WAIT = 3'd3, RESP = 3'd4;
    reg [2:0] state, next_state;

    always @(*) begin
        case(state)
            IDLE: next_state = (s_axi_arvalid & s_axi_arready) ? JUDGE : state;
            JUDGE: next_state = hit ? RESP : REQ;
            REQ: next_state = m_axi_arvalid && m_axi_arready ? WAIT : state;
            WAIT: next_state = m_axi_rvalid && m_axi_rready ? RESP : state;
            RESP: next_state = s_axi_rvalid && s_axi_rready ? IDLE : state;
            default: next_state = IDLE;
        endcase
    end

    always @(posedge clk) begin
        if(reset) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    reg [3:0] id_reg;
    reg [31:0] addr_reg;
    reg [7:0] len_reg;
    reg [2:0] size_reg;
    reg [1:0] burst_reg;
    always @(posedge clk) begin
        if(reset) begin
            id_reg <= 4'b0;
            addr_reg <= 32'b0;
            len_reg <= 8'b0;
            size_reg <= 3'b0;
            burst_reg <= 2'b0;
        end
        else if(state == IDLE && s_axi_arvalid && s_axi_arready) begin
            id_reg <= s_axi_arid;
            addr_reg <= s_axi_araddr;
            len_reg <= s_axi_arlen;
            size_reg <= s_axi_arsize;
            burst_reg <= s_axi_arburst;
        end
    end

    integer i;
    always @(posedge clk) begin
        if(reset) begin
            for(i = 0; i < LINE_NUM; i = i + 1) begin
                valid[i] <= 1'b0;
                tags[i] <= {TAG_SIZE{1'b0}};
                cache[i] <= {(LINE_SIZE*8){1'b0}};
            end
        end
        else if(state == WAIT && m_axi_rvalid && m_axi_rready) begin
            cache[index] <= m_axi_rdata;
            tags[index] <= tag;
            valid[index] <= 1'b1;
        end
    end

    assign s_axi_arready = state == IDLE;
    assign s_axi_rid = id_reg;
    assign s_axi_rdata = cache[index];
    assign s_axi_rresp = 2'b00;
    assign s_axi_rlast = 1'b1;
    assign s_axi_rvalid = state == RESP;
    assign m_axi_araddr = addr_reg;
    assign m_axi_arvalid = state == REQ;
    assign m_axi_arid = id_reg;
    assign m_axi_arlen = len_reg;
    assign m_axi_arsize = size_reg;
    assign m_axi_arburst = burst_reg;
    assign m_axi_rready = state == WAIT;
endmodule
