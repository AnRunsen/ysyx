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

extern "C" void ftrace(int pc, int npc)
{
#ifdef FTRACE
    int inst = sdram_read_laddr(pc);
    ftrace_detect(inst, pc, npc);
#endif
}

extern "C" void itrace(int inst, int pc)
{
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
    // printf("sdram read: bank=%d, row_addr=0x%08x, col_addr=0x%08x, data=0x%04x\n", bank, row_addr, col_addr, *data);
}

extern "C" void sdram_write(uint8_t bank, uint32_t row_addr, uint32_t col_addr, uint16_t data, uint8_t wmask) {
    // printf("sdram write: bank=%d, row_addr=0x%08x, col_addr=0x%08x, data=0x%04x, wmask=0x%02x\n", bank, row_addr, col_addr, data, wmask);
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
        if (~strb & 0x1) *(vbuf + addr) = color & 0xFF;
        if (~strb & 0x2) *(vbuf + addr + 1) = (color >> 8) & 0xFF;
        if (~strb & 0x4) *(vbuf + addr + 2) = (color >> 16) & 0xFF;
        if (~strb & 0x8) *(vbuf + addr + 3) = (color >> 24) & 0xFF;
    } else assert(0);
}

extern "C" void vga_read(uint32_t x, uint32_t y, uint32_t *color) {
    uint32_t addr = (y * 640 + x) * 4;
    if (x < 640 && y < 480) *color = *(uint32_t *)(vbuf + addr);
    else assert(0);
    printf("vga read: x=%d, y=%d, color=0x%08x\n", x, y, *color);
}
