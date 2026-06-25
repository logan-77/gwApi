Func CheckDisconnected()
    If Core_GetStatusError() Then Return True
    If Not Core_IsIngame() Then Return True
    If GetInstanceType() <> 2 And GetAgentExists(-2) Then Return False
    Return True
EndFunc ;==>CheckDisconnected

Func GetArrayFirstElement($aArray)
    If Not IsArray($aArray) Then _
        Exit MsgBox(16, "Error", "GetArrayFirstElement(): Parameter is not an array")

    If UBound($aArray) = 0 Then _
        Exit MsgBox(16, "Error", "GetArrayFirstElement(): Empty array")

    Return $aArray[0]
EndFunc ;==>GetArrayFirstElement

Func EnsureArray(ByRef $vValue)
    If Not IsArray($vValue) Then
        Local $aTmp[1] = [$vValue]
        $vValue = $aTmp
    EndIf

    Return UBound($vValue)
EndFunc ;==>EnsureArray

Func IsChecked($hCbx)
    Return GUICtrlRead($hCbx) = $GUI_CHECKED
EndFunc ;==>IsChecked

Func IsUnchecked($hCbx)
    Return GUICtrlRead($hCbx) = $GUI_UNCHECKED
EndFunc ;==>IsUnchecked

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
