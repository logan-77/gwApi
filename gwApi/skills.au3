#include-once

;~ Returns the pointer to the skillbar of player or hero
;~ only use in explorable!
;~ assumes, that the game orders the array according to the party window 0 -> 7
;~ (seems to be true in explorable)
Func GetSkillbarPtr($iHeroIndex = 0)
    Local $pWorldContext = World_GetWorldContextPtr()
    If $pWorldContext = 0 Or $iHeroIndex < 0 Then Return SetError(1, 0, 0)

    Local $pSkillbarArray = Memory_Read($pWorldContext + 0x6F0, "ptr")
    If $iHeroIndex = 0 Then Return $pSkillbarArray ; player skillbar, fast return

    Local $iSkillbarArraySize = Memory_Read($pWorldContext + 0x6F0 + 0x8, "long")

    If $iHeroIndex < $iSkillbarArraySize Then Return $pSkillbarArray + ($iHeroIndex * 0xBC)

    ;~ Local $pSkillbar
    ;~ $iAgentID = Agent_ConvertID($iAgentID)

    ;~ For $i = 0 To $iSkillbarArraySize - 1
    ;~     $pSkillbar = $pSkillbarArray + ($i * 0xBC)
    ;~     If Memory_Read($pSkillbar, "long") = $iAgentID Then
    ;~         Return $pSkillbar
    ;~     EndIf
    ;~ Next

    Return SetError(2, 0, 0)
EndFunc ;==>GetSkillbarPtr

#Region Skills
Func UseSkillEx($iSkillSlot, $aTarget = -2, $aTimeout = 3000, $aCallTarget = False)
    Local $pSkillbar = GetSkillbarPtr()
    Local $lDeadlock = TimerInit(), $lAgentID = ID($aTarget), $lMe = Agent_GetAgentPtr(-2)
    If $lAgentID = 0 Or GetIsDead($lMe) Or Not IsRecharged($iSkillSlot, $pSkillbar) Then Return

    Local $iSkillID = GetSkillbarSkillID($iSkillSlot, 0, $pSkillbar)
    If GetEnergy($lMe) < GetEnergyReq($iSkillID) Then Return

    If $lAgentID <> GetMyID() Then Agent_ChangeTarget($lAgentID)
    Skill_UseSkill($iSkillSlot, $lAgentID, $aCallTarget)
    Do
        Sleep(50)
        If GetIsDead($lAgentID) Or GetIsDead($lMe) Then Return  
    Until Not IsRecharged($iSkillSlot, $pSkillbar) Or TimerDiff($lDeadlock) > $aTimeout

    Sleep($GC_AMX2_SKILL_DATA[$iSkillID][$GC_F_SKILL_AFTERCAST] * 1000) ; Aftercast
EndFunc ;==>UseskillEx

;~ Description: Returns energy cost of a skill.
Func GetEnergyReq($iSkillID)
    ;~ Local $lEnergycost = Memory_Read(Skill_GetSkillPtr($aSkillID) + 0x35, "byte")
    ;~ If $lEnergycost = 11 Then Return 15
    ;~ If $lEnergycost = 12 Then Return 25
    ;~ Return $lEnergycost
    Return Ceiling($GC_AMX2_SKILL_DATA[$iSkillID][$GC_F_SKILL_ENERGY_REQ_QZ])
EndFunc   ;==>GetEnergyReq

;~ Description: Checks SkillRecharge by SkillSlot; True=Recharged
Func IsRechargedHero($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), "dword")
    Return ($iTimestamp = 0)
EndFunc ;==>IsRechargedHero

Func IsRecharged($iSkillSlot, $pSkillbar = GetSkillbarPtr())
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), "dword")
    Return ($iTimestamp = 0)
EndFunc ;==>IsRecharged

;~ Description: Returns the recharge time remaining of an equipped skill in milliseconds.
Func GetSkillbarSkillRecharge($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), "dword")
    If $iTimestamp = 0 Then Return 0
    
    Local $iTimestampSigned = Utils_MakeInt32($iTimestamp)
    Local $iSkillTimerSigned = Utils_MakeInt32(Skill_GetSkillTimer())
    Local $iTimeRemaining = $iTimestampSigned - $iSkillTimerSigned
    Return ($iTimeRemaining <= 0) ? 0 : $iTimeRemaining
EndFunc ;==>GetSkillbarSkillRecharge

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Return Memory_Read($pSkillbar + 0x10 + (($iSkillSlot - 1) * 0x14), "dword")
EndFunc ;==>GetSkillbarSkillID

;~ Description: Returns the adrenaline charge of an equipped skill.
Func GetSkillbarSkillAdrenaline($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Return Memory_Read($pSkillbar + 0x4 + (($iSkillSlot - 1) * 0x14), "dword")
EndFunc ;==>GetSkillbarSkillAdrenaline

;~ 
Func UpdateSkillbar(ByRef $tSkillbarStruct, $pSkillbar = GetSkillbarPtr())
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pSkillbar, _
                    "struct*", $tSkillbarStruct, _
                    "ulong_ptr", $g_iSkillbarStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(1, 0, 0)

    Return 1
EndFunc ;==>UpdateSkillbar

Func GetIsRecharged($iSkillSlot, ByRef $tSkillbarStruct)
    Local $pRecharge, $tDword = DllStructCreate("dword")
    Local $pBase = DllStructGetPtr($tSkillbarStruct)

    $pRecharge = $pBase + 0xC + (($iSkillSlot - 1) * 0x14)
    $tDword = DllStructCreate("dword", $pRecharge)

    Local $iRecharge = DllStructGetData($tDword, 1)

    Return ($iRecharge = 0)    
EndFunc ;==>GetRecharge
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

    ;~ check effects from which agent? player or a hero
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

    ;~ get EffectArray Ptr and Size
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pAgent + 0x14, _
                    "struct*", $g_tEffectArray, _
                    "ulong_ptr", $g_iEffectArrayStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, $bEffects)

    Local $pEffectArray = DllStructGetData($g_tEffectArray, "EffectArray")
    Local $iEffectCount = DllStructGetData($g_tEffectArray, "EffectArraySize")

    Local $iBufferSize = $iEffectCount * $GC_EFFECT_STRUCT_SIZE
    Local $tEffectBuffer = DllStructCreate("byte[" & $iBufferSize & "]")
    Local $pBuffer = DllStructGetPtr($tEffectBuffer)

    ;~ get snapshot of all active effects
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pEffectArray, _
                    "struct*", $tEffectBuffer, _
                    "ulong_ptr", $iBufferSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, -1)

    Local $pEffect, $tEffect, $iSkillID, $iCount = 0

    For $i = 0 To $iEffectCount - 1
        $pEffect = $pBuffer + ($i * $GC_EFFECT_STRUCT_SIZE)

        $tEffect = DllStructCreate($EFFECT_STRUCT_TEMPLATE, $pEffect)
        $iSkillID = DllStructGetData($tEffect, "SkillID")

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
Func GetEffectTimeRemaining2($aSkillID, $iAgentID = -2)
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
            Local $fDuration = Memory_Read($pCurrent + 0x10, "float")
            Local $iTimeRemaining = $fDuration * 1000 - BitAND(Skill_GetSkillTimer() - $iTimestamp, 0xFFFFFFFF)
            If $iTimeRemaining < 0 Then $iTimeRemaining = 0

            If $aTimeRemaining[$idx] < $iTimeRemaining Then
                $aTimeRemaining[$idx] = $iTimeRemaining
            EndIf
        EndIf
    Next

    Return $bSingle ? $aTimeRemaining[0] : $aTimeRemaining
EndFunc ;==>GetEffectTimeRemaining

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

    Local $pAgentEffects, $pAgent = 0

    ;~ check effects from which agent? player or a hero
    For $i = 0 To $iSize - 1
        $pAgentEffects = $pPtr + ($i * 0x24)
        If Memory_Read($pAgentEffects, "dword") = $iAgentID Then
            $pAgent = $pAgentEffects
            ExitLoop
        EndIf
    Next

    If $pAgent = 0 Then
        Return $bSingle ? SetError(1, 0, 0) : SetError(1, 0, $aTimeRemaining)
    EndIf

    ;~ get EffectArray Ptr and Size
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pAgent + 0x14, _
                    "struct*", $g_tEffectArray, _
                    "ulong_ptr", $g_iEffectArrayStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, $aTimeRemaining)

    Local $pEffectArray = DllStructGetData($g_tEffectArray, "EffectArray")
    Local $iEffectCount = DllStructGetData($g_tEffectArray, "EffectArraySize")

    Local $iBufferSize = $iEffectCount * $GC_EFFECT_STRUCT_SIZE
    Local $tEffectBuffer = DllStructCreate("byte[" & $iBufferSize & "]")
    Local $pBuffer = DllStructGetPtr($tEffectBuffer)

    ;~ get snapshot of all active effects
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pEffectArray, _
                    "struct*", $tEffectBuffer, _
                    "ulong_ptr", $iBufferSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, -1)

    Local $pEffect, $tEffect, $iSkillID, $fDuration, $iTimestamp, $iTimeRemaining
    Local $iSkillTimer = Skill_GetSkillTimer()

    ;~ loop through Effects and return time remaining
    For $i = 0 To $iEffectCount - 1
        $pEffect = $pBuffer + ($i * $GC_EFFECT_STRUCT_SIZE)

        $tEffect = DllStructCreate($EFFECT_STRUCT_TEMPLATE, $pEffect)
        $iSkillID = DllStructGetData($tEffect, "SkillID")

        If MapExists($mSkillID, $iSkillID) Then
            Local $idx = $mSkillID[$iSkillID]

            $iTimestamp = DllStructGetData($tEffect, "Timestamp")
            $fDuration = DllStructGetData($tEffect, "Duration")

            Local $iTimeRemaining = $fDuration * 1000 - BitAND($iSkillTimer - $iTimestamp, 0xFFFFFFFF)
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
Func GetBondCount($iAgent = -2)
    Return Agent_GetAgentEffectArrayInfo($iAgent, "BondArraySize")
EndFunc ;==>GetBondCount

;~ Description: Tests if you are currently maintaining buff on target.
Func GetIsTargetBonded($iSkillID, $iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BondArraySize")
    Local $pBondArray = Agent_GetAgentEffectArrayInfo($iAgent, "BondArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent 

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBondArray + ($i * 0x10)

        $iCurrentSkillID = Memory_Read($pCurrent, "long")
        If $iSkillID <> $iCurrentSkillID Then ContinueLoop

        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")
        If $iTargetID <> $iCurrentTargetID Then ContinueLoop
        
        Return True
    Next

    Return False
EndFunc ;==>GetIsTargetBonded

;~ Description: Stop maintaining enchantment on target.
Func DropBuff($iSkillID, $iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BondArraySize")
    Local $pBondArray = Agent_GetAgentEffectArrayInfo($iAgent, "BondArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent 

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBondArray + ($i * 0x10)

        $iCurrentSkillID = Memory_Read($pCurrent, "long")
        If $iSkillID <> $iCurrentSkillID Then ContinueLoop

        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")
        If $iTargetID <> $iCurrentTargetID Then ContinueLoop

        Local $iBuffID = Memory_Read($pCurrent + 0x8, "long")
        Core_SendPacket(0x8, $GC_I_HEADER_BOND_DROP, $iBuffID)
        Return True
    Next
    Return False
EndFunc ;==>DropBuff

Func DropAllBondsBySkillID($iSkillID, $iAgent = -2)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BondArraySize")
    Local $pBondArray = Agent_GetAgentEffectArrayInfo($iAgent, "BondArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent, $iBuffID

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBondArray + ($i * 0x10)

        $iCurrentSkillID = Memory_Read($pCurrent, "long")
        If $iSkillID <> $iCurrentSkillID Then ContinueLoop

        $iBuffID = Memory_Read($pCurrent + 0x8, "long")
        Core_SendPacket(0x8, $GC_I_HEADER_BOND_DROP, $iBuffID)
    Next
EndFunc ;==>DropAllBondsBySkillID

Func DropAllBondsOnTargetID($iTargetID, $iAgent = -2)
    $iTargetID = Agent_ConvertID($iTargetID)
    $iAgent = Agent_GetAgentPtr($iAgent)

    Local $iBuffCount = Agent_GetAgentEffectArrayInfo($iAgent, "BondArraySize")
    Local $pBondArray = Agent_GetAgentEffectArrayInfo($iAgent, "BondArray")
    Local $iCurrentSkillID, $iCurrentTargetID, $pCurrent, $iBuffID

    For $i = 0 To $iBuffCount - 1
        $pCurrent = $pBondArray + ($i * 0x10)

        $iCurrentTargetID = Memory_Read($pCurrent + 0xC, "dword")
        If $iTargetID <> $iCurrentTargetID Then ContinueLoop

        $iBuffID = Memory_Read($pCurrent + 0x8, "long")
        Core_SendPacket(0x8, $GC_I_HEADER_BOND_DROP, $iBuffID)
    Next
EndFunc ;==>DropAllBondsOnTargetID
#EndRegion Buffs
