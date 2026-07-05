#include-once
Global Enum $normalmode, $hardmode
Global Enum $east, $south_east, $south, $south_west, $west, $north_west, $north, $north_east

; === gold related ==
Global Const $iMaxGoldStorage = 1000000

Global Const $g_aWeaponType[] = [ _
    $GC_I_TYPE_AXE, $GC_I_TYPE_BOW, $GC_I_TYPE_OFFHAND, $GC_I_TYPE_HAMMER, _
    $GC_I_TYPE_WAND, $GC_I_TYPE_SHIELD, $GC_I_TYPE_STAFF, $GC_I_TYPE_SWORD, _
    $GC_I_TYPE_DAGGERS, $GC_I_TYPE_SCYTHE, $GC_I_TYPE_SPEAR _
]

;~ Distance constants
Global Const $g_iDistAdjacent    = 156
Global Const $g_iDistAdjacentSqr  = 156 * 156

Global Const $g_iDistNearby      = 240
Global Const $g_iDistNearbySqr    = 240 * 240

Global Const $g_iDistArea        = 312
Global Const $g_iDistAreaSqr      = 312 * 312

Global Const $g_iDistEarshot     = 1000
Global Const $g_iDistEarshotSqr   = 1000 * 1000

Global Const $g_iDistSpirit      = 2500
Global Const $g_iDistSpiritSqr    = 2500 * 2500

Global Const $g_iDistNatureRitual   = 3500
Global Const $g_iDistNatureRitualSqr = 3500 * 3500

Global Const $g_iDistCompass     = 5000
Global Const $g_iDistCompassSqr   = 5000 * 5000

Global Const $g_iDist50    = 50
Global Const $g_iDist50Sqr = 50 * 50

Global Const $g_iDist100    = 100
Global Const $g_iDist100Sqr = 100 * 100

Global Const $g_iDist150    = 150
Global Const $g_iDist150Sqr = 150 * 150

Global Const $g_iDist200    = 200
Global Const $g_iDist200Sqr = 200 * 200

Global Const $g_iDist250    = 250
Global Const $g_iDist250Sqr = 250 * 250

Global Const $g_iDist500    = 500
Global Const $g_iDist500Sqr = 500 * 500

Global Const $g_iDist750    = 750
Global Const $g_iDist750Sqr = 750 * 750

Global Const $g_iDist800    = 800
Global Const $g_iDist800Sqr = 800 * 800

Global Const $g_iDist850    = 850
Global Const $g_iDist850Sqr = 850 * 850

Global Const $g_iDist900    = 900
Global Const $g_iDist900Sqr = 900 * 900

Global Const $g_iDist950    = 950
Global Const $g_iDist950Sqr = 950 * 950

Global Const $g_iDist1000    = 1000
Global Const $g_iDist1000Sqr = 1000 * 1000

Global Const $g_iDistSpellcast   = 1085
Global Const $g_iDistSpellcastSqr = 1085 * 1085

Global Const $g_iDist1200    = 1200
Global Const $g_iDist1200Sqr = 1200 * 1200

Global Const $g_iDist1250    = 1250
Global Const $g_iDist1250Sqr = 1250 * 1250

Global Const $g_iDistAggro       = 1250
Global Const $g_iDistAggroSqr     = 1250 * 1250

;~ Timeout constants
Global Const $g_iSec1 = 1000*1
Global Const $g_iSec2 = 1000*2
Global Const $g_iSec3 = 1000*3
Global Const $g_iSec4 = 1000*4
Global Const $g_iSec5 = 1000*5
Global Const $g_iSec10 = 1000*10
Global Const $g_iSec15 = 1000*15
Global Const $g_iSec20 = 1000*20
Global Const $g_iSec25 = 1000*25
Global Const $g_iSec30 = 1000*30
Global Const $g_iSec35 = 1000*35
Global Const $g_iSec40 = 1000*40
Global Const $g_iSec45 = 1000*45
Global Const $g_iSec50 = 1000*50
Global Const $g_iSec55 = 1000*55

Global Const $g_iMin1 = 1000*60
Global Const $g_iMin2 = 1000*60*2
Global Const $g_iMin3 = 1000*60*3
Global Const $g_iMin4 = 1000*60*4
Global Const $g_iMin5 = 1000*60*5
Global Const $g_iMin6 = 1000*60*6
Global Const $g_iMin7 = 1000*60*7
Global Const $g_iMin8 = 1000*60*8
Global Const $g_iMin9 = 1000*60*9
Global Const $g_iMin10 = 1000*60*10
Global Const $g_iMin15 = 1000*60*15
Global Const $g_iMin20 = 1000*60*20
Global Const $g_iMin25 = 1000*60*25
Global Const $g_iMin30 = 1000*60*30

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

;~ used by RndTravel
Global Enum $dis_english, $dis_french, $dis_german, $dis_italian, $dis_spanish, $dis_polish, $dis_russian, _
            $dis_american, $dis_international, $dis_korea, $dis_china, $dis_japan, _
            $dis_europe, $dis_europe_no_english, $dis_int_american, $dis_asia, $dis_all, $dis_enum_size

#Region NPC XY
Global Enum _
    $OUTPOST_MAPID, _
    $OUTPOST_BASE, _
    $OUTPOST_MERCHANT, _
    $OUTPOST_MATERIAL, _
    $OUTPOST_RAREMAT, _
    $OUTPOST_RUNE

Global Const $aOutpostEotN[][] = [ _
    [$GC_I_MAP_ID_EYE_OF_THE_NORTH_OUTPOST, $GC_I_MAP_ID_EYE_OF_THE_NORTH_OUTPOST], _ ; MapID
    [-2680, 1212], _ ; Base
    [-2748, 1019], _ ; Merchant
    [-1867, 803], _ ; Material Trader
    [-2079, 1046], _ ; Rare Material Trader
    [-3368, 2092] _ ; Rune Trader
]

Global Const $aOutpostEotNWintersday[][] = [ _
    [$GC_I_MAP_ID_EYE_OF_THE_NORTH_OUTPOST_WINTERSDAY, $GC_I_MAP_ID_EYE_OF_THE_NORTH_OUTPOST_WINTERSDAY], _ ; MapID
    [-2680, 1212], _ ; Base
    [-2748, 1019], _ ; Merchant
    [-1867, 803], _ ; Material Trader
    [-2079, 1046], _ ; Rare Material Trader
    [-3018, 1753] _ ; Rune Trader (Wintersday)
]

Global Const $aOutpostSifhalla[][] = [ _
    [$GC_I_MAP_ID_SIFHALLA, $GC_I_MAP_ID_SIFHALLA], _ ; MapID
    [11800, 23090], _ ; Base
    [11580, 21619], _ ; Merchant
    [11489, 22240], _ ; Material Trader
    [10875, 22596], _ ; Rare Material Trader
    [11240, 22573] _ ; Rune Trader
]

Global Const $aOutpostSeitung[][] = [ _
    [$GC_I_MAP_ID_SEITUNG_HARBOR, $GC_I_MAP_ID_SEITUNG_HARBOR], _ ; MapID
    [17000, 12450], _ ; Base
    [17290, 12426], _ ; Merchant
    [17520, 13805], _ ; Material Trader
    [17709, 13868], _ ; Rare Material Trader
    [16412, 12619] _ ; Rune Trader
]
#EndRegion NPC XY

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

#Region Item ModelID
;~ new anniversary weapons
Global Const $model_id_lesser_stoneblade = 1955 ; eotn only
Global Const $model_id_greater_stoneblade = 1956 ; eotn only
Global Const $model_id_scorpions_bow = 2008
Global Const $model_id_scorpions_lust = 2009 ; all
Global Const $model_id_black_hawks_lust = 2010 ; all
Global Const $model_id_ithas_bow = 2011 ; tyria only

Global Const $model_id_chimeric_prism_fastcasting = 2012 ; tyria only
Global Const $model_id_chimeric_prism_soul_reaping = 2013 ; ???????????????????????????????????????
Global Const $model_id_chimeric_prism_energy_storage = 2014 ; tyria only
Global Const $model_id_chimeric_prism_divine_favor = 2015 ; tyria only
Global Const $model_id_chimeric_prism_spawning_power = 2016 ; ???????????????????????????????????????

Global Const $model_id_bone_idol_soul_reaping = 2017 ; tyria only
Global Const $model_id_bone_idol_blood_magic = 2018 ; tyria only
Global Const $model_id_bone_idol_curses = 2019 ; tyria only
Global Const $model_id_bone_idol_death_magic = 2020  ; tyria only

Global Const $model_id_storm_ember_air_magic = 2021 ; all
Global Const $model_id_storm_ember_earth_magic = 2022 ; all
Global Const $model_id_storm_ember_energy_storage = 2023 ; all
Global Const $model_id_storm_ember_fire_magic = 2024 ; all
Global Const $model_id_storm_ember_water_magic = 2025 ; all

Global Const $model_id_lions_pride_air_magic = 2026 ; all
Global Const $model_id_lions_pride_earth_magic = 2027 ; all
Global Const $model_id_lions_pride_energy_storage = 2028 ; all
Global Const $model_id_lions_pride_fire_magic = 2029 ; all
Global Const $model_id_lions_pride_water_magic = 2030 ; all

Global Const $model_id_tigers_pride_fastcasting = 2031 ; all
Global Const $model_id_tigers_pride_soul_reaping = 2045 ; all
Global Const $model_id_tigers_pride_energy_storage = 2047 ; all
Global Const $model_id_tigers_pride_divine_favor = 2054 ; all
Global Const $model_id_tigers_pride_communing = 2055 ; all

Global Const $model_id_heavens_arch_divine_favor = 2056 ; all
Global Const $model_id_heavens_arch_healing_prayers = 2057 ; all
Global Const $model_id_heavens_arch_protection_prayers = 2066 ; all
Global Const $model_id_heavens_arch_smiting_prayers = 2067 ; all

Global Const $model_id_foxs_greed_divine_favor = 2068 ; all
Global Const $model_id_foxs_greed_healing_prayers = 2069 ; all
Global Const $model_id_foxs_greed_protection_prayers = 2070 ; all
Global Const $model_id_foxs_greed_smiting_prayers = 2080 ; all
Global Const $model_id_foxs_greed_communing = 2081 ; all
Global Const $model_id_foxs_greed_spawning_power = 2082 ; all
Global Const $model_id_foxs_greed_restoration = 2083 ; all
Global Const $model_id_foxs_greed_channeling = 2084 ; all

Global Const $model_id_wolfs_greed_divine_favor = 2085 ; all
Global Const $model_id_wolfs_greed_healing_prayers = 2087 ; all
Global Const $model_id_wolfs_greed_protection_prayers = 2088 ; all
Global Const $model_id_wolfs_greed_smiting_prayers = 2090 ; all
Global Const $model_id_wolfs_greed_communing = 2091 ; all
Global Const $model_id_wolfs_greed_spawning_power = 2092 ; all
Global Const $model_id_wolfs_greed_restoration = 2094 ; all
Global Const $model_id_wolfs_greed_channeling = 2095 ; all

;~ 2096, 2097 ?????????

Global Const $model_id_censors_icon_protection_prayers = 2098 ; ???????????????????????????????????????
Global Const $model_id_censors_icon_smiting_prayers = 2099 ; ???????????????????????????????????????
Global Const $model_id_censors_icon_divine_favor = 2100 ; tyria only
Global Const $model_id_censors_icon_healing_prayers = 2101 ; tyria only

Global Const $model_id_lesser_etched_sword = 2102 ; eotn only
Global Const $model_id_greater_etched_sword = 2103 ; eotn only

Global Const $model_id_lesser_granite_edge = 2116 ; eotn only
Global Const $model_id_greater_granite_edge = 2117 ; eotn only

Global Const $model_id_stoneblade = 2125 ; eotn only
Global Const $model_id_furious_bonecrusher = 2133 ; 
Global Const $model_id_etched_sword = 2134 ; eotn only

Global Const $model_id_bears_sloth = 2239 ; all
Global Const $model_id_rhinos_sloth = 2240 ; all

Global Const $model_id_quicksilver_domination = 2242 ; all
Global Const $model_id_quicksilver_fastcasting = 2243 ; all
Global Const $model_id_quicksilver_illusion = 2244 ; all
Global Const $model_id_quicksilver_inspiration = 2245 ; all

Global Const $model_id_unicorns_wrath_domination = 2246 ; all
Global Const $model_id_unicorns_wrath_fastcasting = 2424 ; all
Global Const $model_id_unicorns_wrath_illusion = 2425 ; all
Global Const $model_id_unicorns_wrath_inspiration = 2426 ; all
Global Const $model_id_unicorns_wrath_soul_reaping = 2427 ; all
Global Const $model_id_unicorns_wrath_energy_storage = 2428 ; all
Global Const $model_id_unicorns_wrath_divine_favor = 2429 ; all
Global Const $model_id_unicorns_wrath_communing = 2430 ; all

Global Const $model_id_peacocks_wrath_domination = 2431 ; all
Global Const $model_id_peacocks_wrath_fastcasting = 2432 ; all
Global Const $model_id_peacocks_wrath_illusion = 2433 ; all
Global Const $model_id_peacocks_wrath_inspiration = 2434 ; all

Global Const $model_id_bronze_guardian_tactics = 2435 ; all
Global Const $model_id_bronze_guardian_strength = 2436 ; all
Global Const $model_id_bronze_guardian_leadership = 2437 ; all

Global Const $model_id_hogs_gluttony_tactics = 2438 ; all
Global Const $model_id_hogs_gluttony_strength = 2439 ; all
Global Const $model_id_hogs_gluttony_leadership = 2440 ; all

Global Const $model_id_spiders_gluttony_tactics = 2441 ; all
Global Const $model_id_spiders_gluttony_strength = 2442 ; all
Global Const $model_id_spiders_gluttony_leadership = 2443 ; all

Global Const $model_id_canthan_targe_tactics = 2444 ; tyria only
Global Const $model_id_canthan_targe_strength = 2445 ; tyria only
Global Const $model_id_canthan_targe_leadership = 2446 ; tyria only

Global Const $model_id_deaths_head_soul_reaping = 2447 ; all
Global Const $model_id_deaths_head_blood_magic = 2448 ; all
Global Const $model_id_deaths_head_curses = 2449 ; all
Global Const $model_id_deaths_head_death_magic = 2450 ; all

Global Const $model_id_snakes_envy_soul_reaping = 2451 ; all
Global Const $model_id_snakes_envy_blood_magic = 2452 ; all
Global Const $model_id_snakes_envy_curses = 2453 ; all
Global Const $model_id_snakes_envy_death_magic = 2454 ; all

Global Const $model_id_dragons_envy_fastcasting = 2455 ; all
Global Const $model_id_dragons_envy_soul_reaping = 2456 ; all
Global Const $model_id_dragons_envy_energy_storage = 2457 ; all
Global Const $model_id_dragons_envy_divine_favor = 2458 ; all
Global Const $model_id_dragons_envy_communing = 2459 ; all

Global Const $model_id_dragon_fangs = 2460 ; cantha only

Global Const $model_id_ominous_aegis_tactics = 2461 ; all
Global Const $model_id_ominous_aegis_strength = 2462 ; all
Global Const $model_id_ominous_aegis_leadership = 2463 ; all

Global Const $model_id_spiritbinder_communing = 2464 ; cantha only
Global Const $model_id_spiritbinder_spawning_power = 2465 ; cantha only
Global Const $model_id_spiritbinder_restoration = 2466 ; cantha only
Global Const $model_id_spiritbinder_channeling = 2467 ; cantha only

Global Const $model_id_soulbreaker = 2468 ; elona only

Global Const $model_id_japan_anniversary_shield_strength = 2469 ; cantha only
Global Const $model_id_japan_anniversary_shield_leadership = 2470 ; cantha only

Global Const $model_id_sunspear = 2471 ; elona only
Global Const $model_id_darksteel_longbow = 2472 ; eotn only
Global Const $model_id_glacial_blade = 2473 ; eotn only, sword
Global Const $model_id_glacial_blades = 2474 ; eotn only, daggers

Global Const $model_id_hourglass_staff_domination = 2475 ; eotn only
Global Const $model_id_hourglass_staff_fastcasting = 2476 ; eotn only
Global Const $model_id_hourglass_staff_illusion = 2477 ; eotn only
Global Const $model_id_hourglass_staff_inspiration = 2478 ; eotn only

Global Const $model_id_hourglass_staff_soul_reaping = 2479 ; eotn only
Global Const $model_id_hourglass_staff_blood_magic = 2480 ; eotn only
Global Const $model_id_hourglass_staff_curses = 2481 ; eotn only
Global Const $model_id_hourglass_staff_death_magic = 2482 ; eotn only

Global Const $model_id_hourglass_staff_air_magic = 2483 ; eotn only
Global Const $model_id_hourglass_staff_earth_magic = 2484 ; eotn only
Global Const $model_id_hourglass_staff_energy_storage = 2485 ; eotn only
Global Const $model_id_hourglass_staff_fire_magic = 2486 ; eotn only
Global Const $model_id_hourglass_staff_water_magic = 2487 ; eotn only

Global Const $model_id_hourglass_staff_divine_favor = 2488 ; eotn only
Global Const $model_id_hourglass_staff_healing_prayers = 2489 ; eotn only
Global Const $model_id_hourglass_staff_protection_prayers = 2490 ; eotn only
Global Const $model_id_hourglass_staff_smiting_prayers = 2491 ; eotn only

Global Const $model_id_hourglass_staff_communing = 2492 ; eotn only
Global Const $model_id_hourglass_staff_spawning_power = 2493 ; eotn only
Global Const $model_id_hourglass_staff_restoration = 2494 ; eotn only
Global Const $model_id_hourglass_staff_channeling = 2495 ; eotn only

;~ other
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

#EndRegion Item ModelID
