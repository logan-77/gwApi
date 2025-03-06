#include-once
#Region Travel
;~ Description: /resign and wait for wipe(atm only for solo+heros), then ReturnToOutpost
; prototype from somehwere, can be improved upon (e.g. GetIsPartyDefeated)
Func ResignAndReturn($aMapID = 0, $aLanguage = GetCharacterInfo("Language"), $aRegion = GetCharacterInfo("Region"))
	Resign()
	Pingsleep(5000)
	If $aMapID = 0 Then
		ReturnToOutpost()
		WaitMapLoading()
	Else
		TravelTo($aMapID, $aLanguage, $aRegion)
	EndIf
EndFunc   ;==>ResignAndReturn
#EndRegion Travel

#Region MapInfo
; Returns the time spent on a map
Func GetInstanceTimestamp()
	Local $lOffset[4] = [0, 0x18, 0x8, 0x1AC]
	Local $lTimer = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lTimer[0]
EndFunc   ;==>GetInstanceTimestamp

;~ Description: Tests if an area has been vanquished.
Func GetAreaVanquished()
	Return GetWorldInfo("FoesToKill") = 0
EndFunc   ;==>GetAreaVanquished
#EndRegion MapInfo