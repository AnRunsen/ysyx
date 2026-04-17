import PKG::pmem_read;
import PKG::inst_port;
module IFU(
    input [31:0] PC,
    output reg [31:0] Inst
);

    always @(*) begin
        Inst = pmem_read(PC);
        inst_port(Inst, PC);
    end

endmodule
