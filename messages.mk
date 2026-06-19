# This file includes all messages to be printed on the screen

include $(MAKE_ROOT)/colors.mk

#------------------------------------------------------------------------------
# Error messages
#------------------------------------------------------------------------------
define MSG_NO_SRC_DIRS
$(M_RED)[ERROR #001]$(M_NC)
Variable "SRC_DIRS" must be defined.
SRC_DIRS should contain the path to the sources' location
endef

define MSG_WRONG_SRC_DIRS
$(M_RED)[ERROR #002]$(M_NC)
Variable "SRC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_WRONG_INC_DIRS
$(M_RED)[ERROR #003]$(M_NC)
Variable "INC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_EMPTY_SRC_DIR
$(M_RED)[ERROR #004]$(M_NC)
Variable "SRC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_EMPTY_INC_DIR
$(M_RED)[ERROR #005]$(M_NC)
Variable "INC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_REPEATED_SRC_DIRS
$(M_RED)[ERROR #006]$(M_NC)
Variable "SRC_DIRS" should not have repeated directories.
Repeated directories:
endef

define MSG_REPEATED_INC_DIRS
$(M_RED)[ERROR #007]$(M_NC)
Variable "INC_DIRS" should not have repeated directories.
Repeated directories:
endef

#------------------------------------------------------------------------------
# Info messages
#------------------------------------------------------------------------------
define MSG_CLEAN_EMPTY
$(CYAN)Nothing to clean.$(NC)\n
endef

define MSG_CLEAN_OK
$(GREEN)All files successfully erased$(NC) $(CHECKMARK)\n
endef

define MSG_COMPILE_DO_NOTHING
$(CYAN)Nothing to compile.$(NC)\n
endef

define MSG_COMPILE_OK
$(GREEN)Compilation successful$(NC) $(CHECKMARK)\n
endef

define MSG_COMPILE_C_FILE
$(MAGENTA)[CC]  $(NC) $<\n
endef

define MSG_COMPILE_ASM_FILE
$(MAGENTA)[AS]  $(NC) $<\n
endef

define MSG_LINK
$(MAGENTA)[LD]  $(NC) $@\n
endef

define MSG_BIN
$(MAGENTA)[BIN] $(NC) $@\n
endef

define MSG_DASM_DO_NOTHING
$(CYAN)Nothing to disassemble.$(NC)\n
endef

define MSG_DASM_FILE
$(MAGENTA)[DASM]$(NC) $@\n
endef

define MSG_HEADERS_DO_NOTHING
$(CYAN)Nothing to generate.$(NC)\n
endef

define MSG_HEADER_FILE
$(MAGENTA)[HEAD]$(NC) $@\n
endef
