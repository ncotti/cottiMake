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

# Name of this file
COTTIMAKE := cottimake.mk

# Path to this Makefile, relative to the location from where it was called.
# E.g. If your project looks like the following, and you execute "make" from 
# the "." directory, then MAKE_ROOT will be equal to "cottimake":
# .
# ├── Makefile ( Your own project Makefile, which contains the statement
# │				 "include cottimake/Makefile")
# └── cottimake
#	  └── cottimake.mk (this file)
MAKE_ROOT := $(dir $(lastword $(MAKEFILE_LIST)))

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
T_GDB		:= $(CROSS_COMPILE)$(GDB)

# Implicit GDB flags
GDBFLAGS += -q
ifneq (,$(GDB_SCRIPT))
GDBFLAGS += -x $(GDB_SCRIPT)
endif

# Add dependency generation flags for compiler
CFLAGS += -MMD -MP

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
LDFLAGS += -T $(LDSCRIPT)
endif

SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c) $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
SRCS := $(sort $(SRCS))

HEADER_FLAGS := $(addprefix -I , $(INC_DIRS))

OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %_asm.o, $(OBJS))
OBJS := $(patsubst %.S, %_asm.o, $(OBJS))
OBJS := $(sort $(OBJS))

DEPS := $(patsubst %.o, %.d, $(OBJS))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))

# Process ID of the last simulator instance that was run
SIM_PID_FILE := $(BUILD_DIR)/sim_pid_file.pid
SIM_OUTPUT_FILE := $(BUILD_DIR)/sim_output.txt

SIM_TIMEOUT_TO_EXIT := 10

# Add flag in simulator to create a pid file to later close it
ifneq ($(findstring qemu,$(SIM)),)
SIMFLAGS += -pidfile $(SIM_PID_FILE)
else ifneq ($(findstring renode,$(SIM)),)
SIMFLAGS += --pid-file $(SIM_PID_FILE)
endif

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
compile: $(ELF)

.PHONY: tidy ## Do static analysis with clang-tidy
tidy: $(SRCS)
	clang-tidy --verify-config
	clang-tidy $^ -p $(COMPILE_COMMANDS)

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
	printf "$(MAGENTA)$(ELF) $(EXEFLAGS)$(NC)\n"
	$(ELF) $(EXEFLAGS)

.PHONY: sim ## Execute program in simulation environment
sim: $(ELF) sim_kill
	printf "$(MSG_SIM)"
	printf "$(MAGENTA)$(SIM) $(SIMFLAGS)$(NC)\n"
	gnome-terminal -- bash -c "\
		$(SIM) $(SIMFLAGS) |& tee $(SIM_OUTPUT_FILE); \
		printf '$(MSG_SIM_CLOSING)'; \
		read -s -t $(SIM_TIMEOUT_TO_EXIT)"; \

.PHONY: sim_kill ## Kills a running simulator instance
sim_kill:
	if [ -f "$(SIM_PID_FILE)" ]; then \
		echo -n "Killing Renode... "; \
		kill "$$(cat $(SIM_PID_FILE))" &>/dev/null; \
		rm $(SIM_PID_FILE); \
	fi

.PHONY: debug ## Debug executable file
debug: $(ELF)
	printf "$(MSG_DEBUG)"
	printf "$(MAGENTA)$(T_GDB) $(GDBFLAGS) $(ELF)$(NC)\n"
	$(T_GDB) $(GDBFLAGS) $(ELF)

.PHONY: test ## Compile and execute tests
test: $(ELF)
	$(MAKE) -f test.mk \
		BUILD_DIR="$(BUILD_DIR)" \
		CFLAGS="$(CFLAGS)" \
		LDFLAGS="$(LDFLAGS)" \
		CC="$(CC)" \
		LD="$(LD)" \
		HEADER_FLAGS="$(HEADER_FLAGS)"

include $(MAKE_ROOT)/print_targets.mk

include $(MAKE_ROOT)/info_targets.mk

#------------------------------------------------------------------------------
# Compilation targets
#------------------------------------------------------------------------------
# Main executable linking
$(ELF): $(OBJS)
	printf "$(MSG_LINK)"
	$(T_LD) -o $@ $^ $(LDFLAGS)
	printf "$(MSG_COMPILE_OK)"

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(LDSCRIPT) Makefile | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_C_FILE)"
	$(T_CC) $(CFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".s"
$(BUILD_DIR)/%_asm.o: %.s $(LDSCRIPT) Makefile | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(T_AS) $(ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources ending with ".S"
$(BUILD_DIR)/%_asm.o: %.S $(LDSCRIPT) Makefile | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(T_AS) $(ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Copy ELF file into BIN file
$(BIN): $(ELF)
	printf "$(MSG_BIN)"
	$(T_OBJCOPY) -O binary $(ELF) $(BIN)

# Folders
$(BUILD_SRC_DIRS):
	mkdir -p $@

-include $(DEPS)
