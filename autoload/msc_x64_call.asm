PUBLIC msc_x64_call

_TEXT SEGMENT
; intptr_t msc_x64_call(FUNCTION p, long narg, INTPTR_T* args)
args$ = 32
narg$ = 24
p$ = 16
msc_x64_call proc
	push rbp
	mov rbp, rsp
	mov p$[rbp], rcx
	mov narg$[rbp], rdx
	mov args$[rbp], r8
	; stacksize is at lease 32 byte, aligned to 16 byte
	; cutting corners with (4 + narg * 2) * 8
	lea rdx, [rdx*2+4]
	lea rdx, [rdx*8]
	sub rsp, rdx
	; while narg >= 5:
	;  narg--
	;  rsp[narg] = args[narg]
	; if narg > 3:
	;  r9 = args[3]
	; if narg > 2:
	;  r8 = args[2]
	; if narg > 1:
	;  rdx = args[1]
	; if narg > 0:
	;  rcx = args[0]
	mov rcx, narg$[rbp]
argN:
	cmp rcx, 5
	jl arg4
	dec rcx
	mov rax, args$[rbp]
	mov rax, [rax+rcx*8]
	mov [rsp+rcx*8], rax
	jmp argN
arg4:
	cmp rcx, 4
	jl arg3
	mov rax, args$[rbp]
	mov rax, [rax+24]
	mov r9, rax
arg3:
	cmp rcx, 3
	jl arg2
	mov rax, args$[rbp]
	mov rax, [rax+16]
	mov r8, rax
arg2:
	cmp rcx, 2
	jl arg1
	mov rax, args$[rbp]
	mov rax, [rax+8]
	mov rdx, rax
arg1:
	cmp rcx, 1
	jl docall
	mov rax, args$[rbp]
	mov rax, [rax]
	mov rcx, rax
docall:
	call qword ptr p$[rbp]
	mov rsp, rbp
	pop rbp
	ret
msc_x64_call endp
_TEXT ENDS

end
