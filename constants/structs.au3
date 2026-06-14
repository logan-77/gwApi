#include-once
#cs 
    Contains all Structs GW uses.
#ce

;~ agent struct, size = 452 / 0x1C4 (probably incomplete)
Global Const $AGENT_STRUCT_TEMPLATE = _
'ptr vtable;                    dword h0004[4];         dword Timer;            dword Timer2;'              & _
'ptr NextAgent;                 dword h0020[3];         long ID;                float Z;'                   & _
'float Width1;                  float Height1;          float Width2;           float Height2;'             & _
'float Width3;                  float Height3;          float Rotation;         float RotationCos;'         & _
'float RotationSin;             dword NameProperties;   dword Ground;           dword h0060;'               & _
'float TerrainNormalX;          float TerrainNormalY;   dword TerrainNormalZ;   byte h0070[4];'             & _
'float X;                       float Y;                dword Plane;            byte h0080[4];'             & _
'float NameTagX;                float NameTagY;         float NameTagZ;'                                    & _
'short VisualEffects;           short h0092;            dword h0094[2];         long Type;'                 & _
'float MoveX;                   float MoveY;            dword h00A8;            float RotationCos2;'        & _
'float RotationSin2;            dword h00B4[4];         long Owner;'                                        & _
'dword ItemID;                  dword ExtraType;        dword GadgetID;         dword h00D4[3];'            & _
'float AnimationType;           dword h00E4[2];         float AttackSpeed;      float AttackSpeedModifier;' & _
'short ModelID;                 short AgentModelType;   dword TransmogNpcID;    ptr Equipment;'             & _
'dword h0100;                   dword h0104;            ptr Tags;               short h010C;'               & _
'byte Primary;                  byte Secondary;         byte Level;             byte Team;'                 & _
'byte h0112[2];                 dword h0114;'                                                               & _
'float EnergyPips;              float Overcast;         float EnergyPercent;    dword MaxEnergy;'           & _
'dword h0128;                   float HPPips;           dword h0130;            float HPPercent;'           & _
'dword MaxHP;                   dword Effects;          dword h0140;'                                       & _
'byte Hex;                      byte h0145[19];         dword ModelState;       dword TypeMap;'             & _
'dword h0160[4];                dword InSpiritRange;    dword VisibleEffects;   dword VisibleEffectsID;'    & _
'dword VisibleEffectsHasEnded;  dword h0180;            dword LoginNumber;      float AnimationSpeed;'      & _
'dword AnimationCode;           dword AnimationID;      byte h0194[32];         byte LastStrike;'           & _
'byte Allegiance;               short WeaponType;       short Skill;            short h01BA;'               & _
'byte WeaponItemType;           byte OffhandItemType;   short WeaponItemID;     short OffhandItemID;'

Global Const $IDX_AGENT_ID = 7
Global Const $IDX_AGENT_X = 25
Global Const $IDX_AGENT_Y = 26
Global Const $IDX_AGENT_MOVEX = 36
Global Const $IDX_AGENT_MOVEY = 37
Global Const $IDX_AGENT_ENERGYPERCENT = 67
Global Const $IDX_AGENT_MAXENERGY = 68
Global Const $IDX_AGENT_HPPERCENT = 72
Global Const $IDX_AGENT_MAXHP = 73
Global Const $IDX_AGENT_EFFECTS = 74
Global Const $IDX_AGENT_LOGINNUMBER = 86
Global Const $IDX_AGENT_ALLEGIANCE = 92
Global Const $IDX_AGENT_SKILL = 94

Global $g_tAgentStruct = DllStructCreate($AGENT_STRUCT_TEMPLATE)
Global $g_iAgentStructSize = DllStructGetSize($g_tAgentStruct)


;~ effect struct, size = 24 / 0x18
Global Const $EFFECT_STRUCT_TEMPLATE = _
'long SkillID;      dword AttributeLevel;' & _
'long EffectID;     dword CasterID;' & _
'float Duration;    dword Timestamp'

Global Const $GC_EFFECT_STRUCT_SIZE = 0x18

Global $g_tEffectStruct = DllStructCreate($EFFECT_STRUCT_TEMPLATE)
Global $g_iEffectStructSize = DllStructGetSize($g_tEffectStruct)

;~ effect count and pointer to the effect array of player or hero
Global $g_tEffectArray = DllStructCreate( _
    "ptr EffectArray; dword _padding; long EffectArraySize")
Global $g_iEffectArrayStructSize = DllStructGetSize($g_tEffectArray)


;~ skillbar struct, size = 188 / 0xBC
Global Const $SKILLBAR_STRUCT_TEMPLATE = _
'long AgentID;' & _
'dword AdrenalineA1; dword AdrenalineB1; dword Recharge1; dword SkillID1; dword Event1;' & _
'dword AdrenalineA2; dword AdrenalineB2; dword Recharge2; dword SkillID2; dword Event2;' & _
'dword AdrenalineA3; dword AdrenalineB3; dword Recharge3; dword SkillID3; dword Event3;' & _
'dword AdrenalineA4; dword AdrenalineB4; dword Recharge4; dword SkillID4; dword Event4;' & _
'dword AdrenalineA5; dword AdrenalineB5; dword Recharge5; dword SkillID5; dword Event5;' & _
'dword AdrenalineA6; dword AdrenalineB6; dword Recharge6; dword SkillID6; dword Event6;' & _
'dword AdrenalineA7; dword AdrenalineB7; dword Recharge7; dword SkillID7; dword Event7;' & _
'dword AdrenalineA8; dword AdrenalineB8; dword Recharge8; dword SkillID8; dword Event8;' & _
'dword Disabled;     dword h00A8[2];     dword Casting;   dword h00B4;    dword Queued;'

Global $g_tSkillbarStruct = DllStructCreate($SKILLBAR_STRUCT_TEMPLATE)
Global $g_iSkillbarStructSize = DllStructGetSize($g_tSkillbarStruct)


;~ bag struct, size = 36 / 0x24 (probably complete)
Global Const $BAG_STRUCT_TEMPLATE = _
'dword BagType;         dword Index;        dword BagID;'   & _
'dword ContainerItem;   dword ItemCount;    ptr BagArray;'  & _
'ptr ItemArray;         long FakeSlots;     dword Slots;'

Global $g_tBagStruct = DllStructCreate($BAG_STRUCT_TEMPLATE)
Global $g_iBagStructSize = DllStructGetSize($g_tBagStruct)

;~ BagType: 1=IsInventoryBag, 2=IsEquipped, 3=IsNotCollected, 4=IsStorage, 5=IsMaterialStorage


;~ item struct, size = 84 / 0x54 (probably complete)
Global Const $ITEM_STRUCT_TEMPLATE = _
'dword ID;          dword AgentID;      ptr BagEquipped;    ptr BagPtr;'            & _
'ptr ModStruct;     dword ModStructSize;ptr Customized;     dword ModelFileID;'     & _
'byte Type;         byte Dye1;          byte ExtraID;       byte Dye3;'             & _
'short Value;       short h0026;        dword Interaction;  dword ModelID;'         & _
'ptr InfoString;    ptr Name;           ptr CompleteName;   ptr SingleItemName;'    & _
'long h0040[2];     short ItemFormula;  byte IsSalvageable; byte h004B;'            & _
'short Quantity;    byte Equipped;      byte Profession;    byte Slot;'

Global $g_tItemStruct = DllStructCreate($ITEM_STRUCT_TEMPLATE)
Global $g_iItemStructSize = DllStructGetSize($g_tItemStruct)


;~ inventory struct
Global Const $INVENTORY_STRUCT_TEMPLATE = _
"dword h0000;" & _
"ptr Backpack;          ptr BeltPouch;          ptr Bag1;                   ptr Bag2;"                          & _
"ptr EquipmentPack;     ptr MaterialStorage;    ptr UnclaimedItems;"                                        & _
"ptr Storage1;          ptr Storage2;           ptr Storage3;           ptr Storage4;   ptr Storage5;"      & _
"ptr Storage6;          ptr Storage7;           ptr Storage8;           ptr Storage9;   ptr Storage10;"     & _
"ptr Storage11;         ptr Storage12;          ptr Storage13;          ptr Storage14;  ptr EquippedItems;" & _
"ptr Bundle;            ptr h0060;"             & _
"ptr WeaponSet0Weapon;  ptr WeaponSet0Offhand;" & _
"ptr WeaponSet1Weapon;  ptr WeaponSet1Offhand;" & _
"ptr WeaponSet2Weapon;  ptr WeaponSet2Offhand;" & _
"ptr WeaponSet3Weapon;  ptr WeaponSet3Offhand;" & _
"long ActiveWeaponSet;"                         & _
"dword h0088;           dword h008C;"           & _
"dword GoldCharacter;   dword GoldStorage;"

Global $g_tInventoryStruct = DllStructCreate($INVENTORY_STRUCT_TEMPLATE)
Global $g_iInventoryStructSize = DllStructGetSize($g_tInventoryStruct)
