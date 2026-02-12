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

Func RndTravel($iMapID, $iMode = 4, $bWaitToLoad = True)
    Local Const $aRegions[]       =	[2, 2, 2, 2, 2, 2, 2, 0, -2, 1, 3, 4]
    Local Const $aLanguages[]     =	[0, 2, 3, 4, 5, 9, 10, 0, 0, 0, 0, 0]
    Local Const $aModeRanges[][2] = [ _
                                        [0, 11],  _ ; 0 = all
                                        [0, 6],  _ ; 1 = EU-only
                                        [7, 8],  _ ; 2 = US-only
                                        [9, 11], _ ; 3 = Asia-only
                                        [1, 6]    _ ; 4 = EU-only, no english
                                    ]

    If $iMode < 0 Or $iMode >= UBound($aModeRanges) Then
        $iMode = 4 ; fallback mode
    EndIf

    Local $iDistrictMin = $aModeRanges[$iMode][0]
    Local $iDistrictMax = $aModeRanges[$iMode][1]

    Local $iCurrentMap      = Map_GetCharacterInfo("MapID")
    Local $iCurrentRegion   = Map_GetCharacterInfo("Region")
    Local $iCurrentLanguage = Map_GetCharacterInfo("Language")
    Local $bExplorable      = Map_GetInstanceInfo("IsExplorable")

    Local $iIdx = Random($iDistrictMin, $iDistrictMax, 1)

    ;~ skip travel if:
    ;~  - already in same map
    ;~  - NOT explorable
    ;~  - same region + language
    If  $iCurrentMap = $iMapID _
        And Not $bExplorable _
        And $aRegions[$iIdx] = $iCurrentRegion _
        And $aLanguages[$iIdx] = $iCurrentLanguage Then
            Return True
    EndIf

    Map_InitMapIsLoaded()
    Map_MoveMap($iMapID, $aRegions[$iIdx], 0, $aLanguages[$iIdx])
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

Func SetAnchorDistrict()
    ;~ skip if NOT in GH
	If Not Map_GetAreaInfo(Map_GetMapID(), "IsGuildHall") Then Return 1

    Out("Traveling to GtoB.")
    RndTravel($map_id_great_temple_of_balthazar)
    Other_RndSleep(2000)

    Out("Going to Charselect.")
    ControlSend(Scanner_GetWindowHandle(), "", "", "{F12}")
	Sleep(2000)
	ControlSend(Scanner_GetWindowHandle(), "", "", "{c}")
	
    Local $hDeadlock = TimerInit(), $iTimeLimit = 2500
    Do
        Sleep(250)
    Until TimerDiff($hDeadlock) > 2500 Or Core_IsCharacterSelection()
    If TimerDiff($hDeadlock) > $iTimeLimit Then Out("Charselect timeout.")
    Sleep(2500)

    Out("Returning to the Game.")
    ControlSend(Scanner_GetWindowHandle(), "", "", "{ENTER}")

    $hDeadlock = TimerInit()
    $iTimeLimit = 15000
    Do
        Sleep(500)
        If TimerDiff($hDeadlock) > $iTimeLimit Then Return 0
    Until Core_IsIngame()
    Sleep(2500)
    Return 1
EndFunc ;==>SetAnchorDistrict