import PKG::pmem_read;
import PKG::pmem_write;

module RAM(
    input clk,
    input arstn,

    input [31:0] s_axi_araddr,
    input s_axi_arvalid,
    output s_axi_arready,

    output [31:0] s_axi_rdata,
    output [1:0] s_axi_rresp,
    output s_axi_rvalid,
    input s_axi_rready,

    input [31:0] s_axi_awaddr,
    input s_axi_awvalid,
    output s_axi_awready,

    input [31:0] s_axi_wdata,
    input [3:0] s_axi_wstrb,
    input s_axi_wvalid,
    output s_axi_wready,

    output [1:0] s_axi_bresp,
    output s_axi_bvalid,
    input s_axi_bready
);

    // ---- Read channel ----
    reg [31:0] rdata_reg;
    reg        rvalid_reg;

    assign s_axi_arready = 1'b1;
    assign s_axi_rdata   = rdata_reg;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rvalid  = rvalid_reg;

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            rdata_reg  <= 32'b0;
            rvalid_reg <= 1'b0;
        end
        else if (s_axi_arvalid && s_axi_arready) begin
            rdata_reg  <= pmem_read(s_axi_araddr);
            rvalid_reg <= 1'b1;
        end
        else if (s_axi_rvalid && s_axi_rready) begin
            rvalid_reg <= 1'b0;
        end
    end

    // ---- Write channel ----
    reg [31:0] awaddr_reg;
    reg        bvalid_reg;

    assign s_axi_awready = 1'b1;
    assign s_axi_wready  = 1'b1;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_bvalid  = bvalid_reg;

    always @(posedge clk or negedge arstn) begin
        if (!arstn) begin
            awaddr_reg <= 32'b0;
            bvalid_reg <= 1'b0;
        end else begin
            if (s_axi_awvalid && s_axi_awready)
                awaddr_reg <= s_axi_awaddr;
            if (s_axi_wvalid && s_axi_wready) begin
                pmem_write(
                    s_axi_awvalid ? s_axi_awaddr : awaddr_reg,
                    s_axi_wdata,
                    {4'b0, s_axi_wstrb}
                );
                bvalid_reg <= 1'b1;
            end
            else if (s_axi_bvalid && s_axi_bready) begin
                bvalid_reg <= 1'b0;
            end
        end
    end

endmodule
