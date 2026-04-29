#include <am.h>
#include <klib.h>
#include <klib-macros.h>

extern char _heap_start;
int main(const char *args);

extern char _pmem_start;

#define UART_BASE 0x10000000L
#define UART_TX   0x0
#define UART_LCR  0x3
#define UART_LSR  0x5
#define UART_DL_MSB 0x1
#define UART_DL_LSB 0x0

#define PMEM_SIZE (8 * 1024)// 8KB
#define PMEM_END  ((uintptr_t)&_pmem_start + PMEM_SIZE)

#define HEAP_SIZE (2 * 1024)// 2KB
#define HEAP_END  ((uintptr_t)&_heap_start + HEAP_SIZE)

Area heap = RANGE(&_heap_start, HEAP_END);
static const char mainargs[MAINARGS_MAX_LEN] = TOSTRING(MAINARGS_PLACEHOLDER); // defined in CFLAGS

void putch(char ch) {
  while(!(*(volatile uint8_t*)(UART_BASE + UART_LSR) & 0x20));

  *(volatile uint8_t*)(UART_BASE + UART_TX) = ch;
}

void halt(int code) {
  asm volatile("mv a0, %0; ebreak" : :"r"(code));
  while (1);
}

void load()
{
  extern char _sdata;
  extern char _data_lma;
  extern char _edata;
  memcpy(&_sdata, &_data_lma, &_edata - &_sdata);

  extern char _sbss;
  extern char _ebss;
  memset(&_sbss, 0, &_ebss - &_sbss);
}

void uart_init() {
  *(volatile uint8_t*)(UART_BASE + UART_LCR) |= 0x80;
  *(volatile uint8_t*)(UART_BASE + UART_DL_MSB) = 0x00;
  *(volatile uint8_t*)(UART_BASE + UART_DL_LSB) = 0x01;
  *(volatile uint8_t*)(UART_BASE + UART_LCR) &= 0x7F;
}

void _trm_init() {
  load();

  uart_init();
  int ret = main(mainargs);
  halt(ret);
}
