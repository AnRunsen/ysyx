.section bootloader, "ax"
.globl _bootloader
.type _bootloader, @function

_bootloader:
  la t0, _stext       # dst: start of .text in SRAM (VMA)
  la t1, _edata       # dst end: end of .data in SRAM
  la t2, _start_lma   # src: load address of .text in flash (LMA)

1:
  bge  t0, t1, 2f     # if dst >= end, done copying
  lw   a0, 0(t2)      # load word from flash
  sw   a0, 0(t0)      # store word to SRAM
  addi t0, t0, 4
  addi t2, t2, 4
  j    1b

2:
  la   t0, _start     # jump to _start in SRAM
  jr   t0


  

