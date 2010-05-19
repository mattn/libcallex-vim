silent unlet! g:libcallex
let g:libcallex = {}

function! s:transform(obj)
  let t = type(a:obj)
  if t == 0
    return string(a:obj)
  elseif t == 1
    let s = string(a:obj)
    let s = substitute(s, '^''\(.*\)''$', '\1', '')
    let s = substitute(s, "''", "'", 'g')
    let s = substitute(s, '"', '\"', 'g')
    let s = substitute(s, '"', '\\"', 'g')
    let s = substitute(s, '\n', '\\n', 'g')
    let s = substitute(s, '\r', '\\r', 'g')
    let s = substitute(s, '\t', '\\t', 'g')
    return '"'.s.'"'
  elseif t == 2
    throw "can't treat function reference"
  elseif t == 3
    let ss = []
    for a in a:obj
      call add(ss, s:transform(a))
	endfor
	return '['.join(ss, ',').']'
  elseif t == 4
    let ss = []
    for k in keys(a:obj)
      call add(ss, s:transform(k).':'.s:transform(a:obj[k]))
	endfor
	return '{'.join(ss, ',').'}'
  elseif t == 5
    return string(a:obj)
  endif
  throw "can't treat unknown type"
endfunction

let s:template = {'libname': '', 'handle': 0, 'rettype': ''}

function! s:template.call(func, ...) dict
  let arguments = []
  let rettype = ''
  if len(a:000) == 1
    let arguments = a:000[0]
  elseif len(a:000) == 2
    let arguments = a:000[0]
    let rettype = a:000[1]
  endif
  let ctx = {
  \ 'handle': self.handle,
  \ 'function': a:func,
  \ 'arguments': arguments,
  \ 'rettype': rettype
  \}
  return libcall('libcallex.dll', 'libcallex_call', s:transform(ctx))
endfunction

function! s:template.free() dict
  call remove(self, 'call')
  call remove(self, 'free')
  return libcall('libcallex.dll', 'libcallex_free', s:transform(self))
endfunction

function! libcallex.load(name) dict
  let lib = copy(s:template)
  let lib.libname = a:name
  let lib.handle = 0 + libcall('libcallex.dll', 'libcallex_load', a:name)
  return lib
endfunction
