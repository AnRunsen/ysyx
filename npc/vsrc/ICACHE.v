`ifndef SYNTHESIS
    import PKG::ihit_num;
`endif
module ICACHE#(
    parameter LINE_NUM = 16,
    parameter LINE_SIZE = 16
)(
    input clk,
    input reset,

    input cache_flush,

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

    `ifndef SYNTHESIS
        always @(posedge clk) begin
            if(state == IDLE && s_axi_arvalid && s_axi_arready && hit) begin
                ihit_num();
            end
        end
    `endif


    localparam TAG_SIZE = 32 - $clog2(LINE_NUM) - $clog2(LINE_SIZE);
    localparam WORDS_PER_LINE = LINE_SIZE / 4;
    localparam WORDS_SEL_SIZE = $clog2(WORDS_PER_LINE);
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

    wire [$clog2(LINE_NUM)-1:0] index = s_axi_araddr[$clog2(LINE_SIZE)+$clog2(LINE_NUM)-1:$clog2(LINE_SIZE)];
    wire [TAG_SIZE-1:0] tag = s_axi_araddr[31:$clog2(LINE_SIZE)+$clog2(LINE_NUM)];
    wire hit = valid[index] && tags[index] == tag;

    localparam IDLE = 2'd0, REQ = 2'd1, WAIT = 2'd2, RESP = 2'd3;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            IDLE: next_state = (s_axi_arvalid & s_axi_arready) ? (hit ? RESP : REQ) : state;
            REQ: next_state = m_axi_arvalid && m_axi_arready ? WAIT : state;
            WAIT: next_state = m_axi_rvalid && m_axi_rready && m_axi_rlast ? RESP : state;
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


    /*logic to latch data*/
    reg [3:0] id_reg;
    reg [31:0] addr_reg;
    reg [$clog2(LINE_NUM)-1:0] index_reg;
    reg [TAG_SIZE-1:0] tag_reg;
    wire [WORDS_SEL_SIZE-1:0] word_sel = addr_reg[$clog2(LINE_SIZE)-1:2];
    always @(posedge clk) begin
        if(reset) begin
            id_reg <= 4'b0;
            addr_reg <= 32'b0;
            index_reg <= 0;
            tag_reg <= 0;
        end
        else if(state == IDLE && s_axi_arvalid && s_axi_arready) begin
            id_reg <= s_axi_arid;
            addr_reg <= s_axi_araddr;
            index_reg <= index;
            tag_reg <= tag;
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
        else if(state == WAIT && m_axi_rvalid && m_axi_rready) begin
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

    assign s_axi_arready = state == IDLE;
    assign s_axi_rid = id_reg;
    assign s_axi_rdata = cache[index_reg][word_sel*32 +: 32];
    assign s_axi_rresp = 2'b00;
    assign s_axi_rlast = 1'b1;
    assign s_axi_rvalid = state == RESP;

    assign m_axi_araddr = {addr_reg[31:4], 4'b0};
    assign m_axi_arvalid = state == REQ;
    assign m_axi_arid = id_reg;
    assign m_axi_arlen = WORDS_PER_LINE-1;
    assign m_axi_arsize = 3'd2;
    assign m_axi_arburst = 2'b01; // INCR
    assign m_axi_rready = state == WAIT;
endmodule
