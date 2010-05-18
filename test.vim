
let g:libcallex = {}

function libcallex.load(name) dict
  return {
  \ "libname": a:name,
  \ "handle": 0 + libcall("libcalllib.dll", "libcallex_loadlib", a:name),
  \ "function": "",
  \ "arguments": []
  \}
endfunction

function libcallex.call(ctx, func, args) dict
  let a:ctx.function = a:func
  let a:ctx.arguments = a:args
  let args = substitute(string(a:ctx), "'", '"', 'g')
  let r = libcall("libcalllib.dll", "libcallex_call", args)
endfunction

silent unlet! ctx
let lib = libcallex.load("user32.dll")
call libcallex.call(lib, "MessageBoxA", [0, "Hello", "World", 0])

