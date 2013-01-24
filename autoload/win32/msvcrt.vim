
function win32#msvcrt#getenv(name)
  let msvcrt = libcallex#load("msvcrt.dll")
  let ret = msvcrt.call("getenv", ["".a:name], "string")
  call msvcrt.free()
  return ret
endfunction
