module ysyx_26040125(
        input  clock,
        input  reset,

        input io_interrupt,

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
    wire [1:0]  IDU_m_brju;
    wire        IDU_m_mem_signext;
    wire [11:0] IDU_m_csr_addr;
    wire [11:0] IDU_csr_addr;
    wire [31:0] IDU_m_csr_data;
    wire        IDU_m_csr_wr_sel;
    wire        IDU_m_csr_wen;
    wire        IDU_m_ecall;
    wire        IDU_m_mret;
    wire [31:0] IDU_m_PC;
    wire        IDU_m_valid;
    wire        IDU_m_fencei;
    wire [4:0]  IDU_rs1;
    wire [4:0]  IDU_rs2;

    // EXU outputs
    wire        EXU_s_ready;
    wire [4:0]  EXU_m_rd;
    wire        EXU_m_wb_en;
    wire        EXU_m_mem_en;
    wire        EXU_m_mem_write_en;
    wire [1:0]  EXU_m_op_width;
    wire [2:0]  EXU_m_wb_sel;
    wire [1:0]  EXU_m_brju;
    wire        EXU_m_mem_signext;
    wire [11:0] EXU_m_csr_addr;
    wire [31:0] EXU_m_csr_data;
    wire        EXU_m_csr_wr_sel;
    wire        EXU_m_csr_wen;
    wire        EXU_m_ecall;
    wire        EXU_m_mret;
    wire [31:0] EXU_m_srcR1;
    wire [31:0] EXU_m_srcR2;
    wire [31:0] EXU_m_result;
    wire [31:0] EXU_m_PC;
    wire [31:0] EXU_m_imm;
    wire        EXU_m_valid;
    wire        EXU_m_fencei;

    // LSU outputs
    wire        LSU_s_ready;
    wire [4:0]  LSU_m_rd;
    wire        LSU_m_wb_en;
    wire [2:0]  LSU_m_wb_sel;
    wire [1:0]  LSU_m_brju;
    wire [11:0] LSU_m_csr_addr;
    wire [31:0] LSU_m_csr_data;
    wire        LSU_m_csr_wr_sel;
    wire        LSU_m_csr_wen;
    wire        LSU_m_ecall;
    wire        LSU_m_mret;
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
    wire        LSU_cache_flush;

    // WBU outputs
    wire        WBU_s_ready;
    wire        WBU_wen;
    wire [31:0] WBU_wdata;
    wire [4:0]  WBU_waddr;
    wire [11:0] WBU_csr_addr_;
    wire [31:0] WBU_csr_srcR1_;
    wire [31:0] WBU_csr_alu_res_;
    wire        WBU_csr_wr_sel_;
    wire        WBU_csr_wen_;
    wire        WBU_csr_ecall_;
    wire [31:0] WBU_csr_epc_;
    wire [31:0] WBU_csr_cause_;
    wire [31:0] WBU_pcr_exu_result;
    wire [31:0] WBU_pcr_imm;
    wire        WBU_pcr_ecall;
    wire        WBU_pcr_mret;
    wire [31:0] WBU_pcr_mtvec;
    wire [31:0] WBU_pcr_mepc;
    wire [1:0]  WBU_pcr_behavior;
    wire        WBU_pcr_pc_en;
    wire        WBU_next_inst;

    // CSR outputs
    wire [31:0] CSR_rdata;

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

    //ICACHE outputs
    wire        	ICACHE_s_axi_arready;
    wire [3:0]  	ICACHE_s_axi_rid;
    wire [31:0] 	ICACHE_s_axi_rdata;
    wire [1:0]  	ICACHE_s_axi_rresp;
    wire        	ICACHE_s_axi_rlast;
    wire        	ICACHE_s_axi_rvalid;
    wire        	ICACHE_s_axi_awready;
    wire        	ICACHE_s_axi_wready;
    wire [3:0]  	ICACHE_s_axi_bid;
    wire [1:0]  	ICACHE_s_axi_bresp;
    wire        	ICACHE_s_axi_bvalid;
    wire [31:0] 	ICACHE_m_axi_araddr;
    wire        	ICACHE_m_axi_arvalid;
    wire [3:0]  	ICACHE_m_axi_arid;
    wire [7:0]  	ICACHE_m_axi_arlen;
    wire [2:0]  	ICACHE_m_axi_arsize;
    wire [1:0]  	ICACHE_m_axi_arburst;
    wire        	ICACHE_m_axi_rready;
    wire [31:0] 	ICACHE_m_axi_awaddr;
    wire        	ICACHE_m_axi_awvalid;
    wire [3:0]  	ICACHE_m_axi_awid;
    wire [7:0]  	ICACHE_m_axi_awlen;
    wire [2:0]  	ICACHE_m_axi_awsize;
    wire [1:0]  	ICACHE_m_axi_awburst;
    wire [31:0] 	ICACHE_m_axi_wdata;
    wire [3:0]  	ICACHE_m_axi_wstrb;
    wire        	ICACHE_m_axi_wvalid;
    wire        	ICACHE_m_axi_wlast;
    wire        	ICACHE_m_axi_bready;

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


    PCR ysyx_26040125_PCR(
            .clk         (clock),
            .reset       (reset),
            .exu_result  (WBU_pcr_exu_result),
            .imm         (WBU_pcr_imm),
            .ecall       (WBU_pcr_ecall),
            .mret        (WBU_pcr_mret),
            .mtvec       (WBU_pcr_mtvec),
            .mepc        (WBU_pcr_mepc),
            .behavior    (WBU_pcr_behavior),
            .pc_en       (WBU_pcr_pc_en),
            .PC          (PCR_PC)
        );

    IFU ysyx_26040125_IFU(
            .clk            (clock),
            .reset          (reset),
            .next_inst      (WBU_next_inst),
            .m_Inst         (IFU_m_Inst),
            .m_PC           (IFU_m_PC),
            .m_valid        (IFU_m_valid),
            .m_ready        (IDU_s_ready),
            .PC             (PCR_PC),
            .m_axi_araddr   (IFU_m_axi_araddr),
            .m_axi_arvalid  (IFU_m_axi_arvalid),
            .m_axi_arready  (ICACHE_s_axi_arready),
            .m_axi_arid     (IFU_m_axi_arid),
            .m_axi_arlen    (IFU_m_axi_arlen),
            .m_axi_arsize   (IFU_m_axi_arsize),
            .m_axi_arburst  (IFU_m_axi_arburst),
            .m_axi_rdata    (ICACHE_s_axi_rdata),
            .m_axi_rresp    (ICACHE_s_axi_rresp),
            .m_axi_rid      (ICACHE_s_axi_rid),
            .m_axi_rlast    (ICACHE_s_axi_rlast),
            .m_axi_rvalid   (ICACHE_s_axi_rvalid),
            .m_axi_rready   (IFU_m_axi_rready),
            .m_axi_awaddr   (IFU_m_axi_awaddr),
            .m_axi_awvalid  (IFU_m_axi_awvalid),
            .m_axi_awready  (ICACHE_s_axi_awready),
            .m_axi_awid     (IFU_m_axi_awid),
            .m_axi_awlen    (IFU_m_axi_awlen),
            .m_axi_awsize   (IFU_m_axi_awsize),
            .m_axi_awburst  (IFU_m_axi_awburst),
            .m_axi_wdata    (IFU_m_axi_wdata),
            .m_axi_wstrb    (IFU_m_axi_wstrb),
            .m_axi_wvalid   (IFU_m_axi_wvalid),
            .m_axi_wlast    (IFU_m_axi_wlast),
            .m_axi_wready   (ICACHE_s_axi_wready),
            .m_axi_bresp    (ICACHE_s_axi_bresp),
            .m_axi_bvalid   (ICACHE_s_axi_bvalid),
            .m_axi_bid      (ICACHE_s_axi_bid),
            .m_axi_bready   (IFU_m_axi_bready)
        );

    GPR ysyx_26040125_GPR(
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

    IDU ysyx_26040125_IDU(
            .clk            (clock),
            .reset          (reset),
            .s_Inst         (IFU_m_Inst),
            .s_PC           (IFU_m_PC),
            .s_valid        (IFU_m_valid),
            .s_ready        (IDU_s_ready),
            .m_rd           (IDU_m_rd),
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
            .m_ecall        (IDU_m_ecall),
            .m_mret         (IDU_m_mret),
            .m_PC           (IDU_m_PC),
            .m_fencei       (IDU_m_fencei),
            .m_valid        (IDU_m_valid),
            .m_ready        (EXU_s_ready),
            .rs1            (IDU_rs1),
            .rs2            (IDU_rs2),
            .srcR1_in       (GPR_rdata1),
            .srcR2_in       (GPR_rdata2),
            .csr_data       (CSR_rdata),
            .csr_addr       (IDU_csr_addr)
        );

    EXU ysyx_26040125_EXU(
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
            .s_ecall        (IDU_m_ecall),
            .s_mret         (IDU_m_mret),
            .s_PC           (IDU_m_PC),
            .s_fencei       (IDU_m_fencei),
            .s_valid        (IDU_m_valid),
            .s_ready        (EXU_s_ready),
            .m_rd           (EXU_m_rd),
            .m_wb_en        (EXU_m_wb_en),
            .m_mem_en       (EXU_m_mem_en),
            .m_mem_write_en (EXU_m_mem_write_en),
            .m_op_width     (EXU_m_op_width),
            .m_wb_sel       (EXU_m_wb_sel),
            .m_brju         (EXU_m_brju),
            .m_mem_signext  (EXU_m_mem_signext),
            .m_csr_addr     (EXU_m_csr_addr),
            .m_csr_data     (EXU_m_csr_data),
            .m_csr_wr_sel   (EXU_m_csr_wr_sel),
            .m_csr_wen      (EXU_m_csr_wen),
            .m_ecall        (EXU_m_ecall),
            .m_mret         (EXU_m_mret),
            .m_srcR1        (EXU_m_srcR1),
            .m_srcR2        (EXU_m_srcR2),
            .m_result       (EXU_m_result),
            .m_PC           (EXU_m_PC),
            .m_imm          (EXU_m_imm),
            .m_valid        (EXU_m_valid),
            .m_ready        (LSU_s_ready),
            .m_fencei       (EXU_m_fencei)
        );

    LSU ysyx_26040125_LSU(
            .clk            (clock),
            .reset          (reset),
            .s_rd           (EXU_m_rd),
            .s_wb_en        (EXU_m_wb_en),
            .s_mem_en       (EXU_m_mem_en),
            .s_mem_write_en (EXU_m_mem_write_en),
            .s_op_width     (EXU_m_op_width),
            .s_wb_sel       (EXU_m_wb_sel),
            .s_brju         (EXU_m_brju),
            .s_mem_signext  (EXU_m_mem_signext),
            .s_csr_addr     (EXU_m_csr_addr),
            .s_csr_data     (EXU_m_csr_data),
            .s_csr_wr_sel   (EXU_m_csr_wr_sel),
            .s_csr_wen      (EXU_m_csr_wen),
            .s_ecall        (EXU_m_ecall),
            .s_mret         (EXU_m_mret),
            .s_srcR1        (EXU_m_srcR1),
            .s_srcR2        (EXU_m_srcR2),
            .s_result       (EXU_m_result),
            .s_PC           (EXU_m_PC),
            .s_imm          (EXU_m_imm),
            .s_fencei       (EXU_m_fencei),
            .s_valid        (EXU_m_valid),
            .s_ready        (LSU_s_ready),
            .m_rd           (LSU_m_rd),
            .m_wb_en        (LSU_m_wb_en),
            .m_wb_sel       (LSU_m_wb_sel),
            .m_brju         (LSU_m_brju),
            .m_csr_addr     (LSU_m_csr_addr),
            .m_csr_data     (LSU_m_csr_data),
            .m_csr_wr_sel   (LSU_m_csr_wr_sel),
            .m_csr_wen      (LSU_m_csr_wen),
            .m_ecall        (LSU_m_ecall),
            .m_mret         (LSU_m_mret),
            .m_srcR1        (LSU_m_srcR1),
            .m_result       (LSU_m_result),
            .m_rdata        (LSU_m_rdata),
            .m_PC           (LSU_m_PC),
            .m_imm          (LSU_m_imm),
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
            .cache_flush    (LSU_cache_flush)
        );

    WBU ysyx_26040125_WBU(
            .clk            (clock),
            .reset          (reset),
            .s_rd           (LSU_m_rd),
            .s_wb_en        (LSU_m_wb_en),
            .s_wb_sel       (LSU_m_wb_sel),
            .s_brju         (LSU_m_brju),
            .s_csr_addr     (LSU_m_csr_addr),
            .s_csr_data     (LSU_m_csr_data),
            .s_csr_wr_sel   (LSU_m_csr_wr_sel),
            .s_csr_wen      (LSU_m_csr_wen),
            .s_ecall        (LSU_m_ecall),
            .s_mret         (LSU_m_mret),
            .s_srcR1        (LSU_m_srcR1),
            .s_result       (LSU_m_result),
            .s_rdata        (LSU_m_rdata),
            .s_PC           (LSU_m_PC),
            .s_imm          (LSU_m_imm),
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
            .csr_ecall_     (WBU_csr_ecall_),
            .csr_epc_       (WBU_csr_epc_),
            .csr_cause_     (WBU_csr_cause_),
            .pcr_exu_result (WBU_pcr_exu_result),
            .pcr_imm        (WBU_pcr_imm),
            .pcr_ecall      (WBU_pcr_ecall),
            .pcr_mret       (WBU_pcr_mret),
            .pcr_mtvec      (WBU_pcr_mtvec),
            .pcr_mepc       (WBU_pcr_mepc),
            .pcr_behavior   (WBU_pcr_behavior),
            .pcr_pc_en      (WBU_pcr_pc_en),
            .next_inst      (WBU_next_inst)
        );

    CSR ysyx_26040125_CSR(
            .clk     (clock),
            .reset   (reset),
            .waddr    (WBU_csr_addr_),
            .raddr    (IDU_csr_addr),
            .srcR1   (WBU_csr_srcR1_),
            .alu_res (WBU_csr_alu_res_),
            .wr_sel  (WBU_csr_wr_sel_),
            .wen     (WBU_csr_wen_),
            .ecall   (WBU_csr_ecall_),
            .w_epc   (WBU_csr_epc_),
            .w_cause (WBU_csr_cause_),
            .rdata   (CSR_rdata)
        );



    ICACHE #(
        .LINE_NUM  	( 16  ),
        .LINE_SIZE 	( 16  ))
    ysyx_26040125_ICACHE(
        .clk           	( clock          ),
        .reset         	( reset          ),

        .cache_flush    ( LSU_cache_flush ),

        .s_axi_arid    	( IFU_m_axi_arid     ),
        .s_axi_araddr  	( IFU_m_axi_araddr   ),
        .s_axi_arlen   	( IFU_m_axi_arlen    ),
        .s_axi_arsize  	( IFU_m_axi_arsize   ),
        .s_axi_arburst 	( IFU_m_axi_arburst  ),
        .s_axi_arvalid 	( IFU_m_axi_arvalid  ),
        .s_axi_arready 	( ICACHE_s_axi_arready  ),
        .s_axi_rid     	( ICACHE_s_axi_rid      ),
        .s_axi_rdata   	( ICACHE_s_axi_rdata    ),
        .s_axi_rresp   	( ICACHE_s_axi_rresp    ),
        .s_axi_rlast   	( ICACHE_s_axi_rlast    ),
        .s_axi_rvalid  	( ICACHE_s_axi_rvalid   ),
        .s_axi_rready  	( IFU_m_axi_rready     ),
        .s_axi_awid    	( IFU_m_axi_awid       ),
        .s_axi_awaddr  	( IFU_m_axi_awaddr     ),
        .s_axi_awlen   	( IFU_m_axi_awlen      ),
        .s_axi_awsize  	( IFU_m_axi_awsize     ),
        .s_axi_awburst 	( IFU_m_axi_awburst    ),
        .s_axi_awvalid 	( IFU_m_axi_awvalid    ),
        .s_axi_awready 	( ICACHE_s_axi_awready  ),
        .s_axi_wdata   	( IFU_m_axi_wdata      ),
        .s_axi_wstrb   	( IFU_m_axi_wstrb      ),
        .s_axi_wlast   	( IFU_m_axi_wlast      ),
        .s_axi_wvalid  	( IFU_m_axi_wvalid     ),
        .s_axi_wready  	( ICACHE_s_axi_wready   ),
        .s_axi_bid     	( ICACHE_s_axi_bid      ),
        .s_axi_bresp   	( ICACHE_s_axi_bresp    ),
        .s_axi_bvalid  	( ICACHE_s_axi_bvalid   ),
        .s_axi_bready  	( IFU_m_axi_bready   ),
        .m_axi_araddr  	( ICACHE_m_axi_araddr   ),
        .m_axi_arvalid 	( ICACHE_m_axi_arvalid  ),
        .m_axi_arready 	( ARB_s_axi_arready_A  ),
        .m_axi_arid    	( ICACHE_m_axi_arid     ),
        .m_axi_arlen   	( ICACHE_m_axi_arlen    ),
        .m_axi_arsize  	( ICACHE_m_axi_arsize   ),
        .m_axi_arburst 	( ICACHE_m_axi_arburst  ),
        .m_axi_rdata   	( ARB_s_axi_rdata_A    ),
        .m_axi_rresp   	( ARB_s_axi_rresp_A    ),
        .m_axi_rid     	( ARB_s_axi_rid_A      ),
        .m_axi_rlast   	( ARB_s_axi_rlast_A    ),
        .m_axi_rvalid  	( ARB_s_axi_rvalid_A   ),
        .m_axi_rready  	( ICACHE_m_axi_rready   ),
        .m_axi_awaddr  	( ICACHE_m_axi_awaddr   ),
        .m_axi_awvalid 	( ICACHE_m_axi_awvalid  ),
        .m_axi_awready 	( ARB_s_axi_awready_A  ),
        .m_axi_awid    	( ICACHE_m_axi_awid     ),
        .m_axi_awlen   	( ICACHE_m_axi_awlen    ),
        .m_axi_awsize  	( ICACHE_m_axi_awsize   ),
        .m_axi_awburst 	( ICACHE_m_axi_awburst  ),
        .m_axi_wdata   	( ICACHE_m_axi_wdata    ),
        .m_axi_wstrb   	( ICACHE_m_axi_wstrb    ),
        .m_axi_wvalid  	( ICACHE_m_axi_wvalid   ),
        .m_axi_wlast   	( ICACHE_m_axi_wlast    ),
        .m_axi_wready  	( ARB_s_axi_wready_A    ),
        .m_axi_bresp   	( ARB_s_axi_bresp_A     ),
        .m_axi_bvalid  	( ARB_s_axi_bvalid_A    ),
        .m_axi_bid     	( ARB_s_axi_bid_A       ),
        .m_axi_bready  	( ICACHE_m_axi_bready   )
    );


    ARB ysyx_26040125_ARB(
            .clk               ( clock                ),
            .reset             ( reset                ),
            .s_axi_araddr_A    ( ICACHE_m_axi_araddr     ),
            .s_axi_arvalid_A   ( ICACHE_m_axi_arvalid    ),
            .s_axi_arready_A   ( ARB_s_axi_arready_A  ),
            .s_axi_arid_A      ( ICACHE_m_axi_arid       ),
            .s_axi_arlen_A     ( ICACHE_m_axi_arlen      ),
            .s_axi_arsize_A    ( ICACHE_m_axi_arsize     ),
            .s_axi_arburst_A   ( ICACHE_m_axi_arburst    ),
            .s_axi_rdata_A     ( ARB_s_axi_rdata_A    ),
            .s_axi_rresp_A     ( ARB_s_axi_rresp_A    ),
            .s_axi_rvalid_A    ( ARB_s_axi_rvalid_A   ),
            .s_axi_rready_A    ( ICACHE_m_axi_rready     ),
            .s_axi_rid_A       ( ARB_s_axi_rid_A      ),
            .s_axi_rlast_A     ( ARB_s_axi_rlast_A    ),
            .s_axi_awaddr_A    ( ICACHE_m_axi_awaddr     ),
            .s_axi_awvalid_A   ( ICACHE_m_axi_awvalid    ),
            .s_axi_awready_A   ( ARB_s_axi_awready_A  ),
            .s_axi_awid_A      ( ICACHE_m_axi_awid       ),
            .s_axi_awlen_A     ( ICACHE_m_axi_awlen      ),
            .s_axi_awsize_A    ( ICACHE_m_axi_awsize     ),
            .s_axi_awburst_A   ( ICACHE_m_axi_awburst    ),
            .s_axi_wdata_A     ( ICACHE_m_axi_wdata      ),
            .s_axi_wstrb_A     ( ICACHE_m_axi_wstrb      ),
            .s_axi_wvalid_A    ( ICACHE_m_axi_wvalid     ),
            .s_axi_wready_A    ( ARB_s_axi_wready_A   ),
            .s_axi_wlast_A     ( ICACHE_m_axi_wlast      ),
            .s_axi_bresp_A     ( ARB_s_axi_bresp_A    ),
            .s_axi_bvalid_A    ( ARB_s_axi_bvalid_A   ),
            .s_axi_bready_A    ( ICACHE_m_axi_bready     ),
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

    XBAR ysyx_26040125_XBAR(
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

    MTIME ysyx_26040125_MTIME(
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

endmodule
