import PKG::pmem_read;
import PKG::itrace;
module IFU(
    input [31:0] PC,
    output reg [31:0] Inst
);

    always @(*) begin
        Inst = pmem_read(PC);
        itrace(Inst, PC);
    end

endmodule
