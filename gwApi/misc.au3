Func CheckDisconnected()
	If GetInstanceType() <> 2 And GetAgentExists(-2) Then Return False
	Return True
EndFunc ;==>CheckDisconnected
