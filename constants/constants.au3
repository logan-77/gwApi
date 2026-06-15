#include-once
Global Enum $normalmode, $hardmode
Global Enum $instancetype_outpost, $instancetype_explorable, $instancetype_loading
Global Enum $east, $south_east, $south, $south_west, $west, $north_west, $north, $north_east

; === gold related ==
Global Const $mMaxGoldStorage = 1000000

Global Const $g_aWeaponType[] = [ _
    $GC_I_TYPE_AXE, $GC_I_TYPE_BOW, $GC_I_TYPE_OFFHAND, $GC_I_TYPE_HAMMER, _
    $GC_I_TYPE_WAND, $GC_I_TYPE_SHIELD, $GC_I_TYPE_STAFF, $GC_I_TYPE_SWORD, _
    $GC_I_TYPE_DAGGERS, $GC_I_TYPE_SCYTHE, $GC_I_TYPE_SPEAR]

; === Material ===
Global Const $model_id_bones  = 921
Global Const $model_id_cloth  = 925
Global Const $model_id_dust   = 929
Global Const $model_id_feather  = 933
Global Const $model_id_fiber  = 934
Global Const $model_id_tanned_hide = 940
Global Const $model_id_wood   = 946
Global Const $model_id_iron   = 948
Global Const $model_id_scales  = 953
Global Const $model_id_chitin  = 954
Global Const $model_id_granite  = 955

; === Rare Material ===
Global Const $model_id_charcoal     = 922
Global Const $model_id_monstrous_claw   = 923
Global Const $model_id_linen     = 926
Global Const $model_id_damask     = 927
Global Const $model_id_silk      = 928
Global Const $model_id_ecto      = 930
Global Const $model_id_monstrous_eye   = 931
Global Const $model_id_monstrous_fang   = 932
Global Const $model_id_diamond     = 935
Global Const $model_id_onyx      = 936
Global Const $model_id_ruby      = 937
Global Const $model_id_sapphire     = 938
Global Const $model_id_glass_vial    = 939
Global Const $model_id_fur_square    = 941
Global Const $model_id_leather_square   = 942
Global Const $model_id_elonian_leather_square = 943
Global Const $model_id_vial_of_ink    = 944
Global Const $model_id_obsidian_shard   = 945
Global Const $model_id_steel_ingot    = 949
Global Const $model_id_deldrimor_steel_ingot = 950
Global Const $model_id_roll_of_parchment  = 951
Global Const $model_id_roll_of_vellum   = 952
Global Const $model_id_spiritwood_plank   = 956
Global Const $model_id_amber_chunk    = 6532
Global Const $model_id_jadeite_shard   = 6533

; === Trophies ===
Global Const $model_id_shadowy_remnant = 441
Global Const $model_id_abnormal_seed = 442
Global Const $model_id_dark_remain  = 522
Global Const $model_id_dragon_root  = 819
Global Const $model_id_feathered_crest = 835
Global Const $model_id_skale_tooth  = 1603
Global Const $model_id_skale_claw  = 1604
Global Const $model_id_iboga_petal  = 19183
Global Const $model_id_skale_fin  = 19184
Global Const $model_id_drake_flesh  = 19185
Global Const $model_id_saurian_bones = 27035
Global Const $model_id_glacial_stone = 27047
Global Const $model_id_silver_bullion_coin = 1579

; === Kits ===
Global Const $model_id_salvage_kit   = 2992
Global Const $model_id_expert_salvage_kit = 2991
Global Const $model_id_superior_salvage_kit = 5900
Global Const $model_id_identification_kit   = 2989
Global Const $model_id_superior_identification_kit = 5899

; == Misc Mode's ==
Global Const $model_id_diessa_chalice = 24353
Global Const $model_id_golden_rin_relic = 24354
Global Const $model_id_mobstopper  = 32558
Global Const $model_id_captured_skeleton = 32559
Global Const $model_id_confessors_orders = 35123
Global Const $model_id_top_left_map_piece = 24629
Global Const $model_id_top_right_map_piece = 24630
Global Const $model_id_bottom_left_map_piece = 24631 
Global Const $model_id_bottom_right_map_piece = 24632
Global Const $model_id_margonite_gemstone = 21128
Global Const $model_id_stygian_gemstone = 21129
Global Const $model_id_titan_gemstone = 21130
Global Const $model_id_torment_gemstone = 21131
Global Const $model_id_zaishen_key  = 28517
Global Const $model_id_heros_strongbox = 36666
Global Const $model_id_copper_zaishen_coin = 31202
Global Const $model_id_silver_zaishen_coin = 31204

Global Const $model_id_ghost_in_the_box = 6368
Global Const $model_id_candy_cane_shard = 556
Global Const $model_id_victory_token = 18345
Global Const $model_id_lunar_token  = 21833
Global Const $model_id_wayfarers_mark = 37765
Global Const $model_id_tot_bag   = 28434

;~ WoC
Global Const $model_id_imperial_guard_lockbox = 30212
Global Const $model_id_imperial_guard_requisition_order = 29108
Global Const $model_id_ministerial_commendation = 36985
Global Const $model_id_imperial_guard_reinforcement_order = 30210
Global Const $model_id_tengu_support_flare = 30209
Global Const $model_id_seal_of_the_dragon_empire = 30211

;Hero IDs
Global Enum $hero_id_norgu = 1, $hero_id_goren, $hero_id_tahlkora, $hero_id_master, $hero_id_jin, _
            $hero_id_koss, $hero_id_dunkoro, $hero_id_sousuke, $hero_id_melonni, $hero_id_zhed, _
            $hero_id_morgahn, $hero_id_margrid, $hero_id_zenmai, $hero_id_olias, $hero_id_razah, _
            $hero_id_mox, $hero_id_keiran, $hero_id_jora, $hero_id_pyre, $hero_id_anton, _
            $hero_id_livia, $hero_id_hayda, $hero_id_kahmu, $hero_id_gwen, $hero_id_xandra, _
            $hero_id_vekk, $hero_id_ogden, $hero_id_mercenary_1, $hero_id_mercenary_2, $hero_id_mercenary_3, _
            $hero_id_mercenary_4, $hero_id_mercenary_5, $hero_id_mercenary_6, $hero_id_mercenary_7, $hero_id_mercenary_8, _
            $hero_id_miku , $hero_id_zei_ri

#Region All Skill Infos
; SKILL TYPES
Global $Stance = 3;
Global $Hex = 4;
Global $Spell = 5;
Global $Enchantment = 6;
Global $Signet = 7;
Global $Condition = 8;
Global $Well = 9;
Global $Skill = 10;
Global $Ward = 11;
Global $Glyph = 12;
Global $Attack = 14;
Global $Shout = 15;
Global $Preparation = 19;
Global $Trap = 21;
Global $Ritual = 22;
Global $ItemSpell = 24;
Global $WeaponSpell = 25;
Global $Chant = 27;
Global $EchoRefrain = 28;
Global $Disguise = 26;

; PROFESSIONS
Global Enum $prof_none, $prof_warrior, $prof_ranger, $prof_monk, $prof_necromancer, $prof_mesmer, $prof_elementalist, $prof_assassin, $prof_ritualist, $prof_paragon, $prof_dervish
Global $None = 0
Global $Warrior = 1
Global $Ranger = 2
Global $Monk = 3
Global $Necromancer = 4
Global $Mesmer = 5
Global $Elementalist = 6
Global $Assassin = 7
Global $Ritualist = 8
Global $Paragon = 9
Global $Dervish = 10

; === Range ===
Global Enum $range_adjacent   = 156,       $range_nearby    = 240,       $range_area    = 312,       $range_earshot   = 1000,        $range_spellcast   = 1085,        $range_spirit   = 2500,        $range_nature_ritual   = 3500,        $range_compass   = 5000
Global Enum $range_adjacent_2 = 156 * 156, $range_nearby_2  = 240 * 240, $range_area_2  = 312 * 312, $range_earshot_2 = 1000 * 1000, $range_spellcast_2 = 1085 * 1085, $range_spirit_2 = 2500 * 2500, $range_nature_ritual_2 = 3500 * 3500, $range_compass_2 = 5000 * 5000

;TypeMap
Global Const $typemap_boss    = 3072  ; 0xC00  Boss
Global Const $typemap_boss2    = 3073  ; 0xC01  Boss with higher drop rate
Global Const $typemap_deadboss   = 3080  ; 0xC08  Boss when dead
Global Const $typemap_ally    = 131072 ; 0x20000 Ally
Global Const $typemap_ally2    = 131073 ; 0x20001  Ally when targeted
Global Const $typemap_spawned_enemy  = 262144 ; 0x40000 Enemy spawned creatures or hero defensive binding rituals
Global Const $typemap_spawned_ally  = 393216 ; 0x60000 Allied spawned creatures - SoS, Bloodsong
Global Const $typemap_vampiric_spirit = 393224 ; 0x60008 Allied spawned creatures - Vampiric Spirit
#EndRegion All Skill Infos

#Region Map Districts - Languages
; Region
Global Const $GC_REGION_INTERNATIONAL = -2
Global Const $GC_REGION_AMERICA = 0
Global Const $GC_REGION_KOREA = 1
Global Const $GC_REGION_EUROPE = 2
Global Const $GC_REGION_CHINA = 3
Global Const $GC_REGION_JAPAN = 4

; Languages
Global Const $GC_LANGUAGE_ENGLISH = 0  ; always used for $International, $Asia_Korean, $Asia_Chinese, $Asia_Japanese
Global Const $GC_LANGUAGE_FRENCH = 2
Global Const $GC_LANGUAGE_GERMAN = 3
Global Const $GC_LANGUAGE_ITALIAN = 4
Global Const $GC_LANGUAGE_SPANISH = 5
Global Const $GC_LANGUAGE_POLISH = 9
Global Const $GC_LANGUAGE_RUSSIAN = 10

Global Const $g_aRegion[12] = [ $GC_REGION_EUROPE, $GC_REGION_EUROPE, $GC_REGION_EUROPE, $GC_REGION_EUROPE, $GC_REGION_EUROPE, $GC_REGION_EUROPE, _
                                $GC_REGION_EUROPE, $GC_REGION_AMERICA, $GC_REGION_INTERNATIONAL, $GC_REGION_KOREA, $GC_REGION_CHINA, $GC_REGION_JAPAN ]
Global Const $g_aLanguage[12] = [ $GC_LANGUAGE_ENGLISH, $GC_LANGUAGE_FRENCH, $GC_LANGUAGE_GERMAN, $GC_LANGUAGE_ITALIAN, $GC_LANGUAGE_SPANISH, $GC_LANGUAGE_POLISH, _
                                  $GC_LANGUAGE_RUSSIAN, $GC_LANGUAGE_ENGLISH, $GC_LANGUAGE_ENGLISH, $GC_LANGUAGE_ENGLISH, $GC_LANGUAGE_ENGLISH, $GC_LANGUAGE_ENGLISH ]

;~ used by RndTravel
Global Enum $dis_english, $dis_french, $dis_german, $dis_italian, $dis_spanish, $dis_polish, $dis_russian, _
            $dis_american, $dis_international, $dis_korea, $dis_china, $dis_japan, _
            $dis_europe, $dis_europe_no_english, $dis_int_american, $dis_asia, $dis_all, $dis_enum_size
#EndRegion Map Districts - Languages

#Region MapID
; === Map IDs ===
Global Const $map_id_the_black_curtain = 18
Global Const $map_id_the_fissure_of_woe = 34
Global Const $map_id_the_underworld = 72
Global Const $map_id_house_zu_heltzer = 77
Global Const $map_id_temple_of_the_ages = 138
Global Const $map_id_cavalon = 193
Global Const $map_id_drazach_thicket = 195
Global Const $map_id_jaya_bluffs = 196
Global Const $map_id_great_temple_of_balthazar = 248
Global Const $map_id_seitung_harbor = 250
Global Const $map_id_isle_of_the_nameless = 280
Global Const $map_id_maatu_keep = 283
Global Const $map_id_the_marketplace = 303
Global Const $map_id_saoshang_trail = 313
Global Const $map_id_saint_anjekas_shrine = 349
Global Const $map_id_yohlon_haven = 381
Global Const $map_id_the_floodplain_of_mahnkelon = 384
Global Const $map_id_chantry_of_secrets = 393
Global Const $map_id_rilohn_refuge = 425
Global Const $map_id_moddok_crevice = 427
Global Const $map_id_plains_of_jarin = 430
Global Const $map_id_kamadan = 449
Global Const $map_id_kamadan_wintersday = 819
Global Const $map_id_gate_of_anguish = 474 ; explorable and outpost
Global Const $map_id_champions_dawn = 479
Global Const $map_id_fahranur = 481
Global Const $map_id_bjora_marches = 482
Global Const $map_id_zehlon_reach = 483
Global Const $map_id_jokanur_diggings = 491
Global Const $map_id_blacktide_den = 492
Global Const $map_id_riven_earth = 501
Global Const $map_id_the_astralarium = 502
Global Const $map_id_jaga_moraine = 546
Global Const $map_id_cathedral_of_flames = 560
Global Const $map_id_rata_sum = 640
Global Const $map_id_eye_of_the_north = 642
Global Const $map_id_eye_of_the_north_wintersday = 821
Global Const $map_id_hall_of_monuments = 646
Global Const $map_id_doomlore_shrine = 648
Global Const $map_id_longeyes_ledge = 650
Global Const $map_id_snowman_dungeon = 782 ; check name
Global Const $map_id_lions_arch = 808
Global Const $map_id_lions_arch_wintersday = 809
Global Const $map_id_shing_jea_monastery = 816
Global Const $map_id_auspicious_beginnings = 849
Global Const $map_id_embark_beach = 857

Global Const $map_id_heros_ascent = 330 ; outpost and explorable
Global Const $map_id_ha_underworld = 84
Global Const $map_id_ha_fetid_river = 593
Global Const $map_id_ha_burial_mounds = 80
Global Const $map_id_ha_unholy_temples = 79
Global Const $map_id_ha_forgotten_shrines = 596
Global Const $map_id_ha_golden_gates = 126
Global Const $map_id_ha_the_courtyard = 78
Global Const $map_id_ha_the_antechamber = 598
Global Const $map_id_ha_the_hall_of_heroes = 75
Global Const $map_id_jade_quarry_luxon = 295
Global Const $map_id_jade_quarry_kurzick = 296
Global Const $map_id_jade_quarry_arena = 223
#EndRegion MapID

; === Specific ItemID's ===
Global Const $model_id_keirans_bow = 35829
Global Const $model_id_balthazars_shortbow = 37866
Global Const $model_id_balthazars_flatbow = 37862
Global Const $model_id_bramble_shortbow = 957
Global Const $model_id_bramble_longbow = 868
Global Const $model_id_bramble_hornbow = 906
Global Const $model_id_bramble_flatbow = 904
Global Const $model_id_ornate_shield = 954
Global Const $model_id_gothic_defender = 951
Global Const $model_id_runic_axe = 753
Global Const $model_id_gothic_dual_axe = 749
Global Const $model_id_gothic_axe = 748
Global Const $model_id_gothic_sword = 793
Global Const $model_id_jug = 1023

#Region TraderCoords
Global Const $aXYBaseEotn = [-2680, 1212]
Global Const $aXYMerchantEotn = [-2748, 1019] ; same for wintersday
Global Const $aXYMaterialTraderEotn = [-1867, 803] ; same for wintersday
Global Const $aXYRareMaterialTraderEotn = [-2079, 1046] ; same for wintersday
Global Const $aXYRuneTraderEotn = [-3368, 2092]
Global Const $aXYRuneTraderEotnWintersday = [-3018, 1753]

Global Const $aXYBaseSifhalla = [11800, 23090]
Global Const $aXYMerchantSifhalla = [11580, 21619]
Global Const $aXYMaterialTraderSifhalla = [11489, 22240]
Global Const $aXYRareMaterialTraderSifhalla = [10875, 22596]
Global Const $aXYRuneTraderSifhalla = [11240, 22573]
#EndRegion TraderCoords

#Region Weapons
Global Enum $item_req, $item_min_dmg, $item_max_dmg

Global Const $g_aAxeMaxStats[][] = [ _
    [9, 6, 28], [8, 6, 27], [7, 6, 25], [6, 6, 24], [5, 6, 22], [4, 6, 19], [3, 6, 17], [2, 6, 14], [1, 6, 12], [0, 6, 12]]

Global Const $g_aBowMaxStats[][] = [ _
    [9, 15, 28], [8, 14, 27], [7, 14, 25], [6, 14, 24], [5, 13, 22], [4, 12, 20], [3, 11, 18], [2, 10, 16], [1, 9, 14], [0, 9, 13]]

Global Const $g_aOffhandMaxStats[][] = [ _
    [9, 6, 12], [8, 6, 12], [7, 0, 11], [6, 0, 11], [5, 0, 10], [4, 0, 9], [3, 0, 8], [2, 0, 7], [1, 0, 6], [0, 0, 6]]

Global Const $g_aHammerMaxStats[][] = [ _
    [9, 19, 35], [8, 18, 34], [7, 18, 32], [6, 17, 30], [5, 16, 28], [4, 15, 24], [3, 14, 22], [2, 12, 19], [1, 11, 16], [0, 11, 15]]

Global Const $g_aWandMaxStats[][] = [ _
    [9, 11, 22], [8, 11, 21], [7, 11, 20], [6, 11, 19], [5, 10, 18], [4, 10, 16], [3, 9, 14], [2, 8, 13], [1, 7, 11], [0, 7, 11]]

Global Const $g_aShieldMaxStats[][] = [ _
    [9, 8, 16], [8, 8, 16], [7, 0, 15], [6, 0, 14], [5, 0, 13], [4, 0, 12], [3, 0, 11], [2, 0, 10], [1, 0, 9], [0, 0, 8]]

Global Const $g_aStaffMaxStats[][] = [ _
    [9, 11, 22], [8, 11, 21], [7, 11, 20], [6, 10, 19], [5, 10, 18], [4, 10, 16], [3, 9, 14], [2, 8, 13], [1, 7, 11], [0, 7, 11]]

Global Const $g_aSwordMaxStats[][] = [ _
    [9, 15, 22], [8, 15, 22], [7, 14, 20], [6, 14, 19], [5, 13, 18], [4, 12, 16], [3, 11, 14], [2, 9, 13], [1, 8, 11], [0, 8, 10]]

Global Const $g_aDaggerMaxStats[][] = [ _
    [9, 7, 17], [8, 7, 16], [7, 7, 15], [6, 7, 14], [5, 6, 13], [4, 6, 12], [3, 5, 11], [2, 5, 9], [1, 4, 8], [0, 4, 8]]

Global Const $g_aScytheMaxStats[][] = [ _
    [9, 9, 41], [8, 9, 40], [7, 9, 36], [6, 9, 35], [5, 9, 32], [4, 9, 28], [3, 9, 24], [2, 9, 21], [1, 8, 18], [0, 8, 16]] ; [0, 8, 17]

Global Const $g_aSpearMaxStats[][] = [ _
    [9, 14, 27], [8, 14, 26], [7, 13, 25], [6, 13, 23], [5, 12, 21], [4, 12, 19], [3, 11, 17], [2, 10, 15], [1, 8, 13], [0, 8, 12]]
#EndRegion Weapons
