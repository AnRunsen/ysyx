#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <assert.h>
#include <time.h>

// #define WAVEON

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

int main(int argc, char **argv)
{
    if(argc > 1){
        load_bin(argv[1]);
    } else {
        printf("please provide a binary file to load into memory\n");
        assert(0);
    }
#ifdef WAVEON
    Verilated::traceEverOn(true);
#endif
    VCPU* cpu = new VCPU;

#ifdef WAVEON
    VerilatedVcdC* tfp = new VerilatedVcdC;
    cpu->trace(tfp, 99);
    tfp->open("cpu.vcd");
#endif

    cpu->contextp()->time(0);
    cpu->arstn = 1;
    cpu->clk = 0;
#ifdef WAVEON
    tfp->dump(cpu->contextp()->time());
#endif
    while(!exit_flag) {
        cpu->contextp()->timeInc(1);
        cpu->clk = 0;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif
        cpu->contextp()->timeInc(1);
        cpu->clk = 1;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif
    }

#ifdef WAVEON
    tfp->close();
    delete tfp;
#endif
    delete cpu;
    return 0;
}