/*
  newlib_stub.c - errno stub for standalone Makefile builds (weak: ignored if libc provides it)
*/

#include <errno.h>

static int _errno_value;

__attribute__((weak)) int *__errno(void)
{
  return &_errno_value;
}
