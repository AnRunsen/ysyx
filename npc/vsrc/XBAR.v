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

    /*read channel*/
    localparam READ_IDLE = 3'b000, READ_REQ_A = 3'b001, READ_REQ_B = 3'b010, READ_WAIT_A = 3'b011, READ_WAIT_B = 3'b100;
    reg [2:0] r_state, r_next_state;

    always @(*) begin
        case(r_state)
            READ_IDLE: begin
                if(s_axi_arvalid && s_axi_arready) begin
                    if(s_axi_araddr == 32'h1000_0000) begin
                        r_next_state = READ_REQ_A;
                    end
                    else begin
                        r_next_state = READ_REQ_B;
                    end
                end
                
                else begin
                    r_next_state = r_state;
                end
            end

            READ_REQ_A: begin
                if(m_axi_arvalid_A && m_axi_arready_A) begin
                    r_next_state = READ_WAIT_A;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            READ_REQ_B: begin
                if(m_axi_arvalid_B && m_axi_arready_B) begin
                    r_next_state = READ_WAIT_B;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            READ_WAIT_A: begin
                if(s_axi_rvalid && s_axi_rready) begin
                    r_next_state = READ_IDLE;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            READ_WAIT_B: begin
                if(s_axi_rvalid && s_axi_rready) begin
                    r_next_state = READ_IDLE;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            default: r_next_state = READ_IDLE;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            r_state <= READ_IDLE;
        end
        else begin
            r_state <= r_next_state;
        end
    end

    /*logic to recv data*/
    assign s_axi_arready = (r_state == READ_IDLE);
    reg [31:0] raddr;
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            raddr <= 32'b0;
        end
        else if(s_axi_arvalid && s_axi_arready) begin
            raddr <= s_axi_araddr;
        end
    end

    assign m_axi_araddr_A = raddr;
    assign m_axi_arvalid_A = (r_state == READ_REQ_A);
    assign m_axi_araddr_B = raddr;
    assign m_axi_arvalid_B = (r_state == READ_REQ_B);

    assign s_axi_rdata = (r_state == READ_WAIT_A) ? m_axi_rdata_A : (r_state == READ_WAIT_B) ? m_axi_rdata_B : 32'b0;
    assign s_axi_rresp = (r_state == READ_WAIT_A) ? m_axi_rresp_A : (r_state == READ_WAIT_B) ? m_axi_rresp_B : 2'b0;
    assign s_axi_rvalid = (r_state == READ_WAIT_A) ? m_axi_rvalid_A : (r_state == READ_WAIT_B) ? m_axi_rvalid_B : 1'b0;
    assign m_axi_rready_A = (r_state == READ_WAIT_A) && s_axi_rready;
    assign m_axi_rready_B = (r_state == READ_WAIT_B) && s_axi_rready;


    /*write channel*/
    reg [31:0] waddr;
    reg [3:0] wstrb;
    reg [31:0] wdata;

    localparam WRITE_IDLE = 4'b0000, WRITE_WAIT_ADDR = 4'b0001, WRITE_WAIT_DATA = 4'b0010, 
    WRITE_REQ_ADDR_A = 4'b0011, WRITE_REQ_DATA_A = 4'b0100, WRITE_REQ_ADDR_B = 4'b0101, 
    WRITE_REQ_DATA_B = 4'b0110, WRITE_RESP_A = 4'b0111, WRITE_RESP_B = 4'b1000;
    reg [3:0] w_state, w_next_state;

    always @(*) begin
        case(w_state)
            WRITE_IDLE: begin
                if(s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                    if(s_axi_awaddr == 32'h1000_0000) begin
                        w_next_state = WRITE_REQ_ADDR_A;
                    end
                    else begin
                        w_next_state = WRITE_REQ_ADDR_B;
                    end
                end

                else if(s_axi_awvalid && s_axi_awready) begin
                    w_next_state = WRITE_WAIT_DATA;
                end

                else if(s_axi_wvalid && s_axi_wready) begin
                    w_next_state = WRITE_WAIT_ADDR;
                end

                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_WAIT_DATA: begin
                if(s_axi_wvalid && s_axi_wready) begin
                    if(waddr == 32'h1000_0000) begin
                        w_next_state = WRITE_REQ_ADDR_A;
                    end
                    else begin
                        w_next_state = WRITE_REQ_ADDR_B;
                    end
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_WAIT_ADDR: begin
                if(s_axi_awvalid && s_axi_awready) begin
                    if(s_axi_awaddr == 32'h1000_0000) begin
                        w_next_state = WRITE_REQ_ADDR_A;
                    end
                    else begin
                        w_next_state = WRITE_REQ_ADDR_B;
                    end
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_REQ_ADDR_A: begin
                if(m_axi_awvalid_A && m_axi_awready_A) begin
                    w_next_state = WRITE_REQ_DATA_A;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_REQ_DATA_A: begin
                if(m_axi_wvalid_A && m_axi_wready_A) begin
                    w_next_state = WRITE_RESP_A;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_REQ_ADDR_B: begin
                if(m_axi_awvalid_B && m_axi_awready_B) begin
                    w_next_state = WRITE_REQ_DATA_B;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_REQ_DATA_B: begin
                if(m_axi_wvalid_B && m_axi_wready_B) begin
                    w_next_state = WRITE_RESP_B;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_RESP_A: begin
                if(s_axi_bvalid && s_axi_bready) begin
                    w_next_state = WRITE_IDLE;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            WRITE_RESP_B: begin
                if(s_axi_bvalid && s_axi_bready) begin
                    w_next_state = WRITE_IDLE;
                end
                else begin
                    w_next_state = w_state;
                end
            end

            default: w_next_state = WRITE_IDLE;
        endcase
    end
    
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            w_state <= WRITE_IDLE;
        end
        else begin
            w_state <= w_next_state;
        end
    end

    /*logic to recv data*/
    assign s_axi_awready = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_ADDR);
    assign s_axi_wready = (w_state == WRITE_IDLE || w_state == WRITE_WAIT_DATA);
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            waddr <= 32'b0;
        end
        else if(s_axi_awvalid && s_axi_awready) begin
            waddr <= s_axi_awaddr;
        end
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            wstrb <= 4'b0;
            wdata <= 32'b0;
        end
        else if(s_axi_wvalid && s_axi_wready) begin
            wstrb <= s_axi_wstrb;
            wdata <= s_axi_wdata;
        end
    end

    assign s_axi_bresp = (w_state == WRITE_RESP_A) ? m_axi_bresp_A : (w_state == WRITE_RESP_B) ? m_axi_bresp_B : 2'b0;
    assign s_axi_bvalid = (w_state == WRITE_RESP_A) ? m_axi_bvalid_A : (w_state == WRITE_RESP_B) ? m_axi_bvalid_B : 1'b0;
    
    assign m_axi_awaddr_A = waddr;
    assign m_axi_awvalid_A = (w_state == WRITE_REQ_ADDR_A);

    assign m_axi_wdata_A = wdata;
    assign m_axi_wstrb_A = wstrb;
    assign m_axi_wvalid_A = (w_state == WRITE_REQ_DATA_A);

    assign m_axi_awaddr_B = waddr;
    assign m_axi_awvalid_B = (w_state == WRITE_REQ_ADDR_B);

    assign m_axi_wdata_B = wdata;
    assign m_axi_wstrb_B = wstrb;
    assign m_axi_wvalid_B = (w_state == WRITE_REQ_DATA_B);

    assign m_axi_bready_A = (w_state == WRITE_RESP_A) && s_axi_bready;
    assign m_axi_bready_B = (w_state == WRITE_RESP_B) && s_axi_bready;
endmodule
