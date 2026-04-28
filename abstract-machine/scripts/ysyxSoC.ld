ENTRY(_start)
PHDRS { text PT_LOAD; data PT_LOAD; }

MEMORY {
  mrom : ORIGIN = 0x20000000, LENGTH = 4K
  sram : ORIGIN = 0x0f000000, LENGTH = 8K
}

SECTIONS {
  . = ORIGIN(mrom);
  .text : {
    *(entry)
    *(.text*)
  } > mrom AT > mrom :text
  etext = .;
  _etext = .;

  .rodata : {
    *(.rodata*)
  } > mrom AT > mrom :text
  _data_lma = .;
  .data : {
    _data_start = .;
    *(.data*)
  } > sram AT > mrom :data
  edata = .;
  _data = .;
  _bss_start = .;
  .bss : {
    *(.bss*)
    *(.sbss*)
    *(.scommon)
  } > sram
  ebss = .;

  _heap_start = ALIGN(ebss, 0x1000);

  . = ORIGIN(sram) + LENGTH(sram);
  _stack_pointer = .;
  
}
