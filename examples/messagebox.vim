so ../libcallex.vim

silent unlet! lib

let lib = libcallex.load('msvcrt.dll')
let username = lib.call('getenv', ["USERNAME"], 'string')
call libcallex.free(lib)

let lib = libcallex.load("user32.dll")
if lib.call('MessageBoxA', [0, "Hello ".username."\r\nCan you see this message?", 'Hello World', 4]) == 6
  call lib.call('MessageBoxA', [0, 'You clicked "YES"', 'Hello World', 0])
else
  call lib.call('MessageBoxA', [0, 'You clicked "NO". Are you all right?', 'Hello World', 0])
endif
call libcallex.free(lib)
