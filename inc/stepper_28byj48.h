/*
  stepper_28byj48.h - 28BYJ-48 + ULN2003 half-step coil drive
*/

#ifndef stepper_28byj48_h
#define stepper_28byj48_h

#include "grbl.h"

void stepper_28byj48_init(void);
void stepper_28byj48_coils_off(void);
void stepper_28byj48_step(uint8_t axis, bool reverse);
bool stepper_28byj48_axis_allowed(uint8_t step_bit);

#endif
