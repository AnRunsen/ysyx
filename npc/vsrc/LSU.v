`include "MACRO.v"

module LSU(
    /*explict ports*/
    input mem_write_en,
    input [1:0] op_width,
    input sign_ext_en,
    input [31:0] addr,
    input [31:0] wdata,
    output [31:0] rdata,

    /*implict ports for RAM*/
    output [31:0] addr_,
    output [31:0] wdata_,
    input [31:0] rdata_,
    output [1:0] op_width_,
    output mem_write_en_
);


    assign addr_ = addr;
    assign wdata_ = wdata;
    assign op_width_ = op_width;
    assign mem_write_en_ = mem_write_en;

    /*load logic*/
    wire [31:0] rdata_ext;

    assign rdata_ext = (op_width == `OP_WIDTH_BYTE) ? {{24{sign_ext_en & rdata_[7]}}, rdata_[7:0]} :
                       (op_width == `OP_WIDTH_HALF) ? {{16{sign_ext_en & rdata_[15]}}, rdata_[15:0]} :
                       rdata_;

    assign rdata = rdata_ext;

    /*store logic*/
    //we sim it in c++

endmodule
