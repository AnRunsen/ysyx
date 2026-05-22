module RAW(
    input [4:0] rs1,
    input [4:0] rs2,
    input need_rs2,
    input [11:0] csr_addr,

    input [4:0] rd_exu,
    input [11:0] csr_exu,
    input rd_valid_exu,
    input csr_valid_exu,
    input [4:0] rd_lsu,
    input [11:0] csr_lsu,
    input rd_valid_lsu,
    input csr_valid_lsu,
    input [4:0] rd_wbu,
    input [11:0] csr_wbu,
    input rd_valid_wbu,
    input csr_valid_wbu,
    
    output stall
);

    assign stall =  (rd_valid_exu && (rd_exu != 0) && (rd_exu == rs1 || (need_rs2 && rd_exu == rs2))) ||
                    (rd_valid_lsu && (rd_lsu != 0) && (rd_lsu == rs1 || (need_rs2 && rd_lsu == rs2))) ||
                    (rd_valid_wbu && (rd_wbu != 0) && (rd_wbu == rs1 || (need_rs2 && rd_wbu == rs2))) ||
                    (csr_valid_exu && (csr_exu == csr_addr)) ||
                    (csr_valid_lsu && (csr_lsu == csr_addr)) ||
                    (csr_valid_wbu && (csr_wbu == csr_addr));

endmodule
