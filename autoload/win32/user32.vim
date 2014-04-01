function! win32#user32#MessageBox(wnd, title, message, style)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('MessageBoxA', [str2nr(a:wnd), "".a:title, "".a:message, str2nr(a:style)], '')
  call user32.free()
  return ret
endfunction

function! win32#user32#CreateWindow(class, name, style, x, y, width, height, parent, menu, instance, param)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('CreateWindowA', [a:class, a:name, str2nr(a:style), str2nr(a:x), str2nr(a:y), str2nr(a:width), str2nr(a:height), str2nr(a:parent), str2nr(a:menu), str2nr(a:instance), str2nr(a:param)], '')
  call user32.free()
  return ret
endfunction

function! win32#user32#CreateWindowEx(exstyle, class, name, style, x, y, width, height, parent, menu, instance, param)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('CreateWindowExA', [str2nr(a:exstyle), "".a:class, "".a:name, str2nr(a:style), str2nr(a:x), str2nr(a:y), str2nr(a:width), str2nr(a:height), str2nr(a:parent), str2nr(a:menu), str2nr(a:instance), str2nr(a:param)], 'ptr')
  call user32.free()
  return ret
endfunction

function! win32#user32#ShowWindow(wnd, cmdshow)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('ShowWindow', [str2nr(a:wnd), str2nr(a:cmdshow)], '')
  call user32.free()
  return ret != 0
endfunction

function! win32#user32#UpdateWindow(wnd)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('UpdateWindow', [str2nr(a:wnd)], '')
  call user32.free()
  return ret != 0
endfunction

function! win32#user32#DestroyWindow(wnd)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('DestroyWindow', [str2nr(a:wnd)], '')
  call user32.free()
  return ret != 0
endfunction

function! win32#user32#GetMessage(wnd, msg)
  let user32 = libcallex#load("user32.dll")
  let buf = [str2nr(a:wnd), str2nr(a:msg), 0, 0]
  let ret = user32.call('GetMessage', buf, '')
  call user32.free()
  return ret
endfunction

function! win32#user32#DispatchMessage(msg)
  let user32 = libcallex#load("user32.dll")
  let ret = user32.call('DispatchMessage', [str2nr(a:msg)], '')
  call user32.free()
  return ret
endfunction
