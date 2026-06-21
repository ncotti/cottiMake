.PHONY: print_src ## Print source files
print_src:
	printf "$(MAGENTA)Source files:$(NC)\n"
	for src in $(SRCS); do \
		printf "$${src}\n"; \
	done
	printf "\n"

.PHONY: print_obj ## Print object files
print_obj:
	printf "$(MAGENTA)Object files:$(NC)\n"
	for obj in $(OBJS); do \
		printf "$${obj}\n"; \
	done
	printf "$(ELF)\n"; \
	printf "\n"

.PHONY: print_header ## Print header files
print_header:
	printf "$(MAGENTA)Header files:$(NC)\n"
	for header in $(HEADERS); do \
		printf "$${header}\n"; \
	done
	printf "\n"

.PHONY: print ## Print all: source, object and header files
print: print_src print_obj print_header
