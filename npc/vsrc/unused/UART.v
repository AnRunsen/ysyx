import PKG::uart_write;

module UART(
    input clk,
    input reset,

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

    /*read port unused*/
    assign s_axi_arready = 1'b0;
    assign s_axi_rdata   = 32'b0;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rvalid  = 1'b0;

    localparam IDLE = 2'd0, WAIT_DATA = 2'd1, WAIT_ADDR = 2'd2, RESP = 2'd3;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            IDLE: begin
                if (s_axi_awvalid && s_axi_awready && s_axi_wvalid && s_axi_wready) begin
                    next_state = RESP;
                end
                else if(s_axi_awvalid && s_axi_awready) begin
                    next_state = WAIT_DATA;
                end
                else if(s_axi_wvalid && s_axi_wready) begin
                    next_state = WAIT_ADDR;
                end
                else begin
                    next_state = IDLE;
                end
            end
            WAIT_DATA: begin
                if (s_axi_wvalid && s_axi_wready) begin
                    next_state = RESP;
                end else begin
                    next_state = WAIT_DATA;
                end
            end

            WAIT_ADDR: begin
                if (s_axi_awvalid && s_axi_awready) begin
                    next_state = RESP;
                end else begin
                    next_state = WAIT_ADDR;
                end
            end
            RESP: begin
                if (s_axi_bready && s_axi_bvalid) begin
                    next_state = IDLE;
                end else begin
                    next_state = RESP;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end


    /*logic to recv data*/
    assign s_axi_awready = (state == IDLE || state == WAIT_ADDR);
    assign s_axi_wready  = (state == IDLE || state == WAIT_DATA);
    reg [31:0] waddr;
    reg [31:0] wdata;
    reg [3:0] wstrb;
    always @(posedge clk) begin
        if (reset) begin
            waddr <= 32'b0;
            wdata <= 32'b0;
            wstrb <= 4'b0;
        end
        else begin
            if (s_axi_awvalid && s_axi_awready) begin
                waddr <= s_axi_awaddr;
            end
            if (s_axi_wvalid && s_axi_wready) begin
                wdata <= s_axi_wdata;
                wstrb <= s_axi_wstrb;
            end
        end
    end


    /*logic to send response*/
    assign s_axi_bresp = 2'b00;
    assign s_axi_bvalid = (state == RESP);

    /*logic to printf*/
    always @(posedge clk) begin
        if (s_axi_bvalid && s_axi_bready) begin
            uart_write(waddr, wdata, {4'b0, wstrb});
        end
    end


endmodule
