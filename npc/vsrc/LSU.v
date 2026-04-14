`include "MACRO.v"

module LSU(
    input mem_write_en,
    input [1:0] op_width,
    input sign_ext_en,
    input [31:0] addr,
    input [31:0] wdata,
    output [31:0] rdata
);

    reg [31:0] rdata_;
    wire [31:0] wdata_ = wdata << (addr[1:0]<<3);

    always @(*) begin
        rdata_ = pmem_read(addr);
        if(mem_write_en) pmem_write(addr, wdata_, (op_width == `OP_WIDTH_BYTE) ? 8'b0000_0001 << addr[1:0] :
                                    (op_width == `OP_WIDTH_HALF) ? 8'b0000_0011 << addr[1:0] : 8'b0000_1111);
    end

    reg [7:0] data8;
    reg [15:0] data16;

    always @(*) begin
        case(addr[1:0])
            2'b00: data8 = rdata_[7:0];
            2'b01: data8 = rdata_[15:8];
            2'b10: data8 = rdata_[23:16];
            2'b11: data8 = rdata_[31:24];
        endcase
    end

    always @(*) begin
        case(addr[1])
            1'b0: data16 = rdata_[15:0];
            1'b1: data16 = rdata_[31:16];
        endcase
    end

    wire [31:0] rdata_ext8;
    wire [31:0] rdata_ext16;


    ext8 u_ext8(
        .data_i 	( data8  ),
        .sign   	( sign_ext_en    ),
        .data_o 	( rdata_ext8  )
    );

    ext16 u_ext16(
        .data_i 	( data16  ),
        .sign   	( sign_ext_en    ),
        .data_o 	( rdata_ext16  )
    );
    wire [31:0] rdata_ext;
    assign rdata_ext = (op_width == `OP_WIDTH_BYTE) ? rdata_ext8 :
                       (op_width == `OP_WIDTH_HALF) ? rdata_ext16 :
                       (op_width == `OP_WIDTH_WORD) ? rdata_ :
                       32'b0;

    assign rdata = rdata_ext;

    /*store logic*/
    //we sim it in c++

endmodule

module ext8(
    input [7:0] data_i,
    input sign,
    output [31:0] data_o
);

   assign data_o = sign ? {{24{data_i[7]}}, data_i} : {24'b0, data_i};
    
endmodule

module ext16(
    input [15:0] data_i,
    input sign,
    output [31:0] data_o
);

   assign data_o = sign ? {{16{data_i[15]}}, data_i} : {16'b0, data_i};
    
endmodule
