ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; bss PT_NULL; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    _stext = .;
    *(entry)
    *(.text*)
  } > mrom AT > mrom :text
  _etext = .;

  .rodata : {
    _srodata = .;
    *(.rodata*)
  } > mrom AT > mrom :text
  _erodata = .;

  .data : {
    _sdata = .;
    *(.data*)
    *(.sdata*)
  } > sram AT > mrom :data
  _edata = .;

  .bss : {
    _sbss = .;
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sram AT > mrom :bss
  _ebss = .;

  _heap_start = ALIGN(0x1000);

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
  _data_lma = LOADADDR(.data);
}
