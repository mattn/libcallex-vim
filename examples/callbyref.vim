silent unlet! kernel32

let kernel32 = libcallex#load('kernel32.dll')

let buf = repeat(' ', 255)
let args = [buf, 255]
call kernel32.call('GetWindowsDirectoryA', args, 'number')
let dir = args[0]
echo "your windows directory: " . dir

let buf = repeat(' ', 255)
let args = [buf, 255]
call kernel32.call('GetSystemDirectoryA', args, 'number')
let dir = args[0]
echo "your system directory : " . dir

call kernel32.free()
