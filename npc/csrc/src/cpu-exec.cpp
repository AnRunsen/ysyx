#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdint.h>
#include "config.hpp"

extern VCPU* cpu;
extern VerilatedVcdC* tfp;
extern bool exit_flag;

void cpu_exec(uint64_t n)
{
    if(exit_flag) {
        printf("Simulation has already ended.\n");
        return;
    }
    while(n-- > 0) {
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
        if(exit_flag) {
            break;
        }
    }
    return;
}