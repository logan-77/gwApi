#include-once

Global $g_mOffset

;~ Build offsets map from struct template
Func BuildOffsetMap($sStructTemplate)
    Local $mOffset[]
    Local $iOffset, $sType, $sName
    Local $sParts, $iCount

    Local $tStruct = DllStructCreate($sStructTemplate)
    Local $iBaseAddress = DllStructGetPtr($tStruct), $iFieldAddress

    Local $aFields = StringSplit($sStructTemplate, ';', 2)
    For $sField In $aFields
        $sField = StringStripWS($sField, 3)
        If $sField = '' Then ContinueLoop

        $sParts = StringSplit($sField, ' ', 2)
        $sType = $sParts[0]
        $sName = $sParts[1]

        ;~ handle arrays (for example wchar name[32])
        $iCount = StringInStr($sName, '[')
        If $iCount > 0 Then
            $sName = StringLeft($sName, $iCount - 1)
        EndIf

        $iFieldAddress = DllStructGetPtr($tStruct, $sName)
        $iOffset = Number($iFieldAddress) - Number($iBaseAddress)

        Local $mField[]
        $mField["offset"] = Int($iOffset)
        $mField["type"]   = String($sType)
        $mOffset[$sName] = $mField
    Next
    Return $mOffset
EndFunc ;==>BuildOffsetMap

$g_mOffset = BuildOffsetMap($GC_AGENT_STRUCT_TEMPLATE)

Global Const $GC_I_OFFSET_AGENT_VTABLE[]               = [$g_mOffset.vtable["offset"], $g_mOffset.vtable["type"]]
Global Const $GC_I_OFFSET_AGENT_H0004[]                = [$g_mOffset.h0004["offset"], $g_mOffset.h0004["type"]]
Global Const $GC_I_OFFSET_AGENT_TIMER[]                = [$g_mOffset.Timer["offset"], $g_mOffset.Timer["type"]]
Global Const $GC_I_OFFSET_AGENT_TIMER2[]               = [$g_mOffset.Timer2["offset"], $g_mOffset.Timer2["type"]]
Global Const $GC_I_OFFSET_AGENT_NEXT_AGENT[]           = [$g_mOffset.NextAgent["offset"], $g_mOffset.NextAgent["type"]]
Global Const $GC_I_OFFSET_AGENT_H0020                  = [$g_mOffset.h0020["offset"], $g_mOffset.h0020["type"]]
Global Const $GC_I_OFFSET_AGENT_ID[]                   = [$g_mOffset.ID["offset"], $g_mOffset.ID["type"]]
Global Const $GC_I_OFFSET_AGENT_Z[]                    = [$g_mOffset.Z["offset"], $g_mOffset.Z["type"]]
Global Const $GC_I_OFFSET_AGENT_WIDTH1[]               = [$g_mOffset.Width1["offset"], $g_mOffset.Width1["type"]]
Global Const $GC_I_OFFSET_AGENT_HEIGHT1[]              = [$g_mOffset.Height1["offset"], $g_mOffset.Height1["type"]]
Global Const $GC_I_OFFSET_AGENT_WIDTH2[]               = [$g_mOffset.Width2["offset"], $g_mOffset.Width2["type"]]
Global Const $GC_I_OFFSET_AGENT_HEIGHT2[]              = [$g_mOffset.Height2["offset"], $g_mOffset.Height2["type"]]
Global Const $GC_I_OFFSET_AGENT_WIDTH3[]               = [$g_mOffset.Width3["offset"], $g_mOffset.Width3["type"]]
Global Const $GC_I_OFFSET_AGENT_HEIGHT3[]              = [$g_mOffset.Height3["offset"], $g_mOffset.Height3["type"]]
Global Const $GC_I_OFFSET_AGENT_ROTATION[]             = [$g_mOffset.Rotation["offset"], $g_mOffset.Rotation["type"]]
Global Const $GC_I_OFFSET_AGENT_ROTATION_COS[]         = [$g_mOffset.RotationCos["offset"], $g_mOffset.RotationCos["type"]]
Global Const $GC_I_OFFSET_AGENT_ROTATION_SIN[]         = [$g_mOffset.RotationSin["offset"], $g_mOffset.RotationSin["type"]]
Global Const $GC_I_OFFSET_AGENT_NAME_PROPERTIES[]      = [$g_mOffset.NameProperties["offset"], $g_mOffset.NameProperties["type"]]
Global Const $GC_I_OFFSET_AGENT_GROUND[]               = [$g_mOffset.Ground["offset"], $g_mOffset.Ground["type"]]
Global Const $GC_I_OFFSET_AGENT_H0060[]                = [$g_mOffset.h0060["offset"], $g_mOffset.h0060["type"]]
Global Const $GC_I_OFFSET_AGENT_TERRAIN_NORMAL_X[]     = [$g_mOffset.TerrainNormalX["offset"], $g_mOffset.TerrainNormalX["type"]]
Global Const $GC_I_OFFSET_AGENT_TERRAIN_NORMAL_Y[]     = [$g_mOffset.TerrainNormalY["offset"], $g_mOffset.TerrainNormalY["type"]]
Global Const $GC_I_OFFSET_AGENT_TERRAIN_NORMAL_Z[]     = [$g_mOffset.TerrainNormalZ["offset"], $g_mOffset.TerrainNormalZ["type"]]
Global Const $GC_I_OFFSET_AGENT_H0070[]                = [$g_mOffset.h0070["offset"], $g_mOffset.h0070["type"]]
Global Const $GC_I_OFFSET_AGENT_X[]                    = [$g_mOffset.X["offset"], $g_mOffset.X["type"]]
Global Const $GC_I_OFFSET_AGENT_Y[]                    = [$g_mOffset.Y["offset"], $g_mOffset.Y["type"]]
Global Const $GC_I_OFFSET_AGENT_PLANE[]                = [$g_mOffset.Plane["offset"], $g_mOffset.Plane["type"]]
Global Const $GC_I_OFFSET_AGENT_H0080[]                = [$g_mOffset.h0080["offset"], $g_mOffset.h0080["type"]]
Global Const $GC_I_OFFSET_AGENT_NAMETAG_X[]            = [$g_mOffset.NameTagX["offset"], $g_mOffset.NameTagX["type"]]
Global Const $GC_I_OFFSET_AGENT_NAMETAG_Y[]            = [$g_mOffset.NameTagY["offset"], $g_mOffset.NameTagY["type"]]
Global Const $GC_I_OFFSET_AGENT_NAMETAG_Z[]            = [$g_mOffset.NameTagZ["offset"], $g_mOffset.NameTagZ["type"]]
Global Const $GC_I_OFFSET_AGENT_VISUAL_EFFECTS[]       = [$g_mOffset.VisualEffects["offset"], $g_mOffset.VisualEffects["type"]]
Global Const $GC_I_OFFSET_AGENT_H0092[]                = [$g_mOffset.h0092["offset"], $g_mOffset.h0092["type"]]
Global Const $GC_I_OFFSET_AGENT_H0094[]                = [$g_mOffset.h0094["offset"], $g_mOffset.h0094["type"]]
Global Const $GC_I_OFFSET_AGENT_TYPE[]                 = [$g_mOffset.Type["offset"], $g_mOffset.Type["type"]]
Global Const $GC_I_OFFSET_AGENT_MOVE_X[]               = [$g_mOffset.MoveX["offset"], $g_mOffset.MoveX["type"]]
Global Const $GC_I_OFFSET_AGENT_MOVE_Y[]               = [$g_mOffset.MoveY["offset"], $g_mOffset.MoveY["type"]]
Global Const $GC_I_OFFSET_AGENT_H00A8[]                = [$g_mOffset.h00A8["offset"], $g_mOffset.h00A8["type"]]
Global Const $GC_I_OFFSET_AGENT_ROTATION_COS2[]        = [$g_mOffset.RotationCos2["offset"], $g_mOffset.RotationCos2["type"]]
Global Const $GC_I_OFFSET_AGENT_ROTATION_SIN2[]        = [$g_mOffset.RotationSin2["offset"], $g_mOffset.RotationSin2["type"]]
Global Const $GC_I_OFFSET_AGENT_H00B4[]                = [$g_mOffset.h00B4["offset"], $g_mOffset.h00B4["type"]]
Global Const $GC_I_OFFSET_AGENT_OWNER[]                = [$g_mOffset.Owner["offset"], $g_mOffset.Owner["type"]]
Global Const $GC_I_OFFSET_AGENT_ITEM_ID[]              = [$g_mOffset.ItemID["offset"], $g_mOffset.ItemID["type"]]
Global Const $GC_I_OFFSET_AGENT_EXTRA_TYPE[]           = [$g_mOffset.ExtraType["offset"], $g_mOffset.ExtraType["type"]]
Global Const $GC_I_OFFSET_AGENT_GADGET_ID[]            = [$g_mOffset.GadgetID["offset"], $g_mOffset.GadgetID["type"]]
Global Const $GC_I_OFFSET_AGENT_H00D4[]                = [$g_mOffset.h00D4["offset"], $g_mOffset.h00D4["type"]]
Global Const $GC_I_OFFSET_AGENT_ANIMATION_TYPE[]       = [$g_mOffset.AnimationType["offset"], $g_mOffset.AnimationType["type"]]
Global Const $GC_I_OFFSET_AGENT_H00E4[]                = [$g_mOffset.h00E4["offset"], $g_mOffset.h00E4["type"]]
Global Const $GC_I_OFFSET_AGENT_ATTACK_SPEED[]         = [$g_mOffset.AttackSpeed["offset"], $g_mOffset.AttackSpeed["type"]]
Global Const $GC_I_OFFSET_AGENT_ATTACK_SPEED_MODIFIER[] = [$g_mOffset.AttackSpeedModifier["offset"], $g_mOffset.AttackSpeedModifier["type"]]
Global Const $GC_I_OFFSET_AGENT_MODEL_ID[]             = [$g_mOffset.ModelID["offset"], $g_mOffset.ModelID["type"]]
Global Const $GC_I_OFFSET_AGENT_AGENT_MODEL_TYPE[]     = [$g_mOffset.AgentModelType["offset"], $g_mOffset.AgentModelType["type"]]
Global Const $GC_I_OFFSET_AGENT_TRANSMOG_NPC_ID[]      = [$g_mOffset.TransmogNpcID["offset"], $g_mOffset.TransmogNpcID["type"]]
Global Const $GC_I_OFFSET_AGENT_EQUIPMENT[]            = [$g_mOffset.Equipment["offset"], $g_mOffset.Equipment["type"]]
Global Const $GC_I_OFFSET_AGENT_H0100[]                = [$g_mOffset.h0100["offset"], $g_mOffset.h0100["type"]]
Global Const $GC_I_OFFSET_AGENT_H0104[]                = [$g_mOffset.h0104["offset"], $g_mOffset.h0104["type"]]
Global Const $GC_I_OFFSET_AGENT_TAGS[]                 = [$g_mOffset.Tags["offset"], $g_mOffset.Tags["type"]]
Global Const $GC_I_OFFSET_AGENT_H010C[]                = [$g_mOffset.h010C["offset"], $g_mOffset.h010C["type"]]
Global Const $GC_I_OFFSET_AGENT_PRIMARY[]              = [$g_mOffset.Primary["offset"], $g_mOffset.Primary["type"]]
Global Const $GC_I_OFFSET_AGENT_SECONDARY[]            = [$g_mOffset.Secondary["offset"], $g_mOffset.Secondary["type"]]
Global Const $GC_I_OFFSET_AGENT_LEVEL[]                = [$g_mOffset.Level["offset"], $g_mOffset.Level["type"]]
Global Const $GC_I_OFFSET_AGENT_TEAM[]                 = [$g_mOffset.Team["offset"], $g_mOffset.Team["type"]]
Global Const $GC_I_OFFSET_AGENT_H0112[]                = [$g_mOffset.h0112["offset"], $g_mOffset.h0112["type"]]
Global Const $GC_I_OFFSET_AGENT_H0114[]                = [$g_mOffset.h0114["offset"], $g_mOffset.h0114["type"]]
Global Const $GC_I_OFFSET_AGENT_ENERGY_PIPS[]          = [$g_mOffset.EnergyPips["offset"], $g_mOffset.EnergyPips["type"]]
Global Const $GC_I_OFFSET_AGENT_OVERCAST[]             = [$g_mOffset.Overcast["offset"], $g_mOffset.Overcast["type"]]
Global Const $GC_I_OFFSET_AGENT_ENERGY_PERCENT[]       = [$g_mOffset.EnergyPercent["offset"], $g_mOffset.EnergyPercent["type"]]
Global Const $GC_I_OFFSET_AGENT_MAX_ENERGY[]           = [$g_mOffset.MaxEnergy["offset"], $g_mOffset.MaxEnergy["type"]]
Global Const $GC_I_OFFSET_AGENT_H0128[]                = [$g_mOffset.h0128["offset"], $g_mOffset.h0128["type"]]
Global Const $GC_I_OFFSET_AGENT_HP_PIPS[]              = [$g_mOffset.HPPips["offset"], $g_mOffset.HPPips["type"]]
Global Const $GC_I_OFFSET_AGENT_H0130[]                = [$g_mOffset.h0130["offset"], $g_mOffset.h0130["type"]]
Global Const $GC_I_OFFSET_AGENT_HP_PERCENT[]           = [$g_mOffset.HPPercent["offset"], $g_mOffset.HPPercent["type"]]
Global Const $GC_I_OFFSET_AGENT_MAX_HP[]               = [$g_mOffset.MaxHP["offset"], $g_mOffset.MaxHP["type"]]
Global Const $GC_I_OFFSET_AGENT_EFFECTS[]              = [$g_mOffset.Effects["offset"], $g_mOffset.Effects["type"]]
Global Const $GC_I_OFFSET_AGENT_H0140[]                = [$g_mOffset.h0140["offset"], $g_mOffset.h0140["type"]]
Global Const $GC_I_OFFSET_AGENT_HEX[]                  = [$g_mOffset.Hex["offset"], $g_mOffset.Hex["type"]]
Global Const $GC_I_OFFSET_AGENT_H0145[]                = [$g_mOffset.h0145["offset"], $g_mOffset.h0145["type"]]
Global Const $GC_I_OFFSET_AGENT_MODEL_STATE[]          = [$g_mOffset.ModelState["offset"], $g_mOffset.ModelState["type"]]
Global Const $GC_I_OFFSET_AGENT_TYPE_MAP[]             = [$g_mOffset.TypeMap["offset"], $g_mOffset.TypeMap["type"]]
Global Const $GC_I_OFFSET_AGENT_H0160[]                = [$g_mOffset.h0160["offset"], $g_mOffset.h0160["type"]]
Global Const $GC_I_OFFSET_AGENT_IN_SPIRIT_RANGE[]      = [$g_mOffset.InSpiritRange["offset"], $g_mOffset.InSpiritRange["type"]]
Global Const $GC_I_OFFSET_AGENT_VISIBLE_EFFECTS[]      = [$g_mOffset.VisibleEffects["offset"], $g_mOffset.VisibleEffects["type"]]
Global Const $GC_I_OFFSET_AGENT_VISIBLE_EFFECTS_ID[]   = [$g_mOffset.VisibleEffectsID["offset"], $g_mOffset.VisibleEffectsID["type"]]
Global Const $GC_I_OFFSET_AGENT_VISIBLE_EFFECTS_HAS_ENDED[] = [$g_mOffset.VisibleEffectsHasEnded["offset"], $g_mOffset.VisibleEffectsHasEnded["type"]]
Global Const $GC_I_OFFSET_AGENT_H0180[]                = [$g_mOffset.h0180["offset"], $g_mOffset.h0180["type"]]
Global Const $GC_I_OFFSET_AGENT_LOGIN_NUMBER[]         = [$g_mOffset.LoginNumber["offset"], $g_mOffset.LoginNumber["type"]]
Global Const $GC_I_OFFSET_AGENT_ANIMATION_SPEED[]      = [$g_mOffset.AnimationSpeed["offset"], $g_mOffset.AnimationSpeed["type"]]
Global Const $GC_I_OFFSET_AGENT_ANIMATION_CODE[]       = [$g_mOffset.AnimationCode["offset"], $g_mOffset.AnimationCode["type"]]
Global Const $GC_I_OFFSET_AGENT_ANIMATION_ID[]         = [$g_mOffset.AnimationID["offset"], $g_mOffset.AnimationID["type"]]
Global Const $GC_I_OFFSET_AGENT_H0194[]                = [$g_mOffset.h0194["offset"], $g_mOffset.h0194["type"]]
Global Const $GC_I_OFFSET_AGENT_LAST_STRIKE[]          = [$g_mOffset.LastStrike["offset"], $g_mOffset.LastStrike["type"]]
Global Const $GC_I_OFFSET_AGENT_ALLEGIANCE[]           = [$g_mOffset.Allegiance["offset"], $g_mOffset.Allegiance["type"]]
Global Const $GC_I_OFFSET_AGENT_WEAPON_TYPE[]          = [$g_mOffset.WeaponType["offset"], $g_mOffset.WeaponType["type"]]
Global Const $GC_I_OFFSET_AGENT_SKILL[]                = [$g_mOffset.Skill["offset"], $g_mOffset.Skill["type"]]
Global Const $GC_I_OFFSET_AGENT_H01BA[]                = [$g_mOffset.h01BA["offset"], $g_mOffset.h01BA["type"]]
Global Const $GC_I_OFFSET_AGENT_WEAPON_ITEM_TYPE[]     = [$g_mOffset.WeaponItemType["offset"], $g_mOffset.WeaponItemType["type"]]
Global Const $GC_I_OFFSET_AGENT_OFFHAND_ITEM_TYPE[]    = [$g_mOffset.OffhandItemType["offset"], $g_mOffset.OffhandItemType["type"]]
Global Const $GC_I_OFFSET_AGENT_WEAPON_ITEM_ID[]       = [$g_mOffset.WeaponItemID["offset"], $g_mOffset.WeaponItemID["type"]]
Global Const $GC_I_OFFSET_AGENT_OFFHAND_ITEM_ID[]      = [$g_mOffset.OffhandItemID["offset"], $g_mOffset.OffhandItemID["type"]]

$g_mOffset = 0