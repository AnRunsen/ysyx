`include "MACRO.v"
`ifndef SYNTHESIS
    import PKG::sim_exit;
    import PKG::perf_cnt_update;
`endif
module IDU(
    input clk,
    input reset,

    input flush,

    /* explict ports*/
    input [31:0] s_Inst,
    input [31:0] s_PC,
    input s_valid,
    output s_ready,


    output [4:0] m_rd,
    output [31:0] m_srcR1,
    output [31:0] m_srcR2,
    output reg [31:0] m_imm,

    output reg [3:0] m_alu_op,
    output reg [1:0] m_alu_sel0, //sel the ALU A port is m_srcR1(0) or PC(1)
    output reg [1:0] m_alu_sel1, //sel the ALU B port is m_srcR2(0) or m_imm(1) or csr(2)

    output m_wb_en,
    output m_mem_en,
    output m_mem_write_en,

    output [1:0] m_op_width,
    output [2:0] m_wb_sel, //m_imm, alu, mem, PC+4

    output reg [1:0] m_brju,
    output reg m_mem_signext,

    output reg [11:0] m_csr_addr,
    output [31:0] m_csr_data,
    output reg m_csr_wr_sel, //0: write m_srcR1, 1: write alu_res
    output reg m_csr_wen,

    output reg m_ecall,
    output reg m_mret,
    output [31:0] m_PC,

    output m_fencei,

    output m_valid,
    input m_ready,

    /*implict ports for read GPRs and CSRs*/
    output [4:0] rs1,
    output [4:0] rs2,
    output [11:0] csr_addr,
    input [31:0] srcR1_in,
    input [31:0] srcR2_in,
    input [31:0] csr_data,

    /*handle the RAW*/
    input [4:0] rd_exu,
    input [11:0] csr_exu,
    input rd_valid_exu,
    input csr_valid_exu,
    input [4:0] rd_lsu,
    input [11:0] csr_lsu,
    input rd_valid_lsu,
    input csr_valid_lsu,
    input [4:0] rd_wbu,
    input [11:0] csr_wbu,
    input rd_valid_wbu,
    input csr_valid_wbu
);
`ifndef SYNTHESIS
    always @(posedge clk) begin
        if(m_valid & m_ready) begin
            perf_cnt_update(1);
        end
    end
`endif


    /*handle the RAW*/
    wire       	stall;
    reg need_rs2;
    RAW u_RAW(
        .rs1         	( rs1          ),
        .rs2         	( rs2          ),
        .need_rs2    	( need_rs2     ),
        .csr_addr    	( csr_addr     ),
        .rd_exu      	( rd_exu       ),
        .rd_valid_exu 	( rd_valid_exu  ),
        .rd_lsu      	( rd_lsu       ),
        .rd_valid_lsu 	( rd_valid_lsu  ),
        .rd_wbu      	( rd_wbu       ),
        .rd_valid_wbu 	( rd_valid_wbu  ),
        .csr_exu      	( csr_exu       ),
        .csr_valid_exu 	( csr_valid_exu  ),
        .csr_lsu      	( csr_lsu       ),
        .csr_valid_lsu 	( csr_valid_lsu  ),
        .csr_wbu      	( csr_wbu       ),
        .csr_valid_wbu 	( csr_valid_wbu  ),
        .stall       	( stall       )
    );


    /*logic to recv data*/
    reg [31:0] inst_reg;
    reg [31:0] pc_reg;
    assign s_ready = (!m_valid || (m_valid & m_ready)) && !stall;
    always @(posedge clk) begin
        if(reset) begin
            inst_reg <= 32'b0;
            pc_reg <= 32'b0;
        end
        else begin
            if(s_ready & s_valid) begin
                inst_reg <= s_Inst;
                pc_reg <= s_PC;
            end
        end
    end

    /*logic to send data*/
    assign m_PC = pc_reg;
    reg valid_reg;
    assign m_valid = valid_reg && !stall && !flush;
    always @(posedge clk) begin
        if(reset) begin
            valid_reg <= 1'b0;
        end

        else begin
            if(flush) begin
                valid_reg <= 1'b0;
            end
            else if(s_valid & s_ready) begin
                valid_reg <= 1'b1;
            end
            else if(m_valid & m_ready) begin
                valid_reg <= 1'b0;
            end
        end
    end


    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    /*all of the m_imm are sign-extended to 32 bits*/
    wire [31:0] immI;
    wire [31:0] immS;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immJ;

    assign m_csr_data = csr_data;
    assign csr_addr = m_csr_addr;

    assign m_srcR1 = srcR1_in;
    assign m_srcR2 = srcR2_in;


    assign rs1 = (opcode == 7'b1110011 && funct3 == 3'b000) ? (rs2 == 5'b1 ? 5'd10 : 5'd15) : inst_reg[19:15];
    assign rs2 = inst_reg[24:20];
    assign m_rd = inst_reg[11:7];
    assign opcode = inst_reg[6:0];
    assign funct3 = inst_reg[14:12];
    assign funct7 = inst_reg[31:25];


    assign immI = { {20{inst_reg[31]}}, inst_reg[31:20] };
    assign immS = { {20{inst_reg[31]}}, inst_reg[31:25], inst_reg[11:7] };
    assign immB = { {19{inst_reg[31]}}, inst_reg[31], inst_reg[7], inst_reg[30:25], inst_reg[11:8], 1'b0 };
    assign immU = { inst_reg[31:12], 12'b0 };
    assign immJ = { {11{inst_reg[31]}}, inst_reg[31], inst_reg[19:12], inst_reg[20], inst_reg[30:21], 1'b0 };


    always @(*) begin
        // --- safe defaults (all zeros, which map to PC_NORMAL / ALU_SEL_RS1 / ALU_SEL_RS2) ---
        m_imm          = 0;
        m_alu_op       = 0;
        m_wb_en        = 0;
        m_mem_write_en = 0;
        m_op_width     = 0;
        m_wb_sel       = 0;
        m_alu_sel0     = 0;
        m_alu_sel1     = 0;
        m_brju         = `PC_NORMAL;
        m_mem_signext  = 0;
        m_mem_en       = 0;
        m_csr_wr_sel   = 0;
        m_csr_wen      = 0;
        m_ecall        = 0;
        m_mret         = 0;
        m_csr_addr     = 0;
        m_fencei       = 0;
        need_rs2       = 0;

        case(opcode)
            7'b1100011: begin //branch  — all share immB / RS1 vs RS2 / PC_BRANCH
                m_imm      = immB;
                m_alu_sel0 = `ALU_SEL_RS1;
                m_alu_sel1 = `ALU_SEL_RS2;
                m_brju     = `PC_BRANCH;
                need_rs2   = 1;
                case(funct3)
                    3'b000: m_alu_op = `ALU_OP_EQ;   //beq
                    3'b001: m_alu_op = `ALU_OP_NE;   //bne
                    3'b100: m_alu_op = `ALU_OP_LT;   //blt
                    3'b101: m_alu_op = `ALU_OP_GE;   //bge
                    3'b110: m_alu_op = `ALU_OP_LTU;  //bltu
                    3'b111: m_alu_op = `ALU_OP_GEU;  //bgeu
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b1101111: begin //jal
                m_imm    = immJ;
                m_wb_en  = 1;
                m_wb_sel = `WB_SEL_PC4;
                m_brju   = `PC_NEAR;
            end

            7'b1100111: begin //jalr
                case(funct3)
                    3'b000: begin
                        m_imm      = immI;
                        m_alu_op   = `ALU_OP_ADD;
                        m_wb_en    = 1;
                        m_wb_sel   = `WB_SEL_PC4;
                        m_alu_sel0 = `ALU_SEL_RS1;
                        m_alu_sel1 = `ALU_SEL_IMM;
                        m_brju     = `PC_FAR;
                    end
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b0110111: begin //lui
                m_imm    = immU;
                m_wb_en  = 1;
                m_wb_sel = `WB_SEL_IMM;
            end

            7'b0010111: begin //auipc
                m_imm      = immU;
                m_alu_op   = `ALU_OP_ADD;
                m_wb_en    = 1;
                m_wb_sel   = `WB_SEL_ALU;
                m_alu_sel0 = `ALU_SEL_PC;
                m_alu_sel1 = `ALU_SEL_IMM;
            end

            7'b0110011: begin //OP  — all share m_wb_en=1 / WB_SEL_ALU / RS1 vs RS2
                m_wb_en    = 1;
                m_wb_sel   = `WB_SEL_ALU;
                m_alu_sel0 = `ALU_SEL_RS1;
                m_alu_sel1 = `ALU_SEL_RS2;
                need_rs2   = 1;
                case(funct3)
                    3'b000: m_alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SUB : `ALU_OP_ADD; //add/sub
                    3'b001: m_alu_op = `ALU_OP_SLL;  //sll
                    3'b010: m_alu_op = `ALU_OP_LT;   //slt
                    3'b011: m_alu_op = `ALU_OP_LTU;  //sltu
                    3'b100: m_alu_op = `ALU_OP_XOR;  //xor
                    3'b101: m_alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL; //srl/sra
                    3'b110: m_alu_op = `ALU_OP_OR;   //or
                    3'b111: m_alu_op = `ALU_OP_AND;  //and
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b0010011: begin //OP-IMM  — all share immI / m_wb_en=1 / WB_SEL_ALU / RS1 / IMM
                m_imm      = immI;
                m_wb_en    = 1;
                m_wb_sel   = `WB_SEL_ALU;
                m_alu_sel0 = `ALU_SEL_RS1;
                m_alu_sel1 = `ALU_SEL_IMM;
                case(funct3)
                    3'b000: m_alu_op = `ALU_OP_ADD;  //addi
                    3'b001: m_alu_op = `ALU_OP_SLL;  //slli
                    3'b010: m_alu_op = `ALU_OP_LT;   //slti
                    3'b011: m_alu_op = `ALU_OP_LTU;  //sltiu
                    3'b100: m_alu_op = `ALU_OP_XOR;  //xori
                    3'b101: m_alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL; //srli/srai
                    3'b110: m_alu_op = `ALU_OP_OR;   //ori
                    3'b111: m_alu_op = `ALU_OP_AND;  //andi
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b0000011: begin //LOAD  — all share immI / ADD / m_wb_en=1 / WB_SEL_MEM / RS1 / IMM / m_mem_en=1
                m_imm      = immI;
                m_alu_op   = `ALU_OP_ADD;
                m_wb_en    = 1;
                m_wb_sel   = `WB_SEL_MEM;
                m_alu_sel0 = `ALU_SEL_RS1;
                m_alu_sel1 = `ALU_SEL_IMM;
                m_mem_en   = 1;
                case(funct3)
                    3'b000: begin m_op_width = `OP_WIDTH_BYTE; m_mem_signext = 1; end //lb
                    3'b001: begin m_op_width = `OP_WIDTH_HALF; m_mem_signext = 1; end //lh
                    3'b010: begin m_op_width = `OP_WIDTH_WORD; m_mem_signext = 1; end //lw
                    3'b100: begin m_op_width = `OP_WIDTH_BYTE; m_mem_signext = 0; end //lbu
                    3'b101: begin m_op_width = `OP_WIDTH_HALF; m_mem_signext = 0; end //lhu
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b0100011: begin //STORE  — all share immS / ADD / m_mem_write_en=1 / RS1 / IMM / m_mem_en=1
                m_imm          = immS;
                m_alu_op       = `ALU_OP_ADD;
                m_mem_write_en = 1;
                m_alu_sel0     = `ALU_SEL_RS1;
                m_alu_sel1     = `ALU_SEL_IMM;
                m_mem_en       = 1;
                need_rs2       = 1;
                case(funct3)
                    3'b000: m_op_width = `OP_WIDTH_BYTE; //sb
                    3'b001: m_op_width = `OP_WIDTH_HALF; //sh
                    3'b010: m_op_width = `OP_WIDTH_WORD; //sw
                    default:begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b1110011: begin //SYSTEM
                case(funct3)
                    3'b000: begin
                        if(funct7 == 7'b0000000 && rs2 == 5'b00001) begin
                            `ifndef SYNTHESIS
                                if(valid_reg) sim_exit(m_srcR1); //ebreak
                            `endif
                        end
                        else if(funct7 == 7'b0000000 && rs2 == 5'b00000) begin //m_ecall
                            m_csr_addr = 12'h305; //mtvec
                            m_ecall = 1;
                        end
                        else if(funct7 == 7'b0011000 && rs2 == 5'b00010) begin //m_mret
                            m_csr_addr = 12'h341; //mepc
                            m_mret = 1;
                        end
                        else begin
                            `ifndef SYNTHESIS
                                if(valid_reg) sim_exit(inst_reg);
                            `endif
                        end
                        
                    end

                    3'b001: begin //csrrw
                        m_wb_en      = 1;
                        m_wb_sel     = `WB_SEL_CSR;
                        m_csr_wr_sel = `CSR_SEL_RS1;
                        m_csr_wen    = 1;
                        m_csr_addr = inst_reg[31:20];
                    end

                    3'b010: begin //csrrs
                        m_alu_op     = `ALU_OP_OR;
                        m_wb_en      = 1;
                        m_wb_sel     = `WB_SEL_CSR;
                        m_alu_sel0   = `ALU_SEL_RS1;
                        m_alu_sel1   = `ALU_SEL_CSR;
                        m_csr_wr_sel = `CSR_SEL_ALU;
                        m_csr_wen    = 1;
                        m_csr_addr = inst_reg[31:20];
                    end
                    default: begin
                        `ifndef SYNTHESIS
                            if(valid_reg) sim_exit(inst_reg);
                        `endif
                    end
                endcase
            end

            7'b0001111: begin //FENCE
                m_fencei = (funct3 == 3'b001);
            end

            default:begin
                `ifndef SYNTHESIS
                    if(valid_reg) sim_exit(inst_reg);
                `endif
            end
        endcase 
    end



endmodule

