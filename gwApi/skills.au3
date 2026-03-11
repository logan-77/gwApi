#include-once

;~ Description: Returns the pointer variable to a skillbar for specified hero number.
Func GetSkillbarPtr($aHeroNumber = 0)
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
    Local $lHeroCount = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
    Local $lSkillbarStructAddress

    For $i = 0 To $lHeroCount[1]
        $lOffset[4] = $i * 0xBC
        $lSkillbarStructAddress = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        If $lSkillbarStructAddress[1] = GetHeroID($aHeroNumber) Then Return $lSkillbarStructAddress[0]
    Next
EndFunc   ;==>GetSkillbarPtr

;~ Description: Returns the pointer variable to a skillbar for specified hero ID.
Func GetSkillbarPtrByHeroID($aHeroId)
    ;~ Local $lOffset[5] = [0, 24, 76, 84, 44]
    Local $lOffset[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
    Local $lHeroCount = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Local $lOffset[5] = [0, 0x18, 0x2C, 0x6F0]
    For $i = 0 To $lHeroCount[1]
        $lOffset[4] = $i * 0xBC
        Local $lSkillbarStructAddress = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        If $lSkillbarStructAddress[1] = $aHeroId Then Return $lSkillbarStructAddress[0]
    Next
EndFunc   ;==>GetSkillbarPtrByHeroID

#Region Skills
Func UseSkillEx($aSkillSlot, $aTarget = -2, $aTimeout = 3000, $aCallTarget = False, $aSkillbarPtr = GetSkillbarPtr())
    Local $lDeadlock = TimerInit(), $lAgentID = ID($aTarget), $lMe = Agent_GetAgentPtr(-2)
    Local $lSkill = Skill_GetSkillPtr(GetSkillbarSkillID($aSkillSlot, 0, $aSkillbarPtr))
    If $lAgentID = 0 Or GetIsDead($lMe) Or Not IsRecharged($aSkillSlot, $aSkillbarPtr) Then Return
    If GetEnergy($lMe) < GetEnergyReq($lSkill) Then Return

    If $lAgentID <> GetMyID() Then Agent_ChangeTarget($lAgentID)
    Skill_UseSkill($aSkillSlot, $lAgentID, $aCallTarget)
    Do
        Sleep(50)
        If GetIsDead($lAgentID) Or GetIsDead($lMe) Then Return  
    Until Not IsRecharged($aSkillSlot, $aSkillbarPtr) Or TimerDiff($lDeadlock) > $aTimeout
    Sleep(Memory_Read($lSkill + 0x40, "float") * 1000) ; Aftercast
    Return True
EndFunc   ;==>UseskillEX

;~ Description: Returns energy cost of a skill.
Func GetEnergyReq($aSkillID)
    Local $lEnergycost = Memory_Read(Skill_GetSkillPtr($aSkillID) + 0x35, "byte")
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
    Local $lTimestamp = Memory_Read($aSkillbarPtr + 0xC + ($aSkillSlot * 0x14), "dword")
    If $lTimestamp = 0 Then Return 0
    Return $lTimestamp - Skill_GetSkillTimer()
EndFunc ;==>GetSkillbarSkillRecharge

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($askillslot, $aHeronumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
    $askillslot -= 1
    Return Memory_Read($aSkillbarPtr + 0x10 + ($aSkillslot * 0x14), "dword")
EndFunc ;==>GetSkillbarSkillID

;~ Description: Returns the adrenaline charge of an equipped skill.
Func GetSkillbarSkillAdrenaline($aSkillSlot, $aHeroNumber = 0, $aSkillbarPtr = GetSkillbarPtr($aHeroNumber))
    $aSkillSlot -= 1
    Return Memory_Read($aSkillbarPtr + 0x4 + ($aSkillSlot * 0x14), "dword")
EndFunc   ;==>GetSkillbarSkillAdrenaline
#EndRegion Skills

#Region Efffects
;~ Description: Returns True if you're under the effect of $aSkillID.
Func HasEffect($aSkillID, $iAgentID = -2)
    Local $bSingle = Not IsArray($aSkillID)
    If $bSingle Then
        Local $aTmp[1] = [$aSkillID]
        $aSkillID = $aTmp
    EndIf

    Local $iSizeEffects = UBound($aSkillID)
    Local $bEffects[$iSizeEffects]
    Local $mSkillID[]
    For $i = 0 To $iSizeEffects - 1
        $bEffects[$i] = False
        $mSkillID[$aSkillID[$i]] = $i
    Next

    Local $pPtr = World_GetWorldInfo("AgentEffectsArray")
    Local $iSize = World_GetWorldInfo("AgentEffectsArraySize")
    $iAgentID = Agent_ConvertID($iAgentID)

    Local $pAgent = 0

    For $i = 0 To $iSize - 1
        Local $pAgentEffects = $pPtr + ($i * 0x24)
        If Memory_Read($pAgentEffects, "dword") = $iAgentID Then
            $pAgent = $pAgentEffects
            ExitLoop
        EndIf
    Next

    If $pAgent = 0 Then
        Return $bSingle ? SetError(1, 0, False) : SetError(1, 0, $bEffects)
    EndIf

    Local $pEffectArray = Memory_Read($pAgent + 0x14, "ptr")
    Local $iEffectCount = Memory_Read($pAgent + 0x14 + 0x8, "long")
    Local $pCurrent, $iSkillID, $iCount = 0

    For $i = 0 To $iEffectCount - 1
        $pCurrent = $pEffectArray + ($i * 0x18)
        $iSkillID = Memory_Read($pCurrent, "long")

        If MapExists($mSkillID, $iSkillID) Then
            Local $idx = $mSkillID[$iSkillID]

            If Not $bEffects[$idx] Then
                $bEffects[$idx] = True
                $iCount += 1
                If $iCount = $iSizeEffects Then ExitLoop
            EndIf
        EndIf
    Next

    Return $bSingle ? $bEffects[0] : $bEffects
EndFunc ;==>HasEffect

;~ Description: Returns time remaining before an effect expires, in milliseconds.
Func GetEffectTimeRemaining($aSkillID, $iAgentID = -2)
    Local $bSingle = Not IsArray($aSkillID)
    If $bSingle Then
        Local $aTmp[1] = [$aSkillID]
        $aSkillID = $aTmp
    EndIf

    Local $iSizeEffects = UBound($aSkillID)
    Local $aTimeRemaining[$iSizeEffects]
    Local $mSkillID[]
    For $i = 0 To $iSizeEffects - 1
        $aTimeRemaining[$i] = 0
        $mSkillID[$aSkillID[$i]] = $i
    Next

    Local $pPtr = World_GetWorldInfo("AgentEffectsArray")
    Local $iSize = World_GetWorldInfo("AgentEffectsArraySize")
    $iAgentID = Agent_ConvertID($iAgentID)

    Local $pAgent = 0

    For $i = 0 To $iSize - 1
        Local $pAgentEffects = $pPtr + ($i * 0x24)
        If Memory_Read($pAgentEffects, "dword") = $iAgentID Then
            $pAgent = $pAgentEffects
            ExitLoop
        EndIf
    Next

    If $pAgent = 0 Then
        Return $bSingle ? SetError(1, 0, 0) : SetError(1, 0, $aTimeRemaining)
    EndIf

    Local $pEffectArray = Memory_Read($pAgent + 0x14, "ptr")
    Local $iEffectCount = Memory_Read($pAgent + 0x14 + 0x8, "long")
    Local $pCurrent, $iSkillID

    For $i = 0 To $iEffectCount - 1
        $pCurrent = $pEffectArray + ($i * 0x18)
        $iSkillID = Memory_Read($pCurrent, "long")

        If MapExists($mSkillID, $iSkillID) Then
            Local $idx = $mSkillID[$iSkillID]
            Local $iTimestamp = Memory_Read($pCurrent + 0x14, "dword")
            Local $iDuration = Memory_Read($pCurrent + 0x10, "float")
            Local $iTimeRemaining = $iDuration * 1000 - BitAND(Skill_GetSkillTimer() - $iTimestamp, 0xFFFFFFFF)
            If $iTimeRemaining < 0 Then $iTimeRemaining = 0

            If $aTimeRemaining[$idx] < $iTimeRemaining Then
                $aTimeRemaining[$idx] = $iTimeRemaining
            EndIf
        EndIf
    Next

    Return $bSingle ? $aTimeRemaining[0] : $aTimeRemaining
EndFunc ;==>GetEffectTimeRemaining

;~ Description: Tests if self or other hero is burning - cannot use for enemies or other human players
Func GetIsBurning($iAgentID = -2)
    Return HasEffect($skill_id_burning, $iAgentID)
EndFunc ;==>GetIsBurning
#EndRegion Effects

#Region Buffs
;~ Functions work for Player and Hero's

;~ Description: Returns current number of buffs being maintained.
Func GetBuffCount($iAgent = -2)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Return Agent_GetAgentEffectArrayInfo($iAgent, "BuffArraySize")
EndFunc   ;==>GetBuffCount

;~ Description: Tests if you are currently maintaining buff on target.
Func GetIsTargetBuffed($iSkillID, $iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArraySize")
    Local $pBuffArray = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent 

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBuffArray + ($i * 0x10)
        $iCurrentSkillID = Memory_Read($pCurrent, "long")
        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")

        If $iSkillID = $iCurrentSkillID And $iTargetID = $iCurrentTargetID Then Return True
    Next

    Return False
EndFunc ;==>GetIsTargetBuffed

;~ Description: Stop maintaining enchantment on target.
Func DropBuff($iSkillID, $iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArraySize")
    Local $pBuffArray = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent 

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBuffArray + ($i * 0x10)
        $iCurrentSkillID = Memory_Read($pCurrent, "long")
        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")

        If $iSkillID = $iCurrentSkillID And $iTargetID = $iCurrentTargetID Then
            Local $iBuffID = Memory_Read($pCurrent + 0x8, "long")
            Core_SendPacket(0x8, $GC_I_HEADER_BUFF_DROP, $iBuffID)
            Return True
        EndIf
    Next
    Return False
EndFunc ;==>DropBuff

Func DropAllBondsBySkillID($iSkillID, $iAgent = -2)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArraySize")
    Local $pBuffArray = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent, $iBuffID

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBuffArray + ($i * 0x10)
        $iCurrentSkillID = Memory_Read($pCurrent, "long")

        If $iSkillID = $iCurrentSkillID Then
            $iBuffID = Memory_Read($pCurrent + 0x8, "long")
            Core_SendPacket(0x8, $GC_I_HEADER_BUFF_DROP, $iBuffID)
        EndIf
    Next
EndFunc ;==>DropAllBondsBySkillID

Func DropAllBondsOnTargetID($iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArraySize")
    Local $pBuffArray = Agent_GetAgentEffectArrayInfo($iAgent, "BuffArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent, $iBuffID

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBuffArray + ($i * 0x10)
        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")

        If $iTargetID = $iCurrentTargetID Then
            $iBuffID = Memory_Read($pCurrent + 0x8, "long")
            Core_SendPacket(0x8, $GC_I_HEADER_BUFF_DROP, $iBuffID)
        EndIf
    Next
EndFunc ;==>DropAllBondsOnTargetID
#EndRegion Buffs


#Region Template: Skill & Attribute
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
        $lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
        If $lBuffer[1] == $lAgentID Then
            If $aWithRunes Then
                $lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0xC
            Else
                $lOffset[4] = 0x43C * $i + 0x14 * $aAttributeID + 0x8
            EndIf
            $lBuffer = Memory_ReadPtr($g_p_BasePointer, $lOffset)
            Return $lBuffer[1]
        EndIf
    Next
EndFunc   ;==>GetAttributeByID

; Returns the attribute of a skill
Func SkillAttribute($aSkill)
    If IsPtr($aSkill) <> 0 Then
        Return Memory_Read($aSkill + 41, "byte")
    ElseIf IsDllStruct($aSkill) <> 0 Then
        Return DllStructGetData($aSkill, "Attribute")
    Else
        Return Memory_Read(Skill_GetSkillPtr($aSkill) + 41, "byte")
    EndIf
EndFunc   ;==>SkillAttribute
#EndRegion Template: Skill & Attribute