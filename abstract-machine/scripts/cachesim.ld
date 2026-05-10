ENTRY(_fsbl)
PHDRS {fsbl PT_LOAD; ssbl PT_LOAD; text PT_LOAD; rodata PT_LOAD; data PT_LOAD; bss PT_NULL; }

MEMORY {
  psram : ORIGIN = 0x80000000, LENGTH = 4M
}

SECTIONS {
  .fsbl : ALIGN(8) {
    _sfsbl = .;
    *(fsbl)
  } > psram AT > psram :fsbl
  _efsbl = .;

  .ssbl : ALIGN(8) {
    _sssbl = .;
    *(ssbl)
  } > psram AT > psram :ssbl
  _essbl = .;

  .text : ALIGN(8){
    _stext = .;
    *(entry)
    *(.text*)
  } > psram AT > psram :text
  _etext = .;

  .rodata : ALIGN(8){
    _srodata = .;
    *(.rodata*)
    *(.srodata*)
  } > psram AT > psram :rodata
  _erodata = .;

  .data : ALIGN(8){
    _sdata = .;
    *(.data*)
    *(.sdata*)
  } > psram AT > psram :data
  _edata = .;

  .bss : ALIGN(8){
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > psram AT > psram :bss
  _ebss = .;

  _heap_start = ALIGN(0x1000);

  . = ORIGIN(psram) + LENGTH(psram);
  _stack_pointer = .;
  
  _ssbl_lma = LOADADDR(.ssbl);
  _text_lma = LOADADDR(.text);
  _rodata_lma = LOADADDR(.rodata);
  _data_lma = LOADADDR(.data);
  _bss_lma = LOADADDR(.bss);
}
