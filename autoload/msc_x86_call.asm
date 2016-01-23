.686P
.model flat

; why need underscore?
PUBLIC _msc_x86_call

_TEXT SEGMENT
; intptr_t msc_x86_call(FUNCTION p, long narg, INTPTR_T* args)
args$ = 16
narg$ = 12
p$ = 8
_msc_x86_call proc
	push ebp
	mov ebp, esp
	; while narg > 0:
	;   push args[--narg]
	mov ecx, narg$[ebp]
argN:
	cmp ecx, 0
	jle docall
	dec ecx
	mov eax, args$[ebp]
	push [eax+ecx*4]
	jmp argN
docall:
	call dword ptr p$[ebp]
	mov esp, ebp
	pop ebp
	ret
_msc_x86_call endp
_TEXT ENDS

end
