module CSR(
    input clk,
    input arstn,
    input [11:0] addr, //rd addr and wr addr are the same
    input [31:0] srcR1,
    input [31:0] alu_res,
    input wr_sel, //0: write srcR1, 1: write alu_res
    input wen,
    output reg [31:0] rdata
);

    reg [31:0] mcycle;
    reg [31:0] mcycleh;

    //a combinational logic to read CSR, only take the mycle(h) into account
    always @(*) begin
        if(addr == 12'hc00) rdata = mcycle; //mcycle
        else if(addr == 12'hc80) rdata = mcycleh; //mcycleh
        else rdata = 32'b0;
    end

    always @(posedge clk or negedge arstn) begin
        if(!arstn) mcycle <= 32'b0;
        else mcycle <= mcycle + 1;
    end
    
    always @(posedge clk or negedge arstn) begin
        if(!arstn) mcycleh <= 32'b0;
        else if(mcycle == 32'hffff_ffff) mcycleh <= mcycleh + 1;
    end


endmodule
