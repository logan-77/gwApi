#include-once

;~ Description: Move to a location. No RNG
Func Move_($aX, $aY)
	If Not GetAgentExists(-2) Then Return False
	DllStructSetData($mMove, 2, $aX)
	DllStructSetData($mMove, 3, $aY)
	Enqueue($mMovePtr, 16)
	Return True
EndFunc ;==>Move_

;~ Description: Move to a location and wait until you reach it.
Func MoveTo($aX, $aY, $aRandom = 50)
	Local $lBlocked = 0, $lMe = GetAgentPtr(-2)
	Local $lMapLoading = GetInstanceInfo("Type"), $lMapLoadingOld
	Local $lDestX = $aX + Random(-$aRandom, $aRandom)
	Local $lDestY = $aY + Random(-$aRandom, $aRandom)

	Move_($lDestX, $lDestY)
	Sleep(200)
	Do
		If GetIsDead($lMe) Then Return False

		$lMapLoadingOld = $lMapLoading
		$lMapLoading = GetInstanceInfo("Type")
		If $lMapLoading <> $lMapLoadingOld Then Return False

		If MoveX($lMe) = 0 And MoveY($lMe) = 0 Then
			$lBlocked += 1
			$lDestX = $aX + Random(-$aRandom, $aRandom)
			$lDestY = $aY + Random(-$aRandom, $aRandom)
			Move_($lDestX, $lDestY)
		EndIf
		Sleep(100)
	Until GetDistanceToXY($lDestX, $lDestY, $lMe) < 25 Or $lBlocked > 14
	Return True
EndFunc   ;==>MoveTo

;~ Description: Go to NPC until you are within actionable distance and interact with them
Func GoToNPC($npc = GetNearestNPCPtrToAgent(-2), $Interact = True)
	Local $lDeadlock = TimerInit()
	Do	; check if $npc is moving
		Sleep(100)
		If TimerDiff($lDeadlock) > 10000 Then ExitLoop
	Until Not GetIsMoving($npc)
	MoveToDistanceAwayfromAgent($npc)
	If $Interact Then GoNPC($npc)
EndFunc   ;==>GoToNPC

; Finds NPC nearest given coords and PlayerID and talks to him/her
Func GoToNPCNearXY($x, $y, $Interact = True)
	Local $npc = GetNearestNPCPtrToXY($x, $y)
	GoToNPC($npc, $Interact)
EndFunc   ;==>GoToNPCNearXY

;~ Description: Move to signpost until you are within actionable distance and interect with it.
Func GoToSignpost($aAgent)
	MoveToDistanceAwayfromAgent($aAgent)
	GoSignpost($aAgent)
EndFunc   ;==>GoToSignpost

; Finds signpost nearest given coords and PlayerID and talks to him/her
Func GoToSignpostNearXY($x, $y) ; $dialog
	$signpost = GetNearestSignpostPtrToXY($x, $y)
	GoToSignpost($signpost)
EndFunc   ;==>GoToSignpostNearXY

; some fancy movement functions.

; Move to certain distance away from an agent at a given angle
Func MoveToDistanceAwayfromAgent($aAgent = 0, $aRandom = 30, $aDistance = 100, $aSectors = 10)
	If $aAgent = 0 Or GetIsDead(-2) Then Return
	Local $lClosestXY = GetClosestXYinRangeOfAgent($aAgent, $aDistance, $aSectors)
	MoveTo($lClosestXY[0], $lClosestXY[1], $aRandom)
EndFunc   ;==>MoveToDistanceAwayfromAgent

; Returns the closest coordinates on a circle within a given radius of an agent
Func GetClosestXYinRangeOfAgent($aAgent = 0, $aDistance = 100, $sectors = 10)
	Local $lClosestXY[2], $lDistance
	Local $lNearestDistance = 100000000
	If $aAgent = 0 Or GetIsDead(-2) Then Return False
	Local $coords = GetAllXYinRangeOfAgent($aAgent, $aDistance, $sectors) 

	For $i = 0 To UBound($coords) - 1    ; Find coords closest to me
		$lDistance = GetPseudoDistanceToXY($coords[$i][0], $coords[$i][1])
		If $lDistance < $lNearestDistance Then
			$lNearestDistance = $lDistance
			$lClosestXY[0] = $coords[$i][0]    ; select closest X but some degrees off axis
			$lClosestXY[1] = $coords[$i][1]    ; select closest Y but some degrees off axis
		EndIf
	Next
	Return $lClosestXY
EndFunc   ;==>GetClosestXYinRangeOfAgent

; Returns an array of all coordinates equidistance to an agent assuming a given number of sectors for that circle
Func GetAllXYinRangeOfAgent($aAgent = 0, $aDistance = 100, $sectors = 360)
	If $aAgent = 0 Then Return False
	Local $coords[$sectors][2]
	For $i = 0 To $sectors - 1 ; divides circle into sectors
		$radian = 2 * 3.141592653589 * ($i / $sectors)
		$coords[$i][0] = ($aDistance * Cos($radian)) + X($aAgent)
		$coords[$i][1] = ($aDistance * Sin($radian)) + Y($aAgent)
	Next
	Return $coords
EndFunc   ;==>GetAllXYinRangeOfAgent

; Move to certain distance away from an agent at a given angle
Func MoveToClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent = 0, $aRandom = 30, $aDistance = 100, $aSectors = 10)
	If $aAgent = 0 Or GetIsDead(-2) Then Return
	Local $lClosestXY = GetClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent, $aDistance, $aSectors)	
	MoveTo($lClosestXY[0], $lClosestXY[1], $aRandom)
EndFunc   ;==>MoveToClosestXYtoWaypointInRangeOfAgent

; Returns the closest coordinates to a wayppoint on a circle within a given radius of an agent
Func GetClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent, $aDistance = 100, $sectors = 360)
	Local $lClosestXY[2], $lDistance
	Local $lNearestDistance = 100000000
	If $aAgent = 0 Then Return False
	Local $coords = GetAllXYinRangeOfAgent($aAgent, $aDistance, $sectors)    ; divides circle into sectors

	For $i = 0 To UBound($coords) - 1    ; Find coords closest to waypoint
		$lDistance = ComputePseudoDistance($coords[$i][0], $coords[$i][1], $wpX, $wpY)
		If $lDistance < $lNearestDistance Then
			$lNearestDistance = $lDistance
			$lClosestXY[0] = $coords[$i][0]
			$lClosestXY[1] = $coords[$i][1]
		EndIf
	Next
	Return $lClosestXY
EndFunc   ;==>GetClosestXYtoWaypointInRangeofAgent