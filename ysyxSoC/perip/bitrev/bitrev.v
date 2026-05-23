module bitrev (
  input  sck,
  input  ss,
  input  mosi,
  output miso
);


reg [7:0] data_recv;
reg [2:0] bit_cnt;
reg recv;

always @(posedge sck or posedge ss) begin
  if(ss) begin
    data_recv <= 8'd0;
  end
  
  else begin
    if(recv) begin
      data_recv <= {data_recv[6:0], mosi};
    end

    else begin
      data_recv <= {1'b0, data_recv[7:1]};
    end
  end
end

always @(posedge sck or posedge ss) begin
  if(ss) begin
    bit_cnt <= 3'd0;
    recv <= 1'b1;
  end

  else begin
    if(bit_cnt == 3'd7) begin
      bit_cnt <= 3'd0;
      recv <= ~recv;
    end

    else begin
      bit_cnt <= bit_cnt + 1'b1;
    end
  end
end

assign miso = (recv) ? 1'b1 : data_recv[0];
endmodule
