# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

#------------------------------------------------------------------------------
# Testing
#------------------------------------------------------------------------------
TEST_SRCS := $(foreach dir, $(TEST_SRC_DIRS), $(wildcard $(dir)/*.c))

TEST_HEADERS := $(foreach dir, $(TEST_INC_DIRS), $(wildcard $(dir)/*.h))
# Test includes are considered system includes, therefore, they won't be
# considered for static analysis
TEST_HEADER_FLAGS := $(addprefix -isystem , $(TEST_INC_DIRS))

TEST_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_OBJS := $(patsubst %.c, %.test.o, $(TEST_OBJS))

TEST_FRAMEWORK_SRCS := $(foreach dir, $(TEST_FRAMEWORK_SRC_DIRS), $(wildcard $(dir)/*.c))
TEST_FRAMEWORK_OBJS := $(addprefix $(BUILD_DIR)/, $(TEST_FRAMEWORK_SRCS))
TEST_FRAMEWORK_OBJS := $(patsubst %.c, %.test_framework.o, $(TEST_FRAMEWORK_OBJS))

TEST_APP_OBJS := $(filter-out %main.o,$(OBJS))

TEST_EXES := $(addprefix $(BUILD_DIR)/, $(TEST_SRCS))
TEST_EXES := $(patsubst %.c, %.elf, $(TEST_EXES))

TEST_DEPS := $(patsubst %.o, %.d, $(TEST_OBJS) $(TEST_FRAMEWORK_OBJS))

BUILD_TEST_DIRS := $(addprefix $(BUILD_DIR)/, $(TEST_SRC_DIRS) $(TEST_FRAMEWORK_SRC_DIRS))

.PHONY: test ## Compile and execute tests
test: $(TEST_EXES) $(TEST_APP_OBJS)
	for test in $(TEST_EXES); do \
		test_name=$$(basename $${test} .elf); \
		printf "$(BOLD_MAGENTA)Running test: $${test_name} $(NC)\n"; \
		./$${test}; \
		printf "\n"; \
	done

$(BUILD_DIR)/%.elf: $(BUILD_DIR)/%.test.o $(TEST_FRAMEWORK_OBJS) $(TEST_APP_OBJS) | $(BUILD_TEST_DIRS)
	printf "$(MSG_LINK_TEST)"
	$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) $(LIB_FLAGS)

# Compiling object files from C sources
$(BUILD_DIR)/%.test.o: %.c $(MISC_DEPS) | $(BUILD_TEST_DIRS)
	printf "$(MSG_COMPILE_C_TEST_FILE)"
	$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) $(HEADER_FLAGS) $(TEST_HEADER_FLAGS) -o $@ -c $<

# Compiling object files from C sources
$(BUILD_DIR)/%.test_framework.o: %.c $(MISC_DEPS) | $(BUILD_TEST_DIRS)
	printf "$(MSG_COMPILE_C_TEST_FILE)"
	$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) $(HEADER_FLAGS) $(TEST_HEADER_FLAGS) -o $@ -c $<

$(BUILD_TEST_DIRS):
	mkdir -p $@

-include $(TEST_DEPS)
