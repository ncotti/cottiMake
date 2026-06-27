# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## CottiMake is a general purpose Makefile for C and ASM projects
## This is the main Makefile file, the one which should be included from
## your project's Makefile.

#------------------------------------------------------------------------------
# Makefile Initialization
#------------------------------------------------------------------------------
SHELL=/bin/bash
.DELETE_ON_ERROR:
.SILENT:
.DEFAULT_GOAL := help

# Path to this Makefile, relative to the location from where it was called.
# E.g. If your project looks like the following, and you execute "make" from
# the "." directory, then MAKE_ROOT will be equal to "cottimake":
# .
# ├── Makefile ( Your own project Makefile, which contains the statement
# │				 "include cottimake/Makefile")
# └── cottimake
#	  └── cottimake.mk (this file)
MAKE_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

# Name of the "main" Makefile, i.e., the one that was called from the terminal
MAKE_ORIGIN := $(firstword $(MAKEFILE_LIST))

include $(MAKE_ROOT)/colors.mk
include $(MAKE_ROOT)/constants.mk
include $(MAKE_ROOT)/messages.mk

#------------------------------------------------------------------------------
# Used-defined variables: default values
#------------------------------------------------------------------------------
# Default values for user variables
include $(MAKE_ROOT)/defaults.mk

# The following are the result of combining the chosen tools and toolchain
T_CC		:= $(CROSS_COMPILE)$(CC)
T_AS		:= $(CROSS_COMPILE)$(AS)
T_LD		:= $(CROSS_COMPILE)$(LD)
T_OBJDUMP	:= $(CROSS_COMPILE)$(OBJDUMP)
T_OBJCOPY 	:= $(CROSS_COMPILE)$(OBJCOPY)
T_AR		:= $(CROSS_COMPILE)$(AR)
T_GDB		:= $(CROSS_COMPILE)$(GDB)

EXTRA_GDBFLAGS := -q
ifneq (,$(GDBSCRIPT))
EXTRA_GDBFLAGS += -x $(GDBSCRIPT)
endif

# Add dependency generation flags for compiler
EXTRA_CFLAGS := -MMD -MP

# If you are using the C compiler for assembly files, use all the extra
# cflags for assembling
ifeq ($(T_CC),$(T_AS))
EXTRA_ASFLAGS += $(EXTRA_CFLAGS)
endif

# Check if all variables are ok
include $(MAKE_ROOT)/arg_check.mk

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------
ELF 		:= $(BUILD_DIR)/$(EXE).elf
BIN 		:= $(BUILD_DIR)/$(EXE).bin

COMPILE_COMMANDS := $(BUILD_DIR)/compile_commands.json
SCAN_BUILD_DIR := $(BUILD_DIR)/scan_build

ifneq (,$(LDSCRIPT))
EXTRA_LDFLAGS := -T $(LDSCRIPT)
endif

C_SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c))
ASM_SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
SRCS := $(sort $(C_SRCS) $(ASM_SRCS))

HEADER_FLAGS := $(addprefix -I,$(INC_DIRS))
LIB_FLAGS := $(addprefix -L,$(LIB_DIRS))
LIB_FLAGS += $(addprefix -l,$(LDLIBS))

OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %_asm.o, $(OBJS))
OBJS := $(patsubst %.S, %_asm.o, $(OBJS))
OBJS := $(sort $(OBJS))

C_HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.h))
ASM_HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
HEADERS := $(sort $(C_HEADERS) $(ASM_HEADERS))

DEPS := $(patsubst %.o, %.d, $(OBJS))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))

MISC_DEPS := $(LDSCRIPT) $(MAKE_ORIGIN)

# Strip handles multiple spaces in between values
override LIB_DIRS := $(strip $(LIB_DIRS))

override LIB_DIRS := $(subst $(SPACE),:,$(LIB_DIRS))

LD_LIBRARY_PATH := $(if $(LD_LIBRARY_PATH),$(LIB_DIRS):$(LD_LIBRARY_PATH),$(LIB_DIRS))

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: compile ## Private compile command
compile: $(ELF)

.PHONY: help ## Display this message.
help:
	grep -E '^\.PHONY:.*## .*$$' $(MAKE_ROOT)/*.mk \
	| sort \
	| awk 'BEGIN {FS=":|## "}; \
	       {gsub(/^[ \t]+|[ \t]+$$/, "", $$3); \
	        printf "$(BOLD_CYAN)%-12s$(NC) %s\n", $$3, $$4}'

.PHONY: bin ## Generate binary file, without ELF headers.
bin: $(BIN)

.PHONY: clean ## Erase contents of build directory.
clean:
	if [ -d "$(BUILD_DIR)" ]; then \
		rm -Rf $(BUILD_DIR) && \
		printf "$(MSG_CLEAN_OK)"; \
	fi

.PHONY: run ## Execute program
run: $(ELF)
	printf "$(MSG_RUN)"
	if [ -n "$(LD_LIBRARY_PATH)" ]; then \
		printf "$(MAGENTA)LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) \\ $(NC) \n"; \
	fi
	printf "$(MAGENTA)$(ELF) $(EXEFLAGS)$(NC)\n"
	LD_LIBRARY_PATH=$(LD_LIBRARY_PATH) $(ELF) $(EXEFLAGS)

.PHONY: debug ## Debug executable file
debug: $(ELF)
	if [ -z $(filter -g,$(CFLAGS)) ]; then \
		printf "$(MSG_DEBUG_NO_G_FLAG)"; \
		exit 11; \
	fi
	printf "$(MSG_DEBUG)"
	printf "$(MAGENTA)$(T_GDB) $(GDBFLAGS) $(EXTRA_GDBFLAGS) $(ELF)$(NC)\n"
	$(T_GDB) $(GDBFLAGS) $(EXTRA_GDBFLAGS) $(ELF)
	$(MAKE) --no-print-directory kill_sim

include $(MAKE_ROOT)/test_targets.mk

include $(MAKE_ROOT)/info_targets.mk

include $(MAKE_ROOT)/simulation_targets.mk

include $(MAKE_ROOT)/lib_targets.mk

include $(MAKE_ROOT)/print_targets.mk

.PHONY: tidy ## Do static analysis with clang-tidy
tidy: $(COMPILE_COMMANDS)
	printf "$(MSG_TIDY)"
	clang-tidy --verify-config --quiet 1>/dev/null
	clang-tidy -p $(BUILD_DIR) \
		--config-file=$(CLANG_TIDY_CONFIG_FILE) \
		--quiet \
		$(C_SRCS) $(TEST_SRCS)

.PHONY: format ## Code formatter with clang-format
format: $(COMPILE_COMMANDS)
	printf "$(MSG_FORMAT)"
	clang-format \
		--style="file:$(CLANG_FORMAT_CONFIG_FILE)" \
		-i \
		--verbose \
		$(C_SRCS) $(C_HEADERS) $(TEST_SRCS)

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Main executable linking
$(ELF): $(OBJS)
	printf "$(MSG_LINK)"
	$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) $(LIB_FLAGS)
	printf "$(MSG_COMPILE_OK)"

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_C_FILE)"
	$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".s"
$(BUILD_DIR)/%_asm.o: %.s $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(T_AS) $(ASFLAGS) $(EXTRA_ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".S"
$(BUILD_DIR)/%_asm.o: %.S $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(T_AS) $(ASFLAGS) $(EXTRA_ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Copy ELF file into BIN file
$(BIN): $(ELF)
	printf "$(MSG_BIN)"
	$(T_OBJCOPY) -O binary $(ELF) $(BIN)

# Folders
$(BUILD_SRC_DIRS) $(BUILD_DIR):
	mkdir -p $@

# Since the compile_commands.json should only be re-created when a new
# header or source file appears, not when they change; it does not have
# $(SRCS) or $(HEADERS) as prerequisites.
# It will only be re-created after a make clean
$(COMPILE_COMMANDS):
	mkdir -p $(BUILD_DIR)
	bear --output $(COMPILE_COMMANDS) -- \
		$(MAKE) -B --no-print-directory $(OBJS) $(TEST_OBJS) $(TEST_FRAMEWORK_OBJS)

# Empty rule for miscellaneous dependencies
$(MISC_DEPS):

-include $(DEPS)
