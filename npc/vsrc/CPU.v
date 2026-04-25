module CPU(
    input clk,
    input arstn
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

    // RAM_IFU outputs
    wire        RAM_IFU_s_axi_arready;
    wire [31:0] RAM_IFU_s_axi_rdata;
    wire [1:0]  RAM_IFU_s_axi_rresp;
    wire        RAM_IFU_s_axi_rvalid;
    wire        RAM_IFU_s_axi_awready;
    wire        RAM_IFU_s_axi_wready;
    wire [1:0]  RAM_IFU_s_axi_bresp;
    wire        RAM_IFU_s_axi_bvalid;

    // RAM_LSU outputs
    wire        RAM_LSU_s_axi_arready;
    wire [31:0] RAM_LSU_s_axi_rdata;
    wire [1:0]  RAM_LSU_s_axi_rresp;
    wire        RAM_LSU_s_axi_rvalid;
    wire        RAM_LSU_s_axi_awready;
    wire        RAM_LSU_s_axi_wready;
    wire [1:0]  RAM_LSU_s_axi_bresp;
    wire        RAM_LSU_s_axi_bvalid;


    PCR u_PCR(
        .clk         (clk),
        .arstn       (arstn),
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

    IFU u_IFU(
        .clk            (clk),
        .arstn          (arstn),
        .next_inst      (WBU_next_inst),
        .m_Inst         (IFU_m_Inst),
        .m_PC           (IFU_m_PC),
        .m_valid        (IFU_m_valid),
        .m_ready        (IDU_s_ready),
        .PC             (PCR_PC),
        .m_axi_araddr   (IFU_m_axi_araddr),
        .m_axi_arvalid  (IFU_m_axi_arvalid),
        .m_axi_arready  (RAM_IFU_s_axi_arready),
        .m_axi_rdata    (RAM_IFU_s_axi_rdata),
        .m_axi_rresp    (RAM_IFU_s_axi_rresp),
        .m_axi_rvalid   (RAM_IFU_s_axi_rvalid),
        .m_axi_rready   (IFU_m_axi_rready),
        .m_axi_awaddr   (IFU_m_axi_awaddr),
        .m_axi_awvalid  (IFU_m_axi_awvalid),
        .m_axi_awready  (RAM_IFU_s_axi_awready),
        .m_axi_wdata    (IFU_m_axi_wdata),
        .m_axi_wstrb    (IFU_m_axi_wstrb),
        .m_axi_wvalid   (IFU_m_axi_wvalid),
        .m_axi_wready   (RAM_IFU_s_axi_wready),
        .m_axi_bresp    (RAM_IFU_s_axi_bresp),
        .m_axi_bvalid   (RAM_IFU_s_axi_bvalid),
        .m_axi_bready   (IFU_m_axi_bready)
    );

    GPR u_GPR(
        .clk    (clk),
        .arstn  (arstn),
        .wdata  (WBU_wdata),
        .waddr  (WBU_waddr[3:0]),
        .wen    (WBU_wen),
        .raddr1 (IDU_rs1[3:0]),
        .rdata1 (GPR_rdata1),
        .raddr2 (IDU_rs2[3:0]),
        .rdata2 (GPR_rdata2)
    );

    IDU u_IDU(
        .clk            (clk),
        .arstn          (arstn),
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

    EXU u_EXU(
        .clk            (clk),
        .arstn          (arstn),
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

    LSU u_LSU(
        .clk            (clk),
        .arstn          (arstn),
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
        .m_axi_arready  (RAM_LSU_s_axi_arready),
        .m_axi_rdata    (RAM_LSU_s_axi_rdata),
        .m_axi_rresp    (RAM_LSU_s_axi_rresp),
        .m_axi_rvalid   (RAM_LSU_s_axi_rvalid),
        .m_axi_rready   (LSU_m_axi_rready),
        .m_axi_awaddr   (LSU_m_axi_awaddr),
        .m_axi_awvalid  (LSU_m_axi_awvalid),
        .m_axi_awready  (RAM_LSU_s_axi_awready),
        .m_axi_wdata    (LSU_m_axi_wdata),
        .m_axi_wstrb    (LSU_m_axi_wstrb),
        .m_axi_wvalid   (LSU_m_axi_wvalid),
        .m_axi_wready   (RAM_LSU_s_axi_wready),
        .m_axi_bresp    (RAM_LSU_s_axi_bresp),
        .m_axi_bvalid   (RAM_LSU_s_axi_bvalid),
        .m_axi_bready   (LSU_m_axi_bready)
    );

    WBU u_WBU(
        .clk            (clk),
        .arstn          (arstn),
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

    CSR u_CSR(
        .clk     (clk),
        .arstn   (arstn),
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

    RAM u_RAM_IFU(
        .clk            (clk),
        .arstn          (arstn),
        .s_axi_araddr   (IFU_m_axi_araddr),
        .s_axi_arvalid  (IFU_m_axi_arvalid),
        .s_axi_arready  (RAM_IFU_s_axi_arready),
        .s_axi_rdata    (RAM_IFU_s_axi_rdata),
        .s_axi_rresp    (RAM_IFU_s_axi_rresp),
        .s_axi_rvalid   (RAM_IFU_s_axi_rvalid),
        .s_axi_rready   (IFU_m_axi_rready),
        .s_axi_awaddr   (IFU_m_axi_awaddr),
        .s_axi_awvalid  (IFU_m_axi_awvalid),
        .s_axi_awready  (RAM_IFU_s_axi_awready),
        .s_axi_wdata    (IFU_m_axi_wdata),
        .s_axi_wstrb    (IFU_m_axi_wstrb),
        .s_axi_wvalid   (IFU_m_axi_wvalid),
        .s_axi_wready   (RAM_IFU_s_axi_wready),
        .s_axi_bresp    (RAM_IFU_s_axi_bresp),
        .s_axi_bvalid   (RAM_IFU_s_axi_bvalid),
        .s_axi_bready   (IFU_m_axi_bready)
    );

    RAM u_RAM_LSU(
        .clk            (clk),
        .arstn          (arstn),
        .s_axi_araddr   (LSU_m_axi_araddr),
        .s_axi_arvalid  (LSU_m_axi_arvalid),
        .s_axi_arready  (RAM_LSU_s_axi_arready),
        .s_axi_rdata    (RAM_LSU_s_axi_rdata),
        .s_axi_rresp    (RAM_LSU_s_axi_rresp),
        .s_axi_rvalid   (RAM_LSU_s_axi_rvalid),
        .s_axi_rready   (LSU_m_axi_rready),
        .s_axi_awaddr   (LSU_m_axi_awaddr),
        .s_axi_awvalid  (LSU_m_axi_awvalid),
        .s_axi_awready  (RAM_LSU_s_axi_awready),
        .s_axi_wdata    (LSU_m_axi_wdata),
        .s_axi_wstrb    (LSU_m_axi_wstrb),
        .s_axi_wvalid   (LSU_m_axi_wvalid),
        .s_axi_wready   (RAM_LSU_s_axi_wready),
        .s_axi_bresp    (RAM_LSU_s_axi_bresp),
        .s_axi_bvalid   (RAM_LSU_s_axi_bvalid),
        .s_axi_bready   (LSU_m_axi_bready)
    );

endmodule
