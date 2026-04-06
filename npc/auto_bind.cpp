#include <nvboard.h>
#include "Vlight.h"

void nvboard_bind_all_pins(Vlight* top) {
	nvboard_bind_pin( &top->a, 1, SW0);
	nvboard_bind_pin( &top->b, 1, SW1);
	nvboard_bind_pin( &top->c, 1, LD0);
}
