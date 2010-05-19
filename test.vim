so libcallex.vim

silent unlet! lib
let lib = libcallex.load("user32.dll")
if lib.call("MessageBoxA", [0, "Can you see this message?", "Hello World", 4]) == 6
  call lib.call("MessageBoxA", [0, "You clicked 'YES'", "Hello World", 0])
else
  call lib.call("MessageBoxA", [0, "You clicked 'NO'. Are you all right?", "Hello World", 0])
endif

