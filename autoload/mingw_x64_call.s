	.text
	.global	mingw_x64_call
	.def	mingw_x64_call
# intptr_t mingw_x64_call(FUNCTION p, long narg, INTPTR_T* args)
args$ = 32
narg$ = 24
p$ = 16
mingw_x64_call:
	.cfi_startproc
	pushq %rbp
	movq %rsp, %rbp
	movq %rcx, p$(%rbp)
	movq %rdx, narg$(%rbp)
	movq %r8, args$(%rbp)
	# stacksize is at lease 32 byte, aligned to 16 byte
	# cutting corners with (4 + narg * 2) * 8
	leaq 4(,%rdx,2), %rdx
	leaq (,%rdx,8), %rdx
	sub %rdx, %rsp
	# while narg >= 5:
	#  narg--
	#  rsp[narg] = args[narg]
	# if narg > 3:
	#  r9 = args[3]
	# if narg > 2:
	#  r8 = args[2]
	# if narg > 1:
	#  rdx = args[1]
	# if narg > 0:
	#  rcx = args[0]
	movq narg$(%rbp), %rcx
argN:
	cmpq $5, %rcx
	jl arg4
	dec %rcx
	movq args$(%rbp), %rax
	movq (%rax,%rcx,8), %rax
	movq %rax, (%rsp,%rcx,8)
	jmp argN
arg4:
	cmpq $4, %rcx
	jl arg3
	movq args$(%rbp), %rax
	movq 24(%rax), %rax
	movq %rax, %r9
arg3:
	cmpq $3, %rcx
	jl arg2
	movq args$(%rbp), %rax
	movq 16(%rax), %rax
	movq %rax, %r8
arg2:
	cmpq $2, %rcx
	jl arg1
	movq args$(%rbp), %rax
	movq 8(%rax), %rax
	movq %rax, %rdx
arg1:
	cmpq $1, %rcx
	jl docall
	movq args$(%rbp), %rax
	movq (%rax), %rax
	movq %rax, %rcx
docall:
	call *p$(%rbp)
	movq %rbp, %rsp
	popq %rbp
	ret
	.cfi_endproc
