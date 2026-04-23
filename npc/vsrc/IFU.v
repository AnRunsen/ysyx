import PKG::itrace;
module IFU(
    input clk,
    input arstn,

    input [31:0] PC,
    output [31:0] Inst,
    output Inst_valid,

    output [31:0] ifu_raddr,
    input  [31:0] ifu_rdata
);

    localparam IDLE = 1'b0;
    localparam WAIT = 1'b1;

    reg state, next_state;

    always @(*) begin
        case(state)
            IDLE: next_state = WAIT;
            WAIT: next_state = IDLE;
        endcase
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) state <= IDLE;
        else state <= next_state;
    end

    assign ifu_raddr = PC;
    assign Inst_valid = (state == WAIT);
    assign Inst = ifu_rdata;

    always @(posedge clk or negedge arstn) begin
        if(state == WAIT) begin
            itrace(Inst, PC);
        end
    end

endmodule
