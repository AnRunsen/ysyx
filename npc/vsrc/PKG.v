package PKG;

    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(
        input int waddr, input int wdata, input byte wmask
    );
    import "DPI-C" function void sim_exit();

endpackage
