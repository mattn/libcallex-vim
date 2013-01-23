
let msvcrt = libcallex#load("msvcrt.dll")
echo msvcrt.call("getenv", ["USERNAME"], "string")
call msvcrt.free()
