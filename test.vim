so libcallex.vim

silent unlet! lib
let lib = libcallex.load("user32.dll")
call libcallex.call(lib, "MessageBoxA", [0, "Hello", "World", 0])

