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
