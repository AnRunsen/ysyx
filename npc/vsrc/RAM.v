import PKG::pmem_read;
import PKG::pmem_write;

module RAM(
        input clk,
        input arstn,
        input [31:0] addr,
        input mem_en,
        input wen,
        input [31:0] wdata,
        input [3:0] wmask,
        output reg [31:0] rdata
    );

    always @(posedge clk or negedge arstn) begin
        if(!arstn)
            rdata <= 32'b0;
        else
            if(mem_en) rdata <= pmem_read(addr);
    end

    always @(posedge clk) begin
        if(wen && mem_en) pmem_write(addr, wdata, {4'b0, wmask});
    end
endmodule
