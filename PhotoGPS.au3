; by arakel2 - https://github.com/arakel2/photogps

#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=photogps.ico
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_Res_Description=GUI for Exiftool for easy geotagging of photos
#AutoIt3Wrapper_Res_Fileversion=1
#AutoIt3Wrapper_Res_ProductName=PhotoGPS
#AutoIt3Wrapper_Res_ProductVersion=1
#AutoIt3Wrapper_Res_LegalCopyright=MIT License
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiEdit.au3>

Opt("GUIOnEventMode", 1)

$Main = GUICreate("PhotoGPS", 506, 666, 264, 126, -1, BitOR($WS_EX_ACCEPTFILES,$WS_EX_WINDOWEDGE))
GUISetOnEvent($GUI_EVENT_CLOSE, "MainClose")
$grLocation = GUICtrlCreateGroup("Location", 8, 8, 489, 49)
$btnPasteGeo = GUICtrlCreateButton("Paste", 400, 24, 75, 25)
GUICtrlSetOnEvent(-1, "btnPasteGeoClick")
$lbLatitude = GUICtrlCreateLabel("Latitude", 16, 28, 42, 17)
$lbLongitude = GUICtrlCreateLabel("Longitude", 200, 28, 51, 17)
$inLat = GUICtrlCreateInput("0", 64, 26, 121, 21)
$inLong = GUICtrlCreateInput("0", 256, 26, 121, 21)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$lbDragPhoto = GUICtrlCreateLabel("Drag Photos", 8, 64, 63, 17)
$edFiles = GUICtrlCreateEdit("", 8, 88, 489, 249)
GUICtrlSetState(-1, $GUI_DROPACCEPTED)
$btnWrite = GUICtrlCreateButton("Write GPS Data", 8, 344, 91, 25)
GUICtrlSetOnEvent(-1, "btnWriteClick")
$btReset = GUICtrlCreateButton("Reset", 104, 344, 75, 25)
GUICtrlSetOnEvent(-1, "btResetClick")
$btExit = GUICtrlCreateButton("Exit", 424, 344, 75, 25)
GUICtrlSetOnEvent(-1, "btExitClick")
$edDOS = GUICtrlCreateEdit("", 8, 376, 489, 281, BitOR($GUI_SS_DEFAULT_EDIT,$ES_READONLY))
GUICtrlSetColor(-1, 0xFFFFFF)
GUICtrlSetBkColor(-1, 0x000000)
GUISetState(@SW_SHOW)


Const $exiftool = "exiftool.exe "                    			  ; If exiftool.exe is in the same folder as PhotoGPS

; Const $exiftool = "G:\Tools\Exiftool\exiftool.exe "  			  ; Absolute path to exiftool.exe

; $sUSB_Drive = StringLeft(@ScriptDir, 2)                         ; Drive for portable installation
; Const $exiftool = $sUSB_Drive&"\Tools\Exiftool\exiftool.exe "   ; Path to portable installation of exiftool.exe

WinSetOnTop("PhotoGPS", "", 1) ; Window always on Top

While 1
	Sleep(100)
WEnd

Func _IsNumerical($vValue) ;Credits: Bowmore https://www.autoitscript.com/forum/topic/97315-isnumerical/
  If IsNumber($vValue) Then Return True
  If StringRegExp($vValue, "(^[+-]?[0-9]+\.?[0-9]*$|^0x[0-9A-Fa-f]{1,8}$|^[0-9]+\.?[0-9]*[Ee][+-][0-9]+$)") Then Return True
  Return False
EndFunc

Func btExitClick()
	Exit
EndFunc

Func btnPasteGeoClick()
	$sGeo = StringSplit(ClipGet(), ",")
	Local $iLife = 42
	If _IsNumerical($sGeo[1]) AND _IsNumerical(StringStripWS($sGeo[2],1)) Then
		GUICtrlSetData($inLat, $sGeo[1])
		GUICtrlSetData($inLong, StringStripWS($sGeo[2],1))
	Else
		MsgBox(4112, "Error", "Please copy position from Google Maps")
	EndIf
EndFunc

Func btnWriteClick()
	if _GUICtrlEdit_GetLine($edFiles, 0) <> '' Then
		$fLat = Number(GUICtrlRead($inLat))
		$fLong = Number(GUICtrlRead($inLong))
		$sLat = $fLat > 0 ? 'N' : 'S'
		$sLong = $fLong > 0 ? 'E' : 'W'
		Local $sOutput = ""
		For $i=0 to _GUICtrlEdit_GetLineCount($edFiles)-1 Step 1
		$hFileOpen = FileOpen(_GUICtrlEdit_GetLine($edFiles, $i), $FO_READ)
			If $hFileOpen = -1 Then
				MsgBox(4112, "Error", "File " & _GUICtrlEdit_GetLine($edFiles, $i) & " not found!")
			Else
				$cmd = $exiftool & "-overwrite_original -GPSLatitude="& $fLat & " -GPSLatitudeRef=" & $sLat & " -GPSLongitude=" & $fLong & " -GPSLongitudeRef=" & $sLong & " " & _GUICtrlEdit_GetLine($edFiles, $i)
				$sOutput &= $cmd&@crlf
				GUICtrlSetData($edDOS, $sOutput)
				$iPID = Run($cmd , "" , @SW_HIDE, $STDOUT_CHILD)
				ProcessWaitClose($iPID)
				$sOutput &= StdoutRead($iPID)
				If @error Then
					MsgBox($MB_SYSTEMMODAL, "", "It appears there was an error trying to find all the files in the current script directory.")
				Else
					GUICtrlSetData($edDOS, $sOutput)
				EndIf
			EndIf
		Next
		$sOutput &= @crlf&"Done"
		GUICtrlSetData($edDOS, $sOutput)
	Else
		MsgBox(4112, "Error", "Please drag photos to edit field!")
	EndIf
	GUICtrlSetData($edFiles, '')
EndFunc

Func btResetClick()
	GUICtrlSetData($inLat, 0)
	GUICtrlSetData($inLong, 0)
	GUICtrlSetData($edFiles, '')
EndFunc

Func MainClose()
	Exit
EndFunc
