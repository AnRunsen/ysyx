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

#include <utils.h>

NEMUState nemu_state = { .state = NEMU_STOP };

typedef struct {
    char buf[16][128];
    int head;  // 写指针
    int tail;  // 读指针
} ring_buffer_t;

int is_exit_status_bad() {
  extern ring_buffer_t ring_buffer;
  int good = (nemu_state.state == NEMU_END && nemu_state.halt_ret == 0) ||
    (nemu_state.state == NEMU_QUIT);

  if(!good)
  {
    //将环形缓冲区中的内容输出到屏幕
    do{
      printf("%s\n", ring_buffer.buf[ring_buffer.tail]);
      ring_buffer.tail = (ring_buffer.tail + 1) % 16;
    }while(ring_buffer.tail != ring_buffer.head);
  }
  return !good;

  
}
