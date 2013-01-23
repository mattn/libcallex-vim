let msg = ""
\."your windows directory: " . win32#kernel32#GetWindowsDirectory() . "\n"
\."your system directory : " . win32#kernel32#GetSystemDirectory()  . "\n"
\."your username         : " . win32#advapi32#GetUserName()         . "\n"

echo win32#user32#MessageBox(0, msg, "your info", 4)
