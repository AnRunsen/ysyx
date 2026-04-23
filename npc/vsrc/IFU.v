import PKG::itrace;
module IFU(
    input clk,
    input arstn,


    output [31:0] Inst,
    output Inst_valid,

    input [31:0] PC,
    output [31:0] ifu_raddr,
    input  [31:0] ifu_rdata,

    input next_inst
);

    localparam IDLE = 1'b0;
    localparam WAIT = 1'b1;

    reg state, next_state;

    always @(*) begin
        case(state)
            IDLE: next_state = WAIT;
            WAIT: next_state = next_inst ? IDLE : WAIT;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) state <= IDLE;
        else state <= next_state;
    end

    assign ifu_raddr = PC;
    assign Inst = ifu_rdata;
    assign Inst_valid = state == WAIT;

    always @(posedge clk or negedge arstn) begin
        if(state == WAIT && next_inst) begin
            itrace(Inst, PC);
        end
    end

endmodule
