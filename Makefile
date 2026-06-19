#------------------------------------------------------------------------------
# Makefile Initialization
#------------------------------------------------------------------------------
SHELL=/bin/bash
.DELETE_ON_ERROR:
.SILENT:
.DEFAULT_GOAL := help

GOALS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),$(.DEFAULT_GOAL))

# Repository's MAKE_ROOT directory. All relative paths will be taken from this path.
MAKE_ROOT ?= .

MAKE_ROOT := $(patsubst %/,%, $(MAKE_ROOT))

#------------------------------------------------------------------------------
# Includes
#------------------------------------------------------------------------------

include $(MAKE_ROOT)/colors.mk
include $(MAKE_ROOT)/constants.mk
include $(MAKE_ROOT)/messages.mk

#------------------------------------------------------------------------------
# Default variables
# All these variables can be modified before including this Makefile
#------------------------------------------------------------------------------

# White-space separated list of paths where source files are
SRC_DIRS ?=


# E.g.: arm-none-eabi-, arm-linux-gnueabihf-, (left empty), etc
TOOLCHAIN ?=




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

include $(MAKE_ROOT)/arg_check.mk

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
INFO_DIR 	:= $(BUILD_DIR)/info
ELF 		:= $(BUILD_DIR)/$(EXE).elf
BIN 		:= $(BUILD_DIR)/$(EXE).bin
MAP			:= $(INFO_DIR)/memory.map

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

# TODO add _asm to assembly object files
OBJS := $(patsubst /%,%, $(SRCS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %.o, $(OBJS))

OBJ_HEADERS := $(patsubst %.o, %.header, $(OBJS) $(ELF))
OBJ_HEADERS := $(patsubst %.elf, %.header, $(OBJ_HEADERS))
OBJ_HEADERS := $(patsubst $(BUILD_DIR)%, $(INFO_DIR)%, $(OBJ_HEADERS))

DASM_FILES := $(patsubst %.header, %.d, $(OBJ_HEADERS))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))
INFO_SRC_DIRS := $(addprefix $(INFO_DIR)/, $(SRC_DIRS))

SRCS := $(sort $(SRCS))
OBJS := $(sort $(OBJS))

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------

# When you call "make compile", the Makefile will be re-called but prepending
# the "scan-build bear -- make p_compile"
# .PHONY: compile ## Compile all source code, generate ELF file.
# compile: $(BUILD_SRC_DIRS)
# # if [ ! -f $(COMPILE_COMMANDS) ]; then \
# # 	scan-build -o $(SCAN_BUILD_DIR) bear --output $(COMPILE_COMMANDS) -- $(MAKE) p_compile; \
# # else \
# # 	scan-build --use-cc=$(CC) -o $(SCAN_BUILD_DIR) -V $(MAKE) p_compile; \
# # fi
# 	if [ ! -f $(COMPILE_COMMANDS) ]; then \
# 		bear --output $(COMPILE_COMMANDS) -- $(MAKE) p_compile; \
# 	else \
# 		$(MAKE) p_compile; \
# 	fi
# 	$(MAKE) tidy

.PHONY: compile ## Private compile command
compile:
	if $(MAKE) --no-print-directory -q $(ELF); then \
		printf "$(MSG_COMPILE_DO_NOTHING)"; \
	else \
		$(MAKE) --no-print-directory $(ELF); \
		printf "$(MSG_COMPILE_OK)"; \
	fi

.PHONY: tidy ## Do static analysis with clang-tidy
tidy: $(SRCS)
	clang-tidy --verify-config
	clang-tidy $^ -p $(COMPILE_COMMANDS)

.PHONY: help ## Display this message.
help:
	grep -E '^\.PHONY:.*## .*$$' $(MAKE_ROOT)/Makefile $(MAKE_ROOT)/*.mk \
	| sort \
	| awk 'BEGIN {FS=":|## "}; \
	       {gsub(/^[ \t]+|[ \t]+$$/, "", $$3); \
	        printf "$(CYAN)%-12s$(NC) %s\n", $$3, $$4}'

.PHONY: bin ## Generate binary file, without ELF headers.
bin:
	if $(MAKE) --no-print-directory -q $(BIN); then \
		printf "$(MSG_COMPILE_DO_NOTHING)"; \
	else \
		$(MAKE) --no-print-directory $(BIN); \
		printf "$(MSG_COMPILE_OK)"; \
	fi

.PHONY: headers ## Generate symbol table and section headers for all object files.
headers: 
	if $(MAKE) --no-print-directory -q $(OBJ_HEADERS); then \
		printf "$(MSG_HEADERS_DO_NOTHING)"; \
	else \
		$(MAKE) --no-print-directory $(OBJ_HEADERS); \
	fi

.PHONY: dasm ## Generate disassemble for all object files and elf file.
dasm:
	if $(MAKE) --no-print-directory -q $(DASM_FILES); then \
		printf "$(MSG_DASM_DO_NOTHING)"; \
	else \
		$(MAKE) --no-print-directory $(DASM_FILES); \
	fi

.PHONY: clean ## Erase contents of build directory.
clean:
	if [ -d "$(BUILD_DIR)" ]; then \
		rm -Rf $(BUILD_DIR); \
		printf "$(MSG_CLEAN_OK)"; \
	else \
		printf "$(MSG_CLEAN_EMPTY)"; \
	fi

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

include $(MAKE_ROOT)/print_targets.mk

# TODO
include $(MAKE_ROOT)/info_targets.mk

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Main executable linking
$(ELF): $(OBJS) | $(INFO_DIR)
	printf "$(MSG_LINK)"
	$(LD) -o $@ $^ $(LDFLAGS)

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(HEADERS) Makefile $(LDSCRIPT) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_C_FILE)"
	$(CC) $(CFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources
$(BUILD_DIR)/%.o: %.s $(HEADERS) Makefile $(LDSCRIPT) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(AS) $(ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Print object files' headers
$(INFO_DIR)/%.header: $(BUILD_DIR)/%.o | $(INFO_SRC_DIRS)
	printf "$(MSG_HEADER_FILE)"
	$(OBJDUMP) -x $< > $@

# Print elf file's header
$(INFO_DIR)/%.header: $(BUILD_DIR)/%.elf | $(INFO_SRC_DIRS)
	printf "$(MSG_HEADER_FILE)"
	$(OBJDUMP) -x $< > $@

# Print object files' disassembly
$(INFO_DIR)/%.d: $(BUILD_DIR)/%.o | $(INFO_SRC_DIRS)
	printf "$(MSG_DASM_FILE)"
	$(OBJDUMP) -d $< > $@

# Print elf file disassembly
$(INFO_DIR)/%.d: $(BUILD_DIR)/%.elf | $(INFO_SRC_DIRS)
	printf "$(MSG_DASM_FILE)"
	$(OBJDUMP) -d $< > $@

# Copy ELF file into BIN file
$(BIN): $(ELF)
	printf "$(MSG_BIN)"
	$(OBJCOPY) -O binary $(ELF) $(BIN)

# Folders
$(BUILD_SRC_DIRS) $(INFO_SRC_DIRS) $(INFO_DIR):
	mkdir -p $@
