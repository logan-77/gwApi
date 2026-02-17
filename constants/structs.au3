#include-once
#cs 
    Contains all Structs GW uses.
    Also custom partial structs.
#ce

;~ complete agent struct
Global Const $GC_AGENT_STRUCT_TEMPLATE = _
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