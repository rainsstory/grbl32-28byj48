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

Прошивка **Grbl 1.1f** для **STM32F103C8 (Blue Pill)** с двигателями **28BYJ-48 + ULN2003** (полушаговый режим). Предназначена для простых **XY плоттеров**.

Основано на [GRBL32](https://github.com/terjeio/grbl32) (YSV).

## Возможности

- 3 оси XYZ, G-code (Grbl 1.1f)
- 28BYJ-48 через ULN2003 (8 полушагов, управление обмотками)
- Последовательный порт: **USART1, 115200 бод**
- Сборка через **Make** или **PlatformIO**

## Подключение

### Blue Pill ↔ USB-UART

| Назначение | Вывод | Подключение |
|------------|-------|-------------|
| TX | PA9 | RX USB-UART |
| RX | PA10 | TX USB-UART |
| GND | GND | GND USB-UART |

### Моторы (28BYJ-48 + ULN2003)

| Ось | Выводы МК | ULN2003 |
|-----|-----------|---------|
| X | PA0 – PA3 | IN1 – IN4 |
| Y | PA4 – PA7 | IN1 – IN4 |
| Z (опционально) | PB0, PB1, PB8, PB9 | IN1 – IN4 |

**Важно**

- Общий **GND** для Blue Pill и всех плат ULN2003.
- Питание моторов — отдельный источник **5 В** (не с вывода 3.3 В МК).
- Перемычка BOOT0: **0** (загрузка из flash).
- Прошивка через **ST-LINK (SWD)** или USB-UART bootloader.

```
USB-UART          Blue Pill          ULN2003 (X)
────────          ─────────          ────────────
    RX ────────── PA9 (TX)
    TX ────────── PA10 (RX)
   GND ────────── GND ───────────── GND
                   PA0..PA3 ─────── IN1..IN4
```

## Конфигурация

Параметры по умолчанию задаются в `inc/config.h`:

```c
#define DEFAULTS_PLOTTER
```

Шаги/мм и скорости настраиваются в `inc/defaults.h` (блок `DEFAULTS_PLOTTER`) или через serial после прошивки (`$100`, `$101`, …).

Назначение выводов обмоток: `inc/cpu_map.h` (в блоке `CPU_MAP_STM32F103`).

USB вместо USART: `make USEUSB=1` или `-DUSEUSB` в `platformio.ini`.

После смены прошивки или значений по умолчанию сбросьте EEPROM:

```text
$RST=$
```

## Сборка

### Зависимости

```bash
sudo apt install gcc-arm-none-eabi binutils-arm-none-eabi stlink-tools
```

### Make

```bash
make info
make
make size
```

Порядок выбора toolchain: `GCC_PATH` → `PATH` → PlatformIO (резерв).

```bash
make GCC_PATH=/usr/bin
make DEBUG=1
make USEUSB=1
```

Результат: `Release/GRBL32_F103C8_PLOTTER_USART_115200.hex`

### PlatformIO

```bash
pio run
pio run -t upload
```

## Прошивка

```bash
make flash         # записать .hex
make upload        # записать .bin по адресу 0x08000000
make erase         # полное стирание
```

Вручную:

```bash
st-flash --reset write Release/GRBL32_F103C8_PLOTTER_USART_115200.hex
```

## Быстрый старт

```bash
screen /dev/ttyUSB0 115200
```

```text
$RST=$       ; сброс настроек (первая прошивка)
$X           ; снять аварию при необходимости
?            ; статус
$$           ; просмотр настроек
```

Калибровка хода: переместите ось на известное расстояние, затем настройте `$100` / `$101`.

## Лицензия

- [Grbl](https://github.com/gnea/grbl) — GPL v3
- Порт GRBL32 для STM32 — YSV
- Управление обмотками — адаптация из grbl-28byj-48 (Arduino)
