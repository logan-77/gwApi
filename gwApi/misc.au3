Func CheckDisconnected()
	If Core_GetStatusError() Then Return True
	If Not Core_IsIngame() Then Return True
	If GetInstanceType() <> 2 And GetAgentExists(-2) Then Return False
	Return True
EndFunc ;==>CheckDisconnected

; Converts an Input in Seconds to a HH:MM:SS format
Func GetTimeString($aSeconds)
	$aSeconds = Int($aSeconds) ; make sure the param is integer
	Local $tmpMinutes = Floor($aSeconds/60) ; total amount of minutes
	Local $lHours = Floor($tmpMinutes/60) ; amount of hours, result
	Local $lSeconds = $aSeconds - $tmpMinutes*60 ; seconds in the current minute, result
	Local $lMinutes = $tmpMinutes - $lHours*60 ; minutes in the current hour, result
	Local $lTimeString = ""
	
	If $lHours < 10 Then
		If $lMinutes < 10 Then
			If $lSeconds < 10 Then
				$lTimeString = '0' & $lHours & ':0' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = '0' & $lHours & ':0' & $lMinutes & ':' & $lSeconds
			EndIf
		ElseIf $lMinutes >= 10 Then
			If $lSeconds < 10 Then
				$lTimeString = '0' & $lHours & ':' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = '0' & $lHours & ':' & $lMinutes & ':' & $lSeconds
			EndIf
		EndIf
	ElseIf $lHours >= 10 Then
		If $lMinutes < 10 Then
			If $lSeconds < 10 Then
				$lTimeString = $lHours & ':0' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = $lHours & ':0' & $lMinutes & ':' & $lSeconds
			EndIf
		ElseIf $lMinutes >= 10 Then
			If $lSeconds < 10 Then
				$lTimeString = $lHours & ':' & $lMinutes & ':0' & $lSeconds
			ElseIf $lSeconds >= 10 Then
				$lTimeString = $lHours & ':' & $lMinutes & ':' & $lSeconds
			EndIf
		EndIf
	EndIf
	Return $lTimeString
EndFunc ;==> GetTimeString
