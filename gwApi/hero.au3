#include-once

#Region PartyCommands
;~ Description: Adds a hero to the party.
Func AddHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_ADD, $aHeroId)
EndFunc   ;==>AddHero

;~ Description: Kicks a hero from the party.
Func KickHero($aHeroId)
	Return SendPacket(0x8, $HEADER_HERO_KICK, $aHeroId)
EndFunc   ;==>KickHero

;~ Description: Kicks all heroes from the party.
Func KickAllHeroes()
	Return SendPacket(0x8, $HEADER_HERO_KICK, 0x26)
EndFunc   ;==>KickAllHeroes

;~ Description: Add a henchman to the party.
Func AddNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_PARTY_INVITE_NPC, $aNpcId)
EndFunc   ;==>AddNpc

;~ Description: Kick a henchman from the party.
Func KickNpc($aNpcId)
	Return SendPacket(0x8, $HEADER_PARTY_KICK_NPC, $aNpcId)
EndFunc   ;==>KickNpc

;~ Description: Clear the position flag from a hero.
Func CancelHero($aHeroNumber)
	Local $lAgentID = GetHeroID($aHeroNumber)
	Return SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, $lAgentID, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelHero

;~ Description: Clear the position flag from all heroes.
Func CancelAll()
	Return SendPacket(0x10, $HEADER_HERO_FLAG_ALL, 0x7F800000, 0x7F800000, 0)
EndFunc   ;==>CancelAll

;~ Description: Clear all hero flags.
Func ClearPartyCommands()
	Return PerformAction(0xDB, 0x1E)
EndFunc   ;==>ClearPartyCommands

;~ Description: Place a hero's position flag.
Func CommandHero($aHeroNumber, $aX, $aY)
	Return SendPacket(0x14, $HEADER_HERO_FLAG_SINGLE, GetHeroID($aHeroNumber), FloatToInt($aX), FloatToInt($aY), 0)
EndFunc   ;==>CommandHero

;~ Description: Place the full-party position flag and optionally wait until heroes are within range of the destination.
Func CommandAll($aX, $aY, $WaitForDestination = False, $aDistanceToDestination = 156)
	SendPacket(0x10, $HEADER_HERO_FLAG_ALL, FloatToInt($aX), FloatToInt($aY), 0)
	Local $Timer = TimerInit()
	If $WaitForDestination Then
		Do
			Sleep(500)
			If TimerDiff($Timer) > 60000 Then Return False
			Out(GetNumberOfAlliesNearXY($aX, $aY, $aDistanceToDestination))
		Until GetNumberOfAlliesNearXY($aX, $aY, $aDistanceToDestination) = GetPartySize() Or GetNumberOfAllies(5000) < 2
	EndIf
	Return True
EndFunc   ;==>CommandAll
#EndRegion PartyCommands

;~ Description: Lock a hero onto a target.
Func LockHeroTarget($aHeroNumber, $aAgentID = 0) ;$aAgentID=0 Cancels Lock
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_LOCK_TARGET, $lHeroID, $aAgentID)
EndFunc   ;==>LockHeroTarget

;~ Description: Change a hero's aggression level.
Func SetHeroAggression($aHeroNumber, $aAggression) ;0=Fight, 1=Guard, 2=Avoid
	Local $lHeroID = GetHeroID($aHeroNumber)
	Return SendPacket(0xC, $HEADER_HERO_BEHAVIOR, $lHeroID, $aAggression)
EndFunc   ;==>SetHeroAggression

;~ Description: Disable a skill on a hero's skill bar.
; Func DisableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	; If Not GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
; EndFunc   ;==>DisableHeroSkillSlot

;~ Description: Enable a skill on a hero's skill bar.
; Func EnableHeroSkillSlot($aHeroNumber, $aSkillSlot)
	; If GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot) Then ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
; EndFunc   ;==>EnableHeroSkillSlot

;~ Description: Tests if a hero's skill slot is disabled.
; Func GetIsHeroSkillSlotDisabled($aHeroNumber, $aSkillSlot)
	; Return BitAND(2 ^ ($aSkillSlot - 1), DllStructGetData(GetSkillbar($aHeroNumber), 'Disabled')) > 0
; EndFunc   ;==>GetIsHeroSkillSlotDisabled

;~ Description: Internal use for enabling or disabling hero skills
Func ChangeHeroSkillSlotState($aHeroNumber, $aSkillSlot)
	Return SendPacket(0xC, $HEADER_HERO_SKILL_TOGGLE, GetHeroID($aHeroNumber), $aSkillSlot - 1)
EndFunc   ;==>ChangeHeroSkillSlotState

;~ Description: Order a hero to use a skill.
Func UseHeroSkill($aHero, $aSkillSlot, $aTarget = -2, $WaitForRecharge = False, $aTimeout = 8000)
	Local $lHeroAgentID = GetHeroID($aHero)
	Local $lSkillID = GetSkillbarSkillID($aSkillSlot, $aHero)
	Local $lSkill = GetSkillPtr($lSkillID)
	
	; If GetEnergy($lHeroAgentID) < GetEnergyReq($lSkill) Then Return
	If Not IsRecharged($aSkillSlot, $aHero) Then Return
	If GetIsDead($lHeroAgentID) Then Return
	
	Local $lDeadlock = TimerInit()
	SendPacket(0x14, $HEADER_HERO_USE_SKILL, $lHeroAgentID, $lSkillID, 0, ID($aTarget))
	
	If $WaitForRecharge Then
		Do
			Sleep(50)
		Until GetIsDead($aTarget) Or (Not IsRecharged($aSkillSlot, $aHero)) Or (TimerDiff($lDeadlock) > $aTimeout)
		Sleep(MemoryRead($lSkill + 64, "float") * 1000) ; Aftercast
	EndIf
	Return True
EndFunc   ;==>UseHeroSkill

#Region HeroInfo
;~ Description: Returns number of heroes you control.
Func GetHeroCount()
	Local $lOffset[5]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x2C
	Local $lHeroCount = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lHeroCount[1]
EndFunc   ;==>GetHeroCount

;~ Description: Returns agent ID of a hero.
Func GetHeroID($aHeroNumber)
	If $aHeroNumber == 0 Then Return GetMyID()
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	$lOffset[5] = 0x18 * ($aHeroNumber - 1)
	Local $lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lAgentID[1]
EndFunc   ;==>GetHeroID

;~ Description: Returns hero number by agent ID.
Func GetHeroNumberByAgentID($aAgentID)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	If ID($aAgentID) = GetMyID() Then Return 0
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aAgentID) Then Return $i
	Next
	Return False
EndFunc   ;==>GetHeroNumberByAgentID

;~ Description: Returns hero number by hero ID.
Func GetHeroNumberByHeroID($aHeroId)
	Local $lAgentID
	Local $lOffset[6]
	$lOffset[0] = 0
	$lOffset[1] = 0x18
	$lOffset[2] = 0x4C
	$lOffset[3] = 0x54
	$lOffset[4] = 0x24
	For $i = 1 To GetHeroCount()
		$lOffset[5] = 8 + 0x18 * ($i - 1)
		$lAgentID = MemoryReadPtr($mBasePointer, $lOffset)
		If $lAgentID[1] == ConvertID($aHeroId) Then Return $i
	Next
	Return 0
EndFunc   ;==>GetHeroNumberByHeroID

;~ Description: Returns hero's profession ID (when it can't be found by other means)
Func GetHeroProfession($aHeroNumber, $aSecondary = False)
	Local $lOffset[5] = [0, 0x18, 0x2C, 0x6BC, 0]
	Local $lBuffer
	$aHeroNumber = GetHeroID($aHeroNumber)
	For $i = 0 To GetHeroCount()
		$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
		If $lBuffer[1] = $aHeroNumber Then
			$lOffset[4] += 4
			If $aSecondary Then $lOffset[4] += 4
			$lBuffer = MemoryReadPtr($mBasePointer, $lOffset)
			Return $lBuffer[1]
		EndIf
		$lOffset[4] += 0x14
	Next
EndFunc   ;==>GetHeroProfession

Func PrintHeroEffects($heronumber = 0)
	Local $lSkillEffectID, $lTimestamp, $lDuration, $TimeRemaining
	$mEffectPtrArray = GetEffectsPtr(0, $heronumber)
	For $i = 1 To $mEffectPtrArray[0]
		$lSkillEffectID = MemoryRead($mEffectPtrArray[$i], 'long')
		$lEffectType = MemoryRead($mEffectPtrArray[$i] + 4, 'long')
		$lTimestamp = MemoryRead($mEffectPtrArray[$i] + 20, 'long')
		$lDuration = MemoryRead($mEffectPtrArray[$i] + 16, 'float')
		$TimeRemaining = $lDuration * 1000 - (GetSkillTimer() - $lTimestamp)
		; Out($aSkill_Name[$lSkillEffectID] & "(" & $lSkillEffectID & ", Type: " & $lEffectType & ")" & ", " & Round($TimeRemaining / 1000) & "s remaining")
		; Out(GetEffectTimeRemaining($lSkillEffectID))
	Next
EndFunc   ;==>PrintHeroEffects
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