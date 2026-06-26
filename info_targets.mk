# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

## This file contains all required variables and targets to print information
## from the compiled object files

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
INFO_DIR 	:= $(BUILD_DIR)/info

OBJ_HEADERS := $(patsubst %.o, %.header, $(OBJS) $(ELF))
OBJ_HEADERS := $(patsubst %.elf, %.header, $(OBJ_HEADERS))
OBJ_HEADERS := $(patsubst $(BUILD_DIR)%, $(INFO_DIR)%, $(OBJ_HEADERS))

DASM_FILES := $(patsubst %.header, %.d, $(OBJ_HEADERS))

INFO_SRC_DIRS := $(addprefix $(INFO_DIR)/, $(SRC_DIRS))

#MAP			:= $(INFO_DIR)/memory.map

# If you use "ld" or "gcc" as linker, the memory map option is declared different
# ifneq (,$(findstring -ld, $(T_LD)))
# LDFLAGS += -Map $(MAP)
# else
# LDFLAGS += -Wl,-Map=$(MAP)
# endif

#------------------------------------------------------------------------------
# User targets
#------------------------------------------------------------------------------
.PHONY: headers ## Generate symbol table and section headers for all object files.
headers: $(OBJ_HEADERS)

.PHONY: dasm ## Generate disassemble for all object files and elf file.
dasm: $(DASM_FILES)

#------------------------------------------------------------------------------
# Information targets
#------------------------------------------------------------------------------
# Print object files' headers
$(INFO_DIR)/%.header: $(BUILD_DIR)/%.o | $(INFO_SRC_DIRS)
	printf "$(MSG_HEADER_FILE)"
	$(T_OBJDUMP) -x $< > $@

# Print elf file's header
$(INFO_DIR)/%.header: $(BUILD_DIR)/%.elf | $(INFO_SRC_DIRS)
	printf "$(MSG_HEADER_FILE)"
	$(T_OBJDUMP) -x $< > $@

# Print object files' disassembly
$(INFO_DIR)/%.d: $(BUILD_DIR)/%.o | $(INFO_SRC_DIRS)
	printf "$(MSG_DASM_FILE)"
	$(T_OBJDUMP) -d $< > $@

# Print elf file disassembly
$(INFO_DIR)/%.d: $(BUILD_DIR)/%.elf | $(INFO_SRC_DIRS)
	printf "$(MSG_DASM_FILE)"
	$(T_OBJDUMP) -d $< > $@

# Create folders
$(INFO_SRC_DIRS):
	mkdir -p $@
