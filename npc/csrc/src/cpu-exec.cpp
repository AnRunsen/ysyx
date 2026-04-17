#include "VCPU.h"
#include "verilated_vcd_c.h"
#include <stdint.h>
#include "config.hpp"
#include "difftest-def.h"

extern VCPU* cpu;
extern VerilatedVcdC* tfp;
extern bool exit_flag;
void difftest_exec(uint64_t n);

typedef struct {
  uint32_t gpr[16];
  uint32_t pc;
} CPU_state;

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
#ifdef DIFFTEST
        difftest_exec(1);
        CPU_state dut_state;
        difftest_regcpy(&dut_state, DIFFTEST_TO_DUT);
        
        for(uint32_t i = 0; i < 16; i++) {
            if(dut_state.gpr[i] != cpu->rootp->CPU__DOT__u_GPR__DOT__gpr[i]) {
                printf("Difftest failed at time %lu: gpr[%u] = 0x%08x, expected 0x%08x\n",
                    cpu->contextp()->time(), i, cpu->rootp->CPU__DOT__u_GPR__DOT__gpr[i], dut_state.gpr[i]);
                exit_flag = true;
                break;
            }
        }
#endif
        if(exit_flag) {
            break;
        }
    }
    return;
}