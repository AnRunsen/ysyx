module XBAR(
    /*axi lite port*/
    input clk,
    input arstn,

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
    output m_axi_bready_B
);

    function addr_sel;
        input [31:0] addr;
        begin
            addr_sel = (addr == 32'h1000_0000) ? 1'b0 : 1'b1;
        end
    endfunction

    /*read channel*/
    localparam READ_IDLE = 2'b00, READ_REQ = 2'b01, READ_WAIT = 2'b10;
    reg [1:0] r_state, r_next_state;
    reg r_sel;

    always @(*) begin
        case (r_state)
            READ_IDLE: r_next_state = (s_axi_arvalid && s_axi_arready) ? READ_REQ  : READ_IDLE;
            READ_REQ:  r_next_state = (r_sel ? m_axi_arready_B : m_axi_arready_A)  ? READ_WAIT : READ_REQ;
            READ_WAIT: r_next_state = (s_axi_rvalid  && s_axi_rready)              ? READ_IDLE : READ_WAIT;
            default:   r_next_state = READ_IDLE;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if (!arstn) r_state <= READ_IDLE;
        else        r_state <= r_next_state;
    end

    assign s_axi_arready = (r_state == READ_IDLE);

    reg [31:0] raddr;
    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            raddr <= 32'b0;
            r_sel <= 1'b0;
        end else if (s_axi_arvalid && s_axi_arready) begin
            raddr <= s_axi_araddr;
            r_sel <= addr_sel(s_axi_araddr);
        end
    end

    assign m_axi_araddr_A  = raddr;
    assign m_axi_arvalid_A = (r_state == READ_REQ)  && (r_sel == 1'b0);
    assign m_axi_araddr_B  = raddr;
    assign m_axi_arvalid_B = (r_state == READ_REQ)  &&  (r_sel == 1'b1);

    assign m_axi_rready_A  = (r_state == READ_WAIT) && (r_sel == 1'b0) && s_axi_rready;
    assign m_axi_rready_B  = (r_state == READ_WAIT) &&  (r_sel == 1'b1) && s_axi_rready;

    assign s_axi_rdata  = (r_state == READ_WAIT) ? (r_sel ? m_axi_rdata_B  : m_axi_rdata_A)  : 32'b0;
    assign s_axi_rresp  = (r_state == READ_WAIT) ? (r_sel ? m_axi_rresp_B  : m_axi_rresp_A)  : 2'b0;
    assign s_axi_rvalid = (r_state == READ_WAIT) ? (r_sel ? m_axi_rvalid_B : m_axi_rvalid_A) : 1'b0;


    /*write channel*/
    localparam WRITE_IDLE      = 3'b000,
               WRITE_WAIT_ADDR = 3'b001,
               WRITE_WAIT_DATA = 3'b010,
               WRITE_REQ_ADDR  = 3'b011,
               WRITE_REQ_DATA  = 3'b100,
               WRITE_RESP      = 3'b101;
    reg [2:0] w_state, w_next_state;
    reg w_sel;

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
            WRITE_REQ_ADDR: w_next_state = (w_sel ? m_axi_awready_B : m_axi_awready_A) ? WRITE_REQ_DATA : WRITE_REQ_ADDR;
            WRITE_REQ_DATA: w_next_state = (w_sel ? m_axi_wready_B  : m_axi_wready_A) ? WRITE_RESP : WRITE_REQ_DATA;
            WRITE_RESP: w_next_state = (s_axi_bvalid  && s_axi_bready) ? WRITE_IDLE : WRITE_RESP;
            default: w_next_state = WRITE_IDLE;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if (!arstn) w_state <= WRITE_IDLE;
        else        w_state <= w_next_state;
    end

    assign s_axi_awready = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_ADDR);
    assign s_axi_wready  = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_DATA);

    reg [31:0] waddr;
    reg [31:0] wdata;
    reg [3:0]  wstrb;

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            waddr <= 32'b0;
            w_sel <= 1'b0;
        end
        else if (s_axi_awvalid && s_axi_awready) begin
            waddr <= s_axi_awaddr;
            w_sel <= addr_sel(s_axi_awaddr);
        end
    end

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            wdata <= 32'b0;
            wstrb <= 4'b0;
        end else if (s_axi_wvalid && s_axi_wready) begin
            wdata <= s_axi_wdata;
            wstrb <= s_axi_wstrb;
        end
    end

    assign m_axi_awaddr_A  = waddr;
    assign m_axi_awvalid_A = (w_state == WRITE_REQ_ADDR) && (w_sel == 1'b0);
    assign m_axi_wdata_A   = wdata;
    assign m_axi_wstrb_A   = wstrb;
    assign m_axi_wvalid_A  = (w_state == WRITE_REQ_DATA) && (w_sel == 1'b0);
    assign m_axi_bready_A  = (w_state == WRITE_RESP)     && (w_sel == 1'b0) && s_axi_bready;

    assign m_axi_awaddr_B  = waddr;
    assign m_axi_awvalid_B = (w_state == WRITE_REQ_ADDR) &&  (w_sel == 1'b1);
    assign m_axi_wdata_B   = wdata;
    assign m_axi_wstrb_B   = wstrb;
    assign m_axi_wvalid_B  = (w_state == WRITE_REQ_DATA) &&  (w_sel == 1'b1);
    assign m_axi_bready_B  = (w_state == WRITE_RESP)     &&  (w_sel == 1'b1) && s_axi_bready;

    assign s_axi_bresp  = (w_state == WRITE_RESP) ? (w_sel ? m_axi_bresp_B  : m_axi_bresp_A)  : 2'b0;
    assign s_axi_bvalid = (w_state == WRITE_RESP) ? (w_sel ? m_axi_bvalid_B : m_axi_bvalid_A) : 1'b0;
endmodule
