#------------------------------------------------------------------------------
# Makefile Initialization
#------------------------------------------------------------------------------
SHELL=/bin/bash
.DELETE_ON_ERROR:
.SILENT:
.DEFAULT_GOAL := help

GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),$(.DEFAULT_GOAL))

#------------------------------------------------------------------------------
# Includes
#------------------------------------------------------------------------------

include colors.mk
include constants.mk
include messages.mk

#------------------------------------------------------------------------------
# Default variables
# All these variables can be modified before including this Makefile
#------------------------------------------------------------------------------

# White-space separated list of paths where source files are
SRC_DIRS ?=


# E.g.: arm-none-eabi-, arm-linux-gnueabihf-, (left empty), etc
TOOLCHAIN ?=

# Repository's root directory. All relative paths will be taken from this path.
ROOT ?= .


INC_DIRS ?=

CFLAGS ?= -Wall -g -Wpedantic
ASFLAGS ?= -g
LDFLAGS ?= -g

# Linker script (can be empty)
LDSCRIPT ?=

# Name of the final executable (without extension)
EXE ?= exe

# Name of the gdb script (can be empty)
GDB_SCRIPT ?=

include arg_check.mk

#------------------------------------------------------------------------------
# Binutils
#------------------------------------------------------------------------------
ifeq ($(origin CC), default)
CC := $(TOOLCHAIN)gcc
else
CC ?= $(TOOLCHAIN)gcc
endif
ifeq ($(origin AS), default)
AS := $(TOOLCHAIN)as
else
AS ?= $(TOOLCHAIN)as
endif
LD 			:= $(TOOLCHAIN)gcc
OBJDUMP 	:= $(TOOLCHAIN)objdump
OBJCOPY 	:= $(TOOLCHAIN)objcopy

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------
BUILD_DIR	:= build
INFO_DIR 	:= info
ELF 		:= $(BUILD_DIR)/$(EXE).elf
BIN 		:= $(BUILD_DIR)/$(EXE).bin
MAP			:= $(BUILD_DIR)/$(INFO_DIR)/memory.map

COMPILE_COMMANDS := $(BUILD_DIR)/compile_commands.json
SCAN_BUILD_DIR := $(BUILD_DIR)/scan_build

# If you use "ld" or "gcc" as linker, the memory map option is declared different
ifneq (,$(findstring -ld, $(LD)))
LDFLAGS += -Map $(MAP)
else
LDFLAGS += -Wl,-Map=$(MAP)
endif

# If you are using a custom linker script, don't use the default crt0.S files
ifneq (,$(LDSCRIPT))
LDFLAGS += -T $(LDSCRIPT)
endif

SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c) $(wildcard $(dir)/*.s))

HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.h) $(wildcard $(dir)/*.s))
HEADER_FLAGS := $(addprefix -I , $(INC_DIRS))

OBJS := $(patsubst /%,%, $(SRCS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %.o, $(OBJS))

OBJ_HEADERS := $(patsubst %.o, %.header, $(OBJS) $(ELF))
OBJ_HEADERS := $(patsubst %.elf, %.header, $(OBJ_HEADERS))
OBJ_HEADERS := $(patsubst $(BUILD_DIR)%, $(BUILD_DIR)/$(INFO_DIR)%, $(OBJ_HEADERS))

DIS_ASM := $(patsubst %.header, %.d, $(OBJ_HEADERS))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))
INFO_SRC_DIRS := $(addprefix $(BUILD_DIR)/$(INFO_DIR)/, $(SRC_DIRS))

SRCS := $(sort $(SRCS))
OBJS := $(sort $(OBJS))

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------

# When you call "make compile", the Makefile will be re-called but prepending
# the "scan-build bear -- make p_compile"
.PHONY: compile ## Compile all source code, generate ELF file.
compile: $(BUILD_SRC_DIRS)
# if [ ! -f $(COMPILE_COMMANDS) ]; then \
# 	scan-build -o $(SCAN_BUILD_DIR) bear --output $(COMPILE_COMMANDS) -- $(MAKE) p_compile; \
# else \
# 	scan-build --use-cc=$(CC) -o $(SCAN_BUILD_DIR) -V $(MAKE) p_compile; \
# fi
	if [ ! -f $(COMPILE_COMMANDS) ]; then \
		bear --output $(COMPILE_COMMANDS) -- $(MAKE) p_compile; \
	else \
		$(MAKE) p_compile; \
	fi
	$(MAKE) tidy


# Actual compile command
.PHONY: p_compile ## Private compile command
p_compile: $(ELF)

.PHONY: tidy ## Do static analysis with clang-tidy
tidy: $(SRCS)
	clang-tidy --verify-config
	clang-tidy $^ -p $(COMPILE_COMMANDS)

.PHONY: help ## Display this message.
help:
	grep -E '^\.PHONY:.*## .*$$' Makefile *.mk \
	| sort \
	| awk 'BEGIN {FS=":|## "}; \
	       {gsub(/^[ \t]+|[ \t]+$$/, "", $$3); \
	        printf "$(CYAN)%-12s$(NC) %s\n", $$3, $$4}'

.PHONY: binary ## Generate binary file, without ELF headers.
binary: $(BIN)

.PHONY: headers ## Generate symbol table and section headers for all object files.
headers: $(OBJ_HEADERS)

.PHONY: dasm ## Generate disassemble for all object files and elf file.
dasm: $(DIS_ASM)

.PHONY: clean ## Erase contents of build directory.
clean:
	rm -Rf $(BUILD_DIR)
	echo -n "All files successfully erased "; $(PRINT_CHECKMARK)

.PHONY: run ## Execute compile program
run: compile
	$(ELF)

.PHONY: debug ## Debug with gdb
debug: compile
	gdb $(ELF)

.PHONY: test ## Compile and execute tests
test: compile
	$(MAKE) -f test.mk \
		BUILD_DIR="$(BUILD_DIR)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)" \
		CC="$(CC)" \
		LD="$(LD)" \
		HEADER_FLAGS="$(HEADER_FLAGS)"

include print_targets.mk

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Main executable linking
$(ELF): $(OBJS)
	echo -n "Linking everything together... "
	mkdir -p $(BUILD_DIR)/$(INFO_DIR)
	$(LD) -o $@ $^ $(LDFLAGS)
	$(PRINT_CHECKMARK)
	echo "Executable file \"$@\" successfully created."

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(HEADERS) Makefile $(LDSCRIPT) $(BUILD_SRC_DIRS)
	echo -n "Compiling $< --> $@... "
	$(CC) $(CFLAGS) $(HEADER_FLAGS) -o $@ -c $<
	$(PRINT_CHECKMARK)

# Compiling object files from asm sources
$(BUILD_DIR)/%.o: %.s $(HEADERS) Makefile $(LDSCRIPT) $(BUILD_SRC_DIRS)
	echo -n "Assembling $< --> $@... "
	$(AS) $(ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<
	$(PRINT_CHECKMARK)

# Print object files' headers
$(BUILD_DIR)/$(INFO_DIR)/%.header: $(BUILD_DIR)/%.o $(INFO_SRC_DIRS)
	echo -n "Printing $< -> $@... "
	$(OBJDUMP) -x $< > $@
	$(PRINT_CHECKMARK)

# Print elf file's header
$(BUILD_DIR)/$(INFO_DIR)/%.header: $(BUILD_DIR)/%.elf $(INFO_SRC_DIRS)
	echo -n "Printing $< -> $@... "
	$(OBJDUMP) -x $< > $@
	$(PRINT_CHECKMARK)

# Print object files' disassembly
$(BUILD_DIR)/$(INFO_DIR)/%.d: $(BUILD_DIR)/%.o $(INFO_SRC_DIRS)
	echo -n "Disassembling $< -> $@... "
	$(OBJDUMP) -d $< > $@
	$(PRINT_CHECKMARK)

# Print elf file disassembly
$(BUILD_DIR)/$(INFO_DIR)/%.d: $(BUILD_DIR)/%.elf $(INFO_SRC_DIRS)
	echo -n "Disassembling $< -> $@... "
	$(OBJDUMP) -d $< > $@
	$(PRINT_CHECKMARK)

# Copy ELF file into BIN file
$(BIN): $(ELF)
	echo -n "Creating binary file $@... "
	$(OBJCOPY) -O binary $(ELF) $(BIN)
	$(PRINT_CHECKMARK)

# Folders
$(BUILD_SRC_DIRS) $(INFO_SRC_DIRS) $(BUILD_DIR)/$(INFO_DIR):
	mkdir -p $@
