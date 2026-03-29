#include-once
#cs 
    Contains all Structs GW uses.
    Also custom partial structs.
#ce

;~ complete agent struct
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