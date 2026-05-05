module ps2_top_apb(
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

  input         ps2_clk,
  input         ps2_data
);

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

  reg [31:0] rdata_reg;
  always @(posedge clock) begin
    if(reset) begin
      rdata_reg <= 32'b0;
    end
    else if(state == WORKING && in_penable && !in_pwrite && !in_pready) begin
      if(addr_reg[1:0] == 2'b00) rdata_reg <= ready ? {24'b0, data} : 32'b0;
      else rdata_reg <= 32'b0;
    end
  end


  reg pready_reg;
  always @(posedge clock) begin
    if(reset) begin
      pready_reg <= 1'b0;
    end

    else if(in_penable && in_pready) begin
      pready_reg <= 1'b0;
    end  

    else if(in_penable) begin
      pready_reg <= 1'b1;
    end
  end

  wire [7:0] data;
  wire nextdata_n = (state == WORKING && in_penable && !in_pwrite && !in_pready);
  reg ready;
  reg overflow;     // fifo overflow
  // internal signal, for test
  reg [9:0] buffer;        // ps2_data bits
  reg [7:0] fifo[7:0];     // data fifo
  reg [2:0] w_ptr,r_ptr;   // fifo write and read pointers
  reg [3:0] count;  // count ps2_data bits
  // detect falling edge of ps2_clk
  reg [2:0] ps2_clk_sync;

  always @(posedge clock) begin
      ps2_clk_sync <=  {ps2_clk_sync[1:0],ps2_clk};
  end

  wire sampling = ps2_clk_sync[2] & ~ps2_clk_sync[1];

  always @(posedge clock) begin
      if (reset) begin // reset
          count <= 0; w_ptr <= 0; r_ptr <= 0; overflow <= 0; ready<= 0;
      end
      else begin
          if ( ready ) begin // read to output next data
              if(nextdata_n == 1'b0) //read next data
              begin
                  r_ptr <= r_ptr + 3'b1;
                  if(w_ptr==(r_ptr+1'b1)) //empty
                      ready <= 1'b0;
              end
          end
          if (sampling) begin
            if (count == 4'd10) begin
              if ((buffer[0] == 0) &&  // start bit
                  (ps2_data)       &&  // stop bit
                  (^buffer[9:1])) begin      // odd  parity
                  fifo[w_ptr] <= buffer[8:1];  // kbd scan code
                  w_ptr <= w_ptr+3'b1;
                  ready <= 1'b1;
                  overflow <= overflow | (r_ptr == (w_ptr + 3'b1));
              end
              count <= 0;     // for next
            end
            else begin
              buffer[count] <= ps2_data;  // store ps2_data
              count <= count + 3'b1;
            end
          end
      end
  end
  assign data = fifo[r_ptr]; //always set output data

  assign in_prdata = rdata_reg;
  assign in_pready = pready_reg;
  assign in_pslverr = 1'b0;

endmodule
