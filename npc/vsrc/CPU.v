module CPU(
        input clk,
        input arstn,

        /*interact with RAM*/
        output [31:0] raddr0, //0 is used by IFU
        input [31:0] rdata0,
        output [31:0] raddr1, //1 is used by LSU
        input [31:0] rdata1,
        output [31:0] waddr,
        output [31:0] wdata,
        output wen,
        output [1:0] op_width
    );

    wire [31:0] 	PCU_PC;

    PCU u_PCU(
            .clk        	( clk         ),
            .arstn      	( arstn       ),
            .PC         	( PCU_PC          ),
            .exu_result 	( EXU_result  ),
            .imm        	( IDU_imm         ),
            .behavior   	( IDU_brju    )
        );

    wire [31:0] 	EXU_result;

    EXU u_EXU(
            .srcR1    	( IDU_srcR1     ),
            .srcR2    	( IDU_srcR2     ),
            .imm      	( IDU_imm       ),
            .alu_sel 	( IDU_alu_sel  ),
            .alu_op   	( IDU_alu_op    ),
            .result   	( EXU_result    )
        );

    wire [31:0] 	GPR_rdata1;
    wire [31:0] 	GPR_rdata2;

    GPR u_GPR(
            .clk    	( clk     ),
            .arstn  	( arstn   ),
            .wdata  	( WBU_wdata   ),
            .waddr  	( WBU_waddr   ),
            .wen    	( WBU_wen     ),
            .raddr1 	( IDU_rs1  ),
            .rdata1 	( GPR_rdata1  ),
            .raddr2 	( IDU_rs2  ),
            .rdata2 	( GPR_rdata2  )
        );

    wire [4:0]  	IDU_rd;
    wire [31:0] 	IDU_srcR1;
    wire [31:0] 	IDU_srcR2;
    wire [31:0] 	IDU_imm;
    wire [3:0]  	IDU_alu_op;
    wire        	IDU_wb_en;
    wire        	IDU_mem_write_en;
    wire [1:0]  	IDU_op_width;
    wire [1:0]  	IDU_wb_sel;
    wire        	IDU_alu_sel;
    wire [1:0]  	IDU_brju;
    wire [4:0]  	IDU_rs1;
    wire [4:0]  	IDU_rs2;
    wire            IDU_mem_signext;

    IDU u_IDU(
            .Inst         	( IFU_Inst          ),
            .rd           	( IDU_rd            ),
            .srcR1        	( IDU_srcR1         ),
            .srcR2        	( IDU_srcR2         ),
            .imm          	( IDU_imm           ),
            .alu_op       	( IDU_alu_op        ),
            .wb_en 	        ( IDU_wb_en  ),
            .mem_write_en 	( IDU_mem_write_en  ),
            .op_width     	( IDU_op_width      ),
            .wb_sel       	( IDU_wb_sel        ),
            .alu_sel     	( IDU_alu_sel      ),
            .brju         	( IDU_brju          ),
            .rs1          	( IDU_rs1           ),
            .rs2          	( IDU_rs2           ),
            .srcR1_in     	( GPR_rdata1      ),
            .srcR2_in     	( GPR_rdata2      ),
            .mem_signext    ( IDU_mem_signext )
        );

    wire [31:0] 	IFU_Inst;
    wire [31:0] 	IFU_RAM_raddr0;

    IFU u_IFU(
            .PC         	( PCU_PC          ),
            .Inst       	( IFU_Inst        ),
            .RAM_raddr0 	( IFU_RAM_raddr0  ),
            .RAM_rdata0 	( rdata0  )
        );

    wire [31:0] 	LSU_rdata;
    wire [31:0] 	LSU_addr_;
    wire [31:0] 	LSU_wdata_;
    wire [1:0]  	LSU_op_width_;
    wire        	LSU_mem_write_en_;

    LSU u_LSU(
            .mem_write_en  	( IDU_mem_write_en   ),
            .op_width      	( IDU_op_width       ),
            .sign_ext_en   	( IDU_mem_signext    ),
            .addr          	( EXU_result           ),
            .wdata         	( IDU_srcR2          ),
            .rdata         	( LSU_rdata          ),
            .addr_         	( LSU_addr_          ),
            .wdata_        	( LSU_wdata_         ),
            .rdata_        	( rdata1         ),
            .op_width_     	( LSU_op_width_      ),
            .mem_write_en_ 	( LSU_mem_write_en_  )
        );

    wire        	WBU_wen;
    wire [31:0] 	WBU_wdata;
    wire [4:0]  	WBU_waddr;

    WBU u_WBU(
            .rd      	( IDU_rd       ),
            .en      	( IDU_wb_en    ),
            .wb_sel  	( IDU_wb_sel   ),
            .imm     	( IDU_imm      ),
            .exu_res 	( EXU_result  ),
            .mem     	( LSU_rdata      ),
            .PC      	( PCU_PC       ),
            .wen     	( WBU_wen      ),
            .wdata   	( WBU_wdata    ),
            .waddr   	( WBU_waddr    )
        );


    assign raddr0 = IFU_RAM_raddr0;
    assign raddr1 = LSU_addr_;
    assign waddr = LSU_addr_;
    assign wdata = LSU_wdata_;
    assign wen = LSU_mem_write_en_;
    assign op_width = LSU_op_width_;


endmodule
