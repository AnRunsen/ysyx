import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(
  input int waddr, input int wdata, input byte wmask
);
import "DPI-C" function void sim_exit();

module CPU(
        input clk,
        input arstn
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
            .Inst       	( IFU_Inst        )
        );

    wire [31:0] 	LSU_rdata;

    LSU u_LSU(
            .mem_write_en  	( IDU_mem_write_en   ),
            .op_width      	( IDU_op_width       ),
            .sign_ext_en   	( IDU_mem_signext    ),
            .addr          	( EXU_result           ),
            .wdata         	( IDU_srcR2          ),
            .rdata         	( LSU_rdata          )
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


endmodule
