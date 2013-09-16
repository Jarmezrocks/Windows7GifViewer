;~ FileSetAttrib("C:\Windows\system32\rundll32.exe", "-RS")
DirCreate("C:\Program Files (x86)\123")
FileCopy("C:\Windows\system32\rundll32.exe" , "C:\Program Files (x86)\Windows7GifViewer\rundll32.exe",9)
;~ FileSetAttrib("C:\Windows\system32\rundll32.exe", "+RS")