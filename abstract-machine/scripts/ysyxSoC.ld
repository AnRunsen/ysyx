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
  .fsbl : ALIGN(8) {
    _sfsbl = .;
    *(fsbl)
  } > flash AT > flash :fsbl
  _efsbl = .;

  .ssbl : ALIGN(8) {
    _sssbl = .;
    *(ssbl)
  } > sram AT > flash :ssbl
  _essbl = .;

  .text : ALIGN(8){
    _stext = .;
    *(entry)
    *(.text*)
  } > sdram AT > flash :text
  _etext = .;

  .rodata : ALIGN(8){
    _srodata = .;
    *(.rodata*)
    *(.srodata*)
  } > sdram AT > flash :rodata
  _erodata = .;

  .data : ALIGN(8){
    _sdata = .;
    *(.data*)
    *(.sdata*)
  } > sdram AT > flash :data
  _edata = .;

  .bss : ALIGN(8){
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sdram AT > flash :bss
  _ebss = .;

  _heap_start = ALIGN(0x1000);

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
  _ssbl_lma = ADDR(.ssbl);
  _text_lma = ADDR(.text);
  _rodata_lma = ADDR(.rodata);
  _data_lma = ADDR(.data);
  _bss_lma = ADDR(.bss);
}
