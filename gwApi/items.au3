#include-once
;~ added for safety
Global $g_hTimerMoveItem = TimerInit()
Global Const $g_iTimeoutMoveItem = 500 ; wait between different MoveItem operations (make sure Bag/Slot state is solid)

#Region Items
Func GetItemExists($pItem)
    Return Item_GetItemPtr($pItem) <> 0
EndFunc ;==>GetItemExists

;~ Description: Returns the AgentID of Item; $pItem = Ptr/Struct/ID
Func GetItemAgentID($pItem) 
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x4, 'dword')
EndFunc ;==>GetItemAgentID

;~ Description: Returns the Type of Item; $pItem = Ptr/Struct/ID
Func GetItemType($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x20, 'byte')
EndFunc ;==>GetItemType

;~ Description: Returns the ExtraID of Item; $pItem = Ptr/Struct/ID
Func GetItemExtraID($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x22, 'byte')
EndFunc ;==>GetItemExtraID

;~ Description: Returns the Value of Item; $pItem = Ptr/Struct/ID
Func GetItemValue($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x24, 'short')
EndFunc ;==>GetItemValue

;~ Description: Returns the ModelID of Item; $pItem = Ptr/Struct/ID
Func GetItemModelID($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x2C, 'dword')
EndFunc ;==>GetItemModelID

;~ Description: Returns rarity (name color) of an item; $pItem = Ptr/Struct/ID
Func GetRarity($pItem)
    Local $lNameString = Memory_Read(Item_GetItemPtr($pItem) + 0x38, "ptr")
    If $lNameString = 0 Then Return
    Return Memory_Read($lNameString, "ushort")
EndFunc ;==>GetRarity

;~ Description: Returns quantity of an item; $pItem = Ptr/Struct/ID
Func GetItemQuantity($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0x4C, 'short')
EndFunc ;==>GetQuantity

;~ Description: Tests if an item is identified.
Func GetIsIDed($pItem)
    Return BitAND(Memory_Read(Item_GetItemPtr($pItem) + 0x28, 'dword'), 0x1) > 0
EndFunc ;==>GetIsIDed

Func GetIsIdentified($pItem)
    Return BitAND(Memory_Read(Item_GetItemPtr($pItem) + 0x28, 'dword'), 0x1) > 0
EndFunc ;==>GetIsIdentified

;~ Description: Tests if an item is unidentfied and can be identified. (IsNotButCanBeIdentified )
Func GetCanBeIdentified($pItem)
    Return BitAND(Memory_Read(Item_GetItemPtr($pItem) + 0x28, 'dword'), 0x00800000) > 0
EndFunc ;==>GetCanBeIdentified

;~ Description: Tests if an Item can be salvaged into Materials.
Func GetIsSalvageable($pItem)
    Return (Memory_Read(Item_GetItemPtr($pItem) + 0x4A, "byte") <> 0)
EndFunc ;==>GetIsSalvageable

Func GetItemPtrBySlot($aBag, $aSlot)
    Local $pBag = Item_GetBagPtr($aBag)
    Local $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
    Return Memory_Read($lItemArrayPtr + 4 * ($aSlot - 1), 'ptr')
EndFunc   ;==>GetItemPtrBySlot

; Return first ItemPtr by ModelID in specified bags. Zero if no Item is found.
Func GetItemPtrByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $bPartialStacksOnly = False, $aIncludeEquipmentPack = False, $aIncludeMats = False)
    Local $pItem, $pBag, $lItemArrayPtr, $lModelID, $iCount = 0
    
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
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                $lModelID = GetItemModelID($pItem)
                For $i = 0 To UBound($aModelID) - 1
                    If $lReturnPtr[$i] <> 0 Or $lModelID <> $aModelID[$i] Then ContinueLoop
                    If $bPartialStacksOnly And GetItemQuantity($pItem) >= 250 Then ContinueLoop
                    $lReturnPtr[$i] = $pItem
                    $iCount += 1
                    If $iCount = UBound($aModelID) Then
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
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                If GetItemModelID($pItem) <> $aModelID Then ContinueLoop
                If $bPartialStacksOnly And GetItemQuantity($pItem) >= 250 Then ContinueLoop
                Return $pItem
            Next
        Next
    EndIf
    Return $lReturnPtr
EndFunc ;==>GetItemPtrByModelID

; Return first ItemPtr by Type in specified bags. Zero if no Item is found.
Func GetItemPtrByType($aType, $aFirstBag = 1, $aLastBag = 16, $aIncludeEquipmentPack = False, $aIncludeMats = False)
    Local $pItem, $pBag, $lItemArrayPtr, $lType, $iCount = 0
    
    If IsArray($aType) Then
        Local $lReturnPtr[UBound($aType)]
        For $i = 0 To UBound($aType) - 1
            $lReturnPtr[$i] = 0
        Next
    Else
        Local $lReturnPtr = 0
    EndIf
    
    If IsArray($aType) Then
        For $bag = $aFirstBag To $aLastBag
            If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
            If $bag = 6 And Not $aIncludeMats Then ContinueLoop
            If $bag = 7 Then ContinueLoop
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                $lType = GetItemType($pItem)
                For $i = 0 To UBound($aType) - 1
                    If $lReturnPtr[$i] <> 0 Or $lType <> $aType[$i] Then ContinueLoop
                    $lReturnPtr[$i] = $pItem
                    $iCount += 1
                    If $iCount = UBound($aType) Then
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
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                If GetItemType($pItem) = $aType Then
                    Return $pItem
                EndIf
            Next
        Next
    EndIf
    Return $lReturnPtr
EndFunc ;==>GetItemPtrByType

; Returns the first Item by ModelID found in Inventory; If no Item is found Returns Zero
Func GetItemInInventory($aModelID, $bPartialStacksOnly = False)
    Return GetItemPtrByModelID($aModelID, 1, 4, $bPartialStacksOnly)
EndFunc ;==>GetItemInInventory

; Returns the first Item by ModelID found in Storage; If no Item is found Returns Zero
Func GetItemInChest($aModelID, $bPartialStacksOnly = False)
    Return GetItemPtrByModelID($aModelID, 8, 11, $bPartialStacksOnly)
EndFunc ;==>GetItemInChest

Func GetItemInInventoryByType($aType)
    Return GetItemPtrByType($aType, 1, 4)
EndFunc ;==>GetItemInInventoryByType

Func GetItemInChestByType($aType)
    Return GetItemPtrByType($aType, 8, 11)
EndFunc ;==>GetItemInChestByType

;~ Returns the first Item, with a matching ModStruct
Func GetItemByModStruct($iBagIndex = 1, $sModStruct = "")
    If $sModStruct = "" Then Return 0
    Local $pItem, $pBag = Item_GetBagPtr($iBagIndex)

    For $slot = 1 To GetMaxSlots($pBag)
        $pItem = GetItemPtrBySlot($pBag, $slot)
        If $pItem = 0 Then ContinueLoop
        If StringInStr(GetModStruct($pItem), $sModStruct) > 0 Then Return $pItem
    Next
    Return 0
EndFunc ;==>GetItemByModStruct

;~ Description: Returns amount of items of $aModelID in selected bags.
Func CountItemByModelID($aModelID, $aFirstBag = 1, $aLastBag = 16, $aCountSlotsOnly = False, $aIncludeEquipmentPack = False, $aIncludeMats = False)
    Local $pItem, $pBag, $lItemArrayPtr, $lModelID
    If IsArray($aModelID) Then
        Local $iCount[UBound($aModelID)]
        For $i = 0 To UBound($aModelID) - 1
            $iCount[$i] = 0
        Next
    Else
        Local $iCount = 0
    EndIf
    
    If IsArray($aModelID) Then
        For $bag = $aFirstBag To $aLastBag
            If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
            If $bag = 6 And Not $aIncludeMats Then ContinueLoop
            If $bag = 7 Then ContinueLoop
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                $lModelID = GetItemModelID($pItem)
                For $i = 0 To UBound($aModelID) - 1
                    If $lModelID = $aModelID[$i] Then
                        If $aCountSlotsOnly Then
                            $iCount[$i] += 1
                        Else
                            $iCount[$i] += GetItemQuantity($pItem)
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
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                If GetItemModelID($pItem) = $aModelID Then
                    If $aCountSlotsOnly Then
                        $iCount += 1
                    Else
                        $iCount += GetItemQuantity($pItem)
                    EndIf
                EndIf
            Next
        Next 
    EndIf
    Return $iCount
EndFunc ;==>CountItemByModelID

; Returns the amount of an Item in Inventory by ModelID
Func GetQuantityInventory($aModelID, $aCountSlotsOnly = False)
    Return CountItemByModelID($aModelID, 1, 4, $aCountSlotsOnly)
EndFunc ;==>GetQuantityInventory

; Return the amount of an Item in Chest by ModelID
Func GetQuantityChest($aModelID, $aCountSlotsOnly = False)
    Return CountItemByModelID($aModelID, 8, 11, $aCountSlotsOnly)
EndFunc ;==>GetQuantityChest

; Returns the amount of an Item by ModelID in Inventory+Chest
Func GetQuantity($aModelID, $aCountSlotsOnly = False)
    Return CountItemByModelID($aModelID, 1, 11, $aCountSlotsOnly)
EndFunc ;==>GetQuantity

;~ Description: Returns amount of items of $aType in selected bags.
Func CountItemByType($aType, $aFirstBag = 1, $aLastBag = 16, $aCountSlotsOnly = False, $aIncludeEquipmentPack = False, $aIncludeMats = False)
    Local $pItem, $pBag, $lItemArrayPtr, $lType
    If IsArray($aType) Then
        Local $iCount[UBound($aType)]
        For $i = 0 To UBound($aType) - 1
            $iCount[$i] = 0
        Next
    Else
        Local $iCount = 0
    EndIf
    
    If IsArray($aType) Then
        For $bag = $aFirstBag To $aLastBag
            If $bag = 5 And Not $aIncludeEquipmentPack Then ContinueLoop
            If $bag = 6 And Not $aIncludeMats Then ContinueLoop
            If $bag = 7 Then ContinueLoop
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                $lType = GetItemType($pItem)
                For $i = 0 To UBound($aType) - 1
                    If $lType = $aType[$i] Then
                        If $aCountSlotsOnly Then
                            $iCount[$i] += 1
                        Else
                            $iCount[$i] += GetItemQuantity($pItem)
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
            $pBag = Item_GetBagPtr($bag)
            If $pBag = 0 Then ContinueLoop
            $lItemArrayPtr = Memory_Read($pBag + 0x18, 'ptr')
            For $slot = 0 To GetMaxSlots($pBag) - 1
                $pItem = Memory_Read($lItemArrayPtr + 4 * $slot, 'ptr')
                If $pItem = 0 Then ContinueLoop
                If GetItemType($pItem) = $aType Then
                    If $aCountSlotsOnly Then
                        $iCount += 1
                    Else
                        $iCount += GetItemQuantity($pItem)
                    EndIf
                EndIf
            Next
        Next 
    EndIf
    Return $iCount
EndFunc ;==>CountItemByType

; Returns the amount of an Item in Inventory by Type
Func GetQuantityInventoryByType($aType, $aCountSlotsOnly = False)
    Return CountItemByType($aType, 1, 4, $aCountSlotsOnly)
EndFunc ;==>GetQuantityInventory

; Return the amount of an Item in Chest by Type
Func GetQuantityChestByType($aType, $aCountSlotsOnly = False)
    Return CountItemByType($aType, 8, 11, $aCountSlotsOnly)
EndFunc ;==>GetQuantityChest

; Returns the amount of an Item by Type in Inventory+Chest
Func GetQuantityByType($aType, $aCountSlotsOnly = False)
    Return CountItemByType($aType, 1, 11, $aCountSlotsOnly)
EndFunc ;==>GetQuantity

;~ Use Item in Inventory
Func UseItemByModelID($iModelID)
    If Not IsArray($iModelID) Then
        Local $aTmp[1] = [$iModelID]
        $iModelID = $aTmp
    EndIf

    Local $pItem = GetItemInInventory($iModelID)

    For $i = 0 To UBound($iModelID) - 1
        If $pItem[$i] = 0 Then ContinueLoop
        Item_UseItem($pItem[$i])
    Next
    Other_PingSleep(100)
EndFunc ;==>UseItemByModelID

;Drops all Items to ground, if in explorable
Func DropAll()
    If Not Map_GetInstanceInfo("IsExplorable") Then Return 0
    Local $pItem, $pBag
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            Item_DropItem($pItem)
            Other_PingSleep(100)
        Next
    Next
    Return 1
EndFunc ;==>DropAll

;Drops all Items of given Type to ground, if in explorable
Func DropItemsByType($aType)
    If Not Map_GetInstanceInfo("IsExplorable") Then Return 0
    Local $pItem, $pBag
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If GetItemType($pItem) <> $aType Then ContinueLoop
            Item_DropItem($pItem)
            Other_PingSleep(100)
        Next
    Next
    Return 1
EndFunc ;==>DropItemsByType

;Drops all Items of given ModelID to ground, if in explorable
Func DropItemsByModelID($iModelID, $aFullStack = False)
    If Not Map_GetInstanceInfo("IsExplorable") Then Return 0
    Local $pItem, $pBag
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If GetItemModelID($pItem) <> $iModelID Then ContinueLoop
            If $aFullStack And GetItemQuantity($pItem) < 250 Then ContinueLoop
            Item_DropItem($pItem)
            Other_PingSleep(100)
        Next
    Next
EndFunc ;==>DropItemsByModelID

;Description: Destroys an Item
Func DestroyItem($pItem)
    Item_DestroyItem($pItem)
    Other_PingSleep(100)
EndFunc   ;==>DestroyItem

;~ Description: Moves an Item and can split up a Stack
Func MoveItemEx($pItemSource, $iBag, $iSlot, $iAmount = 0)
    Local $pItem = Item_GetItemPtr($pItemSource)
    If $pItem = 0 Then Return 0

    Local $iQuantity = GetItemQuantity($pItem)
    If $iAmount = 0 Or $iAmount > $iQuantity Then $iAmount = $iQuantity

    If $iAmount >= $iQuantity Then
        Core_SendPacket(0x10, $GC_I_HEADER_ITEM_MOVE, Item_ItemID($pItem), BagID($iBag), $iSlot - 1)
    Else
        Core_SendPacket(0x14, $GC_I_HEADER_ITEM_SPLIT_STACK, Item_ItemID($pItem), $iAmount, BagID($iBag), $iSlot - 1)
    EndIf
    Return 1
EndFunc ;==>MoveItemEx

Func PickUpLootEx($iMaxDist = 2500)
    Local $lAgentPtr, $lAgentID, $pItem, $lOwner
    Local $lAgentPtrArray = GetAgentPtrArray(1, 0x400)

    For $i = 1 To $lAgentPtrArray[0]
        $lAgentPtr = $lAgentPtrArray[$i]
        $pItem = GetItemPtrByAgentPtr($lAgentPtr)
        If $pItem = 0 Then ContinueLoop

        $lAgentID = ID($lAgentPtr)
        $lOwner = Memory_Read($lAgentPtr + 0xC4, 'long')
        If $lOwner <> 0 And $lOwner <> GetMyID() Then ContinueLoop ; assigned to another player
        
        If CanPickUpEx($pItem) And GetDistance($lAgentPtr) < $iMaxDist Then
            If GetDistanceToXY(X($lAgentPtr), Y($lAgentPtr)) > 250 Then MoveTo(X($lAgentPtr), Y($lAgentPtr))

            $hDeadlock = TimerInit()
            Do
                Item_PickUpItem($lAgentID)
                Other_PingSleep(500)
            Until Agent_GetAgentPtr($lAgentID) <> $lAgentPtr Or GetIsDead(-2) Or TimerDiff($hDeadlock) > 2000
        EndIf
    Next
EndFunc   ;==>PickupLootEx

;~ Description: Returns Itemptr by agentid.
Func GetItemPtrByAgentID($iAgentID)
    $iAgentID = Agent_GetAgentPtr($iAgentID)
    If $iAgentID = 0 Then Return 0
    Return Item_GetItemPtr(Memory_Read($iAgentID + 0xC8, 'dword'))
EndFunc   ;==>GetItemPtrByAgentID

Func GetItemPtrByAgentPtr($pAgent)
    If Not IsPtr($pAgent) Then Return 0
    Return Item_GetItemPtr(Memory_Read($pAgent + 0xC8, 'dword'))
EndFunc   ;==>GetItemPtrByAgentPtr

;~ Description: Looks for free Slot and moves Item to Chest.
;~ $bStackItem = True: if it finds an item with the same ModelID, before it finds a free slot,
;~                     the items will be stacked together; the overflow goes to an empty slot
Func MoveItemToChest($pItemSource, $bStackItem = False)
    Local $pItem, $pBag, $iModelIDSource = 0
    Local $bMoveItem = False
    Local $aBagSlotSource[2] = [0, 0]
    If $bStackItem Then $iModelIDSource = GetItemModelID($pItemSource)

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)

            If $pItem = 0 Then
                $bMoveItem = True
                ExitLoop 2
            EndIf

            If $bStackItem And (GetItemModelID($pItem) = $iModelIDSource) Then
                Local $iQuantityDest = GetItemQuantity($pItem)
                If $iQuantityDest >= 250 Then ContinueLoop

                Local $iQuantitySource = GetItemQuantity($pItemSource)    
                If ($iQuantitySource + $iQuantityDest) <= 250 Then
                    $bMoveItem = True
                    ExitLoop 2
                Else
                    $iQuantitySource = 250 - $iQuantityDest
                    MoveItemEx($pItemSource, $bag, $slot, $iQuantitySource)
                    Other_PingSleep(500) ; game needs time to update item data
                EndIf
            EndIf
        Next
    Next
    
    If $bMoveItem = False Then Return False

    $aBagSlotSource[0] = Item_GetBagInfo(Item_GetItemInfoByPtr($pItemSource, "Bag"), "Index") + 1
    $aBagSlotSource[1] = Item_GetItemInfoByPtr($pItemSource, "Slot") + 1

    Item_MoveItem($pItemSource, $bag, $slot)
    WaitForItemMove($aBagSlotSource[0], $aBagSlotSource[1])
    
    Return True
EndFunc ;==>MoveItemToChest

;~ Merges two < 250 items together, does *not* handle any overflow
;~ > 0: Merge w/o overflow
;~ = 0: Merge w/ overflow or no merge
Func MergeItemToChest($pItemSource, $pItemDest = 0)
    ;~ some other func already found destination item
    If $pItemDest <> 0 Then
        If $pItemSource = $pItemDest Then Return 0
        If GetItemModelID($pItemSource) <> GetItemModelID($pItemDest) Then Return 0

        Local $iQuantityDest = GetItemQuantity($pItemDest)
        If $iQuantityDest >= 250 Then Return 0

        Local $iQuantitySource = GetItemQuantity($pItemSource)
        Local $iBag = Item_GetBagInfo(Item_GetItemInfoByPtr($pItemDest, "Bag"), "Index") + 1
        Local $iSlot = Item_GetItemInfoByPtr($pItemDest, "Slot") + 1
        
        If ($iQuantitySource + $iQuantityDest) <= 250 Then
            Item_MoveItem($pItemSource, $iBag, $iSlot)
            Return ($iQuantitySource + $iQuantityDest)
        Else
            Local $iMoveAmount = 250 - $iQuantityDest
            MoveItemEx($pItemSource, $iBag, $iSlot, $iMoveAmount)
            Return 0
        EndIf
    EndIf

    Local $pItem, $pBag, $iModelID = GetItemModelID($pItemSource)
    Local $iQuantitySource = GetItemQuantity($pItemSource), $iQuantityDest

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If GetItemModelID($pItem) <> $iModelID Then ContinueLoop

            $iQuantityDest = GetItemQuantity($pItem)
            If $iQuantityDest >= 250 Then ContinueLoop

            If ($iQuantitySource + $iQuantityDest) <= 250 Then
                Item_MoveItem($pItemSource, $bag, $slot)
                Return ($iQuantitySource + $iQuantityDest)
            Else
                Local $iMoveAmount = 250 - $iQuantityDest
                MoveItemEx($pItemSource, $bag, $slot, $iMoveAmount)
                Return 0
            EndIf
        Next
    Next
    Return 0
EndFunc ;==>MergeItemToChest

;~ Description: Looks for free Slot and moves Item to Inventory
;~ $bStackItem = True: if it finds an item with the same ModelID, before it finds a free slot,
;~                     the items will be stacked together; the overflow goes to an empty slot
Func MoveItemToInventory($pItemSource, $bStackItem = False)
    Local $pItem, $pBag, $iModelIDSource = 0
    Local $bMoveItem = False
    Local $aBagSlotSource[2] = [0, 0]
    If $bStackItem Then $iModelIDSource = GetItemModelID($pItemSource)

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)

            If $pItem = 0 Then
                $bMoveItem = True
                ExitLoop 2
            EndIf

            If $bStackItem And (GetItemModelID($pItem) = $iModelIDSource) Then
                Local $iQuantityDest = GetItemQuantity($pItem)
                If $iQuantityDest >= 250 Then ContinueLoop

                Local $iQuantitySource = GetItemQuantity($pItemSource)    
                If ($iQuantitySource + $iQuantityDest) <= 250 Then
                    $bMoveItem = True
                    ExitLoop 2
                Else
                    $iQuantitySource = 250 - $iQuantityDest
                    MoveItemEx($pItemSource, $bag, $slot, $iQuantitySource)
                    Other_PingSleep(500) ; game needs time to update item data
                EndIf
            EndIf
        Next
    Next
    
    If $bMoveItem = False Then Return False

    $aBagSlotSource[0] = Item_GetBagInfo(Item_GetItemInfoByPtr($pItemSource, "Bag"), "Index") + 1
    $aBagSlotSource[1] = Item_GetItemInfoByPtr($pItemSource, "Slot") + 1

    Item_MoveItem($pItemSource, $bag, $slot)
    WaitForItemMove($aBagSlotSource[0], $aBagSlotSource[1])

    Return True
EndFunc ;==>MoveItemToInventory

;~ Merges two < 250 items together, does *not* handle any overflow
;~ > 0: Merge w/o overflow
;~ = 0: Merge w/ overflow or no merge
Func MergeItemToInventory($pItemSource, $pItemDest = 0)
    ;~ some other func already found destination item
    If $pItemDest <> 0 Then
        If $pItemSource = $pItemDest Then Return 0
        If GetItemModelID($pItemSource) <> GetItemModelID($pItemDest) Then Return 0

        Local $iQuantityDest = GetItemQuantity($pItemDest)
        If $iQuantityDest >= 250 Then Return 0

        Local $iQuantitySource = GetItemQuantity($pItemSource)
        Local $iBag = Item_GetBagInfo(Item_GetItemInfoByPtr($pItemDest, "Bag"), "Index") + 1
        Local $iSlot = Item_GetItemInfoByPtr($pItemDest, "Slot") + 1
        
        If ($iQuantitySource + $iQuantityDest) <= 250 Then
            Item_MoveItem($pItemSource, $iBag, $iSlot)
            Return ($iQuantitySource + $iQuantityDest)
        Else
            Local $iMoveAmount = 250 - $iQuantityDest
            MoveItemEx($pItemSource, $iBag, $iSlot, $iMoveAmount)
            Return 0
        EndIf
    EndIf

    Local $pItem, $pBag, $iModelID = GetItemModelID($pItemSource)
    Local $iQuantitySource = GetItemQuantity($pItemSource), $iQuantityDest
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If GetItemModelID($pItem) <> $iModelID Then ContinueLoop
            $iQuantityDest = GetItemQuantity($pItem)
            If $iQuantityDest >= 250 Then ContinueLoop
            If ($iQuantitySource + $iQuantityDest) <= 250 Then
                Item_MoveItem($pItemSource, $bag, $slot)
                Return ($iQuantitySource + $iQuantityDest)
            Else
                Local $iMoveAmount = 250 - $iQuantityDest
                MoveItemEx($pItemSource, $bag, $slot, $iMoveAmount)
                Return 0
            EndIf
        Next
    Next
    Return 0
EndFunc ;==>MergeItemToInventory

;~ stores and merges all items by ModelID
;~ $aModelID: singular ModelID or array of ModelIDs
;~ $iAmount: counts stacks only
Func StoreItemsByModelID($aModelID, $iAmount = 0, $bFullStackOnly = False)
    If Not Map_GetInstanceInfo("IsOutpost") Then Return False

    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf

    Local $iCountModelID = UBound($aModelID)
    
    Local $iAmountMoved[$iCountModelID]
    For $i = 0 To $iCountModelID - 1
        $iAmountMoved[$i] = 0
    Next
       
    Local $aFreeSlots = GetFreeSlotsStorage()
    If $aFreeSlots = 0 Then Return False
    Local $pItemDest = GetItemInChest($aModelID, True)
    Local $iFreeSlotsMax = UBound($aFreeSlots), $iCountSlots = 0
    Local $pItem, $pBag, $iModelID, $iQuantity, $iQuantityMerge, $iModelIDFound
    Local $iBagSource, $iSlotSource, $aBagSlotLast[2] = [0, 0]
    Local $iAmountCount = 0

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            $iQuantity = GetItemQuantity($pItem)
            If $bFullStackOnly And $iQuantity < 250 Then ContinueLoop
            $iModelID = GetItemModelID($pItem)
            $iModelIDFound = -1
            For $i = 0 To $iCountModelID - 1
                If $iModelID = $aModelID[$i] Then
                    $iModelIDFound = $i
                    ExitLoop
                EndIf
            Next
            If $iModelIDFound = -1 Then ContinueLoop
            If $iAmount > 0 And $iAmountMoved[$iModelIDFound] >= $iAmount Then ContinueLoop

            $iQuantityMerge = -1
            If $iQuantity < 250 Then
                $iBagSource = Item_GetBagInfo(Item_GetItemInfoByPtr($pItem, "Bag"), "Index") + 1
                $iSlotSource = Item_GetItemInfoByPtr($pItem, "Slot") + 1
                $iQuantityMerge = MergeItemToChest($pItem, $pItemDest[$iModelIDFound])
                If $iQuantityMerge > 0 Then
                    ;~ merge w/o overflow
                    If $iQuantityMerge = 250 Then $pItemDest[$iModelIDFound] = 0
                    WaitForItemMove($iBagSource, $iSlotSource)
                    ContinueLoop
                ElseIf $iQuantityMerge = 0 Then
                    ;~ merge w/ overflow
                    $pItemDest[$iModelIDFound] = $pItem
                EndIf
            EndIf

            $aBagSlotLast[0] = $bag
            $aBagSlotLast[1] = $slot
            Item_MoveItem($pItem, $aFreeSlots[$iCountSlots][0], $aFreeSlots[$iCountSlots][1])
            ;~ wait if a merge happened
            If $iQuantityMerge <> -1 Then
                WaitForItemMove($iBagSource, $iSlotSource)
            EndIf
            $g_hTimerMoveItem = TimerInit()
            $iCountSlots += 1
            If $iCountSlots >= $iFreeSlotsMax Then Return True

            If $iAmount > 0 Then
                $iAmountMoved[$iModelIDFound] += 1
                ; ModelID reached required amount for the first time
                If $iAmountMoved[$iModelIDFound] = $iAmount Then
                    $iAmountCount += 1

                    ; all ModelIDs satisfied
                    If $iAmountCount = $iCountModelID Then Return True
                EndIf
            EndIf
        Next
    Next
    If $aBagSlotLast[0] <> 0 And $aBagSlotLast[1] <> 0 Then
        WaitForItemMove($aBagSlotLast[0], $aBagSlotLast[1])
    EndIf
    
    Return True
EndFunc ;==>StoreItemsByModelID

Func WithdrawItemsByModelID($aModelID, $iAmount = 0, $bFullStackOnly = False)
    If Not Map_GetInstanceInfo("IsOutpost") Then Return False

    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf

    Local $iCountModelID = UBound($aModelID)
    
    Local $iAmountMoved[$iCountModelID]
    For $i = 0 To $iCountModelID - 1
        $iAmountMoved[$i] = 0
    Next
       
    Local $aFreeSlots = GetFreeSlotsInventory()
    If $aFreeSlots = 0 Then Return False
    Local $pItemDest = GetItemInInventory($aModelID, True)
    Local $iFreeSlotsMax = UBound($aFreeSlots), $iCountSlots = 0
    Local $pItem, $pBag, $iModelID, $iQuantity, $iQuantityMerge, $iModelIDFound
    Local $iBagSource, $iSlotSource, $aBagSlotLast[2] = [0, 0]
    Local $iAmountCount = 0

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            $iQuantity = GetItemQuantity($pItem)
            If $bFullStackOnly And $iQuantity < 250 Then ContinueLoop
            $iModelID = GetItemModelID($pItem)
            $iModelIDFound = -1
            For $i = 0 To $iCountModelID - 1
                If $iModelID = $aModelID[$i] Then
                    $iModelIDFound = $i
                    ExitLoop
                EndIf
            Next
            If $iModelIDFound = -1 Then ContinueLoop
            If $iAmount > 0 And $iAmountMoved[$iModelIDFound] >= $iAmount Then ContinueLoop

            $iQuantityMerge = -1
            If $iQuantity < 250 Then
                $iBagSource = Item_GetBagInfo(Item_GetItemInfoByPtr($pItem, "Bag"), "Index") + 1
                $iSlotSource = Item_GetItemInfoByPtr($pItem, "Slot") + 1
                $iQuantityMerge = MergeItemToInventory($pItem, $pItemDest[$iModelIDFound])
                If $iQuantityMerge > 0 Then
                    ;~ merge w/o overflow
                    If $iQuantityMerge = 250 Then $pItemDest[$iModelIDFound] = 0
                    WaitForItemMove($iBagSource, $iSlotSource)
                    ContinueLoop
                ElseIf $iQuantityMerge = 0 Then
                    ;~ merge w/ overflow
                    $pItemDest[$iModelIDFound] = $pItem
                EndIf
            EndIf

            $aBagSlotLast[0] = $bag
            $aBagSlotLast[1] = $slot
            Item_MoveItem($pItem, $aFreeSlots[$iCountSlots][0], $aFreeSlots[$iCountSlots][1])
            ;~ wait if a merge happened
            If $iQuantityMerge <> -1 Then
                WaitForItemMove($iBagSource, $iSlotSource)
            EndIf
            $g_hTimerMoveItem = TimerInit()
            $iCountSlots += 1
            If $iCountSlots >= $iFreeSlotsMax Then Return True

            If $iAmount > 0 Then
                $iAmountMoved[$iModelIDFound] += 1
                ; ModelID reached required amount for the first time
                If $iAmountMoved[$iModelIDFound] = $iAmount Then
                    $iAmountCount += 1

                    ; all ModelIDs satisfied
                    If $iAmountCount = $iCountModelID Then Return True
                EndIf
            EndIf
        Next
    Next
    If $aBagSlotLast[0] <> 0 And $aBagSlotLast[1] <> 0 Then
        WaitForItemMove($aBagSlotLast[0], $aBagSlotLast[1])
    EndIf
    
    Return True
EndFunc ;==>WithdrawItemsByModelID

;Stores all Items of given Type
Func WithdrawItemsByType($aType, $aFullStack = False)
    If Map_GetInstanceInfo("Type") <> $instancetype_outpost Then Return False
    Local $pItem, $pBag
    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If GetItemType($pItem) <> $aType Then ContinueLoop
            If $aFullStack And GetItemQuantity($pItem) < 250 Then ContinueLoop
            If MoveItemToInventory($pItem) = False Then Return
        Next
    Next
EndFunc ;==>WithdrawItemsByType

;~ Wait for confirmation, that an Item has moved. (i.e. the slot is empty)
;~ Params: original position of the item
Func WaitForItemMove($iBag, $iSlot)
    Local $hDeadlock = TimerInit(), $bTimeout
    Do
        Sleep(50)
        $bTimeout = TimerDiff($hDeadlock) > 2000
    Until GetItemPtrBySlot($iBag, $iSlot) = 0 Or $bTimeout

    Sleep(100)
    Return $bTimeout ? 0 : 1
EndFunc ;==>WaitForItemMove

#Region Identify And Salvage
Func IdentifyItem($pItem, $pIdKit = FindIDKit())
    If Not GetCanBeIdentified($pItem) Then Return 1
    
    Local $pKit = IsPtr($pIdKit) ? $pIdKit : FindIDKit()
    If $pKit = 0 Then Return 0
    
    Core_SendPacket(0xC, $GC_I_HEADER_ITEM_IDENTIFY, Item_ItemID($pKit), Item_ItemID($pItem))

    Local $hDeadlock = TimerInit(), $bTimeout
    Do
        Sleep(50)
        $bTimeout = TimerDiff($hDeadlock) > 5000
    Until Not GetCanBeIdentified($pItem) Or $bTimeout

    Return $bTimeout ? 0 : 1
EndFunc ;==>IdentifyItem

;~ Description: Returns ItemPtr of ID kit in inventory. Return 0, if no Kit found.
Func FindIDKit($bCheckUses = False)
    Local $pItem, $pBag, $iValue, $pKit = 0, $iUses = 101

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 to GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop

            Switch GetItemModelID($pItem)
                Case 2989
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 2) < $iUses Then
                        $iUses = $iValue / 2
                        $pKit = $pItem
                    EndIf
                Case 5899
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 2.5) < $iUses Then
                        $iUses = $iValue / 2.5
                        $pKit = $pItem
                    EndIf
            EndSwitch
        Next
    Next

    Return $pKit
EndFunc ;==>FindIDKit

;~ Description: Returns ItemPtr of ID kit in inventory. Return 0, if no Kit found.
Func FindSuperiorIDKit($bCheckUses = False)
    Local $pItem, $pBag, $iValue, $pKit = 0, $iUses = 101

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 to GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            
            Switch GetItemModelID($pItem)
                Case 5899
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 2.5) < $iUses Then
                        $iUses = $iValue / 2.5
                        $pKit = $pItem
                    EndIf
            EndSwitch
        Next
    Next

    Return $pKit
EndFunc ;==>FindSuperiorIDKit

;~ Description: Starts a salvaging session of an item.
Func StartSalvage($pItem, $pSalvageKit = 0, $bCheap = True)
    Local $pKit = 0

    If IsPtr($pSalvageKit) Then
        $pKit = $pSalvageKit
    ElseIf $bCheap Then
        $pKit = FindCheapSalvageKit()
    Else
        $pKit = FindExpertSalvageKit()
    EndIf

    If $pKit = 0 Then Return 0

    Local $l_a_Offset[4] = [0, 0x18, 0x2C, 0x690]
    Local $l_i_SalvageSessionID = Memory_ReadPtr($g_p_BasePointer, $l_a_Offset)

    DllStructSetData($g_d_Salvage, 2, Item_ItemID($pItem))
    DllStructSetData($g_d_Salvage, 3, Item_ItemID($pKit))
    DllStructSetData($g_d_Salvage, 4, $l_i_SalvageSessionID[1])
    Core_Enqueue($g_p_Salvage, 16)
    Return 1
EndFunc   ;==>StartSalvage

;~ Description: Salvage the materials out of an item.
Func SalvageMaterials()
    Return Core_SendPacket(0x4, $GC_I_HEADER_ITEM_SALVAGE_MATERIALS)
EndFunc   ;==>SalvageMaterials

;~ Description: Salvages a mod out of an item.
Func SalvageMod($aModIndex)
    Return Core_SendPacket(0x8, $GC_I_HEADER_ITEM_SALVAGE_UPGRADE, $aModIndex)
EndFunc   ;==>SalvageMod

;~ Description: Returns ItemPtr of cheap Salvage Kit in inventory. Return 0, if no Kit found.
Func FindCheapSalvageKit($bCheckUses = False)
    Local $pItem, $pBag, $iValue, $pKit = 0, $iUses = 101

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 to GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            
            Switch GetItemModelID($pItem)
                Case 2992
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 2) < $iUses Then
                        $iUses = $iValue / 2
                        $pKit = $pItem
                    EndIf
            EndSwitch
        Next
    Next

    Return $pKit
EndFunc ;==>FindCheapSalvageKit

;~ Description: Returns ItemPtr of any Salvage Kit in inventory. Return 0, if no Kit found.
Func FindExpertSalvageKit($bCheckUses = False)
    Local $pItem, $pBag, $iValue, $pKit = 0, $iUses = 101

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 to GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            
            Switch GetItemModelID($pItem)
                Case 2991
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 8) < $iUses Then
                        $iUses = $iValue / 8
                        $pKit = $pItem
                    EndIf
                Case 5900
                    If $bCheckUses = False Then Return $pItem

                    $iValue = GetItemValue($pItem)
                    If ($iValue / 10) < $iUses Then
                        $iUses = $iValue / 10
                        $pKit = $pItem
                    EndIf
            EndSwitch
        Next
    Next

    Return $pKit
EndFunc ;==>FindExpertSalvageKit
#EndRegion Identify and Salvage

#Region Buy and Sell
;~ Buys Salvage Kit
Func BuySalvageKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return
    Merchant_BuyItem($model_id_salvage_kit, $iQuantity)
    Other_PingSleep(1000)
EndFunc ;==>BuySalvageKit

;~ Buys Expert Salvage Kit
Func BuyExpertSalvageKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return
    Merchant_BuyItem($model_id_expert_salvage_kit, $iQuantity)
    Other_PingSleep(1000)
EndFunc ;==>BuySalvageKit

;~ Buys Superior Salvage Kit
Func BuySuperiorSalvageKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return
    Merchant_BuyItem($model_id_superior_salvage_kit, $iQuantity)
    Other_PingSleep(1000)
EndFunc ;==>BuySalvageKit

;~ Buys an ID kit.
Func BuyIDKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return
    Merchant_BuyItem($model_id_identification_kit, $iQuantity)
    Other_PingSleep(1000)
EndFunc ;==>BuyIDKit

;~ Buys Superior ID kit.
Func BuySuperiorIDKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return
    Merchant_BuyItem($model_id_superior_identification_kit, $iQuantity)
    Other_PingSleep(1000)
EndFunc ;==>BuySuperiorIDKit
#EndRegion Buy and Sell

;~ === Slots ===
;~ returns the amount of slots of the bag
Func GetMaxSlots($bag)
    Local $pBag = Item_GetBagPtr($bag)
    Return ($pBag = 0) ? 0 : Memory_Read($pBag + 0x20, 'long')
EndFunc ;==>GetMaxSlots

;~ returns the number of free slots in inventory
Func CountFreeSlots()
    Local $iCount = 0, $pBag

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop

        $iCount += Memory_Read($pBag + 0x20, "long") - Memory_Read($pBag + 0x10, "dword")
    Next

    Return $iCount
EndFunc ;==>CountFreeSlots

;~ returns the number of free slots in storage
Func CountFreeSlotsStorage()
    Local $iCount = 0, $pBag

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop

        $iCount += Memory_Read($pBag + 0x20, "long") - Memory_Read($pBag + 0x10, "dword")
    Next

    Return $iCount
EndFunc ;==>CountFreeSlotsStorage

Func GetFreeSlotsInventory()
    While TimerDiff($g_hTimerMoveItem) < $g_iTimeoutMoveItem
        Sleep(100)
    WEnd
    
    Local $aFreeSlots[60][2]
    Local $pItem, $pBag, $iCount = 0

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            If GetItemPtrBySlot($pBag, $slot) = 0 Then
                $aFreeSlots[$iCount][0] = $bag
                $aFreeSlots[$iCount][1] = $slot
                $iCount += 1
            EndIf
        Next
    Next
    
    If $iCount = 0 Then Return 0
    
    Redim $aFreeSlots[$iCount][2]
    Return $aFreeSlots
EndFunc ;==>GetFreeSlotsInventory

Func GetFreeSlotsStorage()
    While TimerDiff($g_hTimerMoveItem) < $g_iTimeoutMoveItem
        Sleep(100)
    WEnd

    Local $aFreeSlots[125][2]
    Local $pItem, $pBag, $iCount = 0

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then
                $aFreeSlots[$iCount][0] = $bag
                $aFreeSlots[$iCount][1] = $slot
                $iCount += 1
            EndIf
        Next
    Next
    
    If $iCount = 0 Then Return 0
    
    Redim $aFreeSlots[$iCount][2]
    Return $aFreeSlots
EndFunc ;==>GetFreeSlotsStorage
#EndRegion Items

#Region Bag
Func BagID($aBag)
    If IsPtr($aBag) Then
        Return Memory_Read($aBag + 0x8, "dword")
    ElseIf IsDllStruct($aBag) Then
        Return DllStructGetData($aBag, "ID")
    Else
        Return Memory_Read(Item_GetBagPtr($aBag) + 0x8, "dword")
    EndIf
EndFunc ;==>BagID

;~ Description: Returns the Bag of an item by ItemID/ItemPtr/ItemStruct
;~ Is Zero if the item has been destroyed(e.g. IdKit)
Func GetBagPtrByItem($pItem)
    Return Memory_Read(Item_GetItemPtr($pItem) + 0xC, 'ptr')
EndFunc ;==>GetBagPtrByItem

;~ Description: Returns the Bag Index of an item by ItemID/ItemPtr/ItemStruct
Func GetBagNumberByItem($pItem)
    Local $pBag = GetBagPtrByItem($pItem)
    If $pBag = 0 Then Return 0
    Return Memory_Read($pBag + 0x4, "dword")
EndFunc ;==>GetBagNumberByItem
#EndRegion Bag

#Region Equipment
;~ Description: Unequips item to $abag, $aslot (1-based).
;~ Equipmentslots: 1 -> Mainhand/Two-hand 2 -> Offhand 3 -> Chestpiece 4 -> Leggings
;~     5 -> Headpiece   6 -> Boots  7 -> Gloves
Func UnequipItem($aEquipmentSlot, $aBag, $aSlot)
    Return Core_SendPacket(0x10, $GC_I_HEADER_ITEM_UNEQUIP, $aEquipmentSlot - 1, BagID($aBag), $aSlot - 1)
EndFunc   ;==>UnequipItem
#EndRegion Equipment

#Region Gold
;~ Description: Have always Platin in inventory, but not to much
Func MinMaxGold()
    If Map_GetInstanceInfo("Type") <> $instancetype_outpost Then Return 0
    Local $lCharacter = GetGoldCharacter()
    
    If $lCharacter < 30000 Then
        Out("Withdrawing Gold.")
        Item_WithdrawGold(30000)
        Other_PingSleep(100)
    ElseIf $lCharacter > 70000 Then
        Out("Depositing Gold.")
        Item_DepositGold(25000)
        Other_PingSleep(100)
    EndIf
    Return 1
EndFunc ;==>MinMaxGold

;~ Description: Returns amount of gold being carried.
Func GetGoldCharacter()
    Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x90]
    Local $lReturn = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return $lReturn[1]
EndFunc   ;==>GetGoldCharacter

;~ Description: Returns amount of gold in storage.
Func GetGoldStorage()
    Local $lOffset[5] = [0, 0x18, 0x40, 0xF8, 0x94]
    Local $lReturn = Memory_ReadPtr($g_p_BasePointer, $lOffset)
    Return $lReturn[1]
EndFunc   ;==>GetGoldStorage
#EndRegion Gold

#Region Custom
;~ Return the Name of a Common or Rare Material by ModelID
Func GetMaterialName($aModelID)
    Switch $aModelID
        Case $model_id_bones
            Return "Bones"
        Case $model_id_cloth
            Return "Cloth"
        Case $model_id_dust
            Return "Dust"
        Case $model_id_feather
            Return "Feathers"
        Case $model_id_fiber
            Return "Fibers"
        Case $model_id_tanned_hide
            Return "Tanned Hide Squares"
        Case $model_id_wood
            Return "Wood Planks"
        Case $model_id_iron
            Return "Iron"
        Case $model_id_scales
            Return "Scales"
        Case $model_id_chitin
            Return "Chitin"
        Case $model_id_granite
            Return "Granite"
        Case $model_id_charcoal
            Return "Charcoal"
        Case $model_id_monstrous_claw
            Return "Monstrous Claw"
        Case $model_id_linen
            Return "Linen"
        Case $model_id_damask
            Return "Damask"
        Case $model_id_silk
            Return "Silk"
        Case $model_id_ecto
            Return "Ecto"
        Case $model_id_monstrous_eye
            Return "Monstrous Eye"
        Case $model_id_monstrous_fang
            Return "Monstrous Fang"
        Case $model_id_diamond
            Return "Diamond"
        Case $model_id_onyx
            Return "Onyx"
        Case $model_id_ruby
            Return "Ruby"
        Case $model_id_sapphire
            Return "Sapphire"
        Case $model_id_glass_vial
            Return "Glass Vial"
        Case $model_id_fur_square
            Return "Fur Square"
        Case $model_id_leather_square
            Return "Leather Square"
        Case $model_id_elonian_leather_square
            Return "Elonian Leather Square"
        Case $model_id_vial_of_ink
            Return "Vial of Ink"
        Case $model_id_obsidian_shard
            Return "Obsidian Shard"
        Case $model_id_steel_ingot
            Return "Steel Ingot"
        Case $model_id_deldrimor_steel_ingot
            Return "Deldrimor Steel Ingot"
        Case $model_id_roll_of_parchment
            Return "Roll of Parchment"
        Case $model_id_roll_of_vellum
            Return "Roll of Vellum"
        Case $model_id_spiritwood_plank
            Return "Spiritwood Plank"
        Case $model_id_amber_chunk
            Return "Amber Chunk"
        Case $model_id_jadeite_shard
            Return "Jadeite Shard"  
        Case Else
            Return "Not a Material!"
    EndSwitch
EndFunc ;==>GetMaterialName

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
    Local $pItem, $pBag, $iQuantity = 0
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If CheckIsAlc(GetItemModelID($pItem)) Then $iQuantity += GetItemQuantity($pItem)
        Next
    Next
    Return $iQuantity
EndFunc ;==>GetAlcQuantityInventory

; Uses first Alc found in Inventory, Returns 0 if no Alc available
Func UseAlc($aOneMinAlc = False)
    Local $pItem, $pBag
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If $aOneMinAlc And CheckIsOneMinAlc(GetItemModelID($pItem)) Then
                Item_UseItem($pItem)
                Return 1
            ElseIf CheckIsAlc(GetItemModelID($pItem)) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        Next
    Next
    Return 0
EndFunc ;==>UseAlc

;~ Description: Checks if ModelID belongs to an Alcohol Item
Func CheckIsAlc($aModelID)
    Switch $aModelID
        Case $model_id_hard_apple_cider, $model_id_hunters_ale, $model_id_eggnog ; 1min
            Return True
        Case $model_id_witchs_brew, $model_id_vial_of_absinthe, $model_id_shamrock_ale
            Return True
        Case $model_id_keg_of_aged_hunters_ale, $model_id_firewater, $model_id_aged_hunters_ale ; 3min
            Return True
        Case $model_id_krytan_brandy, $model_id_spiked_eggnog, $model_id_grog
            Return True
        Case Else
            Return False
    EndSwitch
    Return False
EndFunc ;==>CheckIsAlc

;~ Description: Checks if ModelID belongs to an Alcohol Item
Func CheckIsOneMinAlc($aModelID)
    Switch $aModelID
        Case $model_id_hard_apple_cider, $model_id_hunters_ale, $model_id_eggnog ; 1min
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
    Local $pItem, $pBag
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If CheckIsCitySpeed(GetItemModelID($pItem)) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        Next
    Next
    
    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If CheckIsCitySpeed(GetItemModelID($pItem)) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        Next
    Next
    Return 0
EndFunc ;==>MaintainCitySpeed

; Sells all the unneeded Mats to Merchant
; Make sure *you are standing at a Merchant!!!*
Func SellJunk()
    Local $pItem, $pBag, $iQuantity, $lModelID
    
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetMaxSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            $lModelID = GetItemModelID($pItem)
            $iQuantity = GetItemQuantity($pItem)   
            Switch $lModelID
                Case $model_id_shing_jea_key, $model_id_istani_key, $model_id_krytan_key, $model_id_obsidian_key
                    ContinueCase
                Case $model_id_wood, $model_id_chitin, $model_id_scales, $model_id_granite
                    ContinueCase
                Case $model_id_cloth, $model_id_tanned_hide
                    Merchant_SellItem($pItem, $iQuantity)
                    Other_PingSleep(500)
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
    ;~ If $aModelID = $model_id_lunar_token Then Return True
    ;~ If $aModelID = $model_id_lunar_fortune_horse Then Return True
    
    ; Lucky Treats Week
    ;~ If $aModelID = $model_id_clover Then Return True
    ;~ If $aModelID = $model_id_shamrock_ale Then Return True
    
    ; Sweet Treats Week
    ;~ If $aModelID = $model_id_golden_egg Then Return True
    ;~ If $aModelID = $model_id_chocolate_bunny Then Return True
    
    ;~ === Anniversary Celebration ===
    ;~ If $aModelID = $model_id_cupcake Then Return True
    ;~ If $aModelID = $model_id_honeycomb Then Return True
    ;~ If $aModelID = $model_id_sugary_blue_drink Then Return True
    ;~ ;~ Alcohol
    ;~ If $aModelID = $model_id_hard_apple_cider Then Return True
    ;~ If $aModelID = $model_id_hunters_ale Then Return True
    ;~ If $aModelID = $model_id_krytan_brandy Then Return True
    ;~ ;~ Party Points
    ;~ If $aModelID = $model_id_champagne_popper Then Return True
    ;~ If $aModelID = $model_id_bottle_rocket Then Return True
    ;~ If $aModelID = $model_id_sparkler Then Return True
    ;~ ;~ 50 Point Boss Items
    ;~ If $aModelID = $model_id_delicious_cake Then Return True
    ;~ If $aModelID = $model_id_iced_tea Then Return True
    ;~ If $aModelID = $model_id_party_beacon Then Return True
    
    ; Dragon Festival
    If $aModelID = $model_id_victory_token Then Return True ; also anniversary
    
    ; Wintersday in July
    ; -->see Wintersday
    
    ; Wayfarer's Reverie
    ; If $aModelID = $model_id_wayfarers_mark Then Return True ; this ID is WRONG in constants.au3
    
    ; Pirate Week
    ; If $aModelID = $model_id_grog Then Return True
    
    ; Halloween
    ;~ If $aModelID = $model_id_tot_bag Then Return True
    
    ; Special Treats Week
    ;~ If $aModelID = $model_id_pumpkin_pie Then Return True ; + Hard Apple Cider, see above
    
    ; Wintersday
    ;~ If $aModelID = $model_id_candy_cane_shard Then Return True
    ;~ If $aModelID = $model_id_eggnog Then Return True
    ;~ If $aModelID = $model_id_spiked_eggnog Then Return True
    ;~ If $aModelID = $model_id_fruitcake Then Return True
    ;~ If $aModelID = $model_id_snowman_summoner Then Return True
        
    ;~ If $aModelID = $model_id_frosty_tonic Then Return True
    ;~ If $aModelID = $model_id_mischievous_tonic Then Return True
    ;~ If $aModelID = $model_id_yuletide_tonic Then Return True
    
    ;~ If $aModelID = $model_id_wintergreen_candy_cane Then Return True
    ;~ If $aModelID = $model_id_rainbow_candy_cane Then Return True
    ;~ If $aModelID = $model_id_peppermint_candy_cane Then Return True
    
    Return False
EndFunc ;==>IsEventItem

;~ Description: Looks for valueable Insignia. 0 value will be skipped. Returns the value of Insignia, to use as comparison to rune value.
Func IsInsignia($pItem)
    Local $sModstruct = GetModStruct($pItem)

    For $i = 0 To UBound($array_insignia) - 1
        If $array_insignia[$i][$insig_value] = 0 Then ContinueLoop
        If StringInStr($sModstruct, $array_insignia[$i][$insig_mod_string]) > 0 Then
            Out($array_insignia[$i][$insig_name]) 
            Return $array_insignia[$i][$insig_value]
        EndIf
    Next
    Return 0
EndFunc ;==>IsInsignia

Func IsRune($pItem)
    Local $sModstruct = GetModStruct($pItem), $lRarity = GetRarity($pItem)

    Switch $lRarity
        Case $rarity_blue
            For $i = 0 To UBound($array_rune_minor) - 1
                If $array_rune_minor[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_minor[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_minor[$i][$rune_name])
                    Return $array_rune_minor[$i][$rune_value]
                EndIf
            Next
        Case $rarity_purple
            For $i = 0 To UBound($array_rune_major) - 1
                If $array_rune_major[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_major[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_major[$i][$rune_name])
                    Return $array_rune_major[$i][$rune_value]
                EndIf
            Next
        Case $rarity_gold
            For $i = 0 To UBound($array_rune_superior) - 1
                If $array_rune_superior[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_superior[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_superior[$i][$rune_name])
                    Return $array_rune_superior[$i][$rune_value]
                EndIf
            Next
    EndSwitch
    Return 0
EndFunc ;==>IsRune
#EndRegion Custom

#Region ModStruct
;~ Description: Returns modstruct of an item.
Func GetModStruct($pItem)
    If IsString($pItem) Then Return $pItem

    $pItem = Item_GetItemPtr($pItem)
    If $pItem = 0 Then Return 0

    Local $lModStructPtr = Item_GetItemInfoByPtr($pItem, "ModStruct")
    If $lModStructPtr = 0 Then Return 0

    Local $lModStructSize = Item_GetItemInfoByPtr($pItem, "ModStructSize")
    If $lModStructSize = 0 Then Return 0
    
    Return String(Memory_Read($lModStructPtr, 'Byte[' & $lModStructSize * 4 & ']'))
EndFunc ;==>GetModStruct

;~ Description: Returns an array of a the requested mod.
Func GetModByIdentifier($pItem, $sIdentifier)
    Local $aReturn[2] = [0, 0]
    Local $sModStruct = StringTrimLeft(GetModStruct($pItem), 2)

    For $i = 0 To StringLen($sModStruct) / 8 - 2
        If StringMid($sModStruct, 8 * $i + 5, 4) == $sIdentifier Then
            $aReturn[0] = Int("0x" & StringMid($sModStruct, 8 * $i + 1, 2))
            $aReturn[1] = Int("0x" & StringMid($sModStruct, 8 * $i + 3, 2))
            ExitLoop
        EndIf
    Next

    Return $aReturn
EndFunc ;==>GetModByIdentifier

;~ checks complete modstruct for a pattern
Func CheckModstruct($sModstruct, $sPattern)
    Return StringInStr($sModstruct, $sPattern) > 0
EndFunc ;==>CheckModstruct
#EndRegion ModStruct

#Region Weapons
;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq($pItem)
    Local $lMod = GetModByIdentifier($pItem, '9827')
    Return $lMod[0]
EndFunc ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute($pItem)
    Local $lMod = GetModByIdentifier($pItem, '9827')
    Return $lMod[1]
EndFunc ;==>GetItemAttribute

;~ Description: Returns the maximum Dmg/Energy/Armor
Func GetItemMaxDmg($pItem)
    Local $lModString = GetModStruct($pItem)
    Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
    If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
    If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
    If $lPos = 0 Then Return 0

    Return Int("0x" & StringMid($lModString, $lPos - 2, 2))
EndFunc ;==>GetItemMaxDmg

;~ Description: Returns the minimum Dmg/Energy/Armor
Func GetItemMinDmg($pItem)
    Local $lModString = GetModStruct($pItem)
    Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
    If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
    If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
    If $lPos = 0 Then Return 0

    Return Int("0x" & StringMid($lModString, $lPos - 4, 2))
EndFunc ;==>GetItemMinDmg

;~ Description: Returns Dmg/Energy/Armor
Func GetItemDmg($pItem)
    Local $lModString = GetModStruct($pItem)
    Local $lPos = StringInStr($lModString, "A8A7") ; Weapon Damage
    If $lPos = 0 Then $lPos = StringInStr($lModString, "C867") ; Energy (focus)
    If $lPos = 0 Then $lPos = StringInStr($lModString, "B8A7") ; Armor (shield)
    If $lPos = 0 Then Return 0

    Local $lMod[2] = [0, 0]
    $lMod[0] = Int("0x" & StringMid($lModString, $lPos - 4, 2))
    $lMod[1] = Int("0x" & StringMid($lModString, $lPos - 2, 2))
    Return $lMod
EndFunc ;==>GetItemDmg

Func IsItemMaxDmg($pItem)
    Local $iType = GetItemType($pItem)

    If Not IsWeaponByType($iType) Then Return False

    Local $lDmg = GetItemDmg($pItem)
    If $lDmg = 0 Then Return False
    
    Switch $iType
        Case $item_type_axe
            If $lDmg[0] = 6 And $lDmg[1] = 28 Then Return True
        Case $item_type_bow
            If $lDmg[0] = 15 And $lDmg[1] = 28 Then Return True
        Case $item_type_offhand
            If $lDmg[1] = 12 Then Return True
        Case $item_type_hammer
            If $lDmg[0] = 19 And $lDmg[1] = 35 Then Return True
        Case $item_type_wand
            If $lDmg[0] = 11 And $lDmg[1] = 22 Then Return True
        Case $item_type_shield
            If $lDmg[1] = 16 Then Return True
        Case $item_type_staff
            If $lDmg[0] = 11 And $lDmg[1] = 22 Then Return True
        Case $item_type_sword
            If $lDmg[0] = 15 And $lDmg[1] = 22 Then Return True
        Case $item_type_daggers
            If $lDmg[0] = 7 And $lDmg[1] = 17 Then Return True
        Case $item_type_scythe
            If $lDmg[0] = 9 And $lDmg[1] = 41 Then Return True
        Case $item_type_spear
            If $lDmg[0] = 14 And $lDmg[1] = 27 Then Return True
    EndSwitch
    Return False
EndFunc ;==>IsItemMaxDmg

;~ Returns True if the Item is of a Weapon Type
Func IsWeapon($pItem)
    Switch GetItemType($pItem)
        Case    $item_type_axe, $item_type_bow, $item_type_offhand, _
                $item_type_hammer, $item_type_wand, $item_type_shield, _
                $item_type_staff, $item_type_sword, $item_type_daggers, _
                $item_type_scythe, $item_type_spear
                    Return True
    EndSwitch
    Return False
EndFunc ;==>IsWeapon

;~ Returns True if the Item is of a Weapon Type
Func IsWeaponByType($iType)
    Switch $iType
        Case    $item_type_axe, $item_type_bow, $item_type_offhand, _
                $item_type_hammer, $item_type_wand, $item_type_shield, _
                $item_type_staff, $item_type_sword, $item_type_daggers, _
                $item_type_scythe, $item_type_spear
                    Return True
    EndSwitch
    Return False
EndFunc ;==>IsWeaponByType

;~ Checks if any Weapon is in Inventory
Func HasWeaponsInInventory()
    Local $aWeapons = GetItemInInventoryByType($g_aWeaponType)

    For $i = 0 To UBound($aWeapons) - 1
        If $aWeapons[$i] <> 0 Then Return True
    Next
    Return False
EndFunc ;==>HasWeaponsInInventory
#Region Weapons

#Region Weapon Mods
;~ checks for 'of the Profession' upgrade
Func HasUpgradeOfTheProfession($pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "fastcasting", "mesmer", "mes"
                If CheckModstruct($sModStruct, "0500A828") Then Return True

            Case "soulreaping", "necromancer", "necro"
                If CheckModstruct($sModStruct, "0506A828") Then Return True

            Case "energystorage", "elementalist", "ele"
                If CheckModstruct($sModStruct, "050CA828") Then Return True

            Case "divinefavor", "monk"
                If CheckModstruct($sModStruct, "0510A828") Then Return True

            Case "strength", "warrior"
                If CheckModstruct($sModStruct, "0511A828") Then Return True

            Case "expertise", "ranger"
                If CheckModstruct($sModStruct, "0517A828") Then Return True

            Case "criticalstrikes", "assassin", "assa", "sin"
                If CheckModstruct($sModStruct, "0523A828") Then Return True

            Case "spawningpower", "ritualist", "rit"
                If CheckModstruct($sModStruct, "0524A828") Then Return True

            Case "leadership", "paragon", "para"
                If CheckModstruct($sModStruct, "0528A828") Then Return True

            Case "mysticism", "dervish", "derv"
                If CheckModstruct($sModStruct, "052CA828") Then Return True
        
        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradeOfTheProfession

;~ checks if item contains selected prefix
Func HasUpgradePrefix($pItem, $sMods)
    If $sMods = "" Then Return False

    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "33bleeding", "barbed"
                If CheckModstruct($sModStruct, "DE016824") Then Return True
            Case "33crippled", "crippling"
                If CheckModstruct($sModStruct, "E1016824") Then Return True
            Case "33deepwound", "cruel"
                If CheckModstruct($sModStruct, "E2016824") Then Return True
            Case "33weakness", "heavy"
                If CheckModstruct($sModStruct, "E6016824") Then Return True
            Case "33poison", "poisonous"
                If CheckModstruct($sModStruct, "E4016824") Then Return True
            Case "33dazed", "silencing"
                If CheckModstruct($sModStruct, "E5016824") Then Return True

            Case "earth", "ebon"
                If CheckModstruct($sModStruct, "000BB824") Then Return True
            Case "fire", "fiery"
                If CheckModstruct($sModStruct, "0005B824") Then Return True
            Case "cold", "icy"
                If CheckModstruct($sModStruct, "0003B824") Then Return True
            Case "lightning", "shocking"
                If CheckModstruct($sModStruct, "0004B824") Then Return True

            Case "10adrenaline", "furious"
                If CheckModstruct($sModStruct, "0A00B823") Then Return True
            Case "sundering"
                If CheckModstruct($sModStruct, "1414F823") Then Return True
            Case "vampiric"
                If CheckModstruct($sModStruct, "00032825") Then Return True
                If CheckModstruct($sModStruct, "00052825") Then Return True
            Case "zealous"
                If CheckModstruct($sModStruct, "01001825") Then Return True

            Case "20hct", "adept", "adeptstaffhead"
                If CheckModstruct($sModStruct, "2004302500140828") Then Return True
            Case "5a", "defensive", "defensivestaffhead"
                If CheckModstruct($sModStruct, "2201302505000821") Then Return True
            Case "30hp", "hale", "halestaffhead"
                If CheckModstruct($sModStruct, "3A013025001E4823") Then Return True
            Case "10hct", "swift", "swiftstaffhead"
                If CheckModstruct($sModStruct, "1E043025000A0822") Then Return True

        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradePrefix

;~ checks if item contains selected suffix
Func HasUpgradeSuffix($pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "5a", "defense", "ofdefense"
                If CheckModstruct($sModStruct, "05000821") Then Return True
            Case "7physical", "shelter", "ofshelter"
                If CheckModstruct($sModStruct, "07005821") Then Return True
            Case "7elemental", "warding", "ofwarding"
                If CheckModstruct($sModStruct, "07002821") Then Return True

            Case "20ench", "enchanting", "ofenchanting"
                If CheckModstruct($sModStruct, "1400B822") Then Return True
            Case "10hct", "swiftness", "ofswiftness"
                If CheckModstruct($sModStruct, "39043025000A0822") Then Return True
            Case "20hct", "aptitude", "ofaptitude"
                If CheckModstruct($sModStruct, "2F04302500140828") Then Return True

            Case "30hp", "fortitude", "offortitude"
                If CheckModstruct($sModStruct, "001E4823") Then Return True
            Case "45ench", "devotion", "ofdevotion"
                If CheckModstruct($sModStruct, "002D6823") Then Return True
            Case "45stance", "endurance", "ofendurance"
                If CheckModstruct($sModStruct, "002D8823") Then Return True
            Case "60hex", "valor", "ofvalor"
                If CheckModstruct($sModStruct, "003C7823") Then Return True

            ;~ both do the same, maybe diff function for the staff upgrade, to include attribute?
            Case "+120attribute", "attribute", "ofattribute"
                Local $aMod = GetModByIdentifier($sModStruct, "1824")
                Return $aMod[0] = 20
            Case "+120mastery", "mastery", "ofmastery"
                Local $aMod = GetModByIdentifier($sModStruct, "1824")
                Return $aMod[0] = 20

            Case "10hsr", "quickening", "ofquickening"
                If CheckModstruct($sModStruct, "C1023025000AA823") Then Return True
            Case "20hsr", "memory", "ofmemory"
                If CheckModstruct($sModStruct, "BF02302500142828") Then Return True

            ;~ needs work, check for 20% missing, maybe diff function?
            Case "20undead", "deathbane", "ofdeathbane"
                If CheckModstruct($sModStruct, "00008080") Then Return True

            Case "20charr", "charrslaying", "ofcharrslaying"
                If CheckModstruct($sModStruct, "00018080") Then Return True

            Case "20trolls", "trollslaying", "oftrollslaying"
                If CheckModstruct($sModStruct, "00028080") Then Return True

            Case "20plants", "pruning", "ofpruning"
                If CheckModstruct($sModStruct, "00038080") Then Return True

            Case "20skeleton", "skeletonslaying", "ofskeletonslaying"
                If CheckModstruct($sModStruct, "00048080") Then Return True

            Case "20giants", "giantslaying", "ofgiantslaying"
                If CheckModstruct($sModStruct, "00058080") Then Return True

            Case "20dwarves", "dwarfslaying", "ofdwarfslaying"
                If CheckModstruct($sModStruct, "00068080") Then Return True

            Case "20tengu", "tenguslaying", "oftenguslaying"
                If CheckModstruct($sModStruct, "00078080") Then Return True

            Case "20demons", "demonslaying", "ofdemonslaying"
                If CheckModstruct($sModStruct, "00088080") Then Return True

            Case "20dragons", "dragonslaying", "ofdragonslaying"
                If CheckModstruct($sModStruct, "00098080") Then Return True
            
            Case "20ogres", "ogreslaying", "ofogreslaying"
                If CheckModstruct($sModStruct, "000A8080") Then Return True

        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradeSuffix

;~ checks if item contains selected inscription
Func HasInscription($pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "1550", "strengthandhonor"
                If CheckModstruct($sModStruct, "CA0232250F327822") Then Return True
            Case "15ench", "guidedbyfate"
                If CheckModstruct($sModStruct, "C80232250F006822") Then Return True
            Case "15stance", "dancewithdeath"
                If CheckModstruct($sModStruct, "D00232250F00A822") Then Return True
            Case "15vshexed", "toomuchinformation"
                If CheckModstruct($sModStruct, "C60232250F005822") Then Return True
            Case "15-10a", "tothepain"
                If CheckModstruct($sModStruct, "D40232250F003822D40232250A001820") Then Return True
            Case "15-5e", "brawnoverbrains"
                If CheckModstruct($sModStruct, "D20232250F003822D20232250500B820") Then Return True
            Case "2050", "vengeanceismine"
                If CheckModstruct($sModStruct, "CC02322514328822") Then Return True
            Case "20hexed", "dontfearthereaper"
                If CheckModstruct($sModStruct, "CE02322514009822") Then Return True

            Case "5e", "ihavethepower"
                If CheckModstruct($sModStruct, "B80232250500D822") Then Return True
            Case "5e50", "haleandhearty"
                If CheckModstruct($sModStruct, "B403322505320823") Then Return True
            Case "5eench", "havefaith"
                If CheckModstruct($sModStruct, "B20332250500F822") Then Return True
            Case "7e50", "dontcallitacomeback"
                If CheckModstruct($sModStruct, "B603322507321823") Then Return True
            Case "7ehexed", "iamsorrow"
                If CheckModstruct($sModStruct, "B803322507002823") Then Return True
            Case "15e-1main", "seizetheday"
                If CheckModstruct($sModStruct, "B00332250F00D822B00332250100C820") Then Return True

            Case "10hct", "dontthinktwice"
                If CheckModstruct($sModStruct, "BA033225000A0822") Then Return True
            Case "10hsr", "letthememoryliveagain"
                If CheckModstruct($sModStruct, "BC023225000AA823") Then Return True
            Case "20hct", "aptitudenotattitude"
                If CheckModstruct($sModStruct, "AE03322500140828") Then Return True

            Case "10blunt", "nottheface"
                If CheckModstruct($sModStruct, "860332A50A0018A1") Then Return True
            Case "10cold", "leafonthewind"
                If CheckModstruct($sModStruct, "880332A50A0318A1") Then Return True
            Case "10earth", "likearollingstone"
                If CheckModstruct($sModStruct, "8A0332A50A0B18A1") Then Return True
            Case "10fire", "sleepnowinthefire"
                If CheckModstruct($sModStruct, "8E0332A50A0518A1") Then Return True
            Case "10lightning", "ridersonthestorm"
                If CheckModstruct($sModStruct, "8C0332A50A0418A1") Then Return True
            Case "10piercing", "throughthickandthin"
                If CheckModstruct($sModStruct, "900332A50A0118A1") Then Return True
            Case "10slashing", "theriddleofsteel"
                If CheckModstruct($sModStruct, "920332A50A0218A1") Then Return True
                
            Case "-2ench", "shelteredbyfaith"
                If CheckModstruct($sModStruct, "A603322502008820") Then Return True
            Case "-2stance", "runforyourlife"
                If CheckModstruct($sModStruct, "AA0332250200A820") Then Return True
            Case "-3hex", "nothingtofear"
                If CheckModstruct($sModStruct, "A803322503009820") Then Return True
            Case "-520", "luckofthedraw"
                If CheckModstruct($sModStruct, "A403322505147820") Then Return True

            Case "20bleeding", "fearcutsdeeper"
                If CheckModstruct($sModStruct, "9403322500005828") Then Return True
            Case "20blind", "icanseeclearlynow"
                If CheckModstruct($sModStruct, "9603322500015828") Then Return True
            Case "20crippled", "swiftasthewind"
                If CheckModstruct($sModStruct, "9803322500035828") Then Return True
            Case "20dazed", "soundnessofmind"
                If CheckModstruct($sModStruct, "A003322500075828") Then Return True
            Case "20deepwound", "strengthofbody"
                If CheckModstruct($sModStruct, "9A03322500045828") Then Return True
            Case "20disease", "castouttheunclean"
                If CheckModstruct($sModStruct, "9C03322500055828") Then Return True
            Case "20poison", "pureofheart"
                If CheckModstruct($sModStruct, "9E03322500065828") Then Return True
            Case "20weakness", "onlythestrongsurvive"
                If CheckModstruct($sModStruct, "A203322500085828") Then Return True

            Case "5a50", "hailtotheking"
                If CheckModstruct($sModStruct, "7C0332250532A821") Then Return True
            Case "5aench", "faithismyshield"
                If CheckModstruct($sModStruct, "7803322505009821") Then Return True
            Case "5aattacking", "mightmakesright"
                If CheckModstruct($sModStruct, "7403322505007821") Then Return True
            Case "5acasting", "knowingishalfthebattle"
                If CheckModstruct($sModStruct, "7603322505008821") Then Return True
            Case "5aelemental", "manforallseasons"
                If CheckModstruct($sModStruct, "7003322505002821") Then Return True
            Case "5aphysical", "survivalofthefittest"
                If CheckModstruct($sModStruct, "7203322505005821") Then Return True
            Case "5a-5e", "ignoranceisbliss"
                If CheckModstruct($sModStruct, "6C033225050008216C0332250500B820") Then Return True
            Case "5a-20hp", "lifeispain"
                If CheckModstruct($sModStruct, "6E033225050008216E0332251400D820") Then Return True
            Case "10a50", "downbutnotout"
                If CheckModstruct($sModStruct, "7A0332250A32B821") Then Return True
            Case "10ahexed", "bejustandfearnot"
                If CheckModstruct($sModStruct, "7E0332250A00C821") Then Return True
            Case "15e-1offhand", "livefortoday"
                If CheckModstruct($sModStruct, "800332250F00D822800332250100C820") Then Return True
                
            Case "+120", "masterofmydomain"
                If CheckModstruct($sModStruct, "AC03322500143828") Then Return True
            Case "10hsroffhand", "serenitynow"
                If CheckModstruct($sModStruct, "82033225000AA823") Then Return True
            Case "20hsr", "forgetmenot"
                If CheckModstruct($sModStruct, "8403322500142828") Then Return True
                
            Case "m4m", "measureformeasure"
                If CheckModstruct($sModStruct, "3E0432251D000826") Then Return True
            Case "showmethemoney"
                If CheckModstruct($sModStruct, "3C0432252E00F825") Then Return True
                If CheckModstruct($sModStruct, "3C0432253000F825") Then Return True
        EndSwitch
    Next

    Return False
EndFunc ;==>HasInscription


;~ checks for 20% HSR upgrade (any)
Func Is20HSR($pItem)
    Local $aMod = GetModByIdentifier($pItem, '2828')
    Return $aMod[1] = 20
EndFunc ;==>Is20HSR

;~ checks for wand wrapping of memory (20% HSR)
Func IsWandWrappingOfMemory($pItem)
    Return CheckModstruct(GetModStruct($pItem), "BF02302500142828")
EndFunc ;==>IsWandWrappingOfMemory

;~ checks for forget me not inscription (20% HSR)
Func IsForgetMeNot($pItem)
    Return CheckModstruct(GetModStruct($pItem), "8403322500142828")
EndFunc ;==>IsForgetMeNot

;~ checks for inherent 20% staff HSR
Func Is20HSRStaff($pItem)
    Local $aMod = GetModByIdentifier($pItem, 'A823')
    Return $aMod[1] = 20
EndFunc ;==>Is20HSRStaff


;~ checks for 10% HSR upgrade (any)
Func Is10HSR($pItem)
    Local $aMod = GetModByIdentifier($pItem, 'A823')
    Return $aMod[1] = 10
EndFunc ;==>Is10HSR

;~ checks for wand wrapping of quickening (10% HSR)
Func IsWandWrappingOfQuickening($pItem)
    Return CheckModstruct(GetModStruct($pItem), "C1023025000AA823")
EndFunc ;==>IsWandWrappingOfQuickening

;~ checks for serenity now inscription (10% HSR)
Func IsSerenityNow($pItem)
    Return CheckModstruct(GetModStruct($pItem), "82033225000AA823")
EndFunc ;==>IsSerenityNow

;~ checks for let the memory live again inscription (10% HSR)
Func IsLetTheMemoryLiveAgain($pItem)
    Return CheckModstruct(GetModStruct($pItem), "BC023225000AA823")
EndFunc ;==>IsLetTheMemoryLiveAgain


;~ checks for 20% HCT upgrade (any)
Func Is20HCT($pItem)
    Local $aMod = GetModByIdentifier($pItem, '0828')
    Return $aMod[1] = 20
EndFunc ;==>Is20HCT

;~ checks for focus core of aptitude (20% HCT)
Func IsFocusCoreOfAptitude($pItem)
    Return CheckModstruct(GetModStruct($pItem), "2F04302500140828")
EndFunc ;==>IsFocusCoreOfAptitude

;~ checks for adept staff head (20% HCT)
Func IsAdeptStaffHead($pItem)
    Return CheckModstruct(GetModStruct($pItem), "2004302500140828")
EndFunc ;==>IsAdeptStaffHead

;~ checks for aptitude not attitude inscription (20% HCT)
Func IsAptitudeNotAttitude($pItem)
    Return CheckModstruct(GetModStruct($pItem), "AE03322500140828")
EndFunc ;==>IsAptitudeNotAttitude


;~ checks for 10% HCT upgrade (any)
Func Is10HCT($pItem)
    Local $aMod = GetModByIdentifier($pItem, '0822')
    Return $aMod[1] = 10
EndFunc ;==>Is20HCT

;~ checks for focus core of swiftness (10% HCT)
Func IsFocusCoreOfSwiftness($pItem)
    Return CheckModstruct(GetModStruct($pItem), "39043025000A0822")
EndFunc ;==>IsFocusCoreOfSwiftness

;~ checks for swift staff head (10% HCT)
Func IsSwiftStaffHead($pItem)
    Return CheckModstruct(GetModStruct($pItem), "1E043025000A0822")
EndFunc ;==>IsSwiftStaffHead

;~ checks for don't think twice inscription (10% HCT)
Func IsDontThinkTwice($pItem)
    Return CheckModstruct(GetModStruct($pItem), "BA033225000A0822")
EndFunc ;==>IsDontThinkTwice


;~ checks for +30Hp upgrade (any)
Func Is30Hp($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '4823')
    If $aMod[1] < 30 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing
    Return False
EndFunc ;==>Is30Hp

;~ checks for hale staff head (+30hp prefix)
Func IsHaleStaffHead($pItem)
    Return CheckModstruct(GetModStruct($pItem), "3A013025001E4823")
EndFunc ;==>IsHaleStaffHead

;~ checks for staff wrapping of fortitude (+30hp suffix)
Func IsStaffWrappingOfFortitude($pItem)
    Return CheckModstruct(GetModStruct($pItem), "B9013025001E4823")
EndFunc ;==>IsStaffWrappingOfFortitude

;~ checks for +45^ench upgrade (any)
Func Is45HpEnch($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '6823')
    If $aMod[1] < 45 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing
    Return False
EndFunc ;==>Is45HpEnch

;~ checks for +45^stance upgrade (any)
Func Is45HpStance($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '8823')
    If $aMod[1] < 45 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing
    Return False
EndFunc ;==>Is45HpStance

;~ checks for +60^hex upgrade (any)
Func Is60HpHex($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '7823')
    If $aMod[1] < 60 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing
    Return False
EndFunc ;==>Is60HpHex


;~ checks for vampiric upgrade
Func IsVampiric($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '2825')
    If $aMod[1] = 0 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing, also check if vamp is max
    Return False
EndFunc ;==>IsVampiric

;~ checks for zealous upgrade
Func IsZealous($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '1825')
    If $aMod[0] = 0 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing
    Return False
EndFunc ;==>IsZealous


;~ checks for 'of Enchanting' upgrade (any)
Func IsOfEnchanting($pItem, $iWeaponType = -1)
    Local $aMod = GetModByIdentifier($pItem, 'B822')
    If $aMod[0] < 20 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type missing
    Return False
EndFunc ;==>IsOfEnchanting


;~ checks for insightful staff head (+5e)
Func IsInsightfulStaffHead($pItem)
    Return CheckModstruct(GetModStruct($pItem), "9C000824380130250500D822")
EndFunc ;==>IsInsightfulStaffHead

;~ checks for I have the power inscription (+5e)
Func IsIHaveThePower($pItem)
    Return CheckModstruct(GetModStruct($pItem), "B80232250500D822")
EndFunc ;==>IsIHaveThePower

;~ checks for have faith inscription (+5e^ench)
Func IsHaveFaith($pItem)
    Return CheckModstruct(GetModStruct($pItem), "B20332250500F822")
EndFunc ;==>IsHaveFaith

;~ checks for seize the day inscription (+15e^-1)
Func IsSeizeTheDay($pItem)
    Return CheckModstruct(GetModStruct($pItem), "B00332250F00D822B00332250100C820")
EndFunc ;==>IsSeizeTheDay

;~ checks for live for today inscription (+15e^-1)
Func IsLiveForToday($pItem)
    Return CheckModstruct(GetModStruct($pItem), "800332250F00D822800332250100C820")
EndFunc ;==>IsLiveForToday


;~ checks for "to the pain inscription" (15^-10a)
Func IsToThePain($pItem)
    Return CheckModstruct(GetModStruct($pItem), "D40232250F003822D40232250A001820")
EndFunc ;==>IsToThePain

;~ checks for "brawn over brains" inscription (15^-5e)
Func IsBrawnOverBrains($pItem)
    Return CheckModstruct(GetModStruct($pItem), "D20232250F003822D20232250500B820")
EndFunc ;==>IsBrawnOverBrains

;~ checks for "guided by faith" inscription (15^ench)
Func IsGuidedByFaith($pItem)
    Return CheckModstruct(GetModStruct($pItem), "C80232250F006822")
EndFunc ;==>IsGuidedByFaith

;~ checks for "strength is honor" inscription (15^50)
Func IsStrengthAndHonor($pItem)
    Return CheckModstruct(GetModStruct($pItem), "CA0232250F327822")
EndFunc ;==>IsStrengthAndHonor

;~ checks for "vengeance is mine" inscription (20^50)
Func IsVengeanceIsMine($pItem)
    Return CheckModstruct(GetModStruct($pItem), "CC02322514328822")
EndFunc ;==>IsVengeanceIsMine

;~ checks for "dont fear the reaper" inscription (20^hexed)
Func IsDontFearTheReaper($pItem)
    Return CheckModstruct(GetModStruct($pItem), "CE02322514009822")
EndFunc ;==>IsDontFearTheReaper

;~ checks for "dance with death" inscription (15^stance)
Func IsDanceWithDeath($pItem)
    Return CheckModstruct(GetModStruct($pItem), "D00232250F00A822")
EndFunc ;==>IsDanceWithDeath

;~ checks for "too much information" inscription (15^vsHexed)
Func IsTooMuchInformation($pItem)
    Return CheckModstruct(GetModStruct($pItem), "C60232250F005822")
EndFunc ;==>IsTooMuchInformation


;~ checks for "sheltered by faith" inscription (-2^ench)
Func IsShelteredByFaith($pItem)
    Return CheckModstruct(GetModStruct($pItem), "A603322502008820")
EndFunc ;==>IsShelteredByFaith

;~ checks for "run for your life" inscription (-2^stance)
Func IsRunForYourLife($pItem)
    Return CheckModstruct(GetModStruct($pItem), "AA0332250200A820")
EndFunc ;==>IsRunForYourLife

;~ checks for "nothing to fear" inscription (-3^hex)
Func IsNothingToFear($pItem)
    Return CheckModstruct(GetModStruct($pItem), "A803322503009820")
EndFunc ;==>IsNothingToFear

;~ checks for "luck of the draw" inscription (-5^20%)
Func IsLuckOfTheDraw($pItem)
    Return CheckModstruct(GetModStruct($pItem), "A403322505147820")
EndFunc ;==>IsLuckOfTheDraw
#EndRegion Weapon Mods

#Region OS Filter
;~ filter for any OS martial weapon
Func CheckOsMartialWeapon($pItem, $sMod = "", $iWeaponType = -1)

    If $iWeaponType <> -1 And Not IsString($pItem) Then
        If GetItemType($pItem) <> $iWeaponType Then Return False
    EndIf

    Local $sModStruct = GetModStruct($pItem)

    Switch $sMod
        Case "1550"
            Return CheckModstruct($sModStruct, "0F327822")
        Case "15ench"
            Return CheckModstruct($sModStruct, "0F006822")
        Case "15stance"
            Return CheckModstruct($sModStruct, "0F00A822")
        Case "15vshexed"
            Return CheckModstruct($sModStruct, "0F005822")
        Case "15-5e"
            Return CheckModstruct($sModStruct, "0F0038220500B820")
        Case "15-10a"
            Return CheckModstruct($sModStruct, "0F0038220A001820")
        Case "5e"
            Return CheckModstruct($sModStruct, "0500D822")
        Case "2050"
            Return CheckModstruct($sModStruct, "14009822")
        Case "dualvamp"
            Return CheckModstruct($sModStruct, "0F0038220100E820")
        Case "dualzeal"
            Return CheckModstruct($sModStruct, "0F0038220100C820")
    EndSwitch

    Return False
EndFunc ;==>CheckOsMartialWeapon

;~ filter for OS wand
Func CheckOsWand($pItem)
    Local $sModStruct = GetModStruct($pItem)
EndFunc ;==>CheckOsWand

;~ filter for OS focus
Func CheckOsFocus($pItem)
    Local $sModStruct = GetModStruct($pItem)
EndFunc ;==>CheckOsFocus

;~ filter for OS staff
Func CheckOsStaff($pItem)
    Local $sModStruct = GetModStruct($pItem)
EndFunc ;==>CheckOsStaff

;~ filter or OS shield
Func CheckOsShield($pItem)
    Local $sModStruct = GetModStruct($pItem)
EndFunc ;==>CheckOsShield


Func IsPerfectShield($pItem)
    If GetItemType($pItem) <> $item_type_shield Then Return False ; check if shield
    If Not IsItemMaxDmg($pItem) Then Return False
    
    Local $lReq = GetItemReq($pItem)
    Local $lModStruct = GetModStruct($pItem)
    ; Universal mods
    Local $Plus30 = StringInStr($lModStruct, "001E4823", 0, 1) ; +30HP
    Local $Plus45Ench = StringInStr($lModStruct, "002D6823", 0, 1) ; +45^ench
    Local $Plus44Ench = StringInStr($lModStruct, "002C6823", 0, 1) ; +44^ench
    Local $Plus43Ench = StringInStr($lModStruct, "002B6823", 0, 1) ; +43^ench
    Local $Plus42Ench = StringInStr($lModStruct, "002A6823", 0, 1) ; +42^ench
    Local $Plus41Ench = StringInStr($lModStruct, "00296823", 0, 1) ; +41^ench
    Local $Minus2Ench = StringInStr($lModStruct, "02008820", 0, 1) ; -2^ench
    Local $Minus3Hex = StringInStr($lModStruct, "3009820", 0, 1) ; -3^hex
    Local $Plus60Hex = StringInStr($lModStruct, "003C7823", 0, 1) ; +60^hex
    Local $Plus45Stance = StringInStr($lModStruct, "002D8823", 0, 1) ; +45^stance
    ; +1 20% Mods
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
    Local $PlusSkeletons = StringInStr($lModStruct, "0A044821", 0 ,1) ; +10vs Skeletons
    Local $PlusDemons = StringInStr($lModStruct, "0A084821", 0, 1) ; +10vs Demons
    ; +10vs Dmg
    Local $PlusBlunt = StringInStr($lModStruct, "0A001821", 0, 1) ; +10vs Blunt
    Local $PlusPiercing = StringInStr($lModStruct, "0A011821", 0, 1) ; +10vs Piercing
    Local $PlusSlashing = StringInStr($lModStruct, "0A021821", 0, 1) ; +10vs Slashing
    Local $PlusCold = StringInStr($lModStruct, "0A031821", 0, 1) ; +10 vs Cold
    Local $PlusLightning = StringInStr($lModStruct, "0A041821", 0, 1) ; +10vs Lightning
    Local $PlusVsFire = StringInStr($lModStruct, "0A051821", 0, 1) ; +10vs Fire
    Local $PlusVsEarth = StringInStr($lModStruct, "0A0B1821", 0, 1) ; +10vs Earth

    Local $VsBlind = StringInStr($lModStruct, "DF017824", 0, 1) ; +20% vs Blind

    If $Plus30 > 0 Then
        If $PlusDemons > 0 Or $PlusUndead > 0 Or $PlusSkeletons > 0 Then
            Return True
        EndIf
        If $lReq <= 9 Then
            If $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusCold > 0 Or $PlusVsFire > 0 Then
                Return True
            ElseIf $PlusBlunt > 0 Or $PlusPiercing > 0 Or $PlusSlashing > 0 Then
                Return True
            ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 _
                Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
                    Return True
            ElseIf $Minus2Ench > 0 Then
                Return True
            EndIf
        Else
            Return False
        EndIf
    EndIf
    If $Plus45Ench > 0 Then
        If $PlusDemons > 0 Or $PlusUndead > 0 Or $PlusSkeletons > 0 Then
            Return True
        EndIf
        If $lReq <= 9 Then
            If $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusCold > 0 Or $PlusVsFire > 0 Then
                Return True
            ElseIf $PlusBlunt > 0 Or $PlusPiercing > 0 Or $PlusSlashing > 0 Then
                Return True
            ElseIf $PlusDomination > 0 Or $PlusDivine > 0 Or $PlusSmite > 0 Or $PlusHealing > 0 Or $PlusProt > 0 Or $PlusFire > 0 Or $PlusWater > 0 Or $PlusAir > 0 Or $PlusEarth > 0 _
                Or $PlusDeath > 0 Or $PlusBlood > 0 Or $PlusIllusion > 0 Or $PlusInspiration > 0 Or $PlusSoulReap > 0 Or $PlusCurses > 0 Then
                    Return True
            ElseIf $Minus2Ench > 0 Then
                Return True
            EndIf
        EndIf
    EndIf
    If $lReq <= 9 And $Minus2Ench > 0 Then
        If $PlusDemons > 0 Or $PlusUndead > 0 Or $PlusSkeletons > 0 Then
            Return True
        ElseIf $PlusLightning > 0 Or $PlusVsEarth > 0 Or $PlusCold > 0 Or $PlusFire > 0 Then
            Return True
        ElseIf $PlusBlunt > 0 Or $PlusPiercing > 0 Or $PlusSlashing > 0 Then
            Return True
        EndIf
    EndIf
    If $lReq <= 9 And ($Plus44Ench > 0 Or $Plus43Ench Or $Plus42Ench Or $Plus41Ench) Then
        If $PlusDemons > 0 Or $PlusSkeletons > 0 Then
            Return True
        EndIf
    EndIf
    If $Minus3Hex > 0 Then
        If $PlusSkeletons > 0 Then
            Return True
        ;~ ElseIf $Plus60Hex > 0 Then
        ;~  Return True
        EndIf
    EndIf
    If $VsBlind > 0 Then
        If $PlusSkeletons > 0 Or $PlusLightning > 0 Then
            Return True
        EndIf
    EndIf
    If $PlusDemons > 0 Then
        If $PlusDomination > 0 Then
            Return True
        EndIf
    EndIf
    Return False
EndFunc ;==>IsPerfectShield

;~ Description: Check if an OS Weapon has Dual Vamp Mod
Func IsDualVamp($pItem)
    If IsWeapon($pItem) = False Or GetRarity($pItem) <> $rarity_gold Then Return False
    Local $lModstruct = GetModStruct($pItem)
    Local $lDv15 = StringInStr($lModstruct, "0F0038220100E820")
    Local $lDv14 = StringInStr($lModstruct, "0E0038220100E820")
    If $lDv15 > 0 Or $lDv14 > 0 Then Return True
    Return False
EndFunc ;==>IsDualVamp

Func IsDualZeal($pItem)
    If IsWeapon($pItem) = False Or GetRarity($pItem) <> $rarity_gold Then Return False
    Local $lModstruct = GetModStruct($pItem)
    Local $lDz15 = StringInStr($lModstruct, "0F0038220100C820")
    Local $lDz14 = StringInStr($lModstruct, "0E0038220100C820")
    If $lDz15 > 0 Or $lDz14 > 0 Then Return True
    Return False
EndFunc ;==>IsDualZeal
#EndRegion OS Filter