#include-once

;~ Description: Returns an array of pointer variables for allies who are party members.
Func GetPartyPtrArray($aAgentPtrArray = 0)
    Local $lReturnPtrArray[1] = [0]
    If $aAgentPtrArray = 0 Then $aAgentPtrArray = GetAgentPtrArray(2, 0xDB, $allegiance_ally)
    For $i = 1 To $aAgentPtrArray[0]
        If BitAND(Memory_Read($aAgentPtrArray[$i] + 0x15C, "dword"), 131072) Or BitAND(Memory_Read($aAgentPtrArray[$i] + 0x15C, "dword"), 131584) Then ; 131584 = Mercenary Heroes
        $lReturnPtrArray[0] += 1
        ReDim $lReturnPtrArray[$lReturnPtrArray[0] + 1]
        $lReturnPtrArray[$lReturnPtrArray[0]] = $aAgentPtrArray[$i]
        EndIf
    Next
    Return $lReturnPtrArray
EndFunc   ;==>GetPartyPtrArray

Func GetPartyLeaderPtr($aPartyPtrArray = 0)
    Local $lPartyLeader, $lPlayerNumber, $lLowestPlayerNumber = 1000
    If $aPartyPtrArray = 0 Then $aPartyPtrArray = GetPartyPtrArray()
    
    If GetIsPartyLeader() Then Return Agent_GetAgentPtr(-2)
    
    For $i = 1 To $aPartyPtrArray[0]
        $lPlayerNumber = GetPlayerNumber($aPartyPtrArray[$i])
        If $lPlayerNumber < $lLowestPlayerNumber Then
            $lLowestPlayerNumber = $lPlayerNumber
            $lPartyLeader = $aPartyPtrArray[$i]
        EndIf
    Next
    ; Out("Party Leader PlayerNo: " & $lLowestPlayerNumber)
    Return $lPartyLeader
EndFunc ;==>GetPartyLeaderPtr

;~  Description: Returns different States about Party. Check with BitAND.
;~  0x8 = Leader starts Mission / Leader is travelling with Party
;~  0x10 = Hardmode enabled
;~  0x20 = Party defeated
;~  0x40 = Guild Battle
;~  0x80 = Party Leader
;~  0x100 = Observe-Mode
Func GetPartyState($aFlag)
    Local $lOffset[4] = [0, 0x18, 0x4C, 0x14]
    Local $lBitMask = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return BitAND($lBitMask[1], $aFlag) > 0
EndFunc   ;==>GetPartyState

Func GetPartyWaitingForMission()
    Return GetPartyState(0x8)
EndFunc   ;==>GetPartyWaitingForMission

Func GetIsHardMode()
    Return GetPartyState(0x10)
EndFunc   ;==>GetIsHardMode

Func GetPartyDefeated()
    Return GetPartyState(0x20)
EndFunc   ;==>GetPartyDefeated

Func GetIsPartyLeader()
    Return GetPartyState(0x80)
EndFunc ;==>GetIsPartyLeader

Func GetPartySize()
    Local $lOffset0[5] = [0, 0x18, 0x4C, 0x54, 0xC]
    Local $lplayersPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset0)

    Local $lOffset1[5] = [0, 0x18, 0x4C, 0x54, 0x1C]
    Local $lhenchmenPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset1)

    Local $lOffset2[5] = [0, 0x18, 0x4C, 0x54, 0x2C]
    Local $lheroesPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset2)

    Local $Party1 = Memory_Read($lplayersPtr[0], 'long') ; players
    Local $Party2 = Memory_Read($lhenchmenPtr[0], 'long') ; henchmen
    Local $Party3 = Memory_Read($lheroesPtr[0], 'long') ; heroes

    Local $lReturn = $Party1 + $Party2 + $Party3
    ;~    If $lReturn > 12 or $lReturn < 1 Then $lReturn = 8
    Return $lReturn
EndFunc   ;==>GetPartySize

;~ Returns how many real players are in the party
Func GetPlayerPartySize()
    Local $lOffset0[5] = [0, 0x18, 0x4C, 0x54, 0xC]
    Local $lplayersPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset0)
    Return Memory_Read($lplayersPtr[0], 'long') ; players
EndFunc   ;==>GetPlayerPartySize

; Memory_Read($lplayersPtr[0] + 4, 'long')
; Memory_Read($lplayersPtr[0] + 8, 'long')

;~ Returns if all Partymembers are connected
Func GetPartyConnected($PartyNumber)
    Local $aParty = GetPartyPtrArray()

    If $aParty[0] < $PartyNumber Then
        Out("Everyone not connected")
        Return False
    EndIf

    If $aParty[0] = $PartyNumber Then
        Out("Everyone is connected")
        Return True
    EndIf

    If $aParty[0] > $PartyNumber Then
        Out("Wtf ??")
        Return True
    EndIf
EndFunc

;Returns all Player names of the current party
Func GetPartyPlayerNames()
    Local $aPartyPtrArray = GetPartyPtrArray()
    If $aPartyPtrArray[0] = 0 Then Return ''

    Local $ret = GetPlayerName(ID($aPartyPtrArray[1]))
    Out(GetPlayerName(ID($aPartyPtrArray[1])))
    If $aPartyPtrArray[0] = 1 Then Return $ret

    For $i = 2 To $aPartyPtrArray[0]
        ; If Memory_Read($aPartyPtrArray[$i] + 344, "long") = 0x20200 Then ContinueLoop ; excludes players in outpost who are not in our part
        $playerName = GetPlayerName(ID($aPartyPtrArray[$i]))
        If Not $playerName = 0 Then
            $ret &= "|"
            $ret &= $playerName
            Out($playerName)
        EndIf
    Next
    Return $ret
EndFunc   ;==>GetPartyPlayerNames

; maybe usefull for Healparty/LoD
Func GetPartyHealth($aPartyPtrArray = 0)
    Local $aTotalTeamHP
    $PartyPtrArray = GetPartyPtrArray($aPartyPtrArray)
    For $i = 1 To $PartyPtrArray[0]
        If GetIsDead($PartyPtrArray[$i]) Then ContinueLoop
        $aAgent = $PartyPtrArray[$i]
        $aTotalTeamHP += Memory_Read($PartyPtrArray[$i] + 304, "Float")
    Next
    $nAverageHP = Round($aTotalTeamHP / $PartyPtrArray[0], 6)
    Return $nAverageHP
EndFunc   ;==>GetPartyHealth

Func GetMaxPartySize($aMapID)
    Switch $aMapID
        Case 293 To 296, 721, 368, 188, 467, 497
            Return 1
        Case 163 To 166
            Return 2
        Case 28 To 30, 32, 36, 39, 40, 81, 131, 135, 148, 189, 214, 242, 249, 251, 281, 282
            Return 4
        Case 431, 449, 479, 491, 502, 544, 555, 795, 796, 811, 815, 816, 818 To 820, 855, 856
            Return 4
        Case 10 To 12, 14 To 16, 19, 21, 25, 38, 49, 55, 57, 73, 109, 116, 117 To 119
            Return 6
        Case 132 To 134, 136, 137, 139 To 142, 152, 153, 154, 213, 250, 385, 808, 809, 810
            Return 6
        Case 266, 307
            Return 12
        Case Else
            Return 8
    EndSwitch
EndFunc   ;==>GetMaxPartySize

;~ Description: Invite a player to the party.
Func InvitePlayer($aPlayerName)
     Chat_SendChat('invite ' & $aPlayerName, '/')
EndFunc   ;==>InvitePlayer

Func InvitePlayerByPlayerNumber($aPlayerNumber)
    Return Core_SendPacket(0x8, $GC_I_HEADER_PARTY_INVITE_PLAYER, $aPlayerNumber)
EndFunc   ;==>InvitePlayerByPlayerNumber

; $aAgent = Ptr/Struct/AgentID
Func InvitePlayerByAgentPtr($aAgent)
    Local $lAgentPtr = Agent_GetAgentPtr($aAgent)
    If $lAgentPtr <> 0 Then Return Core_SendPacket(0x8, $GC_I_HEADER_PARTY_INVITE_PLAYER, GetPlayerNumber($lAgentPtr))
EndFunc   ;==>InvitePlayerByAgentPtr

Func InviteTarget()
    If $g_i_CurrentTarget = 0 Then Return False
    Return Core_SendPacket(0x8, $GC_I_HEADER_PARTY_INVITE_PLAYER, GetPlayerNumber(-1))
EndFunc

;~ Description: Accepts pending invite.
Func AcceptInvite($aAgent = Agent_GetAgentPtr(-1))
    If $aAgent = 0 Then Return False
    Local $lAgentPlayerNumber = GetPlayerNumber($aAgent)
    Return Core_SendPacket(0x8, $GC_I_HEADER_PARTY_ACCEPT_INVITE, $lAgentPlayerNumber)
EndFunc   ;==>AcceptInvite