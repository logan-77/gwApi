#cs

#ce

#include-once
#include "_gwApi.au3"

#Region Constants

#EndRegion Constants

#Region Declarations
Opt("GUIOnEventMode", True)
Opt("GUICloseOnESC", False)
Global $Runs = 0
Global $Fails = 0
Global $Drops = 0
Global $BotRunning = False
Global $BotInitialized = False
Global $TotalSeconds = 0 ; Bot Run Time
Global $tRunTimer ; used to calculate Run Avg
Global $TimeTotal = 0 ; used to calculate Run Avg
Global $TimeRunAverage = 0 ; used to calculate Run Avg
Global $HWND
Global $gPID = 0
Global $free_storage_slots = 100
#EndRegion Declarations

#Region GUI
$hGui = GUICreate("Feather Farmer", 300, 610, -1, -1)
$cbx_char_select = GUICtrlCreateCombo("", 5, 5, 105, 25, BitOR($CBS_DROPDOWN, $CBS_AUTOHSCROLL))
	GUICtrlSetData(-1, GetLoggedCharNames())
$RunsLabel = GUICtrlCreateLabel("Runs:", 5, 30, 31, 17)
$lbl_run_count = GUICtrlCreateLabel("0", 34, 30, 75, 17, $SS_RIGHT)
$FailsLabel = GUICtrlCreateLabel("Fails:", 5, 50, 31, 17)
$lbl_fail_count = GUICtrlCreateLabel("0", 30, 50, 79, 17, $SS_RIGHT)
$DropsLabel = GUICtrlCreateLabel("Feathers:", 5, 70, 76, 17)
$DropsCount = GUICtrlCreateLabel("0", 82, 70, 27, 17, $SS_RIGHT)
$AvgTimeLabel = GUICtrlCreateLabel("Average time:", 5, 90, 65, 17)
$lbl_avg_time = GUICtrlCreateLabel("-", 70, 90, 40, 17, $SS_RIGHT)
$TotTimeLabel = GUICtrlCreateLabel("Total time:", 5, 110, 50, 17)
$lbl_total_time = GUICtrlCreateLabel("-", 55, 110, 55, 17, $SS_RIGHT)
$lbl_status = GUICtrlCreateEdit("", 115, 5, 180, 600, 2097220)
$cbx_rendering = GUICtrlCreateCheckbox("Disable Rendering", 5, 130, 105, 17)
	;~ GUICtrlSetOnEvent(-1, "ToggleRendering")
	GUICtrlSetState($cbx_rendering, $GUI_DISABLE)
$btn_start = GUICtrlCreateButton("Start", 5, 150, 105, 40)
	GUICtrlSetOnEvent(-1, "GuiButtonHandler")
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
		;~ Buying at Trader
		;~ TraderRequestRune(899)
		;~ TraderRequestSell(GetItemPtrBySlot(1,1))
		;~ Sleep(1000)
		;~ ;~ TraderBuy()
		;~ TraderSell()
		;~ Sleep(1000)
		;~ ;~ Local $lItem = GetItemPtrBySlot(1,1)
		;~ ;~ Out("ExtraID: " & GetItemExtraID($lItem))
		Out("GetInstanceInfo: " & GetInstanceInfo("Type"))
		Out("PtrMemRead: " & Hex($mInstanceInfo + 0x04, 8))
		Out("MemReadInstance: " & MemoryRead($mInstanceInfo + 0x04))
		Out("**************************")
	Else
		Out("Initializing...")
		Local $CharName = GUICtrlRead($cbx_char_select)
		If $CharName == "" Then
			If Initialize(ProcessExists("gw.exe"), True, True) == False Then
				MsgBox(0, "Error", "Guild Wars is not running.")
				Exit
			EndIf
		Else
			If Initialize($CharName, True, True) == False Then
				MsgBox(0, "Error", "Could not find a Guild Wars client with a character named '" & $CharName & "'")
				Exit
			EndIf
		EndIf
		$HWND = $mGWWindowHandle
		GUICtrlSetState($cbx_rendering, $GUI_ENABLE)
		$CharName = GetCharname()
		GUICtrlSetData($cbx_char_select, $CharName, $CharName)
		GUICtrlSetState($cbx_char_select, $GUI_DISABLE)
		GUICtrlSetData($btn_start, "Testing")
		WinSetTitle($hGui, "", "Feather Farmer - " & $CharName)
		; $BotRunning = True
		$BotInitialized = True
		SetMaxMemory()
	EndIf
EndFunc

Func Test1()
	Sleep(100)
EndFunc

Func Test2()
	Sleep(100)
EndFunc
#EndRegion ButtonHandling

#Region Loops
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
WEnd

Func CanPickUpEx($aItem)
	Return 0
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