# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

SHELL=/bin/bash
.DELETE_ON_ERROR:
.SILENT:
.DEFAULT_GOAL := help

TEST_SRC_DIRS ?= test
TEST_HEADER_DIRS ?= test

TEST_FRAMEWORK_SRC_DIRS ?= test/framework/unity/src test/framework/fff
TEST_FRAMEWORK_HEADER_DIRS ?= test/framework/unity/src test/framework/fff

BUILD_DIR ?= build


#------------------------------------------------------------------------------
# Testing
#------------------------------------------------------------------------------
TEST_FRAMEWORK_SRCS := $(wildcard $(TEST_FRAMEWORK_SRC_DIRS)/*.c)

TEST_FRAMEWORK_HEADERS := $(foreach dir, $(TEST_FRAMEWORK_HEADER_DIRS), $(wildcard $(dir)/*.h))
TEST_FRAMEWORK_HEADER_FLAGS := $(addprefix -I , $(TEST_FRAMEWORK_HEADER_DIRS))

TEST_FRAMEWORK_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_FRAMEWORK_SRC_DIRS))
TEST_FRAMEWORK_OBJS := $(patsubst %.c, %.o, $(TEST_FRAMEWORK_OBJS))

TEST_SRCS := $(wildcard $(TEST_SRC_DIRS)/*.c)

TEST_HEADERS := $(foreach dir, $(TEST_HEADER_DIRS), $(wildcard $(dir)/*.h))
TEST_HEADER_FLAGS := $(addprefix -I , $(TEST_HEADER_DIRS))

TEST_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_OBJS := $(patsubst %.c, %.o, $(TEST_OBJS))

TEST_EXES := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_EXES := $(patsubst %.c, %.elf, $(TEST_EXES))

BUILD_SRC_DIRS := $(addprefix $(BUILD_DIR)/, $(TEST_SRC_DIRS) $(TEST_FRAMEWORK_SRC_DIRS))


# .PHONY: test
# test: $(TEST_EXES)
# 	for f in $(TEST_EXE_DIR)/*; do \
# 		if [ -x "$${f}" ] && [ ! -d "$${f}" ]; then \
# 			"$${f}"; \
# 		fi \
# 	done


$(BUILD_DIR)/%.elf: %.o
	echo -n "Linking everything together... "
	$(LD) -o $@ $< $(LDFLAGS)
	$(PRINT_CHECKMARK)

# Compiling object files from C sources
$(BUILD_DIR)/%.o: %.c $(TEST_FRAMEWORK_HEADERS) $(TEST_HEADERS) Makefile $(BUILD_SRC_DIRS)
	echo $(HEADER_FLAGS)
	echo "hiiii"
	echo -n "Compiling $< --> $@... "
#$(CC) $(CFLAGS) $(TEST_HEADER_FLAGS) $(HEADER_FLAGS) $(TEST_FRAMEWORK_HEADER_FLAGS) -o $@ -c $<
	$(PRINT_CHECKMARK)


$(BUILD_SRC_DIRS):
	mkdir -p $@