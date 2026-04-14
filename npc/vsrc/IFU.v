module IFU(
    input [31:0] PC,
    output [31:0] Inst,

    /*We sim the RAM with c++. Below is the c++ port*/
    output [31:0] RAM_raddr0,
    input [31:0] RAM_rdata0
);

    assign RAM_raddr0 = PC;
    assign Inst = RAM_rdata0;

endmodule
