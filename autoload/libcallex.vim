function! s:transform(obj)
  let t = type(a:obj)
  if t == 0
    return string(a:obj)
  elseif t == 1
    let s = string(a:obj)
    let s = substitute(s, '^''\(.*\)''$', '\1', '')
    let s = substitute(s, "''", "'", 'g')
    let s = substitute(s, '\\', '\\\\', 'g')
    let s = substitute(s, '"', '\"', 'g')
    let s = substitute(s, '"', '\\"', 'g')
    let s = substitute(s, '\n', '\\n', 'g')
    let s = substitute(s, '\r', '\\r', 'g')
    let s = substitute(s, '\t', '\\t', 'g')
    return '"'.s.'"'
  elseif t == 3
    let ss = []
    for a in a:obj
      call add(ss, s:transform(a))
	endfor
	return '['.join(ss, ',').']'
  elseif t == 4
    let ss = []
    for k in keys(a:obj)
      if type(a:obj[k]) != 2
        call add(ss, s:transform(k).':'.s:transform(a:obj[k]))
      endif
	endfor
	return '{'.join(ss, ',').'}'
  elseif t == 5
    return string(a:obj)
  endif
  throw "can't treat unknown type"
endfunction

let s:template = {'libname': '', 'handle': 0}

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
  let str = ''
  silent! let str = libcall(s:libfile, 'libcallex_call', s:transform(ctx))
  if len(str) == 0
    throw "unknown error"
  endif
  let ret = eval(str)
  if type(ret) == 1
    throw ret
  elseif type(ret) == 4
	if has_key(ret, 'error')
      throw ret.error
    else
      for n in range(len(arguments))
        let arguments[n] = ret.arguments[n]
      endfor
      return ret.return
    endif
  elseif ret
    throw ret
  else
  endif
endfunction

function! s:template.free()
  call remove(self, 'call')
  call remove(self, 'free')
  call libcall(s:libfile, 'libcallex_free', s:transform(self))
  let self.handle = 0
endfunction

function! libcallex#load(name)
  let lib = copy(s:template)
  let lib.libname = a:name
  let lib.handle = libcallnr(s:libfile, 'libcallex_load', a:name)
  if lib.handle == 0
    throw "can't load library: \"" . a:name . "\""
  endif
  return lib
endfunction

let s:libfile = substitute(expand('<sfile>'), '\.vim', '.dll', '')
