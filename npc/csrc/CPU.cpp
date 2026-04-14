#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <assert.h>

#define CHECK_ADDR_READ(addr) \
    do { \
        if ((addr) < 0x80000000 || (addr) >= 0x88000000) { \
            printf("invalid address 0x%08x\n", (addr)); \
            exit_flag = false; \
            return 0; \
        } \
    } while(0)

#define CHECK_ADDR_WRITE(addr) \
    do { \
        if ((addr) < 0x80000000 || (addr) >= 0x88000000) { \
            printf("invalid address 0x%08x\n", (addr)); \
            exit_flag = false; \
            return ; \
        } \
    } while(0)

uint8_t mem[0x8000000]; // 128MB memory
bool exit_flag = false;


extern "C" void sim_exit() {
    exit_flag = true;
}

extern "C" int pmem_read(int raddr)
{
    printf("read from addr 0x%08x\n", raddr);
    CHECK_ADDR_READ(raddr);
    raddr = raddr - 0x80000000; // 内存映射地址转换
    
    // 总是读取地址为`raddr & ~0x3u`的4字节返回
    return *(uint32_t*)(mem + (raddr & ~0x3u));
}
extern "C" void pmem_write(int waddr, int wdata, uint8_t wmask)
{
    // 总是往地址为`waddr & ~0x3u`的4字节按写掩码`wmask`写入`wdata`
    // `wmask`中每比特表示`wdata`中1个字节的掩码,
    // 如`wmask = 0x3`代表只写入最低2个字节, 内存中的其它字节保持不变
    printf("write to addr 0x%08x, data 0x%08x, wmask 0x%02x\n", waddr, wdata, wmask);
    CHECK_ADDR_WRITE(waddr);
    waddr = waddr - 0x80000000; // 内存映射地址转换

    for(int i = 0; i < 4; i++){
        if(wmask & (1 << i)){
            mem[(waddr & ~0x3u) + i] = (wdata >> (i << 3)) & 0xFF;
        }
    }
}


void load_bin(const char *path) {
    FILE *fp = fopen(path, "rb");
    assert(fp != NULL);
    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    rewind(fp);
    assert(size <= (long)sizeof(mem));
    size_t ret = fread(mem, 1, size, fp);
    assert(ret == (size_t)size);
    fclose(fp);
}

int main(int argc, char **argv)
{
    if(argc > 1){
        load_bin(argv[1]);
    } else {
        printf("please provide a binary file to load into memory\n");
        assert(0);
    }
    //*(uint32_t*)(mem+0x224) = 0x00100073;

    Verilated::traceEverOn(true);
    VCPU* cpu = new VCPU;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    cpu->trace(tfp, 99);
    tfp->open("cpu.vcd");

    cpu->contextp()->time(0);
    cpu->arstn = 0;
    cpu->clk = 1;
    cpu->eval();
    tfp->dump(cpu->contextp()->time());
    while(!exit_flag) {
        cpu->contextp()->timeInc(1);
        cpu->clk = 0;
        cpu->eval();
        tfp->dump(cpu->contextp()->time());

        cpu->contextp()->timeInc(1);
        cpu->clk = 1;
        cpu->eval();
        tfp->dump(cpu->contextp()->time());


        if(cpu->contextp()->time() >= 5){
            cpu->arstn = 1;
        }
        if(cpu->contextp()->time() > 100000) break;
    }

    tfp->close();
    delete cpu;
    delete tfp;

    return 0;
}