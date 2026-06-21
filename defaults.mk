## This file contains default values for user-defined variables.

#------------------------------------------------------------------------------
# Source and include directories
#------------------------------------------------------------------------------
# White-space separated list of paths where source files are.
SRC_DIRS ?=

# White-space separated list of paths where header files are.
INC_DIRS ?=

#------------------------------------------------------------------------------
# Compiler and toolchain selection
#------------------------------------------------------------------------------

# Toolchain used to compile.
# Compile commands will have the value of the toolchain prepended.
# E.g.: arm-none-eabi-, arm-linux-gnueabihf-, (left empty), etc
CROSS_COMPILE ?=

# C compiler, used to compile a ".c" file into an object file ".o"
ifeq ($(origin CC), default)
CC := gcc
endif

# Assembler, used to compile an ".S" or ".s" file into an object file ".o"
ifeq ($(origin AS), default)
AS := as
endif

# Linker, used when merging all object files into an executable file ".elf"
ifeq ($(origin LD), default)
LD := gcc
endif

# GDB debugger
# If $(CROSS_COMPILE)$(GDB) exists, it will be used.
# Otherwise, the binary defined here will be used instead.
GDB ?= gdb

# Objdump binutil, used to create disassembly files and section headers
OBJDUMP	?= objdump

# Objcopy binutil, used to create stripped .bin and .hex files from .elf files
OBJCOPY ?= objcopy

#------------------------------------------------------------------------------
# Compiler, assembler and linker flags
#------------------------------------------------------------------------------
# C compiler flags
CFLAGS ?= -Wall -g -Wpedantic

# Assembler flags
ASFLAGS ?= $(CFLAGS)

# Linker flags
LDFLAGS ?= -g

# Linker script (if any)
LDSCRIPT ?=

# GDB flags.
# The following flags are always added to the GDB command by default:
# -q
# -x $(GDB_SCRIPT)
GDBFLAGS ?=

# Name of the gdb script (if any)
GDB_SCRIPT ?=

#------------------------------------------------------------------------------
# Extra variables
#------------------------------------------------------------------------------
# Name of the executable ".elf" file (without extension)
EXE ?= exe
