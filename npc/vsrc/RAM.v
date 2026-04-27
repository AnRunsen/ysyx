import PKG::pmem_read;
import PKG::pmem_write;

module RAM(
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

    // ---- 8-bit Fibonacci LFSR (polynomial x^8 + x^4 + x^3 + x^2 + 1) ----
    // Provides pseudo-random latency of 1-8 cycles for both read and write channels.
    reg  [7:0] lfsr;
    wire       lfsr_fb = lfsr[7] ^ lfsr[3] ^ lfsr[2] ^ lfsr[1];

    always @(posedge clk) begin
        if (reset) lfsr <= 8'hAC;       // non-zero seed
        else        lfsr <= {lfsr[6:0], lfsr_fb};
    end

    // ---- Read channel ----
    // FSM: R_IDLE -> R_WAIT (1-8 cycles) -> R_RESP
    localparam R_IDLE = 2'd0, R_WAIT = 2'd1, R_RESP = 2'd2;

    reg  [1:0]  r_state;
    reg  [31:0] rdata_reg;
    reg  [31:0] r_addr_reg;
    reg  [3:0]  r_cnt;

    assign s_axi_arready = (r_state == R_IDLE);
    assign s_axi_rdata   = rdata_reg;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rvalid  = (r_state == R_RESP);

    always @(posedge clk) begin
        if (reset) begin
            r_state    <= R_IDLE;
            rdata_reg  <= 32'b0;
            r_addr_reg <= 32'b0;
            r_cnt      <= 4'b0;
        end else begin
            case (r_state)
                R_IDLE: begin
                    if (s_axi_arvalid) begin
                        r_addr_reg <= s_axi_araddr;
                        r_cnt      <= {1'b0, lfsr[2:0]} + 4'd1; // 1-8 cycles
                        r_state    <= R_WAIT;
                    end
                end
                R_WAIT: begin
                    if (r_cnt == 4'd1) begin
                        rdata_reg <= pmem_read(r_addr_reg);
                        r_state   <= R_RESP;
                    end else begin
                        r_cnt <= r_cnt - 4'd1;
                    end
                end
                R_RESP: begin
                    if (s_axi_rready)
                        r_state <= R_IDLE;
                end
                default: r_state <= R_IDLE;
            endcase
        end
    end

    // ---- Write channel ----
    // FSM: W_IDLE -> W_WAIT_W / W_WAIT_AW -> W_LATENCY (1-8 cycles) -> W_RESP
    localparam W_IDLE    = 3'd0, W_WAIT_W = 3'd1,
               W_WAIT_AW = 3'd2, W_LATENCY = 3'd3, W_RESP = 3'd4;

    reg  [2:0]  w_state;
    reg  [31:0] awaddr_reg;
    reg  [31:0] wdata_reg;
    reg  [3:0]  wstrb_reg;
    reg  [3:0]  w_cnt;

    assign s_axi_awready = (w_state == W_IDLE || w_state == W_WAIT_AW);
    assign s_axi_wready  = (w_state == W_IDLE || w_state == W_WAIT_W);
    assign s_axi_bresp   = 2'b00;
    assign s_axi_bvalid  = (w_state == W_RESP);

    always @(posedge clk) begin
        if (reset) begin
            w_state    <= W_IDLE;
            awaddr_reg <= 32'b0;
            wdata_reg  <= 32'b0;
            wstrb_reg  <= 4'b0;
            w_cnt      <= 4'b0;
        end else begin
            case (w_state)
                W_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        awaddr_reg <= s_axi_awaddr;
                        wdata_reg  <= s_axi_wdata;
                        wstrb_reg  <= s_axi_wstrb;
                        w_cnt      <= {1'b0, lfsr[6:4]} + 4'd1; // 1-8 cycles
                        w_state    <= W_LATENCY;
                    end else if (s_axi_awvalid) begin
                        awaddr_reg <= s_axi_awaddr;
                        w_state    <= W_WAIT_W;
                    end else if (s_axi_wvalid) begin
                        wdata_reg  <= s_axi_wdata;
                        wstrb_reg  <= s_axi_wstrb;
                        w_state    <= W_WAIT_AW;
                    end
                end
                W_WAIT_W: begin
                    if (s_axi_wvalid) begin
                        wdata_reg <= s_axi_wdata;
                        wstrb_reg <= s_axi_wstrb;
                        w_cnt     <= {1'b0, lfsr[6:4]} + 4'd1;
                        w_state   <= W_LATENCY;
                    end
                end
                W_WAIT_AW: begin
                    if (s_axi_awvalid) begin
                        awaddr_reg <= s_axi_awaddr;
                        w_cnt      <= {1'b0, lfsr[6:4]} + 4'd1;
                        w_state    <= W_LATENCY;
                    end
                end
                W_LATENCY: begin
                    if (w_cnt == 4'd1) begin
                        pmem_write(awaddr_reg, wdata_reg, {4'b0, wstrb_reg});
                        w_state <= W_RESP;
                    end else begin
                        w_cnt <= w_cnt - 4'd1;
                    end
                end
                W_RESP: begin
                    if (s_axi_bready)
                        w_state <= W_IDLE;
                end
                default: w_state <= W_IDLE;
            endcase
        end
    end

endmodule
