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

#Region MapInfo
; Returns the time spent on a map
Func GetInstanceTimestamp()
	Local $lOffset[4] = [0, 0x18, 0x8, 0x1AC]
	Local $lTimer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
	Return $lTimer[0]
EndFunc   ;==>GetInstanceTimestamp

;~ Description: Tests if an area has been vanquished.
Func GetAreaVanquished()
	Return World_GetWorldInfo("FoesToKill") = 0
EndFunc   ;==>GetAreaVanquished
#EndRegion MapInfo