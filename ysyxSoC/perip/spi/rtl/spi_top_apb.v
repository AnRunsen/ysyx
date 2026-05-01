// define this macro to enable fast behavior simulation
// for flash by skipping SPI transfers
// `define FAST_FLASH

module spi_top_apb #(
  parameter flash_addr_start = 32'h30000000,
  parameter flash_addr_end   = 32'h3fffffff,
  parameter spi_ss_num       = 8
) (
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

  output                  spi_sck,
  output [spi_ss_num-1:0] spi_ss,
  output                  spi_mosi,
  input                   spi_miso,
  output                  spi_irq_out
);

`ifdef FAST_FLASH

wire [31:0] data;
parameter invalid_cmd = 8'h0;
flash_cmd flash_cmd_i(
  .clock(clock),
  .valid(in_psel && !in_penable),
  .cmd(in_pwrite ? invalid_cmd : 8'h03),
  .addr({8'b0, in_paddr[23:2], 2'b0}),
  .data(data)
);
assign spi_sck    = 1'b0;
assign spi_ss     = 8'b0;
assign spi_mosi   = 1'b1;
assign spi_irq_out= 1'b0;
assign in_pslverr = 1'b0;
assign in_pready  = in_penable && in_psel && !in_pwrite;
assign in_prdata  = data[31:0];

`else


localparam IDLE = 3'd0,
           SPI = 3'd1, 
           TX  = 3'd2, 
           DIV = 3'd3, 
           SS  = 3'd4, 
           CTRL = 3'd5,
           WAIT = 3'd6,
           READ = 3'd7;

reg [2:0] state;
reg [2:0] next_state;


always @(*) begin
  case(state)
    IDLE: begin
      if(in_psel && in_penable) begin
        if(in_paddr >= flash_addr_start && in_paddr <= flash_addr_end) begin
          assert(!in_pwrite);
          next_state = TX;
        end
        else next_state = SPI;
      end
      else next_state = IDLE;
    end
    SPI:begin
      if(pready) next_state = IDLE;
      else next_state = SPI;
    end
    TX:begin
      if(pready) next_state = DIV;
      else next_state = TX;
    end
    DIV:begin
      if(pready) next_state = SS;
      else next_state = DIV;
    end
    SS:begin
      if(pready) next_state = CTRL;
      else next_state = SS;
    end
    CTRL:begin
      if(pready) next_state = WAIT;
      else next_state = CTRL;
    end
    WAIT:begin
      if(pready & (~prdata[8])) next_state = READ;
      else next_state = WAIT;
    end
    READ:begin
      if(pready) next_state = IDLE;
      else next_state = READ;
    end
    default: next_state = IDLE;
  endcase
end

always @(posedge clock or posedge reset) begin
  if(reset) state <= IDLE;
  else state <= next_state;
end


reg [31:0] paddr;
wire psel;
reg penable;
reg pwrite;
reg [31:0] pwdata;
wire [3:0] pstrb;
wire [31:0] prdata;
wire pready;
wire pslverr;

assign pstrb = 4'b1111;

/*combination logic for pwrite*/
always @(*) begin
  case(state)
    SPI: pwrite = in_pwrite;
    WAIT: pwrite = 1'b0;
    READ: pwrite = 1'b0;
    default: pwrite = 1'b1;
  endcase
end

/*combination logic for pwdata*/
always @(*) begin
  case(state)
    SPI: pwdata = in_pwdata;
    TX: pwdata = {8'h03, in_paddr[23:0]};
    DIV: pwdata = 32'h0;
    SS: pwdata = 32'h1;
    CTRL: pwdata = 32'h2140;
    default: pwdata = 32'h0;
  endcase
end


/*combination logic for paddr*/
always @(*) begin
  case(state)
    SPI: paddr = in_paddr;
    TX: paddr = 32'h1000_1004;
    DIV: paddr = 32'h1000_1014;
    SS: paddr = 32'h1000_1018;
    CTRL: paddr = 32'h1000_1010;
    WAIT: paddr = 32'h1000_1010;
    READ: paddr = 32'h1000_1000;
    default: paddr = 32'h0;
  endcase
end

assign psel = (state != IDLE);

always @(posedge clock or posedge reset) begin
  if(reset) penable <= 1'b0;
  else begin
    if(pready) penable <= 1'b0;
    else if(psel) penable <= 1'b1;
  end
end

spi_top u0_spi_top (
  .wb_clk_i(clock),
  .wb_rst_i(reset),

  .wb_adr_i(paddr[4:0]),
  .wb_dat_i(pwdata),
  .wb_dat_o(prdata),//output
  .wb_sel_i(pstrb),
  .wb_we_i (pwrite),
  .wb_stb_i(psel),
  .wb_cyc_i(penable),
  .wb_ack_o(pready),//output
  .wb_err_o(pslverr),//output

  .wb_int_o(spi_irq_out),
  .ss_pad_o(spi_ss),
  .sclk_pad_o(spi_sck),
  .mosi_pad_o(spi_mosi),
  .miso_pad_i(spi_miso)
);

assign in_pready = (state == SPI || state == READ) && pready;
assign in_prdata = (state == READ) ? {prdata[7:0], prdata[15:8], prdata[23:16], prdata[31:24]} : prdata;
assign in_pslverr = pslverr;

`endif // FAST_FLASH

endmodule
