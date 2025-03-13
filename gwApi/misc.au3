Func CheckDisconnected()
	If GetInstanceType() <> 2 And GetAgentExists(-2) Then Return False
	Return True
EndFunc ;==>CheckDisconnected

#Region Rendering
;~ Description: Enable graphics rendering.
Func EnableRendering()
    If GetRenderEnabled() Then Return 1
	MemoryWrite($mDisableRendering, 0)
EndFunc ;==>EnableRendering

;~ Description: Disable graphics rendering.
Func DisableRendering()
	If GetRenderDisabled() Then Return 1
	MemoryWrite($mDisableRendering, 1)
EndFunc ;==>DisableRendering

;~ Description: Checks if Rendering is disabled
Func GetRenderDisabled()
	Return MemoryRead($mDisableRendering) = 1
EndFunc ;==>GetRenderDisabled

;~ Description: Checks if Rendering is enabled
Func GetRenderEnabled()
	Return MemoryRead($mDisableRendering) = 0
EndFunc ;==>GetRenderEnabled

Func ToggleRendering()
	If GetRenderDisabled() Then
		EnableRendering()
		WinSetState(GetWindowHandle(), "", @SW_SHOW)
	Else
		DisableRendering()
		WinSetState(GetWindowHandle(), "", @SW_HIDE)
		ClearMemory()
	EndIf
EndFunc ;==>ToggleRendering

Func PurgeHook()
	If GetRenderEnabled() Then Return 1
	ToggleRendering()
	Sleep(10000)
	ToggleRendering()
EndFunc ;==>PurgeHook

Func ToggleRendering_()
	If GetRenderDisabled() Then
        EnableRendering()
		ClearMemory()
	Else
		DisableRendering()
		ClearMemory()
	EndIf
EndFunc ;==>ToggleRendering_

Func PurgeHook_()
	If GetRenderEnabled() Then Return 1
    ToggleRendering_()
    Sleep(10000)
    ToggleRendering_()
EndFunc ;==PurgeHook_
#EndRegion Rendering