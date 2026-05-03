ENTRY(_bootloader)
PHDRS { bootloader PT_LOAD; text PT_LOAD; data PT_LOAD; bss PT_NULL; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  psram : ORIGIN = 0x80000000, LENGTH = 4M
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  .bootloader : {
    _sbootloader = .;
    *(bootloader)
  } > flash AT > flash :bootloader
  _ebootloader = .;

  .text : {
    _stext = .;
    *(entry)
    *(.text*)
  } > psram AT > flash :text
  _etext = .;

  .rodata : {
    _srodata = .;
    *(.rodata*)
  } > psram AT > flash :text
  _erodata = .;

  .data : {
    _sdata = .;
    *(.data*)
    *(.sdata*)
  } > psram AT > flash :data
  _edata = .;

  .bss : {
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram AT > flash :bss
  _ebss = .;

  _heap_start = ALIGN(0x1000);

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
  _start_lma = LOADADDR(.text);
}
