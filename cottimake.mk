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
# E.g. If your project looks like the following, then MAKE_ROOT would be
# equal to "cottimake":
# .
# ├── Makefile ( Your own project Makefile, which contains the statement
# │				 "include cottimake/Makefile")
# └── cottimake
#	  └── cottimake.mk (this file)
MAKE_ROOT := $(shell \
    dir=$$(pwd); \
    while [ "$${dir}" != "/" ]; do \
        if [ -f "$${dir}/$(COTTIMAKE)" ]; then \
            echo "$${dir}"; \
            exit 0; \
        fi; \
        dir=$$(dirname "$$dir"); \
    done)

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
GDB_FLAGS += -q -x "$(GDB_SCRIPT)"

# Check if all variables are ok
include $(MAKE_ROOT)/arg_check.mk

#------------------------------------------------------------------------------
# File location
#------------------------------------------------------------------------------
ELF 		:= $(BUILD_DIR)/$(EXE).elf
BIN 		:= $(BUILD_DIR)/$(EXE).bin

COMPILE_COMMANDS := $(BUILD_DIR)/compile_commands.json
SCAN_BUILD_DIR := $(BUILD_DIR)/scan_build

# If you are using a custom linker script, don't use the default crt0.S files
ifneq (,$(LDSCRIPT))
LDFLAGS += -T $(LDSCRIPT)
endif

SRCS := $(foreach dir, $(SRC_DIRS), $(wildcard $(dir)/*.c) $(wildcard $(dir)/*.s))

HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.h) $(wildcard $(dir)/*.s))
HEADER_FLAGS := $(addprefix -I , $(INC_DIRS))

# TODO add _asm to assembly object files
OBJS := $(addprefix $(BUILD_DIR)/, $(SRCS))
OBJS := $(patsubst %.c, %.o, $(OBJS))
OBJS := $(patsubst %.s, %.o, $(OBJS))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(SRC_DIRS))

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
run: compile
	printf "$(MSG_RUN)"
	$(ELF) $(EXEFLAGS)

.PHONY: debug ## Debug executable file
debug: compile
	$(T_GDB) $(GDBFLAGS) "$(ELF)"

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
$(BUILD_DIR)/%.o: %.c $(HEADERS) $(LDSCRIPT) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_C_FILE)"
	$(T_CC) $(CFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Compiling object files from asm sources
$(BUILD_DIR)/%.o: %.s $(HEADERS) $(LDSCRIPT) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_ASM_FILE)"
	$(T_AS) $(ASFLAGS) $(HEADER_FLAGS) -o $@ -c $<

# Copy ELF file into BIN file
$(BIN): $(ELF)
	printf "$(MSG_BIN)"
	$(T_OBJCOPY) -O binary $(ELF) $(BIN)

# Folders
$(BUILD_SRC_DIRS):
	mkdir -p $@
