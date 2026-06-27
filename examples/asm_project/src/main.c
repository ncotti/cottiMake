// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026  Nicolas Gabriel Cotti

#include "main.h"

int main(void) {
    int a = 10;
    a++;
    a++;
    a = a; // This line is used for reference in the gdb script
    return 0;
}
