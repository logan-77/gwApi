#include-once

;~ Only works for Players!
Func GetPartyPtrArray()
    Local $aAgentID = GetPartyIDArray()
    Local $aAgentPtr[Ubound($aAgentID)]
    $aAgentPtr[0] = $aAgentID[0]

    For $i = 1 To $aAgentID[0]
        $aAgentPtr[$i] = Agent_GetAgentPtr($aAgentID[$i])
    Next
    Return $aAgentPtr
EndFunc ;==>GetPartyPtrArray

;~ Only works for Players!
Func GetPartyIDArray()
    Local $iPlayerCount = Party_GetMyPartyInfo("ArrayPlayerPartyMemberSize")
    Local $aPartyID[$iPlayerCount + 1]
    $aPartyID[0] = $iPlayerCount

    Local $aAgentPtr = GetAgentPtrArray(2, 0xDB, $allegiance_ally)
    Local $iLoginNumber, $iMyLoginNumber = Agent_GetAgentInfo(-2, "LoginNumber")

    For $i = 1 To $iPlayerCount
        $iLoginNumber = Party_GetMyPartyPlayerMemberInfo($i, "LoginNumber")

        If $iLoginNumber = $iMyLoginNumber Then
            $aPartyID[$i] = Agent_GetMyID()
            ContinueLoop
        EndIf

        For $j = 1 To $aAgentPtr[0]
            If Agent_GetAgentInfo($aAgentPtr[$j], "LoginNumber") = $iLoginNumber Then
                $aPartyID[$i] = Agent_GetAgentInfo($aAgentPtr[$j], "ID")
                ExitLoop
            EndIf
        Next
    Next
    Return $aPartyID
EndFunc ;==>GetPartyIDArray

Func GetPartyLeaderPtr()
    Local $aPartyPtr = GetPartyPtrArray()
    Return $aPartyPtr[1]
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
    Return Party_GetPartyContextInfo("TotalPartySize")
EndFunc   ;==>GetPartySize

;~ Returns how many real players are in the party
Func GetPlayerPartySize()
    ;~ Local $lOffset0[5] = [0, 0x18, 0x4C, 0x54, 0xC]
    ;~ Local $lplayersPtr = Memory_ReadPtr($g_p_BasePointer, $lOffset0)
    ;~ Return Memory_Read($lplayersPtr[0], 'long') ; players
    Return Party_GetMyPartyInfo("ArrayPlayerPartyMemberSize")
EndFunc   ;==>GetPlayerPartySize

;~ Returns if all Partymembers are connected
;~ Only works with players
Func GetPartyConnected($iPartySize)
    Local $iPlayerCount = Party_GetMyPartyInfo("ArrayPlayerPartyMemberSize")

    If $iPlayerCount < $iPartySize Then
        Out("Players are missing.")
        Return False
    EndIf

    If $iPlayerCount = $iPartySize Then
        Out("Everyone is connected.")
        Return True
    EndIf

    If $iPlayerCount > $iPartySize Then
        Out("Wtf ??")
        Return True
    EndIf
EndFunc

; Returns all Player names of the current party
Func GetPartyPlayerNames()
    Local $aPartiID = GetPartyIDArray()
    Local $sPlayerNames = ""

    For $i = 1 To $aPartiID[0]
        Local $sName = Agent_GetAgentInfo($aPartiID[$i], "Name")

        $sPlayerNames &= $sName
        If $i < $aPartiID[0] Then $sPlayerNames &= "|"

        Out($sName)
    Next

    Return $sPlayerNames
EndFunc   ;==>GetPartyPlayerNames

; maybe usefull for Healparty/LoD
Func GetPartyHealth($aPartyPtrArray = 0)
    Local $aTotalTeamHP
    $PartyPtrArray = GetPartyPtrArray()
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