/*
  stepper_28byj48.c - 28BYJ-48 + ULN2003 half-step coil drive for STM32
  Ported from grbl-28byj-48/grbl/stepper.c coil sequencing logic.

  Wiring (Blue Pill):
    X axis ULN2003 IN1..IN4 -> PA0, PA1, PA2, PA3
    Y axis ULN2003 IN1..IN4 -> PA4, PA5, PA6, PA7
    Z axis ULN2003 IN1..IN4 -> PB0, PB1, PB8, PB9
*/

#include "grbl.h"

#ifdef USE_28BYJ48

#ifdef STM32F103C8
#include "stm32f10x_rcc.h"
#include "stm32f10x_gpio.h"
#endif

// 8-state half-step patterns (IN4..IN1 as bits 3..0), same as grbl-28byj-48 Y axis table.
static const uint8_t half_step_nibble[8] = {0x8, 0xC, 0x4, 0x6, 0x2, 0x3, 0x1, 0x9};

// Phase index 1..8 per axis (matches original fork's costyx/costyy/costyz).
static uint8_t coil_phase[N_AXIS] = {1, 1, 1};

// Z uses non-contiguous pins PB0, PB1, PB8, PB9 (like Arduino Z on PB0,1,4,5).
static const uint16_t z_coil_odr[8] = {
  (1 << 9),
  (1 << 9) | (1 << 8),
  (1 << 8),
  (1 << 8) | (1 << 1),
  (1 << 1),
  (1 << 1) | (1 << 0),
  (1 << 0),
  (1 << 9) | (1 << 0)
};

static void coils_write_contiguous(GPIO_TypeDef *port, uint16_t mask, uint8_t pin_base, uint8_t phase_idx)
{
  uint16_t pattern = ((uint16_t)half_step_nibble[phase_idx]) << pin_base;
  port->ODR = (port->ODR & ~mask) | pattern;
}

void stepper_28byj48_coils_off(void)
{
#ifdef STM32F103C8
  X_COIL_PORT->ODR &= ~X_COIL_MASK;
  Y_COIL_PORT->ODR &= ~Y_COIL_MASK;
  Z_COIL_PORT->ODR &= ~Z_COIL_MASK;
#endif
}

void stepper_28byj48_init(void)
{
#ifdef STM32F103C8
  GPIO_InitTypeDef gpio;
  gpio.GPIO_Speed = GPIO_Speed_50MHz;
  gpio.GPIO_Mode = GPIO_Mode_Out_PP;

  RCC_APB2PeriphClockCmd(RCC_COIL_PORT_A | RCC_COIL_PORT_B, ENABLE);

  gpio.GPIO_Pin = X_COIL_MASK | Y_COIL_MASK;
  GPIO_Init(X_COIL_PORT, &gpio);

  gpio.GPIO_Pin = Z_COIL_MASK;
  GPIO_Init(Z_COIL_PORT, &gpio);

  stepper_28byj48_coils_off();
#endif
}

bool stepper_28byj48_axis_allowed(uint8_t step_bit)
{
  if (sys.state == STATE_HOMING) {
    if (!(sys.homing_axis_lock & (1 << step_bit))) {
      return false;
    }
  }
  return true;
}

void stepper_28byj48_step(uint8_t axis, bool reverse)
{
  uint8_t idx;

  if (reverse) {
    coil_phase[axis]--;
    if (coil_phase[axis] < 1) {
      coil_phase[axis] = 8;
    }
  } else {
    coil_phase[axis]++;
    if (coil_phase[axis] > 8) {
      coil_phase[axis] = 1;
    }
  }

  idx = coil_phase[axis] - 1;

  switch (axis) {
    case X_AXIS:
      coils_write_contiguous(X_COIL_PORT, X_COIL_MASK, X_COIL_PIN_BASE, idx);
      break;
    case Y_AXIS:
      coils_write_contiguous(Y_COIL_PORT, Y_COIL_MASK, Y_COIL_PIN_BASE, idx);
      break;
    case Z_AXIS:
      Z_COIL_PORT->ODR = (Z_COIL_PORT->ODR & ~Z_COIL_MASK) | z_coil_odr[idx];
      break;
    default:
      break;
  }
}
#endif

