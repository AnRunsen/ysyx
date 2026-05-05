#include "VysyxSoCFull.h"
#include "verilated_vcd_c.h"
#include <elf.h>
#include <stdio.h>
#include <assert.h>
#include <stdint.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include "config.hpp"
#include "sdb.hpp"
#include "ftrace.hpp"

#include <nvboard.h>

uint8_t mrom[0x8000000]; // 128MB mrom
uint8_t flash[0x1000000]; // 16MB flash
uint8_t psram[0x1000000]; //16MB psram
uint16_t sdram[4][8192][512]; // 4 banks, 8192 rows, 512 columns

bool exit_flag = false;
enum { DIFFTEST_TO_DUT, DIFFTEST_TO_REF };

static const uint32_t SDRAM_BASE = 0xa0000000u;
static const uint32_t SDRAM_BANK_SHIFT = 22;
static const uint32_t SDRAM_ROW_SHIFT = 9;
static const uint32_t SDRAM_BANK_MASK = 0x3u;
static const uint32_t SDRAM_ROW_MASK = 0x1fffu;
static const uint32_t SDRAM_COL_MASK = 0x1ffu;

static bool addr_range_in_sdram(uint32_t addr, size_t len) {
    uint64_t start = addr;
    uint64_t end = start + len;
    uint64_t sdram_start = SDRAM_BASE;
    uint64_t sdram_end = sdram_start + sizeof(sdram);
    return start >= sdram_start && end <= sdram_end;
}

static void write_sdram_byte(uint32_t addr, uint8_t value) {
    assert(addr_range_in_sdram(addr, 1));

    uint32_t offset = addr - SDRAM_BASE;
    uint32_t halfword_addr = offset >> 1;
    uint32_t bank = (halfword_addr >> SDRAM_BANK_SHIFT) & SDRAM_BANK_MASK;
    uint32_t row = (halfword_addr >> SDRAM_ROW_SHIFT) & SDRAM_ROW_MASK;
    uint32_t col = halfword_addr & SDRAM_COL_MASK;
    uint16_t cell = sdram[bank][row][col];

    if ((offset & 0x1u) == 0) {
        cell = (cell & 0xff00u) | value;
    } else {
        cell = (cell & 0x00ffu) | ((uint16_t)value << 8);
    }

    sdram[bank][row][col] = cell;
}

static void fill_sdram(uint32_t addr, uint8_t value, size_t len) {
    assert(addr_range_in_sdram(addr, len));
    for (size_t i = 0; i < len; ++i) {
        write_sdram_byte(addr + i, value);
    }
}

static void copy_to_sdram(uint32_t addr, const uint8_t *buf, size_t len) {
    assert(addr_range_in_sdram(addr, len));
    for (size_t i = 0; i < len; ++i) {
        write_sdram_byte(addr + i, buf[i]);
    }
}

void load_pt_load_segments_to_sdram(const char *path) {
    FILE *fp = fopen(path, "rb");
    assert(fp != NULL);

    Elf32_Ehdr ehdr;
    size_t ret = fread(&ehdr, 1, sizeof(ehdr), fp);
    assert(ret == sizeof(ehdr));
    assert(memcmp(ehdr.e_ident, ELFMAG, SELFMAG) == 0);
    assert(ehdr.e_ident[EI_CLASS] == ELFCLASS32);
    assert(ehdr.e_phentsize == sizeof(Elf32_Phdr));

    Elf32_Phdr *phdrs = (Elf32_Phdr *)malloc(ehdr.e_phnum * sizeof(Elf32_Phdr));
    assert(phdrs != NULL);
    assert(fseek(fp, ehdr.e_phoff, SEEK_SET) == 0);
    ret = fread(phdrs, sizeof(Elf32_Phdr), ehdr.e_phnum, fp);
    assert(ret == ehdr.e_phnum);

    size_t loaded_segments = 0;
    size_t loaded_bytes = 0;

    for (int i = 0; i < ehdr.e_phnum; ++i) {
        Elf32_Phdr *phdr = &phdrs[i];
        uint32_t runtime_addr = phdr->p_paddr != 0 ? phdr->p_paddr : phdr->p_vaddr;

        if (phdr->p_type != PT_LOAD || phdr->p_memsz == 0 || !addr_range_in_sdram(runtime_addr, phdr->p_memsz)) {
            continue;
        }

        uint8_t *segment = (uint8_t *)malloc(phdr->p_filesz);
        assert(segment != NULL || phdr->p_filesz == 0);
        if (phdr->p_filesz != 0) {
            assert(fseek(fp, phdr->p_offset, SEEK_SET) == 0);
            ret = fread(segment, 1, phdr->p_filesz, fp);
            assert(ret == phdr->p_filesz);
            copy_to_sdram(runtime_addr, segment, phdr->p_filesz);
        }

        if (phdr->p_memsz > phdr->p_filesz) {
            fill_sdram(runtime_addr + phdr->p_filesz, 0, phdr->p_memsz - phdr->p_filesz);
        }

        free(segment);
        loaded_segments++;
        loaded_bytes += phdr->p_memsz;
    }

    free(phdrs);
    fclose(fp);

    printf("Preloaded %zu PT_LOAD segment(s) into SDRAM (%zu bytes) from %s\n",
           loaded_segments, loaded_bytes, path);
}

void load_bin(const char *path) {
    FILE *fp = fopen(path, "rb");
    assert(fp != NULL);
    fseek(fp, 0, SEEK_END);
    long size = ftell(fp);
    rewind(fp);
    assert(size <= (long)sizeof(flash));
    size_t ret = fread(flash, 1, size, fp);
    assert(ret == (size_t)size);
    fclose(fp);
}

VysyxSoCFull* cpu = new VysyxSoCFull;
VerilatedVcdC* tfp = new VerilatedVcdC;
void init_disasm();
char *elf_file = NULL;

extern "C" {
void difftest_init(int port);
void difftest_memcpy(uint32_t addr, void *buf, size_t n, bool direction);
void difftest_regcpy(void *dut, bool direction);
}

void nvboard_bind_all_pins(VysyxSoCFull *top);

typedef struct {
  uint32_t gpr[16];
  uint32_t pc;
} CPU_state;

int main(int argc, char *argv[])
{
    setbuf(stdout, NULL);

    Verilated::commandArgs(argc, argv);
    if(argc > 2){
        load_bin(argv[1]);
        elf_file = argv[2];
        load_pt_load_segments_to_sdram(elf_file);
    } else {
        printf("Usage: %s <binary> <elf_file>\n", argv[0]);
        assert(0);
    }

    nvboard_bind_all_pins(cpu);
    nvboard_init();

#ifdef WAVEON
    Verilated::traceEverOn(true);
#endif

#ifdef WAVEON
    cpu->trace(tfp, 99);
    tfp->open("cpu.vcd");
#endif

#ifdef FTRACE
    init_elf();
#endif

#ifdef ITRACE
    init_disasm();
#endif

#ifdef DIFFTEST
    difftest_init(1234);
    difftest_memcpy(0x80000000, mem, sizeof(mem), DIFFTEST_TO_REF);
#endif

    cpu->contextp()->time(0);
    cpu->eval();

    //reset assert 100 cycles
    while(cpu->contextp()->time() < 100 && !exit_flag) {
        cpu->contextp()->timeInc(1);
        cpu->clock = 0;
        cpu->reset = 1;
        cpu->eval();
    #ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
    #endif

        cpu->contextp()->timeInc(1);
        cpu->clock = 1;
        cpu->reset = 1;
        cpu->eval();
    #ifdef WAVEON
        tfp->dump(cpu->contextp()->time());
    #endif
    }

    sdb_set_batch_mode();

    sdb_mainloop();

#ifdef WAVEON
    tfp->close();
    delete tfp;
#endif

#ifdef FTRACE
    extern ftrace_t ftrace_info;
    if (ftrace_info.symtab) {
        free(ftrace_info.symtab);
        ftrace_info.symtab = NULL;
    }
    if (ftrace_info.strtab) {
        free(ftrace_info.strtab);
        ftrace_info.strtab = NULL;
    }
#endif

    nvboard_quit();
    delete cpu;
    return 0;
}