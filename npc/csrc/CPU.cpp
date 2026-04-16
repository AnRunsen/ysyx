#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdio.h>
#include <assert.h>
#include <time.h>

// #define DEBUG

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

    Verilated::traceEverOn(true);
    VCPU* cpu = new VCPU;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    cpu->trace(tfp, 99);
    tfp->open("cpu.vcd");

    cpu->contextp()->time(0);
    cpu->arstn = 1;
    cpu->clk = 0;
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
    }

    tfp->close();
    delete cpu;
    delete tfp;

    return 0;
}