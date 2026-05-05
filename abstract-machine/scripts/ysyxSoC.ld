ENTRY(_fsbl)
PHDRS {fsbl PT_LOAD; ssbl PT_LOAD; text PT_LOAD; rodata PT_LOAD; data PT_LOAD; bss PT_NULL; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  flash : ORIGIN = 0x30000000, LENGTH = 16M
  psram : ORIGIN = 0x80000000, LENGTH = 4M
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
  sdram : ORIGIN = 0xa0000000, LENGTH = 32M
}

SECTIONS {
  .fsbl : {
    _sfsbl = .;
    *(fsbl)
  } > psram AT > psram :fsbl
  _efsbl = .;

  .ssbl : {
    _sssbl = .;
    *(ssbl)
  } > psram AT > psram :ssbl
  _essbl = .;

  .text : {
    _stext = .;
    *(entry)
    *(.text*)
  } > psram AT > psram :text
  _etext = .;

  .rodata : {
    _srodata = .;
    *(.rodata*)
    *(.srodata*)
  } > psram AT > psram :rodata
  _erodata = .;

  .data : {
    _sdata = .;
    *(.data*)
    *(.sdata*)
  } > psram AT > psram :data
  _edata = .;

  .bss : {
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram AT > psram :bss
  _ebss = .;

  _heap_start = ALIGN(0x1000);

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
  _image_lma = LOADADDR(.text);
  _ssbl_lma = LOADADDR(.ssbl);
}
