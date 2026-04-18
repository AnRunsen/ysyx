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

    output [1:0] wb_sel, //imm, alu, mem, PC+4

    output reg alu_sel0, //sel the ALU A port is srcR1(0) or PC(1)
    output reg alu_sel1, //sel the ALU B port is srcR2(0) or imm(1)
    output reg [1:0] brju, //00:PC=PC+4, 01:PC=PC+imm, 10:PC=ALU_RES
    output reg mem_signext,


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


    assign srcR1 = srcR1_in;
    assign srcR2 = srcR2_in;

    assign rs1 = (opcode == 7'b1110011) ? 5'd10 : Inst[19:15];
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
        case(opcode)
            7'b1100011: begin //branch
                case(funct3)
                    3'b000: begin //beq
                        imm = immB;
                        alu_op = `ALU_OP_EQ;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b001: begin //bne
                        imm = immB;
                        alu_op = `ALU_OP_NE;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b100: begin //blt
                        imm = immB;
                        alu_op = `ALU_OP_LT;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b101: begin //bge
                        imm = immB;
                        alu_op = `ALU_OP_GE;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b110: begin //bltu
                        imm = immB;
                        alu_op = `ALU_OP_LTU;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b111: begin //bgeu
                        imm = immB;
                        alu_op = `ALU_OP_GEU;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_BRANCH; // PC=PC+imm
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            7'b1101111: begin //jal
                imm = immJ;
                alu_op = 0; // not care
                wb_en = 1;
                mem_write_en = 0;
                op_width = 0;
                wb_sel = `WB_SEL_PC4; // PC+4
                alu_sel0 = 0;
                alu_sel1 = 0;
                brju = `PC_NEAR; // PC=PC+imm
                mem_signext = 0;
                mem_en = 0;
            end

            7'b0010111: begin //auipc
                imm = immU;
                alu_op = `ALU_OP_ADD;
                wb_en = 1;
                mem_write_en = 0;
                op_width = 0;
                wb_sel = `WB_SEL_ALU; // alu
                alu_sel0 = `ALU_SEL_PC; // PC
                alu_sel1 = `ALU_SEL_IMM; // imm
                brju = `PC_NORMAL; // PC+4
                mem_signext = 0;
                mem_en = 0;
            end

            7'b1110011: begin //System
                case(funct3)
                    3'b000: begin //ebreak
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;

                        if(funct7 == 7'b0000000 && rs2 == 5'b00001) sim_exit(srcR1);
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;

                        sim_exit(Inst);
                    end
                endcase
            end

            7'b0110011: begin //OP
                case(funct3)
                    3'b000: begin //add, sub
                        imm = 0;
                        alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SUB : `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b001: begin //sll
                        imm = 0;
                        alu_op = `ALU_OP_SLL;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b010: begin //slt
                        imm = 0;
                        alu_op = `ALU_OP_LT;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b011: begin //sltu
                        imm = 0;
                        alu_op = `ALU_OP_LTU;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b100: begin //xor
                        imm = 0;
                        alu_op = `ALU_OP_XOR;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b101: begin //srl, sra
                        imm = 0;
                        alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b110: begin //or
                        imm = 0;
                        alu_op = `ALU_OP_OR;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b111: begin //and
                        imm = 0;
                        alu_op = `ALU_OP_AND;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_RS2; // reg
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            7'b0110111: begin //lui
                imm = immU;
                alu_op = 0; // not care
                wb_en = 1;
                mem_write_en = 0;
                op_width = 0;
                wb_sel = `WB_SEL_IMM; // alu
                alu_sel0 = 0;
                alu_sel1 = 0;
                brju = `PC_NORMAL; // PC+4
                mem_signext = 0;
                mem_en = 0;
            end

            7'b0000011: begin //load
                case(funct3)
                    3'b000: begin //lb
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_BYTE;
                        wb_sel = `WB_SEL_MEM; // mem
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 1;
                        mem_en = 1;
                    end

                    3'b001: begin //lh
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_HALF;
                        wb_sel = `WB_SEL_MEM; // mem
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 1;
                        mem_en = 1;
                    end

                    3'b010: begin //lw
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_WORD;
                        wb_sel = `WB_SEL_MEM; // mem
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 1;
                        mem_en = 1;
                    end

                    3'b100: begin //lbu
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_BYTE;
                        wb_sel = `WB_SEL_MEM; // mem
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 1;
                    end

                    3'b101: begin //lhu
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_HALF;
                        wb_sel = `WB_SEL_MEM; // mem
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 1;
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            7'b0010011: begin //OP-IMM
                case(funct3)
                    3'b000: begin //addi
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end
                    
                    3'b010: begin //slti
                        imm = immI;
                        alu_op = `ALU_OP_LT;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b011: begin //sltiu
                        imm = immI;
                        alu_op = `ALU_OP_LTU;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b100: begin //xori
                        imm = immI;
                        alu_op = `ALU_OP_XOR;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b110: begin //ori
                        imm = immI;
                        alu_op = `ALU_OP_OR;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b111: begin //andi
                        imm = immI;
                        alu_op = `ALU_OP_AND;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b001: begin //slli
                        imm = immI;
                        alu_op = `ALU_OP_SLL;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    3'b101: begin //srli, srai
                        imm = immI;
                        alu_op = (funct7 == 7'b0100000) ? `ALU_OP_SRA : `ALU_OP_SRL;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                        mem_en = 0;
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0;
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            7'b1100111: begin
                case(funct3)
                    3'b000: begin //jalr
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = `WB_SEL_PC4; // PC+4
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_FAR; // PC=ALU_RES
                        mem_signext = 0;
                        mem_en = 0;

                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0; // alu
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0;
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            7'b0100011: begin //store
                case(funct3)
                    3'b000: begin //sb
                        imm = immS;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 0;
                        mem_write_en = 1;
                        op_width = `OP_WIDTH_BYTE;
                        wb_sel = 0; // not care
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 1;
                    end

                    3'b001: begin //sh
                        imm = immS;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 0;
                        mem_write_en = 1;
                        op_width = `OP_WIDTH_HALF;
                        wb_sel = 0; // not care
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 1;
                    end

                    3'b010: begin //sw
                        imm = immS;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 0;
                        mem_write_en = 1;
                        op_width = `OP_WIDTH_WORD;
                        wb_sel = 0; // not care
                        alu_sel0 = `ALU_SEL_RS1; // reg
                        alu_sel1 = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL; // PC+4
                        mem_signext = 0;
                        mem_en = 1;
                    end

                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0; // alu
                        alu_sel0 = 0;
                        alu_sel1 = 0;
                        brju = 0; // PC+4
                        mem_signext = 0;
                        mem_en = 0;
                        sim_exit(Inst);
                    end
                endcase
            end

            default: begin
                imm = 0;
                alu_op = 0;
                wb_en = 0;
                mem_write_en = 0;
                op_width = 0;
                wb_sel = 0;
                alu_sel0 = 0;
                alu_sel1 = 0;
                brju = 0;
                mem_signext = 0;
                mem_en = 0;
                sim_exit(Inst);
            end
        endcase
    end
endmodule

