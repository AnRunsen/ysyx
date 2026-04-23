import PKG::pmem_read;

module RAM(
        input clk,
        input arstn,
        input [31:0] raddr,
        output reg [31:0] rdata
    );

    always @(posedge clk or negedge arstn) begin
        if(!arstn)
            rdata <= 32'b0;
        else
            rdata <= pmem_read(raddr);
    end
endmodule
