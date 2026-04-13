module IFU(
    input [31:0] PC,
    output [31:0] Inst,

    /*We sim the RAM with c++. Below is the c++ port*/
    output [31:0] RAM_addr,
    input [31:0] RAM_data
);

    assign RAM_addr = PC;
    assign Inst = RAM_data;

endmodule
