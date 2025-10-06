#include-once

;~ ;~ Description: Disable a skill on a hero's skill bar.
;~ Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot)
;~ 	If Not GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
;~ EndFunc   ;==>DisableHeroSkillSlot

;~ ;~ Description: Enable a skill on a hero's skill bar.
;~ Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot)
;~ 	If GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
;~ EndFunc   ;==>EnableHeroSkillSlot

;~ ;~ Description: Tests if a hero's skill slot is disabled.
;~ Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot)
;~ 	Return BitAND(2 ^ ($aSkillSlot - 1), DllStructGetData(GetSkillbar($aHeroNumber), 'Disabled')) > 0
;~ EndFunc   ;==>GetIsHeroSkillSlotDisabled

#Region HeroInfo
;~ Description: Returns number of heroes you control.
Func GetHeroCount()
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
	Local $lHeroCount = Memory_ReadPtr($g_p_BasePointer, $lOffset)
	Return $lHeroCount[1]
EndFunc   ;==>GetHeroCount

;~ Description: Returns agent ID of a hero.
Func GetHeroID($aHeroNumber)
	If $aHeroNumber = 0 Then Return GetMyID()
	Local $lOffset[6] = [0, 0x18, 0x4C, 0x54, 0x24, 0]
	$lOffset[5] = 0x18 * ($aHeroNumber - 1)
	Local $lAgentID = Memory_ReadPtr($g_p_BasePointer, $lOffset)
	Return $lAgentID[1]
EndFunc   ;==>GetHeroID

;~ Description: Returns hero number by agent ID.
Func GetHeroNumberByAgentID($aAgentID)
	Local $lAgentID
	Local $lOffset[6] = [0, 0x18, 0x4C, 0x54, 0x24, 0]
	If ID($aAgentID) = GetMyID() Then Return 0

	For $i = 1 To GetHeroCount()
		$lOffset[5] = 0x18 * ($i - 1)
		$lAgentID = Memory_ReadPtr($g_p_BasePointer, $lOffset)
		If $lAgentID[1] = Agent_ConvertID($aAgentID) Then Return $i
	Next
	Return False
EndFunc   ;==>GetHeroNumberByAgentID

;~ Description: Returns hero number by hero ID.
Func GetHeroNumberByHeroID($aHeroId)
	Local $lAgentID
	Local $lOffset[6] = [0, 0x18, 0x4C, 0x54, 0x24, 0]

	For $i = 1 To GetHeroCount()
		$lOffset[5] = 8 + 0x18 * ($i - 1)
		$lAgentID = Memory_ReadPtr($g_p_BasePointer, $lOffset)
		If $lAgentID[1] = Agent_ConvertID($aHeroId) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByHeroID

;~ Description: Returns hero's profession ID (when it can't be found by other means)
Func GetHeroProfession($aHeroNumber, $aSecondary = False)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6BC, 0]
	Local $lBuffer
	$aHeroNumber = GetHeroID($aHeroNumber)
	For $i = 0 To GetHeroCount()
		$lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
		If $lBuffer[1] = $aHeroNumber Then
			$lOffset[4] += 4
			If $aSecondary Then $lOffset[4] += 4
			$lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
		$lOffset[4] += 0x14
	Next
EndFunc   ;==>GetHeroProfession
#EndRegion HeroInfo

#Region Effects
; Returns the number of crippled heroes - burning condition only accessible for heroes
;~ Func GetNumberOfCrippledHeroes($aRange = 5000) ; I think this works also with effect
;~ 	Local $lCount = 0
;~ 	For $heronumber = 0 To GetPartySize() -1
;~ 		If Not HasEffect($skill_id_crippled, $heronumber) Then ContinueLoop
;~ 		$lCount += 1
;~ 	Next
;~ 	Return $lCount
;~ EndFunc   ;==>GetNumberOfCrippledHeroes

;~ ; Returns the number of burning heroes - burning condition only accessible for heroes
;~ Func GetNumberOfBurningHeroes($aRange = 5000)
;~ 	Local $lCount = 0
;~ 	For $heronumber = 0 To GetPartySize() -1
;~ 		If Not HasEffect($skill_id_burning, $heronumber) Then ContinueLoop
;~ 		$lCount += 1
;~ 	Next
;~ 	Return $lCount
;~ EndFunc   ;==>GetNumberOfBurningHeroes
#EndRegion Effects