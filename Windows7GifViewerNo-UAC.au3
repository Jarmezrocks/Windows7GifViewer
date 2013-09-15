#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=SetupNo-UAC.ico
#AutoIt3Wrapper_Outfile=Windows_7_GifViewerNoUAC.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#cs ----------------------------------------------------------------------------
	
	AutoIt Version: 3.3.8.1
	Author: Jarmezrocks aka Digitalfacade82 jarmezrocks@gmail.com
	
	Script Function:
	This installer is based off the one written by Corgano, CorganoWade@gmail.com from sevenforums and autoIT forums
	
	Additions added by me:
	1. Instead of forcing us to install anywhere let alone root of the system drive I would rather give people a choice. This makes the solution a bit more "polished"
	- Note as it was I was using Corgano's installer and then carrying with me an additional reg file to run afterwards to move the install away from the root of C:\ and correct the following:
	
	2. I made some small adjustments to Registry writes to incorrect locations that were annoying for me to have to go and change after installing
	3. Correctly added the rundll32.exe in compatability mode for Windows XP Service Pack 3
	4. I fixed a lot of spelling mistakes, but drastically changed the script so most likely added some as well :-)
	
	Notes taken directly from Corgano's script
	
	"This script provides a one-click Installation for easy gif viewing experience identical (literally!)
	to that of windows XP
	
	Terms of use:
	This script is free to use, distribute, modify, and what else have your fancies be as long as these
	three conditions are met
	1: This header must remain intact with any mods or copies of this script
	2: You may not sell or in any way make profit off of this script. It's free, for free use by
	anyone, anywhere.
	3: This is by no means an official fix. It's just a workaround to make windows XP's photo viewer
	work on win 7. May work for win 8, may fuck up your computer. I'm not responsible for any loss of
	data or hair as result of this program
	
	What it does:
	This is based off of this idea - http://www.goofwear.com/windows/
	However, there were many errors. All the addresses were static, and assumed that the system drive was
	C:. It doesn't work if your system drive isn't C:, so I re-wrote it to use %WinDir% making it much, MUCH more robust. I also moved the
	files to windows\gif, which is cleaner IMO. Replaced the modified "shimgvw.dll" with the real file
	and wrote a simpler Installer
	
	1.1
	Added an unInstall option
	Fixed spelling mistakes (derp)
	Added message confirming Install
	
	Enjoy"
	
	You will require AutoIT version 3x to run this as an uncompiled script. Please use the exe provided.
	
#ce ----------------------------------------------------------------------------
$Title = "Windows 7 Fax & Scan Gif Viewer"
#include <GUIConstantsEx.au3>
#include <File.au3>
#include <Process.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <WinAPI.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>

WinSetOnTop("Windows_7_GifViewerNoUAC.exe", "", 1)
Opt("WinTitleMatchMode", 2)


Func CreateSplash()
	EnvSet("path", EnvGet("path") & ";" & @ScriptDir)
	;Include splash image in exe
	FileInstall("splash.jpg", @TempDir & "\splash.jpg", 1)

	;Show splash
	$splash = GUICreate("Loading...", 430, 154, -1, -1, $WS_POPUPWINDOW)
	WinSetTrans($splash, "", 0)
	GUICtrlCreatePic(@TempDir & "\splash.jpg", -0, -0, 432, 155)
	GUISetState(@SW_SHOW, $splash)
	For $i = 0 To 255 Step 6
		WinSetTrans($splash, "", $i)
		Sleep(1)
	Next
	Sleep(3000)
	GUIDelete($splash)
	MsgBox(0, "", "Please select a location to install Windows 7 Gif Viewer")
EndFunc   ;==>CreateSplash


Func SystemCheck()
	Local $path = FileSelectFolder("Please select install location", "")
	Local $command, $command1, $command2, $command3, $command4, $command5, $Msg1
	;Detect if another installation exists
	If FileExists('C:\rundll32.exe') Then
		FileDelete('C:\rundll32.exe')
	EndIf
	If FileExists('C:\shimgvw.dll') Then
		FileDelete('C:\shimgvw.dll')
	EndIf
	If FileExists('C:\Windows\Gif\rundll32.exe') Then
		FileDelete('C:\Windows\Gif\rundll32.exe')
	EndIf
	If FileExists('C:\Windows\Gif\shimgvw.dll') Then
		FileDelete('C:\shimgvw.dll')
	EndIf
	If FileExists('C:\Windows\Gif') Then
		Run(@ComSpec & " /c rd C:\Windows\Gif", @SW_HIDE)
	EndIf
	If RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", $path & "\Windows7GifViewer\rundll32.exe") = "WINXPSP3" Or FileExists($path & '\Windows7GifViewer') Then
		;If one does exist ask to remove it
		$Msg1 = MsgBox(3, "Application already installed", "Setup has detected a previous installation" & @CRLF & "Would you like to uninstall the existing Windows 7 Gif Viewer first?")
		Select
			Case $Msg1 = 6
				ConsoleWrite("Remove" & @CRLF)
				RegDelete('HKEY_CLASSES_ROOT\.GIF')
				RegDelete('HKEY_CLASSES_ROOT\GIFImage.Document')
				RegDelete("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", $path & "\Windows7GifViewer\rundll32.exe")
				FileDelete($path & "\Windows7GifViewer")
				DirRemove($path & "\Windows7GifViewer")
				;neither of the above work so good ol dos seems to do the trick here
				$command = 'rd Windows7GifViewer ' & '>nul ' & '2>&1'
				Run(@ComSpec & " /c " & $command, $path, @SW_HIDE)
				$command1 = 'del /Q' & $path & '\Windows7GifViewer ' & '>nul ' & '2>&1'
				Run(@ComSpec & " /c " & $command, $path, @SW_HIDE)
				MsgBox(0, "Existing Installation Removed", "Please re-run the installer to install again")
			Case $Msg1 = 7
				Local $RegPath = ($path & "\Windows7GifViewer\shimgvw.dll,4")
				; Double check there's no directory before prompting the user if they want to create one
				If Not FileExists($path & '\Windows7GifViewer') Then
					If MsgBox(36, "Location does not exist", "There is no directory for Windows 7 Gif Viewer? " & @CRLF & "Would you like to create one?") = 6 Then
						DirCreate($path & '\Windows7GifViewer')
						ConsoleWrite("Install" & @CRLF)
						;Commence installation
						EnvSet("path", EnvGet("path") & ";" & @ScriptDir)
						FileInstall("rundll32.exe", $path & "\Windows7GifViewer\rundll32.exe", 1)
						FileInstall("shimgvw.dll", $path & "\Windows7GifViewer\shimgvw.dll", 1)
						;For some reason again this likes to only register from the command line?
						$command2 = 'regsvr32 /s ' & $path & "\Windows7GifViewer\rundll32.exe"
						$command3 = 'regsvr32 /s ' & $path & "\Windows7GifViewer\shimgvw.dll"
						Run(@ComSpec & " /c " & $command2, $path & "\Windows7GifViewer", @SW_HIDE)
						Run(@ComSpec & " /c " & $command3, $path & "\Windows7GifViewer", @SW_HIDE)
						;Here commence normal Writes to the registry....all is good from here on
						RegWrite('HKEY_CLASSES_ROOT\.GIF', '', 'REG_SZ', 'GIFImage.Document')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'EditFlags', 'REG_DWORD', '65536')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'FriendlyTypeName', 'REG_EXPAND_SZ', $path & "\Windows7GifViewer\shimgvw.dll" & ',-306')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'InstallTemp', 'REG_EXPAND_SZ', @ScriptDir)
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'ImageOptionFlags', 'REG_DWORD', '0')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'BrowserFlags', 'REG_DWORD', '8')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', '', 'REG_SZ', 'GIF Image')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\DefaultIcon', '', 'REG_EXPAND_SZ', $path & "\Windows7GifViewer\shimgvw.dll" & ',4')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell', '', 'REG_SZ', '')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open', '', 'REG_SZ', 'Windows 7 Gif Viewer')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open', 'Icon', 'REG_SZ', $path & "\Windows7GifViewer\shimgvw.dll")
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open\command', '', 'REG_EXPAND_SZ', $path & '\Windows7GifViewer' & '\rundll32.exe shimgvw.dll,ImageView_Fullscreen %1')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open\DropTarget', 'Clsid', 'REG_SZ', '{E84FDA7C-1D6A-45F6-B725-CB260C236066}')
						RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\printto\command', '', 'REG_SZ', $path & '\Windows7GifViewer' & '\rundll32.exe shimgvw.dll,ImageView_PrintTo /pt "%1" "%2" "%3" "%4"')
						RegWrite('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $path & '\Windows7GifViewer' & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')
						;Corrected the key from HKLM to HKCU to make this work - This is why rundll32.exe was not actually being set to Windows SP3 mode
						RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $path & '\Windows7GifViewer' & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')
						Run("explorer.exe", Call(ProcessClose("explorer.exe")))
						Sleep(500)
						Run("explorer.exe /n,/e," & $path & "\Windows7GifViewer")
						Opt('WinTitleMatchMode', 2)
						Sleep(100)
						WinSetState("Windows7GifViewer", "", @SW_HIDE)
						Sleep(100)
						Run("explorer.exe /n,/e," & @WorkingDir)
						Opt('WinTitleMatchMode', 2)
						Sleep(100)
						WinSetState(@WorkingDir, "", @SW_HIDE)
						Sleep(100)
						WinMinimizeAll()
						Sleep(200)
						Run("explorer.exe /n,/e," & @UserProfileDir & "\Pictures")
						Sleep(500)
						MsgBox(0, "Installation Complete!", "To run any .Gif animation simply double click the .Gif file" & @CRLF & "" & @CRLF & "To Uninstall Windows 7 Gif Viewer, please re-run the installation" & @CRLF & "and select the same location where it was installed")
						Opt('WinTitleMatchMode', 2)
						WinWaitActive("Installation Complete!", "", 3)
						WinSetOnTop("Installation Complete!", "", 1)
						WinSetState("Installation Complete!", "", @SW_MAXIMIZE)
					EndIf
				EndIf
			Case $Msg1 = 2
				MsgBox(48 + 4096, "Installation Aborted!", "User cancelled installation", 5)
				;This part will only work once the script is compiled
				If ProcessExists("Windows_7_GifViewerNoUAC.exe") Then
					OnAutoItExitRegister("Restart")
					Exit
				EndIf
		EndSelect
	Else
		;Obviously here I was lazy and couldn't bothered to a re-arrange all my code with a nicer loop
		;A good developer never re-uses large chunks of code twice!
		If Not FileExists($path & '\Windows7GifViewer') Then
			If MsgBox(36, "Location does not exist", "There is no directory for Windows 7 Gif Viewer? " & @CRLF & "Would you like to create one?") = 6 Then
				DirCreate($path & '\Windows7GifViewer')
				ConsoleWrite("Install" & @CRLF)
				;Commence installation
				EnvSet("path", EnvGet("path") & ";" & @ScriptDir)
				FileInstall("rundll32.exe", $path & "\Windows7GifViewer\rundll32.exe", 1)
				FileInstall("shimgvw.dll", $path & "\Windows7GifViewer\shimgvw.dll", 1)
				;For some reason again this likes to only register from the command line?
				$command4 = 'regsvr32 /s ' & $path & "\Windows7GifViewer\rundll32.exe"
				$command5 = 'regsvr32 /s ' & $path & "\Windows7GifViewer\shimgvw.dll"
				Run(@ComSpec & " /c " & $command4, $path & "\Windows7GifViewer", @SW_HIDE)
				Run(@ComSpec & " /c " & $command5, $path & "\Windows7GifViewer", @SW_HIDE)
				;Here commence normal Writes to the registry....all is good from here on
				RegWrite('HKEY_CLASSES_ROOT\.GIF', '', 'REG_SZ', 'GIFImage.Document')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'EditFlags', 'REG_DWORD', '65536')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'FriendlyTypeName', 'REG_EXPAND_SZ', $path & "\Windows7GifViewer\shimgvw.dll" & ',-306')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'InstallTemp', 'REG_EXPAND_SZ', @ScriptDir)
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'ImageOptionFlags', 'REG_DWORD', '0')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', 'BrowserFlags', 'REG_DWORD', '8')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document', '', 'REG_SZ', 'GIF Image')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\DefaultIcon', '', 'REG_EXPAND_SZ', $path & "\Windows7GifViewer\shimgvw.dll" & ',4')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell', '', 'REG_SZ', '')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open', '', 'REG_SZ', 'Windows 7 Gif Viewer')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open', 'Icon', 'REG_SZ', $path & "\Windows7GifViewer\shimgvw.dll")
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open\command', '', 'REG_EXPAND_SZ', $path & '\Windows7GifViewer' & '\rundll32.exe shimgvw.dll,ImageView_Fullscreen %1')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\open\DropTarget', 'Clsid', 'REG_SZ', '{E84FDA7C-1D6A-45F6-B725-CB260C236066}')
				RegWrite('HKEY_CLASSES_ROOT\GIFImage.Document\shell\printto\command', '', 'REG_SZ', $path & '\Windows7GifViewer' & '\rundll32.exe shimgvw.dll,ImageView_PrintTo /pt "%1" "%2" "%3" "%4"')
				RegWrite('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $path & '\Windows7GifViewer' & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')
				;Corrected the key from HKLM to HKCU to make this work - This is why rundll32.exe was not actually being set to Windows SP3 mode
				RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $path & '\Windows7GifViewer' & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')
				Run("explorer.exe", Call(ProcessClose("explorer.exe")))
				Sleep(500)
				Run("explorer.exe /n,/e," & $path & "\Windows7GifViewer")
				Sleep(100)
				Opt('WinTitleMatchMode', 2)
				WinSetState("Windows7GifViewer", "", @SW_HIDE)
				Sleep(100)
				Run("explorer.exe /n,/e," & @WorkingDir)
				Opt('WinTitleMatchMode', 2)
				WinSetState(@WorkingDir, "", @SW_HIDE)
				Sleep(100)
				WinMinimizeAll()
				Sleep(200)
				Run("explorer.exe /n,/e," & @UserProfileDir & "\Pictures")
				Sleep(500)
				MsgBox(1, "Installation Complete!", "To run any .Gif animation simply double click the .Gif file" & @CRLF & "" & @CRLF & "To Uninstall Windows 7 Gif Viewer, please re-run the installation" & @CRLF & "and select the same location where it was installed")
				Opt('WinTitleMatchMode', 2)
				WinWaitActive("Installation Complete!", "", 3)
				WinSetOnTop("Installation Complete!", "", 1)
				WinSetState("Installation Complete!", "", @SW_MAXIMIZE)
			EndIf
		EndIf
	EndIf
EndFunc   ;==>SystemCheck

Func Restart()
	Run(@ScriptDir & "\Windows_7_GifViewerNoUAC.exe")
EndFunc   ;==>Restart

Func Cleanup()
	FileDelete(@TempDir & "\splash.jpg")
EndFunc   ;==>Cleanup

Sleep(100)
CreateSplash()
SystemCheck()
Cleanup()
