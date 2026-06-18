# This contains color definitions used with printf

BLACK   := \033[0;30m
RED     := \033[0;31m
GREEN   := \033[0;32m
YELLOW  := \033[0;33m
BLUE    := \033[0;34m
MAGENTA := \033[0;35m
CYAN    := \033[0;36m
WHITE   := \033[0;37m

BOLD_BLACK   := \033[1;30m
BOLD_RED     := \033[1;31m
BOLD_GREEN   := \033[1;32m
BOLD_YELLOW  := \033[1;33m
BOLD_BLUE    := \033[1;34m
BOLD_MAGENTA := \033[1;35m
BOLD_CYAN    := \033[1;36m
BOLD_WHITE   := \033[1;37m

BG_BLACK   := \033[40m
BG_RED     := \033[41m
BG_GREEN   := \033[42m
BG_YELLOW  := \033[43m
BG_BLUE    := \033[44m
BG_MAGENTA := \033[45m
BG_CYAN    := \033[46m
BG_WHITE   := \033[47m

# No Color / reset
NC := \033[0m

## The following colors are meant to be used with Make statements such as
## $(error ...) or $(info ...)

ESC := $(shell printf '\033')

M_BLACK   := $(ESC)[0;30m
M_RED     := $(ESC)[0;31m
M_GREEN   := $(ESC)[0;32m
M_YELLOW  := $(ESC)[0;33m
M_BLUE    := $(ESC)[0;34m
M_MAGENTA := $(ESC)[0;35m
M_CYAN    := $(ESC)[0;36m
M_WHITE   := $(ESC)[0;37m

# No Color / reset
M_NC := $(ESC)[0m
