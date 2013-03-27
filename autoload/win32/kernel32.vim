function! win32#kernel32#GetWindowsDirectory()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [buf, 255]
  call kernel32.call('GetWindowsDirectoryA', args, 'number')
  call kernel32.free()
  return args[0]
endfunction

function! win32#kernel32#GetSystemDirectory()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [buf, 255]
  call kernel32.call('GetSystemDirectoryA', args, 'number')
  call kernel32.free()
  return args[0]
endfunction

function! win32#kernel32#GetModuleFileName()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [0, buf, 255]
  call kernel32.call('GetModuleFileNameA', args, 'number')
  call kernel32.free()
  return args[1]
endfunction

function! win32#kernel32#GetModuleHandle(name)
  let kernel32 = libcallex#load('kernel32.dll')
  let r = kernel32.call('GetModuleHandleA', [0], 'number')
  call kernel32.free()
  return r
endfunction
