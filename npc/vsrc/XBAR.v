module XBAR(
    /*axi lite port*/
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

    /*switch to A port if the addr=0x1000_0000*/
    wire sel_A = (s_axi_araddr[31:28] == 4'h1) || (s_axi_awaddr[31:28] == 4'h1);
    wire sel_B = !sel_A;

    /*the slave port output*/
    assign s_axi_arready = sel_A ? m_axi_arready_A : m_axi_arready_B;
    assign s_axi_rdata   = sel_A ? m_axi_rdata_A   : m_axi_rdata_B;
    assign s_axi_rresp   = sel_A ? m_axi_rresp_A   : m_axi_rresp_B;
    assign s_axi_rvalid  = sel_A ? m_axi_rvalid_A  : m_axi_rvalid_B;
    assign s_axi_awready = sel_A ? m_axi_awready_A : m_axi_awready_B;
    assign s_axi_wready  = sel_A ? m_axi_wready_A  : m_axi_wready_B;
    assign s_axi_bresp   = sel_A ? m_axi_bresp_A   : m_axi_bresp_B;
    assign s_axi_bvalid  = sel_A ? m_axi_bvalid_A  : m_axi_bvalid_B;


    /*the master port A output*/
    assign m_axi_araddr_A = s_axi_araddr;
    assign m_axi_awaddr_A = s_axi_awaddr;
    assign m_axi_wdata_A = s_axi_wdata;
    assign m_axi_wstrb_A = s_axi_wstrb;
    assign m_axi_awvalid_A = s_axi_awvalid && sel_A;
    assign m_axi_arvalid_A = s_axi_arvalid && sel_A;
    assign m_axi_wvalid_A = s_axi_wvalid && sel_A;
    assign m_axi_bready_A = s_axi_bready && sel_A;
    assign m_axi_rready_A = s_axi_rready && sel_A;

    /*the master port B output*/
    assign m_axi_awaddr_B = s_axi_awaddr;
    assign m_axi_araddr_B = s_axi_araddr;
    assign m_axi_wdata_B = s_axi_wdata;
    assign m_axi_wstrb_B = s_axi_wstrb;
    assign m_axi_awvalid_B = s_axi_awvalid && sel_B;
    assign m_axi_arvalid_B = s_axi_arvalid && sel_B;
    assign m_axi_wvalid_B = s_axi_wvalid && sel_B;
    assign m_axi_bready_B = s_axi_bready && sel_B;
    assign m_axi_rready_B = s_axi_rready && sel_B;



endmodule
