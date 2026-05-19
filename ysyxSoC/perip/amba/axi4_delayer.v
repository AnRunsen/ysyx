`define DELAYER_ENABLE
module axi4_delayer(
  input         clock,
  input         reset,

  output        in_arready,
  input         in_arvalid,
  input  [3:0]  in_arid,
  input  [31:0] in_araddr,
  input  [7:0]  in_arlen,
  input  [2:0]  in_arsize,
  input  [1:0]  in_arburst,
  input         in_rready,
  output        in_rvalid,
  output [3:0]  in_rid,
  output [31:0] in_rdata,
  output [1:0]  in_rresp,
  output        in_rlast,
  output        in_awready,
  input         in_awvalid,
  input  [3:0]  in_awid,
  input  [31:0] in_awaddr,
  input  [7:0]  in_awlen,
  input  [2:0]  in_awsize,
  input  [1:0]  in_awburst,
  output        in_wready,
  input         in_wvalid,
  input  [31:0] in_wdata,
  input  [3:0]  in_wstrb,
  input         in_wlast,
                in_bready,
  output        in_bvalid,
  output [3:0]  in_bid,
  output [1:0]  in_bresp,

  input         out_arready,
  output        out_arvalid,
  output [3:0]  out_arid,
  output [31:0] out_araddr,
  output [7:0]  out_arlen,
  output [2:0]  out_arsize,
  output [1:0]  out_arburst,
  output        out_rready,
  input         out_rvalid,
  input  [3:0]  out_rid,
  input  [31:0] out_rdata,
  input  [1:0]  out_rresp,
  input         out_rlast,
  input         out_awready,
  output        out_awvalid,
  output [3:0]  out_awid,
  output [31:0] out_awaddr,
  output [7:0]  out_awlen,
  output [2:0]  out_awsize,
  output [1:0]  out_awburst,
  input         out_wready,
  output        out_wvalid,
  output [31:0] out_wdata,
  output [3:0]  out_wstrb,
  output        out_wlast,
                out_bready,
  input         out_bvalid,
  input  [3:0]  out_bid,
  input  [1:0]  out_bresp
);

`ifdef DELAYER_ENABLE
  localparam DELAY_RATE = 8;

  /*delayer for the ar channel*/
  reg [31:0] ar_delay_cnt;
  reg        ar_delay_flag;

  always @(posedge clock) begin
    if(reset) begin
      ar_delay_flag <= 1'b0;
    end
    else if(out_arready && out_arvalid) begin
      ar_delay_flag <= 1'b1;
    end
    else if(in_arready && in_arvalid) begin
      ar_delay_flag <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if(reset) begin
      ar_delay_cnt <= 32'b0;
    end
    else begin
      if(out_arvalid) begin
        ar_delay_cnt <= ar_delay_cnt + (DELAY_RATE - 1);
      end

      else if(ar_delay_flag) begin
        ar_delay_cnt <= ar_delay_cnt - 1;
      end

      else begin
        ar_delay_cnt <= 32'b0;
      end
    end
  end

  assign in_arready = (ar_delay_cnt == 0) && ar_delay_flag;
  assign out_arvalid = in_arvalid && !ar_delay_flag;
  assign out_arid    = in_arid;
  assign out_araddr  = in_araddr;
  assign out_arlen   = in_arlen;
  assign out_arsize  = in_arsize;
  assign out_arburst = in_arburst;


  /*delayer for the aw channel*/
  reg [31:0] aw_delay_cnt;
  reg        aw_delay_flag;

  always @(posedge clock) begin
    if(reset) begin
      aw_delay_flag <= 1'b0;
    end
    else if(out_awready && out_awvalid) begin
      aw_delay_flag <= 1'b1;
    end
    else if(in_awready && in_awvalid) begin
      aw_delay_flag <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if(reset) begin
      aw_delay_cnt <= 32'b0;
    end
    else begin
      if(out_awvalid) begin
        aw_delay_cnt <= aw_delay_cnt + (DELAY_RATE - 1);
      end

      else if(aw_delay_flag) begin
        aw_delay_cnt <= aw_delay_cnt - 1;
      end

      else begin
        aw_delay_cnt <= 32'b0;
      end
    end
  end

  assign in_awready = (aw_delay_cnt == 0) && aw_delay_flag;
  assign out_awvalid = in_awvalid && !aw_delay_flag;
  assign out_awid    = in_awid;
  assign out_awaddr  = in_awaddr;
  assign out_awlen   = in_awlen;
  assign out_awsize  = in_awsize;
  assign out_awburst = in_awburst;


  /*delayer for the w channel*/
  reg [31:0] w_delay_cnt;
  reg        w_delay_flag;

  always @(posedge clock) begin
    if(reset) begin
      w_delay_flag <= 1'b0;
    end
    else if(out_wready && out_wvalid) begin
      w_delay_flag <= 1'b1;
    end
    else if(in_wready && in_wvalid) begin
      w_delay_flag <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if(reset) begin
      w_delay_cnt <= 32'b0;
    end
    else begin
      if(out_wvalid) begin
        w_delay_cnt <= w_delay_cnt + (DELAY_RATE - 1);
      end

      else if(w_delay_flag) begin
        w_delay_cnt <= w_delay_cnt - 1;
      end

      else begin
        w_delay_cnt <= 32'b0;
      end
    end
  end

  assign in_wready = (w_delay_cnt == 0) && w_delay_flag;
  assign out_wvalid = in_wvalid && !w_delay_flag;
  assign out_wdata   = in_wdata;
  assign out_wstrb   = in_wstrb;
  assign out_wlast   = in_wlast;

  /*delayer for the b channel*/
  reg [31:0] b_delay_cnt;
  reg        b_delay_flag;

  always @(posedge clock) begin
    if(reset) begin
      b_delay_flag <= 1'b0;
    end
    else if(out_bready && out_bvalid) begin
      b_delay_flag <= 1'b1;
    end
    else if(in_bready && in_bvalid) begin
      b_delay_flag <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if(reset) begin
      b_delay_cnt <= 32'b0;
    end
    else begin
      if(out_bvalid && !b_delay_flag) begin
        b_delay_cnt <= b_delay_cnt + (DELAY_RATE - 1);
      end

      else if(b_delay_flag) begin
        b_delay_cnt <= b_delay_cnt - 1;
      end

      else begin
        b_delay_cnt <= 32'b0;
      end
    end
  end

  assign in_bvalid = (b_delay_cnt == 0) && b_delay_flag;
  assign in_bid    = out_bid;
  assign in_bresp  = out_bresp;
  assign out_bready = in_bready && !b_delay_flag;

  /*delayer for the r channel*/
  reg        r_trans_active;
  reg [31:0] r_elapsed;
  reg [7:0]  r_beats_total;
  reg [7:0]  r_beats_sent;

  reg [3:0]  r_id_q[7:0];
  reg [31:0] r_data_q[7:0];
  reg [1:0]  r_resp_q[7:0];
  reg        r_last_q[7:0];
  reg [31:0] r_delay_cnt[7:0];
  reg        r_valid_q[7:0];

  reg [2:0]  r_wr_ptr;
  reg [2:0]  r_rd_ptr;
  reg [3:0]  r_q_count;

  wire r_in_fire;
  wire r_out_fire;
  wire r_q_head_ready;
  wire r_q_full;

  assign r_q_full      = (r_q_count == 4'd8);
  assign out_rready    = !r_q_full;
  assign r_out_fire    = out_rready && out_rvalid;
  assign r_q_head_ready = r_valid_q[r_rd_ptr] && (r_delay_cnt[r_rd_ptr] == 32'b0);
  assign in_rvalid     = r_q_head_ready;
  assign r_in_fire     = in_rready && in_rvalid;

  assign in_rid        = r_id_q[r_rd_ptr];
  assign in_rdata      = r_data_q[r_rd_ptr];
  assign in_rresp      = r_resp_q[r_rd_ptr];
  assign in_rlast      = r_last_q[r_rd_ptr];

  integer i;
  always @(posedge clock) begin
    if(reset) begin
      r_trans_active <= 1'b0;
      r_elapsed      <= 32'b0;
      r_beats_total  <= 8'b0;
      r_beats_sent   <= 8'b0;
      r_wr_ptr       <= 3'b0;
      r_rd_ptr       <= 3'b0;
      r_q_count      <= 4'b0;
      for(i = 0; i < 8; i = i + 1) begin
        r_id_q[i]      <= 4'b0;
        r_data_q[i]    <= 32'b0;
        r_resp_q[i]    <= 2'b0;
        r_last_q[i]    <= 1'b0;
        r_delay_cnt[i] <= 32'b0;
        r_valid_q[i]   <= 1'b0;
      end
    end
    else begin
      if(!r_trans_active && in_arvalid) begin
        r_trans_active <= 1'b1;
        r_elapsed      <= 32'b0;
        r_beats_total  <= in_arlen + 1'b1;
        r_beats_sent   <= 8'b0;
      end
      else if(r_trans_active) begin
        r_elapsed <= r_elapsed + 1'b1;
      end

      for(i = 0; i < 8; i = i + 1) begin
        if(r_valid_q[i] && (r_delay_cnt[i] != 32'b0)) begin
          r_delay_cnt[i] <= r_delay_cnt[i] - 1'b1;
        end
      end

      if(r_out_fire) begin
        r_id_q[r_wr_ptr]      <= out_rid;
        r_data_q[r_wr_ptr]    <= out_rdata;
        r_resp_q[r_wr_ptr]    <= out_rresp;
        r_last_q[r_wr_ptr]    <= out_rlast;
        r_delay_cnt[r_wr_ptr] <= r_elapsed * (DELAY_RATE - 1);
        r_valid_q[r_wr_ptr]   <= 1'b1;
        r_wr_ptr              <= r_wr_ptr + 1'b1;
      end

      if(r_in_fire) begin
        r_valid_q[r_rd_ptr] <= 1'b0;
        r_delay_cnt[r_rd_ptr] <= 32'b0;
        r_rd_ptr            <= r_rd_ptr + 1'b1;
        r_beats_sent        <= r_beats_sent + 1'b1;
      end

      case({r_out_fire, r_in_fire})
        2'b10: r_q_count <= r_q_count + 1'b1;
        2'b01: r_q_count <= r_q_count - 1'b1;
        default: r_q_count <= r_q_count;
      endcase

      if(r_trans_active && r_in_fire && (r_beats_sent + 1'b1 == r_beats_total)) begin
        r_trans_active <= 1'b0;
      end
    end
  end

`else

  assign in_arready  = out_arready;
  assign out_arvalid = in_arvalid;
  assign out_arid    = in_arid;
  assign out_araddr  = in_araddr;
  assign out_arlen   = in_arlen;
  assign out_arsize  = in_arsize;
  assign out_arburst = in_arburst;
  assign out_rready  = in_rready;
  assign in_rvalid   = out_rvalid;
  assign in_rid      = out_rid;
  assign in_rdata    = out_rdata;
  assign in_rresp    = out_rresp;
  assign in_rlast    = out_rlast;
  assign in_awready  = out_awready;
  assign out_awvalid = in_awvalid;
  assign out_awid    = in_awid;
  assign out_awaddr  = in_awaddr;
  assign out_awlen   = in_awlen;
  assign out_awsize  = in_awsize;
  assign out_awburst = in_awburst;
  assign in_wready   = out_wready;
  assign out_wvalid  = in_wvalid;
  assign out_wdata   = in_wdata;
  assign out_wstrb   = in_wstrb;
  assign out_wlast   = in_wlast;
  assign out_bready  = in_bready;
  assign in_bvalid   = out_bvalid;
  assign in_bid      = out_bid;
  assign in_bresp    = out_bresp;

`endif

endmodule
