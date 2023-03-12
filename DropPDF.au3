#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ICO\pdf.ico
#AutoIt3Wrapper_Outfile=DropPDF.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=DropPDF reduce size of pdf files
#AutoIt3Wrapper_Res_Fileversion=1.1
#AutoIt3Wrapper_Res_ProductName=DropPDF
#AutoIt3Wrapper_Res_ProductVersion=1.1
#AutoIt3Wrapper_Res_CompanyName=https://github.com/yann83
#AutoIt3Wrapper_Res_LegalCopyright=Licence MIT
#AutoIt3Wrapper_Res_Language=1036
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdf.jpg, RT_RCDATA, HIGH
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdfmedium.jpg, RT_RCDATA, MEDIUM
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdflow.jpg, RT_RCDATA, LOW
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdf.jpg, RT_RCDATA, HIGH
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdfmedium.jpg, RT_RCDATA, MEDIUM
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdflow.jpg, RT_RCDATA, LOW
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=ICO\pdf.ico
#AutoIt3Wrapper_Outfile=DropPDF.exe
#AutoIt3Wrapper_UseUpx=y
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Description=DropPDF
#AutoIt3Wrapper_Res_Fileversion=1.0.0
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdf.jpg, RT_RCDATA, HIGH
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdfmedium.jpg, RT_RCDATA, MEDIUM
#AutoIt3Wrapper_Res_File_Add=.\Resources\pdflow.jpg, RT_RCDATA, LOW
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------
 AutoIt Version : 3.3.14.5
 Auteur:         Yann83
 Github:        https://github.com/yann83
 Description du programme :
	< Outil de rangement automatique des fichiers>
#ce ----------------------------------------------------------------------------
#NoTrayIcon
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <SendMessage.au3>
#include <File.au3>
#include <Constants.au3>
#include <String.au3>
#include <WinAPIRes.au3>
#include <WinAPIInternals.au3>
#include <WinAPIEx.au3>
#include <Array.au3>


Global $sFichierINI = @ScriptDir & "\" & StringTrimRight(@ScriptName,4) & ".ini"
Global $sFichierLog = @ScriptDir & "\" & StringTrimRight(@ScriptName,4) & ".log"
Global $sGhostscript = @ScriptDir & "\bin\gswin64c.exe"

Global Const $SC_DRAGMOVE1 = 0xF012
Global $sFichierImageHigh = @ScriptDir & "\pdf.jpg"
Global $sFichierImageMedium = @ScriptDir & "\pdfmedium.jpg"
Global $sFichierImageLow = @ScriptDir & "\pdflow.jpg"
Global $hRet,$Ret

Global $Width = @DesktopWidth
Global $Heigh = @DesktopHeight

;genere un nom de dossier temporaire
Global $sTempFolder = _TempFile(@TempDir, "~", "")
DirCreate($sTempFolder)

If Not FileExists($sFichierINI) Then
    _FileCreate($sFichierINI)
    IniWrite($sFichierINI,"Menu","path",$sTempFolder)
EndIf

Global $DirOutput = IniRead($sFichierINI,"Menu","path",$sTempFolder)

If @Compiled Then
	$hRet = _FileInstallFromResource("HIGH",$sFichierImageHigh)
	If @error Then _FileWriteLog($sFichierLog,"_FileInstallFromResource error : " & @error)
	$hRet = _FileInstallFromResource("MEDIUM",$sFichierImageMedium)
	If @error Then _FileWriteLog($sFichierLog,"_FileInstallFromResource error : " & @error)
	$hRet = _FileInstallFromResource("LOW",$sFichierImageLow)
	If @error Then _FileWriteLog($sFichierLog,"_FileInstallFromResource error : " & @error)
Else
    $sFichierImageHigh = @ScriptDir & "\Resources\pdf.jpg"
    $sFichierImageMedium = @ScriptDir & "\Resources\pdfmedium.jpg"
    $sFichierImageLow = @ScriptDir & "\Resources\pdflow.jpg"
EndIf

#Region ### START Koda GUI section ### Form=
Global $hDragDropGui = GUICreate("WM_DROPFILES", 100, 100,$Width-150, $Heigh-150, $WS_POPUP, $WS_EX_ACCEPTFILES)
Global $hDragDropPic = GUICtrlCreatePic($sFichierImageHigh,0, 0, 100, 100)


GUICtrlSetState($hDragDropPic, $GUI_DROPACCEPTED)
GUICtrlSetBkColor($hDragDropPic, 0x0A000)
GUICtrlSetColor($hDragDropPic, 0)

Global $hContextMenu = GuiCtrlCreateContextMenu($hDragDropPic)
Global $hContextMenuHigh = GuiCtrlCreateMenuItem("Bonne qualité", $hContextMenu)
Global $hContextMenuMedium = GuiCtrlCreateMenuItem("Moyenne qualité", $hContextMenu)
Global $hContextMenuLow = GuiCtrlCreateMenuItem("Basse qualité", $hContextMenu)
Global $hContextMenuDir = GuiCtrlCreateMenuItem("Voir dossier de sortie", $hContextMenu)
Global $hContextMenuExit = GuiCtrlCreateMenuItem("Exit", $hContextMenu)

Global $Quality = "printer"
Global $Ext = ""
Global $filename = ""

Global $__aGUIDropFiles = 0

GUISetState(@SW_SHOW)

GUIRegisterMsg($WM_DROPFILES, 'WM_DROPFILES')
#EndRegion ### END Koda GUI section ###

_SetWindowPos($hDragDropGui, $HWND_TOPMOST + $HWND_TOP, 0, 0, 0, 0, BitOR($SWP_NOMOVE,$SWP_NOSIZE))

While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_PRIMARYDOWN ;on bouge l'icône avec la souris
            _SendMessage($hDragDropGui, $WM_SYSCOMMAND, $SC_DRAGMOVE1, 0)

        Case $GUI_EVENT_CLOSE
            If @Compiled = 1 Then
                FileDelete($sFichierImageHigh)
                FileDelete($sFichierImageMedium)
                FileDelete($sFichierImageLow)
            EndIf
            Exit

		Case $hContextMenuExit
            If @Compiled = 1 Then
                FileDelete($sFichierImageHigh)
                FileDelete($sFichierImageMedium)
                FileDelete($sFichierImageLow)
            EndIf
            Exit

        Case $GUI_EVENT_DROPPED
            _FileWriteLog($sFichierLog,">>>> Evenement Drop detecté")
             _FileWriteLog($sFichierLog,"Reception de "&$__aGUIDropFiles[0]&" fichiers ci-dessous")
             _FileWriteLog($sFichierLog,">>>> Début du traitement")
             ProgressOn("Compression", "Compression en cours", "0%", -1, -1, 17)
            For $i = 1 To $__aGUIDropFiles[0]
                 _FileWriteLog($sFichierLog,"Traitement du fichier "&$__aGUIDropFiles[$i])
                 $filename = _GetNameExt($__aGUIDropFiles[$i])
                 ProgressSet(_Progress($i,$__aGUIDropFiles[0]), _Progress($i,$__aGUIDropFiles[0]) & "%", $filename)
                 Sleep(1000)
                $Ext = _GetExt($__aGUIDropFiles[$i])
                If StringLower($Ext) = "pdf" Then
                    $ret= _pdfCompress($Quality,$__aGUIDropFiles[$i],$DirOutput&"\"&$filename)
                    If $ret = 1 Then
                        _FileWriteLog($sFichierLog,"Le fichier "&$filename&" a été compressé vers "&$DirOutput)
                    Else
                         _FileWriteLog($sFichierLog,"ERREUR La compression a échoué pour le fichier "&$filename)
                    EndIf
                Else
                    _FileWriteLog($sFichierLog,"Le fichier "&$__aGUIDropFiles[$i]&" n'est pas un pdf")
                EndIf
            Next
            _FileWriteLog($sFichierLog,">>>> Fin du traitement")
            ProgressSet(100, "Fait", "Terminé")
            Sleep(1000)
            ProgressOff()

        Case $hContextMenuHigh
            $Quality = "printer"
            GUICtrlSetImage($hDragDropPic,$sFichierImageHigh)
            _FileWriteLog($sFichierLog,"Qualité réglé sur Haute")

        Case $hContextMenuMedium
            $Quality = "ebook"
            GUICtrlSetImage($hDragDropPic,$sFichierImageMedium)
            _FileWriteLog($sFichierLog,"Qualité réglé sur Moyenne")

        Case $hContextMenuLow
            $Quality = "screen"
            GUICtrlSetImage($hDragDropPic,$sFichierImageLow)
            _FileWriteLog($sFichierLog,"Qualité réglé sur Basse")

        Case $hContextMenuDir
            ShellExecute($DirOutput)
    EndSwitch
WEnd

Func _Progress($fValue,$fMax)
    Local $fCalcul = (($fValue * 100) / $fMax)
    ConsoleWrite($fCalcul&@CRLF)
    Return(Round($fCalcul))
EndFunc

Func _pdfCompress($fQuality,$fSource,$fOutput)
 #cs
 gswin64c.exe -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH -sOutputFile="D:\DOCUMENTATIONS\Assurance maladie\output.pdf" "D:\DOCUMENTATIONS\Assurance maladie\kit_de_repliques.pdf"
 #ce
 Local $fparameters = '-sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/'&$fQuality&' -dNOPAUSE -dQUIET -dBATCH -sOutputFile="'&$fOutput&'" "'&$fSource&'"'
 _FileWriteLog($sFichierLog,$sGhostscript&" "&$fparameters)
Local $fret = RunWait($sGhostscript&" "&$fparameters,"",@SW_HIDE)
If @error Then Return(0)
Return(1)
EndFunc

Func _GetfileName($f_sSource)
    Local $f_sFileName = StringRegExpReplace($f_sSource, "^.*\\", "")
    Return $f_sFileName
EndFunc

Func _GetPath($f_sSource)
    Local $f_sPath = StringRegExpReplace($f_sSource, "(^.*\\)(.*)", "\1")
    Return $f_sPath
EndFunc

Func _GetExt($f_sSource)
    Local $f_sPath = StringRegExpReplace($f_sSource, "^.*\.", "")
    Return $f_sPath
EndFunc

Func _GetNameExt($f_sSource)
    Local $f_sPath = StringRegExpReplace($f_sSource, "^.*\\", "")
    Return $f_sPath
EndFunc

Func _Rename($aArrayRename,$aArrayRegex)
    Local $nGroup
    Local $sRename = ""
    If  $aArrayRename[0][0] <= UBound($aArrayRegex) Then
        For $i = 1 To $aArrayRename[0][0]
            $nGroup = Number($aArrayRename[$i][0])
            If $aArrayRename[$i][1] <>"" Then
                $sRename &= $aArrayRename[$i][1]
            Else
                $sRename &= $aArrayRegex[$nGroup]
            EndIf
        Next
    Else
        Return SetError(1,0,"Il n'y a pas assez de groupes")
    EndIf
    Return($sRename)
EndFunc

Func _StringExplodeRegex($sString)
    Local $atableau[1][2]
    Local $aDelim = StringRegExp($sString, "\((\d)\)", 3)
    If IsArray($aDelim) Then
        Local $aParts = StringSplit(StringRegExpReplace($sString, "(\(\d\))", "#"), "#", 3)
        _ArrayDelete($aParts,0)
        Local $NbRows = UBound($aDelim)
        ReDim $atableau[$NbRows][2]
        For $i = 0 To $NbRows - 1
                $atableau[$i][0] = $aDelim[$i]
                $atableau[$i][1] = $aParts[$i]
        Next
        _ArrayInsert($atableau,0,$NbRows)
        Return($atableau)
    Else
        Return SetError(1,0,"Pattern introuvable")
    EndIf
EndFunc

Func _SearchDuplicateValue($sConfigFile)
    Local $LectureSectionIni = IniReadSectionNames($sConfigFile)
    Local $aTableauOrg,$aTableauUnique
    For $i = 1 To $LectureSectionIni[0]
        $aTableauOrg = IniReadSection($sConfigFile,$LectureSectionIni[$i])
        If Not IsArray($aTableauOrg) Then SetError(2,0,"La section "&$LectureSectionIni[$i]&" n'est pas remplie")
        $aTableauUnique = _ArrayUnique($aTableauOrg,0,1)
        If Number($aTableauOrg[0][0]) > Number($aTableauUnique[0]) Then Return SetError(2,0,$LectureSectionIni[$i])
    Next
    SetError(0)
    Return(1)
EndFunc

;################### pour integration fichiers dans tableau #################
Func WM_DROPFILES($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $lParam
    Switch $iMsg
        Case $WM_DROPFILES
            Local Const $aReturn = _WinAPI_DragQueryFileEx($wParam)
            If UBound($aReturn) Then
                $__aGUIDropFiles = $aReturn
            Else
                Local Const $aError[1] = [0]
                $__aGUIDropFiles = $aError
            EndIf
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_DROPFILES

;################### pour mise au premier plan #################
Func _SetWindowPos($hwnd, $InsertHwnd, $X, $Y, $cX, $cY, $uFlags)
    $ret = DllCall("user32.dll", "long", "SetWindowPos", "hwnd", $hwnd, "hwnd", $InsertHwnd, _
    "int", $X, "int", $Y, "int", $cX, "int", $cY, "long", $uFlags)
EndFunc

;#################### pour file install ############################
Func _FileInstallFromResource($sResName, $sDest, $isCompressed = False, $iUncompressedSize = Default)
    Local $bBytes = _GetResourceAsBytes($sResName, $isCompressed, $iUncompressedSize)
    If @error Then Return SetError(@error, 0, 0)
    FileDelete($sDest)
    FileWrite($sDest, $bBytes)
EndFunc

Func _GetResourceAsBytes($sResName, $isCompressed = False, $iUncompressedSize = Default)

    Local $hMod = _WinAPI_GetModuleHandle(Null)
    Local $hRes = _WinAPI_FindResource($hMod, 10, $sResName)
    If @error Or Not $hRes Then Return SetError(1, 0, 0)
    Local $dSize = _WinAPI_SizeOfResource($hMod, $hRes)
    If @error Or Not $dSize Then Return SetError(2, 0, 0)
    Local $hLoad = _WinAPI_LoadResource($hMod, $hRes)
    If @error Or Not $hLoad Then Return SetError(3, 0, 0)
    Local $pData = _WinAPI_LockResource($hLoad)
    If @error Or Not $pData Then Return SetError(4, 0, 0)
    Local $tBuffer = DllStructCreate("byte[" & $dSize & "]")
    _WinAPI_MoveMemory(DllStructGetPtr($tBuffer), $pData, $dSize)
    If $isCompressed Then
        Local $oBuffer
       _WinAPI_LZNTDecompress($tBuffer, $oBuffer, $iUncompressedSize)
        If @error Then Return SetError(5, 0, 0)
        $tBuffer = $oBuffer
    EndIf
    Return DllStructGetData($tBuffer, 1)
EndFunc

Func _WinAPI_LZNTDecompress(ByRef $tInput, ByRef $tOutput, $iUncompressedSize = Default)
    ; if no uncompressed size given, use 16x the input buffer
    If $iUncompressedSize = Default Then $iUncompressedSize = 16 * DllStructGetSize($tInput)
    Local $tBuffer, $ret
    $tOutput = 0
    $tBuffer = DllStructCreate("byte[" & $iUncompressedSize & "]")
    If @error Then Return SetError(1, 0, 0)
    $ret = DllCall("ntdll.dll", "long", "RtlDecompressBuffer", "ushort", 2, "struct*", $tBuffer, "ulong", $iUncompressedSize, "struct*", $tInput, "ulong", DllStructGetSize($tInput), "ulong*", 0)
    If @error Then Return SetError(2, 0, 0)
    If $ret[0] Then Return SetError(3, $ret[0], 0)
    $tOutput = DllStructCreate("byte[" & $ret[6] & "]")
    If Not _WinAPI_MoveMemory(DllStructGetPtr($tOutput), DllStructGetPtr($tBuffer), $ret[6]) Then
        $tOutput = 0
        Return SetError(4, 0, 0)
    EndIf
    Return $ret[6]
EndFunc


#cs
; Drive letter -                                     Example returns     "C"
Local $sDrive = StringRegExpReplace($sFile, ":.*$", "")

; Full Path with backslash -                         Example returns     "C:\Program Files\Another Dir\AutoIt3\"
Local $sPath = StringRegExpReplace($sFile, "(^.*\\)(.*)", "\1")

; Full Path without backslash -                     Example returns     "C:\Program Files\Another Dir\AutoIt3"
Local $sPathExDr = StringRegExpReplace($sFile, "(^.:)(\\.*\\)(.*$)", "\2")

; Full Path w/0 backslashes, nor drive letter -     Example returns     "\Program Files\Another Dir\AutoIt3\"
Local $sPathExDrBSs = StringRegExpReplace($sFile, "(^.:\\)(.*)(\\.*$)", "\2")

; Path w/o backslash, not drive letter: -             Example returns     "Program Files\Another Dir\AutoIt3"
Local $sPathExBS = StringRegExpReplace($sFile, "(^.*)\\(.*)", "\1")

; File name with ext -                                 Example returns     "AutoIt3.chm"
Local $sFilName = StringRegExpReplace($sFile, "^.*\\", "")

; File name w/0 ext -                                 Example returns     "AutoIt3"
Local $sFilenameExExt = StringRegExpReplace($sFile, "^.*\\|\..*$", "")

; Dot Extenstion -                                     Example returns     ".chm"
Local $sDotExt = StringRegExpReplace($sFile, "^.*\.", ".$1")

; Extenstion -                                         Example returns     "chm"
Local $sExt = StringRegExpReplace($sFile, "^.*\.", "")

MsgBox(0, "Path File Name Parts", _
        "Drive             " & @TAB & $sDrive & @CRLF & _
        "Path              " & @TAB & $sPath & @CRLF & _
        "Path w/o backslash" & @TAB & $sPathExBS & @CRLF & _
        "Path w/o Drv:     " & @TAB & $sPathExDr & @CRLF & _
        "Path w/o Drv or \'s" & @TAB & $sPathExDrBSs & @CRLF & _
        "File Name         " & @TAB & $sFilName & @CRLF & _
        "File Name w/o Ext " & @TAB & $sFilenameExExt & @CRLF & _
        "Dot Extension     " & @TAB & $sDotExt & @CRLF & _
        "Extension         " & @TAB & $sExt & @CRLF)
#ce
