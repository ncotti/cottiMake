// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026  Nicolas Gabriel Cotti

#include "main.h"
#include "helper.h"
#include "add.h"
#include <stdio.h>

int main(void) {

    int a = helper_return_two();
    a = add1(a);

    printf("C_project_out: %d\n", a);

    return 0;
}