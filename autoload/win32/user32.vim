function! win32#user32#MessageBox(title, message)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('MessageBoxA', [0, a:title, a:message, 4], 'number')
  call user32.free()
  return ret
endfunction
