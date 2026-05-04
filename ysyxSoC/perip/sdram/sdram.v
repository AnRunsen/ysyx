import "DPI-C" function void sdram_read(input byte bank, input int row_addr, input int col_addr, output shortint data);
import "DPI-C" function void sdram_write(input byte bank, input int row_addr, input int col_addr, input shortint data, input byte wmask);

module sdram(
  input        clk,
  input        cke,
  input        cs,
  input        ras,
  input        cas,
  input        we,
  input [12:0] a,
  input [ 1:0] ba,
  input [ 1:0] dqm,
  inout [15:0] dq
);

  wire [3:0] cmd = {cs, ras, cas, we};
  reg [12:0] row_addr [3:0];
  reg [12:0] mode_reg;
  reg [ 1:0] bank_sel;
  reg [8:0] col_addr;
  wire [2:0] CL = mode_reg[6:4];
  wire [2:0] BL = mode_reg[2:0];

  localparam IDLE = 2'd0, READ = 2'd1, WAIT = 2'd2;
  reg [1:0] state, next_state;

  reg [2:0] burst_cnt;
  always @(posedge clk) begin
    if(cke) begin
      if(state == READ) begin
        burst_cnt <= burst_cnt + 3'd1;
      end else begin
        burst_cnt <= 0;
      end
    end
  end

  always @(*) begin
    case(state)
      IDLE: begin
        next_state = (cmd == 4'b0101) ? (CL == 3'd2 ? READ : WAIT) : IDLE;
      end

      READ: begin
        next_state = (burst_cnt == BL) ? IDLE : READ;
      end

      WAIT: begin
        next_state = READ;
      end

      default: begin
        next_state = IDLE;
      end
    endcase
  end

  always @(posedge clk) begin
    if(cke) begin
      state <= next_state;
    end
  end

  reg [15:0] read_data;
  wire [8:0] burst_addr = col_addr + {6'b0, burst_cnt};
  always @(posedge clk) begin
    if(cke) begin
      if(state == READ && burst_cnt < BL) begin
        sdram_read({6'b0, bank_sel}, {19'b0, row_addr[bank_sel]}, {23'b0, burst_addr}, read_data);
      end
    end
  end

  wire o_en = (state == READ) && (burst_cnt > 0);

  always @(posedge clk) begin
    if(cke) begin
      case(cmd)
        4'b0000: begin // LOAD_MODE
          mode_reg <= a;
        end
        4'b0011: begin // ACTIVE
          row_addr[ba] <= a;
        end
        4'b0101: begin // READ
          col_addr <= a[8:0];
          bank_sel <= ba;
        end
        4'b0100: begin // WRITE
          sdram_write({6'b0, ba}, {19'b0, row_addr[ba]}, {23'b0, col_addr[8:0]}, dq, {6'b0, dqm});
        end
        default: begin
          // nop
        end
      endcase
    end
  end


  assign dq = o_en ? read_data : 16'bz;

endmodule
