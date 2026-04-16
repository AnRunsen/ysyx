#include <am.h>
#include <nemu.h>
#include <klib.h>
#include <klib-macros.h>


#define KEYDOWN_MASK 0x8000

void __am_input_keybrd(AM_INPUT_KEYBRD_T *kbd) {
  printf("enter the keyboard input handler\n");
  kbd->keydown = inl(KBD_ADDR) & KEYDOWN_MASK;
  kbd->keycode = inl(KBD_ADDR) & 0xFF;
}
