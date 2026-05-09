#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>

#include "config.hpp"
#include "ftrace.hpp"

extern bool exit_flag;
extern uint8_t mrom[0x8000000];
extern uint8_t flash[0x1000000];
extern uint8_t psram[0x1000000];
extern uint16_t sdram[4][8192][512];
extern uint8_t vbuf[640*480*4];
extern uint64_t cycle_cnt;
extern uint64_t instr_cnt;
extern uint64_t ihit_cnt;

typedef struct {
    uint64_t ifu;
    uint64_t idu;
    uint64_t exu;
    uint64_t lsu;
} performance_cnt;

performance_cnt perf_cnt;

enum { BRANCH=0, JAL, JALR, LUI, AUIPC, OP, OP_IMM, LOAD, STORE, SYSTEM };
uint8_t inst_type = -1;
enum { IFU, IDU, EXU, LSU, WBU };
uint8_t stage = -1;

typedef struct {
    uint64_t branch;
    uint64_t jal;
    uint64_t jalr;
    uint64_t lui;
    uint64_t auipc;
    uint64_t op;
    uint64_t op_imm;
    uint64_t load;
    uint64_t store;
    uint64_t system;
} instr_type_cnt;

instr_type_cnt itype_cnt;

typedef struct {
    uint64_t clk_branch;
    uint64_t clk_jal;
    uint64_t clk_jalr;
    uint64_t clk_lui;
    uint64_t clk_auipc;
    uint64_t clk_op;
    uint64_t clk_op_imm;
    uint64_t clk_load;
    uint64_t clk_store;
    uint64_t clk_system;
} instr_clk_cnt;

instr_clk_cnt itype_clk_cnt;

typedef struct {
    uint64_t clk_ifu;
    uint64_t clk_idu;
    uint64_t clk_exu;
    uint64_t clk_lsu;
    uint64_t clk_wbu;
} stage_clk_cnt;

stage_clk_cnt stclk_cnt;

void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

uint32_t sdram_read_laddr(uint32_t addr){
    addr &= ~0x3u;

    uint32_t row_addr = (addr >> 12) & 0x1fffu;
    uint32_t bank = (addr >> 10) & 0x3u;
    uint32_t col_addr = ((addr >> 1) & 0x1ffu);

    uint32_t low = sdram[bank][row_addr][col_addr];
    uint32_t high = sdram[bank][row_addr][col_addr + 1];
    return low | (high << 16);
}

void sdram_write_laddr(uint32_t addr, uint16_t data) {
    uint32_t row_addr = (addr >> 12) & 0x1fffu;
    uint32_t bank = (addr >> 10) & 0x3u;
    uint32_t col_addr = ((addr >> 1) & 0x1ffu);

    sdram[bank][row_addr][col_addr] = data;
    // printf("sdram write: addr=0x%08x, bank=%d, row_addr=0x%08x, col_addr=0x%08x, data=0x%04x\n", addr, bank, row_addr, col_addr, data);
}

extern "C" void ihit_num()
{
    ihit_cnt++;
}

extern "C" void stage_update(uint8_t target) {
    switch (target) {
        case 0: stage = IFU;
        break;
        case 1: stage = IDU;
        break;
        case 2: stage = EXU;
        break;
        case 3: stage = LSU;
        break;
        case 4: stage = WBU;
        break;
    }
}

extern "C" void itype_cnt_update(uint8_t target) {
    switch (target) {
        case 0: itype_cnt.branch++; inst_type = BRANCH;
        break;
        case 1: itype_cnt.jal++; inst_type = JAL;
        break;
        case 2: itype_cnt.jalr++; inst_type = JALR;
        break;
        case 3: itype_cnt.lui++; inst_type = LUI;
        break;
        case 4: itype_cnt.auipc++; inst_type = AUIPC;
        break;
        case 5: itype_cnt.op++; inst_type = OP;
        break;
        case 6: itype_cnt.op_imm++; inst_type = OP_IMM;
        break;
        case 7: itype_cnt.load++; inst_type = LOAD;
        break;
        case 8: itype_cnt.store++; inst_type = STORE;
        break;
        case 9: itype_cnt.system++; inst_type = SYSTEM;
        break;
    }
}

extern "C" void perf_cnt_update(uint8_t target) {
    switch (target) {
        case 0: perf_cnt.ifu++;
        break;
        case 1: perf_cnt.idu++;
        break;
        case 2: perf_cnt.exu++;
        break;
        case 3: perf_cnt.lsu++;
        break;
    }
}

extern "C" void ftrace(int pc, int npc)
{
#ifdef FTRACE
    int inst = sdram_read_laddr(pc);
    ftrace_detect(inst, pc, npc);
#endif
}

extern "C" void itrace(int inst, int pc)
{
    instr_cnt ++;
#ifdef ITRACE
    char buf[128];
    char *p = buf;
    p += snprintf(p, sizeof(buf), "%08x:", pc);
    int ilen = 4;
    uint8_t *instp = (uint8_t *)&inst;
    for (int i = ilen - 1; i >= 0; i--)
    {
        p += snprintf(p, 4, " %02x", instp[i]);
    }

    *(p++) = ' ';

    disassemble(p, sizeof(buf) - (p - buf), pc, instp, ilen);

    printf("Inst to be exe:%s\n", buf);
#endif
}

extern "C" int mtime_read(int raddr)
{
    if (raddr == 0x02000004 || raddr == 0x02000008)
    {
        if (raddr == 0x02000004)
        {
            // 0x02000004是一个特殊的地址, 读取这里会返回当前时间的低32位
            return (uint32_t)(clock());
        }
        else
        {
            // 0x02000008是一个特殊的地址, 读取这里会返回当前时间的高32位
            return (uint32_t)(clock() >> 32);
        }
    }

    else
    {
        printf("\033[31;1mUnknown MTIME Read: addr=0x%08x\033[0m\n", raddr);
        assert(0);
    }
}
extern "C" void uart_write(int waddr, int wdata, uint8_t wmask)
{
    if (waddr == 0x10000000)
    {
        putchar(wdata & 0xFF);
        fflush(stdout);
    }

    else
    {
        printf("\033[31;1mUnknown UART Write: addr=0x%08x, data=0x%08x, wmask=0x%02x\033[0m\n", waddr, wdata, wmask);
        assert(0);
    }

    return;
}


extern "C" void sim_exit(int code)
{
    printf("\033[34mTotal Cycles: \t\t%lu\n", cycle_cnt);
    printf("Total Instructions: \t%lu\n", instr_cnt);
    printf("IPC: \t\t\t%f\n", (double)instr_cnt / (double)cycle_cnt);
    printf("============================\n");
    printf("Instructions of each type:\n");
    printf("  Type\t\tCount\tPercentage\tClocks\tIPC\n");
    printf("  BRANCH: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.branch, (double)itype_cnt.branch / (double)instr_cnt * 100, itype_clk_cnt.clk_branch, (double)itype_cnt.branch / (double)itype_clk_cnt.clk_branch);
    printf("  JAL: \t\t%lu\t%f%%\t%lu\t%f\n", itype_cnt.jal, (double)itype_cnt.jal / (double)instr_cnt * 100, itype_clk_cnt.clk_jal, (double)itype_cnt.jal / (double)itype_clk_cnt.clk_jal);
    printf("  JALR: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.jalr, (double)itype_cnt.jalr / (double)instr_cnt * 100, itype_clk_cnt.clk_jalr, (double)itype_cnt.jalr / (double)itype_clk_cnt.clk_jalr);
    printf("  LUI: \t\t%lu\t%f%%\t%lu\t%f\n", itype_cnt.lui, (double)itype_cnt.lui / (double)instr_cnt * 100, itype_clk_cnt.clk_lui, (double)itype_cnt.lui / (double)itype_clk_cnt.clk_lui);
    printf("  AUIPC: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.auipc, (double)itype_cnt.auipc / (double)instr_cnt * 100, itype_clk_cnt.clk_auipc, (double)itype_cnt.auipc / (double)itype_clk_cnt.clk_auipc);
    printf("  OP: \t\t%lu\t%f%%\t%lu\t%f\n", itype_cnt.op, (double)itype_cnt.op / (double)instr_cnt * 100, itype_clk_cnt.clk_op, (double)itype_cnt.op / (double)itype_clk_cnt.clk_op);
    printf("  OP-IMM: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.op_imm, (double)itype_cnt.op_imm / (double)instr_cnt * 100, itype_clk_cnt.clk_op_imm, (double)itype_cnt.op_imm / (double)itype_clk_cnt.clk_op_imm);
    printf("  LOAD: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.load, (double)itype_cnt.load / (double)instr_cnt * 100, itype_clk_cnt.clk_load, (double)itype_cnt.load / (double)itype_clk_cnt.clk_load);
    printf("  STORE: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.store, (double)itype_cnt.store / (double)instr_cnt * 100, itype_clk_cnt.clk_store, (double)itype_cnt.store / (double)itype_clk_cnt.clk_store);
    printf("  SYSTEM: \t%lu\t%f%%\t%lu\t%f\n", itype_cnt.system, (double)itype_cnt.system / (double)instr_cnt * 100, itype_clk_cnt.clk_system, (double)itype_cnt.system / (double)itype_clk_cnt.clk_system);
    printf("============================\n");
    printf("Clocks of each stage:\n");
    printf("  Stage\t\tClocks\tPercentage\n");
    printf("  IFU: \t\t%lu\t%f%%\n", stclk_cnt.clk_ifu, (double)stclk_cnt.clk_ifu / (double)cycle_cnt * 100);
    printf("  IDU: \t\t%lu\t%f%%\n", stclk_cnt.clk_idu, (double)stclk_cnt.clk_idu / (double)cycle_cnt * 100);
    printf("  EXU: \t\t%lu\t%f%%\n", stclk_cnt.clk_exu, (double)stclk_cnt.clk_exu / (double)cycle_cnt * 100);
    printf("  LSU: \t\t%lu\t%f%%\n", stclk_cnt.clk_lsu, (double)stclk_cnt.clk_lsu / (double)cycle_cnt * 100);
    printf("  WBU: \t\t%lu\t%f%%\n", stclk_cnt.clk_wbu, (double)stclk_cnt.clk_wbu / (double)cycle_cnt * 100);
    printf("============================\n");
    printf("Performance Counters:\n");
    printf("  IFU: \t%lu\n", perf_cnt.ifu);
    printf("  IDU: \t%lu\n", perf_cnt.idu);
    printf("  EXU: \t%lu\n", perf_cnt.exu);
    printf("  LSU: \t%lu\n", perf_cnt.lsu);
    printf("============================\n");
    printf("  Num of iCache hit: %lu\t%f%%\033[0m\n", ihit_cnt, (double)ihit_cnt / (double)instr_cnt * 100);

    if (code == 0)
    {
        printf("Code:%d \033[32;1mHit Good Trap\033[0m\n", code);
    }
    else if (code == 1)
    {
        printf("Code:%d \033[31;1mHit Bad Trap\033[0m\n", code);
    }

    else
    {
        printf("\033[31;1mUnknown Opcode:%08x\033[0m\n", code);
    }
    exit_flag = true;
}

extern "C" void flash_read(uint32_t addr, uint32_t *data) {
    *data = *(uint32_t *)(flash + (addr & ~0x3u));
    // printf("flash read: addr=0x%08x, data=0x%08x\n", addr, *data);
}
extern "C" void mrom_read(uint32_t addr, uint32_t *data) {
    addr = addr - 0x20000000;
    *data = *(uint32_t *)(mrom + (addr & ~0x3u));
}

extern "C" void psram_read(uint32_t addr, uint32_t *data) {
    *data = *(uint32_t *)(psram + (addr & ~0x3u));
    // printf("psram read: addr=0x%08x, data=0x%08x\n", addr, *data);
}

extern "C" void psram_write(uint32_t addr, uint8_t data) {
    *(psram + addr) = data;
    // printf("psram write: addr=0x%08x, data=0x%08x\n", addr, data);
}

extern "C" void sdram_read(uint8_t bank, uint32_t row_addr, uint32_t col_addr, uint16_t *data) {
    *data = sdram[bank][row_addr][col_addr];

    uint32_t addr = (bank << 10) | (row_addr << 12) | (col_addr << 1);
    // printf("sdram read: addr = 0x%08x, bank=%d, row_addr=0x%08x, col_addr=0x%08x, data=0x%04x\n", addr, bank, row_addr, col_addr, *data);
}

extern "C" void sdram_write(uint8_t bank, uint32_t row_addr, uint32_t col_addr, uint16_t data, uint8_t wmask) {
    uint32_t addr = (bank << 10) | (row_addr << 12) | (col_addr << 1);
    // printf("sdram write: addr = 0x%08x, bank=%d, row_addr=0x%08x, col_addr=0x%08x, data=0x%04x, wmask=0x%02x\n", addr, bank, row_addr, col_addr, data, wmask);
    if (~wmask & 0x1) {
        sdram[bank][row_addr][col_addr] = (sdram[bank][row_addr][col_addr] & 0xFF00) | (data & 0x00FF);
    }
    if (~wmask & 0x2) {
        sdram[bank][row_addr][col_addr] = (sdram[bank][row_addr][col_addr] & 0x00FF) | (data & 0xFF00);
    }
}

extern "C" void vga_write(uint32_t addr, uint32_t color, uint8_t strb) {
    addr = addr & 0xFFFFFFu;
    if (addr < 640*480*4) {
        if (strb & 0x1) *(vbuf + addr) = color & 0xFF;
        if (strb & 0x2) *(vbuf + addr + 1) = (color >> 8) & 0xFF;
        if (strb & 0x4) *(vbuf + addr + 2) = (color >> 16) & 0xFF;
        if (strb & 0x8) *(vbuf + addr + 3) = (color >> 24) & 0xFF;
    } else assert(0);
}

extern "C" void vga_read(uint32_t x, uint32_t y, uint32_t *color) {
    uint32_t addr = (y * 640 + x) * 4;
    if (x < 640 && y < 480) *color = *(uint32_t *)(vbuf + addr);
    else assert(0);
}
