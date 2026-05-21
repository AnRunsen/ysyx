module RAW(
    input [4:0] rs1,
    input [4:0] rs2,
    input need_rs2,
    input working_idu,
    input [4:0] rd_exu,
    input working_exu,
    input [4:0] rd_lsu,
    input working_lsu,
    input [4:0] rd_wbu,
    input working_wbu,
    output stall
);

    assign stall = working_idu && ((working_exu && (rd_exu != 0) && (rd_exu == rs1 || (need_rs2 && rd_exu == rs2))) ||
                   (working_lsu && (rd_lsu != 0) && (rd_lsu == rs1 || (need_rs2 && rd_lsu == rs2))) ||
                   (working_wbu && (rd_wbu != 0) && (rd_wbu == rs1 || (need_rs2 && rd_wbu == rs2))));

endmodule
