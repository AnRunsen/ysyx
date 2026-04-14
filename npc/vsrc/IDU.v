`include "MACRO.v"

module IDU(
    /* explict ports*/
    input [31:0] Inst,
    output [4:0] rd,
    output [31:0] srcR1,
    output [31:0] srcR2,
    
    output reg [31:0] imm,

    output reg [3:0] alu_op,
    output reg wb_en,
    
    output reg mem_write_en,
    output [1:0] op_width,

    output [1:0] wb_sel, //imm, alu, mem, PC+4

    output reg alu_sel, //sel the ALU B port is srcR2(0) or imm(1)
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

    assign rs1 = Inst[19:15];
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
            7'b0010011: begin
                case(funct3)
                    3'b000: begin //addi
                        imm = immI;
                        alu_op = `ALU_OP_ADD;
                        wb_en = 1;
                        mem_write_en = 0;
                        op_width = `OP_WIDTH_NONE;
                        wb_sel = `WB_SEL_ALU; // alu
                        alu_sel = `ALU_SEL_IMM; // imm
                        brju = `PC_NORMAL;
                        mem_signext = 0;
                    end
                    default: begin
                        imm = 0;
                        alu_op = 0;
                        wb_en = 0;
                        mem_write_en = 0;
                        op_width = 0;
                        wb_sel = 0; // alu
                        alu_sel = 0; // imm
                        brju = 0;
                        mem_signext = 0;
                    end
                endcase
            end

            default: begin
                imm = 0;
                alu_op = 0;
                wb_en = 0;
                mem_write_en = 0;
                op_width = 0;
                wb_sel = 0; // alu
                alu_sel = 0; // imm
                brju = 0;
                mem_signext = 0;
            end
        endcase
    end
endmodule

