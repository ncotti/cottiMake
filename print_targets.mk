# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2026  Nicolas Gabriel Cotti

HEADERS := $(foreach dir, $(INC_DIRS), $(wildcard $(dir)/*.h) $(wildcard $(dir)/*.s) $(wildcard $(dir)/*.S))
HEADERS := $(sort $(HEADERS))

.PHONY: print_src ## Print source files
print_src:
	printf "$(BOLD_MAGENTA)Source files:$(NC)\n"
	for src in $(SRCS); do \
		printf "$${src}\n"; \
	done
	printf "\n"

.PHONY: print_obj ## Print object files
print_obj:
	printf "$(BOLD_MAGENTA)Object files:$(NC)\n"
	for obj in $(OBJS); do \
		printf "$${obj}\n"; \
	done
	printf "$(ELF)\n"; \
	printf "\n"

.PHONY: print_header ## Print header files
print_header:
	printf "$(BOLD_MAGENTA)Header files:$(NC)\n"
	for header in $(HEADERS); do \
		printf "$${header}\n"; \
	done
	printf "\n"

.PHONY: print ## Print all: source, object and header files
print: print_src print_obj print_header
