SRC_DIRS ?= src startup
INC_DIRS ?= inc

CROSS_COMPILE ?= arm-none-eabi-

CC ?= gcc

CFLAGS ?= -Wall -g -marm -mcpu=cortex-a8 -mfloat-abi=softfp
LDFLAGS ?= -nostartfiles -Wl,--gc-sections

LDSCRIPT ?= linker_script.ld

GDB ?= gdb-multiarch
GDBSCRIPT ?= debug_interactive.gdb

BUILD_DIR ?= build
EXE ?= exe

SIM ?= qemu-system-arm

define _SIMFLAGS
-M realview-pb-a8 \
-m 32M \
-no-reboot -nographic \
-monitor stdio \
-serial telnet:localhost:2222,server,nowait \
-S -gdb tcp:localhost:2159 \
-device loader,file=$(BUILD_DIR)/$(EXE).elf
endef

SIMFLAGS ?= $(_SIMFLAGS)

include ../../cottimake.mk