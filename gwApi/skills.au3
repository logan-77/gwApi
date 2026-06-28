#include-once

Global $hTimerSkillbar = TimerInit()
Global Const $iSkillbarRefresh = 500 ; refresh skillbar struct if 500ms has passed since the last refresh
Global $bRefreshSkillbar = False

;~ Cache of Player Skillbar
Global $tPlayerSkillbar = DllStructCreate($SKILLBAR_STRUCT_TEMPLATE)
Global $aPlayerRecharge[9]
Global $aPlayerAdrenaline[9]
Global $aPlayerSkillID[9]

Global $aPlayerEffects[] = [ 0 _
]
Global Const $iSizePlayerEffectsArray = UBound($aPlayerEffects)

Global Enum _
    $IDX_OF_EFFECTS ; list of effects we want to keep track of
    ;~ or make the array the size of all Skills and index=SkillID

Global Const $aIdxRecharge[9] = [ _
    0, _
    $IDX_RECHARGE_1, _
    $IDX_RECHARGE_2, _
    $IDX_RECHARGE_3, _
    $IDX_RECHARGE_4, _
    $IDX_RECHARGE_5, _
    $IDX_RECHARGE_6, _
    $IDX_RECHARGE_7, _
    $IDX_RECHARGE_8 _
]

Global Const $aIdxAdrenaline[9] = [ _
    0, _
    $IDX_ADRENALINE_1, _
    $IDX_ADRENALINE_2, _
    $IDX_ADRENALINE_3, _
    $IDX_ADRENALINE_4, _
    $IDX_ADRENALINE_5, _
    $IDX_ADRENALINE_6, _
    $IDX_ADRENALINE_7, _
    $IDX_ADRENALINE_8 _
]

Global Const $aIdxSkillID[9] = [ _
    0, _
    $IDX_SKILLID_1, _
    $IDX_SKILLID_2, _
    $IDX_SKILLID_3, _
    $IDX_SKILLID_4, _
    $IDX_SKILLID_5, _
    $IDX_SKILLID_6, _
    $IDX_SKILLID_7, _
    $IDX_SKILLID_8 _
]

Func UseSkillEx($iSkillSlot, $pTarget = -2, $iTimeout = 3000, $bCall = False)
    Local $hDeadlock = TimerInit()

    Local $pSkillbar = GetSkillbarPtr()
    Local $pMe = Agent_GetAgentPtr(-2)
    Local $iTargetID = ID($pTarget)
    $pTarget = Agent_GetAgentPtr($pTarget)

    If $iTargetID = 0 _
    Or GetIsDead($pMe) _
    Or Not IsRecharged($iSkillSlot, $pSkillbar) Then Return

    Local $iSkillID = GetSkillbarSkillID($iSkillSlot, 0, $pSkillbar)
    If GetEnergy($pMe) < GetEnergyReq($iSkillID) Then Return

    ChangeTarget($iTargetID)
    Skill_UseSkill($iSkillSlot, $iTargetID, $bCall)

    Do
        Sleep(50)
        If GetIsDead($pTarget) Or GetIsDead($pMe) Then Return
    Until Not IsRecharged($iSkillSlot, $pSkillbar) Or TimerDiff($hDeadlock) > $iTimeout

    Sleep($GC_AMX2_SKILL_DATA[$iSkillID][$GC_F_SKILL_AFTERCAST] * 1000) ; Aftercast

    $bRefreshSkillbar = True
EndFunc ;==>UseskillEx

Func UseSkillBySkillID($iSkillID, $pTarget = -2, $iTimeout = 3000, $bCall = False)
    Local Static $tSkillbarStruct = DllStructCreate($SKILLBAR_STRUCT_TEMPLATE)

    Local $pSkillbar = GetSkillbarPtr()

    GetSkillbarStruct($tSkillbarStruct, $pSkillbar)

    Local $iSkillSlot = -1

    For $i = 1 To 8
        If $iSkillID <> DllStructGetData($tSkillbarStruct, $aIdxSkillID[$i]) Then ContinueLoop

        $iSkillSlot = $i
        ExitLoop
    Next

    If $iSkillSlot = -1 Then Return

    Local $hDeadlock = TimerInit()
    Local $pMe = Agent_GetAgentPtr(-2)
    Local $iTargetID = ID($pTarget)
    $pTarget = Agent_GetAgentPtr($pTarget)
    
    If $iTargetID = 0 _
    Or GetIsDead($pMe) _
    Or Not IsRecharged($iSkillSlot, $pSkillbar) Then Return

    If GetEnergy($pMe) < GetEnergyReq($iSkillID) Then Return

    ChangeTarget($iTargetID)
    Skill_UseSkill($iSkillSlot, $iTargetID, $bCall)

    Do
        Sleep(50)
        If GetIsDead($pTarget) Or GetIsDead($pMe) Then Return
    Until Not IsRecharged($iSkillSlot, $pSkillbar) Or TimerDiff($hDeadlock) > $iTimeout

    Sleep($GC_AMX2_SKILL_DATA[$iSkillID][$GC_F_SKILL_AFTERCAST] * 1000) ; Aftercast

    $bRefreshSkillbar = True
EndFunc ;==>UseSkillBySkillID

;~ Description: Returns energy cost of a skill.
Func GetEnergyReq($iSkillID)
    Return Ceiling($GC_AMX2_SKILL_DATA[$iSkillID][$GC_I_SKILL_ENERGY_REQ])
EndFunc ;==>GetEnergyReq

#Region Skillbar
;~ Returns the pointer to the skillbar of player or hero
;~ only use in explorable!
;~ assumes, that the game orders the array according to the party window 0 -> 7
;~ (seems to be true in explorable)
Func GetSkillbarPtr($iHeroIndex = 0)
    Local $pWorldContext = World_GetWorldContextPtr()
    If $pWorldContext = 0 Or $iHeroIndex < 0 Then Return SetError(1, 0, 0)

    Local $pSkillbarArray = Memory_Read($pWorldContext + 0x6F0, 'ptr')
    If $iHeroIndex = 0 Then Return $pSkillbarArray ; player skillbar, fast return

    Local $iSkillbarArraySize = Memory_Read($pWorldContext + 0x6F0 + 0x8, 'long')

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

;~ 
Func GetSkillbarStruct(ByRef $tSkillbarStruct, $pSkillbar = GetSkillbarPtr())
    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pSkillbar, _
                    "struct*", $tSkillbarStruct, _
                    "ulong_ptr", $g_iSkillbarStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(1, 0, False)

    Return True
EndFunc ;==>GetSkillbarStruct

;~ 
Func UpdateSkillbarCache($pSkillbar = GetSkillbarPtr())
    If Not $bRefreshSkillbar And TimerDiff($hTimerSkillbar) < $iSkillbarRefresh Then Return True

    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pSkillbar, _
                    "struct*", $tPlayerSkillbar, _
                    "ulong_ptr", $g_iSkillbarStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(1, 0, False)

    $hTimerSkillbar = TimerInit()
    $bRefreshSkillbar = False

    ;~ fill cache
    For $i = 1 To 8
        $aPlayerRecharge[$i] = DllStructGetData($tPlayerSkillbar, $aIdxRecharge[$i])
    Next

    Return True
EndFunc ;==>UpdateSkillbarCache

Func GetIsRecharged($iSkillSlot, $pSkillbar = GetSkillbarPtr())
    UpdateSkillbarCache($pSkillbar)

    Local $iTimestamp = Utils_MakeInt32($aPlayerRecharge[$iSkillSlot])
    Local $iNow = Utils_MakeInt32(Skill_GetSkillTimer())

    Return $iTimestamp <= $iNow
EndFunc ;==>GetIsRecharged

Func GetRechargeTime($iSkillSlot, $pSkillbar = GetSkillbarPtr())
    UpdateSkillbarCache($pSkillbar)

    Local $iTimestamp = Utils_MakeInt32($aPlayerRecharge[$iSkillSlot])
    Local $iNow = Utils_MakeInt32(Skill_GetSkillTimer())    

    Local $iTimeRemaining = $iTimestamp - $iNow

    If $iTimeRemaining < 0 Then $iTimeRemaining = 0

    Return $iTimeRemaining
EndFunc ;==>GetRechargeTime

;~ for hot loops, where you want to know recharge state asap
Func IsRecharged($iSkillSlot, $pSkillbar = GetSkillbarPtr())
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), 'dword')
    Return $iTimestamp = 0
EndFunc ;==>IsRecharged

;~ Description: Checks SkillRecharge by SkillSlot; True=Recharged
Func IsRechargedHero($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), 'dword')
    Return ($iTimestamp = 0)
EndFunc ;==>IsRechargedHero

;~ Description: Returns the recharge time remaining of an equipped skill in milliseconds.
Func GetSkillbarSkillRecharge($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Local $iTimestamp = Memory_Read($pSkillbar + 0xC + (($iSkillSlot - 1) * 0x14), 'dword')
    If $iTimestamp = 0 Then Return 0
    
    Local $iTimestampSigned = Utils_MakeInt32($iTimestamp)
    Local $iNow = Utils_MakeInt32(Skill_GetSkillTimer())
    Local $iTimeRemaining = $iTimestampSigned - $iNow
    Return ($iTimeRemaining <= 0) ? 0 : $iTimeRemaining
EndFunc ;==>GetSkillbarSkillRecharge

;~ Description: Returns the skill ID of an equipped skill.
Func GetSkillbarSkillID($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Return Memory_Read($pSkillbar + 0x10 + (($iSkillSlot - 1) * 0x14), 'dword')
EndFunc ;==>GetSkillbarSkillID

;~ Description: Returns the adrenaline charge of an equipped skill.
Func GetSkillbarSkillAdrenaline($iSkillSlot, $iHeroIndex = 0, $pSkillbar = GetSkillbarPtr($iHeroIndex))
    Return Memory_Read($pSkillbar + 0x4 + (($iSkillSlot - 1) * 0x14), 'dword')
EndFunc ;==>GetSkillbarSkillAdrenaline
#EndRegion Skillbar

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
