dnl  x86 fat binary entrypoints.

dnl  Copyright 2003 Free Software Foundation, Inc.
dnl
dnl  This file is part of the GNU MP Library.
dnl
dnl  The GNU MP Library is free software; you can redistribute it and/or
dnl  modify it under the terms of the GNU Lesser General Public License as
dnl  published by the Free Software Foundation; either version 2.1 of the
dnl  License, or (at your option) any later version.
dnl
dnl  The GNU MP Library is distributed in the hope that it will be useful,
dnl  but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
dnl  Lesser General Public License for more details.
dnl
dnl  You should have received a copy of the GNU Lesser General Public
dnl  License along with the GNU MP Library; see the file COPYING.LIB.  If
dnl  not, write to the Free Software Foundation, Inc., 51 Franklin Street,
dnl  Fifth Floor, Boston, MA 02110-1301, USA.

include(`../config.m4')


dnl  Forcibly disable profiling.
dnl
dnl  The entrypoints and inits are small enough not to worry about, the real
dnl  routines arrived at will have any profiling.  Also, the way the code
dnl  here ends with a jump means we won't work properly with the
dnl  "instrument" profiling scheme anyway.

define(`WANT_PROFILING',no)


	TEXT


dnl  Usage: FAT_ENTRY(name, offset)
dnl
dnl  Emit a fat binary entrypoint function of the given name.  This is the
dnl  normal entry for applications, eg. __gmpn_add_n.
dnl
dnl  The code simply jumps through the function pointer in __gmpn_cpuvec at
dnl  the given "offset" (in bytes).
dnl
dnl  For non-PIC, the jumps are 5 bytes each, aligning them to 8 should be
dnl  fine for all x86s.
dnl
dnl  For PIC, the jumps are 20 bytes each, and are best aligned to 16 to
dnl  ensure at least the first two instructions don't cross a cache line
dnl  boundary.
dnl
dnl  Note the extra `' ahead of PROLOGUE obscures it from the HAVE_NATIVE
dnl  grepping in configure, stopping that code trying to eval something with
dnl  $1 in it.

define(FAT_ENTRY,
m4_assert_numargs(2)
`	ALIGN(ifdef(`PIC',16,8))
`'PROLOGUE($1)
ifdef(`PIC',
`	call	L(movl_eip_edx)
L(entry_here$2):
	addq	$_GLOBAL_OFFSET_TABLE_+[.-L(entry_here$2)], %rdx
	movq	GSYM_PREFIX`'__gmpn_cpuvec@GOT(%rdx), %rdx
	jmp	*m4_empty_if_zero($2)(%rdx)
',`dnl non-PIC
	jmp	*GSYM_PREFIX`'__gmpn_cpuvec+$2
')
EPILOGUE()
')


dnl  FAT_ENTRY for each CPUVEC_FUNCS_LIST
dnl

define(`CPUVEC_offset',0)
foreach(i,
`FAT_ENTRY(MPN(i),CPUVEC_offset)
define(`CPUVEC_offset',eval(CPUVEC_offset + 4))',
CPUVEC_FUNCS_LIST)

ifdef(`PIC',`
	ALIGN(8)
L(movl_eip_edx):
	movq	(%rsp), %rdx
	ret_internal
')


dnl  Usage: FAT_INIT(name, offset)
dnl
dnl  Emit a fat binary initializer function of the given name.  These
dnl  functions are the initial values for the pointers in __gmpn_cpuvec.
dnl
dnl  The code simply calls __gmpn_cpuvec_init, and then jumps back through
dnl  the __gmpn_cpuvec pointer, at the given "offset" (in bytes).
dnl  __gmpn_cpuvec_init will have stored the address of the selected
dnl  implementation there.
dnl
dnl  Only one of these routines will be executed, and only once, since after
dnl  that all the __gmpn_cpuvec pointers go to real routines.  So there's no
dnl  need for anything special here, just something small and simple.  To
dnl  keep code size down, "fat_init" is a shared bit of code, arrived at
dnl  with the offset in %al.  %al is used since the movb instruction is 2
dnl  bytes where %eax would be 4.
dnl
dnl  Note having `PROLOGUE in FAT_INIT obscures that PROLOGUE from the
dnl  HAVE_NATIVE grepping in configure, preventing that code trying to eval
dnl  something with $1 in it.

define(FAT_INIT,
m4_assert_numargs(2)
`PROLOGUE($1)
	movb	$`'$2, %al
	jmp	L(fat_init)
EPILOGUE()
')

L(fat_init):
	C al	__gmpn_cpuvec byte offset

	movsbq	%al, %rax
	pushq	%rax

ifdef(`PIC',`
	pushq	%rbx
	call	L(movl_eip_ebx)
L(init_here):
	addq	$_GLOBAL_OFFSET_TABLE_+[.-L(init_here)], %rbx
	call	GSYM_PREFIX`'__gmpn_cpuvec_init@PLT
	movq	GSYM_PREFIX`'__gmpn_cpuvec@GOT(%rbx), %rdx
	popq	%rbx
	popq	%rax
	jmp	*(%rdx,%rax)

L(movl_eip_ebx):
	movq	(%rsp), %rbx
	ret_internal

',`dnl non-PIC
	call	GSYM_PREFIX`'__gmpn_cpuvec_init
	popq	%rax
	jmp	*GSYM_PREFIX`'__gmpn_cpuvec(%rax)
')

dnl  FAT_INIT for each CPUVEC_FUNCS_LIST
dnl

define(`CPUVEC_offset',0)
foreach(i,
`FAT_INIT(MPN(i`'_init),CPUVEC_offset)
define(`CPUVEC_offset',eval(CPUVEC_offset + 4))',
CPUVEC_FUNCS_LIST)



C long __gmpn_cpuid (char dst[12], int id);
C
C This is called only once, so just something simple and compact is fine.

defframe(PARAM_ID,  8)
defframe(PARAM_DST, 4)
deflit(`FRAME',0)

PROLOGUE(__gmpn_cpuid)
	pushq	%rsi		FRAME_pushq()
	pushq	%rbx		FRAME_pushq()
	movq	%rsi, %rax
	cpuid
	movl	%ebx, (%rsi)
	movl	%edx, 4(%rsi)
	movl	%ecx, 8(%rsi)
	popq	%rbx
	popq	%rsi
	ret
EPILOGUE()


C int __gmpn_cpuid_available (void);
C
C Return non-zero if the cpuid instruction is available, which means late
C model 80486 and higher.  80386 and early 80486 don't have cpuid.
C
C The test follows Intel AP-485 application note, namely that if bit 21 is
C modifiable then cpuid is supported.  This test is reentrant and thread
C safe, since of course any interrupt or context switch will preserve the
C flags while we're tinkering with them.
C
C This is called only once, so just something simple and compact is fine.

PROLOGUE(__gmpn_cpuid_available)
	pushf
	popq	%rcx		C old flags

	movq	%rcx, %rdx
	xorq	$0x200000, %rdx
	pushq	%rdx
	popf
	pushf
	popq	%rdx		C tweaked flags

	movq	$1, %rax
	cmpq	%rcx, %rdx
	jne	L(available)
	xorq	%rax, %rax	C not changed, so cpuid not available

L(available):
	ret
EPILOGUE()
