# GRBL Blue Pill (STM32F103C8) — standalone Makefile
# Mirrors platformio.ini. Requires arm-none-eabi-gcc (no PlatformIO required).

######################################
# Target / options
######################################
MCU        = cortex-m3
F_CPU      = 72000000

# debug build: make DEBUG=1
DEBUG     ?= 0
# optimization: -Os (default), -O2, -O3 ...
OPT       ?= -Os

# USB CDC serial instead of USART1: make USEUSB=1
USEUSB    ?= 0

ifeq ($(USEUSB), 1)
  TARGET  = GRBL32_F103C8_PLOTTER_USB
else
  TARGET  = GRBL32_F103C8_PLOTTER_USART_115200
endif

######################################
# Toolchain (priority: GCC_PATH > PATH > PlatformIO fallback)
######################################
# GCC_PATH = directory containing arm-none-eabi-gcc (like Makefile_old)
#   example: make GCC_PATH=/usr/bin
#   example: make GCC_PATH=/opt/gcc-arm-none-eabi-10.3-2021.10/bin
#
# PREFIX overrides everything:
#   example: make PREFIX=/opt/.../bin/arm-none-eabi-

DEFAULT_PREFIX := arm-none-eabi-

ifdef GCC_PATH
  DETECTED_PREFIX := $(GCC_PATH)/$(DEFAULT_PREFIX)
else
  DETECTED_PREFIX := $(DEFAULT_PREFIX)
  ifeq ($(shell command -v $(DETECTED_PREFIX)gcc 2>/dev/null),)
    PIO_BIN := $(HOME)/.platformio/packages/toolchain-gccarmnoneeabi@1.70201.0/bin
    ifneq ($(wildcard $(PIO_BIN)/$(DEFAULT_PREFIX)gcc),)
      DETECTED_PREFIX := $(PIO_BIN)/$(DEFAULT_PREFIX)
    endif
  endif
endif

PREFIX    ?= $(DETECTED_PREFIX)

CC         = $(PREFIX)gcc
AS         = $(PREFIX)gcc -x assembler-with-cpp
OBJCOPY    = $(PREFIX)objcopy
OBJDUMP    = $(PREFIX)objdump
SIZE       = $(PREFIX)size

BUILD_DIR   = build
RELEASE_DIR = Release
LDSCRIPT    = linker/stm32_flash.ld
FLASH       = st-flash

######################################
# Sources
######################################
GRBL_SRC      = $(wildcard src/*.c)
ASM_SRC       = $(wildcard src/*.s)
UTIL_SRC      = $(wildcard util/*.c)
USB_SRC       = $(wildcard usb/*.c)
USB_LIB       = $(wildcard stm_usb_fs_lib/src/*.c)
STDPeriph_SRC = $(wildcard Libraries/STM32F10x_StdPeriph_Driver/src/*.c)

SRCS = $(GRBL_SRC) $(UTIL_SRC) $(USB_SRC) $(USB_LIB) $(STDPeriph_SRC)
OBJS = $(SRCS:%.c=$(BUILD_DIR)/%.o) $(ASM_SRC:%.s=$(BUILD_DIR)/%.o)
DEPS = $(OBJS:.o=.d)

######################################
# Flags
######################################
INCLUDES = \
	-Iinc \
	-Iutil \
	-Iusb \
	-Istm_usb_fs_lib/inc \
	-ILibraries/CMSIS/Include \
	-ILibraries/CMSIS/Device/ST/STM32F10x/Include \
	-ILibraries/STM32F10x_StdPeriph_Driver/inc

DEFINES = \
	-DSTM32F10X_MD \
	-DUSE_STDPERIPH_DRIVER \
	-DSTM32F103C8 \
	-DF_CPU=$(F_CPU)

ifeq ($(USEUSB), 1)
  DEFINES += -DUSEUSB
endif

ifeq ($(DEBUG), 1)
  OPTFLAGS = -Og -g3
else
  OPTFLAGS = $(OPT) -g
endif

CFLAGS = $(OPTFLAGS) -Wall -Wno-int-in-bool-context \
	-ffunction-sections -fdata-sections \
	-mthumb -mcpu=$(MCU) \
	-fno-math-errno \
	$(DEFINES) $(INCLUDES) \
	-specs=nosys.specs -specs=nano.specs \
	-MMD -MP

LDFLAGS = -T$(LDSCRIPT) -mthumb -mcpu=$(MCU) \
	-specs=nosys.specs -specs=nano.specs \
	-Wl,--gc-sections -Wl,-Map=$(BUILD_DIR)/$(TARGET).map \
	-lm

######################################
# Outputs
######################################
ELF = $(BUILD_DIR)/$(TARGET).elf
HEX = $(RELEASE_DIR)/$(TARGET).hex
BIN = $(RELEASE_DIR)/$(TARGET).bin

.PHONY: all hex bin size clean distclean upload flash erase openocd info check-toolchain

all: check-toolchain hex size

hex: $(HEX)
bin: $(BIN)

check-toolchain:
	@test -n "$(shell command -v $(CC) 2>/dev/null)" || ( \
		echo "ERROR: $(CC) not found."; \
		echo "Install: sudo apt install gcc-arm-none-eabi"; \
		echo "Or set:  make GCC_PATH=/path/to/bin"; \
		exit 1)

info:
	@echo "TARGET   = $(TARGET)"
	@echo "USEUSB   = $(USEUSB)"
	@echo "DEBUG    = $(DEBUG)"
	@echo "OPT      = $(OPT)"
	@echo "CC       = $(CC)"
	@$(CC) --version | head -1

$(HEX): $(ELF) | $(RELEASE_DIR)
	$(OBJCOPY) -O ihex $< $@
	@echo "HEX: $@"

$(BIN): $(ELF) | $(RELEASE_DIR)
	$(OBJCOPY) -O binary $< $@
	@echo "BIN: $@"

$(ELF): $(OBJS) | $(BUILD_DIR)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)
	@echo "ELF: $@"

$(BUILD_DIR)/%.o: %.c Makefile | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.s Makefile | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(AS) $(CFLAGS) -c $< -o $@

$(BUILD_DIR) $(RELEASE_DIR):
	mkdir -p $@

size: $(ELF)
	$(SIZE) --format=berkeley $<

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf $(RELEASE_DIR)

# Flash (ihex) — same workflow as Makefile_old
flash: check-toolchain $(HEX)
	$(FLASH) --reset --format ihex write $(HEX)

# Flash (binary)
upload: check-toolchain $(BIN)
	$(FLASH) --reset write $(BIN) 0x08000000

erase:
	$(FLASH) erase

openocd: check-toolchain $(ELF)
	openocd -f interface/stlink.cfg -f target/stm32f1x.cfg \
		-c "program $(ELF) verify reset exit"

-include $(DEPS)
