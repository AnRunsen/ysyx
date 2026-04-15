#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);


  uint32_t count = 0;
  for( ; *fmt != '\0'; fmt++) {
    count++;
    if (*fmt != '%') {
      putch(*fmt);
      continue;
    }
    fmt++;
    if (*fmt == 'd') {
      int x = va_arg(ap, int);
      if (x < 0) {
        putch('-');
        x = -x;
      }
      char buf[16];
      char *q = buf + sizeof(buf);
      do {
        *--q = '0' + x % 10;
        x /= 10;
      } while (x > 0);
      while (q < buf + sizeof(buf)) {
        putch(*q++);
      }
    }
    else if (*fmt == 's') {
      const char *s = va_arg(ap, const char *);
      while (*s != '\0') {
        putch(*s++);
      }
    }
    else {
      panic("unsupported format");
    }
  }

  return count+1;
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
