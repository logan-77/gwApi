#include-once

;~ Description: Returns the pointer variable to a skillbar for specified hero number.
Func GetSkillbarPtr($aHeroNumber = 0)
	; Local $lOffset[5] = [0, 24, 76, 84, 44]
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
	Local $lSkillbarStructAddress
	
	For $i = 0 To $lHeroCount[1]
		$lOffset[4] = $i * 0xBC
		$lSkillbarStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
		If $lSkillbarStructAddress[1] = GetHeroID($aHeroNumber) Then Return $lSkillbarStructAddress[0]
	Next
EndFunc   ;==>GetSkillbarPtr

;~ Description: Returns the pointer variable to a skillbar for specified hero ID.
Func GetSkillbarPtrByHeroID($aHeroId)
	;~ Local $lOffset[5] = [0, 24, 76, 84, 44]
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
	For $i = 0 To $lHeroCount[1]
		$lOffset[4] = $i * 0xBC
		Local $lSkillbarStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
		If $lSkillbarStructAddress[1] = $aHeroId Then Return $lSkillbarStructAddress[0]
	Next
EndFunc   ;==>GetSkillbarPtrByHeroID

#Region Skills
Func UseSkillEx($aSkillSlot, $aTarget = -2, $aTimeout = 3000, $aCallTarget = False, $aSkillbarPtr = GetSkillbarPtr())
	Local $lDeadlock = TimerInit(), $lAgentID = ID($aTarget), $lMe = GetAgentPtr(-2)
	Local $lSkill = GetSkillPtr(GetSkillbarSkillID($aSkillSlot, 0, $aSkillbarPtr))
	If $lAgentID = 0 Or GetIsDead($lMe) Or Not IsRecharged($aSkillSlot, $aSkillbarPtr) Then Return
	If GetEnergy($lMe) < GetEnergyReq($lSkill) Then Return
	
	If $lAgentID <> GetMyID() Then ChangeTarget($lAgentID)
	UseSkill($aSkillSlot, $lAgentID, $aCallTarget)
	Do
		Sleep(50)
		If GetIsDead($lAgentID) Or GetIsDead($lMe) Then Return		
	Until Not IsRecharged($aSkillSlot, $aSkillbarPtr) Or TimerDiff($lDeadlock) > $aTimeout
	Sleep(MemoryRead($lSkill + 64, "float") * 1000) ; Aftercast
	Return True
EndFunc   ;==>UseskillEX

;~ Description: Returns energy cost of a skill.
Func GetEnergyReq($aSkillID)
	Local $lEnergycost = MemoryRead(GetSkillPtr($aSkillID) + 53, "byte")
	If $lEnergycost = 11 Then Return 15
	If $lEnergycost = 12 Then Return 25
	Return $lEnergycost
EndFunc   ;==>GetEnergyReq

;~ Description: Checks SkillRecharge by SkillSlot; True=Recharged
Func IsRechargedHero($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	Return GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber, $aSkillbarPtr) = 0
EndFunc   ;==>IsRechargedHero

Func IsRecharged($aSkillSlot, $aSkillbarPtr = GetSkillbarPtr())
	Return GetSkillbarSkillRecharge($aSkillSlot, 0, $aSkillbarPtr) = 0
EndFunc ;==>IsRecharged

;~ Description: Returns the recharge time remaining of an equipped skill in milliseconds.
Func GetSkillbarSkillRecharge($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$aSkillSlot -= 1
	Local $lTimestamp = MemoryRead($aSkillbarPtr + 12 + $aSkillSlot * 20, "dword")
	If $lTimestamp = 0 Then Return 0
	Return $lTimestamp - GetSkillTimer()
EndFunc ;==>GetSkillbarSkillRecharge

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($askillslot, $aHeronumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$askillslot -= 1
	Return MemoryRead($aSkillbarPtr + 16 + $aSkillslot * 20, "dword")
EndFunc ;==>GetSkillbarSkillID

;~ Description: Returns the adrenaline charge of an equipped skill.
Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
	$aSkillSlot -= 1
	Return MemoryRead($aSkillbarPtr + 4 + $aSkillSlot * 20, "long")
EndFunc   ;==>GetSkillbarSkillAdrenaline
#EndRegion Skills

#Region Efffects
;~ Description: Returns array of effectptr on agent.
Func GetEffectsPtr($aSkillID = 0, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Local $lEffectCount, $lEffectStructAddress, $lBuffer
	Local $lAmount = 0
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x510]
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroId Then
			$lOffset[4] = 0x1C + 0x24 * $i
			$lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			ReDim $lOffset[6]
			$lOffset[4] = 0x14 + 0x24 * $i
			$lOffset[5] = 0
			$lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			If $aSkillID = 0 Then
				Local $lReturnArray[$lEffectCount[1] + 1]
				$lReturnArray[0] = $lEffectCount[1]
				For $i = 1 To $lEffectCount[1]
					$lReturnArray[$i] = Ptr($lEffectStructAddress[0] + 0x18 * ($i - 1))
				Next
				Return $lReturnArray
			Else
				Local $lReturnArray[2] = [0, 0]
				For $j = 0 To $lEffectCount[1] - 1
					$lReturn = $lEffectStructAddress[0] + 0x18 * $j
					If MemoryRead($lReturn, "long") = $aSkillID Then
						$lReturnArray[0] = 1
						$lReturnArray[1] = Ptr($lReturn)
						Return $lReturnArray
					EndIf
				Next
			EndIf
		EndIf
	Next
EndFunc   ;==>GetEffectsPtr

;~ Description: 
Func GetSkillEffectPtr($aSkillID, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x510]
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroId Then
			$lOffset[4] = 0x1C + 0x24 * $i
			Local $lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			$lOffset[4] = 0x14 + 0x24 * $i
			Local $lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')
			For $j = 0 To $lEffectCount[1] - 1
				Local $lEffectSkillID = MemoryRead($lEffectStructAddress[1] + 0x18 * $j, 'long')
				If $lEffectSkillID = $aSkillID Then Return Ptr($lEffectStructAddress[1] + 0x18 * $j)
			Next
		EndIf
	Next
EndFunc   ;==>GetSkillEffectPtr

; Local $lOffset[5] = [0, 24, 44, 1288, 28]
; Local $lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
; $lOffset[4] = 20
; Local $lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset, 'ptr')


;~ Description: Returns ptr to effect by EffectNumber.
Func GetSkillEffectPtrByEffectnumber($aEffectNumber, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Local $lOffset[4] = [0, 24, 44, 1296]
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 1288
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 36 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroId Then
			$lOffset[4] = 28 + 36 * $i
			$lEffectCount = MemoryReadPtr($mBasePointer, $lOffset)
			$lOffset[4] = 20 + 36 * $i
			ReDim $lOffset[6]
			$lOffset[5] = 0
			$lEffectStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			Return Ptr($lEffectStructAddress[0] + 24 * $aEffectNumber)
		EndIf
	Next
EndFunc   ;==>GetSkillEffectPtrByEffectnumber

;~ Description: Returns time remaining before an effect expires, in milliseconds.
Func GetEffectTimeRemaining($aEffect)
	Local $lTimestamp, $lDuration

	If IsArray($aEffect) Then Return 0
	If $aEffect = 0 Then Return 0
	If IsPtr($aEffect) Then
		$lTimestamp = MemoryRead($aEffect + 20, 'long')
		$lDuration = MemoryRead($aEffect + 16, 'float')
	ElseIf IsDllStruct($aEffect) <> 0 Then
		$lTimestamp = DllStructGetData($aEffect, 'TimeStamp')
		$lDuration = DllStructGetData($aEffect, 'Duration')
	Else
		Local $lPtr = GetSkillEffectPtr($aEffect)
		If $lPtr = 0 Then Return 0
		$lTimestamp = MemoryRead($lPtr + 20, 'long')
		$lDuration = MemoryRead($lPtr + 16, 'float')
	EndIf
	Local $lReturn = $lDuration * 1000 - (GetSkillTimer() - $lTimestamp)
	Return $lReturn
EndFunc   ;==>GetEffectTimeRemaining

;~ Description: Returns current morale.
Func GetMorale($aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x638
	Local $lIndex = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x62C
	$lOffset[4] = 8 + 0xC * BitAND($lAgentID, $lIndex[1])
	$lOffset[5] = 0x18
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1] - 100
EndFunc   ;==>GetMorale

;~ Description: Returns True if you're under the effect of $aEffectSkillID.
Func HasEffect($aEffectSkillID, $aHeroNumber = 0, $aHeroId = GetHeroID($aHeroNumber))
	Return GetSkillEffectPtr($aEffectSkillID, $aHeroNumber, $aHeroId) <> 0
EndFunc   ;==>HasEffect

;~ Description: Tests if self or other hero is burning - cannot use for enemies or other human players
Func GetIsBurning($aHeroNumber = 0)
	Return HasEffect($skill_id_burning, $aHeroNumber)
EndFunc   ;==>GetIsBurning
#EndRegion Effects

#Region Buffs
;~ Description: Returns current number of buffs being maintained.
Func GetBuffCount($aHeroNumber = 0)
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			Return MemoryRead($lBuffer[0] + 0xC)
		EndIf
	Next
	Return 0
EndFunc   ;==>GetBuffCount

;~ Description: Tests if you are currently maintaining buff on target.
Func GetIsTargetBuffed($aSkillID, $aAgentID, $aHeroNumber = 0)
	Local $lBuffStruct = DllStructCreate('long SkillId;byte unknown1[4];long BuffId;long TargetId')
	Local $lBuffCount = GetBuffCount($aHeroNumber)
	Local $lBuffStructAddress
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			For $J = 0 To $lBuffCount - 1
				$lOffset[5] = 0 + 0x10 * $J
				$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
				DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($lBuffStruct), 'int', DllStructGetSize($lBuffStruct), 'int', '')
				If (DllStructGetData($lBuffStruct, 'SkillID') = $aSkillID) And (DllStructGetData($lBuffStruct, 'TargetId') = ID($aAgentID)) Then
					Return $J + 1
				EndIf
			Next
		EndIf
	Next
	Return 0
EndFunc   ;==>GetIsTargetBuffed

;~ Description: Returns buff struct.
Func GetBuffByIndex($aBuffNumber, $aHeroNumber = 0)
	Local $lBuffStruct = DllStructCreate('long SkillId;byte unknown1[4];long BuffId;long TargetId')
	Local $lOffset[4]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0x510
	Local $lCount = MemoryReadPtr($mBasePointer, $lOffset)
	ReDim $lOffset[5]
	$lOffset[3] = 0x508
	Local $lBuffer
	For $i = 0 To $lCount[1] - 1
		$lOffset[4] = 0x24 * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == GetHeroID($aHeroNumber) Then
			$lOffset[4] = 0x4 + 0x24 * $i
			ReDim $lOffset[6]
			$lOffset[5] = 0 + 0x10 * ($aBuffNumber - 1)
			$lBuffStructAddress = MemoryReadPtr($mBasePointer, $lOffset)
			DllCall($mKernelHandle, 'int', 'ReadProcessMemory', 'int', $mGWProcHandle, 'int', $lBuffStructAddress[0], 'ptr', DllStructGetPtr($lBuffStruct), 'int', DllStructGetSize($lBuffStruct), 'int', '')
			Return $lBuffStruct
		EndIf
	Next
	Return 0
EndFunc   ;==>GetBuffByIndex

Func DropAllBondsBySkillID($aSkillID)
	For $i = 1 To GetBuffCount()
		DropBuff($aSkillID, DllStructGetData(GetBuffByIndex($i), 'TargetId'))
	Next
EndFunc   ;==>DropAllBondsBySkillID

Func DropAllBondsOnTargetID($aTargetID)
	For $i = 1 To GetBuffCount()
		DropBuff(DllStructGetData(GetBuffByIndex($i), 'SkillId'), $aTargetID)
	Next
EndFunc   ;==>DropAllBondsOnTargetID
#EndRegion Buffs


#Region Template: Skill & Attribute
;~ Description: Set all attributes to 0
;~ Func ClearAttributes($aHeroNumber = 0)
;~ 	Local $lLevel
;~ 	If GetMapLoading() <> 0 Then Return
;~ 	For $i = 0 To 44
;~ 		If GetAttributeByID($i, False, $aHeroNumber) > 0 Then
;~ 			Do
;~ 				$lLevel = GetAttributeByID($i, False, $aHeroNumber)
;~ 				$lDeadlock = TimerInit()
;~ 				DecreaseAttribute($i, $aHeroNumber)
;~ 				Do
;~ 					Sleep(20)
;~ 				Until $lLevel > GetAttributeByID($i, False, $aHeroNumber) Or TimerDiff($lDeadlock) > 5000
;~ 				Sleep(100)
;~ 			Until GetAttributeByID($i, False, $aHeroNumber) == 0
;~ 		EndIf
;~ 	Next
;~ EndFunc   ;==>ClearAttributes

;~ Description: Returns level of an attribute.
Func GetAttributeByID($aAttributeID, $aWithRunes = False, $aHeroNumber = 0)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Local $lBuffer
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x2C
	$lOffset[3] = 0xAC
	For $i = 0 To GetHeroCount()
		$lOffset[4] = 0x43C * $i
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] == $lAgentID Then
			If $aWithRunes Then
				$lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0xC
			Else
				$lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0x8
			EndIf
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
	Next
EndFunc   ;==>GetAttributeByID

; Returns the attribute of a skill
Func SkillAttribute($aSkill)
	If IsPtr($aSkill) <> 0 Then
		Return MemoryRead($aSkill + 41, "byte")
	ElseIf IsDllStruct($aSkill) <> 0 Then
		Return DllStructGetData($aSkill, "Attribute")
	Else
		Return MemoryRead(GetSkillPtr($aSkill) + 41, "byte")
	EndIf
EndFunc   ;==>SkillAttribute
#EndRegion Template: Skill & Attribute