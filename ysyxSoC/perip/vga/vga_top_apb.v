import "DPI-C" function void vga_write(input int addr, input int color, input byte strb);
import "DPI-C" function void vga_read(input int x, input int y, output int color);

module vga_top_apb(
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

  output [7:0]  vga_r,
  output [7:0]  vga_g,
  output [7:0]  vga_b,
  output        vga_hsync,
  output        vga_vsync,
  output        vga_valid
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

  /*The Vbuf is Write Only*/
  always @(posedge clock) begin
    if(state == WORKING && write_reg && in_penable && !pready_reg) begin
      vga_write(addr_reg, wdata_reg, {4'b0, strb_reg});
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

  parameter h_frontporch = 96;
  parameter h_active = 144;
  parameter h_backporch = 784;
  parameter h_total = 800;

  parameter v_frontporch = 2;
  parameter v_active = 35;
  parameter v_backporch = 515;
  parameter v_total = 525;

  reg [9:0] x_cnt;
  reg [9:0] y_cnt;
  wire h_valid;
  wire v_valid;
  wire [9:0] h_addr;
  wire [9:0] v_addr;

  always @(posedge clock) begin
      if(reset == 1'b1) begin
          x_cnt <= 1;
          y_cnt <= 1;
      end
      else begin
          if(x_cnt == h_total)begin
              x_cnt <= 1;
              if(y_cnt == v_total) y_cnt <= 1;
              else y_cnt <= y_cnt + 1;
          end
          else x_cnt <= x_cnt + 1;
      end
  end

  reg [31:0] color;
  always @(*) begin
    vga_read({22'b0, h_addr}, {22'b0, v_addr}, color);
  end

  //生成同步信号    
  assign vga_hsync = (x_cnt > h_frontporch);
  assign vga_vsync = (y_cnt > v_frontporch);
  //生成消隐信号
  assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
  assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
  assign vga_valid = h_valid & v_valid;
  //计算当前有效像素坐标
  assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
  assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;
  //设置输出的颜色值
  assign vga_r = color[23:16];
  assign vga_g = color[15:8];
  assign vga_b = color[7:0];

  assign in_pready = pready_reg;
  assign in_prdata = 32'b0;
  assign in_pslverr = 1'b0;

endmodule
