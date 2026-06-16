# GRBL Blue Pill Stepper

Grbl **1.1f** for **STM32F103C8 (Blue Pill)** driving **28BYJ-48 + ULN2003** motors in half-step mode. Built for simple **XY pen plotters**.

Based on [GRBL32](https://github.com/terjeio/grbl32) (YSV).

## Features

- 3-axis XYZ G-code motion (Grbl 1.1f)
- 28BYJ-48 via ULN2003 (8-step half-step coil sequencing)
- Serial: **USART1 @ 115200 baud**
- Build with **Make** or **PlatformIO**

## Wiring

### Blue Pill ↔ USB-UART

| Function | Pin | Connect to |
|----------|-----|------------|
| TX | PA9 | USB-UART RX |
| RX | PA10 | USB-UART TX |
| GND | GND | USB-UART GND |

### Motors (28BYJ-48 + ULN2003)

| Axis | MCU pins | ULN2003 |
|------|----------|---------|
| X | PA0 – PA3 | IN1 – IN4 |
| Y | PA4 – PA7 | IN1 – IN4 |
| Z (optional) | PB0, PB1, PB8, PB9 | IN1 – IN4 |

**Notes**

- Common **GND** between Blue Pill and all ULN2003 boards.
- Motor power: separate **5 V** supply (not from the 3.3 V pin).
- BOOT0 jumper: **0** (run from flash).
- Flash via **ST-LINK (SWD)** or USB-UART bootloader.

```
USB-UART          Blue Pill          ULN2003 (X)
────────          ─────────          ────────────
    RX ────────── PA9 (TX)
    TX ────────── PA10 (RX)
   GND ────────── GND ───────────── GND
                   PA0..PA3 ─────── IN1..IN4
```

## Configuration

Defaults are set in `inc/config.h`:

```c
#define DEFAULTS_PLOTTER
```

Tune steps/mm and speeds in `inc/defaults.h` (`DEFAULTS_PLOTTER` block), or over serial after flashing (`$100`, `$101`, …).

Coil pin assignments: `inc/cpu_map.h` (under `CPU_MAP_STM32F103`).

USB serial instead of USART: `make USEUSB=1` or `-DUSEUSB` in `platformio.ini`.

After firmware or default changes, reset EEPROM:

```text
$RST=$
```

## Build

### Prerequisites

```bash
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi stlink-tools
```

### Make

```bash
make info
make
make size
```

Toolchain: `GCC_PATH` → `PATH` → PlatformIO fallback.

```bash
make GCC_PATH=/usr/bin
make DEBUG=1
make USEUSB=1
```

Output: `Release/GRBL32_F103C8_PLOTTER_USART_115200.hex`

### PlatformIO

```bash
pio run
pio run -t upload
```

## Flash

```bash
make flash         # write .hex
make upload        # write .bin to 0x08000000
make erase         # mass erase
```

Manual:

```bash
st-flash --reset write Release/GRBL32_F103C8_PLOTTER_USART_115200.hex
```

## Quick start

```bash
screen /dev/ttyUSB0 115200
```

```text
$RST=$       ; reset settings (first flash)
$X           ; unlock alarm if needed
?            ; status
$$           ; view settings
```

Calibrate travel: move a known distance, then adjust `$100` / `$101`.

## License

- [Grbl](https://github.com/gnea/grbl) — GPL v3
- GRBL32 STM32 port — YSV
- Coil sequencing — adapted from grbl-28byj-48 (Arduino)

---

# GRBL Blue Pill Stepper (RU)

Прошивка **Grbl 1.1f** для **STM32F103C8 (Blue Pill)** с двигателями **28BYJ-48 + ULN2003** (полушаг). Для простых **XY плоттеров**.

Основано на [GRBL32](https://github.com/terjeio/grbl32) (YSV).

## Возможности

- 3 оси XYZ, G-code (Grbl 1.1f)
- 28BYJ-48 через ULN2003 (8 полушагов)
- Последовательный порт: **USART1, 115200 бод**
- Сборка: **Make** или **PlatformIO**

## Подключение

### Blue Pill ↔ USB-UART

| Назначение | Вывод | Подключение |
|------------|-------|-------------|
| TX | PA9 | RX адаптера |
| RX | PA10 | TX адаптера |
| GND | GND | GND адаптера |

### Моторы (28BYJ-48 + ULN2003)

| Ось | Выводы МК | ULN2003 |
|-----|-----------|---------|
| X | PA0 – PA3 | IN1 – IN4 |
| Y | PA4 – PA7 | IN1 – IN4 |
| Z (опционально) | PB0, PB1, PB8, PB9 | IN1 – IN4 |

**Важно**

- Общий **GND** для Blue Pill и ULN2003.
- Питание моторов — отдельный **5 В** (не с 3.3 В МК).
- BOOT0: **0** (загрузка из flash).
- Прошивка: **ST-LINK (SWD)** или USB-UART bootloader.

## Конфигурация

В `inc/config.h`:

```c
#define DEFAULTS_PLOTTER
```

Параметры шагов/мм и скоростей — в `inc/defaults.h` или через serial (`$100`, `$101`, …).

Выводы обмоток: `inc/cpu_map.h`.

USB вместо USART: `make USEUSB=1`.

После смены прошивки:

```text
$RST=$
```

## Сборка

```bash
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi stlink-tools
make
```

Результат: `Release/GRBL32_F103C8_PLOTTER_USART_115200.hex`

```bash
pio run
```

## Прошивка

```bash
make flash
```

```bash
st-flash --reset write Release/GRBL32_F103C8_PLOTTER_USART_115200.hex
```

## Быстрый старт

```bash
screen /dev/ttyUSB0 115200
```

```text
$RST=$
$X
?
$$
```

Калибровка: переместите ось на известное расстояние, настройте `$100` / `$101`.

## Лицензия

- [Grbl](https://github.com/gnea/grbl) — GPL v3
- Порт GRBL32 — YSV
- Управление обмотками — адаптация из grbl-28byj-48 (Arduino)
