package PKG;
    import "DPI-C" function void sim_exit();
    import "DPI-C" function void itrace(input int inst, input int pc);
    import "DPI-C" function void ftrace(input int pc, input int npc);
    import "DPI-C" function void uart_write(input int waddr, input int wdata, input byte wmask);
    import "DPI-C" function int mtime_read(input int raddr);
    import "DPI-C" function void perf_cnt_update(input byte target);
    import "DPI-C" function void flush_num();
    import "DPI-C" function void enter_userapp(input int npc);
endpackage
