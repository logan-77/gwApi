#cs
Functions for retrieving information from the Agent Struct.
#ce
#include-once
;~ Case 0: all agents
;~ Case 1: agents by: $iType (use only this for 0x200/0x400)
;~ Case 2: agents by: $iType + $iAllegiance
;~ Case 3: agents by $iType + $iAllegiance + exclude Minions/Spirits + optional: PlayerNumber, Effect, $aRange ($iAgent or $aX/$aY)
;~ Case 5: only for Feather Farm
;~ Case 6: only for CoF
;~ GetAgentPtrArray: Mode, Type, Allegiance, Range, Agent, PlayerNumber, Effect, x, y
Func GetAgentPtrArray($iMode = 0, $iType = 0xDB, $iAllegiance = 3, $aRange = 1320, $iAgent = Agent_GetAgentPtr(-2), $aPlayerNumber = 0, $aEffect = 0, $aX = X($iAgent), $aY = Y($iAgent))
    Local $iMaxAgents = Agent_GetMaxAgents()
    Local $lAgentPtrStruct = DllStructCreate("ptr[" & $iMaxAgents & "]")
    DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", "handle", $g_h_GWProcess, "ptr", Memory_Read($g_p_AgentBase), "struct*", $lAgentPtrStruct, "ulong_ptr", $iMaxAgents * 4, "ulong_ptr*", 0)
    Local $lTempPtr, $iModelID
    Local $lAgentArray[$iMaxAgents + 1]
    $lAgentArray[0] = 0

    For $i = 1 To $iMaxAgents
        $lTempPtr = DllStructGetData($lAgentPtrStruct, 1, $i)
        If $lTempPtr = 0 Then ContinueLoop
        If $iMode >= 1 And Memory_Read($lTempPtr + 0x9C, 'long') <> $iType Then ContinueLoop
        If $iMode >= 2 And Memory_Read($lTempPtr + 0x1B5, 'byte') <> $iAllegiance Then ContinueLoop
        If $iMode >= 3 Then
            If $aEffect <> 0x0010 And GetIsDead($lTempPtr) Then ContinueLoop ; HP > 0
            If $aRange <> 0 And GetDistanceToXY($aX, $aY, $lTempPtr) > $aRange Then ContinueLoop ; is in $aRange
            
            If $iAllegiance = 0x03 Or $aPlayerNumber <> 0 Then
                $iModelID = Memory_Read($lTempPtr + 0xF4, "short")
            EndIf
            If $aPlayerNumber <> 0 And $aPlayerNumber <> $iModelID Then ContinueLoop ; has PlayerNumber
            If $iAllegiance = 0x3 And (IsMinionAgent($iModelID) Or IsSpiritAgent($iModelID)) Then ContinueLoop

            If $aEffect <> 0 And Not BitAND(Memory_Read($lTempPtr + 0x13C, 'dword'), $aEffect) Then ContinueLoop ; has $aEffect
        EndIf
        If $iMode = 5 And Not IsSensali($iModelID) Then ContinueLoop ; feather bot
        If $iMode = 6 And Not IsCofEnemy($iModelID) Then ContinueLoop ; cof bot

        $lAgentArray[0] += 1
        $lAgentArray[$lAgentArray[0]] = $lTempPtr
    Next
    ReDim $lAgentArray[$lAgentArray[0] + 1]
    Return $lAgentArray
EndFunc ;==>GetAgentPtrArray

#Region AgentControls
; Returns the number of living enemies in range of an agent excluding spawned creatures. optional: PlayerNumber
Func GetNumberOfEnemiesNearAgent($iAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, $iAgent, $aPlayerNumber)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfEnemiesNearAgent

; Returns the number of living enemies in range of an agent excluding spawned creatures. optional: PlayerNumber
Func GetNumberOfEnemiesNearAgent2(ByRef $aAgentPtrArray, $iAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
    Local $lAgentPtr = Agent_GetAgentPtr($iAgent), $lCount = 0
    
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
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, -2, $aPlayerNumber, 0, $aX, $aY)
    Return UBound($aAgentPtr) - 1
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
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, Agent_GetAgentPtr(-2), 0, 0x0010)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfDeadAllies

;~ Returns the number of living allies in range of an agent. (include npc, pet, spirit)
Func GetNumberOfAlliesInRangeOfAgent($iAgent = -2, $aRange = 1250)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, $iAgent)
    Return UBound($aAgentPtr) - 1
EndFunc ;==>GetNumberOfAlliesInRangeOfAgent

; Returns the number of allies with a condition
Func GetNumberOfConditionedAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, Agent_GetAgentPtr(-2), 0, 0x0002)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfConditionedAllies

; Returns the number of bleeding allies
Func GetNumberOfBleedingAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, Agent_GetAgentPtr(-2), 0, 0x0001)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfBleedingAllies

; Returns the number of poisoned allies
Func GetNumberOfPoisonedAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, Agent_GetAgentPtr(-2), 0, 0x0040)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfPoisonedAllies

; Returns the number of deep-wounded allies
Func GetNumberOfDeepWoundedAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, $aRange, Agent_GetAgentPtr(-2), 0, 0x0020)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfDeepWoundedAllies

;~ GetAgentPtrArray: Mode, Type, Allegiance, Range, Agent, PlayerNumber, Effect, x, y
;~ Description: Returns Highest HP Enemy in Range. optional: PlayerNumber
Func GetHighestHPEnemyPtrToAgent($iAgent = -2, $aRange = 1250, $aPlayerNumber = 0)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x03, $aRange, $iAgent, $aPlayerNumber)
    Local $lHighestHP = 0, $lHighestHPAgentPtr = 0, $lHP
    
    For $i = 1 To $aAgentPtr[0]
        $lHP = GetHP($aAgentPtr[$i])
        If $lHP > $lHighestHP Then
            $lHighestHP = $lHP
            $lHighestHPAgentPtr = $aAgentPtr[$i]
        EndIf
    Next
    Return $lHighestHPAgentPtr
EndFunc ;==>GetHighestHPEnemyPtr

Func GetAgentPtrByPlayerNumber($aPlayerNumber, $aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(1, 0xDB)
    For $i = 1 To $aAgentPtr[0]
        If GetIsDead($aAgentPtr[$i]) Then ContinueLoop
        If GetDistance($aAgentPtr[$i]) > $aRange Then ContinueLoop
        If Memory_Read($aAgentPtr[$i] + 0xF4, "short") = $aPlayerNumber Then Return $aAgentPtr[$i]
    Next
    Return 0
EndFunc   ;==>GetAgentPtrByPlayerNumber
#EndRegion AgentControls

#Region GetNearestAgentPtr
;~ Description: Returns Pointer to nearest agent to an Agent or XY. optional: PlayerNumber
;~ GetNearestAgentPtr: Agent, Type, Allegiance, PlayerNumber, X, Y
Func GetNearestAgentPtr($iAgent = -2, $iType = 0xDB, $iAllegiance = 0, $aPlayerNumber = 0, $aX = X($iAgent), $aY = Y($iAgent))
    Local $pAgent = Agent_GetAgentPtr($iAgent), $pNearestAgent = 0, $iNearestDistance = 100000000
    Local $aAgentPtr, $iDistance, $iModelID
    Switch $iType
        Case 0xDB
            $aAgentPtr = GetAgentPtrArray(2, $iType, $iAllegiance)
        Case 0x200, 0x400
            $aAgentPtr = GetAgentPtrArray(1, $iType)
    EndSwitch

    For $i = 1 To $aAgentPtr[0]
        If $aAgentPtr[$i] = $pAgent Then ContinueLoop
        If $iType = 0xDB And GetIsDead($aAgentPtr[$i]) Then ContinueLoop

        If $iAllegiance = 0x03 Or $aPlayerNumber <> 0 Then
            $iModelID = Memory_Read($aAgentPtr[$i] + 0xF4, "short")
        EndIf
        If $aPlayerNumber <> 0 And $iModelID <> $aPlayerNumber Then ContinueLoop
        If $iAllegiance = 0x03 And (IsMinionAgent($iModelID) Or IsSpiritAgent($iModelID)) Then ContinueLoop
        
        $iDistance = GetPseudoDistanceToXY($aX, $aY, $aAgentPtr[$i])
        If $iDistance < $iNearestDistance Then
            $pNearestAgent = $aAgentPtr[$i]
            $iNearestDistance = $iDistance
        EndIf
    Next
    Return $pNearestAgent
EndFunc ;==>GetNearestAgentPtr

;~ Returns distance of nearest Agent. param: Allegiance
Func GetNearestDistance($iAgent = -2, $iAllegiance = 3)
    Local $pNearestAgent = GetNearestAgentPtr($iAgent, 0xDB, $iAllegiance)
    If $pNearestAgent <> 0 Then
        Return GetDistance($pNearestAgent, $iAgent)
    Else
        Return 10000
    EndIf
EndFunc   ;==>GetNearestDistance

;~ Description: Returns pointer variable for the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent($iAgent = -2, $aPlayerNumber = 0)
    Return GetNearestAgentPtr($iAgent, 0xDB, 0x03, $aPlayerNumber)
EndFunc ;==>GetNearestEnemyPtrToAgent

;~ Description: Returns pointer variable for the nearest enemy to an agent.
Func GetNearestEnemyPtrToAgent2(ByRef $aAgentPtrArray, $iAgent = -2, $aPlayerNumber = 0) 
    Local $pAgent = Agent_GetAgentPtr($iAgent), $pNearestAgent = 0, $iNearestDistance = 100000000, $iDistance
    For $i = 1 To $aAgentPtrArray[0]
        If GetIsDead($aAgentPtrArray[$i]) Then ContinueLoop
        If $aPlayerNumber <> 0 And Memory_Read($aAgentPtrArray[$i] + 0xF4, "short") <> $aPlayerNumber Then ContinueLoop
        $iDistance = GetPseudoDistance($aAgentPtrArray[$i], $pAgent)
        If $iDistance < $iNearestDistance Then
            $iNearestDistance = $iDistance
            $pNearestAgent = $aAgentPtrArray[$i]
        EndIf
    Next
    Return $pNearestAgent
EndFunc ;==>GetNearestEnemyPtrToAgent

Func GetNearestEnemyPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
    Return GetNearestAgentPtr(-2, 0xDB, 0x03, $aPlayerNumber, $aX, $aY)
EndFunc ;==>GetNearestEnemyPtrToXY

;~ Description: Returns pointer to the nearest NPC to an agent. optional: PlayerNumber
Func GetNearestNPCPtrToAgent($iAgent = -2, $aPlayerNumber = 0)
    Return GetNearestAgentPtr($iAgent, 0xDB, 0x06, $aPlayerNumber)
EndFunc   ;==>GetNearestNPCPtrToAgent

;~ Description: Returns pointer to the nearest NPC to XY. optional: PlayerNumber
Func GetNearestNPCPtrToXY($aX = X(-2), $aY = Y(-2), $aPlayerNumber = 0)
    Return GetNearestAgentPtr(-2, 0xDB, 0x06, $aPlayerNumber, $aX, $aY)
EndFunc   ;==>GetNearestNPCPtrToXY

;~ Description: Returns the pointer variable for the nearest signpost to an agent.
Func GetNearestSignpostPtrToAgent($iAgent = -2)
    Return GetNearestAgentPtr($iAgent, 0x200)
EndFunc   ;==>GetNearestSignpostPtrToAgent

;~ Description: Returns the pointer variable for the nearest signpost to a set of coordinates.
Func GetNearestSignpostPtrToXY($aX, $aY)
    Return GetNearestAgentPtr(-2, 0x200, 0, 0, $aX, $aY)
EndFunc   ;==>GetNearestSignpostPtrToXY

;~ Description: Returns pointer variable for the nearest ally to an agent.
Func GetNearestAllyPtrToAgent($iAgent = -2)
    Return GetNearestAgentPtr($iAgent, 0xDB, 0x01)
EndFunc   ;==>GetNearestAllyPtrToAgent

;~ Description: Returns pointer variable for the nearest dead ally to an agent.
Func GetNearestDeadAllyPtrToAgent($iAgent = -2)
    Local $lPtr = Agent_GetAgentPtr($iAgent), $pNearestAgent = 0, $iDistance, $iNearestDistance = 100000000
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x01, 1320, $lPtr, 0, 0x0010)

    For $i = 1 To $aAgentPtr[0]
        If $aAgentPtr[$i] = $lPtr Then ContinueLoop

        $iDistance = GetPseudoDistance($aAgentPtr[$i], $lPtr)
        If $iDistance < $iNearestDistance Then
            $pNearestAgent = $aAgentPtr[$i]
            $iNearestDistance = $iDistance
        EndIf
    Next
    Return $pNearestAgent
EndFunc   ;==>GetNearestDeadAllyPtrToAgent

;~ Description: Returns pointer variable for the nearest spirit ally to an agent.
Func GetNearestSpiritPtrToAgent($iAgent = -2)
    Return GetNearestAgentPtr($iAgent, 0xDB, 0x04)
EndFunc   ;==>GetNearestSpiritPtrToAgent

;~ Description: Returns pointer variable for the nearest minion ally to an agent.
Func GetNearestMinionAllyToAgent($iAgent = -2)
    Return GetNearestAgentPtr($iAgent, 0xDB, 0x05)
EndFunc   ;==>GetNearestMinionAllyToAgent
#EndRegion GetNearestAgentPtr

#Region AgentInfo
;~ Description: Returns the ID of an Agent
Func ID($iAgent = Agent_GetAgentPtr(-2))
    Select
        Case $iAgent = -2
            Return Agent_GetMyID()
        Case $iAgent = -1
            Return Agent_GetCurrentTarget()
        Case IsPtr($iAgent)
            Return Memory_Read($iAgent + 0x2C, 'long')
        Case IsDllStruct($iAgent)
            Return DllStructGetData($iAgent, 'ID')
        Case Else
            Return $iAgent
    EndSelect
EndFunc ;==>ID

;~ Description: Test if an agent exists.
Func GetAgentExists($iAgent)
    Return (Agent_GetAgentPtr($iAgent) > 0 And ID($iAgent) < Agent_GetMaxAgents())
EndFunc ;==>GetAgentExists

;~ Description: Agents X Location
Func X($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x74, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_X[0], $GC_I_OFFSET_AGENT_X[1])
EndFunc ;==>X

;~ Description: Agents X Location
Func GetAgentX($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x74, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_X[0], $GC_I_OFFSET_AGENT_X[1])
EndFunc ;==>GetAgentX

;~ Description: Agents Movevement on the X axis
Func MoveX($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0xA0, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MOVE_X[0], $GC_I_OFFSET_AGENT_MOVE_X[1])
EndFunc ;==>MoveX

;~ Description: Agents Movevement on the X axis
Func GetAgentMoveX($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0xA0, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MOVE_X[0], $GC_I_OFFSET_AGENT_MOVE_X[1])
EndFunc ;==>GetAgentMoveX

;~ Description: Agents Y Location
Func Y($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x78, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_Y[0], $GC_I_OFFSET_AGENT_Y[1])
EndFunc ;==>Y

;~ Description: Agents Y Location
Func GetAgentY($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x78, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_Y[0], $GC_I_OFFSET_AGENT_Y[1])
EndFunc ;==>GetAgentY

;~ Description: Agents Movevement on the Y axis
Func MoveY($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0xA4, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MOVE_Y[0], $GC_I_OFFSET_AGENT_MOVE_Y[1])
EndFunc ;==>MoveY

;~ Description: Agents Movevement on the Y axis
Func GetAgentMoveY($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0xA4, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MOVE_Y[0], $GC_I_OFFSET_AGENT_MOVE_Y[1])
EndFunc ;==>MoveY

;~ Description: Agents X and Y Location
Func XY($iAgent = -2)
    Local $lLocation[2]
    Local $lPtr = Agent_GetAgentPtr($iAgent)
    
    $lLocation[0] = X($lPtr)
    $lLocation[1] = Y($lPtr)
    Return $lLocation
EndFunc   ;==>XY

;~ Description: Agents Z Location
Func Z($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x30, 'float')
EndFunc ;==>Z

;~ Description: Returns Agents PlayerNumber/ModelID
Func GetPlayerNumber($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MODEL_ID[0], $GC_I_OFFSET_AGENT_MODEL_ID[1])
EndFunc ;==>GetPlayerNumber

;~ Description: Returns Agents PlayerNumber/ModelID
Func GetAgentModelID($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MODEL_ID[0], $GC_I_OFFSET_AGENT_MODEL_ID[1])
EndFunc ;==>GetAgentModelID

;~ Description: Returns a player's name.
Func GetPlayerName($iAgent = -2)
    Local $lLogin = Memory_Read(Agent_GetAgentPtr($iAgent) + 0x184, "dword")
    Local $lOffset[6] = [0, 0x18, 0x2C, 0x80C, 0x50 * $lLogin + 0x28, 0]
    Local $lReturn = Memory_ReadPtr($g_p_BasePointer, $lOffset, 'wchar[20]')
    Return $lReturn[1]
EndFunc   ;==>GetPlayerName

;~ Description: Returns health of an agent as % of max HP
Func GetHP($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x134, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_HP_PERCENT[0], $GC_I_OFFSET_AGENT_HP_PERCENT[1])
EndFunc ;==>GetHP

;~ Description: Returns health of an agent as % of max HP
Func GetAgentHpPercent($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x134, 'float')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_HP_PERCENT[0], $GC_I_OFFSET_AGENT_HP_PERCENT[1])
EndFunc   ;==>GetHP

Func GetAgentMaxHP($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MAX_HP[0], $GC_I_OFFSET_AGENT_MAX_HP[1])
EndFunc ;==>GetAgentMaxHP

;~ Description: Returns health of an agent. Returns 0 for NPC's
Func GetHealth($iAgent = -2)
    Local $lPtr = Agent_GetAgentPtr($iAgent)
    Local $nHpPercent = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_HP_PERCENT[0], $GC_I_OFFSET_AGENT_HP_PERCENT[1])
    Local $nMaxHp = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_MAX_HP[0], $GC_I_OFFSET_AGENT_MAX_HP[1])
    Return $nHpPercent * $nMaxHp
EndFunc ;==>GetHealth

;~ Description: Returns health of an agent. Returns 0 for NPC's
;~ Func GetAgentHealth($iAgent = -2)
;~     Local $lPtr = Agent_GetAgentPtr($iAgent)
;~     Local $nHpPercent = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_HP_PERCENT[0], $GC_I_OFFSET_AGENT_HP_PERCENT[1])
;~     Local $nMaxHp = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_MAX_HP[0], $GC_I_OFFSET_AGENT_MAX_HP[1])
;~     Return $nHpPercent * $nMaxHp
;~ EndFunc ;==>GetAgentHealth

;~ Description: Returns the level of an agent.
Func GetLevel($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x110, "byte")
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_LEVEL[0], $GC_I_OFFSET_AGENT_LEVEL[1])
EndFunc ;==>GetLevel

;~ Description: Returns the team of an agent.
Func GetTeam($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_TEAM[0], $GC_I_OFFSET_AGENT_TEAM[1])
EndFunc ;==>GetTeam

;~ Description: Returns the energy pips of an agent.
Func GetAgentEnergyPips($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_ENERGY_PIPS[0], $GC_I_OFFSET_AGENT_ENERGY_PIPS[1])
EndFunc ;==>GetEnergyPips

;~ Description: Returns the energy pips of an agent.
Func GetAgentEnergyPercent($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_ENERGY_PERCENT[0], $GC_I_OFFSET_AGENT_ENERGY_PERCENT[1])
EndFunc ;==>GetAgentEnergyPercent

;~ Description: Returns the energy pips of an agent.
Func GetAgentEnergyMax($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_MAX_ENERGY[0], $GC_I_OFFSET_AGENT_MAX_ENERGY[1])
EndFunc ;==>GetAgentEnergyMax

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetEnergy($iAgent = -2)
    Local $lPtr = Agent_GetAgentPtr($iAgent)
    Local $nEnergyPercent = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_ENERGY_PERCENT[0], $GC_I_OFFSET_AGENT_ENERGY_PERCENT[1])
    Local $nMaxEnergy = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_MAX_ENERGY[0], $GC_I_OFFSET_AGENT_MAX_ENERGY[1])
    Return $nEnergyPercent * $nMaxEnergy
EndFunc ;==>GetEnergy

;~ Description: Returns energy of an agent. (Only self/heroes)
Func GetAgentEnergyCurrent($iAgent = -2)
    Local $lPtr = Agent_GetAgentPtr($iAgent)
    Local $nEnergyPercent = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_ENERGY_PERCENT[0], $GC_I_OFFSET_AGENT_ENERGY_PERCENT[1])
    Local $nMaxEnergy = Memory_Read($lPtr + $GC_I_OFFSET_AGENT_MAX_ENERGY[0], $GC_I_OFFSET_AGENT_MAX_ENERGY[1])
    Return $nEnergyPercent * $nMaxEnergy
EndFunc ;==>GetEnergy

;~ Description: Returns the allegiance of an agent.
Func GetAllegiance($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_ALLEGIANCE[0], $GC_I_OFFSET_AGENT_ALLEGIANCE[1])
EndFunc   ;==>GetAllegiance

;~ Description: Returns the skill currently being cast by an agent.
Func GetSkillID($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_SKILL[0], $GC_I_OFFSET_AGENT_SKILL[1])
EndFunc ;==>GetSkillID

;~ Description: Returns the skill currently being cast by an agent.
Func GetAgentSkillID($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_SKILL[0], $GC_I_OFFSET_AGENT_SKILL[1])
EndFunc ;==>GetAgentSkillID

;~ Description: Returns the weapon type of an agent.
Func GetWeaponType($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_WEAPON_TYPE[0], $GC_I_OFFSET_AGENT_WEAPON_TYPE[1])
EndFunc ;==>GetWeaponType

;~ Description: Returns the weapon item ID of an agent.
Func GetWeaponItemID($iAgent)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_WEAPON_ITEM_ID[0], $GC_I_OFFSET_AGENT_WEAPON_ITEM_ID[1])
EndFunc ;==>GetWeaponItemID

;~ Description: Returns the weapon item type of an agent.
Func GetWeaponItemType($iAgent)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_WEAPON_ITEM_TYPE[0], $GC_I_OFFSET_AGENT_WEAPON_ITEM_TYPE[1])
EndFunc ;==>GetWeaponItemType

;~ Description: Returns the offhand item ID of an agent.
Func GetOffhandItemID($iAgent)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_OFFHAND_ITEM_ID[0], $GC_I_OFFSET_AGENT_OFFHAND_ITEM_ID[1])
EndFunc ;==>GetOffhandItemID

;~ Description: Returns the offhand item type of an agent.
Func GetOffhandItemType($iAgent)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_OFFHAND_ITEM_TYPE[0], $GC_I_OFFSET_AGENT_OFFHAND_ITEM_TYPE[1])
EndFunc ;==>GetOffhandItemType

;~ Description: Tests if an agent is casting.
Func GetIsCasting($iAgent = -2)
    Return GetAgentSkillID($iAgent) <> 0
EndFunc   ;==>GetIsCasting

;~ Description: Tests if an agent is moving.
Func GetIsMoving($iAgent = Agent_GetAgentPtr(-2), $aTimer = 0)
    If MoveX($iAgent) <> 0 Or MoveY($iAgent) <> 0 Then Return True
    If $aTimer > 0 Then
        Sleep($aTimer)
        If MoveX($iAgent) <> 0 Or MoveY($iAgent) <> 0 Then Return True
    EndIf
    Return False
EndFunc   ;==>GetIsMoving

;~ Description: Returns the primary profession of an agent (heroes and PvP enemies only).
Func GetPrimaryProfession($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x10E, "byte")
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_PRIMARY[0], $GC_I_OFFSET_AGENT_PRIMARY[1])
EndFunc   ;==>GetPrimaryProfession

;~ Description: Returns the secondary profession of an agent (heroes and PvP enemies only).
Func GetSecondaryProfession($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x10F, "byte")
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_SECONDARY[0], $GC_I_OFFSET_AGENT_SECONDARY[1])
EndFunc   ;==>GetSecondaryProfession

; === Type ===
;~ Description: Tests if an agent is living.
Func GetIsLiving($iAgent = -2)
    Return GetAgentType($iAgent) = 0xDB
EndFunc   ;==>GetIsLiving

;~ Description: Tests if an agent is a signpost/chest/etc.
Func GetIsGadget($iAgent = -2)
    Return GetAgentType($iAgent) = 0x200
EndFunc   ;==>GetIsStatic

;~ Description: Tests if an agent is an item.
Func GetIsItem($iAgent = -2)
    Return GetAgentType($iAgent) = 0x400
EndFunc   ;==>GetIsMovable

;~ Description: Returns the Type of the Agent. 0xDB/0x200/0x400
Func GetType($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x9C, 'long')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_TYPE[0], $GC_I_OFFSET_AGENT_TYPE[1])
EndFunc ;==>GetType

;~ Description: Returns the Type of the Agent. 0xDB/0x200/0x400
Func GetAgentType($iAgent = -2)
    ;~ Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x9C, 'long')
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + $GC_I_OFFSET_AGENT_TYPE[0], $GC_I_OFFSET_AGENT_TYPE[1])
EndFunc ;==>GetAgentType

#Region Model State
; NOT reliable with disable render
;~ Description: Tests if an agent is knocked down.
Func GetIsKnocked($iAgent = -2)
    Return Memory_Read(Agent_GetAgentPtr($iAgent) + 0x158, "dword") = 0x450
EndFunc   ;==>GetIsKnocked

;~ Description: Tests if an agent is attacking.
Func GetIsAttacking($iAgent = -2)
    Local $lModelState = Memory_Read(Agent_GetAgentPtr($iAgent) + 0x158, "dword")
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
; === Effects ====
;~ Description: Tests if an agent is dead.
Func GetIsDead($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0010) > 0
EndFunc   ;==>GetIsDead

;~ Description: Tests if an agent has a condition. Accepts ID, Struct or Ptr
Func GetHasCondition($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0002) > 0
EndFunc   ;==>GetHasCondition

;~ Description: Tests if an agent is bleeding.
Func GetIsBleeding($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0001) > 0
EndFunc   ;==>GetIsBleeding

;~ Description: Tests if self or other hero is crippled - cannot use for enemies or other human players
Func GetIsCrippled($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0008) > 0 ; check vs GwAu3
EndFunc   ;==>GetIsCrippled

;~ Description: Tests if an agent has a deep wound. Accepts ID, Struct or Ptr
Func GetHasDeepWound($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0020) > 0
EndFunc   ;==>GetHasDeepWound

;~ Description: Tests if an agent is poisoned. Accepts ID, Struct or Ptr
Func GetIsPoisoned($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, 'dword'), 0x0040) > 0
EndFunc   ;==>GetIsPoisoned

;~ Description: Tests if an agent is enchanted. Accepts ID, Struct or Ptr
Func GetIsEnchanted($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0080) > 0
EndFunc   ;==>GetIsEnchanted

;~ Description: Tests if an agent has a degen hex. Accepts ID, Struct or Ptr
Func GetHasDegenHex($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0400) > 0
EndFunc   ;==>GetHasDegenHex

;~ Description: Tests if an agent is hexed. Accepts ID, Struct or Ptr
Func GetHasHex($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x0800) > 0
EndFunc   ;==>GetHasHex

;~ Description: Tests if an agent has a weapon spell. Accepts ID, Struct or Ptr
Func GetHasWeaponSpell($iAgent = -2)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x13C, "dword"), 0x8000) > 0
EndFunc   ;==>GetHasWeaponSpell
#EndRegion Effects

; === TypeMap ===
;~ Description: Tests if an agent is a boss. Accepts ID, Struct or Ptr
Func GetIsBoss($iAgent)
    Return BitAND(Memory_Read(Agent_GetAgentPtr($iAgent) + 0x15C, "dword"), 0x0400) > 0
EndFunc   ;==>GetIsBoss

#Region Distance
;~ Description: Returns the distance between two coordinate pairs.
Func ComputeDistance($nX1, $nY1, $nX2, $nY2)
    Local $dx = $nX1 - $nX2
    Local $dy = $nY1 - $nY2
    Return Sqrt(($dx * $dx) + ($dy * $dy))
EndFunc   ;==>ComputeDistance

;~ Description: Returns the square of the distance between two coordinate pairs.
Func ComputePseudoDistance($nX1, $nY1, $nX2, $nY2)
    Local $dx = $nX1 - $nX2
    Local $dy = $nY1 - $nY2
    Return (($dx * $dx) + ($dy * $dy))
EndFunc   ;==>ComputePseudoDistance

;~ Description: Returns the distance between two agents.
Func GetDistance($pAgent1 = GetNearestAgentPtr(-2), $pAgent2 = Agent_GetAgentPtr(-2))
    Local $dx = X($pAgent1) - X($pAgent2)
    Local $dy = Y($pAgent1) - Y($pAgent2)
    Return Sqrt(($dx * $dx) + ($dy * $dy))
EndFunc   ;==>GetDistance

;~ Description: Return the square of the distance between two agents.
Func GetPseudoDistance($pAgent1 = GetNearestAgentPtr(-2), $pAgent2 = Agent_GetAgentPtr(-2))
    Local $dx = X($pAgent1) - X($pAgent2)
    Local $dy = Y($pAgent1) - Y($pAgent2)
    Return (($dx * $dx) + ($dy * $dy))
EndFunc   ;==>GetPseudoDistance

;~ Description: Returns the distance of agent from a waypoint.
Func GetDistanceToXY($nX, $nY, $pAgent = Agent_GetAgentPtr(-2))
    Local $dx = $nX - X($pAgent)
    Local $dy = $nY - Y($pAgent)
    Return Sqrt(($dx * $dx) + ($dy * $dy))
EndFunc   ;==>GetDistanceToXY

;~ Description: Returns the square of the distance of agent from a waypoint.
Func GetPseudoDistanceToXY($nX, $nY, $pAgent = Agent_GetAgentPtr(-2))
    Local $dx = $nX - X($pAgent)
    Local $dy = $nY - Y($pAgent)
    Return (($dx * $dx) + ($dy * $dy))
EndFunc   ;==>GetPseudoDistanceToXY

; Description: returns whether an Agent is moving away from a waypoint
Func GetIsMovingAwayFromXY($aX, $aY, $iAgent)
    $Distance = GetDistanceToXY($aX, $aY, $iAgent)
    Sleep(50)
    If GetDistanceToXY($aX, $aY, $iAgent) > $Distance Then Return True
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
;~ Check if Agent is a Nature Ritual
Func IsNatureRitual($iModelID)
    Switch $iModelID
        Case 2925 To 2939, _
             4283, 4285 To 4290, _
             5766 To 5769
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsNatureRitual

;~ Check if Agent is a Binding Ritual
Func IsBindingRitual($iModelID)
    Switch $iModelID
        Case 5770 To 5774, _
             5904 To 5905, _
             4264 To 4282
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsBindingRitual

;~ Check if Agent is a Nature Ritual or a Binding Ritual
Func IsSpiritAgent($iModelID)
    Switch $iModelID
        Case 2925 To 2939, _
             4283, 4285 To 4290, _
             5766 To 5769 ; nature rituals
                Return True

        Case 5770 To 5774, _
             5904 To 5905, _
             4264 To 4282 ; binding rituals
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsSpiritAgent

;~ Check if Agent is a Minion
Func IsMinionAgent($iModelID)
    Switch $iModelID
        Case 2280 To 2282, _ ; bone minions
             4260 To 4261, _ ; flesh golem, vampiric horror
             5764 To 5765  ; shambling+jagged
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsMinionAgent

;~ Checks if Agent is a Sensali. Used for Feather Bot.
Func IsSensali($iModelID)
    Switch $iModelID
        Case $model_id_sensali_claw, _
             $model_id_sensali_darkfeather, _
             $model_id_sensali_cutter
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsSensali

;~ Check if Agent is from CoF. Used for CoF Bot.
Func IsCofEnemy($iModelID)
    Switch $iModelID
        Case $model_id_crypt_ghoul, $model_id_crypt_slasher, _
             $model_id_crypt_wraith, $model_id_crypt_banshee, _
             $model_id_shock_phantom, $model_id_ash_phantom, _
             $model_id_servant_of_murakai
                Return True
    EndSwitch
    Return False
EndFunc ;==>IsCofEnemy

;~Returns whether a player ID corresponds to a frost worm
Func IsFrostWorm($iModelID)
    Switch $iModelID
        Case 6491 To 6492, 6929 To 6932
            Return True
    EndSwitch
    Return False
EndFunc   ;==>IsFrostWorm
#EndRegion Special

#Region Minions & Spirits
; Returns the an array of spirit and minion allies I control
Func GetMinionPtrArray() ; Not tested yet
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x3C]
    Return Memory_ReadPtr($g_p_BasePointer, $lOffset)
EndFunc   ;==>GetMinionPtrArray

; Returns the number of minions in range of an agent
Func GetNumberOfMinionAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x05, $aRange)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfMinionAllies

; Returns the number of minions I control in range of an agent
Func GetMyMinionCount($aRange = 5000)
    Local $lCount, $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x05, $aRange)
    For $i = 1 To $aAgentPtr[0]
        If Memory_Read($aAgentPtr[$i] + 0x2C, "long") <> GetMyID() Then ContinueLoop ; minion owner
        $lCount += 1
    Next
    Return $lCount
EndFunc   ;==>GetMyMinionCount

; Returns the number of spirits in range of an agent
Func GetNumberOfSpiritAllies($aRange = 5000)
    Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, 0x04, $aRange)
    Return UBound($aAgentPtr) - 1
EndFunc   ;==>GetNumberOfSpiritAllies

; Returns the number of spirits I control
Func GetMySpiritCount_()
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x3C]
    Local $lPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return Memory_Read($lPtr[0], 'long') - 1
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
;~  Local $lCount = 0
;~  Local $aAgentPtr = GetAgentPtrArray(3, 0xDB, $allegiance_spirit, $aRange)

;~  For $i = 1 To $aAgentPtr[0]
;~   Switch Memory_Read($aAgentPtr[$i] + 244, 'word')    ; check on player number
;~    Case $model_id_Empowerment, $model_id_Rejuvenation, $model_id_Displacement, $model_id_Life, $model_id_Preservation _
;~      , $model_id_Recuperation, $model_id_Shelter, $model_id_Union, $model_id_Restoration
;~     If $Defensive Then $lCount += 1
;~    Case $model_id_Agony, $model_id_Anger, $model_id_Anguish, $model_id_Bloodsong, $model_id_Destruction _
;~      , $model_id_Earthbind, $model_id_Hate, $model_id_Pain, $model_id_Suffering, $model_id_Vampirism
;~     If $Offensive Then $lCount += 1
;~    Case $model_id_Dissonance, $model_id_Disenchantment, $model_id_Shadowsong, $model_id_Wanderlust
;~     $lCount += 1
;~   EndSwitch
;~  Next
;~  Return $lCount
;~ EndFunc   ;==>GetNumberOfSpirits

; Returns the number of ritualist pressure spirits in range of an agent
;~ Func NumberOfPressureSpirits($aRange = 5000)
;~  Return GetNumberOfSpirits($aRange, True, False)
;~ EndFunc   ;==>NumberOfPressureSpirits

;~ ; Returns the number of ritualist survival spirits in range of an agent
;~ Func NumberOfSurvivalSpirits($aRange = 5000)
;~  Return GetNumberOfSpirits($aRange, False, True)
;~ EndFunc   ;==>NumberOfSurvivalSpirits
#EndRegion Minions & Spirits