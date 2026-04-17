package PKG;

    import "DPI-C" function int pmem_read(input int raddr);
    import "DPI-C" function void pmem_write(
        input int waddr, input int wdata, input byte wmask
    );
    import "DPI-C" function void sim_exit(input int code);
    import "DPI-C" function void itrace(input int inst, input int pc);
    import "DPI-C" function void ftrace(input int pc, input int npc);

endpackage
