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

function! libcallex.load(name) dict
  return {
  \ 'libname': a:name,
  \ 'handle': 0 + libcall('libcallex.dll', 'libcallex_loadlib', a:name),
  \ 'function': '',
  \ 'arguments': []
  \}
endfunction

function! libcallex.call(ctx, func, args) dict
  let a:ctx.function = a:func
  let a:ctx.arguments = a:args
  let r = libcall('libcallex.dll', 'libcallex_call', s:transform(a:ctx))
endfunction
