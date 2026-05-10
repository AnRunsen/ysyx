/***************************************************************************************
 * Copyright (c) 2014-2024 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan PSL v2.
 * You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
 * MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include <cpu/cpu.h>
#include <cpu/decode.h>
#include <cpu/difftest.h>
#include <locale.h>
#include <ftrace.h>
#include <ringbuf.h>
#include <watchpoint.h>

/* The assembly code of instructions executed is only output to the screen
 * when the number of instructions executed is less than this value.
 * This is useful when you use the `si' command.
 * You can modify this value as you want.
 */
#define MAX_INST_TO_PRINT 10

CPU_state cpu = {};
uint64_t g_nr_guest_inst = 0;
static uint64_t g_timer = 0; // unit: us
static bool g_print_step = false;

#define DEFAULT_CACHE_BLOCK_SIZE 4
#define DEFAULT_CACHE_NUM_SETS 16
#define DEFAULT_CACHE_NUM_WAYS 1

ring_buffer_t ring_buffer = {.head = 0, .tail = 0, .size = 0};

typedef struct {
  bool valid;
  uint64_t tag;
  uint64_t last_used;
} cache_line_t;

typedef struct {
  bool initialized;
  size_t block_size;
  size_t num_sets;
  size_t num_ways;
  uint64_t accesses;
  uint64_t hits;
  uint64_t misses;
  uint64_t timestamp;
  cache_line_t *lines;
} cache_sim_t;

static cache_sim_t icache = {};

#ifdef CONFIG_FTRACE
/* ftrace 调用深度（缩进水平） */
static int ftrace_depth = 0;



/*
 * 检测当前指令是否为函数调用或返回。
 * RISC-V 中：
 *   JAL  opcode=0x6F: rd==1 (ra) 表示函数调用
 *   JALR opcode=0x67  funct3=0:
 *     rd==0, rs1==1 (ra) 表示返回 (ret)
 *     rd==1           表示间接调用
 */
static void ftrace_detect(Decode *s)
{
  if (ftrace_info.symtab == NULL)
    return;

  uint32_t inst = s->isa.inst;
  uint32_t opcode = inst & 0x7F;
  uint32_t rd = (inst >> 7) & 0x1F;
  uint32_t rs1 = (inst >> 15) & 0x1F;
  uint32_t funct3 = (inst >> 12) & 0x7;

  if (opcode == 0x6F)
  { /* JAL */
    if (rd == 1 || rd == 5)
    { /* rd = ra 或 t0 → 函数调用 */
      vaddr_t func_addr = s->dnpc;
      const char *name = ftrace_find_func(s->dnpc, &func_addr);
      printf("0x%08x: %*scall [%s@0x%08x]\n",
             (uint32_t)s->pc, ftrace_depth * 2, "",
             name ? name : "???", (uint32_t)func_addr);
      ftrace_depth++;
    }
  }
  else if (opcode == 0x67 && funct3 == 0)
  { /* JALR */
    if (rd == 0 && (rs1 == 1 || rs1 == 5))
    { /* jalr x0, ra, 0 → ret */
      vaddr_t func_addr = s->pc;
      const char *name = ftrace_find_func(s->pc, &func_addr);
      if (ftrace_depth > 0)
        ftrace_depth--;
      printf("0x%08x: %*sret  [%s]\n",
             (uint32_t)s->pc, ftrace_depth * 2, "",
             name ? name : "???");
    }
    else if (rd == 1 || rd == 5)
    { /* jalr ra, rs, imm → 间接调用 */
      vaddr_t func_addr = s->dnpc;
      const char *name = ftrace_find_func(s->dnpc, &func_addr);
      printf("0x%08x: %*scall [%s@0x%08x]\n",
             (uint32_t)s->pc, ftrace_depth * 2, "",
             name ? name : "???", (uint32_t)func_addr);
      ftrace_depth++;
    }
  }
}
#endif

void device_update();

word_t expr(char *e, bool *success);
WP *new_wp();
void free_wp(WP *wp);

static void trace_and_difftest(Decode *_this, vaddr_t dnpc)
{
#ifdef CONFIG_ITRACE_COND
  if (ITRACE_COND)
  {
    log_write("%s\n", _this->logbuf);
  }
#endif
  if (g_print_step)
  {
    IFDEF(CONFIG_ITRACE, puts(_this->logbuf));
  }
  IFDEF(CONFIG_DIFFTEST, difftest_step(_this->pc, dnpc));

#ifdef CONFIG_WATCHPOINT
  /*Watch all of the watchpoint*/
  WP *wp = head;
  uint32_t new_value;
  bool success;
  while (wp != NULL)
  {
    new_value = expr(wp->expr, &success);
    if (success)
    {
      if (new_value != wp->value)
      {
        printf("Watchpoint %d: %s\nOld value = %d\nNew value = %d\n", wp->NO, wp->expr, wp->value, new_value);
        wp->value = new_value;
        nemu_state.state = NEMU_STOP;
      }
    }
    else
    {
      printf("Invalid expression in watchpoint %d: %s\n", wp->NO, wp->expr);
      nemu_state.state = NEMU_STOP;
    }
    wp = wp->next;
  }
#endif
}

static bool is_power_of_two(size_t value)
{
  return value != 0 && (value & (value - 1)) == 0;
}

static size_t read_cache_config(const char *name, size_t default_value, bool must_be_power_of_two)
{
#ifdef CONFIG_TARGET_AM
  return default_value;
#else
  const char *value = getenv(name);
  if (value == NULL || *value == '\0')
    return default_value;

  char *end = NULL;
  unsigned long parsed = strtoul(value, &end, 0);
  Assert(end != value && *end == '\0' && parsed > 0,
         "%s should be a positive integer, but got '%s'", name, value);
  Assert(!must_be_power_of_two || is_power_of_two(parsed),
         "%s should be a power of two, but got '%s'", name, value);
  return parsed;
#endif
}

static cache_line_t *cache_set_base(cache_sim_t *cache, size_t set_index)
{
  return cache->lines + set_index * cache->num_ways;
}

static void init_cachesim(void)
{
  if (icache.initialized)
    return;

  icache.block_size = read_cache_config("NEMU_CACHE_BLOCK_SIZE", DEFAULT_CACHE_BLOCK_SIZE, true);
  icache.num_sets = read_cache_config("NEMU_CACHE_NUM_SETS", DEFAULT_CACHE_NUM_SETS, true);
  icache.num_ways = read_cache_config("NEMU_CACHE_NUM_WAYS", DEFAULT_CACHE_NUM_WAYS, false);
  icache.lines = calloc(icache.num_sets * icache.num_ways, sizeof(*icache.lines));

  Assert(icache.lines != NULL, "failed to allocate cache simulator metadata");
  icache.initialized = true;
  Log("cache simulator: block=%zuB, sets=%zu, ways=%zu", icache.block_size, icache.num_sets, icache.num_ways);
}

static void cachesim(Decode *s)
{
  init_cachesim();

  icache.accesses++;
  icache.timestamp++;

  uint64_t block_addr = s->pc / icache.block_size;
  size_t set_index = block_addr % icache.num_sets;
  uint64_t tag = block_addr / icache.num_sets;
  cache_line_t *set = cache_set_base(&icache, set_index);
  cache_line_t *victim = &set[0];

  for (size_t way = 0; way < icache.num_ways; way++)
  {
    cache_line_t *line = &set[way];
    if (line->valid && line->tag == tag)
    {
      icache.hits++;
      line->last_used = icache.timestamp;
      return;
    }

    if (!line->valid)
    {
      victim = line;
      break;
    }

    if (line->last_used < victim->last_used)
    {
      victim = line;
    }
  }

  icache.misses++;
  victim->valid = true;
  victim->tag = tag;
  victim->last_used = icache.timestamp;
}

static void exec_once(Decode *s, vaddr_t pc)
{
  s->pc = pc;
  s->snpc = pc;

  cachesim(s);
  isa_exec_once(s);
  cpu.pc = s->dnpc;
#ifdef CONFIG_ITRACE
  char *p = s->logbuf;
  p += snprintf(p, sizeof(s->logbuf), FMT_WORD ":", s->pc);
  int ilen = s->snpc - s->pc;
  int i;
  uint8_t *inst = (uint8_t *)&s->isa.inst;
#ifdef CONFIG_ISA_x86
  for (i = 0; i < ilen; i++)
  {
#else
  for (i = ilen - 1; i >= 0; i--)
  {
#endif
    p += snprintf(p, 4, " %02x", inst[i]);
  }
  int ilen_max = MUXDEF(CONFIG_ISA_x86, 8, 4);
  int space_len = ilen_max - ilen;
  if (space_len < 0)
    space_len = 0;
  space_len = space_len * 3 + 1;
  memset(p, ' ', space_len);
  p += space_len;

  void disassemble(char *str, int size, uint64_t pc, uint8_t *code, int nbyte);
  disassemble(p, s->logbuf + sizeof(s->logbuf) - p,
              MUXDEF(CONFIG_ISA_x86, s->snpc, s->pc), (uint8_t *)&s->isa.inst, ilen);

  // 将s->logbuf字符串写入循环缓冲区
  strncpy(ring_buffer.buf[ring_buffer.head], s->logbuf, sizeof(s->logbuf));
  ring_buffer.head = (ring_buffer.head + 1) % 16;
  if (ring_buffer.size < 16)
  {
    ring_buffer.size++;
  }
  else
  {
    ring_buffer.tail = (ring_buffer.tail + 1) % 16; // 覆盖最旧的指令
  }

#endif
}

static void execute(uint64_t n)
{
  Decode s;
  for (; n > 0; n--)
  {
    exec_once(&s, cpu.pc);
    g_nr_guest_inst++;
    //现在S->inst是上一条指令，S->Dnpc是下一条指令的地址
    IFDEF(CONFIG_FTRACE, ftrace_detect(&s));
    trace_and_difftest(&s, cpu.pc);
    if (nemu_state.state != NEMU_RUNNING)
      break;
    IFDEF(CONFIG_DEVICE, device_update());
  }
}

static void statistic()
{
  IFNDEF(CONFIG_TARGET_AM, setlocale(LC_NUMERIC, ""));
#define NUMBERIC_FMT MUXDEF(CONFIG_TARGET_AM, "%", "%'") PRIu64
  Log("host time spent = " NUMBERIC_FMT " us", g_timer);
  Log("total guest instructions = " NUMBERIC_FMT, g_nr_guest_inst);
  if (icache.initialized && icache.accesses > 0)
  {
    uint64_t hit_percent_x100 = icache.hits * 10000 / icache.accesses;
    Log("cache hit statistics = " NUMBERIC_FMT " hits / " NUMBERIC_FMT " accesses (%" PRIu64 ".%02" PRIu64 "%%), misses = " NUMBERIC_FMT,
        icache.hits, icache.accesses,
        hit_percent_x100 / 100, hit_percent_x100 % 100,
        icache.misses);
  }
  if (g_timer > 0)
    Log("simulation frequency = " NUMBERIC_FMT " inst/s", g_nr_guest_inst * 1000000 / g_timer);
  else
    Log("Finish running in less than 1 us and can not calculate the simulation frequency");
}

void assert_fail_msg()
{
  isa_reg_display();
  statistic();
}

/* Simulate how the CPU works. */
void cpu_exec(uint64_t n)
{
  g_print_step = (n < MAX_INST_TO_PRINT);
  switch (nemu_state.state)
  {
  case NEMU_END:
  case NEMU_ABORT:
  case NEMU_QUIT:
    printf("Program execution has ended. To restart the program, exit NEMU and run again.\n");
    return;
  default:
    nemu_state.state = NEMU_RUNNING;
  }

  uint64_t timer_start = get_time();

  execute(n);

  uint64_t timer_end = get_time();
  g_timer += timer_end - timer_start;

  switch (nemu_state.state)
  {
  case NEMU_RUNNING:
    nemu_state.state = NEMU_STOP;
    break;

  case NEMU_END:
  case NEMU_ABORT:
    Log("nemu: %s at pc = " FMT_WORD,
        (nemu_state.state == NEMU_ABORT ? ANSI_FMT("ABORT", ANSI_FG_RED) : (nemu_state.halt_ret == 0 ? ANSI_FMT("HIT GOOD TRAP", ANSI_FG_GREEN) : ANSI_FMT("HIT BAD TRAP", ANSI_FG_RED))),
        nemu_state.halt_pc);

#ifdef CONFIG_ITRACE
    if(nemu_state.halt_ret && ring_buffer.size > 0)
    {
      //将环形缓冲区中的内容输出到屏幕
      do{
        printf("%s\n", ring_buffer.buf[ring_buffer.tail]);
        ring_buffer.tail = (ring_buffer.tail + 1) % 16;
      }while(ring_buffer.tail != ring_buffer.head);
    }
#endif
    // fall through
  case NEMU_QUIT:
    statistic();
  }
}
