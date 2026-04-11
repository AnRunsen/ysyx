#include "Vswitch.h"
#include <nvboard.h>

void single_cycle(Vswitch *top) {
  top->eval();
}

void nvboard_bind_all_pins(Vswitch *top);

int main(int argc, char **argv)
{
  Vswitch *top = new Vswitch;

  nvboard_bind_all_pins(top);
  nvboard_init();

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