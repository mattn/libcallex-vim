silent unlet! user32

let user32 = libcallex#load("user32.dll")
call user32.call('MessageBoxA', [0, "Hello\r\nCan you see this message?", 'Hello World', 4], 'number')
call user32.free()
