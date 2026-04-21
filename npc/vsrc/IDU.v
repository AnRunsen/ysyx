`include "MACRO.v"
import PKG::sim_exit;
module IDU(
    /* explict ports*/
    input [31:0] Inst,
    output [4:0] rd,
    output [31:0] srcR1,
    output [31:0] srcR2,
    
    output reg [31:0] imm,

    output reg [3:0] alu_op,
    output reg wb_en,
    
    output reg mem_en,
    output reg mem_write_en,
    output [1:0] op_width,

    output [2:0] wb_sel, //imm, alu, mem, PC+4

    output reg [1:0] alu_sel0, //sel the ALU A port is srcR1(0) or PC(1)
    output reg [1:0] alu_sel1, //sel the ALU B port is srcR2(0) or imm(1) or csr(2)
    output reg [1:0] brju,
    output reg mem_signext,

    output [11:0] csr_addr,
    output reg csr_wr_sel, //0: write srcR1, 1: write alu_res
    output reg csr_wen,

    output reg ecall,
    output reg mret,

    /*implict ports for read GPRs*/
    output [4:0] rs1,
    output [4:0] rs2,
    input [31:0] srcR1_in,
    input [31:0] srcR2_in
);

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    /*all of the imm are sign-extended to 32 bits*/
    wire [31:0] immI;
    wire [31:0] immS;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immJ;

    assign csr_addr = Inst[31:20];

    assign srcR1 = srcR1_in;
    assign srcR2 = srcR2_in;

    assign rs1 = (opcode == 7'b1110011 && funct3 == 3'b000) ? (rs2 == 5'b1 ? 5'd10 : 5'd15) : Inst[19:15];
    assign rs2 = Inst[24:20];
    assign rd = Inst[11:7];
    assign opcode = Inst[6:0];
    assign funct3 = Inst[14:12];
    assign funct7 = Inst[31:25];


    assign immI = { {20{Inst[31]}}, Inst[31:20] };
    assign immS = { {20{Inst[31]}}, Inst[31:25], Inst[11:7] };
    assign immB = { {19{Inst[31]}}, Inst[31], Inst[7], Inst[30:25], Inst[11:8], 1'b0 };
    assign immU = { Inst[31:12], 12'b0 };
    assign immJ = { {11{Inst[31]}}, Inst[31], Inst[19:12], Inst[20], Inst[30:21], 1'b0 };


    always @(*) begin
        // --- safe defaults (all zeros, which map to PC_NORMAL / ALU_SEL_RS1 / ALU_SEL_RS2) ---
        imm          = 0;
        alu_op       = 0;
        wb_en        = 0;
        mem_write_en = 0;
        op_width     = 0;
        wb_sel       = 0;
        alu_sel0     = 0;
        alu_sel1     = 0;
        brju         = `PC_NORMAL;
        mem_signext  = 0;
        mem_en       = 0;
        csr_wr_sel   = 0;
        csr_wen      = 0;
        ecall        = 0;
        mret         = 0;

        case(opcode)
            7'b1100011: begin //branch  — all share immB / RS1 vs RS2 / PC_BRANCH
                imm      = immB;
                alu_sel0 = `ALU_SEL_RS1;
                alu_sel1 = `ALU_SEL_RS2;
                brju     = `PC_BRANCH;
                case(funct3)
                    3'b000: alu_op = `ALU_OP_EQ;   //beq
                    3'b001: alu_op = `ALU_OP_NE;   //bne
                    3'b100: alu_op = `ALU_OP_LT;   //blt
                    3'b101: alu_op = `ALU_OP_GE;   //bge
                    3'b110: alu_op = `ALU_OP_LTU;  //bltu
                    3'b111: alu_op = `ALU_OP_GEU;  //bgeu
                    default: sim_exit(Inst);
                endcase
            end

            7'b1101111: begin //jal
                imm    = immJ;
                wb_en  = 1;
                wb_sel = `WB_SEL_PC4;
                brju   = `PC_NEAR;
            end

            7'b1100111: begin //jalr
                case(funct3)
                    3'b000: begin
                        imm      = immI;
                        alu_op   = `ALU_OP_ADD;
                        wb_en    = 1;
                        wb_sel   = `WB_SEL_PC4;
                        alu_sel0 = `ALU_SEL_RS1;
                        alu_sel1 = `ALU_SEL_IMM;
                        brju     = `PC_FAR;
                    end
                    default: sim_exit(Inst);
                endcase
            end

            7'b0110111: begin //lui
                imm    = immU;
                wb_en  = 1;
                wb_sel = `WB_SEL_IMM;
            end

            7'b0010111: begin //auipc
                imm      = immU;
                alu_op   = `ALU_OP_ADD;
                wb_en    = 1;
                wb_sel   = `WB_SEL_ALU;
                alu_sel0 = `ALU_SEL_PC;
                alu_sel1 = `ALU_SEL_IMM;
            end

            7'b0110011: begin //OP  — all share wb_en=1 / WB_SEL_ALU / RS1 vs RS2
                wb_en    = 1;
                wb_sel   = `WB_SEL_ALU;
                alu_sel0 = `ALU_SEL_RS1;
                alu_sel1 = `ALU_SEL_RS2;
                case(funct3)
                    3'b000: alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SUB : `ALU_OP_ADD; //add/sub
                    3'b001: alu_op = `ALU_OP_SLL;  //sll
                    3'b010: alu_op = `ALU_OP_LT;   //slt
                    3'b011: alu_op = `ALU_OP_LTU;  //sltu
                    3'b100: alu_op = `ALU_OP_XOR;  //xor
                    3'b101: alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL; //srl/sra
                    3'b110: alu_op = `ALU_OP_OR;   //or
                    3'b111: alu_op = `ALU_OP_AND;  //and
                    default: sim_exit(Inst);
                endcase
            end

            7'b0010011: begin //OP-IMM  — all share immI / wb_en=1 / WB_SEL_ALU / RS1 / IMM
                imm      = immI;
                wb_en    = 1;
                wb_sel   = `WB_SEL_ALU;
                alu_sel0 = `ALU_SEL_RS1;
                alu_sel1 = `ALU_SEL_IMM;
                case(funct3)
                    3'b000: alu_op = `ALU_OP_ADD;  //addi
                    3'b001: alu_op = `ALU_OP_SLL;  //slli
                    3'b010: alu_op = `ALU_OP_LT;   //slti
                    3'b011: alu_op = `ALU_OP_LTU;  //sltiu
                    3'b100: alu_op = `ALU_OP_XOR;  //xori
                    3'b101: alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL; //srli/srai
                    3'b110: alu_op = `ALU_OP_OR;   //ori
                    3'b111: alu_op = `ALU_OP_AND;  //andi
                    default: sim_exit(Inst);
                endcase
            end

            7'b0000011: begin //LOAD  — all share immI / ADD / wb_en=1 / WB_SEL_MEM / RS1 / IMM / mem_en=1
                imm      = immI;
                alu_op   = `ALU_OP_ADD;
                wb_en    = 1;
                wb_sel   = `WB_SEL_MEM;
                alu_sel0 = `ALU_SEL_RS1;
                alu_sel1 = `ALU_SEL_IMM;
                mem_en   = 1;
                case(funct3)
                    3'b000: begin op_width = `OP_WIDTH_BYTE; mem_signext = 1; end //lb
                    3'b001: begin op_width = `OP_WIDTH_HALF; mem_signext = 1; end //lh
                    3'b010: begin op_width = `OP_WIDTH_WORD; mem_signext = 1; end //lw
                    3'b100: begin op_width = `OP_WIDTH_BYTE; mem_signext = 0; end //lbu
                    3'b101: begin op_width = `OP_WIDTH_HALF; mem_signext = 0; end //lhu
                    default: sim_exit(Inst);
                endcase
            end

            7'b0100011: begin //STORE  — all share immS / ADD / mem_write_en=1 / RS1 / IMM / mem_en=1
                imm          = immS;
                alu_op       = `ALU_OP_ADD;
                mem_write_en = 1;
                alu_sel0     = `ALU_SEL_RS1;
                alu_sel1     = `ALU_SEL_IMM;
                mem_en       = 1;
                case(funct3)
                    3'b000: op_width = `OP_WIDTH_BYTE; //sb
                    3'b001: op_width = `OP_WIDTH_HALF; //sh
                    3'b010: op_width = `OP_WIDTH_WORD; //sw
                    default: sim_exit(Inst);
                endcase
            end

            7'b1110011: begin //SYSTEM
                case(funct3)
                    3'b000: begin
                        if(funct7 == 7'b0000000 && rs2 == 5'b00001) sim_exit(srcR1); //ebreak
                        else if(funct7 == 7'b0000000 && rs2 == 5'b00000) begin //ecall
                            ecall = 1;
                        end
                        else if(funct7 == 7'b0011000 && rs2 == 5'b00010) begin //mret
                            mret = 1;
                        end
                        else sim_exit(Inst);
                        
                    end

                    3'b001: begin //csrrw
                        wb_en      = 1;
                        wb_sel     = `WB_SEL_CSR;
                        csr_wr_sel = `CSR_SEL_RS1;
                        csr_wen    = 1;
                    end

                    3'b010: begin //csrrs
                        alu_op     = `ALU_OP_OR;
                        wb_en      = 1;
                        wb_sel     = `WB_SEL_CSR;
                        alu_sel0   = `ALU_SEL_RS1;
                        alu_sel1   = `ALU_SEL_CSR;
                        csr_wr_sel = `CSR_SEL_ALU;
                        csr_wen    = 1;
                    end
                    default: sim_exit(Inst);
                endcase
            end

            default: sim_exit(Inst);
        endcase
    end
endmodule

