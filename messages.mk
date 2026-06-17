# This file includes all messages to be printed on the screen

include colors.mk

define MSG_NO_SRC_DIRS
[ERROR #001] Variable "SRC_DIRS" must be defined.
SRC_DIRS should contain the path to the sources' location
endef

define MSG_WRONG_SRC_DIRS
[ERROR #002] Variable "SRC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_WRONG_INC_DIRS
[ERROR #003] Variable "INC_DIRS" must hold valid directories.
Invalid directories:
endef

define MSG_EMPTY_SRC_DIR
[ERROR #004] Variable "SRC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_EMPTY_INC_DIR
[ERROR #005] Variable "INC_DIRS" should not have empty directories.
Empty directories:
endef

define MSG_REPEATED_SRC_DIRS
[ERROR #006] Variable "SRC_DIRS" should not have repeated directories.
Repeated directories:
endef

define MSG_REPEATED_INC_DIRS
[ERROR #007] Variable "INC_DIRS" should not have repeated directories.
Repeated directories:
endef
