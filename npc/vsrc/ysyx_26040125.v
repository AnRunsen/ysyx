module ysyx_26040125(
        input clock,
        input reset
    );

    // PCR outputs
    wire [31:0] PCR_PC;

    // IFU outputs
    wire [31:0] IFU_m_Inst;
    wire [31:0] IFU_m_PC;
    wire        IFU_m_valid;
    wire [31:0] IFU_m_axi_araddr;
    wire        IFU_m_axi_arvalid;
    wire        IFU_m_axi_rready;
    wire [31:0] IFU_m_axi_awaddr;
    wire        IFU_m_axi_awvalid;
    wire [31:0] IFU_m_axi_wdata;
    wire [3:0]  IFU_m_axi_wstrb;
    wire        IFU_m_axi_wvalid;
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
    wire        LSU_m_axi_rready;
    wire [31:0] LSU_m_axi_awaddr;
    wire        LSU_m_axi_awvalid;
    wire [31:0] LSU_m_axi_wdata;
    wire [3:0]  LSU_m_axi_wstrb;
    wire        LSU_m_axi_wvalid;
    wire        LSU_m_axi_bready;

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

    // RAM outputs
    wire        RAM_s_axi_arready;
    wire [31:0] RAM_s_axi_rdata;
    wire [1:0]  RAM_s_axi_rresp;
    wire        RAM_s_axi_rvalid;
    wire        RAM_s_axi_awready;
    wire        RAM_s_axi_wready;
    wire [1:0]  RAM_s_axi_bresp;
    wire        RAM_s_axi_bvalid;

    // XBAR outputs (slave side, responses back to ARB)
    wire        XBAR_s_axi_arready;
    wire [31:0] XBAR_s_axi_rdata;
    wire [1:0]  XBAR_s_axi_rresp;
    wire        XBAR_s_axi_rvalid;
    wire        XBAR_s_axi_awready;
    wire        XBAR_s_axi_wready;
    wire [1:0]  XBAR_s_axi_bresp;
    wire        XBAR_s_axi_bvalid;
    // XBAR outputs (master A, to UART)
    wire [31:0] XBAR_m_axi_araddr_A;
    wire        XBAR_m_axi_arvalid_A;
    wire        XBAR_m_axi_rready_A;
    wire [31:0] XBAR_m_axi_awaddr_A;
    wire        XBAR_m_axi_awvalid_A;
    wire [31:0] XBAR_m_axi_wdata_A;
    wire [3:0]  XBAR_m_axi_wstrb_A;
    wire        XBAR_m_axi_wvalid_A;
    wire        XBAR_m_axi_bready_A;
    // XBAR outputs (master B, to RAM)
    wire [31:0] XBAR_m_axi_araddr_B;
    wire        XBAR_m_axi_arvalid_B;
    wire        XBAR_m_axi_rready_B;
    wire [31:0] XBAR_m_axi_awaddr_B;
    wire        XBAR_m_axi_awvalid_B;
    wire [31:0] XBAR_m_axi_wdata_B;
    wire [3:0]  XBAR_m_axi_wstrb_B;
    wire        XBAR_m_axi_wvalid_B;
    wire        XBAR_m_axi_bready_B;
    // XBAR outputs (master C, to MTIME)
    wire [31:0] XBAR_m_axi_araddr_C;
    wire        XBAR_m_axi_arvalid_C;
    wire        XBAR_m_axi_rready_C;
    wire [31:0] XBAR_m_axi_awaddr_C;
    wire        XBAR_m_axi_awvalid_C;
    wire [31:0] XBAR_m_axi_wdata_C;
    wire [3:0]  XBAR_m_axi_wstrb_C;
    wire        XBAR_m_axi_wvalid_C;
    wire        XBAR_m_axi_bready_C;

    // UART outputs
    wire        UART_s_axi_arready;
    wire [31:0] UART_s_axi_rdata;
    wire [1:0]  UART_s_axi_rresp;
    wire        UART_s_axi_rvalid;
    wire        UART_s_axi_awready;
    wire        UART_s_axi_wready;
    wire [1:0]  UART_s_axi_bresp;
    wire        UART_s_axi_bvalid;

    // ARB outputs
    wire        	ARB_s_axi_arready_A;
    wire [31:0] 	ARB_s_axi_rdata_A;
    wire [1:0]  	ARB_s_axi_rresp_A;
    wire        	ARB_s_axi_rvalid_A;
    wire        	ARB_s_axi_awready_A;
    wire        	ARB_s_axi_wready_A;
    wire [1:0]  	ARB_s_axi_bresp_A;
    wire        	ARB_s_axi_bvalid_A;
    wire        	ARB_s_axi_arready_B;
    wire [31:0] 	ARB_s_axi_rdata_B;
    wire [1:0]  	ARB_s_axi_rresp_B;
    wire        	ARB_s_axi_rvalid_B;
    wire        	ARB_s_axi_awready_B;
    wire        	ARB_s_axi_wready_B;
    wire [1:0]  	ARB_s_axi_bresp_B;
    wire        	ARB_s_axi_bvalid_B;
    wire [31:0] 	ARB_m_axi_araddr;
    wire        	ARB_m_axi_arvalid;
    wire        	ARB_m_axi_rready;
    wire [31:0] 	ARB_m_axi_awaddr;
    wire        	ARB_m_axi_awvalid;
    wire [31:0] 	ARB_m_axi_wdata;
    wire [3:0]  	ARB_m_axi_wstrb;
    wire        	ARB_m_axi_wvalid;
    wire        	ARB_m_axi_bready;

    wire        	MTIME_s_axi_arready;
    wire [31:0] 	MTIME_s_axi_rdata;
    wire [1:0]  	MTIME_s_axi_rresp;
    wire        	MTIME_s_axi_rvalid;
    wire        	MTIME_s_axi_awready;
    wire        	MTIME_s_axi_wready;
    wire [1:0]  	MTIME_s_axi_bresp;
    wire        	MTIME_s_axi_bvalid;


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
            .m_axi_arready  (ARB_s_axi_arready_A),
            .m_axi_rdata    (ARB_s_axi_rdata_A),
            .m_axi_rresp    (ARB_s_axi_rresp_A),
            .m_axi_rvalid   (ARB_s_axi_rvalid_A),
            .m_axi_rready   (IFU_m_axi_rready),
            .m_axi_awaddr   (IFU_m_axi_awaddr),
            .m_axi_awvalid  (IFU_m_axi_awvalid),
            .m_axi_awready  (ARB_s_axi_awready_A),
            .m_axi_wdata    (IFU_m_axi_wdata),
            .m_axi_wstrb    (IFU_m_axi_wstrb),
            .m_axi_wvalid   (IFU_m_axi_wvalid),
            .m_axi_wready   (ARB_s_axi_wready_A),
            .m_axi_bresp    (ARB_s_axi_bresp_A),
            .m_axi_bvalid   (ARB_s_axi_bvalid_A),
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
            .m_ready        (LSU_s_ready)
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
            .m_axi_rdata    (ARB_s_axi_rdata_B),
            .m_axi_rresp    (ARB_s_axi_rresp_B),
            .m_axi_rvalid   (ARB_s_axi_rvalid_B),
            .m_axi_rready   (LSU_m_axi_rready),
            .m_axi_awaddr   (LSU_m_axi_awaddr),
            .m_axi_awvalid  (LSU_m_axi_awvalid),
            .m_axi_awready  (ARB_s_axi_awready_B),
            .m_axi_wdata    (LSU_m_axi_wdata),
            .m_axi_wstrb    (LSU_m_axi_wstrb),
            .m_axi_wvalid   (LSU_m_axi_wvalid),
            .m_axi_wready   (ARB_s_axi_wready_B),
            .m_axi_bresp    (ARB_s_axi_bresp_B),
            .m_axi_bvalid   (ARB_s_axi_bvalid_B),
            .m_axi_bready   (LSU_m_axi_bready)
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

    ARB ysyx_26040125_ARB(
            .clk             	( clock              ),
            .reset           	( reset            ),
            .s_axi_araddr_A  	( IFU_m_axi_araddr   ),
            .s_axi_arvalid_A 	( IFU_m_axi_arvalid  ),
            .s_axi_arready_A 	( ARB_s_axi_arready_A  ),
            .s_axi_rdata_A   	( ARB_s_axi_rdata_A    ),
            .s_axi_rresp_A   	( ARB_s_axi_rresp_A    ),
            .s_axi_rvalid_A  	( ARB_s_axi_rvalid_A   ),
            .s_axi_rready_A  	( IFU_m_axi_rready   ),
            .s_axi_awaddr_A  	( IFU_m_axi_awaddr   ),
            .s_axi_awvalid_A 	( IFU_m_axi_awvalid  ),
            .s_axi_awready_A 	( ARB_s_axi_awready_A  ),
            .s_axi_wdata_A   	( IFU_m_axi_wdata    ),
            .s_axi_wstrb_A   	( IFU_m_axi_wstrb    ),
            .s_axi_wvalid_A  	( IFU_m_axi_wvalid   ),
            .s_axi_wready_A  	( ARB_s_axi_wready_A   ),
            .s_axi_bresp_A   	( ARB_s_axi_bresp_A    ),
            .s_axi_bvalid_A  	( ARB_s_axi_bvalid_A   ),
            .s_axi_bready_A  	( IFU_m_axi_bready   ),

            .s_axi_araddr_B  	( LSU_m_axi_araddr   ),
            .s_axi_arvalid_B 	( LSU_m_axi_arvalid  ),
            .s_axi_arready_B 	( ARB_s_axi_arready_B  ),
            .s_axi_rdata_B   	( ARB_s_axi_rdata_B    ),
            .s_axi_rresp_B   	( ARB_s_axi_rresp_B    ),
            .s_axi_rvalid_B  	( ARB_s_axi_rvalid_B   ),
            .s_axi_rready_B  	( LSU_m_axi_rready   ),
            .s_axi_awaddr_B  	( LSU_m_axi_awaddr   ),
            .s_axi_awvalid_B 	( LSU_m_axi_awvalid  ),
            .s_axi_awready_B 	( ARB_s_axi_awready_B  ),
            .s_axi_wdata_B   	( LSU_m_axi_wdata    ),
            .s_axi_wstrb_B   	( LSU_m_axi_wstrb    ),
            .s_axi_wvalid_B  	( LSU_m_axi_wvalid   ),
            .s_axi_wready_B  	( ARB_s_axi_wready_B   ),
            .s_axi_bresp_B   	( ARB_s_axi_bresp_B    ),
            .s_axi_bvalid_B  	( ARB_s_axi_bvalid_B   ),
            .s_axi_bready_B  	( LSU_m_axi_bready   ),

            .m_axi_araddr    	( ARB_m_axi_araddr     ),
            .m_axi_arvalid   	( ARB_m_axi_arvalid    ),
            .m_axi_arready   	( XBAR_s_axi_arready   ),
            .m_axi_rdata     	( XBAR_s_axi_rdata     ),
            .m_axi_rresp     	( XBAR_s_axi_rresp     ),
            .m_axi_rvalid    	( XBAR_s_axi_rvalid    ),
            .m_axi_rready    	( ARB_m_axi_rready     ),
            .m_axi_awaddr    	( ARB_m_axi_awaddr     ),
            .m_axi_awvalid   	( ARB_m_axi_awvalid    ),
            .m_axi_awready   	( XBAR_s_axi_awready   ),
            .m_axi_wdata     	( ARB_m_axi_wdata      ),
            .m_axi_wstrb     	( ARB_m_axi_wstrb      ),
            .m_axi_wvalid    	( ARB_m_axi_wvalid     ),
            .m_axi_wready    	( XBAR_s_axi_wready    ),
            .m_axi_bresp     	( XBAR_s_axi_bresp     ),
            .m_axi_bvalid    	( XBAR_s_axi_bvalid    ),
            .m_axi_bready    	( ARB_m_axi_bready     )
        );

    XBAR ysyx_26040125_XBAR(
             .clk             (clock),
             .reset           (reset),
             .s_axi_araddr    (ARB_m_axi_araddr),
             .s_axi_arvalid   (ARB_m_axi_arvalid),
             .s_axi_arready   (XBAR_s_axi_arready),
             .s_axi_rdata     (XBAR_s_axi_rdata),
             .s_axi_rresp     (XBAR_s_axi_rresp),
             .s_axi_rvalid    (XBAR_s_axi_rvalid),
             .s_axi_rready    (ARB_m_axi_rready),
             .s_axi_awaddr    (ARB_m_axi_awaddr),
             .s_axi_awvalid   (ARB_m_axi_awvalid),
             .s_axi_awready   (XBAR_s_axi_awready),
             .s_axi_wdata     (ARB_m_axi_wdata),
             .s_axi_wstrb     (ARB_m_axi_wstrb),
             .s_axi_wvalid    (ARB_m_axi_wvalid),
             .s_axi_wready    (XBAR_s_axi_wready),
             .s_axi_bresp     (XBAR_s_axi_bresp),
             .s_axi_bvalid    (XBAR_s_axi_bvalid),
             .s_axi_bready    (ARB_m_axi_bready),
             .m_axi_araddr_A  (XBAR_m_axi_araddr_A),
             .m_axi_arvalid_A (XBAR_m_axi_arvalid_A),
             .m_axi_arready_A (UART_s_axi_arready),
             .m_axi_rdata_A   (UART_s_axi_rdata),
             .m_axi_rresp_A   (UART_s_axi_rresp),
             .m_axi_rvalid_A  (UART_s_axi_rvalid),
             .m_axi_rready_A  (XBAR_m_axi_rready_A),
             .m_axi_awaddr_A  (XBAR_m_axi_awaddr_A),
             .m_axi_awvalid_A (XBAR_m_axi_awvalid_A),
             .m_axi_awready_A (UART_s_axi_awready),
             .m_axi_wdata_A   (XBAR_m_axi_wdata_A),
             .m_axi_wstrb_A   (XBAR_m_axi_wstrb_A),
             .m_axi_wvalid_A  (XBAR_m_axi_wvalid_A),
             .m_axi_wready_A  (UART_s_axi_wready),
             .m_axi_bresp_A   (UART_s_axi_bresp),
             .m_axi_bvalid_A  (UART_s_axi_bvalid),
             .m_axi_bready_A  (XBAR_m_axi_bready_A),

             .m_axi_araddr_B  (XBAR_m_axi_araddr_B),
             .m_axi_arvalid_B (XBAR_m_axi_arvalid_B),
             .m_axi_arready_B (RAM_s_axi_arready),
             .m_axi_rdata_B   (RAM_s_axi_rdata),
             .m_axi_rresp_B   (RAM_s_axi_rresp),
             .m_axi_rvalid_B  (RAM_s_axi_rvalid),
             .m_axi_rready_B  (XBAR_m_axi_rready_B),
             .m_axi_awaddr_B  (XBAR_m_axi_awaddr_B),
             .m_axi_awvalid_B (XBAR_m_axi_awvalid_B),
             .m_axi_awready_B (RAM_s_axi_awready),
             .m_axi_wdata_B   (XBAR_m_axi_wdata_B),
             .m_axi_wstrb_B   (XBAR_m_axi_wstrb_B),
             .m_axi_wvalid_B  (XBAR_m_axi_wvalid_B),
             .m_axi_wready_B  (RAM_s_axi_wready),
             .m_axi_bresp_B   (RAM_s_axi_bresp),
             .m_axi_bvalid_B  (RAM_s_axi_bvalid),
             .m_axi_bready_B  (XBAR_m_axi_bready_B),
             
             .m_axi_araddr_C  (XBAR_m_axi_araddr_C),
             .m_axi_arvalid_C (XBAR_m_axi_arvalid_C),
             .m_axi_arready_C (MTIME_s_axi_arready),
             .m_axi_rdata_C   (MTIME_s_axi_rdata),
             .m_axi_rresp_C   (MTIME_s_axi_rresp),
             .m_axi_rvalid_C  (MTIME_s_axi_rvalid),
             .m_axi_rready_C  (XBAR_m_axi_rready_C),
             .m_axi_awaddr_C  (XBAR_m_axi_awaddr_C),
             .m_axi_awvalid_C (XBAR_m_axi_awvalid_C),
             .m_axi_awready_C (MTIME_s_axi_awready),
             .m_axi_wdata_C   (XBAR_m_axi_wdata_C),
             .m_axi_wstrb_C   (XBAR_m_axi_wstrb_C),
             .m_axi_wvalid_C  (XBAR_m_axi_wvalid_C),
             .m_axi_wready_C  (MTIME_s_axi_wready),
             .m_axi_bresp_C   (MTIME_s_axi_bresp),
             .m_axi_bvalid_C  (MTIME_s_axi_bvalid),
             .m_axi_bready_C  (XBAR_m_axi_bready_C)
         );

    UART ysyx_26040125_UART(
             .clk           (clock),
             .reset         (reset),
             .s_axi_araddr  (XBAR_m_axi_araddr_A),
             .s_axi_arvalid (XBAR_m_axi_arvalid_A),
             .s_axi_arready (UART_s_axi_arready),
             .s_axi_rdata   (UART_s_axi_rdata),
             .s_axi_rresp   (UART_s_axi_rresp),
             .s_axi_rvalid  (UART_s_axi_rvalid),
             .s_axi_rready  (XBAR_m_axi_rready_A),
             .s_axi_awaddr  (XBAR_m_axi_awaddr_A),
             .s_axi_awvalid (XBAR_m_axi_awvalid_A),
             .s_axi_awready (UART_s_axi_awready),
             .s_axi_wdata   (XBAR_m_axi_wdata_A),
             .s_axi_wstrb   (XBAR_m_axi_wstrb_A),
             .s_axi_wvalid  (XBAR_m_axi_wvalid_A),
             .s_axi_wready  (UART_s_axi_wready),
             .s_axi_bresp   (UART_s_axi_bresp),
             .s_axi_bvalid  (UART_s_axi_bvalid),
             .s_axi_bready  (XBAR_m_axi_bready_A)
         );

    RAM ysyx_26040125_RAM(
            .clk            (clock),
            .reset          (reset),
            .s_axi_araddr   (XBAR_m_axi_araddr_B),
            .s_axi_arvalid  (XBAR_m_axi_arvalid_B),
            .s_axi_arready  (RAM_s_axi_arready),
            .s_axi_rdata    (RAM_s_axi_rdata),
            .s_axi_rresp    (RAM_s_axi_rresp),
            .s_axi_rvalid   (RAM_s_axi_rvalid),
            .s_axi_rready   (XBAR_m_axi_rready_B),
            .s_axi_awaddr   (XBAR_m_axi_awaddr_B),
            .s_axi_awvalid  (XBAR_m_axi_awvalid_B),
            .s_axi_awready  (RAM_s_axi_awready),
            .s_axi_wdata    (XBAR_m_axi_wdata_B),
            .s_axi_wstrb    (XBAR_m_axi_wstrb_B),
            .s_axi_wvalid   (XBAR_m_axi_wvalid_B),
            .s_axi_wready   (RAM_s_axi_wready),
            .s_axi_bresp    (RAM_s_axi_bresp),
            .s_axi_bvalid   (RAM_s_axi_bvalid),
            .s_axi_bready   (XBAR_m_axi_bready_B)
        );

    MTIME ysyx_26040125_MTIME(
              .clk           	( clock            ),
              .reset         	( reset          ),
              .s_axi_araddr  	( XBAR_m_axi_araddr_C   ),
              .s_axi_arvalid 	( XBAR_m_axi_arvalid_C ),
              .s_axi_arready 	( MTIME_s_axi_arready  ),
              .s_axi_rdata   	( MTIME_s_axi_rdata    ),
              .s_axi_rresp   	( MTIME_s_axi_rresp    ),
              .s_axi_rvalid  	( MTIME_s_axi_rvalid   ),
              .s_axi_rready  	( XBAR_m_axi_rready_C ),
              .s_axi_awaddr  	( XBAR_m_axi_awaddr_C ),
              .s_axi_awvalid 	( XBAR_m_axi_awvalid_C ),
              .s_axi_awready 	( MTIME_s_axi_awready  ),
              .s_axi_wdata   	( XBAR_m_axi_wdata_C ),
              .s_axi_wstrb   	( XBAR_m_axi_wstrb_C ),
              .s_axi_wvalid  	( XBAR_m_axi_wvalid_C ),
              .s_axi_wready  	( MTIME_s_axi_wready   ),
              .s_axi_bresp   	( MTIME_s_axi_bresp    ),
              .s_axi_bvalid  	( MTIME_s_axi_bvalid   ),
              .s_axi_bready  	( XBAR_m_axi_bready_C )
          );

endmodule
