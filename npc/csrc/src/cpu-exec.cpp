#include "VysyxSoCFull.h"
#include "verilated_vcd_c.h"
#include "VysyxSoCFull___024root.h"
#include <stdint.h>
#include "config.hpp"

extern VysyxSoCFull* cpu;
extern VerilatedVcdC* tfp;
extern bool exit_flag;
extern "C" {
void difftest_exec(uint64_t n);
void difftest_regcpy(void *dut, bool direction);
}
enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

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
        cpu->clock = 0;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif
        cpu->contextp()->timeInc(1);
        cpu->clock = 1;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif
#ifdef DIFFTEST
        difftest_exec(1);
        CPU_state dut_state;
        difftest_regcpy(&dut_state, DIFFTEST_TO_DUT);
        
        for(uint32_t i = 0; i < 16; i++) {
            if(dut_state.gpr[i] != cpu->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ysyx_26040125_GPR__DOT__gpr[i]) {
                printf("Difftest failed at time %lu: gpr[%u] = 0x%08x, expected 0x%08x\n",
                    cpu->contextp()->time(), i, cpu->rootp->ysyxSoCFull__DOT__asic__DOT__cpu__DOT__cpu__DOT__ysyx_26040125_GPR__DOT__gpr[i], dut_state.gpr[i]);
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