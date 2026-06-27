// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026  Nicolas Gabriel Cotti

#include "interrupt.h"

void default_handler(void) {
    while (1)
        ;
}

void undef_handler(void) {
    while (1)
        ;
}

void svc_handler(void) {
    while (1)
        ;
}
