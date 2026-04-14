#include "VCPU.h"
#include "verilated_fst_c.h"

uint8_t mem[0x8000000]; // 128MB memory

void mem_op(VCPU* cpu) {
    if(cpu->wen) {
        switch(cpu->op_width) {
            case 0: // byte
                *(uint8_t*)(mem + (cpu->waddr & ~0x0)) = (uint8_t)(cpu->wdata & 0xFF);
                break;
            case 1: // half-word
                *(uint16_t*)(mem + (cpu->waddr & ~0x1)) = (uint16_t)(cpu->wdata & 0xFFFF);
                break;
            case 2: // word
                *(uint32_t*)(mem + (cpu->waddr & ~0x3)) = (uint32_t)cpu->wdata;
                break;
        }
    }

    cpu->rdata0 = *(uint32_t*)(mem + (cpu->raddr0 & ~0x3));
    cpu->rdata1 = *(uint32_t*)(mem + (cpu->raddr1 & ~0x3));
}


int main()
{
    Verilated::traceEverOn(true);
    VCPU* cpu = new VCPU;
    VerilatedFstC* tfp = new VerilatedFstC;
    cpu->trace(tfp, 99);
    tfp->open("cpu.fst");

    cpu->contextp()->time(0);
    cpu->arstn = 0;
    cpu->clk = 0;
    while(1){
        cpu->clk = 0;
        cpu->clk = 1;
        cpu->eval();
        mem_op(cpu);
        tfp->dump(cpu->contextp()->time());
        cpu->contextp()->timeInc(1);
        if(cpu->contextp()->time() == 5) cpu->arstn = 1;
        if(cpu->contextp()->time() > 1000) break;
    }

    tfp->close();
    delete cpu;
    delete tfp;

    return 0;
}