#NoTrayIcon
#RequireAdmin
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Setup.ico
#AutoIt3Wrapper_Outfile=Windows7GifViewer.exe
Global $Name = "Windows7GifViewer"	;the name of the programm is now stored in variable $Name, so if we want to change it, it's easy
;Global $Name = "WindowsPictureandFaxViewer"	;Posible alturnate name? Gif viewer implies Gifs only, and honestly, I like to change the origional files / naming as little as posible
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

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
#include <GUIConstantsEx.au3>
#Include <ScrollBarConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <GUIEdit.au3>
#include <File.au3>
#include <Process.au3>
#include <WinAPI.au3>

OnAutoItExitRegister("Cleanup")
Global $aTypes[8] = [ 7, "BMP", "JPEG", "JPG", "PNG", "ICO", "TIFF", "GIF" ];used by instal, maininstaller, and uninstal funcs so moved up here
;~ Global $Name = "Windows7GifViewer.exe"	;Declaired up top, can be declaired here too

;moved the main script up top
ConsoleWrite("Hello"&@CRLF)
MainInstaller()
ConsoleWrite("Bye"&@CRLF)

;then have all the functions. It doesn't really matter, but most people have
;	includes and global declaration at top,
;	then main code,
;	then functions underneith
Func MainInstaller()
	Local $defaultpath = @ProgramFilesDir&"\"&$Name
	Local $cTypes[$aTypes[0]+1], $iCurTab, $iNextTab, $i, $Quick = False
	Local $hTab[5]
	Consolewrite("Started Main loop"&@CRLF)
	Consolewrite("Generating GUI..."&@CRLF)

	FileInstall('.\splash.jpg',@TempDir&'\splash.jpg')

	#Region ### START Koda GUI section ### Form=
	$GUI = GUICreate("Windows Picture and Fax Viewer for Win7", 426, 342, 192, 124)
	GUICtrlCreatePic(@TempDir & "\splash.jpg", 0, 0, 425, 155)
	$hTabs = GUICtrlCreateTab(0, 160, 425, 153)
	$hTab[0] = GUICtrlCreateTabItem("Welcome!")
		GUICtrlSetState(-1,$GUI_SHOW)
		GUICtrlCreateLabel( "Welcome to the Windows Picture and Fax Viewer installer for Win7 (and maybe 8)."&@CRLF& _
							"This will install Windows Picture and Fax Viewer, the picture viewer that came stock with XP. "& _
							"If you liked the way Windows Picture and Fax Viewer worked in WinXP, then you'll like this."&@CRLF&@CRLF& _
							"Windows Picture and Fax Viewer.", 8, 186, 399, 78)

	$hTab[1] = GUICtrlCreateTabItem("Install Path")
		GUICtrlCreateLabel("Please select the directory to install Windows Picture and Fax Viewer:", 8, 192, 329, 17)
		$iPath = GUICtrlCreateInput($defaultpath, 8, 216, 335, 21)
		$bBrowse = GUICtrlCreateButton("Browse...", 344, 216, 72, 21)

	$hTab[2] = GUICtrlCreateTabItem("File Types")
		Consolewrite("	Loading types...")
		For $i = 1 to $aTypes[0]
			Consolewrite("	"&$aTypes[$i])
			$cTypes[$i] = GUICtrlCreateCheckbox("."&$aTypes[$i], (144*Mod($i,3))-120+144, 192+(24*Floor(($i-1)/3)), 97, 17)
			if $aTypes[$i] = "GIF" Then GUICtrlSetState( $cTypes[$i], $GUI_CHECKED)
		Next
		Consolewrite("	Done!"&@CRLF)

	$hTab[3] = GUICtrlCreateTabItem("Instalation Progress")
		Global $Edit1 = GUICtrlCreateEdit("", 8, 184, 409, 121, BitOR($ES_AUTOVSCROLL,$ES_WANTRETURN,$WS_VSCROLL,$WS_HSCROLL))
		GUICtrlSetData(-1, "Started, Creating GUI..."&@CRLF)

	$hTab[4] = GUICtrlCreateTabItem("Status")

	GUICtrlCreateTabItem("")

	$bQuickInstall = GUICtrlCreateButton("Just install the damn thing", 78, 314, 184, 25)
	$bUninstall = GUICtrlCreateButton("Uninstall", 2, 314, 75, 25)
	$bNext = GUICtrlCreateButton("Next", 347, 314, 75, 25)
	$bPrev = GUICtrlCreateButton("Back", 271, 314, 75, 25)
	GUICtrlSetState($bPrev, $GUI_HIDE)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###
	_Consolewrite("GUI Done! Starting Main Loop"&@CRLF)

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				FileDelete(@TempDir&"\splash.jpg")
				Exit

			Case $bNext
				$iCurTab = GUICtrlRead($hTabs)
				GUICtrlSetState($hTab[$iCurTab + 1], $GUI_SHOW)
				$nMsg = $hTabs

			Case $bPrev
				$iCurTab = GUICtrlRead($hTabs)
				GUICtrlSetState($hTab[$iCurTab - 1], $GUI_SHOW)
				$nMsg = $hTabs

			Case $bQuickInstall
				$Quick = True
				GUICtrlSetState($hTab[3], $GUI_SHOW)
				$nMsg = $hTabs

		EndSwitch

		If $nMsg = $hTabs Then
			$iCurTab = GUICtrlRead($hTabs)
			If $iCurTab <= 0 Then
				GUICtrlSetState($bPrev, $GUI_HIDE)
				GUICtrlSetState($bNext, $GUI_SHOW)
			ElseIf $iCurTab >= UBound($hTab)-1 Then
				GUICtrlSetState($bPrev, $GUI_SHOW)
				GUICtrlSetState($bNext, $GUI_HIDE)
			Else
				GUICtrlSetState($bPrev, $GUI_SHOW)
				GUICtrlSetState($bNext, $GUI_SHOW)
			EndIf

			ConsoleWrite("HI	"&$iCurTab&@CRLF)
			Switch $iCurTab
				Case 3
;~ 					If $Quick = True or MsgBox(4, "Install", "Ready to start instalation?") = 6 Then
						$sTemp = ""
						For $i = 1 To $aTypes[0]
							If GUICtrlRead($cTypes[$i]) = $GUI_CHECKED Then $sTemp &= $aTypes[$i] & "|"
						Next
						$sTemp = StringTrimRight($sTemp,1)

						GUICtrlSetState($bNext, $GUI_DISABLE)
						GUICtrlSetState($bPrev, $GUI_DISABLE)
						GUICtrlSetState($bQuickInstall, $GUI_DISABLE)
						GUICtrlSetState($bUninstall, $GUI_DISABLE)
						ConsoleWrite("GIF_Install	"&GUICtrlRead($iPath)&"	"&$sTemp&@CRLF)
						$result = WPaFV_Install(GUICtrlRead($iPath),$sTemp, $Quick)
						sleep(2000)
						$Quick = False
						GUICtrlSetState($bNext, $GUI_ENABLE)
						GUICtrlSetState($bPrev, $GUI_ENABLE)
						GUICtrlSetState($bQuickInstall, $GUI_ENABLE)
						GUICtrlSetState($bUninstall, $GUI_ENABLE)

						If $result = 1 Then GUICtrlSetState($hTab[$iCurTab + 1], $GUI_SHOW)

;~ 					EndIf
			EndSwitch

		EndIf

	WEnd

EndFunc


Func WPaFV_Install($Path, $sTypes = 'GIF', $Quick = False)

	Local $aTypes = StringSplit($sTypes,'|')
	Local $iType, $Type
	_ConsoleWrite("Starting Install"&@CRLF)

	ConsoleWrite($sTypes&@CRLF)
	If not IsArray($aTypes) Then
		ConsoleWrite("ERROR -2: Type error!"&@CRLF)
		return -2
	EndIf


	If StringRight($Path, StringLen($Name)) = $Name Then $Path = StringReplace($Path, "\"&$Name, "")
	_ConsoleWrite("Path = "& $Path & "\"&$Name&@CRLF)


	;Detect if another installation exists
	CleanOtherInstalls()

	_Consolewrite("Checking for old installs..."&@CRLF)
	;If already installed (by registry check)
	If RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers", $Path & "\" & $Name & "\rundll32.exe") = "WINXPSP3" Or FileExists($Path & '\" & $Name & "') Then

		_Consolewrite("	Old installs found"&@CRLF)
		;If we're doign a quick install don't ask questions just get it done
		If $Quick Then
			_Consolewrite("	Removing...")
			WPaFV_Uninstall($Path, "GIF")
			_Consolewrite("	Done"&@CRLF)

		Else	;Otherwise ask to remove

			_Consolewrite("	Asking user to remove old installs")
			Switch MsgBox(3, "Application already installed", "Setup has detected a previous installation" & @CRLF & "Would you like to uninstall the existing Windows 7 Gif Viewer first?")
				Case 6	;they say yes
					_Consolewrite("	Removing...")
					WPaFV_Uninstall($Path, "GIF")
					_Consolewrite("	Done"&@CRLF)

				Case 2	;they say no
					_Consolewrite("ERROR -1: Installation Cancled by User. Click the install button below to retry.")
					Return -1

			EndSwitch	;In this case, no and no response is the same thing so just ocntinue the script

		EndIf	;end quickinstall check
	EndIf	;end already installed check
	_Consolewrite("Check end"&@CRLF)

	_Consolewrite('Installing...' & @CRLF)
	;Let's copy the system's rundll32.exe. Not only will this reduce file size
	;	but will prevent other malicious jerks from changing it with a bad exe,
	;	and will prevent "exe in an exe" flags from antiviri
	;	Flag 9 will overwrite (flag 1), AND make the folder if it does not exist! (flag 8)
	FileCopy(@WindowsDir & '\system32\rundll32.exe', $Path & '\' & $Name & '\rundll32.exe', 9)
	_Consolewrite(@error&'	Copied "'&@WindowsDir & '\system32\rundll32.exe" to '& $Path & '\' & $Name & '\rundll32.exe'&@CRLF)

	;Using ".\shimgvw.dll" is the same as @ScriptDir & "\shimgvw.dll",
	;	so it will use the dll that's in the source folder
	FileInstall('.\shimgvw.dll', $Path & '\' & $Name & '\shimgvw.dll', 1)
	_Consolewrite(@error&'	Installed shimgvw.dll to ' & $Path & '\' & $Name & '\shimgvw.dll'&@CRLF)

	;Note:- This works from an uncompiled script and the source files can be either in the script directory or referenced from somewhere else in this case and works
	;For some reason again this likes to only register from the command line?
	Run(@ComSpec & ' /c regsvr32 /s ' & $Path & "\" & $Name & "\rundll32.exe", 	$Path & "\" & $Name, @SW_HIDE)
	_Consolewrite(@error&'	' & @ComSpec & ' /c regsvr32 /s ' & $Path & "\" & $Name & "\rundll32.exe" & @CRLF)
	Run(@ComSpec & ' /c regsvr32 /s ' & $Path & "\" & $Name & "\shimgvw.dll", 	$Path & "\" & $Name, @SW_HIDE)
	_Consolewrite(@error&'	' & @ComSpec & ' /c regsvr32 /s ' & $Path & "\" & $Name & "\shimgvw.dll" & @CRLF)

	for $iType = 1 to $aTypes[0]
		$Type = $aTypes[$iType]	;I like arrays. Can you tell? :D

		_Consolewrite("	Regestering type "&$Type&@CRLF)
		;Here commence normal Writes to the registry....all is good from here on
		RegWrite('HKEY_CLASSES_ROOT\.'&$Type, 										'', 				'REG_SZ', 			$Type&'Image.Document')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\."&$Type&", '', 'REG_SZ', "&$Type&'Image.Document'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', 'EditFlags', 			'REG_DWORD', 		'65536')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, EditFlags, REG_DWORD, 65536"&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', 'FriendlyTypeName', 	'REG_EXPAND_SZ', 	'@' & $Path & '\' & $Name & '\shimgvw.dll,-306')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, FriendlyTypeName, REG_EXPAND_SZ, @"& $Path & '\' & $Name & '\shimgvw.dll,-306'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', 'InstallTemp',		'REG_EXPAND_SZ', 	@ScriptDir)
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, InstallTemp,	REG_EXPAND_SZ, "&@ScriptDir&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', 'ImageOptionFlags', 	'REG_DWORD', 		'0')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, ImageOptionFlags, REG_DWORD, 0"&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', 'BrowserFlags', 		'REG_DWORD', 		'8')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, BrowserFlags, REG_DWORD, 8"&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document', '', 					'REG_SZ', 			$Type&' Image')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document, '', REG_SZ, "&$Type&' Image'&@CRLF)

		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\DefaultIcon', 			'', 		'REG_EXPAND_SZ',	'@' & $Path & '\' & $Name & '\shimgvw.dll,4')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\DefaultIcon', '', REG_EXPAND_SZ, @" & $Path & '\' & $Name & '\shimgvw.dll,4'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell', 				'', 		'REG_SZ', 			'')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell, '', REG_SZ, ''"&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell\open', 			'', 		'REG_SZ', 			$Name)
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell\open, '', REG_SZ, Windows 7 "&$Type&' Viewer'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell\open', 			'Icon', 	'REG_SZ', 			$Path & '\' & $Name & '\shimgvw.dll,1')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell\open, Icon, REG_SZ, " & $Path & '\' & $Name & '\shimgvw.dll,1'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell\open\command', 	'', 		'REG_EXPAND_SZ',	$Path & '\' & $Name & '\rundll32.exe shimgvw.dll,ImageView_Fullscreen %1')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell\open\command, '', 'REG_EXPAND_SZ', " & $Path & '\' & $Name & '\rundll32.exe shimgvw.dll,ImageView_Fullscreen %1'&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell\open\DropTarget', 'Clsid', 	'REG_SZ', 			'{E84FDA7C-1D6A-45F6-B725-CB260C236066}')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell\open\DropTarget, Clsid, REG_SZ, {E84FDA7C-1D6A-45F6-B725-CB260C236066}"&@CRLF)
		RegWrite('HKEY_CLASSES_ROOT\'&$Type&'Image.Document\shell\printto\command',	'', 		'REG_SZ', 			$Path & '\' & $Name & '\rundll32.exe shimgvw.dll,ImageView_PrintTo /pt "%1" "%2" "%3" "%4"')
		_Consolewrite("	"&@error&"	Registering	HKEY_CLASSES_ROOT\"&$Type&"Image.Document\shell\printto\command, '', 'REG_SZ', " & $Path & '\' & $Name & '\rundll32.exe shimgvw.dll,ImageView_PrintTo /pt "%1" "%2" "%3" "%4"'&@CRLF)
		_Consolewrite(@CRLF)

	Next

	_Consolewrite("	Setting Compatibility Mode..."&@CRLF)
	RegWrite('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $Path & '\' & $Name & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')
	;Corrected the key from HKLM to HKCU to make this work - This is why rundll32.exe was not actually being set to Windows SP3 mode
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $Path & '\' & $Name & '\rundll32.exe', 'REG_SZ', 'WINXPSP3')

	RunWait(@ComSpec & " /e:on /f:on /s /k ", "taskkill /f /IM explorer.exe >nul 2>&1", @SW_HIDE)

	_Consolewrite("Installation completed successfully!"&@CRLF&"Open an image and see if it worked."&@CRLF&"To reinstall, hit back then next or click the download button below"&@CRLF)
	return 1
EndFunc

Func WPaFV_Uninstall($Path, $sTypes = 'ALL')
	If $sTypes <> "ALL" Then Local $aTypes = StringSplit($sTypes,'|')
	Local $iType, $Type
	_Consolewrite('Removeing...' & @CRLF)
	for $iType = 1 to $aTypes[0]
		$Type = $aTypes[$iType]	;makes it simpler on our brains for the rest of it
		_Consolewrite('	'&$Type&@CRLF)
		RegDelete('HKEY_CLASSES_ROOT\.' & $Type)
		_Consolewrite(@error & '	HKEY_CLASSES_ROOT\.' & $Type &@CRLF)

		RegDelete('HKEY_CLASSES_ROOT\' & $Type & 'Image.Document')
		_Consolewrite(@error & '	HKEY_CLASSES_ROOT\' & $Type & 'Image.Document' &@CRLF)

		RegDelete('HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers', $Path & '\' & $Name & '\rundll32.exe')
		_Consolewrite(@error & '	HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers	' & $Path & '\' & $Name & '\rundll32.exe' &@CRLF)

	Next
	FileSetAttrib($Path, "-RS", 1)	;should work, will test. Filedelete can't delete files of certin attibutes (Probably as a security feature). We'll use dos if we have to
	FileDelete($Path & "\" & $Name)
	DirRemove($Path & "\" & $Name)
	;neither of the above work so good ol dos seems to do the trick here
;~ 	Run(@ComSpec & ' /c rd ' & $Name & ' >nul 2>&1', $Path, @SW_HIDE)	;you don't need to specify a variable for the command
;~ 	Run(@ComSpec & ' /c del /Q' & $Path & '\' & $Name & ' >nul 2>&1', $Path, @SW_HIDE)	;and you could have reused $command instead of making a $command1, $command2, etc
EndFunc

Func _Consolewrite($s)
	Consolewrite($s); holder for proper logging
	GUICtrlSetData($Edit1, GUICtrlRead($Edit1) & $s)
	local $iEnd = StringLen(GUICtrlRead($Edit1))
    _GUICtrlEdit_SetSel($Edit1, $iEnd, $iEnd)
	_GUICtrlEdit_Scroll($Edit1, $SB_SCROLLCARET)
EndFunc

Func CleanOtherInstalls()
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
EndFunc

Func Cleanup()
	FileDelete(@TempDir & "\splash.jpg")
EndFunc   ;==>Cleanup
