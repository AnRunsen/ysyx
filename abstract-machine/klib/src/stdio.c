#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);

  int count = 0;
  for (; *fmt != '\0'; fmt++) {
    if (*fmt != '%') {
      putch(*fmt);
      count++;
      continue;
    }
    fmt++;

    /* 解析填充字符（默认空格，'0' 表示零填充） */
    char pad_char = ' ';
    if (*fmt == '0') {
      pad_char = '0';
      fmt++;
    }

    /* 解析宽度 */
    int width = 0;
    while (*fmt >= '0' && *fmt <= '9') {
      width = width * 10 + (*fmt - '0');
      fmt++;
    }

    if (*fmt == 'd') {
      int x = va_arg(ap, int);
      char buf[16];
      char *q = buf + sizeof(buf);
      int negative = (x < 0);
      /* 使用无符号运算避免 INT_MIN 溢出 */
      unsigned int ux = negative ? (unsigned int)(-(unsigned int)x) : (unsigned int)x;
      do {
        *--q = '0' + ux % 10;
        ux /= 10;
      } while (ux > 0);
      int digits = (int)(buf + sizeof(buf) - q);
      int total = digits + negative;
      /* 空格填充在符号前，零填充在符号后 */
      if (pad_char == ' ') {
        for (int i = total; i < width; i++) { putch(' '); count++; }
      }
      if (negative) { putch('-'); count++; }
      if (pad_char == '0') {
        for (int i = total; i < width; i++) { putch('0'); count++; }
      }
      while (q < buf + sizeof(buf)) {
        putch(*q++);
        count++;
      }
    }
    else if (*fmt == 'u') {
      unsigned int x = va_arg(ap, unsigned int);
      char buf[16];
      char *q = buf + sizeof(buf);
      do {
        *--q = '0' + x % 10;
        x /= 10;
      } while (x > 0);
      int digits = (int)(buf + sizeof(buf) - q);
      for (int i = digits; i < width; i++) { putch(pad_char); count++; }
      while (q < buf + sizeof(buf)) {
        putch(*q++);
        count++;
      }
    }
    else if (*fmt == 's') {
      const char *s = va_arg(ap, const char *);
      while (*s != '\0') {
        putch(*s++);
        count++;
      }
    }

    else if(*fmt == 'c') {
      char c = (char)va_arg(ap, int); // char 会被提升为 int
      putch(c);
      count++;
    }
    else {
      panic("unsupported format");
    }
  }

  va_end(ap);
  return count;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);

  char *p = out;
  for( ; *fmt != '\0'; fmt++) {
    if (*fmt != '%') {
      *p++ = *fmt;
      continue;
    }
    fmt++;
    if (*fmt == 'd') {
      int x = va_arg(ap, int);
      if (x < 0) {
        *p++ = '-';
        x = -x;
      }
      char buf[16];
      char *q = buf + sizeof(buf);
      do {
        *--q = '0' + x % 10;
        x /= 10;
      } while (x > 0);
      while (q < buf + sizeof(buf)) {
        *p++ = *q++;
      }
    }
    else if (*fmt == 's') {
      const char *s = va_arg(ap, const char *);
      while (*s != '\0') {
        *p++ = *s++;
      }
    }
    else {
      panic("unsupported format");
    }
  }

  *p = '\0';
  return p - out;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
