import "DPI-C" function void psram_read(input int addr, output int data);
import "DPI-C" function void psram_write(input int addr, input byte data);

module psram(
  input sck,
  input ce_n,
  inout [3:0] dio
);

  localparam CMD = 2'd0, ADDR = 2'd1, WAIT = 2'd2, DATA = 2'd3;
  reg [1:0] state, next_state;
  reg [7:0] count;
  always @(*) begin
    case(state)
      CMD: next_state = (count == 7) ? ADDR : CMD;
      ADDR: next_state = (count == 5) ? (cmd == 8'hEB ? WAIT : DATA) : ADDR;
      WAIT: next_state = (count == 5) ? DATA : WAIT;
      DATA: next_state = (count == 7) ? CMD : DATA;
      default: next_state = CMD;
    endcase
  end

  /*logic to recv cmd*/
  reg [7:0] cmd;
  always @(posedge sck or posedge ce_n) begin
    if (ce_n) begin
      cmd <= 8'b0;
    end
    else if (state == CMD) begin
      cmd <= {cmd[6:0], dio[0]};
    end
  end

  /*logic to recv addr*/
  reg [23:0] addr;
  always @(posedge sck or posedge ce_n) begin
    if (ce_n) begin
      addr <= 24'b0;
    end
    else if (state == ADDR) begin
      addr <= {addr[19:0], dio};
    end
  end

  /*logic to read data*/
  reg [31:0] data;
  always @(negedge sck or posedge ce_n) begin
    if (ce_n) begin
      data <= 32'b0;
    end
    else if (cmd == 8'hEB && state == WAIT && next_state == DATA) begin
      psram_read({8'b0, addr}, data);
    end
  end

  reg [3:0] dout;
  /*logic to send data*/
  always @(*) begin
    case(count)
      0: dout = data[7:4];
      1: dout = data[3:0];
      2: dout = data[15:12];
      3: dout = data[11:8];
      4: dout = data[23:20];
      5: dout = data[19:16];
      6: dout = data[31:28];
      7: dout = data[27:24];
      default: dout = 4'b0;
    endcase
  end

  reg byte_flag;
  always @(posedge sck or posedge ce_n) begin
    if (ce_n) begin
      byte_flag <= 1'b0;
    end
    else if (cmd == 8'h38 && state == DATA) begin
      byte_flag <= ~byte_flag;
    end
  end

  reg [3:0] buffer;
  always @(posedge sck or posedge ce_n) begin
    if(ce_n) begin
      buffer <= 4'b0;
    end
    else if (cmd == 8'h38 && state == DATA) begin
      buffer <= dio;
    end
  end

  wire [23:0] waddr = addr + {17'b0, count[7:1]};

  /*logic to write data*/
  always @(posedge sck) begin
    if (cmd == 8'h38 && state == DATA && byte_flag) begin
      psram_write({8'b0, waddr}, {buffer, dio});
    end
  end

  reg [7:0] cycle;
  always @(*) begin
    case(state)
      CMD: cycle = 8;
      ADDR: cycle = 6;
      WAIT: cycle = 6;
      DATA: cycle = 8;
      default: cycle = 8;
    endcase
  end

  always @(negedge sck or posedge ce_n) begin
    if (ce_n) begin
      state <= CMD;
    end
    else begin
      state <= next_state;
    end
  end

  always @(posedge sck or posedge ce_n) begin
    if (ce_n) begin
      count <= 8'b0;
    end
    else begin
      if (count == cycle) begin
        count <= 8'b0;
      end
      else begin
        count <= count + 1;
      end
    end
  end

  assign dio = (state == DATA && cmd == 8'hEB) ? dout : 4'bz;

endmodule
