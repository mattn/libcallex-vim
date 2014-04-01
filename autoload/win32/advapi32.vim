function! win32#advapi32#GetUserName()
  let msvcrt = libcallex#load('msvcrt.dll')
  let advapi32 = libcallex#load('advapi32.dll')

  " make address of variable which is stored 256
  let ptr = 0 + msvcrt.call('malloc', [4], 'ptr')
  call msvcrt.call('memset', [ptr, 0, 4], '')
  call msvcrt.call('memset', [ptr+1, 1, 1], '')

  let buf = repeat(' ', 256)
  let args = [buf, ptr]
  call advapi32.call('GetUserNameA', args, '')
  let username = args[0]

  call msvcrt.call('free', [ptr], '')

  call advapi32.free()
  call msvcrt.free()
  return username
endfunction
