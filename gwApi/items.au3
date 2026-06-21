#include-once
;~ added for safety
Global $g_hTimerMoveItem = TimerInit()
Global Const $g_iTimeoutMoveItem = 500 ; wait between different MoveItem operations (make sure Bag/Slot state is solid)

Global Enum _
    $idx_mod_shield_30hp, _
    $idx_mod_shield_45stance, _
    $idx_mod_shield_60hex, _
    $idx_mod_shield_45ench, _
    $idx_mod_shield_2ench, _
    $idx_mod_shield_2stance, _
    $idx_mod_shield_3hex, _
    $idx_mod_shield_armor_type, _
    $idx_mod_shield_armor_monster, _
    $idx_mod_shield_condition, _
    $idx_mod_shield_attribute, _
    $idx_mod_shield_size

Global Enum _
    $idx_mod_wand_5_50, _
    $idx_mod_wand_5_ench, _
    $idx_mod_wand_10_hct, _
    $idx_mod_wand_10_hsr, _
    $idx_mod_wand_20_hct_attribute, _
    $idx_mod_wand_20_hct_value, _
    $idx_mod_wand_20_hsr_attribute, _
    $idx_mod_wand_20_hsr_value, _
    $idx_mod_wand_high_energy, _
    $idx_mod_wand_attribute, _
    $idx_mod_wand_size

Global Enum _
    $idx_mod_focus_30hp, _
    $idx_mod_focus_45stance, _
    $idx_mod_focus_60hex, _
    $idx_mod_focus_45ench, _
    $idx_mod_focus_armor_enchanted, _
    $idx_mod_focus_armor_monster_type, _
    $idx_mod_focus_armor_monster_value, _
    $idx_mod_focus_10_hct, _
    $idx_mod_focus_10_hsr, _
    $idx_mod_focus_20_hct_attribute, _
    $idx_mod_focus_20_hct_value, _
    $idx_mod_focus_20_hsr_attribute, _
    $idx_mod_focus_20_hsr_value, _
    $idx_mod_focus_high_energy, _
    $idx_mod_focus_attribute, _
    $idx_mod_focus_size

#Region Items
Func GetItemPtr($iItemID, $pItemArray = 0, $pItemContext = 0)
    If IsPtr($iItemID) Then Return $iItemID

    $iItemID = GetItemID($iItemID)

    If Not IsPtr($pItemArray) Then
        If Not IsPtr($pItemContext) Then $pItemContext = Item_GetItemContextPtr()

        $pItemArray = Memory_Read($pItemContext + 0xB8, 'ptr')
    EndIf

    Return Memory_Read($pItemArray + (0x4 * $iItemID), 'ptr')
EndFunc ;==>GetItemPtr

;~ reads whole item struct
Func GetItemStruct(ByRef $tItemStruct, $pItem, $pItemArray = 0, $pItemContext = 0)
    ;~ If Not IsDllStruct($tItemStruct) Then Return SetError(3, 0, False) ; not sure if it is useful to keep this

    $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)

    If Not IsPtr($pItem) Or $pItem = 0 Then Return SetError(1, 0, False)


    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pItem, _
                    "struct*", $tItemStruct, _
                    "ulong_ptr", $g_iItemStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, False)
    
    Return True
EndFunc ;==>GetItemStruct

;~ pointer to the *global* Item Array, which contains *all* Items in the instance
Func GetItemArrayPtr()
    Local $l_ai_Offset[4] = [0, 0x18, 0x40, 0xB8]
    Local $l_ap_ItemContextPtr = Memory_ReadPtr($g_p_BasePointer, $l_ai_Offset, 'ptr')
    Return SetExtended($l_ap_ItemContextPtr[0], $l_ap_ItemContextPtr[1])
EndFunc ;==>GetItemArrayPtr

;~ Item Count of *all* Items in the instance (use in combo with GetItemArrayPtr)
Func GetMaxItems($pItemContext = 0)
    If Not IsPtr($pItemContext) Then $pItemContext = Item_GetItemContextPtr()

    Return Memory_Read($pItemContext + 0xB8 + 0x8, 'dword')
EndFunc ;==>GetMaxItems

;~ only pass ItemID, passing pointer is pointless
Func GetItemExists($iItemID)
    Return GetItemPtr($iItemID) <> 0
EndFunc ;==>GetItemExists

Func GetItemID(ByRef $pItem)
    If IsPtr($pItem) Then
        Return Memory_Read($pItem, 'dword')
    ElseIf IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'ID')
    Else
        Return $pItem
    EndIf
EndFunc ;==>GetItemID

;~ Description: Returns the AgentID of Item; $pItem = Ptr/Struct/ID
Func GetItemAgentID(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'AgentID')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0

        Return Memory_Read($pItem + 0x4, 'dword')
    EndIf
EndFunc ;==>GetItemAgentID

;~ Description: Returns the Bag of an item by ItemID/ItemPtr/ItemStruct
;~ Is Zero if the item has been destroyed(e.g. IdKit)
Func GetItemBagPtr(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'BagPtr')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Return Memory_Read($pItem + 0xC, 'ptr')
    EndIf
EndFunc ;==>GetItemBagPtr

;~ Description: Returns the Type of Item; $pItem = Ptr/Struct/ID
Func GetItemType(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'Type')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0

        Return Memory_Read($pItem + 0x20, 'byte')
    EndIf
EndFunc ;==>GetItemType

;~ Description: Returns the ExtraID of Item; $pItem = Ptr/Struct/ID
Func GetItemExtraID(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'ExtraID')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0

        Return Memory_Read($pItem + 0x22, 'byte')
    EndIf
EndFunc ;==>GetItemExtraID

;~ Description: Returns the Value of Item; $pItem = Ptr/Struct/ID
Func GetItemValue(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'Value')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0

        Return Memory_Read($pItem + 0x24, 'short')
    EndIf
EndFunc ;==>GetItemValue

;~ Description: Returns the ModelID of Item; $pItem = Ptr/Struct/ID
Func GetItemModelID(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'ModelID')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Return Memory_Read($pItem + 0x2C, 'dword')
    EndIf
EndFunc ;==>GetItemModelID

;~ Description: Returns rarity (name color) of an item; $pItem = Ptr/Struct/ID
Func GetItemRarity(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Local $pName = DllStructGetData($pItem, 'CompleteName')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Local $pName = Memory_Read($pItem + 0x38, 'ptr')
    EndIf

    If $pName = 0 Then Return 0

    Return Memory_Read($pName, "ushort")
EndFunc ;==>GetItemRarity

Func GetItemName(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Local $pName = DllStructGetData($pItem, 'Name')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Local $pName = Memory_Read($pItem + 0x34, 'ptr')
    EndIf

    If $pName = 0 Then Return 0

    Return Utils_DecodeEncStringAsync($pName)
EndFunc ;==>GetItemName

Func GetItemNameComplete(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Local $pName = DllStructGetData($pItem, 'CompleteName')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Local $pName = Memory_Read($pItem + 0x38, 'ptr')
    EndIf

    If $pName = 0 Then Return 0

    Return Utils_DecodeEncStringAsync($pName)
EndFunc ;==>GetItemNameComplete

Func GetItemNameSingle(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Local $pName = DllStructGetData($pItem, 'SingleItemName')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Local $pName = Memory_Read($pItem + 0x3C, 'ptr')
    EndIf

    If $pName = 0 Then Return 0

    Return Utils_DecodeEncStringAsync($pName)
EndFunc ;==>GetItemNameSingle

;~ Description: Tests if an Item can be salvaged into Materials.
Func GetIsSalvageable(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'IsSalvageable') <> 0
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return False
            
        Return Memory_Read($pItem + 0x4A, 'byte') <> 0
    EndIf
EndFunc ;==>GetIsSalvageable

;~ Description: Returns quantity of an item; $pItem = Ptr/Struct/ID
Func GetItemQuantity(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'Quantity')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Return Memory_Read($pItem + 0x4C, 'short')
    EndIf
EndFunc ;==>GetQuantity

;~ Returns the Slot the Item is in, if it is in inventory.
Func GetItemSlot(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'Slot')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Return Memory_Read($pItem + 0x50, 'byte')
    EndIf
EndFunc ;==>GetItemSlot

Func GetItemInteraction(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsDllStruct($pItem) Then
        Return DllStructGetData($pItem, 'Interaction')
    Else
        $pItem = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItem = 0 Then Return 0
            
        Return Memory_Read($pItem + 0x28, 'dword')
    EndIf
EndFunc ;==>GetItemInteraction

;~ Description: Tests if an item is identified.
Func GetIsIDed(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    Return BitAND(GetItemInteraction($pItem, $pItemArray, $pItemContext), 0x01) > 0
EndFunc ;==>GetIsIDed

Func GetIsIdentified(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    Return BitAND(GetItemInteraction($pItem, $pItemArray, $pItemContext), 0x01) > 0
EndFunc ;==>GetIsIdentified

;~ Description: Tests if an item is unidentfied and can be identified. (IsNotButCanBeIdentified )
Func GetCanBeIdentified(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    Return BitAND(GetItemInteraction($pItem, $pItemArray, $pItemContext), 0x00800000) > 0
EndFunc ;==>GetCanBeIdentified

Func GetItemPtrBySlot($iBag, $iSlot, $pInventory = 0)
    Local $pBag = GetBagPtr($iBag, $pInventory)
    If $pBag = 0 Then Return 0
    
    Local $pItemArray = Memory_Read($pBag + 0x18, 'ptr')

    Return Memory_Read($pItemArray + 4 * ($iSlot - 1), 'ptr')
EndFunc ;==>GetItemPtrBySlot

;~ Return first ItemPtr by ModelID in specified bags. Zero if no Item is found.
Func GetItemByModelID($aModelID, $iFirstBag, $iLastBag, $bPartialStacks = False, $bEquipmentPack = False, $bMaterialStorage = False)

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf

    Local $iSize = UBound($aModelID)
    Local $aReturn[$iSize]

    Local $aItemPtr = GetBagItemArray($iFirstBag, $iLastBag, $bEquipmentPack, $bMaterialStorage)
    If @error Then Return SetError(1, 0, ($iSize = 1) ? $aReturn[0] : $aReturn)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iModelID, $iCount = 0

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        $iModelID = GetItemModelID($tItemStruct)

        For $j = 0 To $iSize - 1
            If $aReturn[$j] <> 0 Or $iModelID <> $aModelID[$j] Then ContinueLoop
            If $bPartialStacks And GetItemQuantity($tItemStruct) >= 250 Then ContinueLoop
                
            $aReturn[$j] = $pItem

            $iCount += 1
            If $iCount = $iSize Then Return ($iSize = 1) ? $aReturn[0] : $aReturn
 
            ExitLoop
        Next
    Next
 
    Return ($iSize = 1) ? $aReturn[0] : $aReturn
EndFunc ;==>GetItemByModelID

;~ Return first ItemPtr by Type in specified bags. Zero if no Item is found.
Func GetItemByType($aType, $iFirstBag, $iLastBag, $bPartialStacks = False, $bEquipmentPack = False, $bMaterialStorage = False)

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aType) Then
        Local $aTmp[1] = [$aType]
        $aType = $aTmp
    EndIf

    Local $iSize = UBound($aType)
    Local $aReturn[$iSize]

    Local $aItemPtr = GetBagItemArray($iFirstBag, $iLastBag, $bEquipmentPack, $bMaterialStorage)
    If @error Then Return SetError(1, 0, ($iSize = 1) ? $aReturn[0] : $aReturn)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iType, $iCount = 0

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        $iType = GetItemType($tItemStruct)

        For $j = 0 To $iSize - 1
            If $aReturn[$j] <> 0 Or $iType <> $aType[$j] Then ContinueLoop
            If $bPartialStacks And GetItemQuantity($tItemStruct) >= 250 Then ContinueLoop
                
            $aReturn[$j] = $pItem

            $iCount += 1
            If $iCount = $iSize Then Return ($iSize = 1) ? $aReturn[0] : $aReturn
 
            ExitLoop
        Next
    Next
 
    Return ($iSize = 1) ? $aReturn[0] : $aReturn
EndFunc ;==>GetItemByType

; Returns the first Item by ModelID found in Inventory; If no Item is found Returns Zero
Func GetItemInInventory($aModelID, $bPartialStacks = False)
    Return GetItemByModelID($aModelID, 1, 4, $bPartialStacks)
EndFunc ;==>GetItemInInventory

; Returns the first Item by ModelID found in Storage; If no Item is found Returns Zero
Func GetItemInChest($aModelID, $bPartialStacks = False)
    Return GetItemByModelID($aModelID, 8, 11, $bPartialStacks)
EndFunc ;==>GetItemInChest

Func GetItemInInventoryByType($aType, $bPartialStacks = False)
    Return GetItemByType($aType, 1, 4, $bPartialStacks)
EndFunc ;==>GetItemInInventoryByType

Func GetItemInChestByType($aType, $bPartialStacks = False)
    Return GetItemByType($aType, 8, 11, $bPartialStacks)
EndFunc ;==>GetItemInChestByType

;~ Returns the first Item, with a matching ModStruct
Func GetItemByModStruct($iBagIndex = 1, $sModStruct = "")
    If $sModStruct = "" Then Return 0
    Local $pItem, $pBag = Item_GetBagPtr($iBagIndex)

    For $slot = 1 To GetBagSlots($pBag)
        $pItem = GetItemPtrBySlot($pBag, $slot)
        If $pItem = 0 Then ContinueLoop
        If StringInStr(GetModStruct($pItem), $sModStruct) > 0 Then Return $pItem
    Next
    Return 0
EndFunc ;==>GetItemByModStruct

;~ Counts the Quantity or Slots of all Items contained in $aModelID in selected bags.
Func CountItemByModelID($aModelID, $iFirstBag, $iLastBag, $bCountSlots = False, $bEquipmentPack = False, $bMaterialStorage = False)
    
    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf

    Local $iSize = UBound($aModelID)
    Local $aCount[$iSize]

    Local $aItemPtr = GetBagItemArray($iFirstBag, $iLastBag, $bEquipmentPack, $bMaterialStorage)
    If @error Then Return SetError(1, 0, ($iSize = 1) ? $aCount[0] : $aCount)


    Local $pItem, $iModelID

    For $i = 0 To UBound($aItemPtr) - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        $iModelID = GetItemModelID($tItemStruct)

        For $j = 0 To $iSize - 1
            If $iModelID <> $aModelID[$j] Then ContinueLoop

            If $bCountSlots Then
                $aCount[$j] += 1
            Else
                $aCount[$j] += GetItemQuantity($tItemStruct)
            EndIf
        Next
    Next
 
    Return ($iSize = 1) ? $aCount[0] : $aCount
EndFunc ;==>CountItemByModelID

;~ Counts the Quantity or Slots of all Items contained in $aType in selected bags.
Func CountItemByType($aType, $iFirstBag, $iLastBag, $bCountSlots = False, $bEquipmentPack = False, $bMaterialStorage = False)
    
    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aType) Then
        Local $aTmp[1] = [$aType]
        $aType = $aTmp
    EndIf

    Local $iSize = UBound($aType)
    Local $aCount[$iSize]

    Local $aItemPtr = GetBagItemArray($iFirstBag, $iLastBag, $bEquipmentPack, $bMaterialStorage)
    If @error Then Return SetError(1, 0, ($iSize = 1) ? $aCount[0] : $aCount)


    Local $pItem, $iType

    For $i = 0 To UBound($aItemPtr) - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        $iType = GetItemType($tItemStruct)

        For $j = 0 To $iSize - 1
            If $iType <> $aType[$j] Then ContinueLoop

            If $bCountSlots Then
                $aCount[$j] += 1
            Else
                $aCount[$j] += GetItemQuantity($tItemStruct)
            EndIf
        Next
    Next
 
    Return ($iSize = 1) ? $aCount[0] : $aCount
EndFunc ;==>CountItemByType

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
Func UseItemByModelID($aModelID)
    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf

    Local $pItem = GetItemInInventory($aModelID)

    For $i = 0 To UBound($aModelID) - 1
        If $pItem[$i] = 0 Then ContinueLoop
        Item_UseItem($pItem[$i])
    Next

    Other_PingSleep(100)
EndFunc ;==>UseItemByModelID

;~ Drops all Items to the ground.
Func DropAll()
    If Not GetIsExplorable() Then Return

    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        Item_DropItem($pItem)
        Other_PingSleep(100)
    Next
EndFunc ;==>DropAll

;~ Drops all Items to the ground, by Type.
Func DropItemsByType($aType, $bFullStack = False)
    If Not GetIsExplorable() Then Return

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aType) Then
        Local $aTmp[1] = [$aType]
        $aType = $aTmp
    EndIf
    Local $iSize = UBound($aType)

    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iType

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        If $bFullStack And GetItemQuantity($tItemStruct) < 250 Then ContinueLoop
        
        $iType = GetItemType($tItemStruct)

        For $j = 0 To $iSize - 1
            If $aType[$j] <> $iType Then ContinueLoop

            Item_DropItem($pItem)
            Other_PingSleep(100)
            ExitLoop
        Next        
    Next
EndFunc ;==>DropItemsByType

;~ Drops all Items to the ground, by ModelID
Func DropItemsByModelID($aModelID, $bFullStack = False)
    If Not GetIsExplorable() Then Return

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If Not IsArray($aModelID) Then
        Local $aTmp[1] = [$aModelID]
        $aModelID = $aTmp
    EndIf
    Local $iSize = UBound($aModelID)

    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iModelID

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        If $bFullStack And GetItemQuantity($tItemStruct) < 250 Then ContinueLoop
        
        $iModelID = GetItemModelID($tItemStruct)

        For $j = 0 To $iSize - 1
            If $aModelID[$j] <> $iModelID Then ContinueLoop

            Item_DropItem($pItem)
            Other_PingSleep(100)
            ExitLoop
        Next        
    Next
EndFunc ;==>DropItemsByModelID

;Description: Destroys an Item
Func DestroyItem($pItem)
    Item_DestroyItem($pItem)
    Other_PingSleep(100)
EndFunc ;==>DestroyItem

Func PickUpLootEx($iMaxDist = 2500)
    Local $lAgentPtr, $lAgentID, $pItem, $lOwner
    Local $lAgentPtrArray = GetAgentPtrArray(1, 0x400)

    $iMaxDist = $iMaxDist * $iMaxDist

    For $i = 1 To $lAgentPtrArray[0]
        $lAgentPtr = $lAgentPtrArray[$i]
        $pItem = GetItemPtrByAgentPtr($lAgentPtr)
        If $pItem = 0 Then ContinueLoop

        $lAgentID = ID($lAgentPtr)
        $lOwner = Memory_Read($lAgentPtr + 0xC4, 'long')
        If $lOwner <> 0 And $lOwner <> Agent_GetMyID() Then ContinueLoop ; assigned to another player
        
        If CanPickUpEx($pItem) And GetPseudoDistance($lAgentPtr) < $iMaxDist Then
            If GetDistanceToXY(X($lAgentPtr), Y($lAgentPtr)) > 250 Then MoveTo(X($lAgentPtr), Y($lAgentPtr))

            $hDeadlock = TimerInit()
            Do
                Item_PickUpItem($lAgentID)
                Other_PingSleep(500)
            Until Agent_GetAgentPtr($lAgentID) <> $lAgentPtr Or GetIsDead(-2) Or TimerDiff($hDeadlock) > 2000
        EndIf
    Next
EndFunc ;==>PickupLootEx

;~ Description: Returns Itemptr by agentid.
Func GetItemPtrByAgentID($iAgentID)
    $iAgentID = Agent_GetAgentPtr($iAgentID)
    If $iAgentID = 0 Then Return 0
    Return Item_GetItemPtr(Memory_Read($iAgentID + 0xC8, 'dword'))
EndFunc ;==>GetItemPtrByAgentID

Func GetItemPtrByAgentPtr($pAgent)
    If Not IsPtr($pAgent) Then Return 0
    Return Item_GetItemPtr(Memory_Read($pAgent + 0xC8, 'dword'))
EndFunc ;==>GetItemPtrByAgentPtr

Func MoveItem($pItem, $pBag, $iSlot)
    Return Core_SendPacket(0x10, $GC_I_HEADER_ITEM_MOVE, Item_ItemID($pItem), GetBagID($pBag), $iSlot)
EndFunc ;==>MoveItem

;~ Description: Moves an Item and can split up a Stack
Func MoveItemEx($pItemSource, $iBag, $iSlot, $iAmount = 0)
    Local $pItem = Item_GetItemPtr($pItemSource)
    If $pItem = 0 Then Return 0

    Local $iQuantity = GetItemQuantity($pItem)
    If $iAmount = 0 Or $iAmount > $iQuantity Then $iAmount = $iQuantity

    If $iAmount >= $iQuantity Then
        Core_SendPacket(0x10, $GC_I_HEADER_ITEM_MOVE, Item_ItemID($pItem), GetBagID($iBag), $iSlot - 1)
    Else
        Core_SendPacket(0x14, $GC_I_HEADER_ITEM_SPLIT_STACK, Item_ItemID($pItem), $iAmount, GetBagID($iBag), $iSlot - 1)
    EndIf
    Return 1
EndFunc ;==>MoveItemEx

Func MoveItemToStorage($pItemSource, $bStack = False, $pItemDest = 0)

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)
    Local Static $tItemStructDest = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    If $pItemSource = $pItemDest Then Return False

    Local $aFreeSlots = GetFreeSlotsStorage()
    Local $iFreeSlots = UBound($aFreeSlots)
    If Not $bStack And $iFreeSlots = 0 Then Return False

    If GetItemStruct($tItemStruct, $pItemSource) = False Then Return False

    Local $iModelID = GetItemModelID($tItemStruct)
    Local $iQuantitySource = GetItemQuantity($tItemStruct)

    If $bStack Then
        If $pItemDest = 0 Then $pItemDest = GetItemInChest($iModelID, True)

        If $pItemDest <> 0 Then
            If GetItemStruct($tItemStructDest, $pItemDest) = False Then Return False

            Local $iQuantityDest = GetItemQuantity($tItemStructDest)
            Local $iQuantity = $iQuantitySource + $iQuantityDest

            Local $pBagDest = GetItemBagPtr($tItemStructDest)
            Local $iSlotDest = GetItemSlot($tItemStructDest)

            If $iQuantity <= 250 Then                
                MoveItem($pItemSource, $pBagDest, $iSlotDest)
                ;~ wait for move here (source=0)
                Return True
            Else
                $iQuantity = 250 - $iQuantityDest
                MoveItemEx($pItemSource, $pBagDest, $iSlotDest, $iQuantity) ; ZERO BASED HERE
                ;~ wait for move here (dest=250!?!)
            EndIf
        EndIf
    EndIf

    If $iFreeSlots = 0 Then Return False

    MoveItem($pItemSource, $aFreeSlots[0][0], $aFreeSlots[0][1])
    ;~ wait for move here (source=0 OR dest<>0)
    Return True
EndFunc ;==>MoveItemToStorage

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
        For $slot = 1 To GetBagSlots($pBag)
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
        For $slot = 1 To GetBagSlots($pBag)
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
        For $slot = 1 To GetBagSlots($pBag)
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
        For $slot = 1 To GetBagSlots($pBag)
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
    If Not GetIsOutpost() Then Return False

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
    If UBound($aFreeSlots) = 0 Then Return False

    Local $pItemDest = GetItemInChest($aModelID, True)
    Local $iFreeSlotsMax = UBound($aFreeSlots), $iCountSlots = 0
    Local $pItem, $pBag, $iModelID, $iQuantity, $iQuantityMerge, $iModelIDFound
    Local $iBagSource, $iSlotSource, $aBagSlotLast[2] = [0, 0]
    Local $iAmountCount = 0

    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetBagSlots($pBag)
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
    If Not GetIsOutpost() Then Return False

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
    If UBound($aFreeSlots) = 0 Then Return False

    Local $pItemDest = GetItemInInventory($aModelID, True)
    Local $iFreeSlotsMax = UBound($aFreeSlots), $iCountSlots = 0
    Local $pItem, $pBag, $iModelID, $iQuantity, $iQuantityMerge, $iModelIDFound
    Local $iBagSource, $iSlotSource, $aBagSlotLast[2] = [0, 0]
    Local $iAmountCount = 0

    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetBagSlots($pBag)
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
    If Map_GetInstanceInfo("Type") <> $GC_I_MAP_TYPE_OUTPOST Then Return False
    Local $pItem, $pBag
    For $bag = 8 To 11
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetBagSlots($pBag)
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
        For $slot = 1 to GetBagSlots($pBag)
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
        For $slot = 1 to GetBagSlots($pBag)
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
        For $slot = 1 to GetBagSlots($pBag)
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
        For $slot = 1 to GetBagSlots($pBag)
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

    While $iQuantity > 10
        Merchant_BuyItem($GC_I_MODELID_SALVAGE_KIT, 10)
        Other_PingSleep(1000)

        $iQuantity -= 10
    WEnd

    If $iQuantity > 0 Then
        Merchant_BuyItem($GC_I_MODELID_SALVAGE_KIT, $iQuantity)
        Other_PingSleep(1000)
    EndIf
EndFunc ;==>BuySalvageKit

;~ Buys Expert Salvage Kit
Func BuyExpertSalvageKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return

    While $iQuantity > 10
        Merchant_BuyItem($GC_I_MODELID_EXPERT_SALVAGE_KIT, 10)
        Other_PingSleep(1000)

        $iQuantity -= 10
    WEnd

    If $iQuantity > 0 Then
        Merchant_BuyItem($GC_I_MODELID_EXPERT_SALVAGE_KIT, $iQuantity)
        Other_PingSleep(1000)
    EndIf
EndFunc ;==>BuySalvageKit

;~ Buys Superior Salvage Kit
Func BuySuperiorSalvageKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return

    While $iQuantity > 10
        Merchant_BuyItem($GC_I_MODELID_SUPERIOR_SALVAGE_KIT, 10)
        Other_PingSleep(1000)

        $iQuantity -= 10
    WEnd

    If $iQuantity > 0 Then
        Merchant_BuyItem($GC_I_MODELID_SUPERIOR_SALVAGE_KIT, $iQuantity)
        Other_PingSleep(1000)
    EndIf
EndFunc ;==>BuySalvageKit

;~ Buys an ID kit.
Func BuyIDKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return

    While $iQuantity > 10
        Merchant_BuyItem($GC_I_MODELID_IDENTIFICATION_KIT, 10)
        Other_PingSleep(1000)

        $iQuantity -= 10
    WEnd

    If $iQuantity > 0 Then
        Merchant_BuyItem($GC_I_MODELID_IDENTIFICATION_KIT, $iQuantity)
        Other_PingSleep(1000)
    EndIf
EndFunc ;==>BuyIDKit

;~ Buys Superior ID kit.
Func BuySuperiorIDKit($iQuantity = 1)
    If $iQuantity <= 0 Then Return

    While $iQuantity > 10
        Merchant_BuyItem($GC_I_MODELID_SUPERIOR_IDENTIFICATION_KIT, 10)
        Other_PingSleep(1000)

        $iQuantity -= 10
    WEnd

    If $iQuantity > 0 Then
        Merchant_BuyItem($GC_I_MODELID_SUPERIOR_IDENTIFICATION_KIT, $iQuantity)
        Other_PingSleep(1000)
    EndIf
EndFunc ;==>BuySuperiorIDKit
#EndRegion Buy and Sell

#EndRegion Items

#Region Bag
Func GetBagPtr($iBagNumber, $pInventory = 0)
    If IsPtr($iBagNumber) Then Return $iBagNumber

    If $iBagNumber < $GC_I_INVENTORY_BACKPACK _
    Or $iBagNumber > $GC_I_INVENTORY_EQUIPPED_ITEMS Then Return SetError(1, 0, 0)

    If Not IsPtr($pInventory) Then $pInventory = Item_GetInventoryPtr()
    
    Return Memory_Read($pInventory + (0x4 * $iBagNumber), 'ptr')
EndFunc ;==>GetBagPtr

Func GetBagStruct(ByRef $tBagStruct, $pBag, $pInventory = 0)
    ;~ If Not IsDllStruct($tBagStruct) Then Return SetError(4, 0, False) ; not sure if it is useful to keep this

    $pBag = GetBagPtr($pBag, $pInventory)

    If @error Then Return SetError(1, 0, False) ; GetBagPtr returned @error

    If Not IsPtr($pBag) Or $pBag = 0 Then Return SetError(2, 0, False)


    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pBag, _
                    "struct*", $tBagStruct, _
                    "ulong_ptr", $g_iBagStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(3, 0, False)
    
    Return True
EndFunc ;==>GetBagStruct

Func GetBagType(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, 'BagType')
    Else
        Return Memory_Read(GetBagPtr($pBag), 'dword')
    EndIf
EndFunc ;==>GetBagType

Func GetBagIndex(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, 'Index')
    Else
        Return Memory_Read(GetBagPtr($pBag) + 0x04, 'dword')
    EndIf
EndFunc ;==>GetBagIndex

Func GetBagID(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, 'BagID')
    Else
        Return Memory_Read(GetBagPtr($pBag) + 0x08, 'dword')
    EndIf
EndFunc ;==>GetBagID

Func GetBagContainerItem(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, "ContainerItem")
    Else
        Return Memory_Read(Item_GetBagPtr($pBag) + 0x0C, "dword")
    EndIf
EndFunc ;==>GetBagContainerItem

Func GetBagItemCount(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, "ItemCount")
    Else
        Return Memory_Read(Item_GetBagPtr($pBag) + 0x10, "dword")
    EndIf
EndFunc ;==>GetBagItemCount

Func GetBagArrayPtr(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, "BagArray")
    Else
        Return Memory_Read(Item_GetBagPtr($pBag) + 0x14, "ptr")
    EndIf
EndFunc ;==>GetBagArrayPtr

Func GetBagItemArrayPtr(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, "ItemArray")
    Else
        Return Memory_Read(Item_GetBagPtr($pBag) + 0x18, "ptr")
    EndIf
EndFunc ;==>GetBagItemArrayPtr

;~ returns the complete ItemPtr Array of the specified bags
Func GetBagItemArray($iFirstBag, $iLastBag, $bEquipmentPack = False, $bMaterialStorage = False)
    Local Static $tBagStruct = DllStructCreate($BAG_STRUCT_TEMPLATE)

    If $iLastBag < $iFirstBag Then Return SetError(1, 0, 0)

    Local $pInventory = Item_GetInventoryPtr()

    Local $iCountBags = $iLastBag - $iFirstBag + 1
    Local $iSlotsMax = $iCountBags * 25

    Local $aItemPtr[$iSlotsMax][3] ; $bag, $slot, $ItemPtr
    
    Local $iCount = 0

    For $bag = $iFirstBag To $iLastBag

        If $bag = $GC_I_INVENTORY_EQUIPMENT_PACK And Not $bEquipmentPack Then ContinueLoop
        If $bag = $GC_I_INVENTORY_MATERIAL_STORAGE And Not $bMaterialStorage Then ContinueLoop
        If $bag = $GC_I_INVENTORY_UNCLAIMED_ITEMS Then ContinueLoop

        If GetBagStruct($tBagStruct, $bag, $pInventory) = False Then ContinueLoop

        Local $iSlots = GetBagSlots($tBagStruct)
        Local $pItemArray = GetBagItemArrayPtr($tBagStruct)
        Local $tBuffer = DllStructCreate("ptr[" & $iSlots & "]")

        Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", "handle", $g_h_GWProcess, _
                        "ptr", $pItemArray, _
                        "struct*", $tBuffer, _
                        "ulong_ptr", DllStructGetSize($tBuffer), _
                        "ulong_ptr*", 0)
        If @error Or Not $aCall[0] Then ContinueLoop


        For $slot = 1 To $iSlots

            $aItemPtr[$iCount][0] = $bag
            $aItemPtr[$iCount][1] = $slot
            $aItemPtr[$iCount][2] = DllStructGetData($tBuffer, 1, $slot)

            $iCount += 1
        Next

    Next

    If $iCount = 0 Then Return 0

    Redim $aItemPtr[$iCount][3]
    Return $aItemPtr
EndFunc ;==>GetBagItemArray

;~ returns amount of slots the bag has
Func GetBagSlots(ByRef $pBag)
    If IsDllStruct($pBag) Then
        Return DllStructGetData($pBag, "Slots")
    Else
        Return Memory_Read(Item_GetBagPtr($pBag) + 0x20, "dword")
    EndIf
EndFunc ;==>GetBagSlots

;~ counts free slots in specified bags
Func CountFreeSlots($iFirstBag, $iLastBag)
    Local Static $tBagStruct = DllStructCreate($BAG_STRUCT_TEMPLATE)

    If $iLastBag < $iFirstBag Then Return SetError(1, 0, 0)

    Local $pInventory = Item_GetInventoryPtr()
    Local $iCount = 0

    For $bag = $iFirstBag To $iLastBag

        If GetBagStruct($tBagStruct, $bag, $pInventory) = False Then ContinueLoop

        $iCount += DllStructGetData($tBagStruct, 'Slots') - DllStructGetData($tBagStruct, 'ItemCount')

    Next

    Return $iCount
EndFunc ;==>CountFreeSlots

;~ returns the number of free slots in inventory
Func CountFreeSlotsInventory()
    Return CountFreeSlots($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
EndFunc ;==>CountFreeSlotsInventory

;~ returns the number of free slots in storage
Func CountFreeSlotsStorage()
    Return CountFreeSlots($GC_I_INVENTORY_STORAGE1, $GC_I_INVENTORY_STORAGE4)
EndFunc ;==>CountFreeSlotsStorage


Func GetFreeSlots($iFirstBag, $iLastBag)
    Local Static $tBagStruct = DllStructCreate($BAG_STRUCT_TEMPLATE)

    If $iLastBag < $iFirstBag Then Return SetError(1, 0, 0)

    While TimerDiff($g_hTimerMoveItem) < $g_iTimeoutMoveItem
        Sleep(100)
    WEnd
    
    Local $pInventory = Item_GetInventoryPtr()
    
    Local $iCountBags = $iLastBag - $iFirstBag + 1
    Local $iFreeSlotsMax = $iCountBags * 25

    Local $aFreeSlots[$iFreeSlotsMax][2] 

    Local $pItem, $iCount = 0

    For $bag = $iFirstBag To $iLastBag

        If GetBagStruct($tBagStruct, $bag, $pInventory) = False Then ContinueLoop

        Local $iSlots = GetBagSlots($tBagStruct)
        Local $pItemArray = GetBagItemArrayPtr($tBagStruct)
        Local $tBuffer = DllStructCreate("ptr[" & $iSlots & "]")

        Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", "handle", $g_h_GWProcess, _
                        "ptr", $pItemArray, _
                        "struct*", $tBuffer, _
                        "ulong_ptr", DllStructGetSize($tBuffer), _
                        "ulong_ptr*", 0)
        If @error Or Not $aCall[0] Then ContinueLoop

        For $slot = 1 To $iSlots
            
            $pItem = DllStructGetData($tBuffer, 1, $slot)

            If $pItem = 0 Then
                $aFreeSlots[$iCount][0] = $bag
                $aFreeSlots[$iCount][1] = $slot
                $iCount += 1
            EndIf

        Next

    Next
    
    Redim $aFreeSlots[$iCount][2]

    Return $aFreeSlots
EndFunc ;==>GetFreeSlots

Func GetFreeSlotsInventory()
    Return GetFreeSlots($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
EndFunc ;==>GetFreeSlotsInventory

Func GetFreeSlotsStorage()
    Return GetFreeSlots($GC_I_INVENTORY_STORAGE1, $GC_I_INVENTORY_STORAGE4)
EndFunc ;==>GetFreeSlotsStorage
#EndRegion Bag

#Region Inventory
Func GetInventoryStruct(ByRef $tInventorySruct, $pInventory = 0)

    If Not IsPtr($pInventory) Then $pInventory = Item_GetInventoryPtr()

    If Not IsPtr($pInventory) Or $pInventory = 0 Then Return SetError(1, 0, False)

    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pInventory, _
                    "struct*", $tInventorySruct, _
                    "ulong_ptr", $g_iInventoryStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, False)

    Return True
EndFunc ;==>GetInventoryStruct

;~ Description: Have always Platin in inventory, but not to much
Func MinMaxGold()
    If Not GetIsOutpost() Then Return

    Local $iGoldCharacter = GetGoldCharacter()
    
    If $iGoldCharacter < 30000 Then
        Out("Withdrawing Gold.")
        Item_WithdrawGold(30000)
        Other_PingSleep(100)
    ElseIf $iGoldCharacter > 70000 Then
        Out("Depositing Gold.")
        Item_DepositGold(25000)
        Other_PingSleep(100)
    EndIf
EndFunc ;==>MinMaxGold

;~ Description: Returns amount of gold being carried.
;~ @extended = gold in storage
Func GetGoldCharacter()
    Local $iGoldCharacter, $iGoldStorage

    If Not GetGoldInfo($iGoldCharacter, $iGoldStorage) Then Return SetError(@error, 0, 0)

    Return SetExtended($iGoldStorage, $iGoldCharacter)
EndFunc ;==>GetGoldCharacter

;~ Description: Returns amount of gold in storage.
;~ @extended = gold being carried
Func GetGoldStorage()
    Local $iGoldCharacter, $iGoldStorage

    If Not GetGoldInfo($iGoldCharacter, $iGoldStorage) Then Return SetError(@error, 0, 0)

    Return SetExtended($iGoldCharacter, $iGoldStorage)
EndFunc ;==>GetGoldStorage

Func GetGoldInfo(ByRef $iGoldCharacter, ByRef $iGoldStorage)
    Local Static $tGoldInfo = DllStructCreate("dword GoldCharacter; dword GoldStorage")
    Local Static $iStructSize = DllStructGetSize($tGoldInfo)

    Local $pInventory = Item_GetInventoryPtr()
    If Not IsPtr($pInventory) Or $pInventory = 0 Then Return SetError(1, 0, False)

    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pInventory + 0x90, _
                    "struct*", $tGoldInfo, _
                    "ulong_ptr", $iStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(2, 0, False)

    $iGoldCharacter = DllStructGetData($tGoldInfo, "GoldCharacter")
    $iGoldStorage   = DllStructGetData($tGoldInfo, "GoldStorage")

    Return True
EndFunc ;==>GetGoldInfo
#EndRegion Inventory

#Region Custom
;~ Return the Name of a Common or Rare Material by ModelID
Func GetMaterialName($aModelID)
    Switch $aModelID
        Case $GC_I_MODELID_BONES
            Return "Bones"
        Case $GC_I_MODELID_CLOTHS
            Return "Cloth"
        Case $GC_I_MODELID_DUST
            Return "Dust"
        Case $GC_I_MODELID_FEATHERS
            Return "Feathers"
        Case $GC_I_MODELID_PLANT_FIBRES
            Return "Fibers"
        Case $GC_I_MODELID_TANNED_HIDE
            Return "Tanned Hide Squares"
        Case $GC_I_MODELID_WOOD
            Return "Wood Planks"
        Case $GC_I_MODELID_IRON
            Return "Iron"
        Case $GC_I_MODELID_SCALES
            Return "Scales"
        Case $GC_I_MODELID_CHITIN
            Return "Chitin"
        Case $GC_I_MODELID_GRANITE
            Return "Granite"
        Case $GC_I_MODELID_CHARCOAL
            Return "Charcoal"
        Case $GC_I_MODELID_MONSTROUS_CLAW
            Return "Monstrous Claw"
        Case $GC_I_MODELID_LINEN
            Return "Linen"
        Case $GC_I_MODELID_DAMASK
            Return "Damask"
        Case $GC_I_MODELID_SILK
            Return "Silk"
        Case $GC_I_MODELID_GLOB_OF_ECTOPLASM
            Return "Ecto"
        Case $GC_I_MODELID_MONSTROUS_EYE
            Return "Monstrous Eye"
        Case $GC_I_MODELID_MONSTROUS_FANG
            Return "Monstrous Fang"
        Case $GC_I_MODELID_DIAMOND
            Return "Diamond"
        Case $GC_I_MODELID_ONYX
            Return "Onyx"
        Case $GC_I_MODELID_RUBY
            Return "Ruby"
        Case $GC_I_MODELID_SAPPHIRE
            Return "Sapphire"
        Case $GC_I_MODELID_GLASS_VIAL
            Return "Glass Vial"
        Case $GC_I_MODELID_FUR_SQUARE
            Return "Fur Square"
        Case $GC_I_MODELID_LEATHER_SQUARE
            Return "Leather Square"
        Case $GC_I_MODELID_ELONIAN_LEATHER_SQUARE
            Return "Elonian Leather Square"
        Case $GC_I_MODELID_VIAL_OF_INK
            Return "Vial of Ink"
        Case $GC_I_MODELID_OBSIDIAN_SHARD
            Return "Obsidian Shard"
        Case $GC_I_MODELID_STEEL_INGOT
            Return "Steel Ingot"
        Case $GC_I_MODELID_DELDRIMOR_STEEL_INGOT
            Return "Deldrimor Steel Ingot"
        Case $GC_I_MODELID_ROLL_OF_PARCHMENT
            Return "Roll of Parchment"
        Case $GC_I_MODELID_ROLL_OF_VELLUM
            Return "Roll of Vellum"
        Case $GC_I_MODELID_SPIRITWOOD_PLANK
            Return "Spiritwood Plank"
        Case $GC_I_MODELID_AMBER_CHUNK
            Return "Amber Chunk"
        Case $GC_I_MODELID_JADEIT_SHARD
            Return "Jadeite Shard"  
        Case Else
            Return "Not a Material!"
    EndSwitch
EndFunc ;==>GetMaterialName

Func IsBlackDye($aModelID, $aExtraID)
    If $aModelID = $GC_I_MODELID_DYE And $aExtraID = $GC_I_EXTRAID_DYE_BLACK Then Return True
    Return False
EndFunc ;==>IsBlackDye

; Return the amount of Alcohol in Inventory
Func GetAlcQuantityInventory()
    Local $pItem, $pBag, $iQuantity = 0
    For $bag = 1 To 4
        $pBag = Item_GetBagPtr($bag)
        If $pBag = 0 Then ContinueLoop
        For $slot = 1 To GetBagSlots($pBag)
            $pItem = GetItemPtrBySlot($pBag, $slot)
            If $pItem = 0 Then ContinueLoop
            If CheckIsAlc(GetItemModelID($pItem)) Then $iQuantity += GetItemQuantity($pItem)
        Next
    Next
    Return $iQuantity
EndFunc ;==>GetAlcQuantityInventory

;~ Uses first Alcohol found in Inventory, Returns 0 if no Alc available
Func UseAlcohol($bOnePoint = False, $bThreePoint = False)

    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $bAnyAlcohol = ($bOnePoint = $bThreePoint)
    Local $pItem, $iModelID

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        $iModelID = GetItemModelID($pItem)

        If $bAnyAlcohol Then
            If CheckIsOnePointAlc($iModelID) Or CheckIsThreePointAlc($iModelID) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        ElseIf $bOnePoint Then
            If CheckIsOnePointAlc($iModelID) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        Else
            If CheckIsThreePointAlc($iModelID) Then
                Item_UseItem($pItem)
                Return 1
            EndIf
        EndIf
    Next

    Return 0
EndFunc ;==>UseAlcohol

;~ Checks if Item is Alcohol.
Func CheckIsAlc($iModelID)
    For $i = 1 To UBound($GC_AI_ONEPOINT_ALCOHOL) - 1
        If $GC_AI_ONEPOINT_ALCOHOL[$i] = $iModelID Then Return True
    Next

    For $i = 1 To UBound($GC_AI_THREEPOINT_ALCOHOL) - 1
        If $GC_AI_THREEPOINT_ALCOHOL[$i] = $iModelID Then Return True
    Next

    Return False
EndFunc ;==>CheckIsAlc

;~ Checks if Item is One Point Alcohol.
Func CheckIsOnePointAlc($iModelID)
    For $i = 1 To UBound($GC_AI_ONEPOINT_ALCOHOL) - 1
        If $GC_AI_ONEPOINT_ALCOHOL[$i] = $iModelID Then Return True
    Next

    Return False
EndFunc ;==>CheckIsOnePointAlc

;~ Checks if Item is Three Point Alcohol.
Func CheckIsThreePointAlc($iModelID)
    For $i = 1 To UBound($GC_AI_ONEPOINT_ALCOHOL) - 1
        If $GC_AI_ONEPOINT_ALCOHOL[$i] = $iModelID Then Return True
    Next

    Return False
EndFunc ;==>CheckIsThreePointAlc

;~ Description: Checks if ModelID belongs to a City Speed Item
Func CheckIsCitySpeed($iModelID)
    Local Static $aSweets[] = [ _
        $GC_I_MODELID_CREME_BRULEE, _
        $GC_I_MODELID_RED_BEAN_CAKE, _
        $GC_I_MODELID_MANDRAGOR_ROOT_CAKE, _
        $GC_I_MODELID_FRUITCAKE, _
        $GC_I_MODELID_SUGARY_BLUE_DRINK, _
        $GC_I_MODELID_CHOCOLATE_BUNNY, _
        $GC_I_MODELID_MINI_TREATS_OF_PURITY, _
        $GC_I_MODELID_JAR_OF_HONEY, _
        $GC_I_MODELID_KRYTAN_LOKUM _
    ]

    For $i = 0 To UBound($aSweets) - 1
        If $aSweets[$i] = $iModelID Then Return True
    Next    
    
    Return False
EndFunc ;==>CheckIsCitySpeed

; Pops a City Speedboost
Func MaintainCitySpeed()
    If GetIsEnchanted(-2) Then Return 1
    
    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_STORAGE4)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iModelID

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        $iModelID = GetItemModelID($pItem)

        If CheckIsCitySpeed($iModelID) Then
            Item_UseItem($pItem)
            Return 1
        EndIf
    Next

    Return 0
EndFunc ;==>MaintainCitySpeed

; Sells all the unneeded Mats to Merchant
; Make sure *you are standing at a Merchant!!!*
Func SellJunk()
    Local Static $aJunk[] = [ _
        $GC_I_MODELID_SHING_JEA_KEY, _
        $GC_I_MODELID_ISTANI_KEY, _
        $GC_I_MODELID_KRYTAN_KEY, _
        $GC_I_MODELID_OBSIDIAN_KEY, _
        $GC_I_MODELID_WOOD, _
        $GC_I_MODELID_CHITIN, _
        $GC_I_MODELID_CLOTHS, _
        $GC_I_MODELID_TANNED_HIDE, _
        $GC_I_MODELID_SCALES, _
        $GC_I_MODELID_GRANITE _
    ]
    Local Static $iSizeJunkArray = UBound($aJunk)

    Local Static $tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)

    Local $aItemPtr = GetBagItemArray($GC_I_INVENTORY_BACKPACK, $GC_I_INVENTORY_BAG2)
    If @error Then Return SetError(1, 0, 0)

    Local $iItemCount = UBound($aItemPtr)

    Local $pItem, $iModelID, $iQuantity

    For $i = 0 To $iItemCount - 1
        $pItem = $aItemPtr[$i][2]

        If $pItem = 0 Then ContinueLoop

        If GetItemStruct($tItemStruct, $pItem) = False Then ContinueLoop

        $iModelID = GetItemModelID($tItemStruct)

        For $j = 0 To $iSizeJunkArray - 1
            If $aJunk[$j] <> $iModelID Then ContinueLoop
            
            $iQuantity = GetItemQuantity($tItemStruct)  

            Merchant_SellItem($pItem, $iQuantity)
            Other_PingSleep(500)
            ExitLoop
        Next
    Next
EndFunc ;==>SellJunk

Func IsEventItem($iModelID)
    ; *******************************************************************************************
    ; Pick up EVENT ITEMS, put semicolon(;) infront of the line, if you DON'T want do pick it up
    ; ******************************************************************************************* 
    
    ; Canthan New Year
    ;~ If $iModelID = $GC_I_MODELID_LUNAR_TOKEN Then Return True
    ;~ If $iModelID = $GC_I_MODELID_LUNAR_FORTUNE_HORSE Then Return True
    
    ; Lucky Treats Week
    ;~ If $iModelID = $GC_I_MODELID_FOUR_LEAF_CLOVER Then Return True
    ;~ If $iModelID = $GC_I_MODELID_SHAMROCK_ALE Then Return True
    
    ; Sweet Treats Week
    ;~ If $iModelID = $GC_I_MODELID_GOLDEN_EGG Then Return True
    ;~ If $iModelID = $GC_I_MODELID_CHOCOLATE_BUNNY Then Return True
    
    ;~ === Anniversary Celebration ===
    ;~ If $iModelID = $GC_I_MODELID_CUPCAKE Then Return True
    ;~ If $iModelID = $GC_I_MODELID_HONEYCOMB Then Return True
    ;~ If $iModelID = $GC_I_MODELID_SUGARY_BLUE_DRINK Then Return True
    ;~ ;~ Alcohol
    ;~ If $iModelID = $GC_I_MODELID_HARD_APPLE_CIDER Then Return True
    ;~ If $iModelID = $GC_I_MODELID_HUNTERS_ALE Then Return True
    ;~ If $iModelID = $GC_I_MODELID_KRYTAN_BRANDY Then Return True
    ;~ ;~ Party Points
    ;~ If $iModelID = $GC_I_MODELID_CHAMPAGNE_POPPER Then Return True
    ;~ If $iModelID = $GC_I_MODELID_BOTTLE_ROCKET Then Return True
    ;~ If $iModelID = $GC_I_MODELID_SPARKLER Then Return True
    ;~ ;~ 50 Point Boss Items
    ;~ If $iModelID = $GC_I_MODELID_DELICIOUS_CAKE Then Return True
    ;~ If $iModelID = $GC_I_MODELID_BATTLE_ISLE_ICED_TEA Then Return True
    ;~ If $iModelID = $GC_I_MODELID_PARTY_BEACON Then Return True
    
    ; Dragon Festival
    If $iModelID = $GC_I_MODELID_VICTORY_TOKEN Then Return True ; also anniversary
    
    ; Wintersday in July
    ; -->see Wintersday
    
    ; Wayfarer's Reverie
    ; If $iModelID = $GC_I_MODELID_WAYFARER_MARK Then Return True ; this ID is WRONG in constants.au3
    
    ; Pirate Week
    ; If $iModelID = $GC_I_MODELID_BOTTLE_OF_GROG Then Return True
    
    ; Halloween
    ;~ If $iModelID = $GC_I_MODELID_TRICK_OR_TREAT_BAGS Then Return True
    
    ; Special Treats Week
    ;~ If $iModelID = $GC_I_MODELID_PUMPKIN_PIE Then Return True ; + Hard Apple Cider, see above
    
    ; Wintersday
    ;~ If $iModelID = $GC_I_MODELID_CC_SHARDS Then Return True
    ;~ If $iModelID = $GC_I_MODELID_EGGNOG Then Return True
    ;~ If $iModelID = $GC_I_MODELID_SPIKED_EGGNOGG Then Return True
    ;~ If $iModelID = $GC_I_MODELID_FRUITCAKE Then Return True
    ;~ If $iModelID = $GC_I_MODELID_SNOWMAN_SUMMONER Then Return True
        
    ;~ If $iModelID = $GC_I_MODELID_FROSTY_TONIC Then Return True
    ;~ If $iModelID = $GC_I_MODELID_MISCHIEVOUS_TONIC Then Return True
    ;~ If $iModelID = $GC_I_MODELID_YULETIDE_TONIC Then Return True
    
    ;~ If $iModelID = $GC_I_MODELID_WINTERGREEN_CC Then Return True
    ;~ If $iModelID = $GC_I_MODELID_RAINBOW_CC Then Return True
    ;~ If $iModelID = $GC_I_MODELID_PEPPERMINT_CC Then Return True
    
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

    Return False
EndFunc ;==>IsInsignia

Func IsRune($pItem)
    Local $sModstruct = GetModStruct($pItem), $iRarity = GetItemRarity($pItem)

    Switch $iRarity
        Case $GC_I_RARITY_BLUE
            For $i = 0 To UBound($array_rune_minor) - 1
                If $array_rune_minor[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_minor[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_minor[$i][$rune_name])
                    Return $array_rune_minor[$i][$rune_value]
                EndIf
            Next
        Case $GC_I_RARITY_PURPLE
            For $i = 0 To UBound($array_rune_major) - 1
                If $array_rune_major[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_major[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_major[$i][$rune_name])
                    Return $array_rune_major[$i][$rune_value]
                EndIf
            Next
        Case $GC_I_RARITY_GOLD
            For $i = 0 To UBound($array_rune_superior) - 1
                If $array_rune_superior[$i][$rune_value] = 0 Then ContinueLoop
                If StringInStr($sModstruct, $array_rune_superior[$i][$rune_mod_string]) > 0 Then
                    Out($array_rune_superior[$i][$rune_name])
                    Return $array_rune_superior[$i][$rune_value]
                EndIf
            Next
    EndSwitch

    Return False
EndFunc ;==>IsRune
#EndRegion Custom

#Region ModStruct
;~ Description: Returns modstruct of an item.
Func GetModStruct(ByRef $pItem, $pItemArray = 0, $pItemContext = 0)
    If IsString($pItem) Then Return $pItem

    Local $pModStruct = 0, $iModStructSize = 0

    If IsDllStruct($pItem) Then
        $pModStruct = DllStructGetData($pItem, 'ModStruct')
        $iModStructSize = DllStructGetData($pItem, 'ModStructSize')
    Else
        Local $pItemTmp = GetItemPtr($pItem, $pItemArray, $pItemContext)
        If $pItemTmp = 0 Then Return 0

        If GetItemModInfo($pItemTmp, $pModStruct, $iModStructSize) = False Then Return 0
    EndIf

    If $pModStruct = 0 Or $iModStructSize = 0 Then Return 0
    
    Return String(Memory_Read($pModStruct, 'Byte[' & 4 * $iModStructSize & ']'))
EndFunc ;==>GetModStruct

Func GetItemModInfo($pItem, ByRef $pModStruct, ByRef $iModStructSize)
    Local Static $tModInfo = DllStructCreate("ptr ModPtr; dword Size")
    Local Static $iStructSize = DllStructGetSize($tModInfo)

    Local $aCall = DllCall($g_h_Kernel32, "bool", "ReadProcessMemory", _
                    "handle", $g_h_GWProcess, _
                    "ptr", $pItem + 0x10, _
                    "struct*", $tModInfo, _
                    "ulong_ptr", $iStructSize, _
                    "ulong_ptr*", 0)
    If @error Or Not $aCall[0] Then Return SetError(1, 0, False)

    $pModStruct     = DllStructGetData($tModInfo, "ModPtr")
    $iModStructSize = DllStructGetData($tModInfo, "Size")

    Return True
EndFunc ;==>GetItemModInfo

;~ Description: Returns an array of a the requested mod.
Func GetModByIdentifier(ByRef $pItem, $sIdentifier)
   
    Local $sModStruct = GetModStruct($pItem)

    $sModStruct = StringTrimLeft($sModStruct, 2)

    Local $aReturn[2] = [-1, -1]

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
Func CheckModStruct($sModstruct, $sPattern)
    Return StringInStr($sModstruct, $sPattern) > 0
EndFunc ;==>CheckModStruct
#EndRegion ModStruct

#Region Weapons
;~ Description: Returns a weapon or shield's minimum required attribute.
Func GetItemReq(ByRef $pItem)
    Local $aMod = GetModByIdentifier($pItem, '9827')
    Return $aMod[0]
EndFunc ;==>GetItemReq

;~ Description: Returns a weapon or shield's required attribute.
Func GetItemAttribute(ByRef $pItem)
    Local $aMod = GetModByIdentifier($pItem, '9827')
    Return $aMod[1]
EndFunc ;==>GetItemAttribute

;~ Description: Returns the maximum Dmg/Energy/Armor
Func GetItemMaxDmg(ByRef $pItem)
    Local $sModStruct = GetModStruct($pItem)
    Local $iPos = StringInStr($sModStruct, "A8A7") ; Weapon Damage
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "C867") ; Energy (focus)
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "B8A7") ; Armor (shield)
    If $iPos = 0 Then Return -1

    Return Int("0x" & StringMid($sModStruct, $iPos - 2, 2))
EndFunc ;==>GetItemMaxDmg

;~ Description: Returns the minimum Dmg/Energy/Armor
Func GetItemMinDmg(ByRef $pItem)
    Local $sModStruct = GetModStruct($pItem)
    Local $iPos = StringInStr($sModStruct, "A8A7") ; Weapon Damage
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "C867") ; Energy (focus)
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "B8A7") ; Armor (shield)
    If $iPos = 0 Then Return -1

    Return Int("0x" & StringMid($sModStruct, $iPos - 4, 2))
EndFunc ;==>GetItemMinDmg

;~ Description: Returns Dmg/Energy/Armor
Func GetItemDmg(ByRef $pItem)
    Local $sModStruct = GetModStruct($pItem)
    Local $iPos = StringInStr($sModStruct, "A8A7") ; Weapon Damage
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "C867") ; Energy (focus)
    If $iPos = 0 Then $iPos = StringInStr($sModStruct, "B8A7") ; Armor (shield)
    If $iPos = 0 Then Return -1

    Local $aMod[2] = [0, 0]
    $aMod[0] = Int("0x" & StringMid($sModStruct, $iPos - 4, 2))
    $aMod[1] = Int("0x" & StringMid($sModStruct, $iPos - 2, 2))
    Return $aMod
EndFunc ;==>GetItemDmg

Func IsWeaponMaxDmg(ByRef $pItem, $iType = -1)
    If $iType = -1 Then $iType = GetItemType($pItem)

    If Not IsWeaponByType($iType) Then Return False

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False

    Local $aDmg = GetItemDmg($sModStruct)
    If $aDmg = -1 Then Return False

    Local $iReq = GetItemReq($sModStruct)
    If $iReq = -1 Then Return False
    
    Switch $iType
        Case $GC_I_TYPE_AXE
            If $aDmg[0] >= 7 Then Return True
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aAxeMaxStats) Then Return True

        Case $GC_I_TYPE_BOW
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aBowMaxStats) Then Return True

        Case $GC_I_TYPE_OFFHAND
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aOffhandMaxStats) Then Return True

        Case $GC_I_TYPE_HAMMER
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aHammerMaxStats) Then Return True

        Case $GC_I_TYPE_WAND
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aWandMaxStats) Then Return True

        Case $GC_I_TYPE_SHIELD
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aShieldMaxStats) Then Return True

        Case $GC_I_TYPE_STAFF
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aStaffMaxStats) Then Return True

        Case $GC_I_TYPE_SWORD
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aSwordMaxStats) Then Return True

        Case $GC_I_TYPE_DAGGERS
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aDaggerMaxStats) Then Return True

        Case $GC_I_TYPE_SCYTHE
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aScytheMaxStats) Then Return True

        Case $GC_I_TYPE_SPEAR
            If CheckMaxDmg($iReq, $aDmg, $iType, $g_aSpearMaxStats) Then Return True

    EndSwitch

    Return False
EndFunc ;==>IsWeaponMaxDmg

;~ checks if weapon has max damage/armor/energy stats
Func CheckMaxDmg($iReq, $aDmg, $iType, ByRef Const $aMaxStats)
    If $iReq > 9 Then $iReq = 9 ; normalize all req's 9-13, they all got same stats

    For $i = 0 To UBound($aMaxStats) - 1
        If $iReq <> $aMaxStats[$i][$item_req] Then ContinueLoop
        
        If $iType = $GC_I_TYPE_OFFHAND Or $iType = $GC_I_TYPE_SHIELD Then
            If $aDmg[1] >= $aMaxStats[$i][$item_max_dmg] Then Return True
        Else
            If $aDmg[0] >= $aMaxStats[$i][$item_min_dmg] And $aDmg[1] >= $aMaxStats[$i][$item_max_dmg] Then Return True
        EndIf

        Return False ; there can only be one match, so we can safely exit
    Next

    Return False
EndFunc ;==>CheckMaxDmg

;~ Returns True if the Item is of a Weapon Type
Func IsWeapon(ByRef $pItem)
    Switch GetItemType($pItem)
        Case    $GC_I_TYPE_AXE, $GC_I_TYPE_BOW, $GC_I_TYPE_OFFHAND, _
                $GC_I_TYPE_HAMMER, $GC_I_TYPE_WAND, $GC_I_TYPE_SHIELD, _
                $GC_I_TYPE_STAFF, $GC_I_TYPE_SWORD, $GC_I_TYPE_DAGGERS, _
                $GC_I_TYPE_SCYTHE, $GC_I_TYPE_SPEAR
                    Return True
    EndSwitch
    Return False
EndFunc ;==>IsWeapon

;~ Returns True if the Item is of a Weapon Type
Func IsWeaponByType($iType)
    Switch $iType
        Case    $GC_I_TYPE_AXE, $GC_I_TYPE_BOW, $GC_I_TYPE_OFFHAND, _
                $GC_I_TYPE_HAMMER, $GC_I_TYPE_WAND, $GC_I_TYPE_SHIELD, _
                $GC_I_TYPE_STAFF, $GC_I_TYPE_SWORD, $GC_I_TYPE_DAGGERS, _
                $GC_I_TYPE_SCYTHE, $GC_I_TYPE_SPEAR
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
Func HasUpgradeOfTheProfession(ByRef $pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "fastcasting", "mesmer", "mes"
                If CheckModStruct($sModStruct, "0500A828") Then Return True

            Case "soulreaping", "necromancer", "necro"
                If CheckModStruct($sModStruct, "0506A828") Then Return True

            Case "energystorage", "elementalist", "ele"
                If CheckModStruct($sModStruct, "050CA828") Then Return True

            Case "divinefavor", "monk"
                If CheckModStruct($sModStruct, "0510A828") Then Return True

            Case "strength", "warrior"
                If CheckModStruct($sModStruct, "0511A828") Then Return True

            Case "expertise", "ranger"
                If CheckModStruct($sModStruct, "0517A828") Then Return True

            Case "criticalstrikes", "assassin", "assa", "sin"
                If CheckModStruct($sModStruct, "0523A828") Then Return True

            Case "spawningpower", "ritualist", "rit"
                If CheckModStruct($sModStruct, "0524A828") Then Return True

            Case "leadership", "paragon", "para"
                If CheckModStruct($sModStruct, "0528A828") Then Return True

            Case "mysticism", "dervish", "derv"
                If CheckModStruct($sModStruct, "052CA828") Then Return True
        
        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradeOfTheProfession

;~ checks if item contains selected prefix
Func HasUpgradePrefix(ByRef $pItem, $sMods)
    If $sMods = "" Then Return False

    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "33bleeding", "barbed"
                If CheckModStruct($sModStruct, "DE016824") Then Return True
            Case "33crippled", "crippling"
                If CheckModStruct($sModStruct, "E1016824") Then Return True
            Case "33deepwound", "cruel"
                If CheckModStruct($sModStruct, "E2016824") Then Return True
            Case "33weakness", "heavy"
                If CheckModStruct($sModStruct, "E6016824") Then Return True
            Case "33poison", "poisonous"
                If CheckModStruct($sModStruct, "E4016824") Then Return True
            Case "33dazed", "silencing"
                If CheckModStruct($sModStruct, "E5016824") Then Return True

            Case "earth", "ebon"
                If CheckModStruct($sModStruct, "000BB824") Then Return True
            Case "fire", "fiery"
                If CheckModStruct($sModStruct, "0005B824") Then Return True
            Case "cold", "icy"
                If CheckModStruct($sModStruct, "0003B824") Then Return True
            Case "lightning", "shocking"
                If CheckModStruct($sModStruct, "0004B824") Then Return True

            Case "10adrenaline", "furious"
                If CheckModStruct($sModStruct, "0A00B823") Then Return True
            Case "sundering"
                If CheckModStruct($sModStruct, "1414F823") Then Return True
            Case "vampiric"
                If CheckModStruct($sModStruct, "00032825") Then Return True
                If CheckModStruct($sModStruct, "00052825") Then Return True
            Case "zealous"
                If CheckModStruct($sModStruct, "01001825") Then Return True

            Case "20hct", "adept", "adeptstaffhead"
                If CheckModStruct($sModStruct, "2004302500140828") Then Return True
            Case "5a", "defensive", "defensivestaffhead"
                If CheckModStruct($sModStruct, "2201302505000821") Then Return True
            Case "30hp", "hale", "halestaffhead"
                If CheckModStruct($sModStruct, "3A013025001E4823") Then Return True
            Case "10hct", "swift", "swiftstaffhead"
                If CheckModStruct($sModStruct, "1E043025000A0822") Then Return True

        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradePrefix

;~ checks if item contains selected suffix
Func HasUpgradeSuffix(ByRef $pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "5a", "defense", "ofdefense"
                If CheckModStruct($sModStruct, "05000821") Then Return True
            Case "7physical", "shelter", "ofshelter"
                If CheckModStruct($sModStruct, "07005821") Then Return True
            Case "7elemental", "warding", "ofwarding"
                If CheckModStruct($sModStruct, "07002821") Then Return True

            Case "20ench", "enchanting", "ofenchanting"
                If CheckModStruct($sModStruct, "1400B822") Then Return True
            Case "10hct", "swiftness", "ofswiftness"
                If CheckModStruct($sModStruct, "39043025000A0822") Then Return True
            Case "20hct", "aptitude", "ofaptitude"
                If CheckModStruct($sModStruct, "2F04302500140828") Then Return True

            Case "30hp", "fortitude", "offortitude"
                If CheckModStruct($sModStruct, "001E4823") Then Return True
            Case "45ench", "devotion", "ofdevotion"
                If CheckModStruct($sModStruct, "002D6823") Then Return True
            Case "45stance", "endurance", "ofendurance"
                If CheckModStruct($sModStruct, "002D8823") Then Return True
            Case "60hex", "valor", "ofvalor"
                If CheckModStruct($sModStruct, "003C7823") Then Return True

            ;~ both do the same, maybe diff function for the staff upgrade, to include attribute?
            Case "+120attribute", "attribute", "ofattribute"
                Local $aMod = GetModByIdentifier($sModStruct, "1824")
                Return $aMod[0] = 20
            Case "+120mastery", "mastery", "ofmastery"
                Local $aMod = GetModByIdentifier($sModStruct, "1824")
                Return $aMod[0] = 20

            Case "10hsr", "quickening", "ofquickening"
                If CheckModStruct($sModStruct, "C1023025000AA823") Then Return True
            Case "20hsr", "memory", "ofmemory"
                If CheckModStruct($sModStruct, "BF02302500142828") Then Return True

            ;~ needs work, check for 20% missing, maybe diff function?
            Case "20undead", "deathbane", "ofdeathbane"
                If CheckModStruct($sModStruct, "00008080") Then Return True

            Case "20charr", "charrslaying", "ofcharrslaying"
                If CheckModStruct($sModStruct, "00018080") Then Return True

            Case "20trolls", "trollslaying", "oftrollslaying"
                If CheckModStruct($sModStruct, "00028080") Then Return True

            Case "20plants", "pruning", "ofpruning"
                If CheckModStruct($sModStruct, "00038080") Then Return True

            Case "20skeleton", "skeletonslaying", "ofskeletonslaying"
                If CheckModStruct($sModStruct, "00048080") Then Return True

            Case "20giants", "giantslaying", "ofgiantslaying"
                If CheckModStruct($sModStruct, "00058080") Then Return True

            Case "20dwarves", "dwarfslaying", "ofdwarfslaying"
                If CheckModStruct($sModStruct, "00068080") Then Return True

            Case "20tengu", "tenguslaying", "oftenguslaying"
                If CheckModStruct($sModStruct, "00078080") Then Return True

            Case "20demons", "demonslaying", "ofdemonslaying"
                If CheckModStruct($sModStruct, "00088080") Then Return True

            Case "20dragons", "dragonslaying", "ofdragonslaying"
                If CheckModStruct($sModStruct, "00098080") Then Return True
            
            Case "20ogres", "ogreslaying", "ofogreslaying"
                If CheckModStruct($sModStruct, "000A8080") Then Return True

        EndSwitch
    Next

    Return False
EndFunc ;==>HasUpgradeSuffix

;~ checks if item contains selected inscription
Func HasInscription(ByRef $pItem, $sMods)
    If $sMods = "" Then Return False
    
    Local $sModStruct = GetModStruct($pItem)
    Local $aMods = StringSplit(StringLower($sMods), "|", $STR_NOCOUNT)

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "1550", "strengthandhonor"
                If CheckModStruct($sModStruct, "CA0232250F327822") Then Return True
            Case "15ench", "guidedbyfate"
                If CheckModStruct($sModStruct, "C80232250F006822") Then Return True
            Case "15stance", "dancewithdeath"
                If CheckModStruct($sModStruct, "D00232250F00A822") Then Return True
            Case "15vshexed", "toomuchinformation"
                If CheckModStruct($sModStruct, "C60232250F005822") Then Return True
            Case "15-10a", "tothepain"
                If CheckModStruct($sModStruct, "D40232250F003822D40232250A001820") Then Return True
            Case "15-5e", "brawnoverbrains"
                If CheckModStruct($sModStruct, "D20232250F003822D20232250500B820") Then Return True
            Case "2050", "vengeanceismine"
                If CheckModStruct($sModStruct, "CC02322514328822") Then Return True
            Case "20hexed", "dontfearthereaper"
                If CheckModStruct($sModStruct, "CE02322514009822") Then Return True

            Case "5e", "ihavethepower"
                If CheckModStruct($sModStruct, "B80232250500D822") Then Return True
            Case "5e50", "haleandhearty"
                If CheckModStruct($sModStruct, "B403322505320823") Then Return True
            Case "5eench", "havefaith"
                If CheckModStruct($sModStruct, "B20332250500F822") Then Return True
            Case "7e50", "dontcallitacomeback"
                If CheckModStruct($sModStruct, "B603322507321823") Then Return True
            Case "7ehexed", "iamsorrow"
                If CheckModStruct($sModStruct, "B803322507002823") Then Return True
            Case "15e-1main", "seizetheday"
                If CheckModStruct($sModStruct, "B00332250F00D822B00332250100C820") Then Return True

            Case "10hct", "dontthinktwice"
                If CheckModStruct($sModStruct, "BA033225000A0822") Then Return True
            Case "10hsr", "letthememoryliveagain"
                If CheckModStruct($sModStruct, "BC023225000AA823") Then Return True
            Case "20hct", "aptitudenotattitude"
                If CheckModStruct($sModStruct, "AE03322500140828") Then Return True

            Case "10blunt", "nottheface"
                If CheckModStruct($sModStruct, "860332A50A0018A1") Then Return True
            Case "10cold", "leafonthewind"
                If CheckModStruct($sModStruct, "880332A50A0318A1") Then Return True
            Case "10earth", "likearollingstone"
                If CheckModStruct($sModStruct, "8A0332A50A0B18A1") Then Return True
            Case "10fire", "sleepnowinthefire"
                If CheckModStruct($sModStruct, "8E0332A50A0518A1") Then Return True
            Case "10lightning", "ridersonthestorm"
                If CheckModStruct($sModStruct, "8C0332A50A0418A1") Then Return True
            Case "10piercing", "throughthickandthin"
                If CheckModStruct($sModStruct, "900332A50A0118A1") Then Return True
            Case "10slashing", "theriddleofsteel"
                If CheckModStruct($sModStruct, "920332A50A0218A1") Then Return True
                
            Case "-2ench", "shelteredbyfaith"
                If CheckModStruct($sModStruct, "A603322502008820") Then Return True
            Case "-2stance", "runforyourlife"
                If CheckModStruct($sModStruct, "AA0332250200A820") Then Return True
            Case "-3hex", "nothingtofear"
                If CheckModStruct($sModStruct, "A803322503009820") Then Return True
            Case "-520", "luckofthedraw"
                If CheckModStruct($sModStruct, "A403322505147820") Then Return True

            Case "20bleeding", "fearcutsdeeper"
                If CheckModStruct($sModStruct, "9403322500005828") Then Return True
            Case "20blind", "icanseeclearlynow"
                If CheckModStruct($sModStruct, "9603322500015828") Then Return True
            Case "20crippled", "swiftasthewind"
                If CheckModStruct($sModStruct, "9803322500035828") Then Return True
            Case "20dazed", "soundnessofmind"
                If CheckModStruct($sModStruct, "A003322500075828") Then Return True
            Case "20deepwound", "strengthofbody"
                If CheckModStruct($sModStruct, "9A03322500045828") Then Return True
            Case "20disease", "castouttheunclean"
                If CheckModStruct($sModStruct, "9C03322500055828") Then Return True
            Case "20poison", "pureofheart"
                If CheckModStruct($sModStruct, "9E03322500065828") Then Return True
            Case "20weakness", "onlythestrongsurvive"
                If CheckModStruct($sModStruct, "A203322500085828") Then Return True

            Case "5a50", "hailtotheking"
                If CheckModStruct($sModStruct, "7C0332250532A821") Then Return True
            Case "5aench", "faithismyshield"
                If CheckModStruct($sModStruct, "7803322505009821") Then Return True
            Case "5aattacking", "mightmakesright"
                If CheckModStruct($sModStruct, "7403322505007821") Then Return True
            Case "5acasting", "knowingishalfthebattle"
                If CheckModStruct($sModStruct, "7603322505008821") Then Return True
            Case "5aelemental", "manforallseasons"
                If CheckModStruct($sModStruct, "7003322505002821") Then Return True
            Case "5aphysical", "survivalofthefittest"
                If CheckModStruct($sModStruct, "7203322505005821") Then Return True
            Case "5a-5e", "ignoranceisbliss"
                If CheckModStruct($sModStruct, "6C033225050008216C0332250500B820") Then Return True
            Case "5a-20hp", "lifeispain"
                If CheckModStruct($sModStruct, "6E033225050008216E0332251400D820") Then Return True
            Case "10a50", "downbutnotout"
                If CheckModStruct($sModStruct, "7A0332250A32B821") Then Return True
            Case "10ahexed", "bejustandfearnot"
                If CheckModStruct($sModStruct, "7E0332250A00C821") Then Return True
            Case "15e-1offhand", "livefortoday"
                If CheckModStruct($sModStruct, "800332250F00D822800332250100C820") Then Return True
                
            Case "+120", "masterofmydomain"
                If CheckModStruct($sModStruct, "AC03322500143828") Then Return True
            Case "10hsroffhand", "serenitynow"
                If CheckModStruct($sModStruct, "82033225000AA823") Then Return True
            Case "20hsr", "forgetmenot"
                If CheckModStruct($sModStruct, "8403322500142828") Then Return True
                
            Case "m4m", "measureformeasure"
                If CheckModStruct($sModStruct, "3E0432251D000826") Then Return True
            Case "showmethemoney"
                If CheckModStruct($sModStruct, "3C0432252E00F825") Then Return True
                If CheckModStruct($sModStruct, "3C0432253000F825") Then Return True
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
    Return CheckModStruct(GetModStruct($pItem), "BF02302500142828")
EndFunc ;==>IsWandWrappingOfMemory

;~ checks for forget me not inscription (20% HSR)
Func IsForgetMeNot($pItem)
    Return CheckModStruct(GetModStruct($pItem), "8403322500142828")
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
    Return CheckModStruct(GetModStruct($pItem), "C1023025000AA823")
EndFunc ;==>IsWandWrappingOfQuickening

;~ checks for serenity now inscription (10% HSR)
Func IsSerenityNow($pItem)
    Return CheckModStruct(GetModStruct($pItem), "82033225000AA823")
EndFunc ;==>IsSerenityNow

;~ checks for let the memory live again inscription (10% HSR)
Func IsLetTheMemoryLiveAgain($pItem)
    Return CheckModStruct(GetModStruct($pItem), "BC023225000AA823")
EndFunc ;==>IsLetTheMemoryLiveAgain


;~ checks for 20% HCT upgrade (any)
Func Is20HCT($pItem)
    Local $aMod = GetModByIdentifier($pItem, '0828')
    Return $aMod[1] = 20
EndFunc ;==>Is20HCT

;~ checks for focus core of aptitude (20% HCT)
Func IsFocusCoreOfAptitude($pItem)
    Return CheckModStruct(GetModStruct($pItem), "2F04302500140828")
EndFunc ;==>IsFocusCoreOfAptitude

;~ checks for adept staff head (20% HCT)
Func IsAdeptStaffHead($pItem)
    Return CheckModStruct(GetModStruct($pItem), "2004302500140828")
EndFunc ;==>IsAdeptStaffHead

;~ checks for aptitude not attitude inscription (20% HCT)
Func IsAptitudeNotAttitude($pItem)
    Return CheckModStruct(GetModStruct($pItem), "AE03322500140828")
EndFunc ;==>IsAptitudeNotAttitude


;~ checks for 10% HCT upgrade (any)
Func Is10HCT($pItem)
    Local $aMod = GetModByIdentifier($pItem, '0822')
    Return $aMod[1] = 10
EndFunc ;==>Is20HCT

;~ checks for focus core of swiftness (10% HCT)
Func IsFocusCoreOfSwiftness($pItem)
    Return CheckModStruct(GetModStruct($pItem), "39043025000A0822")
EndFunc ;==>IsFocusCoreOfSwiftness

;~ checks for swift staff head (10% HCT)
Func IsSwiftStaffHead($pItem)
    Return CheckModStruct(GetModStruct($pItem), "1E043025000A0822")
EndFunc ;==>IsSwiftStaffHead

;~ checks for don't think twice inscription (10% HCT)
Func IsDontThinkTwice($pItem)
    Return CheckModStruct(GetModStruct($pItem), "BA033225000A0822")
EndFunc ;==>IsDontThinkTwice

;~ checks for hale staff head (+30hp prefix)
Func IsHaleStaffHead($pItem)
    Return CheckModStruct(GetModStruct($pItem), "3A013025001E4823")
EndFunc ;==>IsHaleStaffHead

;~ checks for staff wrapping of fortitude (+30hp suffix)
Func IsStaffWrappingOfFortitude($pItem)
    Return CheckModStruct(GetModStruct($pItem), "B9013025001E4823")
EndFunc ;==>IsStaffWrappingOfFortitude


;~ checks for vampiric upgrade
Func IsVampiric($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '2825')
    If $aMod[1] < 3 Then Return False

    If $iWeaponType = -1 Then Return True

    ;~ Switch for selective weapon type is missing, also check if vamp is max
    Return False
EndFunc ;==>IsVampiric

;~ checks for zealous upgrade
Func IsZealous($pItem, $iWeaponType = -1)
    Local $sModStruct = GetModStruct($pItem)
    Local $aMod = GetModByIdentifier($sModStruct, '1825')
    If $aMod[0] < 1 Then Return False

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
    Return CheckModStruct(GetModStruct($pItem), "9C000824380130250500D822")
EndFunc ;==>IsInsightfulStaffHead

;~ checks for I have the power inscription (+5e)
Func IsIHaveThePower($pItem)
    Return CheckModStruct(GetModStruct($pItem), "B80232250500D822")
EndFunc ;==>IsIHaveThePower

;~ checks for have faith inscription (+5e^ench)
Func IsHaveFaith($pItem)
    Return CheckModStruct(GetModStruct($pItem), "B20332250500F822")
EndFunc ;==>IsHaveFaith

;~ checks for seize the day inscription (+15e^-1)
Func IsSeizeTheDay($pItem)
    Return CheckModStruct(GetModStruct($pItem), "B00332250F00D822B00332250100C820")
EndFunc ;==>IsSeizeTheDay

;~ checks for live for today inscription (+15e^-1)
Func IsLiveForToday($pItem)
    Return CheckModStruct(GetModStruct($pItem), "800332250F00D822800332250100C820")
EndFunc ;==>IsLiveForToday


;~ checks for "to the pain inscription" (15^-10a)
Func IsToThePain($pItem)
    Return CheckModStruct(GetModStruct($pItem), "D40232250F003822D40232250A001820")
EndFunc ;==>IsToThePain

;~ checks for "brawn over brains" inscription (15^-5e)
Func IsBrawnOverBrains($pItem)
    Return CheckModStruct(GetModStruct($pItem), "D20232250F003822D20232250500B820")
EndFunc ;==>IsBrawnOverBrains

;~ checks for "guided by faith" inscription (15^ench)
Func IsGuidedByFaith($pItem)
    Return CheckModStruct(GetModStruct($pItem), "C80232250F006822")
EndFunc ;==>IsGuidedByFaith

;~ checks for "strength is honor" inscription (15^50)
Func IsStrengthAndHonor($pItem)
    Return CheckModStruct(GetModStruct($pItem), "CA0232250F327822")
EndFunc ;==>IsStrengthAndHonor

;~ checks for "vengeance is mine" inscription (20^50)
Func IsVengeanceIsMine($pItem)
    Return CheckModStruct(GetModStruct($pItem), "CC02322514328822")
EndFunc ;==>IsVengeanceIsMine

;~ checks for "dont fear the reaper" inscription (20^hexed)
Func IsDontFearTheReaper($pItem)
    Return CheckModStruct(GetModStruct($pItem), "CE02322514009822")
EndFunc ;==>IsDontFearTheReaper

;~ checks for "dance with death" inscription (15^stance)
Func IsDanceWithDeath($pItem)
    Return CheckModStruct(GetModStruct($pItem), "D00232250F00A822")
EndFunc ;==>IsDanceWithDeath

;~ checks for "too much information" inscription (15^vsHexed)
Func IsTooMuchInformation($pItem)
    Return CheckModStruct(GetModStruct($pItem), "C60232250F005822")
EndFunc ;==>IsTooMuchInformation


;~ checks for "sheltered by faith" inscription (-2^ench)
Func IsShelteredByFaith($pItem)
    Return CheckModStruct(GetModStruct($pItem), "A603322502008820")
EndFunc ;==>IsShelteredByFaith

;~ checks for "run for your life" inscription (-2^stance)
Func IsRunForYourLife($pItem)
    Return CheckModStruct(GetModStruct($pItem), "AA0332250200A820")
EndFunc ;==>IsRunForYourLife

;~ checks for "nothing to fear" inscription (-3^hex)
Func IsNothingToFear($pItem)
    Return CheckModStruct(GetModStruct($pItem), "A803322503009820")
EndFunc ;==>IsNothingToFear

;~ checks for "luck of the draw" inscription (-5^20%)
Func IsLuckOfTheDraw($pItem)
    Return CheckModStruct(GetModStruct($pItem), "A403322505147820")
EndFunc ;==>IsLuckOfTheDraw
#EndRegion Weapon Mods

#Region OS Filter
;~ filter for any OS martial weapon
Func CheckOsMartialWeapon(ByRef $pItem, ByRef $sRules)
    Local Static $bFirstCall = True

    Local Static $aRuleReq[0]
    Local Static $aRuleWeapon[0]
    Local Static $aRuleMods[0]

    If $bFirstCall Then

        Local $aRows = StringSplit(StringLower($sRules), "|", $STR_NOCOUNT) ; split rows

        Local $iRows = UBound($aRows), $iValidRows = 0

        ReDim $aRuleReq[$iRows]
        ReDim $aRuleWeapon[$iRows]
        ReDim $aRuleMods[$iRows]

        For $sCurrentRow In $aRows

            Local $aCols = StringSplit($sCurrentRow, ";", $STR_NOCOUNT) ; split columns

            If UBound($aCols) <> 3 Then
                Out("Martial rule is wrongly formatted: " & $sCurrentRow)
                ContinueLoop
            EndIf

            $aRuleReq[$iValidRows] = Number(StringStripWS($aCols[0], $STR_STRIPLEADING + $STR_STRIPTRAILING))
            $aRuleWeapon[$iValidRows] = $aCols[1]
            $aRuleMods[$iValidRows] = $aCols[2]

            $iValidRows += 1
        Next

        If $iValidRows < $iRows Then
            Redim $aRuleReq[$iValidRows]
            Redim $aRuleWeapon[$iValidRows]
            Redim $aRuleMods[$iValidRows]
        EndIf
        
        $bFirstCall = False
    EndIf

    If UBound($aRuleReq) = 0 Then
        Out("No valid martial rules found.")
        Return False
    EndIf

    Local $iType = GetItemType($pItem)
    If Not IsWeaponByType($iType) Then Return False ; not a weapon?

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False
    
    If Not IsWeaponMaxDmg($sModStruct, $iType) Then Return False ; max dmg?

    Local $iReq = GetItemReq($sModStruct) ; check against 1st column

    For $i = 0 To UBound($aRuleReq) - 1

        If $iReq > $aRuleReq[$i] Then ContinueLoop ; req

        If Not CheckTypeMartial($iType, $aRuleWeapon[$i]) Then ContinueLoop ; type

        If Not CheckModMartial($sModStruct, $aRuleMods[$i]) Then ContinueLoop ; mods

        Return True

    Next

    Return False
EndFunc ;==>CheckOsMartialWeapon

Func CheckTypeMartial($iType, ByRef $sWeapons)
    Local $aWeapons = StringSplit($sWeapons, ",", $STR_NOCOUNT)

    For $sWeapon In $aWeapons

        $sWeapon = StringStripWS($sWeapon, $STR_STRIPLEADING + $STR_STRIPTRAILING)

        Switch $sWeapon
            Case "allweapons", "any"
                Return True
            Case "axe"
                If $iType = $GC_I_TYPE_AXE Then Return True
            Case "bow"
                If $iType = $GC_I_TYPE_BOW Then Return True
            Case "daggers", "dagger"
                If $iType = $GC_I_TYPE_DAGGERS Then Return True
            Case "hammer"
                If $iType = $GC_I_TYPE_HAMMER Then Return True
            Case "sword"
                If $iType = $GC_I_TYPE_SWORD Then Return True
        EndSwitch

    Next

    Return False
EndFunc ;==>CheckTypeMartial

Func CheckModMartial(ByRef $sModStruct, ByRef $sMods)
    Local $aMods = StringSplit($sMods, ",", $STR_NOCOUNT)

    For $sMod In $aMods

        $sMod = StringStripWS($sMod, $STR_STRIPLEADING + $STR_STRIPTRAILING)

        Switch $sMod
            
            Case "1550"
                If CheckModStruct($sModStruct, "0F327822") Then Return True

            Case "15ench"
                If CheckModStruct($sModStruct, "0F006822") Then Return True

            Case "15stance"
                If CheckModStruct($sModStruct, "0F00A822") Then Return True

            Case "15vshexed"
                If CheckModStruct($sModStruct, "0F005822") Then Return True

            Case "15-5e"
                If CheckModStruct($sModStruct, "0F0038220500B820") Then Return True

            Case "15-10a"
                If CheckModStruct($sModStruct, "0F0038220A001820") Then Return True

            Case "5e"
                If CheckModStruct($sModStruct, "0500D822") Then Return True

            Case "2050"
                If CheckModStruct($sModStruct, "14009822") Then Return True

            Case "dualvamp", "vampiricstrength"
                If CheckModStruct($sModStruct, "0F0038220100E820") Then Return True

            Case "dualzeal", "zealousstrength"
                If CheckModStruct($sModStruct, "0F0038220100C820") Then Return True

        EndSwitch

    Next

    Return False
EndFunc ;==>CheckModMartial

;~ filter for OS wand
Func CheckOsWand($pItem, ByRef $sRules)
    Local Static $bFirstCall = True

    Local Static $aRuleReq[0]
    Local Static $aRuleAttribute[0]
    Local Static $aRuleMod1[0]
    Local Static $aRuleMod2[0]

    If $bFirstCall Then

        Local $aRows = StringSplit(StringLower($sRules), "|", $STR_NOCOUNT) ; split rows

        Local $iRows = UBound($aRows), $iValidRows = 0

        ReDim $aRuleReq[$iRows]
        ReDim $aRuleAttribute[$iRows]
        ReDim $aRuleMod1[$iRows]
        ReDim $aRuleMod2[$iRows]

        For $sCurrentRow In $aRows

            Local $aCols = StringSplit($sCurrentRow, ";", $STR_NOCOUNT) ; split columns

            If UBound($aCols) <> 4 Then
                Out("Shield rule is wrongly formatted: " & $sCurrentRow)
                ContinueLoop
            EndIf

            $aRuleReq[$iValidRows] = Number(StringStripWS($aCols[0], $STR_STRIPLEADING + $STR_STRIPTRAILING))
            $aRuleAttribute[$iValidRows] = $aCols[1]
            $aRuleMod1[$iValidRows] = $aCols[2]
            $aRuleMod2[$iValidRows] = $aCols[3]

            $iValidRows += 1
        Next

        If $iValidRows < $iRows Then
            Redim $aRuleReq[$iValidRows]
            Redim $aRuleAttribute[$iValidRows]
            Redim $aRuleMod1[$iValidRows]
            Redim $aRuleMod2[$iValidRows]
        EndIf
        
        $bFirstCall = False
    EndIf

    If UBound($aRuleReq) = 0 Then
        Out("No valid wand rules found.")
        Return False
    EndIf

    Local $iType = GetItemType($pItem)
    If $iType <> $GC_I_TYPE_WAND Then Return False ; wand?

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False

    If Not IsWeaponMaxDmg($sModStruct, $iType) Then Return False ; max dmg?

    Local $iReq = GetItemReq($sModStruct) ; check against 1st column
    Local $iItemAttribute = GetItemAttribute($sModStruct) ; check against 2nd column
    Local $aWandMods = ParseWandMods($sModStruct)

    For $i = 0 To UBound($aRuleReq) - 1

        If $iReq > $aRuleReq[$i] Then ContinueLoop ; req

        If Not CheckWeaponAttribute($iItemAttribute, $aRuleAttribute[$i]) Then ContinueLoop ; weapon attribute

        If Not CheckModWand($aWandMods, $aRuleMod1[$i]) Then ContinueLoop ; mod1

        If Not CheckModWand($aWandMods, $aRuleMod2[$i]) Then ContinueLoop ; mod2

        Return True

    Next

    Return False
EndFunc ;==>CheckOsWand

;~ checks if wand contains any requested mod
Func CheckModWand(ByRef $aWandMods, ByRef $sMods)

    ; Split requested mods
    Local $aMods = StringSplit($sMods, ",", $STR_NOCOUNT)

    ;~ remove whitespace
    For $i = 0 To UBound($aMods) - 1
        $aMods[$i] = StringStripWS($aMods[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)
    Next

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "5e50", "+5e^50"
                If $aWandMods[$idx_mod_wand_5_50] Then Return True
            Case "5ench", "+5e^ench"
                If $aWandMods[$idx_mod_wand_5_ench] Then Return True
            Case "10hct"
                If $aWandMods[$idx_mod_wand_10_hct] Then Return True
            Case "10hsr"
                If $aWandMods[$idx_mod_wand_10_hsr] Then Return True
            Case "15-1", "+15e^-1", "highenergy"
                If $aWandMods[$idx_mod_wand_high_energy] Then Return True

            ;~ pick and choose specific attributes for 20 hct/hsr is missing
            Case "19hct"
                If $aWandMods[$idx_mod_wand_20_hct_value] >= 19 Then Return True
            Case "19hsr"
                If $aWandMods[$idx_mod_wand_20_hsr_value] >= 19 Then Return True
            Case "20hct"
                If $aWandMods[$idx_mod_wand_20_hct_value] >= 20 Then Return True
            Case "20hsr"
                If $aWandMods[$idx_mod_wand_20_hsr_value] >= 20 Then Return True
        EndSwitch
    Next

    ;~ +1^20% attribute mods
    If CheckModAttribute($aWandMods[$idx_mod_wand_attribute], $aMods) Then Return True

    Return False
EndFunc ;==>CheckModWand

;~ parses the modstruct of the wand and returns an array
Func ParseWandMods(ByRef $sModStruct)
    Local $aWandMods[$idx_mod_wand_size]

    $aWandMods[$idx_mod_wand_5_50] = CheckModStruct($sModStruct, "05320823")
    $aWandMods[$idx_mod_wand_5_ench] = CheckModStruct($sModStruct, "0500F822")
    $aWandMods[$idx_mod_wand_10_hct] = CheckModStruct($sModStruct, "000A0822")
    $aWandMods[$idx_mod_wand_10_hsr] = CheckModStruct($sModStruct, "000AA823")
    $aWandMods[$idx_mod_wand_high_energy] = CheckModStruct($sModStruct, "0F00D822")

    Local $aHct20 = GetModByIdentifier($sModStruct, '1822') ; 20% HCT
    $aWandMods[$idx_mod_wand_20_hct_attribute] = $aHct20[0]
    $aWandMods[$idx_mod_wand_20_hct_value] = $aHct20[1]

    Local $aHsr20 = GetModByIdentifier($sModStruct, '9823') ; 20% HSR
    $aWandMods[$idx_mod_wand_20_hsr_attribute] = $aHsr20[0]
    $aWandMods[$idx_mod_wand_20_hsr_value] = $aHsr20[1]

    Local $aAttribute = GetModByIdentifier($sModStruct, '1824') ; +1^20% attribute
    If $aAttribute[0] < 20 Then $aAttribute[1] = -1
    $aWandMods[$idx_mod_wand_attribute] = $aAttribute[1]

    Return $aWandMods
EndFunc ;==>ParseWandMods

;~ filter for OS focus
Func CheckOsFocus($pItem, ByRef $sRules)
    Local Static $bFirstCall = True

    Local Static $aRuleReq[0]
    Local Static $aRuleAttribute[0]
    Local Static $aRuleMod1[0]
    Local Static $aRuleMod2[0]

    If $bFirstCall Then

        Local $aRows = StringSplit(StringLower($sRules), "|", $STR_NOCOUNT) ; split rows

        Local $iRows = UBound($aRows), $iValidRows = 0

        ReDim $aRuleReq[$iRows]
        ReDim $aRuleAttribute[$iRows]
        ReDim $aRuleMod1[$iRows]
        ReDim $aRuleMod2[$iRows]

        For $sCurrentRow In $aRows

            Local $aCols = StringSplit($sCurrentRow, ";", $STR_NOCOUNT) ; split columns

            If UBound($aCols) <> 4 Then
                Out("Shield rule is wrongly formatted: " & $sCurrentRow)
                ContinueLoop
            EndIf

            $aRuleReq[$iValidRows] = Number(StringStripWS($aCols[0], $STR_STRIPLEADING + $STR_STRIPTRAILING))
            $aRuleAttribute[$iValidRows] = $aCols[1]
            $aRuleMod1[$iValidRows] = $aCols[2]
            $aRuleMod2[$iValidRows] = $aCols[3]

            $iValidRows += 1
        Next

        If $iValidRows < $iRows Then
            Redim $aRuleReq[$iValidRows]
            Redim $aRuleAttribute[$iValidRows]
            Redim $aRuleMod1[$iValidRows]
            Redim $aRuleMod2[$iValidRows]
        EndIf
        
        $bFirstCall = False
    EndIf

    If UBound($aRuleReq) = 0 Then
        Out("No valid wand rules found.")
        Return False
    EndIf

    Local $iType = GetItemType($pItem)
    If $iType <> $GC_I_TYPE_OFFHAND Then Return False ; focus?

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False

    If Not IsWeaponMaxDmg($sModStruct, $iType) Then Return False ; max energy?

    Local $iReq = GetItemReq($sModStruct) ; check against 1st column
    Local $iItemAttribute = GetItemAttribute($sModStruct) ; check against 2nd column
    Local $aFocusMods = ParseFocusMods($sModStruct)

   For $i = 0 To UBound($aRuleReq) - 1

        If $iReq > $aRuleReq[$i] Then ContinueLoop ; req

        If Not CheckWeaponAttribute($iItemAttribute, $aRuleAttribute[$i]) Then ContinueLoop ; weapon attribute

        If Not CheckModFocus($aFocusMods, $aRuleMod1[$i]) Then ContinueLoop ; mod1

        If Not CheckModFocus($aFocusMods, $aRuleMod2[$i]) Then ContinueLoop ; mod2

        Return True

    Next

    Return False
EndFunc ;==>CheckOsFocus

;~ checks if focus contains any requested mod
Func CheckModFocus(ByRef $aFocusMods, ByRef $sMods)

    ; Split requested mods
    Local $aMods = StringSplit($sMods, ",", $STR_NOCOUNT)

    ;~ remove whitespace
    For $i = 0 To UBound($aMods) - 1
        $aMods[$i] = StringStripWS($aMods[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)
    Next

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            ;~ Case "5a50", "+5a^50"
            ;~     If $aFocusMods[$idx_mod_focus_armor_enchanted] Then Return True
            Case "5ench", "+5a^ench"
                If $aFocusMods[$idx_mod_focus_armor_enchanted] Then Return True
            Case "10hct"
                If $aFocusMods[$idx_mod_focus_10_hct] Then Return True
            Case "10hsr"
                If $aFocusMods[$idx_mod_focus_10_hsr] Then Return True
            Case "15-1", "+15e^-1", "highenergy"
                If $aFocusMods[$idx_mod_focus_high_energy] Then Return True

            ;~ pick and choose specific attributes for 20 hct/hsr is missing
            Case "19hct"
                If $aFocusMods[$idx_mod_focus_20_hct_value] >= 19 Then Return True
            Case "19hsr"
                If $aFocusMods[$idx_mod_focus_20_hsr_value] >= 19 Then Return True
            Case "20hct"
                If $aFocusMods[$idx_mod_focus_20_hct_value] >= 20 Then Return True
            Case "20hsr"
                If $aFocusMods[$idx_mod_focus_20_hsr_value] >= 20 Then Return True
        EndSwitch
    Next

    ;~ +30Hp
    If CheckMod30Hp($aFocusMods[$idx_mod_focus_30hp], $aMods) Then Return True

    ;~ +45Hp^ench
    If CheckMod45Ench($aFocusMods[$idx_mod_focus_45ench], $aMods) Then Return True

    ;~ +45Hp^stance
    If CheckMod45Stance($aFocusMods[$idx_mod_focus_45stance], $aMods) Then Return True

    ;~ +60Hp^hex
    If CheckMod60Hex($aFocusMods[$idx_mod_focus_60hex], $aMods) Then Return True

    ;~ +1^20% attribute mods
    If CheckModAttribute($aFocusMods[$idx_mod_focus_attribute], $aMods) Then Return True

    ;~ armor vs monster type
    ;~ If CheckModMonster($aFocusMods[$idx_mod_shield_armor_monster], $aMods) Then Return True

    Return False
EndFunc ;==>CheckModFocus

;~ parses the modstruct of the focus and returns an array
Func ParseFocusMods(ByRef $sModStruct)
    Local $aFocusMods[$idx_mod_focus_size]

    Local $a30hp = GetModByIdentifier($sModStruct, '4823') ; 30hp
    $aFocusMods[$idx_mod_focus_30hp] = $a30hp[1]

    Local $a45ench = GetModByIdentifier($sModStruct, '6823') ; 45ench
    $aFocusMods[$idx_mod_focus_45ench] = $a45ench[1]
    
    Local $a45stance = GetModByIdentifier($sModStruct, '8823') ; 45stance
    $aFocusMods[$idx_mod_focus_45stance] = $a45stance[1]

    Local $a60hex = GetModByIdentifier($sModStruct, '7823') ; 60hex
    $aFocusMods[$idx_mod_focus_60hex] = $a60hex[1]

    $aFocusMods[$idx_mod_focus_armor_enchanted] = CheckModStruct($sModStruct, "05009821")
    $aFocusMods[$idx_mod_focus_10_hct] = CheckModStruct($sModStruct, "000A0822")
    $aFocusMods[$idx_mod_focus_10_hsr] = CheckModStruct($sModStruct, "000AA823")
    $aFocusMods[$idx_mod_focus_high_energy] = CheckModStruct($sModStruct, "0F00D822")

    Local $aHct20 = GetModByIdentifier($sModStruct, '1822') ; 20% HCT
    $aFocusMods[$idx_mod_focus_20_hct_attribute] = $aHct20[0]
    $aFocusMods[$idx_mod_focus_20_hct_value] = $aHct20[1]

    Local $aHsr20 = GetModByIdentifier($sModStruct, '9823') ; 20% HSR
    $aFocusMods[$idx_mod_focus_20_hsr_attribute] = $aHsr20[0]
    $aFocusMods[$idx_mod_focus_20_hsr_value] = $aHsr20[1]

    Local $aAttribute = GetModByIdentifier($sModStruct, '1824') ; +1^20% attribute
    If $aAttribute[0] < 20 Then $aAttribute[1] = -1
    $aFocusMods[$idx_mod_focus_attribute] = $aAttribute[1]

    Local $aMonster = GetModByIdentifier($sModStruct, '8080') ; +monster type
    $aFocusMods[$idx_mod_focus_armor_monster_type] = $aMonster[1]

    If $aFocusMods[$idx_mod_focus_armor_monster_type] <> -1 Then
        $aMonster = GetModByIdentifier($sModStruct, 'F8A0') ; armor vs monster value
        If $aMonster[1] < 10 Then $aMonster[1] = -1
        $aFocusMods[$idx_mod_focus_armor_monster_value] = $aMonster[1]
    Else
        $aFocusMods[$idx_mod_focus_armor_monster_value] = -1
    EndIf

    Return $aFocusMods
EndFunc ;==>ParseFocusMods

;~ filter for OS staff
Func CheckOsStaff($pItem, ByRef $sRules)
    Local $iType = GetItemType($pItem)
    If $iType <> $GC_I_TYPE_STAFF Then Return False ; focus?

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False

    If Not IsWeaponMaxDmg($sModStruct, $iType) Then Return False ; max dmg?
    ;~ check inherent mods for max stats here

    Local $iReq = GetItemReq($sModStruct) ; check against 1st column
    Local $iItemAttribute = GetItemAttribute($sModStruct) ; check against 2nd column
    Local $aStaffMods = ParseStaffMods($sModStruct)

    ; Split all rule rows
    Local $aRows = StringSplit(StringLower($sRules), "|", $STR_NOCOUNT)

    ; Process each rule row
    For $sRow In $aRows

        ; Split row into columns
        Local $aCols = StringSplit($sRow, ";", $STR_NOCOUNT)

        ; safety check
        If UBound($aCols) <> 4 Then
            Out("Row is wrongly formatted.")
            ContinueLoop
        EndIf

        ;========================================
        ; Column 1: Requirement
        ;========================================

        Local $iRuleReq = Number(StringStripWS($aCols[0], $STR_STRIPLEADING + $STR_STRIPTRAILING))

        If $iReq > $iRuleReq Then ContinueLoop

        ;========================================
        ; Column 2: Attribute
        ;========================================

        Local $bAttributeMatch = CheckWeaponAttribute($iItemAttribute, $aCols[1])

        If Not $bAttributeMatch Then ContinueLoop

    Next

    Return False
EndFunc ;==>CheckOsStaff

Func CheckModStaff()
    Return True
EndFunc ;==>CheckModStaff

Func ParseStaffMods(ByRef $sModStruct)
    Return True
EndFunc ;==>ParseStaffMods

;~ filter or OS shield
Func CheckOsShield(ByRef $pItem, ByRef $sRules)
    Local Static $bFirstCall = True

    Local Static $aRuleReq[0]
    Local Static $aRuleAttribute[0]
    Local Static $aRuleMod1[0]
    Local Static $aRuleMod2[0]

    If $bFirstCall Then

        Local $aRows = StringSplit(StringLower($sRules), "|", $STR_NOCOUNT) ; split rows

        Local $iRows = UBound($aRows), $iValidRows = 0

        ReDim $aRuleReq[$iRows]
        ReDim $aRuleAttribute[$iRows]
        ReDim $aRuleMod1[$iRows]
        ReDim $aRuleMod2[$iRows]

        For $sCurrentRow In $aRows

            Local $aCols = StringSplit($sCurrentRow, ";", $STR_NOCOUNT) ; split columns

            If UBound($aCols) <> 4 Then
                Out("Shield rule is wrongly formatted: " & $sCurrentRow)
                ContinueLoop
            EndIf

            $aRuleReq[$iValidRows] = Number(StringStripWS($aCols[0], $STR_STRIPLEADING + $STR_STRIPTRAILING))
            $aRuleAttribute[$iValidRows] = $aCols[1]
            $aRuleMod1[$iValidRows] = $aCols[2]
            $aRuleMod2[$iValidRows] = $aCols[3]

            $iValidRows += 1
        Next

        If $iValidRows < $iRows Then
            Redim $aRuleReq[$iValidRows]
            Redim $aRuleAttribute[$iValidRows]
            Redim $aRuleMod1[$iValidRows]
            Redim $aRuleMod2[$iValidRows]
        EndIf
        
        $bFirstCall = False
    EndIf

    If UBound($aRuleReq) = 0 Then
        Out("No valid shield rules found.")
        Return False
    EndIf

    Local $iType = GetItemType($pItem)
    If $iType <> $GC_I_TYPE_SHIELD Then Return False ; shield?

    Local $sModStruct = GetModStruct($pItem)
    If $sModStruct = 0 Then Return False

    If Not IsWeaponMaxDmg($sModStruct, $iType) Then Return False ; max armor?

    Local $iReq = GetItemReq($sModStruct) ; check against 1st column
    Local $iItemAttribute = GetItemAttribute($sModStruct) ; check against 2nd column
    Local $aShieldMods = ParseShieldMods($sModStruct)


    For $i = 0 To UBound($aRuleReq) - 1

        If $iReq > $aRuleReq[$i] Then ContinueLoop ; req

        If Not CheckWeaponAttribute($iItemAttribute, $aRuleAttribute[$i]) Then ContinueLoop ; weapon attribute

        If Not CheckModShield($aShieldMods, $aRuleMod1[$i]) Then ContinueLoop ; mod1

        If Not CheckModShield($aShieldMods, $aRuleMod2[$i]) Then ContinueLoop ; mod2

        Return True

    Next

    Return False
EndFunc ;==>CheckOsShield

;~ checks if shield contains any requested mod
Func CheckModShield(ByRef $aShieldMods, ByRef $sMods)

    ; Split requested mods
    Local $aMods = StringSplit($sMods, ",", $STR_NOCOUNT)

    ;~ remove whitespace
    For $i = 0 To UBound($aMods) - 1
        $aMods[$i] = StringStripWS($aMods[$i], $STR_STRIPLEADING + $STR_STRIPTRAILING)
    Next

    For $sCurrentMod In $aMods
        Switch $sCurrentMod
            Case "-2ench", "2ench"
                If $aShieldMods[$idx_mod_shield_2ench] Then Return True
            Case "-2stance", "2stance"
                If $aShieldMods[$idx_mod_shield_2stance] Then Return True
            Case "-3hex", "3hex"
                If $aShieldMods[$idx_mod_shield_3hex] Then Return True
        EndSwitch
    Next

    ;~ +30Hp
    If CheckMod30Hp($aShieldMods[$idx_mod_shield_30hp], $aMods) Then Return True

    ;~ +45Hp^ench
    If CheckMod45Ench($aShieldMods[$idx_mod_shield_45ench], $aMods) Then Return True

    ;~ +45Hp^stance
    If CheckMod45Stance($aShieldMods[$idx_mod_shield_45stance], $aMods) Then Return True

    ;~ +60Hp^hex
    If CheckMod60Hex($aShieldMods[$idx_mod_shield_60hex], $aMods) Then Return True


    ;~ armor vs monster type
    If CheckModMonster($aShieldMods[$idx_mod_shield_armor_monster], $aMods) Then Return True

    ;~ Armor vs damage type
    If CheckModArmor($aShieldMods[$idx_mod_shield_armor_type], $aMods) Then Return True

    ;~ Reduced condition duration
    If CheckModCondition($aShieldMods[$idx_mod_shield_condition], $aMods) Then Return True

    ;~ +1^20% attribute mods
    If CheckModAttribute($aShieldMods[$idx_mod_shield_attribute], $aMods) Then Return True

    Return False
EndFunc ;==>CheckModShield

;~ parses the ModStruct of the shield and returns an array
Func ParseShieldMods(ByRef $sModStruct)
    Local $aShieldMods[$idx_mod_shield_size]

    Local $a30hp = GetModByIdentifier($sModStruct, '4823') ; 30hp
    $aShieldMods[$idx_mod_shield_30hp] = $a30hp[1]

    Local $a45ench = GetModByIdentifier($sModStruct, '6823') ; 45ench
    $aShieldMods[$idx_mod_shield_45ench] = $a45ench[1]
    
    Local $a45stance = GetModByIdentifier($sModStruct, '8823') ; 45stance
    $aShieldMods[$idx_mod_shield_45stance] = $a45stance[1]

    Local $a60hex = GetModByIdentifier($sModStruct, '7823') ; 60hex
    $aShieldMods[$idx_mod_shield_60hex] = $a60hex[1]

    $aShieldMods[$idx_mod_shield_2ench] = CheckModStruct($sModStruct, "02008820") ; -2ench
    $aShieldMods[$idx_mod_shield_2stance] = CheckModStruct($sModStruct, "0200A820") ; -2stance
    $aShieldMods[$idx_mod_shield_3hex] = CheckModStruct($sModStruct, "03009820") ; -3hex

    Local $aArmor = GetModByIdentifier($sModStruct, '1821') ; blunt/fire/etc
    If $aArmor[0] < 10 Then $aArmor[1] = -1
    $aShieldMods[$idx_mod_shield_armor_type] = $aArmor[1]

    $aShieldMods[$idx_mod_shield_armor_monster] = GetModArmorMonster($sModStruct) ; skeleton/demon/etc

    Local $aCondition = GetModByIdentifier($sModStruct, "7824") ; 20% blind/dazed/etc
    $aShieldMods[$idx_mod_shield_condition] = $aCondition[0]

    Local $aAttribute = GetModByIdentifier($sModStruct, "1824") ; +1^20% attribute
    If $aAttribute[0] < 20 Then $aAttribute[1] = -1
    $aShieldMods[$idx_mod_shield_attribute] = $aAttribute[1]

    Return $aShieldMods
EndFunc ;==>ParseShieldMods

Func CheckWeaponAttribute($iAttribute, ByRef $sAttributeList)
    Local $aAttributes = StringSplit($sAttributeList, ",", $STR_NOCOUNT)

    For $sAttribute In $aAttributes

        $sAttribute = StringStripWS($sAttribute, $STR_STRIPLEADING + $STR_STRIPTRAILING)

        If CheckAttribute($iAttribute, $sAttribute) Then Return True

    Next

    Return False
EndFunc ;==>CheckWeaponAttribute

;~ checks if item contains +30Hp
Func CheckMod30Hp($iHp, ByRef $aMods)
    If $iHp = -1 Then Return False

    For $sCurrendMod In $aMods

        Switch $sCurrendMod
            Case "30", "30hp"
                If $iHp >= 30 Then Return True
            Case "29", "29hp"
                If $iHp >= 29 Then Return True
            Case "28", "28hp"
                If $iHp >= 28 Then Return True
            Case "27", "27hp"
                If $iHp >= 27 Then Return True
        EndSwitch

    Next
    
    Return False
EndFunc ;==>CheckMod30Hp

;~ checks if item contains +45Hp^ench
Func CheckMod45Ench($iHp, ByRef $aMods)
    If $iHp = -1 Then Return False

    For $sCurrendMod In $aMods

        Switch $sCurrendMod
            Case "45ench"
                If $iHp >= 45 Then Return True
            Case "44ench"
                If $iHp >= 44 Then Return True
            Case "43ench"
                If $iHp >= 43 Then Return True
            Case "42ench"
                If $iHp >= 42 Then Return True
            Case "41ench"
                If $iHp >= 41 Then Return True
        EndSwitch

    Next
    
    Return False
EndFunc ;==>CheckMod45Ench

;~ checks if item contains +45Hp^stance
Func CheckMod45Stance($iHp, ByRef $aMods)
    If $iHp = -1 Then Return False

    For $sCurrendMod In $aMods

        Switch $sCurrendMod
            Case "45stance"
                If $iHp >= 45 Then Return True
            Case "44stance"
                If $iHp >= 44 Then Return True
            Case "43stance"
                If $iHp >= 43 Then Return True
            Case "42stance"
                If $iHp >= 42 Then Return True
            Case "41stance"
                If $iHp >= 41 Then Return True
        EndSwitch

    Next
    
    Return False
EndFunc ;==>CheckMod45Stance

;~ checks if item contains +60Hp^hex
Func CheckMod60Hex($iHp, ByRef $aMods)
    If $iHp = -1 Then Return False

    For $sCurrendMod In $aMods

        Switch $sCurrendMod
            Case "60hex"
                If $iHp >= 60 Then Return True
            Case "59hex"
                If $iHp >= 59 Then Return True
            Case "58hex"
                If $iHp >= 58 Then Return True
            Case "57hex"
                If $iHp >= 57 Then Return True
            Case "56hex"
                If $iHp >= 56 Then Return True
        EndSwitch

    Next
    
    Return False
EndFunc ;==>CheckMod60Hex

;~ checks if item contains +10 vsType (blunt/fire/etc)
Func CheckModArmor($iArmorType, ByRef $aMods)
    If $iArmorType = -1 Then Return False

    For $sCurrentMod In $aMods

        Switch $sCurrentMod
            Case "allarmor"
                Return True
            Case "blunt"
                If $iArmorType = 0x00 Then Return True
            Case "piercing"
                If $iArmorType = 0x01 Then Return True
            Case "slashing"
                If $iArmorType = 0x02 Then Return True
            Case "cold"
                If $iArmorType = 0x03 Then Return True
            Case "lightning"
                If $iArmorType = 0x04 Then Return True
            Case "fire"
                If $iArmorType = 0x05 Then Return True
            Case "earth"
                If $iArmorType = 0x0B Then Return True
        EndSwitch

    Next

    Return False                
EndFunc ;==>CheckModArmor

;~ checks if item contains 20% condition mod
Func CheckModCondition($iCondition, ByRef $aMods)
    If $iCondition = -1 Then Return False

    For $sCurrentMod In $aMods

        Switch $sCurrentMod
            Case "allcondition"
                Return True
            Case "bleeding"
                If $iCondition = 0xDE Then Return True
            Case "blind"
                If $iCondition = 0xDF Then Return True
            Case "cripple", "crippled"
                If $iCondition = 0xE1 Then Return True
            Case "deepwound"
                If $iCondition = 0xE2 Then Return True
            Case "disease"
                If $iCondition = 0xE3 Then Return True
            Case "poison"
                If $iCondition = 0xE4 Then Return True
            Case "daze", "dazed"
                If $iCondition = 0xE5 Then Return True
            Case "weakness"
                If $iCondition = 0xE6 Then Return True
        EndSwitch

    Next

    Return False
EndFunc ;==>CheckModCondition

;~ checks if item contains +1^20% attribute mod
Func CheckModAttribute($iAttribute, ByRef $aMods)
    If $iAttribute = -1 Then Return False

    For $sCurrentMod In $aMods

        If CheckAttribute($iAttribute, $sCurrentMod) Then Return True

    Next

    Return False
EndFunc ;==>CheckModAttribute

Func CheckAttribute(ByRef $iAttribute, ByRef $sAttribute)
    Switch $sAttribute
        Case "allattributes", "any"
            Return True
        Case "fastcasting", "fc"
            If $iAttribute = $GC_I_ATTRIBUTE_FAST_CASTING Then Return True
        Case "illusion", "illusionmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_ILLUSION_MAGIC Then Return True
        Case "domination", "dominationmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_DOMINATION_MAGIC Then Return True
        Case "inspiration", "inspirationmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_INSPIRATION_MAGIC Then Return True
        Case "blood", "bloodmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_BLOOD_MAGIC Then Return True
        Case "death", "deathmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_DEATH_MAGIC Then Return True
        Case "soulreaping", "sr"
            If $iAttribute = $GC_I_ATTRIBUTE_SOUL_REAPING Then Return True
        Case "curses"
            If $iAttribute = $GC_I_ATTRIBUTE_CURSES Then Return True
        Case "airmagic", "air"
            If $iAttribute = $GC_I_ATTRIBUTE_AIR_MAGIC Then Return True
        Case "earthmagic", "earth"
            If $iAttribute = $GC_I_ATTRIBUTE_EARTH_MAGIC Then Return True
        Case "firemagic", "fire"
            If $iAttribute = $GC_I_ATTRIBUTE_FIRE_MAGIC Then Return True
        Case "watermagic", "water"
            If $iAttribute = $GC_I_ATTRIBUTE_WATER_MAGIC Then Return True
        Case "energystorage", "es"
            If $iAttribute = $GC_I_ATTRIBUTE_ENERGY_STORAGE Then Return True
        Case "healing", "healingprayers"
            If $iAttribute = $GC_I_ATTRIBUTE_HEALING_PRAYERS Then Return True
        Case "smiting", "smitingprayers"
            If $iAttribute = $GC_I_ATTRIBUTE_SMITING_PRAYERS Then Return True
        Case "protection", "protectionprayers", "prot"
            If $iAttribute = $GC_I_ATTRIBUTE_PROTECTION_PRAYERS Then Return True
        Case "divinefavor", "df"
            If $iAttribute = $GC_I_ATTRIBUTE_DIVINE_FAVOR Then Return True
        Case "strength"
            If $iAttribute = $GC_I_ATTRIBUTE_STRENGTH Then Return True
        Case "axe", "axemastery"
            If $iAttribute = $GC_I_ATTRIBUTE_AXE_MASTERY Then Return True
        Case "hammer", "hammermastery"
            If $iAttribute = $GC_I_ATTRIBUTE_HAMMER_MASTERY Then Return True
        Case "sword", "swordsmanship"
            If $iAttribute = $GC_I_ATTRIBUTE_SWORDSMANSHIP Then Return True
        Case "tactics"
            If $iAttribute = $GC_I_ATTRIBUTE_TACTICS Then Return True
        Case "beastmastery"
            If $iAttribute = $GC_I_ATTRIBUTE_BEAST_MASTERY Then Return True
        Case "expertise"
            If $iAttribute = $GC_I_ATTRIBUTE_EXPERTISE Then Return True
        Case "wilderness", "wildernesssurvival"
            If $iAttribute = $GC_I_ATTRIBUTE_WILDERNESS_SURVIVAL Then Return True
        Case "marksmanship"
            If $iAttribute = $GC_I_ATTRIBUTE_MARKSMANSHIP Then Return True
        Case "dagger", "daggermastery"
            If $iAttribute = $GC_I_ATTRIBUTE_DAGGER_MASTERY Then Return True
        Case "deadlyarts", "deadly"
            If $iAttribute = $GC_I_ATTRIBUTE_DEADLY_ARTS Then Return True
        Case "shadowarts", "shadow"
            If $iAttribute = $GC_I_ATTRIBUTE_SHADOW_ARTS Then Return True
        Case "communing"
            If $iAttribute = $GC_I_ATTRIBUTE_COMMUNING Then Return True
        Case "restoration", "restorationmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_RESTORATION_MAGIC Then Return True
        Case "channeling", "channelingmagic"
            If $iAttribute = $GC_I_ATTRIBUTE_CHANNELING_MAGIC Then Return True
        Case "criticalstrikes", "cs"
            If $iAttribute = $GC_I_ATTRIBUTE_CRITICAL_STRIKES Then Return True
        Case "spawningpower", "sp"
            If $iAttribute = $GC_I_ATTRIBUTE_SPAWNING_POWER Then Return True
        Case "spear", "spearmastery"
            If $iAttribute = $GC_I_ATTRIBUTE_SPEAR_MASTERY Then Return True
        Case "command"
            If $iAttribute = $GC_I_ATTRIBUTE_COMMAND Then Return True
        Case "motivation"
            If $iAttribute = $GC_I_ATTRIBUTE_MOTIVATION Then Return True
        Case "leadership"
            If $iAttribute = $GC_I_ATTRIBUTE_LEADERSHIP Then Return True
        Case "scythe", "scythemastery"
            If $iAttribute = $GC_I_ATTRIBUTE_SCYTHE_MASTERY Then Return True
        Case "windprayers", "wind"
            If $iAttribute = $GC_I_ATTRIBUTE_WIND_PRAYERS Then Return True
        Case "earthprayers"
            If $iAttribute = $GC_I_ATTRIBUTE_EARTH_PRAYERS Then Return True
        Case "mysticism"
            If $iAttribute = $GC_I_ATTRIBUTE_MYSTICISM Then Return True
        Case Else
            Out("Unknown Attribute: " & $sAttribute)
    EndSwitch

    Return False
EndFunc ;==>CheckAttribute

;~ checks if item contains +10 vsMonster (demon/skeleton/etc)
Func CheckModMonster($iMonster, ByRef $aMods)
    If $iMonster == "" Then Return False

    For $sCurrentMod In $aMods

        Switch $sCurrentMod

            Case "allmonster"
                If $iMonster <> "" Then Return True

            Case "demon", "skeleton", "undead"
                If $iMonster == $sCurrentMod Then Return True

            Case "charr", "troll", "plant", "giant", "dwarf", "tengu",  "dragon", "ogre"
                If $iMonster == $sCurrentMod Then Return True

        EndSwitch

    Next

    Return False
EndFunc ;==>CheckModMonster

;~ checks if item contains +10 vsMonster
Func GetModArmorMonster(ByRef $sModStruct)
    Local $aMod = GetModByIdentifier($sModStruct, '4821')
    If $aMod[0] = -1 Or $aMod[1] = -1 Then Return ""

    If $aMod[0] < 10 Then Return "" ; not +10armor

    Return GetMonsterType($aMod[1])
EndFunc ;==>GetModArmorMonster

;~ returns string representing monster type
Func GetMonsterType($iMonsterID)
    Switch $iMonsterID
        Case 0
            Return "undead"
        Case 1
            Return "charr"
        Case 2
            Return "troll"
        Case 3
            Return "plant"
        Case 4
            Return "skeleton"
        Case 5
            Return "giant"
        Case 6
            Return "dwarf"
        Case 7
            Return "tengu"
        Case 8
            Return "demon"
        Case 9
            Return "dragon"
        Case 10
            Return "ogre"
    EndSwitch

    Return ""
EndFunc ;==>GetMonsterType
#EndRegion OS Filter