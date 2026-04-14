import "DPI-C" function int pmem_read(input int raddr);

module IFU(
    input [31:0] PC,
    output reg [31:0] Inst
);

    always @(*) begin
        Inst = pmem_read(PC);
    end

endmodule