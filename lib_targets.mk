LIBA		:= $(BUILD_DIR)/lib$(EXE).a
LIBSO		:= $(BUILD_DIR)/lib$(EXE).so

OBJS_PIC := $(patsubst %.o, %.pic.o, $(OBJS))

.PHONY: compile_static_lib ## Compile sources as a static library
compile_static_lib: $(LIBA)

.PHONY: compile_dynamic_lib ## Compile sources as a dynamic library
compile_dynamic_lib: $(LIBSO)

# Static library linking
$(LIBA): $(OBJS)
	printf "$(MSG_AR)"
	$(T_AR) rcs $@ $^
	printf "$(MSG_STATIC_LIB_OK)"

# Dynamic library linking
$(LIBSO): $(OBJS_PIC)
	printf "$(MSG_LINK)"
	$(T_LD) -o $@ $^ $(LDFLAGS) $(EXTRA_LDFLAGS) -shared
	printf "$(MSG_DYNAMIC_LIB_OK)"

# Compiling object files from C sources with PIC (position independent code)
# For usage with dynamic libs
$(BUILD_DIR)/%.pic.o: %.c $(MISC_DEPS) | $(BUILD_SRC_DIRS)
	printf "$(MSG_COMPILE_C_FILE)"
	$(T_CC) $(CFLAGS) $(EXTRA_CFLAGS) -fPIC $(HEADER_FLAGS) -o $@ -c $<
