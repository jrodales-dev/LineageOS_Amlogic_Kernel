/*
 * arch/arm/include/asm/stacktrace.h
 *
 * Copyright (C) 2017 Amlogic, Inc. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.
 *
 */

#ifndef __ASM_STACKTRACE_H
#define __ASM_STACKTRACE_H

#include <asm/ptrace.h>

struct stackframe {
	/*
	 * FP member should hold R7 when CONFIG_THUMB2_KERNEL is enabled
	 * and R11 otherwise.
	 */
	unsigned long fp;
	unsigned long sp;
	unsigned long lr;
	unsigned long pc;
};

static __always_inline
void arm_get_current_stackframe(struct pt_regs *regs, struct stackframe *frame)
{
		frame->fp = frame_pointer(regs);
		frame->sp = regs->ARM_sp;
		frame->lr = regs->ARM_lr;
		frame->pc = regs->ARM_pc;
}

#if defined(CONFIG_FRAME_POINTER) || defined(CONFIG_ARM_UNWIND)
extern int unwind_frame(struct stackframe *frame);
#else
#define unwind_frame(f) (-EINVAL)
#endif
extern void walk_stackframe(struct stackframe *frame,
			    int (*fn)(struct stackframe *, void *), void *data);

#endif	/* __ASM_STACKTRACE_H */
