#include-once
#Region Items
Func GetItemExists($aItemID)
	Return GetItemPtr($aItemID) <> 0
EndFunc ;==>GetItemExists

;~ Description: Returns the AgentID of Item; $aItem = Ptr/Struct/ID
Func GetItemAgentID($aItem) 
	Return MemoryRead(GetItemPtr($aItem) + 4, 'long')
EndFunc ;==>GetItemAgentID

;~ Description: Returns the Type of Item; $aItem = Ptr/Struct/ID
Func GetItemType($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 32, 'byte')
EndFunc ;==>GetItemType

;~ Description: Returns the ExtraID of Item; $aItem = Ptr/Struct/ID
Func GetItemExtraID($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 34, 'short')
EndFunc ;==>GetItemExtraID

;~ Description: Returns the Value of Item; $aItem = Ptr/Struct/ID
Func GetItemValue($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 36, 'short')
EndFunc ;==>GetItemValue

;~ Description: Returns the ModelID of Item; $aItem = Ptr/Struct/ID
Func GetItemModelID($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 44, 'long')
EndFunc ;==>GetItemModelID

;~ Description: Returns rarity (name color) of an item; $aItem = Ptr/Struct/ID
Func GetRarity($aItem)
	Local $lNameString = MemoryRead(GetItemPtr($aItem) + 56, "ptr")
	If $lNameString = 0 Then Return
	Return MemoryRead($lNameString, "ushort")
EndFunc ;==>GetRarity

;~ Description: Returns quantity of an item; $aItem = Ptr/Struct/ID
Func GetItemQuantity($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 0x4C, 'short')
EndFunc ;==>GetQuantity

;~ Description: Tests if an item is identified.
Func GetIsIDed($aItem)
	Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 1) > 0
EndFunc ;==>GetIsIDed

;~ Descriptions: Tests if an item is unidentfied and can be identified.
Func GetIsUnIDed($aItem)
	Return BitAND(MemoryRead(GetItemPtr($aItem) + 40, 'long'), 0x800000) > 0
EndFunc ;==>GetIsUnIDed

;~ Description: Returns True if item has a suffix, prefix or inscription in it that isnt fixed.
Func GetIsUpgraded($lItemPtr)
	Return BitAND(MemoryRead($lItemPtr + 40, 'long'), 0x4110000) > 0
EndFunc ;==>GetIsUpgraded

Func GetItemPtrBySlot($aBag, $aSlot)
	Local $lBagPtr = GetBagPtr($aBag)
	Local $lItemArrayPtr = MemoryRead($lBagPtr + 0x18, 'ptr')
	Return MemoryRead($lItemArrayPtr + 4 * ($aSlot - 1), 'ptr')
EndFunc   ;==>GetItemPtrBySlot

; Return first ItemPtr by ModelID in specified bags. Zero if no Item is found.
Func GetItemPtrByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $aIncludeEquipmentPack = False, $aIncludeMats = False)
	Local $lItemPtr, $lBagPtr, $lItemArrayPtr, $lModelID, $lCount = 0
	
	If IsArray($aModelID) Then
		Local $lReturnPtr[UBound($aModelID)]
		For $i = 0 To UBound($aModelID) - 1
			$lReturnPtr[$i] = 0
		Next
	Else
		Local $lReturnPtr = 0
	EndIf
	
	If IsArray($aModelID) Then
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				$lModelID = GetItemModelID($lItemPtr)
				For $i = 0 To UBound($aModelID) - 1
					If $lReturnPtr[$i] <> 0 Or $lModelID <> $aModelID[$i] Then ContinueLoop
					$lReturnPtr[$i] = $lItemPtr
					$lCount += 1
					If $lCount = UBound($aModelID) Then
						Return $lReturnPtr
					EndIf
					ExitLoop
				Next				
			Next
		Next	
	Else
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				If GetItemModelID($lItemPtr) = $aModelID Then
					Return $lItemPtr
				EndIf
			Next
		Next
	EndIf
	Return $lReturnPtr
EndFunc ;==>GetItemPtrByModelID

; Returns the first Item by ModelID found in Inventory; If no Item is found Returns Zero
Func GetItemInInventory($aModelID)
	Return GetItemPtrByModelID($aModelID, 1, 4)
EndFunc ;==>GetItemInInventory

; Returns the first Item by ModelID found in Storage; If no Item is found Returns Zero
Func GetItemInChest($aModelID)
	Return GetItemPtrByModelID($aModelID, 8, 12)
EndFunc ;==>GetItemInChest

;~ Description: Returns amount of items of $aModelID in selected bags.
Func CountItemByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $aCountSlotsOnly = False, $aIncludeEquipmentPack = False, $aIncludeMats = False)
	Local $lItemPtr, $lBagPtr, $lItemArrayPtr, $lModelID
	If IsArray($aModelID) Then
		Local $lCount[UBound($aModelID)]
		For $i = 0 To UBound($aModelID) - 1
			$lCount[$i] = 0
		Next
	Else
		Local $lCount = 0
	EndIf
	
	If IsArray($aModelID) Then
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				$lModelID = GetItemModelID($lItemPtr)
				For $i = 0 To UBound($aModelID) - 1
					If $lModelID = $aModelID[$i] Then
						If $aCountSlotsOnly Then
							$lCount[$i] += 1
						Else
							$lCount[$i] += GetItemQuantity($lItemPtr)
						EndIf
					EndIf
				Next
			Next
		Next	
	Else
		For $bag = $aFirstBag To $aLastBag
			If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
			If $bag = 6 And Not $aIncludeMats Then ContinueLoop
			If $bag = 7 Then ContinueLoop
			$lBagPtr = GetBagPtr($bag)
			If $lBagPtr = 0 Then ContinueLoop
			$lItemArrayPtr = MemoryRead($lBagPtr + 24, 'ptr')
			For $slot = 0 To GetMaxSlots($lBagPtr) - 1
				$lItemPtr = MemoryRead($lItemArrayPtr + 4 * $slot, 'ptr')
				If $lItemPtr = 0 Then ContinueLoop
				If GetItemModelID($lItemPtr) = $aModelID Then
					; Out("Bag: " & $bag & "; Slot: " & ($slot+1))
					If $aCountSlotsOnly Then
						$lCount += 1
					Else
						$lCount += GetItemQuantity($lItemPtr)
					EndIf
				EndIf
			Next
		Next	
	EndIf
	Return $lCount
EndFunc ;==>CountItemByModelID

; Returns the amount of an Item in Inventory by ModelID
Func GetQuantityInventory($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 1, 4, $aCountSlotsOnly)
EndFunc ;==>GetQuantityInventory

; Return the amount of an Item in Chest by ModelID
Func GetQuantityChest($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 8, 12, $aCountSlotsOnly)
EndFunc ;==>GetQuantityChest

; Returns the amount of an Item by ModelID in Inventory+Chest
Func GetQuantity($aModelID, $aCountSlotsOnly = False)
	Return CountItemByModelID($aModelID, 1, 12, $aCountSlotsOnly)
EndFunc ;==>GetQuantity

;~ === Move Items around ===
Func UseItemByModelID($aModelID)
	Local $lItemPtr = GetItemInInventory($aModelID)
	If $lItemPtr = 0 Then Return False
	
	UseItem($lItemPtr)
	PingSleep(100)
	Return True
EndFunc ;==>UseItemByModelID

;~ Func PickUpItem($aItem)
;~ 	Return SendPacket(0xC, $HEADER_INTERACT_ITEM, ItemID($aItem), 0)
;~ EndFunc   ;==>PickUpItem

;Drops all Items to ground, if in explorable
Func DropAll()
	If GetInstanceInfo("Type") <> $instancetype_explorable Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
	Return 1
EndFunc ;==>DropAll

;Drops all Items of given Type to ground, if in explorable
Func DropItemsByType($aType)
	If GetInstanceInfo("Type") <> $instancetype_explorable Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
	Return 1
EndFunc ;==>DropItemsByType

;Drops all Items of given ModelID to ground, if in explorable
Func DropItemsByModelID($aModelID, $aFullStack = False)
	If GetInstanceInfo("Type") <> $instancetype_explorable Then Return 0
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			DropItem($lItemPtr)
			PingSleep(100)
		Next
	Next
EndFunc ;==>DropItemsByModelID

;Description: Destroys an Item
Func DestroyItem($aItem)
	SendPacket(0x8, $HEADER_ITEM_DESTROY, ItemID($aItem))
	PingSleep(100)
EndFunc   ;==>DestroyItem

;~ Description: Moves an Item and can split up a Stack
Func MoveItemEx($aItem, $aBag, $aSlot, $aAmount = 0)
	Local $lQuantity = GetItemQuantity($aItem)
	If $aAmount = 0 Or $aAmount > $lQuantity Then $aAmount = $lQuantity
	If $aAmount >= $lQuantity Then
		SendPacket(0x10, $HEADER_ITEM_MOVE, ItemID($aItem), BagID($aBag), $aSlot - 1)
	Else
		SendPacket(0x14, $HEADER_ITEM_SPLIT_STACK, ItemID($aItem), $aAmount, BagID($aBag), $aSlot - 1)
	EndIf
EndFunc ;==>MoveItemEx

Func PickUpLootEx($iMaxDist = 2500)
	Local $lAgentPtr, $lAgentID, $lItemPtr, $lOwner

	Local $lAgentPtrArray = GetAgentPtrArray(1, 0x400)
	For $i = 1 To $lAgentPtrArray[0]
		$lAgentPtr = $lAgentPtrArray[$i]
		$lAgentID = ID($lAgentPtr)
		$lItemPtr = GetItemPtrByAgentID($lAgentID) ; GetItemPtrByAgentPtr($lAgentPtr)
		If $lItemPtr = 0 Then ContinueLoop
		$lOwner = MemoryRead($lAgentPtr + 196, 'long')
		If $lOwner <> 0 And $lOwner <> GetMyID() Then ContinueLoop ; assigned to another player
		If CanPickUpEx($lItemPtr) And GetDistance($lAgentPtr) < $iMaxDist Then
			If GetDistanceToXY(X($lAgentPtr), Y($lAgentPtr)) > 250 Then MoveTo(X($lAgentPtr), Y($lAgentPtr))
			$lDeadlock = TimerInit()
			Do
				PickUpItem($lAgentID)
				PingSleep(500)
			Until GetAgentPtr($lAgentID) <> $lAgentPtr Or GetIsDead(-2) Or TimerDiff($lDeadlock) > 2000
		EndIf
	Next
EndFunc   ;==>PickupLootEx

;~ Description: Returns Itemptr by agentid.
Func GetItemPtrByAgentID($aAgentID)
	Return GetItemPtr(MemoryRead(GetAgentPtr($aAgentID) + 200))
EndFunc   ;==>GetItemPtrByAgentID

;~ Description: Looks for free Slot and moves Item to Chest.
;~ If $aStackItem=True, it will try to stack Items with same ModelID
Func MoveItemToChest($aItem, $aStackItem = False)
	Local $lItemPtr, $lBagPtr
	Local $lQuantity = 0, $lModelID = 0, $lMoveItem = False
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then
				$lMoveItem = True
				ExitLoop 2
			EndIf
			If $aStackItem And GetItemModelID($lItemPtr) = GetItemModelID($aItem) Then
				If (GetItemQuantity($lItemPtr) + GetItemQuantity($aItem)) <= 250 Then
					$lMoveItem = True
					ExitLoop 2
				EndIf
			EndIf
		Next
	Next
	
	If $lMoveItem = False Then Return False
	MoveItem($aItem, $bag, $slot)
	PingSleep(200)
	Return True
EndFunc ;==>MoveItemToChest

;~ Description: Looks for free Slot and moves Item to Inventory
Func MoveItemToInventory($aItem)
	Local $lItemPtr, $lBagPtr, $lMoveItem = False
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			If GetItemPtrBySlot($lBagPtr, $slot) = 0 Then
				$lMoveItem = True
				ExitLoop 2
			EndIf
		Next
	Next
	
	If $lMoveItem = False Then Return False
	MoveItem($aItem, $bag, $slot)
	PingSleep(200)
	Return True
EndFunc ;==>MoveItemToInventory

Func StoreItemsByModelID($aModelID, $aFullStack = False)
	GetInstanceInfo("Type")
	If GetInstanceInfo("Type") <> $instancetype_outpost Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToChest($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>StoreItemsByModelID

;Stores all Items of given Type
Func StoreItemsByType($aType, $aFullStack = False)
	If GetInstanceInfo("Type") <> $instancetype_outpost Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToChest($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>StoreItemsByType

Func WithdrawItemsByModelID($aModelID, $aFullStack = False)
	If GetInstanceInfo("Type") <> $instancetype_outpost Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemModelID($lItemPtr) <> $aModelID Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToInventory($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>WithdrawItemsByModelID

;Stores all Items of given Type
Func WithdrawItemsByType($aType, $aFullStack = False)
	If GetInstanceInfo("Type") <> $instancetype_outpost Then Return False
	Local $lItemPtr, $lBagPtr
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) <> $aType Then ContinueLoop
			If $aFullStack And GetItemQuantity($lItemPtr) < 250 Then ContinueLoop
			If MoveItemToInventory($lItemPtr) = False Then Return
		Next
	Next
EndFunc ;==>WithdrawItemsByType

Func GetItemInInventoryByType($aType)
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) = $aType Then Return $lItemPtr
		Next
	Next
	Return 0
EndFunc ;==>GetItemInInventoryByType

Func GetItemInChestByType($aType)
	Local $lItemPtr, $lBagPtr
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If GetItemType($lItemPtr) = $aType Then Return $lItemPtr
		Next
	Next
	Return 0
EndFunc ;==>GetItemInChestByType

#Region Identify And Salvage
Func IdentifyItem2($aItem, $aIdKit = FindIDKit())	
	If GetIsIDed($aItem) Then Return 1
	
	Local $lIdKit = 0
	If IsPtr($aIDKit) Then
		$lIdKit = $aIdKit
	Else
		$lIdKit = FindIDKit()
	EndIf
	If $lIdKit = 0 Then Return 0
	
	Sendpacket(0xC, $HEADER_ITEM_IDENTIFY, ItemID($lIdKit), ItemID($aItem))
	Local $lDeadlock = TimerInit()
	Do
		Sleep(50)
	Until GetIsIDed($aItem) Or TimerDiff($lDeadlock) > 5000
	If TimerDiff($lDeadlock) > 5000 Then Return 0
	Return 1
EndFunc ;==>IdentifyItem

;~ Description: Returns ItemPtr of ID kit in inventory. Return 0, if no Kit found.
Func FindIDKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2989
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2) < $lUses Then
						$lUses = $lValue / 2
						$lKitPtr = $lItemPtr
					EndIf
				Case 5899
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2.5) < $lUses Then
						$lUses = $lValue / 2.5
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindIDKit

;~ Description: Returns ItemPtr of ID kit in inventory. Return 0, if no Kit found.
Func FindSuperiorIDKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 5899
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2.5) < $lUses Then
						$lUses = $lValue / 2.5
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindSuperiorIDKit

;~ Description: Starts a salvaging session of an item.
Func StartSalvage2($aItem, $aSalvageKit = 0, $aCheap = True)
	Local $lOffset[4] = [0, 0x18, 0x2C, 0x690]
	Local $lSalvageSessionID = MemoryReadPtr($mBasePointer, $lOffset)
	Local $lSalvageKit = 0

	If IsPtr($aSalvageKit) Then
		$lSalvageKit = $aSalvageKit
	ElseIf $aCheap Then
		$lSalvageKit = FindCheapSalvageKit()
	Else
		$lSalvageKit = FindExpertSalvageKit()
	EndIf
	If $lSalvageKit = 0 Then Return 0

	DllStructSetData($mSalvage, 2, ItemID($aItem))
	DllStructSetData($mSalvage, 3, ItemID($lSalvageKit))
	DllStructSetData($mSalvage, 4, $lSalvageSessionID[1])
	Enqueue($mSalvagePtr, 16)
	Return 1
EndFunc   ;==>StartSalvage

;~ Description: Returns ItemPtr of cheap Salvage Kit in inventory. Return 0, if no Kit found.
Func FindCheapSalvageKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2992
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 2) < $lUses Then
						$lUses = $lValue / 2
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindCheapSalvageKit

;~ Description: Returns ItemPtr of any Salvage Kit in inventory. Return 0, if no Kit found.
Func FindExpertSalvageKit($aCheckUses = False)
	Local $lItemPtr, $lValue, $lKitPtr = 0, $lUses = 101
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 to GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lValue = GetItemValue($lItemPtr)
			Switch GetItemModelID($lItemPtr)
				Case 2991
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 8) < $lUses Then
						$lUses = $lValue / 8
						$lKitPtr = $lItemPtr
					EndIf
				; Case 2992
					; If $aCheckUses = False Then Return $lItemPtr
					; If ($lValue / 2) < $lUses Then
						; $lUses = $lValue / 2
						; $lKitPtr = $lItemPtr
					; EndIf
				Case 5900
					If $aCheckUses = False Then Return $lItemPtr
					If ($lValue / 10) < $lUses Then
						$lUses = $lValue / 10
						$lKitPtr = $lItemPtr
					EndIf
				Case Else
					ContinueLoop
			EndSwitch
		Next
	Next
	Return $lKitPtr
EndFunc   ;==>FindExpertSalvageKit
#EndRegion Identify and Salvage

#Region Buy and Sell
; Buys the cheapest Salvage Kit
Func BuySalvageKit()
	BuyItem(2, 1, 100)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuySalvageKitEmbark()
	BuyItem(3, 1, 100)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

; Buys the cheapest Salvage Kit
Func BuyExpertSalvageKit()
	BuyItem(3, 1, 400)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuyExpertSalvageKitEmbark()
	BuyItem(4, 1, 400)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

; Buys the cheapest Salvage Kit
Func BuySuperiorSalvageKit()
	BuyItem(4, 1, 2000)
	PingSleep(1000)
EndFunc ;==>BuySalvageKit

; Buys the cheapest Salvage Kit, use only in Embark Beach
Func BuySuperiorSalvageKitEmbark()
	BuyItem(5, 1, 2000)
	PingSleep(1000)
EndFunc ;==>BuySalvageKitEmbark

;~ Description: Buys an ID kit.
Func BuyIDKit()
	BuyItem(5, 1, 100)
	PingSleep(1000)
EndFunc   ;==>BuyIDKit

;~ Description: Buys an ID kit, use only in Embark Beach
Func BuyIDKitEmbark()
	BuyItem(6, 1, 100)
	PingSleep(1000)
EndFunc   ;==>BuyIDKit

; Buys Superior ID kit.
Func BuySuperiorIDKit()
	BuyItem(6, 1, 500)
	PingSleep(1000)
EndFunc

; Buys Superior ID kit, use only in Embark Beach
Func BuySuperiorIDKitEmbark()
	BuyItem(7, 1, 500)
	PingSleep(1000)
EndFunc
#EndRegion Buy and Sell

;~ === Slots ===
;~ Description: Returns amount of slots of bag.
Func GetMaxSlots($aBag)
	Local $lBagPtr = GetBagPtr($aBag)
	If $lBagPtr = 0 Then Return 0
	Return MemoryRead($lBagPtr + 32, 'long')
EndFunc   ;==>GetMaxSlots

;~ Description: Returns amount of slots available to character.
Func GetMaxTotalSlots()
   Local $SlotCount = 0, $lBagPtr
   For $Bag = 1 to 4
	  $lBagPtr = GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   For $Bag = 8 to 12
	  $lBagPtr = GetBagPtr($Bag)
	  $SlotCount += MemoryRead($lBagPtr + 32, 'long')
   Next
   Return $SlotCount
EndFunc   ;==>GetMaxTotalSlots

;~ Description: Returns number of free slots in inventory
Func CountFreeSlots()
	Local $lCount = 0, $lBagPtr
	For $lBag = 1 To 4
		$lBagPtr = GetBagPtr($lBag)
		If $lBagPtr = 0 Then ContinueLoop
		$lCount += MemoryRead($lBagPtr + 32, "long") - MemoryRead($lBagPtr + 16, "long")
	Next
	Return $lCount
EndFunc   ;==>CountFreeSlots

;~ Description: Retursn number of free slots in storage
Func CountFreeSlotsStorage()
	Local $lCount = 0, $lBagPtr
	For $lBag = 8 To 12
		$lBagPtr = GetBagPtr($lBag)
		If $lBagPtr = 0 Then ContinueLoop
		$lCount += MemoryRead($lBagPtr + 32, "long") - MemoryRead($lBagPtr + 16, "long")
	Next
	Return $lCount
EndFunc ;==>CountFreeSlotsStorage
#EndRegion Items

#Region Bag
Func BagID($aBag)
	If IsPtr($aBag) Then
		Return MemoryRead($aBag + 8, "long")
	ElseIf IsDllStruct($aBag) Then
		Return DllStructGetData($aBag, "ID")
	Else
		Return MemoryRead(GetBagPtr($aBag) + 8, "long")
	EndIf
EndFunc   ;==>BagID

;~ Description: Returns the Bag of an item by ItemID/ItemPtr/ItemStruct
;~ Is Zero if the item has been destroyed(e.g. IdKit)
Func GetBagPtrByItem($aItem)
	Return MemoryRead(GetItemPtr($aItem) + 0xC, 'ptr')
EndFunc   ;==>GetBagPtrByItem

;~ Description: Returns the Bag Index of an item by ItemID/ItemPtr/ItemStruct
Func GetBagNumberByItem($aItem)
	Local $lBagPtr = GetBagPtrByItem($aItem)
	Return MemoryRead($lBagPtr + 4, "long") + 1
EndFunc   ;==>GetBagNumberByItem
#EndRegion Bag

#Region ModStruct
;~ Description: Returns modstruct of an item.
Func GetModStruct($aItem)
	If IsString($aItem) Then Return $aItem
	Local $lItemPtr = GetItemPtr($aItem)
	If $lItemPtr = 0 Then Return 0

	Local $lModStructPtr = GetItemInfoByPtr($lItemPtr, "ModStruct")
    If $lModStructPtr = 0 Then Return 0

	Local $lModStructSize = GetItemInfoByPtr($lItemPtr, "ModStructSize")
    If $lModStructSize = 0 Then Return 0
	
	Return MemoryRead($lModStructPtr, 'Byte[' & $lModStructSize * 4 & ']')
EndFunc   ;==>GetModStruct

;~ Description: Returns an array of a the requested mod.
Func GetModByIdentifier($aItem, $aIdentifier)
	Local $lReturn[2] = [0, 0]
	Local $lString = StringTrimLeft(GetModStruct($aItem), 2)
	For $i = 0 To StringLen($lString) / 8 - 2
		If StringMid($lString, 8 * $i + 5, 4) == $aIdentifier Then
			$lReturn[0] = Int("0x" & StringMid($lString, 8 * $i + 1, 2))
			$lReturn[1] = Int("0x" & StringMid($lString, 8 * $i + 3, 2))
			ExitLoop
		EndIf
	Next
	Return $lReturn
EndFunc   ;==>GetModByIdentifier

;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq($aItem)
	Local $lMod = GetModByIdentifier($aItem, '9827')
	Return $lMod[0]
EndFunc   ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute($aItem)
	Local $lMod = GetModByIdentifier($aItem, '9827')
	Return $lMod[1]
EndFunc   ;==>GetItemAttribute

;~ Description: Returns the maximum Dmg/Energy/Armor
Func GetItemMaxDmg($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc ;==>GetItemMaxDmg

;~ Description: Returns the minimum Dmg/Energy/Armor
Func GetItemMinDmg($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Return Int("0x" & StringMid($lModString, $lPos - 4, 2))
EndFunc ;==>GetItemMinDmg

;~ Description: Returns Dmg/Energy/Armor
Func GetItemDmg($aItem)
	Local $lModString = GetModStruct($aItem)
	Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
	If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
	If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
	If $lPos = 0 Then Return 0
	Local $lMod[2] = [0, 0]
	$lMod[0] = Int("0x" & StringMid($lModString, $lPos - 4, 2))
	$lMod[1] = Int("0x" & StringMid($lModString, $lPos - 2, 2))
	Return $lMod
EndFunc ;==>GetItemDmg

;~ Description: Checks if weapon has +20% ench upgrade
Func Is20Ench($aItem)
	If StringInStr(GetModStruct($aItem), "1400B822") > 0 Then Return True
	Return False
EndFunc ;==>Is20Ench

;~ Description: Checks if weapon has +45^ench upgrade
Func Is45HPEnch($aItem)
	Local $l45 = GetModByIdentifier($aItem, '6823')
	If $l45[1] = 45 Then Return True
	Return False
EndFunc ;==>Is45HPEnch

;~ Description: Checks if weapon has +30HP upgrade
Func Is30HP($aItem)
	If GetItemType($aItem) <> $item_type_shield Then Return False
	Local $l30 = GetModByIdentifier($aItem, '4823')
	If $l30[1] = 30 Then Return True
	Return False
EndFunc ;==>Is30HP

; Mod: +5 energy / "I have the power!"
Func Is5Energy($aItem)
	If IsWeapon($aItem) = False Then Return False
	If StringInStr(GetModStruct($aItem), "0500D822") > 0 Then Return True
	Return False
EndFunc ;==>Is5Energy

;~ Description: Check if an OS Weapon has Dual Vamp Mod (or Zeal)
Func IsDualVamp($aItem)
	If IsWeapon($aItem) = False Or GetRarity($aItem) <> $rarity_gold Then Return False
	Local $lModstruct = GetModStruct($aItem)
	Local $lDv15 = StringInStr($lModstruct, "0F0038220100E820")
	Local $lDv14 = StringInStr($lModstruct, "0E0038220100E820")
	Local $lDz15 = StringInStr($lModstruct, "0F0038220100C820")
	Local $lDz14 = StringInStr($lModstruct, "0E0038220100C820")
	If $lDv15 > 0 Or $lDv14 > 0 Or $lDz15 > 0 Or $lDz14 > 0 Then Return True
	Return False
EndFunc ;==>IsDualVamp

; Mod: +15% dmg / -10 armor while attacking
Func Is15Minus10($aItem)
	If IsWeapon($aItem) = False Or GetRarity($aItem) <> $rarity_gold Then Return False
	If StringInStr(GetModStruct($aItem), "0F0038220A001820") > 0 Then Return True
	Return False
EndFunc ;==>Is15Minus10

; Mod: +15% dmg / -5 energy
Func Is15Minus5($aItem)
	If IsWeapon($aItem) = False Or GetRarity($aItem) <> $rarity_gold Then Return False
	Local $lModstruct = GetModStruct($aItem)
	Local $l15m5 = StringInStr($lModstruct, "0F0038220500B820")
	If $l15m5 > 0 Then Return True
	Return False
EndFunc ;==>Is15Minus5

; Mod 15% dmg / Health above 50%
Func Is1550($aItem)
	If IsWeapon($aItem) = False Or GetRarity($aItem) <> $rarity_gold Then Return False
	If StringInStr(GetModStruct($aItem), "0F327822") > 0 Then Return True
	Return False
EndFunc ;==>Is1550

;~ Description: Check if Weapon has Vamp upgrade
Func IsVamp($aItem)
	If IsWeapon($aItem) = False Then Return False
	Local $lVamp = GetModByIdentifier($aItem, 'E820')
	If $lVamp[0] = 1 Then Return True
	Return False
EndFunc

;~ Description: Check if Weapon has Zealous upgrade
Func IsZealous($aItem)
	If IsWeapon($aItem) = False Then Return False
	Local $lZeal = GetModByIdentifier($aItem, 'C820')
	If $lZeal[0] = 1 Then Return True
	Return False
EndFunc

;~ Description: Check if weapon has Forget Me Not inscription
Func IsForgetMeNot($aItem)
	If GetItemType($aItem) <> $item_type_offhand Then Return False
	Local $lForget = GetModByIdentifier($aItem, '2828')
	If $lForget[1] >= 19 Then Return True
	Return False
EndFunc ;==>IsForgetMeNot

;~ Description: Check if focus has +20% HCT
Func Is20HCTFocus($aItem)
	If GetItemType($aItem) <> $item_type_offhand Then Return False
	Local $lHct = GetModByIdentifier($aItem, '0828')
	If $lHct[1] = 20 Then Return True
	Return False
EndFunc ;==>Is20HCTFocus

; Mod: 10% HCT Focus
Func Is10HCTFocus($aItem)
	If GetItemType($aItem) <> $item_type_offhand Then Return False
	If StringInStr(GetModStruct($aItem), "000A0822") > 0 Then Return True
	Return False
EndFunc ;==>Is10HCTFocus

; Mod: 10% HSR Focus
Func Is10HSRFocus($aItem)
	If GetItemType($aItem) <> $item_type_offhand Then Return False
	If StringInStr(GetModStruct($aItem), "000AA823") > 0 Then Return True
	Return False
EndFunc ;==>Is10HSRFocus

;~ Returns True if the Item is of a Weapon Type
Func IsWeapon($aItem)
	Switch GetItemType($aItem)
		Case $item_type_axe, $item_type_bow, $item_type_offhand
			Return True
		Case $item_type_hammer, $item_type_wand, $item_type_shield
			Return True
		Case $item_type_staff, $item_type_sword, $item_type_daggers
			Return True
		Case $item_type_scythe, $item_type_spear
			Return True
	EndSwitch
	Return False
EndFunc ;==>IsWeapon

Func IsPerfectShield($aItem)
	If GetItemType($aItem) <> $item_type_shield Then Return False ; check if shield

	Local $lModStruct = GetModStruct($aItem)
	; Universal mods
	Local $Plus30 = StringInStr($lModStruct, "001E4823", 0, 1) ; +30HP
	Local $Plus45Ench = StringInStr($lModStruct, "002D6823", 0, 1) ; +45^ench
	Local $Plus44Ench = StringInStr($lModStruct, "002C6823", 0, 1) ; +44^ench
	Local $Minus2Ench = StringInStr($lModStruct, "2008820", 0, 1) ; -2^ench
	Local $Minus3Hex = StringInStr($lModStruct, "3009820", 0, 1) ; -3^hex
	; +1 20% Mods ~ Updated 08/10/2018 - FINISHED
	Local $PlusIllusion = StringInStr($lModStruct, "0118240", 0, 1) ; +1 Illu 20%
	Local $PlusDomination = StringInStr($lModStruct, "0218240", 0, 1) ; +1 Dom 20%
	Local $PlusInspiration = StringInStr($lModStruct, "0318240", 0, 1) ; +1 Insp 20%
	Local $PlusBlood = StringInStr($lModStruct, "0418240", 0, 1) ; +1 Blood 20%
	Local $PlusDeath = StringInStr($lModStruct, "0518240", 0, 1) ; +1 Death 20%
	Local $PlusSoulReap = StringInStr($lModStruct, "0618240", 0, 1) ; +1 SoulR 20%
	Local $PlusCurses = StringInStr($lModStruct, "0718240", 0, 1) ; +1 Curses 20%
	Local $PlusAir = StringInStr($lModStruct, "0818240", 0, 1) ; +1 Air 20%
	Local $PlusEarth = StringInStr($lModStruct, "0918240", 0, 1) ; +1 Earth 20%
	Local $PlusFire = StringInStr($lModStruct, "0A18240", 0, 1) ; +1 Fire 20%
	Local $PlusWater = StringInStr($lModStruct, "0B18240", 0, 1) ; +1 Water 20%
	Local $PlusHealing = StringInStr($lModStruct, "0D18240", 0, 1) ; +1 Heal 20%
	Local $PlusSmite = StringInStr($lModStruct, "0E18240", 0, 1) ; +1 Smite 20%
	Local $PlusProt = StringInStr($lModStruct, "0F18240", 0, 1) ; +1 Prot 20%
	Local $PlusDivine = StringInStr($lModStruct, "1018240", 0, 1) ; +1 Divine 20%
	; +10vsMonster Mods
	Local $PlusUndead = StringInStr($lModStruct, "0A004821", 0, 1) ; +10vs Undead
	Local $PlusCharr = StringInStr($lModStruct, "0A014821", 0 ,1) ; +10vs Charr
	Local $PlusTrolls = StringInStr($lModStruct, "0A024821", 0 ,1) ; +10vs Trolls
	Local $PlusPlants = StringInStr($lModStruct, "0A034821", 0, 1) ; +10vs Plants
	Local $PlusSkeletons = StringInStr($lModStruct, "0A044821", 0 ,1) ; +10vs Skeletons
	Local $PlusGiants = StringInStr($lModStruct, "0A054821", 0 ,1) ; +10vs Giants
	Local $PlusDwarves = StringInStr($lModStruct, "0A064821", 0 ,1) ; +10vs Dwarves
	Local $PlusTengu = StringInStr($lModStruct, "0A074821", 0, 1) ; +10vs Tengu
	Local $PlusDemons = StringInStr($lModStruct, "0A084821", 0, 1) ; +10vs Demons
	Local $PlusDragons = StringInStr($lModStruct, "0A094821", 0, 1) ; +10vs Dragons
	Local $PlusOgres = StringInStr($lModStruct, "0A0A4821", 0 ,1) ; +10vs Ogres
	; +10vs Dmg
	Local $PlusBlunt = StringInStr($lModStruct, "0A0018210", 0, 1) ; +10vs Blunt
	Local $PlusPiercing = StringInStr($lModStruct, "0A011821", 0, 1) ; +10vs Piercing
	Local $PlusSlashing = StringInStr($lModStruct, "0A021821", 0, 1) ; +10vs Slashing
	Local $PlusCold = StringInStr($lModStruct, "0A031821", 0, 1) ; +10 vs Cold
	Local $PlusLightning = StringInStr($lModStruct, "0A041821", 0, 1) ; +10vs Lightning
	Local $PlusVsFire = StringInStr($lModStruct, "0A051821", 0, 1) ; +10vs Fire
	Local $PlusVsEarth = StringInStr($lModStruct, "0A0B1821", 0, 1) ; +10vs Earth	

    If $Plus30 > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
		  Return True
	   ElseIf $Minus2Ench > 0 Or $Minus3Hex > 0 Then
		  Return False
	   Else
		  Return False
	   EndIf
	EndIf
    If $Plus45Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
	      Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   ElseIf $Minus2Ench > 0 Then
		  Return True
	   ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
		  Return True
	   Else
		  Return False
	   EndIf
	EndIf
	If $Minus2Ench > 0 Then
	   If $PlusDemons > 0 Or $PlusPiercing > 0 Or $PlusDragons > 0 Or $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusPlants > 0 Or $PlusCold > 0 Or $PlusUndead > 0 Or $PlusSlashing > 0 Or $PlusTengu > 0 Or $PlusVsFire > 0 Then
		  Return True
	   ElseIf $PlusCharr > 0 Or $PlusTrolls > 0 Or $PlusSkeletons > 0 Or $PlusGiants > 0 Or $PlusDwarves > 0 Or $PlusDragons > 0 Or $PlusOgres > 0 Or $PlusBlunt > 0 Then
		  Return True
	   EndIf
	EndIf
    If $Plus44Ench > 0 Then
	   If $PlusDemons > 0 Then
	      Return True
	   EndIf
	EndIf
	Return False
EndFunc
#EndRegion ModStruct

#Region Equipment
;~ Description: Unequips item to $abag, $aslot (1-based).
;~ Equipmentslots:	1 -> Mainhand/Two-hand	2 -> Offhand	3 -> Chestpiece	4 -> Leggings
;~					5 -> Headpiece			6 -> Boots		7 -> Gloves
Func UnequipItem($aEquipmentSlot, $aBag, $aSlot)
	Return SendPacket(0x10, $HEADER_ITEM_UNEQUIP, $aEquipmentSlot - 1, BagID($aBag), $aSlot - 1)
EndFunc   ;==>UnequipItem
#EndRegion Equipment

#Region Trader
;~ Description: Returns the item ID of the quoted item.
Func GetTraderCostID()
	Return MemoryRead($mTraderCostID)
EndFunc   ;==>GetTraderCostID

;~ Description: Returns the cost of the requested item.
Func GetTraderCostValue()
	Return MemoryRead($mTraderCostValue)
EndFunc   ;==>GetTraderCostValue
#EndRegion Trader

#Region Gold
;~ Description: Have always Platin in inventory, but not to much
Func MinMaxGold()
	If GetInstanceInfo("Type") <> $instancetype_outpost Then Return 0
	Local $lCharacter = GetGoldCharacter()
	
	If $lCharacter < 20000 Then
		Out("Withdrawing Gold.")
		WithdrawGold(20000)
	ElseIf $lCharacter > 50000 Then
		Out("Depositing Gold.")
		DepositGold(25000)
	EndIf
	Return 1
EndFunc ;==>MinMaxGold

;~ Description: Returns amount of gold being carried.
Func GetGoldCharacter()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x90]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldCharacter

;~ Description: Returns amount of gold in storage.
Func GetGoldStorage()
	Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x94]
	Local $lReturn = MemoryReadPtr($mBasePointer, $lOffset)
	Return $lReturn[1]
EndFunc   ;==>GetGoldStorage
#EndRegion Gold

#Region Custom
Func IsBlackDye($aModelID, $aExtraID)
	If $aModelID = $model_id_dye And $aExtraID = $item_extraid_black_dye Then Return True
	Return False
EndFunc ;==>IsBlackDye

Func IsEliteOrNormalTome($aModelID)
	If $aModelID > 21785 And $aModelID < 21806 Then Return True
	Return False
EndFunc ;==>IsEliteOrNormalTome

; Return the amount of Alcohol in Inventory
Func GetAlcQuantityInventory()
	Local $lItemPtr, $lBagPtr, $lQuantity = 0
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If CheckIsAlc(GetItemModelID($lItemPtr)) Then $lQuantity += GetItemQuantity($lItemPtr)
		Next
	Next
	Return $lQuantity
EndFunc ;==>GetAlcQuantityInventory

; Uses first Alc found in Inventory, Returns 0 if no Alc available
Func UseAlc($aOneMinAlc = False)
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If $aOneMinAlc And CheckIsOneMinAlc(GetItemModelID($lItemPtr)) Then
				UseItem($lItemPtr)
				Return 1
			ElseIf CheckIsAlc(GetItemModelID($lItemPtr)) Then
				UseItem($lItemPtr)
				Return 1
			EndIf
		Next
	Next
	Return 0
EndFunc ;==>UseAlc

;~ Description: Checks if ModelID belongs to an Alcohol Item
Func CheckIsAlc($aModelID)
	Switch $aModelID
		Case $model_id_hard_apple_cider, $model_id_hunters_ale, $model_id_eggnogg ; 1min
			Return True
		Case $model_id_witchs_brew, $model_id_vial_of_absinthe, $model_id_shamrock_ale
			Return True
		Case $model_id_keg_of_aged_hunters_ale, $model_id_firewater, $model_id_aged_hunters_ale ; 3min
			Return True
		Case $model_id_krytan_brandy, $model_id_spiked_eggnogg, $model_id_grog
			Return True
		Case Else
			Return False
	EndSwitch
	Return False
EndFunc ;==>CheckIsAlc

;~ Description: Checks if ModelID belongs to an Alcohol Item
Func CheckIsOneMinAlc($aModelID)
	Switch $aModelID
		Case $model_id_hard_apple_cider, $model_id_hunters_ale, $model_id_eggnogg ; 1min
			Return True
		Case $model_id_witchs_brew, $model_id_vial_of_absinthe, $model_id_shamrock_ale
			Return True
		Case Else
			Return False
	EndSwitch
	Return False
EndFunc ;==>CheckIsAlc

;~ Description: Checks if ModelID belongs to a City Speed Item
Func CheckIsCitySpeed($aModelID)
	Switch $aModelID
		Case $model_id_sugary_blue_drink, $model_id_chocolate_bunny, $model_id_fruitcake
			Return True
		Case $model_id_creme_brulee, $model_id_jar_of_honey, $model_id_krytan_lokum
			Return True
		Case Else
			Return False
	EndSwitch
	Return False
EndFunc ;==>CheckIsCitySpeed

; Pops a City Speedboost
Func MaintainCitySpeed()
	If GetIsEnchanted(-2) Then Return 1
	Local $lItemPtr, $lBagPtr
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If CheckIsCitySpeed(GetItemModelID($lItemPtr)) Then
				UseItem($lItemPtr)
				Return 1
			EndIf
		Next
	Next
	
	For $bag = 8 To 12
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			If CheckIsCitySpeed(GetItemModelID($lItemPtr)) Then
				UseItem($lItemPtr)
				Return 1
			EndIf
		Next
	Next
	Return 0
EndFunc ;==>MaintainCitySpeed

; Sells all the unneeded Mats to Merchant
; Make sure *you are standing at a Merchant!!!*
Func SellJunk()
	Local $lItemPtr, $lBagPtr, $lQuantity, $lModelID
	
	For $bag = 1 To 4
		$lBagPtr = GetBagPtr($bag)
		If $lBagPtr = 0 Then ContinueLoop
		For $slot = 1 To GetMaxSlots($lBagPtr)
			$lItemPtr = GetItemPtrBySlot($lBagPtr, $slot)
			If $lItemPtr = 0 Then ContinueLoop
			$lModelID = GetItemModelID($lItemPtr)
			$lQuantity = GetItemQuantity($lItemPtr)			
			Switch $lModelID
				Case $model_id_shing_jea_key
					ContinueCase
				Case $model_id_wood, $model_id_chitin, $model_id_scales
					ContinueCase
				Case $model_id_cloth, $model_id_tanned_hide
					SellItem($lItemPtr, $lQuantity)
					PingSleep(500)
					ContinueLoop
			EndSwitch
		Next
	Next
EndFunc ;==>SellJunk

Func IsEventItem($aModelID)
	; *******************************************************************************************
	; Pick up EVENT ITEMS, put semicolon(;) infront of the line, if you DON'T want do pick it up
	; *******************************************************************************************	
	
	; Canthan New Year
	; If $aModelID = $model_id_lunar_token Then Return True
	
	; Lucky Treats Week
	; If $aModelID = $model_id_four_leaf_clover Then Return True
	; If $aModelID = $model_id_shamrock_ale Then Return True
	
	; Sweet Treats Week
	If $aModelID = $model_id_golden_egg Then Return True
	If $aModelID = $model_id_chocolate_bunny Then Return True
	
	; === Anniversary Celebration ===
	; If $aModelID = $model_id_cupcake Then Return True
	; If $aModelID = $model_id_honeycomb Then Return True
	; If $aModelID = $model_id_sugary_blue_drink Then Return True
	; Alcohol
	; If $aModelID = $model_id_hard_apple_cider Then Return True
	; If $aModelID = $model_id_hunters_ale Then Return True
	; If $aModelID = $model_id_krytan_brandy Then Return True
	; Party Points
	; If $aModelID = $model_id_champagne_popper Then Return True
	; If $aModelID = $model_id_bottle_rocket Then Return True
	; If $aModelID = $model_id_sparkler Then Return True
	; 50 Point Boss Items
	; If $aModelID = $model_id_delicious_cake Then Return True
	; If $aModelID = $model_id_iced_tea Then Return True
	; If $aModelID = $model_id_party_beacon Then Return True
	
	; Dragon Festival
	; If $aModelID = $model_id_victory_token Then Return True ; also anniversary
	
	; Wintersday in July
	;	-->see Wintersday
	
	; Wayfarer's Reverie
	; If $aModelID = $model_id_wayfarers_mark Then Return True ; this ID is WRONG in constants.au3
	
	; Pirate Week
	; If $aModelID = $model_id_grog Then Return True
	
	; Halloween
	; If $aModelID = $model_id_tot_bag Then Return True
	
	; Special Treats Week
	; If $aModelID = $model_id_pumpkin_pie Then Return True ; + Hard Apple Cider, see above
	
	; Wintersday
	; If $aModelID = $model_id_candy_cane_shard Then Return True
	; If $aModelID = $model_id_eggnog Then Return True
	; If $aModelID = $model_id_fruitcake Then Return True
	; If $aModelID = $model_id_snowman_summoner Then Return True
	; If $aModelID = $model_id_frosty_tonic Then Return True
	; If $aModelID = $model_id_mischievous_tonic Then Return True
	
	Return False
EndFunc ;==>IsEventItem

Func IsRareRune($aItem)
    Local $ModStruct = GetModStruct($aItem)
	
	If StringInStr($ModStruct, "C202EA27", 0, 1) > 0 Then ; Mod struct for Sup vigor rune
		Out("Sup Vigor Rune.")
	ElseIf StringInStr($ModStruct, "C202E927", 0, 1) > 0 Then ; Major Vigor
		Out("Major Vigor Rune.")
	ElseIf StringInStr($ModStruct, "C202E827", 0, 1) > 0 Then ; Minor Vigor
		Out("Minor Vigor Rune.")
	; ElseIf StringInStr($ModStruct, "25043025", 0, 1) > 0 Then ; Rune of Vitae
		; Out("Rune of Vitae.")
	; ElseIf StringInStr($ModStruct, "23043025", 0, 1) > 0 Then ; Rune of Attunement
		; Out("Rune of Attunement.")
	; ElseIf StringInStr($ModStruct, "D20330A5", 0, 1) > 0 Then ; Blessed insig
		; Out("Blessed Insignia.")
	; ElseIf StringInStr($ModStruct, "2B043025", 0, 1) > 0 Then ; Rune of Clarity
		; Out("Rune of Clarity.")
	ElseIf StringInStr($ModStruct, "0100E821", 0, 1) > 0 Then ; Minor Fast Casting
		Out("Minor Fast Casting.")
	; ElseIf StringInStr($ModStruct, "0101E821", 0, 1) > 0 Then ; Minor Illusion
		; Out("Minor Illusion.")
	ElseIf StringInStr($ModStruct, "0103E821", 0, 1) > 0 Then ; Minor Inspiration
		Out("Minor Inspiration.")
	; ElseIf StringInStr($ModStruct, "0200E821", 0, 1) > 0 Then ; Major Fast Casting
		; Out("Major Fast Casting.")
	; ElseIf StringInStr($ModStruct, "0202E821", 0, 1) > 0 Then ; Major Domination
		; Out("Major Domination.")
	ElseIf StringInStr($ModStruct, "0302E821", 0, 1) > 0 Then ; Superior Domination
		Out("Superior Domination.")
	ElseIf StringInStr($ModStruct, "C60330A5", 0, 1) > 0 Then ; Prodigy insig
		Out("Prodigy Insignia.")
	ElseIf StringInStr($ModStruct, "0124E821", 0, 1) > 0 Then ; Minor Spawning
		Out("Minor Spawning Power.")
	; ElseIf StringInStr($ModStruct, "0122E821", 0, 1) > 0 Then ; Minor Channeling
		; Out("Minor Channeling Magic.")
	; ElseIf StringInStr($ModStruct, "0121E821", 0, 1) > 0 Then ; Minor Restoration
		; Out("Minor Restoration Magic.")
	; ElseIf StringInStr($ModStruct, "0224E821", 0, 1) > 0 Then ; Major Spawning
		; Out("Major Spawning Power.")
	ElseIf StringInStr($ModStruct, "080430A5", 0, 1) > 0 Then ; Shamans insig
		Out("Shaman's Insignia.")
	; ElseIf StringInStr($ModStruct, "0C0430A5", 0, 1) > 0 Then ; Mystic insig
		; Out("Mystic's Insignia.")
	ElseIf StringInStr($ModStruct, "0106E821", 0, 1) > 0 Then ; Minor SoulReaping
		Out("Minor Soul Reaping.")
	; ElseIf StringInStr($ModStruct, "0204E821", 0, 1) > 0 Then ; Major Blood Magic
		; Out("Major Blood Magic.")
	; ElseIf StringInStr($ModStruct, "0206E821", 0, 1) > 0 Then ; Major SoulReaping
		; Out("Major Soul Reaping.")
	; ElseIf StringInStr($ModStruct, "0205E821", 0, 1) > 0 Then ; Major Death Magic
		; Out("Major Death Magic.")
	; ElseIf StringInStr($ModStruct, "D80330A5", 0, 1) > 0 Then ; Tormentor insig
		; Out("Tormentor's Insignia.")
	; ElseIf StringInStr($ModStruct, "14043025", 0, 1) > 0 Then ; Bloodstained insig
		; Out("Bloodstained Insignia.")
	; ElseIf StringInStr($ModStruct, "EA02E827", 0, 1) > 0 Then ; Minor Absorption
		; Out("Minor Absorption.")
	; ElseIf StringInStr($ModStruct, "0111E821", 0, 1) > 0 Then ; Minor Strength
		; Out("Minor Strength.")
	; ElseIf StringInStr($ModStruct, "0112E821", 0, 1) > 0 Then ; Minor Axe Mastery
		; Out("Minor Axe Mastery.")
	; ElseIf StringInStr($ModStruct, "0113E821", 0, 1) > 0 Then ; Minor Hammer Mastery
		; Out("Minor Hammer Mastery.")
	; ElseIf StringInStr($ModStruct, "0114E821", 0, 1) > 0 Then ; Minor Swordsmanship
		; Out("Minor Swordsmanship.")
	; ElseIf StringInStr($ModStruct, "0115E821", 0, 1) > 0 Then ; Minor Tactics
		; Out("Minor Tactics.")
	; ElseIf StringInStr($ModStruct, "F60330A5", 0, 1) > 0 Then ; Sentinel insig
		; Out("Sentinels Insignia.")
	; ElseIf StringInStr($ModStruct, "0116E821", 0, 1) > 0 Then ; Minor Beast Mastery
		; Out("Minor Beast Mastery.")
	; ElseIf StringInStr($ModStruct, "0118E821", 0, 1) > 0 Then ; Minor Wilderness Survival
		; Out("Minor Wilderness Survival.")
	; ElseIf StringInStr($ModStruct, "0119E821", 0, 1) > 0 Then ; Minor Marksmanship
		; Out("Minor Marksmanship.")
	; ElseIf StringInStr($ModStruct, "0117E821", 0, 1) > 0 Then ; Minor Expertise
		; Out("Minor Expertise.")
	; ElseIf StringInStr($ModStruct, "0110E821", 0, 1) > 0 Then ; Minor Divine Favor
		; Out("Minor Divine Favor.")
	; ElseIf StringInStr($ModStruct, "010FE821", 0, 1) > 0 Then ; Minor Protection Prayers
		; Out("Minor Protection Prayers.")
	; ElseIf StringInStr($ModStruct, "F00330A5", 0, 1) > 0 Then ; Anchorite insig
		; Out("Anchorite Insignia.")
	; ElseIf StringInStr($ModStruct, "010CE821", 0, 1) > 0 Then ; Minor Energy Storage
		; Out("Minor Energy Storage.")
	; ElseIf StringInStr($ModStruct, "0108E821", 0, 1) > 0 Then ; Minor Air Magic
		; Out("Minor Air Magic.")
	; ElseIf StringInStr($ModStruct, "0109E821", 0, 1) > 0 Then ; Minor Earth Magic
		; Out("Minor Earth Magic.")
	; ElseIf StringInStr($ModStruct, "010BE821", 0, 1) > 0 Then ; Minor Water Magic
		; Out("Minor Water Magic.")
	; ElseIf StringInStr($ModStruct, "020CE821", 0, 1) > 0 Then ; Major Energy Storage
		; Out("Major Energy Storage.")
	ElseIf StringInStr($ModStruct, "0123E821", 0, 1) > 0 Then ; Minor Critical Strikes
		Out("Minor Critical Strikes.")
	; ElseIf StringInStr($ModStruct, "011DE821", 0, 1) > 0 Then ; Minor Dagger Mastery
		; Out("Minor Dagger Mastery.")
	; ElseIf StringInStr($ModStruct, "C20330A5", 0, 1) > 0 Then ; Nightstalker insig
		; Out("Nightstalker Insignia.")
	ElseIf StringInStr($ModStruct, "032BE821", 0, 1) > 0 Then ; Sup earth prayers
		Out("Superior Earth Prayers.")
	ElseIf StringInStr($ModStruct, "012CE821", 0, 1) > 0 Then ; Minor Mysticism
		Out("Minor Mysticism.")
	ElseIf StringInStr($ModStruct, "0129E821", 0, 1) > 0 Then ; Minor Scythe Mastery
		Out("Minor Scythe Mastery.")
	ElseIf StringInStr($ModStruct, "040430A5", 0, 1) > 0 Then ; Windwalker insig
		Out("Windwalker Insignia.")
	ElseIf StringInStr($ModStruct, "0E04708000003081", 0, 1) > 0 Then ; Centurion insig
		Out("Centurion Insignia.")
	Else
		Return False
	EndIf	
	Return True
EndFunc ;==>IsRareRune

;~ Description: Looks for valueable Insignia. 0 value will be skipped. Returns the value of Insignia, to use as comparison to rune value.
Func IsInsignia($aItem)
	Local $lModstruct = GetModStruct($aItem)

	For $i = 0 To UBound($array_insignia) - 1
		If $array_insignia[$i][$insig_value] = 0 Then ContinueLoop
		If StringInStr($lModstruct, $array_insignia[$i][$insig_mod_string]) > 0 Then
			Out($array_insignia[$i][$insig_name])	
			Return $array_insignia[$i][$insig_value]
		EndIf
	Next
	Return 0
EndFunc ;==>IsInsignia

Func IsRune($aItem)
	Local $lModstruct = GetModStruct($aItem), $lRarity = GetRarity($aItem)

	Switch $lRarity
		Case $rarity_blue
			For $i = 0 To UBound($array_rune_minor) - 1
				If $array_rune_minor[$i][$rune_value] = 0 Then ContinueLoop
				If StringInStr($lModstruct, $array_rune_minor[$i][$rune_mod_string]) > 0 Then
					Out($array_rune_minor[$i][$rune_name])
					Return $array_rune_minor[$i][$rune_value]
				EndIf
			Next
		Case $rarity_purple
			For $i = 0 To UBound($array_rune_major) - 1
				If $array_rune_major[$i][$rune_value] = 0 Then ContinueLoop
				If StringInStr($lModstruct, $array_rune_major[$i][$rune_mod_string]) > 0 Then
					Out($array_rune_major[$i][$rune_name])
					Return $array_rune_major[$i][$rune_value]
				EndIf
			Next
		Case $rarity_gold
			For $i = 0 To UBound($array_rune_superior) - 1
				If $array_rune_superior[$i][$rune_value] = 0 Then ContinueLoop
				If StringInStr($lModstruct, $array_rune_superior[$i][$rune_mod_string]) > 0 Then
					Out($array_rune_superior[$i][$rune_name])
					Return $array_rune_superior[$i][$rune_value]
				EndIf
			Next
	EndSwitch
	Return 0
EndFunc ;==>IsRune
#EndRegion Custom