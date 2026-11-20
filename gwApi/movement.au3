#include-once

;~ Description: Move to a location. No RNG
Func Move_($iX, $iY)

    DllStructSetData($g_d_Move, 2, $iX)
    DllStructSetData($g_d_Move, 3, $iY)
    DllStructSetData($g_d_Move, 4, 0)  ; Z coordinate (usually 0)

    Core_Enqueue($g_p_Move, 16)

    Return True
EndFunc ;==>Move_

;~ Description: Move to a location and wait until you reach it.
Func MoveTo($iX, $iY, $iRandom = 50)
    Local Static $iDistThreshold = 25 * 25

    Local $iBlocked = 0
    Local $pMe = Agent_GetAgentPtr(-2)
    Local $iInstanceType = GetInstanceType()

    Local $fDestX = $iX + Random(-$iRandom, $iRandom)
    Local $fDestY = $iY + Random(-$iRandom, $iRandom)

    Move_($fDestX, $fDestY)

    Do
        Sleep(100)

        If GetIsDead($pMe) Then Return False

        If $iInstanceType <> GetInstanceType() Then Return False

        If Not GetIsMoving($pMe) Then
            $iBlocked += 1

            $fDestX = $iX + Random(-$iRandom, $iRandom)
            $fDestY = $iY + Random(-$iRandom, $iRandom)

            Move_($fDestX, $fDestY)
        EndIf        

    Until GetDistanceSqrToXY($fDestX, $fDestY, $pMe) < $iDistThreshold Or $iBlocked > 14

    Return True
EndFunc ;==>MoveTo

;~ Description: Go to NPC until you are within actionable distance and interact with them
Func GoToNPC($npc = GetNearestNPCPtrToAgent(-2), $Interact = True)
    Local $lDeadlock = TimerInit()
    Do ; check if $npc is moving
        Sleep(100)
        If TimerDiff($lDeadlock) > 10000 Then ExitLoop
    Until Not GetIsMoving($npc)
    MoveToDistanceAwayfromAgent($npc)
    If $Interact Then Agent_GoNPC($npc)
EndFunc   ;==>GoToNPC

; Finds NPC nearest given coords and PlayerID and talks to him/her
Func GoToNPCNearXY($x, $y, $Interact = True)
    Local $npc = GetNearestNPCPtrToXY($x, $y)
    GoToNPC($npc, $Interact)
EndFunc   ;==>GoToNPCNearXY

;~ Description: Move to signpost until you are within actionable distance and interect with it.
Func GoToSignpost($aAgent)
    MoveToDistanceAwayfromAgent($aAgent)
    Agent_GoSignpost($aAgent)
EndFunc   ;==>GoToSignpost

; Finds signpost nearest given coords and PlayerID and talks to him/her
Func GoToSignpostNearXY($x, $y) ; $dialog
    $signpost = GetNearestSignpostPtrToXY($x, $y)
    GoToSignpost($signpost)
EndFunc   ;==>GoToSignpostNearXY

; some fancy movement functions.

; Move to certain distance away from an agent at a given angle
Func MoveToDistanceAwayfromAgent($aAgent = 0, $iRandom = 30, $aDistance = 100, $aSectors = 10)
    If $aAgent = 0 Or GetIsDead(-2) Then Return
    Local $lClosestXY = GetClosestXYinRangeOfAgent($aAgent, $aDistance, $aSectors)
    MoveTo($lClosestXY[0], $lClosestXY[1], $iRandom)
EndFunc   ;==>MoveToDistanceAwayfromAgent

; Returns the closest coordinates on a circle within a given radius of an agent
Func GetClosestXYinRangeOfAgent($aAgent = 0, $aDistance = 100, $sectors = 10)
    Local $lClosestXY[2], $lDistance
    Local $lNearestDistance = 100000000
    If $aAgent = 0 Or GetIsDead(-2) Then Return False
    Local $coords = GetAllXYinRangeOfAgent($aAgent, $aDistance, $sectors) 

    For $i = 0 To UBound($coords) - 1    ; Find coords closest to me
        $lDistance = GetDistanceSqrToXY($coords[$i][0], $coords[$i][1])
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
Func MoveToClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent = 0, $iRandom = 30, $aDistance = 100, $aSectors = 10)
    If $aAgent = 0 Or GetIsDead(-2) Then Return
    Local $lClosestXY = GetClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent, $aDistance, $aSectors) 
    MoveTo($lClosestXY[0], $lClosestXY[1], $iRandom)
EndFunc   ;==>MoveToClosestXYtoWaypointInRangeOfAgent

; Returns the closest coordinates to a wayppoint on a circle within a given radius of an agent
Func GetClosestXYtoWaypointInRangeOfAgent($wpX, $wpY, $aAgent, $aDistance = 100, $sectors = 360)
    Local $lClosestXY[2], $lDistance
    Local $lNearestDistance = 100000000
    If $aAgent = 0 Then Return False
    Local $coords = GetAllXYinRangeOfAgent($aAgent, $aDistance, $sectors)    ; divides circle into sectors

    For $i = 0 To UBound($coords) - 1    ; Find coords closest to waypoint
        $lDistance = ComputeDistanceSqr($coords[$i][0], $coords[$i][1], $wpX, $wpY)
        If $lDistance < $lNearestDistance Then
            $lNearestDistance = $lDistance
            $lClosestXY[0] = $coords[$i][0]
            $lClosestXY[1] = $coords[$i][1]
        EndIf
    Next
    Return $lClosestXY
EndFunc   ;==>GetClosestXYtoWaypointInRangeofAgent