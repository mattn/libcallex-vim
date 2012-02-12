
function! linux32#libc#getenv(name)
  let msvcrt = libcallex#load("/lib/libc.so.6")
  let ret = msvcrt.call("getenv", ["".a:name], "string")
  call msvcrt.free()
  return ret
endfunction
