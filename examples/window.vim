let inst = win32#kernel32#GetModuleHandle(0)
let wnd = win32#user32#CreateWindowEx(0, "Button", "foobar", 0xcf0000, 0, 0, 300, 300, 0, 0, inst, 0)
call win32#user32#ShowWindow(wnd, 5)
call win32#user32#UpdateWindow(wnd)
echo win32#user32#MessageBox(0, "Hello Vimmer!", "hello world", 4)
call win32#user32#DestroyWindow(wnd)
