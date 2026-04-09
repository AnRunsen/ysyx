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

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "sdb.h"
#include <memory/paddr.h>

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);
  return 0;
}


static int cmd_q(char *args) {
  return -1;
}

static int cmd_si(char *args) {
  cpu_exec(1);
  return 0;
}

static int cmd_p(char *args) {
  if (args == NULL) {
    printf("Hint: Try p <expression>\n");
  }
  else {
    bool success = false;
    uint32_t result = expr(args, &success);
    if(success) {
      printf("%d\n", result);
    }
    else {
      printf("Invalid expression.\n");
    }
  }
  return 0;
}

static int cmd_x(char *args);

static int cmd_help(char *args);
static int cmd_info(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Step in one instruction", cmd_si},
  { "info", "Print the info of reg or the watch point", cmd_info},
  { "x", "Scan the memory", cmd_x},
  { "p", "Print the value of an expression", cmd_p},

  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}


static int cmd_info(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Hint: Try <info r> or <info w>\n");
  }

  else if(strcmp(arg, "r") == 0) {
    isa_reg_display();
  }

  else if(strcmp(arg, "w") == 0) {
    printf("Impl me in sdb.c:116\n");
  }
  else {
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

static int cmd_x(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");

  if (arg == NULL) {
    printf("Hint: Try x <num> <addr>\n");
  }

  else{
    int scannum = atoi(arg);

    arg = strtok(NULL, " ");
    if(arg == NULL) {
      printf("Hint: Try x <num> <addr>\n");
    }
    else {
      int startaddr = (int)strtol(arg, NULL, 0);
      for(int i=0; i<scannum; i++)
      {
        printf("0x%08x: 0x%08x\n", startaddr + i*4, paddr_read(startaddr + i*4, 4));
      }
    }
    
  }
  return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }


  /*For the AI agent here */
  {
    FILE *fp = fopen("/home/anderson/ysyx/ysyx-workbench/nemu/tools/gen-expr/expr", "r");
    if (fp != NULL) {
      char line[65536];
      int pass = 0, fail = 0;
      while (fgets(line, sizeof(line), fp) != NULL) {
        /* strip trailing newline */
        line[strcspn(line, "\n")] = '\0';
        /* parse golden result (first token) */
        char *endptr;
        uint32_t golden = (uint32_t)strtoul(line, &endptr, 10);
        if (endptr == line || *endptr != ' ') continue;
        char *expression = endptr + 1;
        bool success = false;
        word_t result = expr(expression, &success);
        if (!success) {
          printf("FAIL (parse error): golden=%u expr=%s\n", golden, expression);
          assert(0);
          fail++;
        } else if ((uint32_t)result == golden) {
          printf("PASS: golden=%u got=%u expr=%s\n", golden, (uint32_t)result, expression);
          pass++;
        } else {
          printf("FAIL: golden=%u got=%u expr=%s\n", golden, (uint32_t)result, expression);
          assert(0);
          fail++;
        }
      }
      fclose(fp);
      printf("Expression test: %d passed, %d failed\n", pass, fail);
    } else {
      printf("Cannot open expr file\n");
    }
  }
  /*For the AI agent end */

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
