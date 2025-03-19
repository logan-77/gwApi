#cs
Functions for retrieving information from the Agent Struct.
#ce
#include-once

;~ Case 0: all agents
;~ Case 1: agents by: $aType (use only this for 0x200/0x400)
;~ Case 2: agents by: $aType + $aAllegiance
;~ Case 3: agents by $aType + $aAllegiance + exclude Minions/Spirits + optional: PlayerNumber, Effect, $aRange ($aAgent or $aX/$aY)
;~ Case 5: only for Feather Farm
;~ Case 6: only for CoF
;~ GetAgentPtrArray: Mode, Type, Allegiance, Range, Agent, PlayerNumber, Effect, x, y
Func GetAgentPtrArray($aMode = 0, $aType = 0xDB, $aAllegiance = 3, $aRange = 1320, $aAgent = GetAgentPtr(-2), $aPlayerNumber = 0, $aEffect = 0, $aX = X($aAgent), $aY = Y($aAgent))
	Local $lMaxAgents = GetMaxAgents()
	Local $lAgentPtrStruct = DllStructCreate("PTR[" & $lMaxAgents & "]")
	DllCall($mKernelHandle, "BOOL", "ReadProcessMemory", "HANDLE", $mGWProcHandle, "PTR", MemoryRead($mAgentBase), "STRUCT*", $lAgentPtrStruct, "ULONG_PTR", $lMaxAgents * 4, "ULONG_PTR*", 0)
	Local $lTempPtr
	Local $lAgentArray[$lMaxAgents + 1]
	$lAgentArray[0] = 0

	For $i = 1 To $lMaxAgents
		$lTempPtr = DllStructGetData($lAgentPtrStruct, 1, $i)
		If $lTempPtr = 0 Then ContinueLoop
		If $aMode >= 1 And MemoryRead($lTempPtr + 156, 'long') <> $aType Then ContinueLoop
		If $aMode >= 2 And MemoryRead($lTempPtr + 433, 'byte') <> $aAllegiance Then ContinueLoop
		If $aMode >= 3 Then
			If $aEffect <> 0x0010 And GetIsDead($lTempPtr) Then ContinueLoop ; HP > 0
			If $aRange <> 0 And GetDistanceToXY($aX, $aY, $lTempPtr) > $aRange Then ContinueLoop ; is in $aRange
			If $aPlayerNumber <> 0 And $aPlayerNumber <> MemoryRead($lTempPtr + 244, "word") Then ContinueLoop ; has PlayerNumber
			If $aEffect <> 0 And Not BitAND(MemoryRead($lTempPtr + 312, 'long'), $aEffect) Then ContinueLoop ; has $aEffect
			; ally Spirits/Minions have Allegiance 0x4/0x5
			If $aAllegiance = 3 And (IsMinionAgent($lTempPtr) Or IsSpiritAgent($lTempPtr)) Then ContinueLoop
		EndIf
		If $aMode = 5 And Not IsSensali($lTempPtr) Then ContinueLoop ; featherbot
		If $aMode = 6 And Not IsCofEnemy($lTempPtr) Then ContinueLoop ; cof bot

		$lAgentArray[0] += 1
		$lAgentArray[$lAgentArray[0]] = $lTempPtr
	Next
	ReDim $lAgentArray[$lAgentArray[0] + 1]
	Return $lAgentArray
EndFunc ;==>GetAgentPtrArray

#Region AgentControls
; Returns the number of living enemies in range of an agent excluding spawned creatures. optional: PlayerNumber
Func GetNumberOfEnemiesNearAgent($aAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, $aAgent, $aPlayerNumber)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfEnemiesNearAgent

; Returns the number of living enemies in range of an agent excluding spawned creatures. optional: PlayerNumber
Func GetNumberOfEnemiesNearAgent2(ByRef $aAgentPtrArray, $aAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtr = GetAgentPtr($aAgent), $lCount = 0
	
	For $i = 1 To $aAgentPtrArray[0]
		If GetIsDead($aAgentPtrArray[$i]) Then ContinueLoop
		If GetDistance($aAgentPtrArray[$i], $lAgentPtr) > $aRange Then ContinueLoop
		If $aPlayerNumber <> 0 And GetPlayerNumber($aAgentPtrArray[$i]) <> $aPlayerNumber Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfEnemiesNearAgent

; Returns the number of living enemies in range of a waypoint excluding Spirits+Minions. optional: PlayerNumber
Func GetNumberOfEnemiesNearXY($aX, $aY, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, -2, $aPlayerNumber, 0, $aX, $aY)
	Return UBound($lAgentPtrArray) - 1
EndFunc ;==>GetNumberOfEnemiesNearXY

; Returns the number of living enemies in range of a waypoint excluding Spirits+Minions. optional: PlayerNumber
Func GetNumberOfEnemiesNearXY2(ByRef $aAgentPtrArray, $aX, $aY, $aRange = 1250, $aPlayerNumber = 0)
	Local $lCount = 0
	
	For $i = 1 To $aAgentPtrArray[0]
		If GetIsDead($aAgentPtrArray[$i]) Then ContinueLoop
		If GetDistanceToXY($aX, $aY, $aAgentPtrArray[$i]) > $aRange Then ContinueLoop
		If $aPlayerNumber <> 0 And GetPlayerNumber($aAgentPtrArray[$i]) <> $aPlayerNumber Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetNumberOfEnemiesNearXY

; Returns the number of living allies in range of an agent
Func GetNumberOfDeadAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, GetAgentPtr(-2), 0, 0x0010)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfDeadAllies

;~ Returns the number of living allies in range of an agent. (include npc, pet, spirit)
Func GetNumberOfAlliesInRangeOfAgent($aAgent = -2, $aRange = 1250)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, $aAgent)
	Return UBound($lAgentPtrArray) - 1
EndFunc ;==>GetNumberOfAlliesInRangeOfAgent

; Returns the number of allies with a condition
Func GetNumberOfConditionedAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, GetAgentPtr(-2), 0, 0x0002)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfConditionedAllies

; Returns the number of bleeding allies
Func GetNumberOfBleedingAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, GetAgentPtr(-2), 0, 0x0001)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfBleedingAllies

; Returns the number of poisoned allies
Func GetNumberOfPoisonedAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, GetAgentPtr(-2), 0, 0x0040)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfPoisonedAllies

; Returns the number of deep-wounded allies
Func GetNumberOfDeepWoundedAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, GetAgentPtr(-2), 0, 0x0020)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfDeepWoundedAllies

;~ GetAgentPtrArray: Mode, Type, Allegiance, Range, Agent, PlayerNumber, Effect, x, y
;~ Description: Returns Highest HP Enemy in Range. optional: PlayerNumber
Func GetHighestHPEnemyPtrToAgent($aAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, $aAgent, $aPlayerNumber)
	Local $lHighestHP = 0, $lHighestHPAgentPtr = 0, $lHP
	
	For $i = 1 To $lAgentPtrArray[0]
		$lHP = GetHP($lAgentPtrArray[$i])
		If $lHP > $lHighestHP Then
			$lHighestHP = $lHP
			$lHighestHPAgentPtr = $lAgentPtrArray[$i]
		EndIf
	Next
	Return $lHighestHPAgentPtr
EndFunc ;==>GetHighestHPEnemyPtr

Func GetAgentPtrByPlayerNumber($aPlayerNumber, $aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(1, 0xDB)
	For $i = 1 To $lAgentPtrArray[0]
		If GetIsDead($lAgentPtrArray[$i]) Then ContinueLoop
		If GetDistance($lAgentPtrArray[$i]) > $aRange Then ContinueLoop
		If MemoryRead($lAgentPtrArray[$i] + 244, 'word') = $aPlayerNumber Then Return $lAgentPtrArray[$i]
	Next
	Return 0
EndFunc   ;==>GetAgentPtrByPlayerNumber
#EndRegion AgentControls

#Region GetNearestAgentPtr
;~ Description: Returns Pointer to nearest agent to an agent or XY. optional: PlayerNumber
;~ GetNearestAgentPtr: Agent, Type, Allegiance, PlayerNumber, X, Y
Func GetNearestAgentPtr($aAgent = -2, $aType = 0xDB, $aAllegiance = 0, $aPlayerNumber = 0, $aX = X($aAgent), $aY = Y($aAgent))
	Local $lAgent = GetAgentPtr($aAgent), $lNearestAgentPtr = 0, $lNearestDistance = 25000000
	Local $lAgentPtrArray, $lDistance
	Switch $aType
		Case 0xDB
			$lAgentPtrArray = GetAgentPtrArray(2, $aType, $aAllegiance)
		Case 0x200, 0x400
			$lAgentPtrArray = GetAgentPtrArray(1, $aType)
	EndSwitch

	For $i = 1 To $lAgentPtrArray[0]
		If $lAgentPtrArray[$i] = $lAgent Then ContinueLoop
		If GetIsDead($lAgentPtrArray[$i]) Then ContinueLoop
		If $aAllegiance = 0x03 And (IsMinionAgent($lAgentPtrArray[$i]) Or IsSpiritAgent($lAgentPtrArray[$i])) Then ContinueLoop
		If $aPlayerNumber <> 0 And MemoryRead($lAgentPtrArray[$i] + 244, "word") <> $aPlayerNumber Then ContinueLoop
		$lDistance = GetPseudoDistanceToXY($aX, $aY, $lAgentPtrArray[$i])
		If $lDistance < $lNearestDistance Then
			$lNearestAgentPtr = $lAgentPtrArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next
	Return $lNearestAgentPtr
EndFunc ;==>GetNearestAgentPtr

;~ Returns distance of nearest Agent. param: Allegiance
Func GetNearestDistance($aAgent = -2, $aAllegiance = 3)
	Local $lNearestAgentPtr = GetNearestAgentPtr($aAgent, 0xDB, $aAllegiance)
	If $lNearestAgentPtr <> 0 Then
		Return GetDistance($lNearestAgentPtr, $aAgent)
	Else
		Return 10000
	EndIf
EndFunc   ;==>GetNearestDistance

;~ Description: Returns pointer variable for the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent($aAgent = -2, $aPlayerNumber = 0)
	Return GetNearestAgentPtr($aAgent, 0xDB, 0x03, $aPlayerNumber)
EndFunc ;==>GetNearestEnemyPtrToAgent

;~ Description: Returns pointer variable for the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent2(ByRef $aAgentPtrArray, $aAgent = -2, $aPlayerNumber = 0)	
	Local $lAgent = GetAgentPtr($aAgent), $lNearestAgentPtr = 0, $lNearestDistance = 100000000, $lDistance
	For $i = 1 To $aAgentPtrArray[0]
		If GetIsDead($aAgentPtrArray[$i]) Then ContinueLoop
		If $aPlayerNumber <> 0 And MemoryRead($aAgentPtrArray[$i] + 244, "word") <> $aPlayerNumber Then ContinueLoop
		$lDistance = GetPseudoDistance($aAgentPtrArray[$i], $lAgent)
		If $lDistance < $lNearestDistance Then
			$lNearestDistance = $lDistance
			$lNearestAgentPtr = $aAgentPtrArray[$i]
		EndIf
	Next
	Return $lNearestAgentPtr
EndFunc ;==>GetNearestEnemyPtrToAgent

Func GetNearestEnemyPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
	Return GetNearestAgentPtr(-2, 0xDB, 0x03, $aPlayerNumber, $aX, $aY)
EndFunc ;==>GetNearestEnemyPtrToXY

;~ Description: Returns pointer to the nearest NPC to an agent. optional: PlayerNumber
Func GetNearestNPCPtrToAgent($aAgent = -2, $aPlayerNumber = 0)
	Return GetNearestAgentPtr($aAgent, 0xDB, 0x06, $aPlayerNumber)
EndFunc   ;==>GetNearestNPCPtrToAgent

;~ Description: Returns pointer to the nearest NPC to XY. optional: PlayerNumber
Func GetNearestNPCPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
	Return GetNearestAgentPtr(-2, 0xDB, 0x06, $aPlayerNumber, $aX, $aY)
EndFunc   ;==>GetNearestNPCPtrToXY

;~ Description: Returns the pointer variable for the nearest signpost to an agent.
;~ GetNearestAgentPtr: Agent, Type, Allegiance, PlayerNumber, X, Y
Func GetNearestSignpostPtrToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0x200)
EndFunc   ;==>GetNearestSignpostPtrToAgent

;~ Description: Returns the pointer variable for the nearest signpost to a set of coordinates.
Func GetNearestSignpostPtrToXY($aX, $aY)
	Return GetNearestAgentPtr(-2, 0x200, 2, 0, $aX, $aY) ; look up allegiance=2
EndFunc   ;==>GetNearestSignpostPtrToXY

;~ Description: Returns pointer variable for the nearest ally to an agent.
Func GetNearestAllyPtrToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0xDB, 0x01)
EndFunc   ;==>GetNearestAllyPtrToAgent

;~ Description: Returns pointer variable for the nearest dead ally to an agent.
;CHECK THIS FUNC, this deffo needs changing!
Func GetNearestDeadAllyPtrToAgent($aAgent = -2)
	Local $lPtr = GetAgentPtr($aAgent), $lNearestAgentPtr, $lDistance, $lNearestDistance = 25000000
	Local $lAgentPtrArray = GetAgentPtrArray(4, 0xDB, 1, 1320, GetAgentPtr(-2), 0x0010)

	For $i = 1 To $lAgentPtrArray[0]
		If $lAgentPtrArray[$i] == $lPtr Then ContinueLoop
		$lDistance = GetDistance($lAgentPtrArray[$i], $lPtr)
		If $lDistance < $lNearestDistance Then
			$lNearestAgentPtr = $lAgentPtrArray[$i]
			$lNearestDistance = $lDistance
		EndIf
	Next
	Return $lNearestAgentPtr
EndFunc   ;==>GetNearestDeadAllyPtrToAgent

;~ Description: Returns pointer variable for the nearest spirit ally to an agent.
Func GetNearestSpiritPtrToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0xDB, 0x04)
EndFunc   ;==>GetNearestSpiritPtrToAgent

;~ Description: Returns pointer variable for the nearest minion ally to an agent.
Func GetNearestMinionAllyToAgent($aAgent = -2)
	Return GetNearestAgentPtr($aAgent, 0xDB, 0x05)
EndFunc   ;==>GetNearestMinionAllyToAgent
#EndRegion GetNearestAgentPtr

#Region AgentInfo
;~ Description: Returns the ID of an Agent
Func ID($aAgent = GetAgentPtr(-2))
	Select
		Case $aAgent = -2
			Return GetMyID()
		Case $aAgent = -1
			Return GetCurrentTargetID()
		Case IsPtr($aAgent)
			Return MemoryRead($aAgent + 44, 'long')
		Case IsDllStruct($aAgent)
			Return DllStructGetData($aAgent, 'ID')
		Case Else
			Return $aAgent
	EndSelect
EndFunc ;==>ID

;~ Description: Returns current target Ptr.
Func GetCurrentTargetPtr()
	Local $lCurrentTargetID = MemoryRead($mCurrentTarget)
	If $lCurrentTargetID = 0 Then Return
	Return MemoryRead(MemoryRead($mAgentBase, 'ptr') + 4 * $lCurrentTargetID, 'ptr')
EndFunc   ;==>GetCurrentTargetPtr

;~ Description: Internal use for GetAgentByID()
;~ Func GetAgentPtr($aAgent = GetMyID())
;~ 	If IsPtr($aAgent) Then Return $aAgent
;~ 	Return MemoryRead(MemoryRead($mAgentBase, 'ptr') + 4 * ID($aAgent), 'ptr')
;~ 	; Local $lOffset[3] = [0, 4 * ID($aAgent), 0]
;~ 	; Local $lAgentStructAddress = MemoryReadPtr($mAgentBase, $lOffset, 'ptr')
;~ 	; Return $lAgentStructAddress[0]
;~ EndFunc   ;==>GetAgentPtr

;~ Description: Test if an agent exists.
Func GetAgentExists($aAgentID)
	Return (GetAgentPtr($aAgentID) > 0 And ID($aAgentID) < GetMaxAgents())
EndFunc   ;==>GetAgentExists

;~ Description: Agents X Location
Func X($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 116, 'float')
EndFunc   ;==>X

;~ Description: Agents Movevement on the X axis
Func MoveX($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 160, 'float')
EndFunc   ;==>MoveX

;~ Description: Agents Y Location
Func Y($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 120, 'float')
EndFunc   ;==>Y

;~ Description: Agents Movevement on the Y axis
; #FUNCTION# ====================================================================================================================
; Name ..........: MoveY
; Description ...:
; Syntax ........: MoveY([$aAgent = -2])
; Parameters ....: $aAgent              - [optional] Default is -2.
; Return values .: None
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func MoveY($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 164, 'float')
EndFunc   ;==>MoveY

;~ Description: Agents X and Y Location
Func XY($aAgent = -2)
	Local $lLocation[2]
	Local $lPtr = GetAgentPtr($aAgent)
	
	$lLocation[0] = X($lPtr)
	$lLocation[1] = Y($lPtr)
	Return $lLocation
EndFunc   ;==>XY

;~ Description: Agents Z Location
Func Z($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 48, 'float')
EndFunc ;==>Z

;~ Description: Agents PlayerNumber
Func GetPlayerNumber($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 244, "word")
EndFunc	;==>GetPlayerNumber

;~ Description: Returns a player's name.
Func GetPlayerName($aAgent = -2)
	Local $lLogin = MemoryRead(GetAgentPtr($aAgent) + 384, "long")
	Local $lOffset[6] = [0, 0x18, 0x2C, 0x80C, 76 * $lLogin + 0x28, 0]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset, 'wchar[30]')
	Return $lReturn[1]
EndFunc   ;==>GetPlayerName

;~ Description: Returns the name of an agent.
;~ Func GetAgentName($aAgent = -2)
;~ 	If $mUseStringLog = False Then Return
;~ 	Local $lAgentID = ID($aAgent)
;~ 	If $lAgentID = GetMyID() Then Return GetCharname()
;~ 	Local $lAddress = $mAgentNameLogBase + 256 * $lAgentID
;~ 	Local $lName = MemoryRead($lAddress + 0x2, 'wchar [126]')
;~ 	If $lName = '' Then
;~ 		DisplayAll(True)
;~ 		Sleep(100)
;~ 		DisplayAll(False)
;~ 	EndIf
;~ 	Local $lName = MemoryRead($lAddress + 0x2, 'wchar [126]')
;~ 	$lName = StringRegExpReplace($lName, '[<]{1}([^>]+)[>]{1}', '')
;~ 	Return $lName
;~ EndFunc   ;==>GetAgentName

;~ Description: Returns health of an agent. Returns 0 for NPC's
Func GetHealth($aAgent = -2)
	Local $lPtr = GetAgentPtr($aAgent)
	Return MemoryRead($lPtr + 304, 'float') * MemoryRead($lPtr + 308, "long")
EndFunc   ;==>GetHealth

;~ Description: Returns health of an agent as % of max HP
Func GetHP($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 304, 'float')
EndFunc   ;==>GetHP

;~ Description: Returns the level of an agent.
Func GetLevel($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 268, "byte")
EndFunc   ;==>GetLevel

;~ Description: Returns the team of an agent.
Func GetTeam($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 269, "byte")
EndFunc   ;==>GetTeam

;~ Description: Returns the energy pips of an agent.
Func GetEnergyPips($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 276, "float")
EndFunc   ;==>GetEnergyPips

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetEnergy($aAgent = -2)
	Local $lPtr = GetAgentPtr($aAgent)
	Return MemoryRead($lPtr + 284, 'float') * MemoryRead($lPtr + 288, "long")
EndFunc   ;==>GetEnergy

;~ Description: Returns the allegiance of an agent.
Func GetAllegiance($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 433, 'byte')
EndFunc   ;==>GetSkillID

;~ Description: Returns the skill currently being cast by an agent.
Func GetSkillID($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 436, "word")
EndFunc   ;==>GetSkillID

;~ Description: Returns the weapon Type of an agent.
Func GetWeaponType($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 434, "Word")
EndFunc   ;==>GetWeaponType

;~ Description: Returns the weapon item ID of an agent.
Func GetWeaponItemID($aAgent)
	Return MemoryRead(GetAgentPtr($aAgent) + 442, "word")
EndFunc   ;==>GetWeaponItemID

;~ Description: Returns the offhand item ID of an agent.
Func GetOffhandItemID($aAgent)
	Return MemoryRead(GetAgentPtr($aAgent) + 444, "word")
EndFunc   ;==>GetOffhandItemID

;~ Description: Tests if an agent is casting.
Func GetIsCasting($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 436, "word") <> 0
EndFunc   ;==>GetIsCasting

;~ Description: Tests if an agent is moving.
Func GetIsMoving($aAgent = GetAgentPtr(-2), $aTimer = 0)
	If MoveX($aAgent) <> 0 Or MoveY($aAgent) <> 0 Then Return True
	If $aTimer <> 0 Then
		Sleep($aTimer)
		If MoveX($aAgent) <> 0 Or MoveY($aAgent) <> 0 Then Return True
	EndIf
	Return False
EndFunc   ;==>GetIsMoving

; === Type ===
;~ Description: Tests if an agent is living.
Func GetIsLiving($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0xDB
EndFunc   ;==>GetIsLiving

;~ Description: Tests if an agent is a signpost/chest/etc.
Func GetIsStatic($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x200
EndFunc   ;==>GetIsStatic

;~ Description: Tests if an agent is an item.
Func GetIsMovable($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long') = 0x400
EndFunc   ;==>GetIsMovable

;~ Description: Returns the Type of the Agent. 0xDB/0x200/0x400
Func GetType($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 156, 'long')
EndFunc   ;==>GetType

#Region Model State
; NOT reliable with disable render
;~ Description: Tests if an agent is knocked down.
Func GetIsKnocked($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 340, "long") = 0x450
EndFunc   ;==>GetIsKnocked

;~ Description: Tests if an agent is attacking.
Func GetIsAttacking($aAgent = -2)
	Local $lModelState = MemoryRead(GetAgentPtr($aAgent) + 340, "long")
	Switch $lModelState
		Case 0x60, 0x460, 0x440
			Return True
		Case 0x20, 0x420, 0x24 ;derv w/ disable render
			Return True
		Case Else
			Return False
	EndSwitch
EndFunc   ;==>GetIsAttacking
#EndRegion Model State
#EndRegion AgentInfo

#Region Effects
;	=== Effects ====
;~ Description: Tests if an agent is dead.
Func GetIsDead($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0010) > 0
EndFunc   ;==>GetIsDead

;~ Description: Tests if an agent has a condition. Accepts ID, Struct or Ptr
Func GetHasCondition($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0002) > 0
EndFunc   ;==>GetHasCondition

;~ Description: Tests if an agent is bleeding.
Func GetIsBleeding($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0001) > 0
EndFunc   ;==>GetIsBleeding

;~ Description: Tests if self or other hero is crippled - cannot use for enemies or other human players
Func GetIsCrippled($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0008) > 0
EndFunc   ;==>GetIsCrippled

;~ Description: Tests if an agent has a deep wound. Accepts ID, Struct or Ptr
Func GetHasDeepWound($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0020) > 0
EndFunc   ;==>GetHasDeepWound

;~ Description: Tests if an agent is poisoned. Accepts ID, Struct or Ptr
Func GetIsPoisoned($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, 'long'), 0x0040) > 0
EndFunc   ;==>GetIsPoisoned

;~ Description: Tests if an agent is enchanted. Accepts ID, Struct or Ptr
Func GetIsEnchanted($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0080) > 0
EndFunc   ;==>GetIsEnchanted

;~ Description: Tests if an agent has a degen hex. Accepts ID, Struct or Ptr
Func GetHasDegenHex($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0400) > 0
EndFunc   ;==>GetHasDegenHex

;~ Description: Tests if an agent is hexed. Accepts ID, Struct or Ptr
Func GetHasHex($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x0800) > 0
EndFunc   ;==>GetHasHex

;~ Description: Tests if an agent has a weapon spell. Accepts ID, Struct or Ptr
Func GetHasWeaponSpell($aAgent = -2)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 312, "long"), 0x8000) > 0
EndFunc   ;==>GetHasWeaponSpell
#EndRegion Effects

;	=== TypeMap ===
;~ Description: Tests if an agent is a boss. Accepts ID, Struct or Ptr
Func GetIsBoss($aAgent)
	Return BitAND(MemoryRead(GetAgentPtr($aAgent) + 344, "long"), 0x0400) > 0
EndFunc   ;==>GetIsBoss

;~ Description: Returns the primary profession of an agent (heroes and PvP enemies only).
Func GetPrimaryProfession($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 266, "byte")
EndFunc   ;==>GetPrimaryProfession

;~ Description: Returns the secondary profession of an agent (heroes and PvP enemies only).
Func GetSecondaryProfession($aAgent = -2)
	Return MemoryRead(GetAgentPtr($aAgent) + 267, "byte")
EndFunc   ;==>GetSecondaryProfession

;~ Description: Returns number of agents currently loaded.
Func GetMaxAgents()
	Return MemoryRead($mMaxAgents)
EndFunc   ;==>GetMaxAgents

#Region Interaction
;~ Description: Changes WeaponSet with CtoS packet
Func SwitchWeaponSet($aWeaponSet)
    Return SendPacket(0x8, 0x31, $aWeaponSet)
EndFunc   ;==>SwitchWeaponSet

;~ Func DropHeroBundle($aHeroNumber)
;~ 	SendPacket(0x8, 0x19, GetHeroID($aHeroNumber)) ; Drop bundle
;~ EndFunc   ;==>DropHeroBundle
#EndRegion Interaction

#Region Distance
;~ Description: Returns the distance between two coordinate pairs.
Func ComputeDistance($aX1, $aY1, $aX2, $aY2)
	Return Sqrt(($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2)
EndFunc   ;==>ComputeDistance

;~ Description: Returns the square of the distance between two coordinate pairs.
Func ComputePseudoDistance($aX1, $aY1, $aX2, $aY2)
	Return ($aX1 - $aX2) ^ 2 + ($aY1 - $aY2) ^ 2
EndFunc   ;==>ComputePseudoDistance

;~ Description: Returns the distance between two agents.
Func GetDistance($aAgent1 = GetNearestAgentPtr(-2), $aAgent2 = GetAgentPtr(-2))
	Return Sqrt((X($aAgent1) - X($aAgent2)) ^ 2 + (Y($aAgent1) - Y($aAgent2)) ^ 2)
EndFunc   ;==>GetDistance

;~ Description: Return the square of the distance between two agents.
Func GetPseudoDistance($aAgent1 = GetNearestAgentPtr(-2), $aAgent2 = GetAgentPtr(-2))
	Return (X($aAgent1) - X($aAgent2)) ^ 2 + (Y($aAgent1) - Y($aAgent2)) ^ 2
EndFunc   ;==>GetPseudoDistance

;~ Description: Returns the distance of agent from a waypoint.
Func GetDistanceToXY($aX, $aY, $aAgent = GetAgentPtr(-2))
	Return Sqrt(($aX - X($aAgent)) ^ 2 + ($aY - Y($aAgent)) ^ 2)
EndFunc   ;==>GetDistanceToXY

;~ Description: Returns the square of the distance of agent from a waypoint.
Func GetPseudoDistanceToXY($aX, $aY, $aAgent = GetAgentPtr(-2))
	Return ($aX - X($aAgent)) ^ 2 + ($aY - Y($aAgent)) ^ 2
EndFunc   ;==>GetPseudoDistanceToXY

; Description: returns whether an Agent is moving away from a waypoint
Func GetIsMovingAwayFromXY($aX, $aY, $aAgent)
	$Distance = GetDistanceToXY($aX, $aY, $aAgent)
	Sleep(50)
	If GetDistanceToXY($aX, $aY, $aAgent) > $Distance Then Return True
	Return False
EndFunc   ;==>GetIsMovingAwayFromXY

;~ Description: Checks if a point is within a polygon defined by an array
Func GetIsPointInPolygon($aAreaCoords, $aPosX = 0, $aPosY = 0)
	Local $lPosition
	Local $lEdges = UBound($aAreaCoords)
	Local $lOddNodes = False
	If $lEdges < 3 Then Return False
	If $aPosX = 0 Then
		$aPosX = X(-2)
		$aPosY = Y(-2)
	EndIf
	$J = $lEdges - 1
	For $i = 0 To $lEdges - 1
		If (($aAreaCoords[$i][1] < $aPosY And $aAreaCoords[$J][1] >= $aPosY) _
				Or ($aAreaCoords[$J][1] < $aPosY And $aAreaCoords[$i][1] >= $aPosY)) _
				And ($aAreaCoords[$i][0] <= $aPosX Or $aAreaCoords[$J][0] <= $aPosX) Then
			If ($aAreaCoords[$i][0] + ($aPosY - $aAreaCoords[$i][1]) / ($aAreaCoords[$J][1] - $aAreaCoords[$i][1]) * ($aAreaCoords[$J][0] - $aAreaCoords[$i][0]) < $aPosX) Then
				$lOddNodes = Not $lOddNodes
			EndIf
		EndIf
		$J = $i
	Next
	Return $lOddNodes
EndFunc   ;==>GetIsPointInPolygon
#EndRegion Distance

#Region Special
;~Returns whether a player ID corresponds to a ritual
Func IsSpiritAgent($aAgent)
	Local $lPlayerNumber = MemoryRead(GetAgentPtr($aAgent) + 244, "word")
	Switch $lPlayerNumber
		Case 2870 To 2888, 4230 To 4239, 5711 To 5719, 5776 ; nature rituals
			Return True
		Case 4209 To 4231, 5720, 5721, 5723, 5853, 5854 ; binding rituals
			Return True
		Case 5848 To 5850 ; EVA, spirits
			Return True
	EndSwitch
	Return False
EndFunc   ;==>IsSpiritAgent

;~Returns whether a player ID corresponds to a minion
Func IsMinionAgent($aAgent)
	Local $lPlayerNumber = MemoryRead(GetAgentPtr($aAgent) + 244, "word")
	Switch $lPlayerNumber
		Case 2226 To 2228 ; bone minions
			Return True
		Case 3962, 3963, 4205, 4206 ; corrupted scale, corrupted spore, flesh golem, vampiric horror
			Return True
		Case 5709, 5710 ; shambling horror, jagged horror
			Return True
	EndSwitch
	Return False
EndFunc   ;==>IsMinionAgent

;~ Checks if Agent is a Sensali. Used for FeatherBot.
Func IsSensali($aAgent)
	Local $lPlayerNumber = MemoryRead(GetAgentPtr($aAgent) + 244, "word")
	Switch $lPlayerNumber
		Case $model_id_sensali_claw, $model_id_sensali_darkfeather, $model_id_sensali_cutter
			Return True
	EndSwitch
	Return False
EndFunc ;==>IsSensali

;~ Checks if Agent is an enemy in CoF farm.
Func IsCofEnemy($aAgent)
	Local $lPlayerNumber = MemoryRead(GetAgentPtr($aAgent) + 244, "word")
	Switch $lPlayerNumber
		Case $model_id_crypt_ghoul, $model_id_crypt_slasher
			Return True
		Case $model_id_crypt_wraith, $model_id_crypt_banshee
			Return True
		Case $model_id_shock_phantom, $model_id_ash_phantom
			Return True
		Case $model_id_servant_of_murakai
			Return True
	EndSwitch
	Return False
EndFunc ;==>IsCofEnemy

;~Returns whether a player ID corresponds to a frost worm
Func IsFrostWorm($aAgent)
	$lPlayerNumber = MemoryRead(GetAgentPtr($aAgent) + 244, "word")
	Switch $lPlayerNumber
		Case 6491 To 6492, 6929 To 6932
			Return True
	EndSwitch
	Return False
EndFunc   ;==>IsFrostWorm
#EndRegion Special

#Region Minions & Spirits
; Returns the an array of spirit and minion allies I control
Func GetMinionPtrArray()
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x3C]
	Return MemoryReadPtr($mBasePointer, $lOffset)
EndFunc   ;==>GetMinionPtrArray

; Returns the number of minions in range of an agent
Func GetNumberOfMinionAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x05, $aRange)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfMinionAllies

; Returns the number of minions I control in range of an agent
Func GetMyMinionCount($aRange = 5000)
	Local $lCount, $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x05, $aRange)
	For $i = 1 To $lAgentPtrArray[0]
		If MemoryRead($lAgentPtrArray[$i] + 231, "Byte") <> GetMyID() Then ContinueLoop ; minion owner
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetMyMinionCount

; Returns the number of spirits in range of an agent
Func GetNumberOfSpiritAllies($aRange = 5000)
	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, 0x04, $aRange)
	Return UBound($lAgentPtrArray) - 1
EndFunc   ;==>GetNumberOfSpiritAllies

; Returns the number of spirits I control
Func GetMySpiritCount_()
	Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x3C]
	Local $lPtr = MemoryReadPtr($mBasePointer, $lOffset)
	Return MemoryRead($lPtr[0], 'long') - 1
EndFunc   ;==>GetMySpiritCount

Func GetMySpiritCount($aRange = 2500)
	Local $lCount, $MinionPtrArray = GetMinionPtrArray()
	;_ArrayDisplay($MinionPtrArray)
	If $MinionPtrArray = 0 Then Return 0
	For $i = 1 To $MinionPtrArray[0]
		If GetDistance($MinionPtrArray[$i]) > $aRange Then ContinueLoop
		$lCount += 1
	Next
	Return $lCount
EndFunc   ;==>GetMySpiritCount_

; Returns the number of offensive and/or defensive ritualist spirits in range of an agent
;~ Func GetNumberOfSpirits($aRange = 5000, $Offensive = True, $Defensive = True)
;~ 	Local $lCount = 0
;~ 	Local $lAgentPtrArray = GetAgentPtrArray(3, 0xDB, $allegiance_spirit, $aRange)

;~ 	For $i = 1 To $lAgentPtrArray[0]
;~ 		Switch MemoryRead($lAgentPtrArray[$i] + 244, 'word')    ; check on player number
;~ 			Case $model_id_Empowerment, $model_id_Rejuvenation, $model_id_Displacement, $model_id_Life, $model_id_Preservation _
;~ 					, $model_id_Recuperation, $model_id_Shelter, $model_id_Union, $model_id_Restoration
;~ 				If $Defensive Then $lCount += 1
;~ 			Case $model_id_Agony, $model_id_Anger, $model_id_Anguish, $model_id_Bloodsong, $model_id_Destruction _
;~ 					, $model_id_Earthbind, $model_id_Hate, $model_id_Pain, $model_id_Suffering, $model_id_Vampirism
;~ 				If $Offensive Then $lCount += 1
;~ 			Case $model_id_Dissonance, $model_id_Disenchantment, $model_id_Shadowsong, $model_id_Wanderlust
;~ 				$lCount += 1
;~ 		EndSwitch
;~ 	Next
;~ 	Return $lCount
;~ EndFunc   ;==>GetNumberOfSpirits

; Returns the number of ritualist pressure spirits in range of an agent
;~ Func NumberOfPressureSpirits($aRange = 5000)
;~ 	Return GetNumberOfSpirits($aRange, True, False)
;~ EndFunc   ;==>NumberOfPressureSpirits

;~ ; Returns the number of ritualist survival spirits in range of an agent
;~ Func NumberOfSurvivalSpirits($aRange = 5000)
;~ 	Return GetNumberOfSpirits($aRange, False, True)
;~ EndFunc   ;==>NumberOfSurvivalSpirits
#EndRegion Minions & Spirits