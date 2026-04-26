module ARB(
    input clk,
    input arstn,

    /*axi lite port A*/
    input [31:0] s_axi_araddr_A,
    input s_axi_arvalid_A,
    output s_axi_arready_A,

    output [31:0] s_axi_rdata_A,
    output [1:0] s_axi_rresp_A,
    output s_axi_rvalid_A,
    input s_axi_rready_A,


    input [31:0] s_axi_awaddr_A,
    input s_axi_awvalid_A,
    output s_axi_awready_A,

    input [31:0] s_axi_wdata_A,
    input [3:0] s_axi_wstrb_A,
    input s_axi_wvalid_A,
    output s_axi_wready_A,

    output [1:0] s_axi_bresp_A,
    output s_axi_bvalid_A,
    input s_axi_bready_A,

    /*axi lite port B*/
    input [31:0] s_axi_araddr_B,
    input s_axi_arvalid_B,
    output s_axi_arready_B,

    output [31:0] s_axi_rdata_B,
    output [1:0] s_axi_rresp_B,
    output s_axi_rvalid_B,
    input s_axi_rready_B,


    input [31:0] s_axi_awaddr_B,
    input s_axi_awvalid_B,
    output s_axi_awready_B,

    input [31:0] s_axi_wdata_B,
    input [3:0] s_axi_wstrb_B,
    input s_axi_wvalid_B,
    output s_axi_wready_B,

    output [1:0] s_axi_bresp_B,
    output s_axi_bvalid_B,
    input s_axi_bready_B,

    /*axi lite output*/
    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    input m_axi_rvalid,
    output m_axi_rready,


    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
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
                if(s_axi_rvalid_A && s_axi_rready_A) begin
                    r_next_state = R_POLLINGB;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            R_WORKINGB: begin
                if(s_axi_rvalid_B && s_axi_rready_B) begin
                    r_next_state = R_POLLINGA;
                end
                else begin
                    r_next_state = r_state;
                end
            end

            default: r_next_state = R_POLLINGA;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
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

    /*read data channel*/
    assign s_axi_rdata_A = m_axi_rdata;
    assign s_axi_rresp_A = m_axi_rresp;
    assign s_axi_rvalid_A = (r_state == R_WORKINGA) && m_axi_rvalid;
    assign s_axi_rdata_B = m_axi_rdata;
    assign s_axi_rresp_B = m_axi_rresp;
    assign s_axi_rvalid_B = (r_state == R_WORKINGB) && m_axi_rvalid;
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

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
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

    /*write data channel*/
    assign s_axi_wready_A = (w_state == W_POLLINGA || w_state == W_WORKINGA) && m_axi_wready;
    assign s_axi_wready_B = (w_state == W_POLLINGB || w_state == W_WORKINGB) && m_axi_wready;
    assign m_axi_wdata = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wdata_A : s_axi_wdata_B;
    assign m_axi_wstrb = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wstrb_A : s_axi_wstrb_B;
    assign m_axi_wvalid = (w_state == W_POLLINGA || w_state == W_WORKINGA) ? s_axi_wvalid_A : s_axi_wvalid_B;

    /*write response channel*/
    assign s_axi_bresp_A = m_axi_bresp;
    assign s_axi_bresp_B = m_axi_bresp;
    assign s_axi_bvalid_A = (w_state == W_WORKINGA) && m_axi_bvalid;
    assign s_axi_bvalid_B = (w_state == W_WORKINGB) && m_axi_bvalid;
    assign m_axi_bready = (w_state == W_WORKINGA) ? s_axi_bready_A : s_axi_bready_B;

endmodule
