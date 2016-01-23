	.text
	.global	_mingw_x86_call
	.def	_mingw_x86_call
# intptr_t mingw_x86_call(FUNCTION p, long narg, INTPTR_T* args)
args$ = 16
narg$ = 12
p$ = 8
_mingw_x86_call:
	.cfi_startproc
	pushl %ebp
	movl %esp, %ebp
	# while narg > 0:
	#   push args[--narg]
	movl narg$(%ebp), %ecx
argN:
	cmpl $0, %ecx
	jle docall
	dec %ecx
	movl args$(%ebp), %eax
	pushl (%eax,%ecx,4)
	jmp argN
docall:
	call *p$(%ebp)
	movl %ebp, %esp
	popl %ebp
	ret
	.cfi_endproc
