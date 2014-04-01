function! win32#kernel32#GetWindowsDirectory()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [buf, 255]
  call kernel32.call('GetWindowsDirectoryA', args, '')
  call kernel32.free()
  return args[0]
endfunction

function! win32#kernel32#GetSystemDirectory()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [buf, 255]
  call kernel32.call('GetSystemDirectoryA', args, '')
  call kernel32.free()
  return args[0]
endfunction

function! win32#kernel32#GetModuleFileName()
  let kernel32 = libcallex#load('kernel32.dll')
  let buf = repeat(' ', 255)
  let args = [0, buf, 255]
  call kernel32.call('GetModuleFileNameA', args, '')
  call kernel32.free()
  return args[1]
endfunction

function! win32#kernel32#GetModuleHandle(name)
  let kernel32 = libcallex#load('kernel32.dll')
  let r = kernel32.call('GetModuleHandleA', [0], 'ptr')
  call kernel32.free()
  return r
endfunction
