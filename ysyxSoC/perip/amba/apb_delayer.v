`define DELAYER_ENABLE
module apb_delayer(
  input         clock,
  input         reset,
  input  [31:0] in_paddr,
  input         in_psel,
  input         in_penable,
  input  [2:0]  in_pprot,
  input         in_pwrite,
  input  [31:0] in_pwdata,
  input  [3:0]  in_pstrb,
  output        in_pready,
  output [31:0] in_prdata,
  output        in_pslverr,

  output [31:0] out_paddr,
  output        out_psel,
  output        out_penable,
  output [2:0]  out_pprot,
  output        out_pwrite,
  output [31:0] out_pwdata,
  output [3:0]  out_pstrb,
  input         out_pready,
  input  [31:0] out_prdata,
  input         out_pslverr
);

`ifdef DELAYER_ENABLE

  localparam DELAY_RATE = 8;
  reg [31:0] delay_cnt;
  reg        delay_flag;

  always @(posedge clock) begin
    if (reset) begin
      delay_flag <= 1'b0;
    end
    else if (out_pready && out_penable) begin
      delay_flag <= 1'b1;
    end
    else if (in_pready && in_penable) begin
      delay_flag <= 1'b0;
    end
  end

  always @(posedge clock) begin
    if(reset) begin
      delay_cnt <= 32'b0;
    end
    else begin
      if(out_penable) begin
        delay_cnt <= delay_cnt + (DELAY_RATE - 1);
      end

      else if(delay_flag) begin
        delay_cnt <= delay_cnt - 1;
      end

      else begin
        delay_cnt <= 32'b0;
      end
    end
  end

  assign out_paddr   = in_paddr;
  assign out_psel    = in_psel && (!delay_flag);
  assign out_penable = in_penable && (!delay_flag);
  assign out_pprot   = in_pprot;
  assign out_pwrite  = in_pwrite;
  assign out_pwdata  = in_pwdata;
  assign out_pstrb   = in_pstrb;
  assign in_pready   = (delay_cnt == 0);
  assign in_prdata   = out_prdata;
  assign in_pslverr  = out_pslverr;

`else

  assign out_paddr   = in_paddr;
  assign out_psel    = in_psel;
  assign out_penable = in_penable;
  assign out_pprot   = in_pprot;
  assign out_pwrite  = in_pwrite;
  assign out_pwdata  = in_pwdata;
  assign out_pstrb   = in_pstrb;
  assign in_pready   = out_pready;
  assign in_prdata   = out_prdata;
  assign in_pslverr  = out_pslverr;

`endif

endmodule
