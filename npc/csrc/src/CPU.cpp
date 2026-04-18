#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <assert.h>
#include <time.h>
#include "config.hpp"
#include "sdb.hpp"
#include "ftrace.hpp"

uint8_t mem[0x8000000]; // 128MB memory
bool exit_flag = false;

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

VCPU* cpu = new VCPU;
VerilatedVcdC* tfp = new VerilatedVcdC;
void init_disasm();
char *elf_file = NULL;

int main(int argc, char *argv[])
{
    if(argc > 2){
        load_bin(argv[1]);
        elf_file = argv[2];
    } else {
        printf("Usage: %s <binary> <elf_file>\n", argv[0]);
        assert(0);
    }
#ifdef WAVEON
    Verilated::traceEverOn(true);
#endif

#ifdef WAVEON
    cpu->trace(tfp, 99);
    tfp->open("cpu.vcd");
#endif

    init_elf();
    init_disasm();

    cpu->contextp()->time(0);
    cpu->arstn = 1;
    cpu->clk = 0;
    cpu->eval();
#ifdef WAVEON
    tfp->dump(cpu->contextp()->time());
#endif

    sdb_mainloop();

#ifdef WAVEON
    tfp->close();
    delete tfp;
#endif
    delete cpu;
    return 0;
}