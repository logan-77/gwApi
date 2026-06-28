#cs

#ce

#include-once
#include "_gwApi.au3"

#Region Constants

#EndRegion Constants

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $BotRunning = False
Global $BotInitialized = False
Global $hWnd = 0, $gPID = 0
#EndRegion Declarations

#Region GUI
$hGui = GUICreate("Testing", 300, 610, -1, -1)
$cbx_char_select = GUICtrlCreateCombo("", 5, 5, 105, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
    GUICtrlSetData(-1, Scanner_GetLoggedCharNames())

$lbl_status = GUICtrlCreateEdit("", 115, 5, 180, 600, 2097220)
$cbx_ontop = GUICtrlCreateCheckbox("Always On Top", 5, 130, 105, 17)
    GUICtrlSetOnEvent($cbx_ontop, "ToggleOnTop")
    GUICtrlSetState($cbx_ontop, $GUI_CHECKED)
$btn_start = GUICtrlCreateButton("Start", 5, 150, 105, 40)
    GUICtrlSetOnEvent($btn_start, "GuiButtonHandler")
$TestButton = GUICtrlCreateButton("Test1", 5, 200, 105, 40)
    GUICtrlSetOnEvent(-1, "Test1")
$TestButton2 = GUICtrlCreateButton("Test2", 5, 250, 105, 40)
    GUICtrlSetOnEvent(-1, "Test2")
GUISetOnEvent($GUI_EVENT_CLOSE, "_exit")
GUISetState(@SW_SHOW)
#EndRegion GUI

#Region ButtonHandling
Func GuiButtonHandler()
    If $BotRunning Then
        Out("Will pause after this run.")
        $BotRunning = False
    ElseIf $BotInitialized Then
        ; put test code here
        Local $lItemPtr = GetItemPtrBySlot(1,1)
        Out("IntAction: " & "0x" & Hex(Item_GetItemInfoByPtr($lItemPtr, "Interaction"), 8))
        Out("IsSalv: " & GetIsSalvageable($lItemPtr))
        Out("**************************")
    Else
        StartBot()
    EndIf
EndFunc

Func Test1()
    Return
EndFunc

Func Test2()
    Return
EndFunc
#EndRegion ButtonHandling

#Region Loops
ToggleOnTop()

While Not $BotRunning
    Sleep(500)
WEnd

While True
    If Not $BotRunning Then
        Out("Bot is paused.")
        While Not $BotRunning
            Sleep(500)
        WEnd
    EndIf
    Sleep(500)
WEnd

Func ToggleOnTop()
    If GUICtrlRead($cbx_ontop) = $GUI_CHECKED Then
        WinSetOnTop($hGui, "", $WINDOWS_ONTOP)
    Else
        WinSetOnTop($hGui, "", $WINDOWS_NOONTOP)
    EndIf
EndFunc ;==>ToggleOnTop

Func CanPickUpEx($aItem)
    Return
EndFunc

Func StartBot()
    Out("Initializing...")
    Local $CharName = GUICtrlRead($cbx_char_select)
    If $CharName == "" Then
        If Core_Initialize(ProcessExists("gw.exe"), True) = 0 Then
            MsgBox(0, "Error", "Guild Wars is not running.")
            _exit()
        EndIf
    Else
        If Core_Initialize($CharName, True) = 0 Then
            MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
            _exit()
        EndIf
    EndIf
    $hWnd = Scanner_GetWindowHandle()
    $CharName = Player_GetCharname()
    GUICtrlSetData($cbx_char_select, $CharName, $CharName)
    GUICtrlSetState($cbx_char_select, $GUI_DISABLE)
    GUICtrlSetData($btn_start, "Testing")
    WinSetTitle($hGui, "", "Testing - " & $CharName)
    ; $BotRunning = True
    $BotInitialized = True
    Out("Init complete.")
EndFunc

Func Out($msg)
    GUICtrlSetData($lbl_status, GUICtrlRead($lbl_status) & "[" & @HOUR & ":" & @MIN & "]" & " " & $msg & @CRLF)
    _GUICtrlEdit_Scroll($lbl_status, $SB_SCROLLCARET)
    _GUICtrlEdit_Scroll($lbl_status, $SB_LINEUP)
 EndFunc

Func _exit()
    Exit
EndFunc
#EndRegion Functions