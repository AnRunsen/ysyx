import PKG::itrace;
module IFU(
    input clk,
    input arstn,

    output [31:0] m_Inst,
    output [31:0] m_PC,
    output m_Inst_valid,
    input m_Inst_ready,

    input [31:0] s_PC,
    input s_PC_valid,
    output s_PC_ready,

    //axi lite interface to RAM
    output [31:0] m_axi_araddr,
    output m_axi_arvalid,
    input m_axi_arready,

    input [31:0] m_axi_rdata,
    input [1:0] m_axi_rresp,
    input m_axi_rvalid,
    output m_axi_rready,


    output [31:0] m_axi_awaddr,
    output m_axi_awvalid,
    input m_axi_awready,

    output [31:0] m_axi_wdata,
    output [3:0] m_axi_wstrb,
    output m_axi_wvalid,
    input m_axi_wready,

    input [1:0] m_axi_bresp,
    input m_axi_bvalid,
    output m_axi_bready
);

    /*Unused AXI signals*/
    assign m_axi_awaddr = 32'b0;
    assign m_axi_awvalid = 1'b0;
    assign m_axi_wdata = 32'b0;
    assign m_axi_wstrb = 4'b0;
    assign m_axi_wvalid = 1'b0;
    assign m_axi_bready = 1'b0;


    /*logic to recv PC*/
    reg [31:0] PC_reg;
    assign s_PC_ready = !m_axi_arvalid || (m_axi_arvalid & m_axi_arready);
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            PC_reg <= 32'b0;
        end

        else begin
            if(s_PC_ready && s_PC_valid) begin
                PC_reg <= s_PC;
            end
        end
    end

    /*logic to recv rdata*/
    reg [31:0] m_axi_rdata_reg;
    assign m_axi_rready = !m_Inst_valid || (m_Inst_valid & m_Inst_ready);
    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            m_axi_rdata_reg <= 32'b0;
        end

        else begin
            if(m_axi_rready && m_axi_rvalid) begin
                m_axi_rdata_reg <= m_axi_rdata;
                itrace(m_axi_rdata, PC_reg);
            end
        end
    end


    /*logic to send ardata*/
    assign m_axi_araddr = PC_reg;
    reg m_axi_arvalid_reg;
    assign m_axi_arvalid = m_axi_arvalid_reg;

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            m_axi_arvalid_reg <= 1'b0;
        end
        else begin
            // upstream shakehand
            if(s_PC_valid && s_PC_ready) begin
                m_axi_arvalid_reg <= 1'b1;
            end
            else if(m_axi_arvalid && m_axi_arready) begin
                m_axi_arvalid_reg <= 1'b0;
            end

        end
    end

    /*logic to send data*/
    assign m_Inst = m_axi_rdata_reg;
    assign m_PC = PC_reg;
    reg Inst_valid_reg;
    assign m_Inst_valid = Inst_valid_reg;

    always @(posedge clk or negedge arstn) begin
        if(!arstn) begin
            Inst_valid_reg <= 1'b0;
        end

        else begin
            if(m_axi_rvalid && m_axi_rready) begin
                Inst_valid_reg <= 1'b1;
            end

            else if(m_Inst_valid && m_Inst_ready) begin
                Inst_valid_reg <= 1'b0;
            end
        end
    end


endmodule
