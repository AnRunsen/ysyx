module gpio_top_apb(
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

	output [15:0] gpio_out,
	input  [15:0] gpio_in,
	output [7:0]  gpio_seg_0,
	output [7:0]  gpio_seg_1,
	output [7:0]  gpio_seg_2,
	output [7:0]  gpio_seg_3,
	output [7:0]  gpio_seg_4,
	output [7:0]  gpio_seg_5,
	output [7:0]  gpio_seg_6,
	output [7:0]  gpio_seg_7
);

  /*The FSM Logic*/
  localparam IDEL = 1'b0, WORKING = 1'b1;
  reg state, next_state;

  always @(*) begin
    case(state)
      IDEL: begin
        if(in_psel) next_state = WORKING;
        else next_state = IDEL;
      end
      WORKING: begin
        if(in_penable && in_pready) next_state = IDEL;
        else next_state = WORKING;
      end
      default: next_state = IDEL;
    endcase
  end

  always @(posedge clock) begin
    if(reset) begin
      state <= IDEL;
    end
    else begin
      state <= next_state;
    end
  end


  /*DATA Latch Logic For Low Power*/
	reg [31:0] addr_reg;
	reg        write_reg;
	reg [31:0] wdata_reg;
	reg [3:0] strb_reg;

  always @(posedge clock) begin
    if(reset) begin
      addr_reg <= 32'b0;
      write_reg <= 1'b0;
      wdata_reg <= 32'b0;
      strb_reg <= 4'b0;
    end
    else if(in_psel && !in_penable) begin
      addr_reg <= in_paddr;
      write_reg <= in_pwrite;
      wdata_reg <= in_pwdata;
      strb_reg <= in_pstrb;
    end
  end


  /*Main logic for reg access*/
  reg [15:0] gpio_led;  //0x0 RW
  reg [15:0] gpio_switch; //0x4 RO
  reg [31:0] gpio_seg; //0x8 RW

  reg [31:0] rdata_reg;

  always @(posedge clock) begin
    if(reset) begin
      gpio_led <= 16'b0;
      gpio_switch <= 16'b0;
      gpio_seg <= 32'b0;
    end
    else if(state == WORKING && write_reg && in_penable && !pready_reg) begin
      case(addr_reg[3:0])
        4'h0: begin
          if(strb_reg[0]) gpio_led[7:0] <= wdata_reg[7:0];
          if(strb_reg[1]) gpio_led[15:8] <= wdata_reg[15:8];
        end
        4'h8: begin
          if(strb_reg[0]) gpio_seg[7:0] <= wdata_reg[7:0];
          if(strb_reg[1]) gpio_seg[15:8] <= wdata_reg[15:8];
          if(strb_reg[2]) gpio_seg[23:16] <= wdata_reg[23:16];
          if(strb_reg[3]) gpio_seg[31:24] <= wdata_reg[31:24];
        end
        default: ;
      endcase
    end
    else if(state == WORKING && !write_reg && in_penable && !pready_reg) begin
      case(addr_reg[3:0])
        4'h0: rdata_reg <= {16'b0, gpio_led};
        4'h4: rdata_reg <= {16'b0, gpio_switch};
        4'h8: rdata_reg <= gpio_seg;
        default: ;
      endcase
    end
  end

  reg pready_reg;
  always @(posedge clock) begin
    if(reset) begin
      pready_reg <= 1'b0;
    end

    else if(in_penable && pready_reg) begin
      pready_reg <= 1'b0;
    end  

    else if(in_penable) begin
      pready_reg <= 1'b1;
    end
  end

  /*Logic to get the switch*/
  always @(posedge clock) begin
    if(reset) begin
      gpio_switch <= 16'b0;
    end
    else begin
      gpio_switch <= gpio_in;
    end
  end

  assign in_pready = pready_reg;
  assign in_prdata = rdata_reg;
  assign in_pslverr = 1'b0;

  assign gpio_out = gpio_led;

  function [7:0] seg_out;
    input [3:0] num;
    case(num)
      4'h0: seg_out = ~8'b11111100;
      4'h1: seg_out = ~8'b01100000;
      4'h2: seg_out = ~8'b11011010;
      4'h3: seg_out = ~8'b11110010;
      4'h4: seg_out = ~8'b01100110;
      4'h5: seg_out = ~8'b10110110;
      4'h6: seg_out = ~8'b10111110;
      4'h7: seg_out = ~8'b11100000;
      4'h8: seg_out = ~8'b11111110;
      4'h9: seg_out = ~8'b11110110;
      4'ha: seg_out = ~8'b11101110;
      4'hb: seg_out = ~8'b00111110;
      4'hc: seg_out = ~8'b10011100;
      4'hd: seg_out = ~8'b01111010;
      4'he: seg_out = ~8'b10011110;
      4'hf: seg_out = ~8'b10001110;
      default: seg_out = ~8'b00000000; // off
    endcase
  endfunction

  assign gpio_seg_0 = seg_out(gpio_seg[3:0]);
  assign gpio_seg_1 = seg_out(gpio_seg[7:4]);
  assign gpio_seg_2 = seg_out(gpio_seg[11:8]);
  assign gpio_seg_3 = seg_out(gpio_seg[15:12]);
  assign gpio_seg_4 = seg_out(gpio_seg[19:16]);
  assign gpio_seg_5 = seg_out(gpio_seg[23:20]);
  assign gpio_seg_6 = seg_out(gpio_seg[27:24]);
  assign gpio_seg_7 = seg_out(gpio_seg[31:28]);

endmodule
