#include <am.h>
#include <klib.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;

#define UART_BASE 0x10000000L
#define UART_TX   0x0

#define PMEM_SIZE (8 * 1024)// 8KB
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define HEAP_SIZE (2 * 1024)// 2KB
#define HEAP_END  ((uintptr_t)&_heap_start + HEAP_SIZE)

Area heap = RANGE(&_heap_start, HEAP_END);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
  *(volatile uint8_t*)(UART_BASE + UART_TX) = ch;
}

void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : :"r"(code));
  while (1);
}

void _trm_init() {
  extern char _data_start;
  extern char _data_lma;
  extern char edata;
  memcpy(&_data_start, &_data_lma, &edata - &_data_start);

  int ret = main(mainargs);
  halt(ret);
}
