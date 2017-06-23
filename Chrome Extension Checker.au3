#NoTrayIcon

#Region AutoIt3Wrapper directives section
#AutoIt3Wrapper_Icon=juno_okyo.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=Y
#AutoIt3Wrapper_Res_Comment=Developed by Juno_okyo
#AutoIt3Wrapper_Res_Description=Developed by Juno_okyo
#AutoIt3Wrapper_Res_Fileversion=1.0.0.2
#AutoIt3Wrapper_Res_FileVersion_AutoIncrement=Y
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=(C) 2017 Juno_okyo. All rights reserved.
#AutoIt3Wrapper_Res_Field=CompanyName|J2TeaM
#AutoIt3Wrapper_Res_Field=Website|https://junookyo.blogspot.com/
#AutoIt3Wrapper_Compile_both=Y
#EndRegion AutoIt3Wrapper directives section

#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <Array.au3>
#include <File.au3>
#include <GuiEdit.au3>
#include <ScrollBarsConstants.au3>
#include <Misc.au3>

_Singleton(@ScriptName)
Opt('MustDeclareVars', 1)

Global Const $EXTENSIONS_PATH = @LocalAppDataDir & '\Google\Chrome\User Data\Default\Extensions\'

#Region ### START Koda GUI section ### Form=
Global $Form1 = GUICreate("[J2TEAM] Chrome Extension Checker by Juno_okyo", 700, 425)
GUISetFont(12, 400, 0, "Segoe UI")
Global $Label1 = GUICtrlCreateLabel("Path to Extensions:", 16, 18, 133, 25)
Global $Input1 = GUICtrlCreateInput($EXTENSIONS_PATH, 160, 16, 377, 29)
GUICtrlSetState(-1, $GUI_FOCUS)
Global $Button1 = GUICtrlCreateButton("...", 552, 16, 43, 29)
GUICtrlSetCursor(-1, 0)
Global $Button2 = GUICtrlCreateButton("Start", 608, 16, 75, 29)
GUICtrlSetCursor(-1, 0)
GUICtrlSetState(-1, $GUI_DEFBUTTON)
Global $Edit1 = GUICtrlCreateEdit("Waiting...", 16, 64, 666, 305, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSetBkColor(-1, 0x333333)
GUICtrlSetColor(-1, 0x7be083)

GUIStartGroup()
Global $Button3 = GUICtrlCreateButton("Fan-page", 172, 384, 100, 29)
GUICtrlSetCursor(-1, 0)
Global $Button4 = GUICtrlCreateButton("Group", 293, 384, 75, 29)
GUICtrlSetCursor(-1, 0)
Global $Button5 = GUICtrlCreateButton("Opensource", 389, 384, 115, 29)
GUICtrlSetCursor(-1, 0)
GUIStartGroup()

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	Local $nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit

		Case $Button1
			selectExtensionsFolder()

		Case $Button2
			startScan()

		Case $Button3
			ShellExecute('https://www.facebook.com/J2TeaM.pro/')

		Case $Button4
			ShellExecute('https://www.facebook.com/groups/j2team.community/')

		Case $Button5
			ShellExecute('https://github.com/J2TeaM/chrome-extension-checker')

	EndSwitch
WEnd

Func startScan()
	GUICtrlSetData($Edit1, '')

	Local $path = GUICtrlRead($Input1)
	If $path And FileExists($path) Then
		If StringLeft($path, 1) <> '\' Then $path &= '\'

		Local $extensions = _FileListToArray($path, '*', 2)
		_log('Total extensions: ' & $extensions[0] & @CRLF)

		; Remove counter
		_ArrayDelete($extensions, 0)

		For $extension In $extensions
			checkExtension($path, $extension)
		Next

		_log('Done!' & @CRLF)
	Else
		MsgBox(16 + 262144, 'Error', 'Please select a valid path to Extensions folder!', 0, $Form1)
		GUICtrlSetState($Input1, $GUI_FOCUS)
		selectExtensionsFolder()
		Return False
	EndIf
EndFunc

Func checkExtension($path, $extension)
	If StringLen($extension) <> 32 Then Return False

	_log('Checking extension: ' & $extension & @TAB)

	; Ignore IDs
	If $extension == 'ngpampappnmepgilojfohadhhmbhlaek' Or $extension == 'hmlcjjclebjnfohgmgikjfnbmfkigocc' Then
		_log(' [OK]' & @CRLF)
		Return True
	EndIf

	; Malware extension ID
	If $extension == 'ldobpmmlhhamdbpcipmehcibdlkoliah' Then
		_log(' [Malware Extension]' & @CRLF)
		Return False
	EndIf

	; Read manifest.json
	Local $manifestPath = getManifestPath($path & $extension)
	If $manifestPath == False Then
		_log(' [ERROR]' & @CRLF)
		Return False
	Else
		Local $fp = FileOpen($manifestPath)
		Local $data = FileRead($fp)
		FileClose($fp)

		If StringInStr($data, '"name": "IDM Integration Module"') Then
			If StringInStr($data, '"author": "J2Team"') Then
				_log(' [Malware Extension]' & @CRLF)
			Else
				_log(' [Fake IDM Extension]' & @CRLF)
			EndIf
			Return False
		EndIf
	EndIf

	; Everything is OK
	_log(' [OK]' & @CRLF)
	Return True
EndFunc

Func getManifestPath($path)
	Local $tempArr = _FileListToArray($path, '*', 2, True)
	If Not @error And $tempArr[0] == 1 Then
		Return $tempArr[1] & '\manifest.json'
	Else
		Return False
	EndIf
EndFunc

Func _log($msg)
	_GUICtrlEdit_AppendText($Edit1, $msg)

	; Auto scroll to the end
	Local $iEnd = StringLen(GUICtrlRead($Edit1))
	_GUICtrlEdit_SetSel($Edit1, $iEnd, $iEnd)
	_GUICtrlEdit_Scroll($Edit1, $SB_SCROLLCARET)
EndFunc

Func selectExtensionsFolder()
	Local $fp = FileSelectFolder('Select folder', $EXTENSIONS_PATH, 0, '', $Form1)
	If Not @error Then GUICtrlSetData($Input1, $fp)
EndFunc