import PKG::mtime_read;

module MTIME(
    input clk,
    input reset,

    input [31:0] s_axi_araddr,
    input s_axi_arvalid,
    output s_axi_arready,

    output reg [31:0] s_axi_rdata,
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

    /*write port unused*/
    assign s_axi_awready = 1'b0;
    assign s_axi_wready  = 1'b0;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_bvalid  = 1'b0;

    localparam IDLE = 2'd0, RESP = 2'd1;
    reg [1:0] state, next_state;

    always @(*) begin
        case(state)
            IDLE: begin
                if (s_axi_arvalid && s_axi_arready) begin
                    next_state = RESP;
                end else begin
                    next_state = IDLE;
                end
            end
            RESP: begin
                if (s_axi_rready && s_axi_rvalid) begin
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

    always @(posedge clk) begin
        if (reset) begin
            s_axi_rdata <= 32'b0;
        end
        else if (s_axi_arready && s_axi_arvalid) begin
            s_axi_rdata <= mtime_read(s_axi_araddr);
        end
    end

    assign s_axi_arready = (state == IDLE);
    assign s_axi_rvalid  = (state == RESP);
    assign s_axi_rresp   = 2'b00;

endmodule
