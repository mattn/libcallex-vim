so ../libcallex.vim

silent unlet! lib

let lib = libcallex.load('kernel32.dll')

let buf = repeat(' ', 255)
let args = [buf, 255]
call lib.call('GetWindowsDirectoryA', args, 'number')
let dir = args[0]
echo "your windows directory: " . dir

let buf = repeat(' ', 255)
let args = [buf, 255]
call lib.call('GetSystemDirectoryA', args, 'number')
let dir = args[0]
echo "your system directory : " . dir

call libcallex.free(lib)
