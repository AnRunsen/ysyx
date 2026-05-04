.section ssbl, "ax"
.globl _ssbl
.type _ssbl, @function

_ssbl:
  la t2, _image_lma   # src: LMA of .text in flash (runs forward through all sections)

  # Copy .text byte by byte
  la t0, _stext
  la t1, _etext
1:
  bge  t0, t1, 2f
  lb   a0, 0(t2)
  sb   a0, 0(t0)
  addi t0, t0, 1
  addi t2, t2, 1
  j    1b

2:
  # Copy .rodata byte by byte (LMA follows .text in flash)
  la t0, _srodata
  la t1, _erodata
3:
  bge  t0, t1, 4f
  lb   a0, 0(t2)
  sb   a0, 0(t0)
  addi t0, t0, 1
  addi t2, t2, 1
  j    3b

4:
  # Copy .data byte by byte (LMA follows .rodata in flash)
  la t0, _sdata
  la t1, _edata
5:
  bge  t0, t1, 6f
  lb   a0, 0(t2)
  sb   a0, 0(t0)
  addi t0, t0, 1
  addi t2, t2, 1
  j    5b

6:
  # Zero .bss section
  la t0, _sbss
  la t1, _ebss
7:
  bge  t0, t1, 8f
  sb   zero, 0(t0)
  addi t0, t0, 1
  j    7b

8:
  la   t0, _start     # jump to _start in psram
  jr   t0


  

