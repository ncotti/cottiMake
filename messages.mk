# This file includes all messages to be printed on the screen

include colors.mk

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
