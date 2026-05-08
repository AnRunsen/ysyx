#include "VysyxSoCFull.h"
#include "verilated_vcd_c.h"
#include "VysyxSoCFull___024root.h"
#include <stdint.h>
#include "config.hpp"
#include <nvboard.h>

extern VysyxSoCFull* cpu;
extern VerilatedVcdC* tfp;
extern bool exit_flag;
extern uint64_t cycle_cnt;
extern uint8_t inst_type;
extern uint8_t stage;

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
extern instr_clk_cnt itype_clk_cnt;

typedef struct {
    uint64_t clk_ifu;
    uint64_t clk_idu;
    uint64_t clk_exu;
    uint64_t clk_lsu;
    uint64_t clk_wbu;
} stage_clk_cnt;
stage_clk_cnt stclk_cnt;

enum { BRANCH=0, JAL, JALR, LUI, AUIPC, OP, OP_IMM, LOAD, STORE, SYSTEM };

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
        cpu->reset = 0;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif
        cpu->contextp()->timeInc(1);
        cpu->clock = 1;
        cpu->reset = 0;
        cpu->eval();
#ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
#endif

        cycle_cnt++;
        switch(inst_type) {
            case BRANCH: itype_clk_cnt.clk_branch += 1;
            break;
            case JAL: itype_clk_cnt.clk_jal += 1;
            break;
            case JALR: itype_clk_cnt.clk_jalr += 1;
            break;
            case LUI: itype_clk_cnt.clk_lui += 1;
            break;
            case AUIPC: itype_clk_cnt.clk_auipc += 1;
            break;
            case OP: itype_clk_cnt.clk_op += 1;
            break;
            case OP_IMM: itype_clk_cnt.clk_op_imm += 1;
            break;
            case LOAD: itype_clk_cnt.clk_load += 1;
            break;
            case STORE: itype_clk_cnt.clk_store += 1;
            break;
            case SYSTEM: itype_clk_cnt.clk_system += 1;
            break;
        }

        switch(stage) {
            case IFU: stclk_cnt.clk_ifu += 1;
            break;
            case IDU: stclk_cnt.clk_idu += 1;
            break;
            case EXU: stclk_cnt.clk_exu += 1;
            break;
            case LSU: stclk_cnt.clk_lsu += 1;
            break;
            case WBU: stclk_cnt.clk_wbu += 1;
            break;
        }

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

        nvboard_update();
    }
    return;
}