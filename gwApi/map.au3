#include-once
#Region Instance
;~ Description: Returns current load-state.
Func GetInstanceType()
    Return Memory_Read($g_p_InstanceInfo + 0x4, "dword")
EndFunc   ;==>GetInstanceType

Func GetIsOutpost()
    Return Memory_Read($g_p_InstanceInfo + 0x4, "dword") = 0
EndFunc

Func GetIsExplorable()
    Return Memory_Read($g_p_InstanceInfo + 0x4, "dword") = 1
EndFunc

Func GetIsLoading()
    Return Memory_Read($g_p_InstanceInfo + 0x4, "dword") = 2
EndFunc
#EndRegion Instance


#Region Travel
;~ Customized Wrapper (added extra sleep)
Func WaitMapLoading($aMapID = -1, $aInstanceType = -1, $aTimeout = 15000)
    If Map_WaitMapLoading($aMapID, $aInstanceType, $aTimeout) = False Then Return False
    Other_RndSleep(3000)
    Return True
EndFunc ;==>WaitMapLoading

;~ Customized Wrapper (added extra sleep)
Func WaitMapIsLoaded($aTimeout = 30000)
    If Map_WaitMapIsLoaded($aTimeout) = False Then Return False
    Other_RndSleep(1000)
    Return True
EndFunc ;==>WaitMapIsLoaded

;~ Customized Wrapper (added extra sleep)
Func TravelTo($aMapID, $aLanguage = Map_GetCharacterInfo("Language"), $aRegion = Map_GetCharacterInfo("Region"), $aDistrict = 0, $aWaitToLoad = True)
    Map_TravelTo($aMapID, $aLanguage, $aRegion, $aDistrict, $aWaitToLoad)
    Other_RndSleep(1000)
EndFunc ;==>TravelTo

;~ $iTargetDistrict: according to the Enum in constants.au3
Func RndTravel($iMapID, $iTargetDistrict = $dis_europe, $bWaitToLoad = True)
    If Map_GetNormalizedMapID() = $iMapID And IsInTargetDistrict($iTargetDistrict) Then Return 1
        
    If $iTargetDistrict < $dis_english Or $iTargetDistrict >= $dis_enum_size Then $iTargetDistrict = $dis_all
    
    Local $iIdx

    ; ============================
    ; CASE 1: Exact district (0–11)
    ; ============================
    If $iTargetDistrict >= $dis_english And $iTargetDistrict <= $dis_japan Then
        $iIdx = $iTargetDistrict
    Else
        ; ============================
        ; CASE 2: Range-based districts
        ; ============================
        Local $iMin, $iMax

        Switch $iTargetDistrict
            Case $dis_europe
                $iMin = $dis_english
                $iMax = $dis_russian
            Case $dis_europe_no_english
                $iMin = $dis_french
                $iMax = $dis_russian
            Case $dis_int_american
                $iMin = $dis_american
                $iMax = $dis_international
            Case $dis_asia
                $iMin = $dis_korea
                $iMax = $dis_japan
            Case Else
                $iMin = $dis_english
                $iMax = $dis_japan
        EndSwitch

        $iIdx = Random($iMin, $iMax, 1)
    EndIf    

    Map_InitMapIsLoaded()
    Map_MoveMap($iMapID, $g_aRegion[$iIdx], 0, $g_aLanguage[$iIdx])
    If $bWaitToLoad Then Return WaitMapIsLoaded()
EndFunc ;==>RndTravel

;~ Description: /resign+wait for wipe+return to outpost+wait for mapload
Func ResignAndReturn()
    Resign()
    Local $lDeadlock = TimerInit()
    Do
        Sleep(100)
    Until GetPartyDefeated() or (TimerDiff($lDeadlock) > 5000)
    Other_PingSleep(1000)

    Map_ReturnToOutpost()
    Other_RndSleep(1000)
EndFunc   ;==>ResignAndReturn
#EndRegion Travel

;~ Param: According to the Enum in constants.au3
Func SetAnchorDistrict($iTargetDistrict)
    If IsInTargetDistrict($iTargetDistrict) Then Return 1

    Out("Traveling to GtoB.")
    RndTravel($map_id_great_temple_of_balthazar, $iTargetDistrict)
    Other_RndSleep(2000)

    Out("Going to Charselect.")
    ControlSend(Scanner_GetWindowHandle(), "", "", "{F12}")
    Sleep(2000)
    ControlSend(Scanner_GetWindowHandle(), "", "", "{c}")
 
    Local $hDeadlock = TimerInit(), $iTimeLimit = 2000
    Do
        Sleep(250)
    Until TimerDiff($hDeadlock) > 2500 Or Core_IsCharacterSelection()
    If TimerDiff($hDeadlock) > $iTimeLimit Then Out("Charselect timeout.")
    Sleep(2000)

    Out("Returning to the Game.")
    ControlSend(Scanner_GetWindowHandle(), "", "", "{ENTER}")

    $hDeadlock = TimerInit()
    $iTimeLimit = 15000
    Do
        Sleep(500)
        If TimerDiff($hDeadlock) > $iTimeLimit Then Return 0
    Until Core_IsIngame()
    Sleep(2000)
    Return 1
EndFunc ;==>SetAnchorDistrict

;~ Returns True if you are already in Target District
;~ Param: Index According to the constants $g_aRegion and $g_aLanguage,
;~        and the corresponding Enum
Func IsInTargetDistrict($iTargetDistrict = $dis_europe)
    If $iTargetDistrict < 0 Or $iTargetDistrict >= $dis_enum_size Then $iTargetDistrict = $dis_all
    If $iTargetDistrict = $dis_all Then Return True
    
    Local $bExplorable = Map_GetInstanceInfo("IsExplorable")
    If $bExplorable Then Return False
    
    Local $bInGH = Map_GetAreaInfo(Map_GetMapID(), "IsGuildHall")
    If $bInGH Then Return False
    
    Local $iCurrentRegion   = Map_GetCharacterInfo("Region")
    Local $iCurrentLanguage = Map_GetCharacterInfo("Language")

    ; ============================
    ; CASE 1: Exact district (0–11)
    ; ============================
    If $iTargetDistrict <= $dis_japan Then
        Local $iTargetRegion = $g_aRegion[$iTargetDistrict]
        Local $iTargetLanguage = $g_aLanguage[$iTargetDistrict]
        Return (($iTargetRegion = $iCurrentRegion) And ($iTargetLanguage = $iCurrentLanguage))
    EndIf

    ; ============================
    ; CASE 2: Range-based districts
    ; ============================
    Switch $iTargetDistrict
        Case $dis_europe
            Return ($iCurrentRegion = $GC_REGION_EUROPE)
        Case $dis_europe_no_english
            Return ($iCurrentRegion = $GC_REGION_EUROPE _
                And $iCurrentLanguage <> $GC_LANGUAGE_ENGLISH)
        Case $dis_int_american
            Return ($iCurrentRegion = $GC_REGION_INTERNATIONAL _
                Or $iCurrentRegion = $GC_REGION_AMERICA)
        Case $dis_asia
            Return ($iCurrentRegion = $GC_REGION_KOREA _
                Or $iCurrentRegion = $GC_REGION_CHINA _
                Or $iCurrentRegion = $GC_REGION_JAPAN)
    EndSwitch
    Return False
EndFunc ;==>IsInTargetDistrict