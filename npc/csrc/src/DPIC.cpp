#include <stdio.h>
#include <stdint.h>
#include <time.h>
#include <assert.h>

#include "config.hpp"
#include "ftrace.hpp"

extern bool exit_flag;
extern uint8_t mem[];
extern uint8_t flash[];
extern uint8_t psram[];

void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);

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

    extern bool itrace_enable;
    if (itrace_enable) {
        printf("Inst to be exe:%s\n", buf);
    }
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

extern "C" int pmem_read(int raddr)
{
#ifdef MTRACE
    printf("Read: addr=0x%08x\n", raddr);
#endif
    // 串口相关
    if (raddr == 0x10000000)
    {
        printf("should not reach here\n");
        assert(0);
    }

    // RTC相关
    else if (raddr == 0x10000004 || raddr == 0x10000008)
    {
        printf("should not reach here\n");
        assert(0);
    }

    raddr = raddr - 0x20000000; // 内存映射地址转换
    // 总是读取地址为`raddr & ~0x3u`的4字节返回
    return *(uint32_t *)(mem + (raddr & ~0x3u));
}
extern "C" void pmem_write(int waddr, int wdata, uint8_t wmask)
{
#ifdef MTRACE
    printf("Write: addr=0x%08x, data=0x%08x, wmask=0x%02x\n", waddr, wdata, wmask);
#endif
    if (waddr == 0x10000000)
    {
        printf("should not reach here\n");
        assert(0);
    }

    // RTC相关
    else if (waddr == 0x10000004 || waddr == 0x10000008)
    {
        printf("should not reach here\n");
        assert(0);
    }

    waddr = waddr - 0x20000000; // 内存映射地址转换
    for (int i = 0; i < 4; i++)
    {
        if (wmask & (1 << i))
        {
            mem[(waddr & ~0x3u) + i] = (wdata >> (i << 3)) & 0xFF;
        }
    }
}


extern "C" void ftrace(int pc, int npc)
{
#ifdef FTRACE
    int inst = pmem_read(pc);
    ftrace_detect(inst, pc, npc);
#endif
}

extern "C" void flash_read(uint32_t addr, uint32_t *data) {
    *data = *(uint32_t *)(flash + (addr & ~0x3u));
}
extern "C" void mrom_read(uint32_t addr, uint32_t *data) {
    *data = pmem_read(addr);
}
extern "C" void psram_read(uint32_t addr, uint32_t *data) {
    *data = *(uint32_t *)(psram + (addr & ~0x3u));
}
extern "C" void psram_write(uint32_t addr, uint8_t data) {
    printf("PSRAM Write: addr=0x%08x, data=0x%02x\n", addr, data);
    *(psram + addr) = data;
}