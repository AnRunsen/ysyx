module XBAR(
    /*axi lite port*/
    input clk,
    input reset,

    input [31:0] s_axi_araddr,
    input s_axi_arvalid,
    output s_axi_arready,

    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input s_axi_rready,

    input [31:0] s_axi_awaddr,
    input s_axi_awvalid,
    output s_axi_awready,

    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input s_axi_wvalid,
    output s_axi_wready,

    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready,

    /*m axi port A*/
    output [31:0] m_axi_araddr_A,
    output m_axi_arvalid_A,
    input m_axi_arready_A,

    input [31:0] m_axi_rdata_A,
    input [1:0] m_axi_rresp_A,
    input m_axi_rvalid_A,
    output m_axi_rready_A,

    output [31:0] m_axi_awaddr_A,
    output m_axi_awvalid_A,
    input m_axi_awready_A,

    output [31:0] m_axi_wdata_A,
    output [3:0] m_axi_wstrb_A,
    output m_axi_wvalid_A,
    input m_axi_wready_A,

    input [1:0] m_axi_bresp_A,
    input m_axi_bvalid_A,
    output m_axi_bready_A,

    /*m axi port B*/
    output [31:0] m_axi_araddr_B,
    output m_axi_arvalid_B,
    input m_axi_arready_B,

    input [31:0] m_axi_rdata_B,
    input [1:0] m_axi_rresp_B,
    input m_axi_rvalid_B,
    output m_axi_rready_B,

    output [31:0] m_axi_awaddr_B,
    output m_axi_awvalid_B,
    input m_axi_awready_B,

    output [31:0] m_axi_wdata_B,
    output [3:0] m_axi_wstrb_B,
    output m_axi_wvalid_B,
    input m_axi_wready_B,

    input [1:0] m_axi_bresp_B,
    input m_axi_bvalid_B,
    output m_axi_bready_B,

    /*m axi port C*/
    output [31:0] m_axi_araddr_C,
    output m_axi_arvalid_C,
    input m_axi_arready_C,

    input [31:0] m_axi_rdata_C,
    input [1:0] m_axi_rresp_C,
    input m_axi_rvalid_C,
    output m_axi_rready_C,

    output [31:0] m_axi_awaddr_C,
    output m_axi_awvalid_C,
    input m_axi_awready_C,

    output [31:0] m_axi_wdata_C,
    output [3:0] m_axi_wstrb_C,
    output m_axi_wvalid_C,
    input m_axi_wready_C,

    input [1:0] m_axi_bresp_C,
    input m_axi_bvalid_C,
    output m_axi_bready_C
);

    function [1:0] addr_sel;
        input [31:0] addr;
        begin
            if(addr == 32'h1000_0000) addr_sel = 2'd0; // select port A
            else if(addr == 32'h1000_0004 || addr == 32'h1000_0008) addr_sel = 2'd2; // select port C
            else addr_sel = 2'd1; // default to port B
        end
    endfunction

    /*read channel*/
    localparam READ_IDLE = 2'b00, READ_REQ = 2'b01, READ_WAIT = 2'b10;
    reg [1:0] r_state, r_next_state;
    reg [1:0] r_sel;

    always @(*) begin
        case (r_state)
            READ_IDLE: r_next_state = (s_axi_arvalid && s_axi_arready) ? READ_REQ  : READ_IDLE;
            READ_REQ:  r_next_state = (r_sel == 2'd0 ? m_axi_arready_A : (r_sel == 2'd1 ? m_axi_arready_B : m_axi_arready_C)) ? READ_WAIT : READ_REQ;
            READ_WAIT: r_next_state = (s_axi_rvalid  && s_axi_rready)              ? READ_IDLE : READ_WAIT;
            default:   r_next_state = READ_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) r_state <= READ_IDLE;
        else        r_state <= r_next_state;
    end

    assign s_axi_arready = (r_state == READ_IDLE);

    reg [31:0] raddr;
    always @(posedge clk) begin
        if (reset) begin
            raddr <= 32'b0;
            r_sel <= 2'd0;
        end else if (s_axi_arvalid && s_axi_arready) begin
            raddr <= s_axi_araddr;
            r_sel <= addr_sel(s_axi_araddr);
        end
    end

    assign m_axi_araddr_A  = raddr;
    assign m_axi_arvalid_A = (r_state == READ_REQ)  && (r_sel == 2'd0);
    assign m_axi_araddr_B  = raddr;
    assign m_axi_arvalid_B = (r_state == READ_REQ)  &&  (r_sel == 2'd1);
    assign m_axi_araddr_C  = raddr;
    assign m_axi_arvalid_C = (r_state == READ_REQ)  &&  (r_sel == 2'd2);

    assign m_axi_rready_A  = (r_state == READ_WAIT) && (r_sel == 2'd0) && s_axi_rready;
    assign m_axi_rready_B  = (r_state == READ_WAIT) &&  (r_sel == 2'd1) && s_axi_rready;
    assign m_axi_rready_C  = (r_state == READ_WAIT) &&  (r_sel == 2'd2) && s_axi_rready;

    assign s_axi_rdata  = (r_state == READ_WAIT) ? (r_sel == 2'd0 ? m_axi_rdata_A : (r_sel == 2'd1 ? m_axi_rdata_B : m_axi_rdata_C))  : 32'b0;
    assign s_axi_rresp  = (r_state == READ_WAIT) ? (r_sel == 2'd0 ? m_axi_rresp_A : (r_sel == 2'd1 ? m_axi_rresp_B : m_axi_rresp_C))  : 2'b0;
    assign s_axi_rvalid = (r_state == READ_WAIT) ? (r_sel == 2'd0 ? m_axi_rvalid_A : (r_sel == 2'd1 ? m_axi_rvalid_B : m_axi_rvalid_C)) : 1'b0;


    /*write channel*/
    localparam WRITE_IDLE      = 3'b000,
               WRITE_WAIT_ADDR = 3'b001,
               WRITE_WAIT_DATA = 3'b010,
               WRITE_REQ_ADDR  = 3'b011,
               WRITE_REQ_DATA  = 3'b100,
               WRITE_RESP      = 3'b101;
    reg [2:0] w_state, w_next_state;
    reg [1:0] w_sel;

    always @(*) begin
        case (w_state)
            WRITE_IDLE: begin
                if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready)
                    w_next_state = WRITE_REQ_ADDR;
                else if (s_axi_awvalid && s_axi_awready)
                    w_next_state = WRITE_WAIT_DATA;
                else if (s_axi_wvalid && s_axi_wready)
                    w_next_state = WRITE_WAIT_ADDR;
                else
                    w_next_state = WRITE_IDLE;
            end

            WRITE_WAIT_DATA: w_next_state = (s_axi_wvalid  && s_axi_wready) ? WRITE_REQ_ADDR : WRITE_WAIT_DATA;
            WRITE_WAIT_ADDR: w_next_state = (s_axi_awvalid && s_axi_awready) ? WRITE_REQ_ADDR : WRITE_WAIT_ADDR;
            WRITE_REQ_ADDR: w_next_state = (w_sel == 2'd0 ? m_axi_awready_A : (w_sel == 2'd1 ? m_axi_awready_B : m_axi_awready_C)) ? WRITE_REQ_DATA : WRITE_REQ_ADDR;
            WRITE_REQ_DATA: w_next_state = (w_sel == 2'd0 ? m_axi_wready_A  : (w_sel == 2'd1 ? m_axi_wready_B : m_axi_wready_C)) ? WRITE_RESP : WRITE_REQ_DATA;
            WRITE_RESP: w_next_state = (s_axi_bvalid  && s_axi_bready) ? WRITE_IDLE : WRITE_RESP;
            default: w_next_state = WRITE_IDLE;
        endcase
    end

    always @(posedge clk) begin
        if (reset) w_state <= WRITE_IDLE;
        else        w_state <= w_next_state;
    end

    assign s_axi_awready = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_ADDR);
    assign s_axi_wready  = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_DATA);

    reg [31:0] waddr;
    reg [31:0] wdata;
    reg [3:0]  wstrb;

    always @(posedge clk) begin
        if (reset) begin
            waddr <= 32'b0;
            w_sel <= 2'd0;
        end
        else if (s_axi_awvalid && s_axi_awready) begin
            waddr <= s_axi_awaddr;
            w_sel <= addr_sel(s_axi_awaddr);
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            wdata <= 32'b0;
            wstrb <= 4'b0;
        end else if (s_axi_wvalid && s_axi_wready) begin
            wdata <= s_axi_wdata;
            wstrb <= s_axi_wstrb;
        end
    end

    assign m_axi_awaddr_A  = waddr;
    assign m_axi_awvalid_A = (w_state == WRITE_REQ_ADDR) && (w_sel == 2'd0);
    assign m_axi_wdata_A   = wdata;
    assign m_axi_wstrb_A   = wstrb;
    assign m_axi_wvalid_A  = (w_state == WRITE_REQ_DATA) && (w_sel == 2'd0);
    assign m_axi_bready_A  = (w_state == WRITE_RESP)     && (w_sel == 2'd0) && s_axi_bready;

    assign m_axi_awaddr_B  = waddr;
    assign m_axi_awvalid_B = (w_state == WRITE_REQ_ADDR) &&  (w_sel == 2'd1);
    assign m_axi_wdata_B   = wdata;
    assign m_axi_wstrb_B   = wstrb;
    assign m_axi_wvalid_B  = (w_state == WRITE_REQ_DATA) &&  (w_sel == 2'd1);
    assign m_axi_bready_B  = (w_state == WRITE_RESP)     &&  (w_sel == 2'd1) && s_axi_bready;

    assign m_axi_awaddr_C  = waddr;
    assign m_axi_awvalid_C = (w_state == WRITE_REQ_ADDR) &&  (w_sel == 2'd2);
    assign m_axi_wdata_C   = wdata;
    assign m_axi_wstrb_C   = wstrb;
    assign m_axi_wvalid_C  = (w_state == WRITE_REQ_DATA) &&  (w_sel == 2'd2);
    assign m_axi_bready_C  = (w_state == WRITE_RESP)     &&  (w_sel == 2'd2) && s_axi_bready;

    assign s_axi_bresp  = (w_state == WRITE_RESP) ? (w_sel == 2'd0 ? m_axi_bresp_A : (w_sel == 2'd1 ? m_axi_bresp_B : m_axi_bresp_C))  : 2'b0;
    assign s_axi_bvalid = (w_state == WRITE_RESP) ? (w_sel == 2'd0 ? m_axi_bvalid_A : (w_sel == 2'd1 ? m_axi_bvalid_B : m_axi_bvalid_C)) : 1'b0;
endmodule
