#include "Vlight.h"
#include <nvboard.h>

void single_cycle(Vlight *top) {
  top->clk = 0; top->eval();
  top->clk = 1; top->eval();
}

void reset(Vlight *top, int n) {
  top->rst = 1;
  while (n -- > 0) single_cycle(top);
  top->rst = 0;
}


void nvboard_bind_all_pins(Vlight *top);

int main(int argc, char **argv)
{
  Vlight *top = new Vlight;

  nvboard_bind_all_pins(top);
  nvboard_init();

  reset(top, 10);  // 复位10个周期
  while (true)
  {

    //update input signals
    nvboard_update();

    //calculate the output signals
    single_cycle(top);

    //update output signals
    nvboard_update();
  }

  nvboard_quit();
  delete top;
  return 0;
}