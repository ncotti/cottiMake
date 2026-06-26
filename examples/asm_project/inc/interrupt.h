// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026  Nicolas Gabriel Cotti

#ifndef _INTERRUPT_H_
#define _INTERRUPT_H_

void default_handler(void);

void undef_handler(void);

void svc_handler(void);

#endif // _INTERRUPT_H_