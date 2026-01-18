#include-once
Global Enum $normalmode, $hardmode
Global Enum $instancetype_outpost, $instancetype_explorable, $instancetype_loading
Global Enum $east, $south_east, $south, $south_west, $west, $north_west, $north, $north_east
Global Enum $mode_feather, $mode_vaettir, $mode_cof, $mode_fiber, $mode_dust_toa, _
			$mode_soup, $mode_kabob, $mode_salad, $mode_warsupply, $mode_moddok, _
			$mode_scrolls, $mode_conset, $mode_polar
Global Enum $state_farm_feather, $state_farm_dust, $state_farm_bones, $state_farm_fiber, $state_farm_iron, $state_craft_cons, $state_next

; === gold related ==
Global Const $mMaxGoldStorage = 1000000

; === rarity ===
Global Const $rarity_green	= 2627
Global Const $rarity_gold	= 2624
Global Const $rarity_purple	= 2626
Global Const $rarity_blue	= 2623
Global Const $rarity_white	= 2621

; === dye ===
Global Const $model_id_dye = 146
Global Const $item_extraid_black_dye = 10
Global Const $item_extraid_white_dye = 12

; === weapon sets ===
Global Const $weapon_set_1 = 1
Global Const $weapon_set_2 = 2
Global Const $weapon_set_3 = 3
Global Const $weapon_set_4 = 4

; === item type ===
Global Const $item_type_salvage				= 0
Global Const $item_type_leadhand			= 1
Global Const $item_type_axe					= 2
Global Const $item_type_bag					= 3
Global Const $item_type_boots				= 4
Global Const $item_type_bow					= 5
Global Const $item_type_bundle				= 6
Global Const $item_type_chestpiece			= 7
Global Const $item_type_rune_and_mod		= 8
Global Const $item_type_usable				= 9		; includes tomes
Global Const $item_type_dye					= 10
Global Const $item_type_material_and_zcoins	= 11
Global Const $item_type_offhand				= 12
Global Const $item_type_gloves				= 13
Global Const $item_type_celestial_sigil		= 14
Global Const $item_type_hammer				= 15
Global Const $item_type_headpiece			= 16
Global Const $item_type_trophy_2			= 17	; salvageitem / cc shards?
Global Const $item_type_key					= 18	; includes lockpicks
Global Const $item_type_leggins				= 19
Global Const $item_type_gold_coins			= 20	; includes platinum
Global Const $item_type_quest_item			= 21
Global Const $item_type_wand				= 22
Global Const $item_type_shield				= 24
Global Const $item_type_staff				= 26
Global Const $item_type_sword				= 27
Global Const $item_type_kit					= 29	; + keg ale
Global Const $item_type_trophy				= 30	; includes polyymock pieces
Global Const $item_type_scroll				= 31
Global Const $item_type_daggers				= 32
Global Const $item_type_present				= 33
Global Const $item_type_minipet				= 34
Global Const $item_type_scythe				= 35
Global Const $item_type_spear				= 36
Global Const $item_type_books				= 43	; encrypted charr battle plan/decoder, golem user manual, books
Global Const $item_type_costume_body		= 44
Global Const $item_type_costume_headpice	= 45
Global Const $item_type_not_equipped		= 46

; === Material ===
Global Const $model_id_bones		= 921
Global Const $model_id_cloth		= 925
Global Const $model_id_dust			= 929
Global Const $model_id_feather		= 933
Global Const $model_id_fiber		= 934
Global Const $model_id_tanned_hide	= 940
Global Const $model_id_wood			= 946
Global Const $model_id_iron			= 948
Global Const $model_id_scales		= 953
Global Const $model_id_chitin		= 954
Global Const $model_id_granite		= 955

; === Rare Material ===
Global Const $model_id_charcoal					= 922
Global Const $model_id_monstrous_claw			= 923
Global Const $model_id_linen					= 926
Global Const $model_id_damask					= 927
Global Const $model_id_silk						= 928
Global Const $model_id_ecto						= 930
Global Const $model_id_monstrous_eye			= 931
Global Const $model_id_monstrous_fang			= 932
Global Const $model_id_diamond					= 935
Global Const $model_id_onyx						= 936
Global Const $model_id_ruby						= 937
Global Const $model_id_sapphire					= 938
Global Const $model_id_glass_vial				= 939
Global Const $model_id_fur_square				= 941
Global Const $model_id_leather_square			= 942
Global Const $model_id_elonian_leather_square	= 943
Global Const $model_id_vial_of_ink				= 944
Global Const $model_id_obsidian_shard			= 945
Global Const $model_id_steel_ingot				= 949
Global Const $model_id_deldrimor_steel_ingot	= 950
Global Const $model_id_roll_of_parchment		= 951
Global Const $model_id_roll_of_vellum			= 952
Global Const $model_id_spiritwood_plank			= 956
Global Const $model_id_amber_chunk				= 6532
Global Const $model_id_jadeite_shard			= 6533

; === Trophies ===
Global Const $model_id_shadowy_remnant	= 441
Global Const $model_id_abnormal_seed	= 442
Global Const $model_id_dark_remain		= 522
Global Const $model_id_dragon_root		= 819
Global Const $model_id_feathered_crest	= 835
Global Const $model_id_skale_tooth		= 1603
Global Const $model_id_skale_claw		= 1604
Global Const $model_id_iboga_petal		= 19183
Global Const $model_id_skale_fin		= 19184
Global Const $model_id_drake_flesh		= 19185
Global Const $model_id_saurian_bones	= 27035
Global Const $model_id_glacial_stone	= 27047
Global Const $model_id_silver_bullion_coin = 1579

; === Kits ===
Global Const $model_id_salvage_kit			= 2992
Global Const $model_id_expert_salvage_kit	= 2991
Global Const $model_id_superior_salvage_kit	= 5900
Global Const $model_id_identification_kit			= 2989
Global Const $model_id_superior_identification_kit	= 5899

; === Scroll ModelID's ===
Global Const $model_id_uw_scroll		= 3746
Global Const $model_id_fow_scroll		= 22280

Global Const $XP_Scrolls[7][2] 			= [[5594,765], [5595, 767], [5611, 768], [5853,857], [5975, 894], [5976, 895], [21233, 1887]]
Global Const $Scroll_Heros_Insight 		= 5594 ; $Heros_Insight = 765
Global Const $Scroll_Berserkers_Insight	= 5595 ; $Berserkers_Insight = 767
Global Const $Scroll_Slayers_Insight 	= 5611 ; $Slayers_Insight = 768
Global Const $Scroll_Adventurers_Insight= 5853 ; $Adventurers_Insight = 857
Global Const $Scroll_Rampagers_Insight 	= 5975 ; $Rampagers_Insight = 894
Global Const $Scroll_Hunters_Insight 	= 5976 ; $Hunters_Insight = 895
Global Const $Scroll_Lightbringer_Scroll= 21233 ; $Lightbringers_Insight = 1887

;Summoning Stone ModelID's
Global Const $Summoning_Stones[21]			= [30847, 37810, 31156, 30846, 30959, 30961, 30962, 30963, 30964, 30965, 30966 _
											  ,31022, 31023, 32557, 34176, 30960, 31155, 35126, 30210, 30209, 21154]
Global Const $Stone_Igneous					= 30847
Global Const $Stone_Legionnaire				= 37810
Global Const $Stone_Zaishen					= 31156
Global Const $Stone_Automaton				= 30846
Global Const $Stone_Chitinous				= 30959
Global Const $Stone_Amber					= 30961
Global Const $Stone_Artic					= 30962
Global Const $Stone_Demonic					= 30963
Global Const $Stone_Geletinous				= 30964
Global Const $Stone_Fossilized				= 30965
Global Const $Stone_Jadeite					= 30966
Global Const $Stone_Mischievous				= 31022
Global Const $Stone_Frosty					= 31023
Global Const $Stone_Ghastly					= 32557
Global Const $Stone_Celestial				= 34176
Global Const $Stone_Mystical				= 30960
Global Const $Stone_Mysterious				= 31155
Global Const $Stone_Shining_Blade			= 35126	; may be incorrect
Global Const $Stone_Imperial_Guard			= 30210
Global Const $Stone_Tengu					= 30209
Global Const $Stone_Merchant				= 21154

;Cons ModelID's (effect ID included in array)
Global Const $Consets[3][2]					= [[24859, 2520], [24860, 2521], [24861, 2522]]
Global Const $model_id_essence_of_celerity 	= 24859 ;2520 (effect ID)
Global Const $model_id_armor_of_salvation	= 24860 ;2521
Global Const $model_id_grail_of_might		= 24861 ;2522
Global Const $model_id_powerstone			= 24862
Global Const $model_id_scroll_of_resurrection = 26501

;Pcons ModelID's (effect ID included in array)
Global Const $Pcons[12][2]				= [[17060,1680],[22269,1945],[28436,2649],[22752,1934], [28432,2604], [28431,2605], [21833,1926], [29434,1926],[35121,3174],[31151,2972],[31152,2972],[31152,31153]]
Global Const $model_id_drake_kabob		= 17060	; $drake_skin = 1680
Global Const $model_id_skalefin_soup	= 17061 ; $skale_vigor = 1681
Global Const $model_id_pahnai_salad		= 17062 ; $pahnai_salad_item_effect = 1682
Global Const $model_id_cupcake			= 22269	; $birthday_cupcake_skill = 1945
Global Const $model_id_pumpkin_pie		= 28436 ; $pie_induced_ecstasy = 2649
Global Const $model_id_golden_egg		= 22752	; $golden_egg_skill = 1934
Global Const $model_id_candy_corn		= 28432	; $candy_corn_skill = 2604
Global Const $model_id_candy_apple		= 28431	; $candy_apple_skill = 2605
Global Const $model_id_lunar_fortune	= 21833 ; $lunar_blessing = 1926
Global Const $model_id_lunar_fortune_2	= 29434 ; $lunar_blessing = 1926
Global Const $model_id_war_supplies		= 35121 ; $well_supplied = 3174
Global Const $model_id_blue_rock		= 31151	; $blue_rock_candy_rush = 2971
Global Const $model_id_green_rock		= 31152	; $green_rock_candy_rush = 2972
Global Const $model_id_red_rock			= 31153	; $red_rock_candy_rush = 2973
Global Const $model_id_lunar_fortune_snake	= 29430

;DP Removal ModelID's
Global Const $dp_removal[4]						= [22191, 22191, 28433]
Global Const $model_id_clover					= 22191
Global Const $model_id_honeycomb				= 26784
Global Const $model_id_pumpkin_cookie			= 28433
Global Const $model_id_shining_blade_ration		= 35127
Global Const $model_id_refined_jelly			= 19039
Global Const $model_id_wintergreen_candy_cane  	= 21488
Global Const $model_id_rainbow_candy_cane		= 21489
Global Const $model_id_peppermint_candy_cane	= 6370

; == sweets ==
Global Const $model_id_delicious_cake	= 36681
Global Const $model_id_chocolate_bunny	= 22644
Global Const $model_id_sugary_blue_drink= 21812
Global Const $model_id_fruitcake		= 21492
Global Const $model_id_jar_of_honey = 31150
Global Const $model_id_creme_brulee = 15528
Global Const $model_id_krytan_lokum = 35125

; == party ==
Global Const $model_id_party_beacon		= 36683
Global Const $model_id_champagne_popper	= 21810
Global Const $model_id_bottle_rocket	= 21809
Global Const $model_id_sparkler			= 21813
Global Const $model_id_squash_serum		= 6369
Global Const $model_id_snowman_summoner	= 6376

; == alcohol ==
Global Const $model_id_iced_tea			= 36682
Global Const $model_id_keg_of_aged_hunters_ale = 31146
Global Const $model_id_aged_hunters_ale	= 31145
Global Const $model_id_grog				= 30855
Global Const $model_id_krytan_brandy	= 35124
Global Const $model_id_firewater		= 2513
Global Const $model_id_spiked_eggnog	= 6366

Global Const $model_id_shamrock_ale		= 22190
Global Const $model_id_hard_apple_cider	= 28435
Global Const $model_id_hunters_ale		= 910
Global Const $model_id_eggnog			= 6375
Global Const $model_id_vial_of_absinthe	= 6367
Global Const $model_id_witchs_brew		= 6049

; == tonics ==
Global Const $model_id_frosty_tonic			= 30648
Global Const $model_id_mischievous_tonic	= 31020
Global Const $model_id_yuletide_tonic		= 21490
Global Const $model_id_transmogrifier_tonic	= 15837

; == Misc Mode's ==
Global Const $model_id_gold_coins		= 2511
Global Const $model_id_lockpick			= 22751
Global Const $model_id_krytan_key		= 5964
Global Const $model_id_obsidian_key		= 5971
Global Const $model_id_phantom_key		= 5882
Global Const $model_id_shing_jea_key	= 6537
Global Const $model_id_istani_key		= 15557
Global Const $model_id_diessa_chalice	= 24353
Global Const $model_id_golden_rin_relic	= 24354
Global Const $model_id_mobstopper		= 32558
Global Const $model_id_captured_skeleton = 32559
Global Const $model_id_confessors_orders = 35123
Global Const $model_id_top_left_map_piece = 24629
Global Const $model_id_top_right_map_piece = 24630
Global Const $model_id_bottom_left_map_piece = 24631 
Global Const $model_id_bottom_right_map_piece = 24632
Global Const $model_id_margonite_gemstone = 21128
Global Const $model_id_stygian_gemstone	= 21129
Global Const $model_id_titan_gemstone	= 21130
Global Const $model_id_torment_gemstone	= 21131
Global Const $model_id_zaishen_key		= 28517
Global Const $model_id_heros_strongbox	= 36666
Global Const $model_id_copper_zaishen_coin = 31202
Global Const $model_id_silver_zaishen_coin = 31204

Global Const $model_id_ghost_in_the_box = 6368
Global Const $model_id_candy_cane_shard = 556
Global Const $model_id_victory_token	= 18345
Global Const $model_id_lunar_token		= 21833
Global Const $model_id_wayfarers_mark	= 37765
Global Const $model_id_tot_bag			= 28434

;Hero IDs
Global Enum $hero_id_norgu = 1, $hero_id_goren, $hero_id_tahlkora, $hero_id_master, $hero_id_jin, $hero_id_koss, $hero_id_dunkoro, $hero_id_sousuke, $hero_id_melonni, $hero_id_zhed, $hero_id_morgahn, $hero_id_margrid, $hero_id_zenmai, $hero_id_olias, $hero_id_razah, $hero_id_mox, $hero_id_keiran, $hero_id_jora, $hero_id_pyre, $hero_id_anton, $hero_id_livia, $hero_id_hayda, $hero_id_kahmu, $hero_id_gwen, $hero_id_xandra, $hero_id_vekk, $hero_id_ogden, $hero_id_mercenary_1, $hero_id_mercenary_2, $hero_id_mercenary_3, $hero_id_mercenary_4, $hero_id_mercenary_5, $hero_id_mercenary_6, $hero_id_mercenary_7, $hero_id_mercenary_8, $hero_id_miku , $hero_id_zei_ri
Global Enum $Backpack = 1, $BeltPouch, $Bag1, $Bag2, $EquipmentPack, $UnclaimedItems = 7, $Storage1, $Storage2, $Storage3, $Storage4, $Storage5, $Storage6, $Storage7, $Storage8, $Storage9, $Storage10, $Storage11, $Storage12, $Storage13, $StorageAnniversary
Global Const $HERO_ID[38][2] = [ [37, 1], [1, "Norgu"], [2, "Goren"], [3, "Tahlkora"], [4, "Master"], [5, "Jin"], [6, "Koss"], [7, "Dunkoro"], [8, "Sousuke"], [9, "Melonni"], [10, "Zhed"], [11, "Morgahn"], [12, "Margrid"], [13, "Zenmai"], [14, "Olias"], [15, "Razah"], [16, "Mox"], [17, "Keiran"], [18, "Jora"], [19, "Pyre"], [20, "Anton"], [21, "Livia"], [22, "Hayda"], [23, "Kahmu"], [24, "Gwen"], [25, "Xandra"], [26, "Vekk"], [27, "Ogden"], [28, "Mercenary Hero 1"], [29, "Mercenary Hero 2"], [30, "Mercenary Hero 3"], [31, "Mercenary Hero 4"], [32, "Mercenary Hero 5"], [33, "Mercenary Hero 6"], [34, "Mercenary Hero 7"], [35, "Mercenary Hero 8"], [36, "Miku"], [37, "Zei Ri"] ]
Global Const $item_type_ID [12] = [$item_type_STAFF, $item_type_WAND, $item_type_OFFHAND, $item_type_SHIELD, $item_type_AXE, $item_type_BOW, $item_type_HAMMER, $item_type_DAGGERS, $item_type_SCYTHE, $item_type_SPEAR, $item_type_SWORD, $item_type_SALVAGE]
Global Const $GH_Array[16] = [4, 5, 6, 51, 176, 177, 178, 179, 275, 276, 359, 360, 529, 530, 537, 538]
#Endregion

#Region Tomes
; all tomes
global $tomes[20] = [21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795, 21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805]
;~ elite tomes
global $elite_tomes[10] = [21786, 21787, 21788, 21789, 21790, 21791, 21792, 21793, 21794, 21795]
Global Const $model_id_elite_tome_assassin 		= 21786
Global Const $model_id_elite_tome_mesmer 		= 21787
Global Const $model_id_elite_tome_necromancer 	= 21788
Global Const $model_id_elite_tome_elementalist	= 21789
Global Const $model_id_elite_tome_monk			= 21790
Global Const $model_id_elite_tome_warrior		= 21791
Global Const $model_id_elite_tome_ranger		= 21792
Global Const $model_id_elite_tome_dervish		= 21793
Global Const $model_id_elite_tome_ritualist		= 21794
Global Const $model_id_elite_tome_paragon		= 21795
;~ normal tomes
global $regular_tomes[10] = [21796, 21797, 21798, 21799, 21800, 21801, 21802, 21803, 21804, 21805]
Global Const $model_id_tome_assassin 	= 21796
Global Const $model_id_tome_mesmer 		= 21797
Global Const $model_id_tome_necromancer = 21798
Global Const $model_id_tome_elementalist= 21799
Global Const $model_id_tome_monk		= 21800
Global Const $model_id_tome_warrior		= 21801
Global Const $model_id_tome_ranger		= 21802
Global Const $model_id_tome_dervish		= 21803
Global Const $model_id_tome_ritualist	= 21804
Global Const $model_id_tome_paragon		= 21805
#EndRegion Tomes

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

; ATTRIBUTES
Global $Fast_Casting = 0;
Global $Illusion_Magic = 1;
Global $Domination_Magic = 2;
Global $Inspiration_Magic = 3;
Global $Blood_Magic = 4;
Global $Death_Magic = 5;
Global $Soul_Reaping = 6;
Global $Curses = 7;
Global $Air_Magic = 8;
Global $Earth_Magic = 9;
Global $Fire_Magic = 10;
Global $Water_Magic = 11;
Global $Energy_Storage = 12;
Global $Healing_Prayers = 13;
Global $Smiting_Prayers = 14;
Global $Protection_Prayers = 15;
Global $Divine_Favor = 16;
Global $Strength = 17;
Global $Axe_Mastery = 18;
Global $Hammer_Mastery = 19;
Global $Swordsmanship = 20;
Global $Tactics = 21;
Global $Beast_Mastery = 22;
Global $Expertise = 23;
Global $Wilderness_Survival = 24;
Global $Marksmanship = 25;
Global $Dagger_Mastery = 29;
Global $Deadly_Arts = 30;
Global $Shadow_Arts = 31;
Global $Communing = 32;
Global $Restoration_Magic = 33;
Global $Channeling_Magic = 34;
Global $Critical_Strikes = 35;
Global $Spawning_Power = 36;
Global $Spear_Mastery = 37;
Global $Command = 38;
Global $Motivation = 39;
Global $Leadership = 40;
Global $Scythe_Mastery = 41;
Global $Wind_Prayers = 42;
Global $Earth_Prayers = 43;
Global $Mysticism = 44;
Global $AttrID_None = 0xFF

; === Range ===
Global Enum $range_adjacent=156, $range_nearby=240, $range_area=312, $range_earshot=1000, $range_spellcast=1085, $range_spirit=2500, $range_compass=5000
Global Enum $range_adjacent_2=156^2, $range_nearby_2=240^2, $range_area_2=312^2, $range_earshot_2=1000^2, $range_spellcast_2=1085^2, $range_spirit_2=2500^2, $range_compass_2=5000^2

;Allegiance
Global Const $allegiance_ally 			= 0x01 		; ally/non-attackable
Global Const $allegiance_enemy			= 0x03		; enemy
Global Const $allegiance_spirit			= 0x04		; spirit or pet or summon stone
Global Const $allegiance_minion			= 0x05		; minion
Global Const $allegiance_npc			= 0x06 		; npc/minipet

;TypeMap
Global Const $typemap_boss				= 3072		; 0xC00		Boss
Global Const $typemap_boss2				= 3073		; 0xC01		Boss with higher drop rate
Global Const $typemap_deadboss			= 3080		; 0xC08		Boss when dead
Global Const $typemap_ally				= 131072	; 0x20000	Ally
Global Const $typemap_ally2				= 131073	; 0x20001 	Ally when targeted
Global Const $typemap_spawned_enemy		= 262144	; 0x40000	Enemy spawned creatures or hero defensive binding rituals
Global Const $typemap_spawned_ally		= 393216	; 0x60000	Allied spawned creatures - SoS, Bloodsong
Global Const $typemap_vampiric_spirit	= 393224	; 0x60008	Allied spawned creatures - Vampiric Spirit
#EndRegion All Skill Infos

#Region Map Districts - Languages
; Map Districts
Global Const $International = -2
Global Const $Asia_Korean = 1
Global Const $Europe = 2
Global Const $Asia_Chinese = 3
Global Const $Asia_Japanese = 4

; Languages
Global Const $English = 0  ; always used for $International, $Asia_Korean, $Asia_Chinese, $Asia_Japanese
Global Const $French = 2
Global Const $German = 3
Global Const $Italian = 4
Global Const $Spanish = 5
Global Const $Polish = 9
Global Const $Russian = 10

Global Const $lRegion[12] = 	[-2, 0, 2, 2, 2, 2, 2, 2,  2, 1, 3, 4]
Global Const $lLanguage[12] = 	[0,  0, 0, 2, 3, 4, 5, 9, 10, 0, 0, 0]
#EndRegion Map Districts - Languages

#Region MapID
; === Map IDs ===
Global Const $map_id_the_black_curtain = 18
Global Const $map_id_the_fissure_of_woe = 34
Global Const $map_id_the_underworld = 72
Global Const $map_id_temple_of_the_ages = 138
Global Const $map_id_drazach_thicket = 195
Global Const $map_id_jaya_bluffs = 196
Global Const $map_id_great_temple_of_balthazar = 248
Global Const $map_id_seitung_harbor = 250
Global Const $map_id_isle_of_the_nameless = 280
Global Const $map_id_maatu_keep = 283
Global Const $map_id_the_marketplace = 303
Global Const $map_id_saoshang_trail = 313
Global Const $map_id_saint_anjekas_shrine = 349
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

#Region PlayerNumber
;~ === Playernumber ===
;~ nature rituals
Global Const $model_id_winter                = 2925 ; 2874
Global Const $model_id_winnowing             = 2926 ; 2875
Global Const $model_id_extinction            = 2927 ; 2876
Global Const $model_id_greater_conflagration = 2928 ; 2877
Global Const $model_id_fertile_season        = 2929 ; 2878
Global Const $model_id_symbiosis             = 2930 ; 2879
Global Const $model_id_primal_echoes         = 2931 ; 2880
Global Const $model_id_predatory_season      = 2932 ; 2881
Global Const $model_id_frozen_soil           = 2933 ; 2882
Global Const $model_id_favorable_winds       = 2934 ; 2883
Global Const $model_id_winds                 = 2935 ; 2884
Global Const $model_id_energizing_wind       = 2936 ; 2885
Global Const $model_id_quickening_zephir     = 2937 ; 2886
Global Const $model_id_natures_renewal       = 2938 ; 2887
Global Const $model_id_muddy_terrain         = 2939 ; 2888
Global Const $model_id_laceration            = 4283 ; 4232
Global Const $model_id_pestilence            = 4285 ; 4234
Global Const $model_id_tranquility           = 4286 ; 4235
Global Const $model_id_equinox               = 4287 ; 4236
Global Const $model_id_conflagration         = 4288 ; 4237
Global Const $model_id_famine                = 4289 ; 4238
Global Const $model_id_brambles              = 4290 ; 4239
Global Const $model_id_infuriating_heat      = 5766 ; 5715
Global Const $model_id_roaring_winds         = 5768 ; 5717
Global Const $model_id_quicksand             = 5769 ; 5718
Global Const $model_id_toxicity              = 5827 ; 5776

;~ binding rituals
Global Const $model_id_anguish            = 5771 ; 5720
Global Const $model_id_empowerment        = 5772 ; 5721
Global Const $model_id_vampirism          = 5774 ; 5723
Global Const $model_id_rejuvenation       = 5904 ; 5853
Global Const $model_id_agony              = 5905 ; 5854
Global Const $model_id_shadowsong         = 4264 ; 4213
Global Const $model_id_pain               = 4265 ; 4214
Global Const $model_id_destruction        = 4266 ; 4215
Global Const $model_id_displacement       = 4268 ; 4217
Global Const $model_id_life               = 4269 ; 4218
Global Const $model_id_preservation       = 4270 ; 4219
Global Const $model_id_recuperation       = 4271 ; 4220
Global Const $model_id_dissonance         = 4272 ; 4221
Global Const $model_id_earthbind          = 4273 ; 4222
Global Const $model_id_shelter            = 4274 ; 4223
Global Const $model_id_union              = 4275 ; 4224
Global Const $model_id_disenchantment     = 4276 ; 4225
Global Const $model_id_restoration        = 4277 ; 4226
Global Const $model_id_bloodsong          = 4278 ; 4227
Global Const $model_id_wanderlust         = 4279 ; 4228
Global Const $model_id_anger              = 4280 ; 4229
Global Const $model_id_hate               = 4281 ; 4230
Global Const $model_id_suffering          = 4282 ; 4231

; Nightfall Pcons farm
Global Const $model_id_fanged_iboga					= 4439 ; 4388
Global Const $model_id_fanged_iboga_lvl_6			= 4437 ; 4386
Global Const $model_id_stormseed_jacaranda_lvl_6    = 4436 ; 4385
Global Const $model_id_stormseed_jacaranda_lvl_10   = 4438 ; 4387
Global Const $model_id_grub_lance_lvl_8             = 4428 ; 4377
Global Const $model_id_preying_lance_lvl_8          = 4430 ; 4379
Global Const $model_id_stalking_nephila_lvl_2       = 4393 ; 4342
Global Const $model_id_stalking_nephila_lvl_15      = 4392 ; 4341
Global Const $model_id_irontooth_drake_lvl_10       = 4403 ; 4352
Global Const $model_id_irontooth_drake_lvl_18       = 4404 ; 4353
Global Const $model_id_steelfang_drake              = 4965 ; 4914

; Plant Fiber Farm
Global Const $model_id_dragon_moss            = 3773 ; 3722
; Feather Farm
Global Const $model_id_sensali_claw           = 3995 ; 3944
Global Const $model_id_sensali_darkfeather    = 3997 ; 3946
Global Const $model_id_sensali_cutter         = 3999 ; 3948
; CoF Farm
Global Const $model_id_crypt_ghoul            = 7075 ; 7024
Global Const $model_id_crypt_slasher          = 7077 ; 7026
Global Const $model_id_crypt_wraith           = 7079 ; 7028
Global Const $model_id_crypt_banshee          = 7081 ; 7030
Global Const $model_id_shock_phantom          = 7083 ; 7032
Global Const $model_id_ash_phantom            = 7085 ; 7034
Global Const $model_id_servant_of_murakai     = 7069 ; 7018
; ToA Dust Farm
Global Const $model_id_fog_nightmare           = 1732 ; 1729
; Moddok Farm
Global Const $model_id_corsair_cutthroat       = 5127 ; 5076
Global Const $model_id_corsair_raider          = 5128 ; 5077
Global Const $model_id_corsair_captain         = 5130 ; 5079

; FoW and UW
Global Const $model_id_avatar_of_grenth			= 1995 ; 1945
Global Const $model_id_champion_of_balthazar	= 1997 ; 1947
Global Const $model_id_abyssal					= 2861 ; 2810
Global Const $model_id_shadow_ranger			= 2859 ; 2808
Global Const $model_id_skeleton_of_dhuum		= 2392 ; 2342
; DoA
Global Const $model_id_kaya                  = 5217 ; 5166
Global Const $model_id_dabi                  = 5218 ; 5167
Global Const $model_id_su                    = 5219 ; 5168
Global Const $model_id_ki                    = 5220 ; 5169
Global Const $model_id_vu                    = 5221 ; 5170
Global Const $model_id_tuk                   = 5222 ; 5171
Global Const $model_id_ruk                   = 5223 ; 5172
Global Const $model_id_rund                  = 5224 ; 5173
Global Const $model_id_mank                  = 5225 ; 5174
Global Const $model_id_jadoth                = 0   ; 0
Global Const $model_id_rage_titan             = 5252 ; 5201
Global Const $model_id_despair_titan          = 5254 ; 5203
Global Const $model_id_tortureweb_dryder      = 5266 ; 5215
Global Const $model_id_greater_dream_rider    = 5268 ; 5217
; Jade Quarry
Global Const $model_id_luxon_wizard           = 3138 ; mes ; 3087
Global Const $model_id_luxon_storm_caller     = 3140 ; ele ; 3089
Global Const $model_id_luxon_longbow          = 3142 ; ranger ; 3091
Global Const $model_id_kurzick_illusionist    = 3137 ; mes ; 3086
Global Const $model_id_kurzick_thunder        = 3139 ; ele ; 3088
Global Const $model_id_kurzick_far_shot       = 3141 ; ranger ; 3090
Global Const $model_id_luxon_hauler_turtle    = 3636 ; 3585
Global Const $model_id_kurzick_carrier_juggernaut = 3418 ; 3367

; War Supply Farm
Global Const $model_id_white_mantle_ritualist_6 = 8288 ; rit/paragon spear ; 8237
Global Const $model_id_white_mantle_ritualist_8 = 8289 ; rit/monk (preservation, strong heal, hexremove, spirits) primary ; 8238
Global Const $model_id_white_mantle_ritualist   = 8290 ; SoS ; 8239
Global Const $model_id_white_mantle_ritualist_2 = 8291 ; PRIMARY (shadowsong,bloodsong,pain,anguish) ; 8240
Global Const $model_id_white_mantle_ritualist_7 = 8292 ; minions 2nd prio;  ; 8241
Global Const $model_id_white_mantle_ritualist_9 = 8293 ; weapon of remedy rit(hardrez, prio) ; 8242

Global Const $model_id_white_mantle_ritualist_3 = 8243 ; 8192
Global Const $model_id_white_mantle_ritualist_4 = 8244 ;  ; 8193
Global Const $model_id_white_mantle_ritualist_5 = 8245 ; 8194

Global Const $model_id_white_mantle_savant      = 8251 ; mshower ; 8200
Global Const $model_id_white_mantle_savant_2    = 8252 ; savannah heat + rit heal ; 8201

Global Const $model_id_white_mantle_adherent    = 8255 ;  ; 8204
Global Const $model_id_white_mantle_adherent_2  = 8256 ; shatterstone ; 8205
Global Const $model_id_white_mantle_adherent_3  = 8257 ; Unsteady Ground ; 8206
Global Const $model_id_white_mantle_adherent_4  = 8258 ; Sandstorm ; 8207

Global Const $model_id_white_mantle_priest      = 8259 ; WoH ; 8208
Global Const $model_id_white_mantle_priest_2    = 8260 ; Healing Burst ; 8209
Global Const $model_id_white_mantle_priest_3    = 8261 ; Healers Boon(hexremove) ; 8210
Global Const $model_id_white_mantle_priest_4    = 8262 ; mo/ele (smite) RoJ ; 8211

Global Const $model_id_white_mantle_abbot        = 8263 ; Prot Mo (Boon Signet, spiritbond) ; 8212
Global Const $model_id_white_mantle_abbot_2      = 8264 ; Mantra of Recall ; 8213
Global Const $model_id_white_mantle_abbot_3      = 8265 ;  ; 8214
Global Const $model_id_white_mantle_abbot_4      = 8266 ; zeal benediction + smite ; 8215

Global Const $model_id_white_mantle_sycophant    = 8237 ; degen mes (crippling anguish) ; 8186
Global Const $model_id_white_mantle_sycophant_2  = 8238 ; dom mes (clumsiness) 2nd ; 8187
Global Const $model_id_white_mantle_sycophant_3  = 8239 ; dom mes (emp+healing signet) ; 8188
Global Const $model_id_white_mantle_sycophant_4  = 8240 ; esurge, spirit shackles 2NDARY ; 8189
Global Const $model_id_white_mantle_sycophant_5  = 8241 ; condi mes 2nd ; 8190
Global Const $model_id_white_mantle_sycophant_6  = 8242 ; WoH isMonk ; 8191

Global Const $model_id_white_mantle_fanatic      = 8247 ; 8196
Global Const $model_id_white_mantle_fanatic_2    = 8248 ; nec (rit heal) ; 8197
Global Const $model_id_white_mantle_fanatic_3    = 8249 ; lingering curse ; 8198
Global Const $model_id_white_mantle_fanatic_4    = 8250 ; tainted flesh ; 8199
;roj Missing
#Endregion PlayerNumber

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
