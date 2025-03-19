#include-once
#cs 
    $array_insignia
    $array_rune_minor
    $array_rune_major
    $array_rune_major
#ce

Global Enum $insig_name, $insig_model_id, $insig_mod_string, $insig_value, $insig_enum_size
; Name, ModelID, ModString, Value
Global Const $array_insignia[][$insig_enum_size] = [ _
["Survivor Insignia", 19132, "E6010824", 0], _
["Radiant Insignia", 19131, "E5010824", 0], _
["Stalwart Insignia", 19133, "E7010824", 0], _
["Brawler's Insignia", 19134, "E8010824", 0], _
["Blessed Insignia", 19135, "E9010824", 1000], _
["Herald's Insignia", 19136, "EA010824", 0], _
["Sentry's Insignia", 19137, "EB010824", 0], _
["Knight's Insignia[Warrior]", 19152, "F9010824", 0], _
["Lieutenant's Insignia[Warrior]", 19153, "08020824", 0], _
["Stonefist Insignia[Warrior]", 19154, "09020824", 0], _
["Dreadnought Insignia[Warrior]", 19155, "FA010824", 0], _
["Sentinel's Insignia[Warrior]", 19156, "FB010824", 1500], _
["Frostbound Insignia[Ranger]", 19157, "FC010824", 0], _
["Pyrebound Insignia[Ranger]", 19159, "FE010824", 0], _
["Stormbound Insignia[Ranger]", 19160, "FF010824", 0], _
["Scout's Insignia[Ranger]", 19162, "01020824", 0], _
["Earthbound Insignia[Ranger]", 19158, "FD010824", 0], _
["Beastmaster's Insignia[Ranger]", 19161, "00020824", 0], _
["Wanderer's Insignia[Monk]", 19149, "F6010824", 0], _
["Disciple's Insignia[Monk]", 19150, "F7010824", 0], _
["Anchorite's Insignia[Monk]", 19151, "F8010824", 400], _
["Bloodstained Insignia[Necromancer]", 19138, "0A020824", 0], _
["Tormentor's Insignia[Necromancer]", 19139, "EC010824", 2500], _
["Bonelace Insignia[Necromancer]", 19141, "EE010824", 0], _
["Minion Master's Insignia[Necromancer]", 19142, "EF010824", 0], _
["Blighter's Insignia[Necromancer]", 19143, "F0010824", 0], _
["Undertaker's Insignia[Necromancer]", 19140, "ED010824", 0], _
["Virutoso's Insignia[Mesmer]", 19130, "E4010824", 0], _
["Artificer's Insignia[Mesmer]", 19128, "E2010824", 0], _
["Prodigy's Insignia[Mesmer]", 19129, "E3010824", 15000], _
["Hydromancer Insignia[Elementalist]", 19145, "F2010824", 0], _
["Geomancer Insignia[Elementalist]", 19146, "F3010824", 0], _
["Pyromancer Insignia[Elementalist]", 19147, "F4010824", 0], _
["Aeromancer Insignia[Elementalist]", 19148, "F5010824", 0], _
["Prismatic Insignia[Elementalist]", 19144, "F1010824", 0], _
["Vanguard's Insignia[Assassin]", 19124, "DE010824", 0], _
["Infiltrator's Insignia[Assassin]", 19125, "DF010824", 0], _
["Saboteur's Insignia[Assassin]", 19126, "E0010824", 0], _
["Nightstalker's Insignia[Assassin]", 19127, "E1010824", 0], _
["Shaman's Insignia[Ritualist]", 19165, "04020824", 10000], _
["Ghost Forge Insignia[Ritualist]", 19166, "05020824", 0], _
["Mystic's Insignia[Ritualist]", 19167, "06020824", 0], _
["Windwalker Insignia[Dervish]", 19163, "02020824", 4500], _
["Forsaken Insignia[Dervish]", 19164, "03020824", 0], _
["Centurion's Insignia[Paragon]", 19168, "07020824", 1500] ]

Global Enum $rune_name, $rune_model_id, $rune_mod_string, $rune_value, $rune_enum_size
; Name, ModelID, ModString, Value
Global Const $array_rune_minor[][$rune_enum_size] = [ _
["Rune of Minor Vigor", 898, "C202E827", 5000], _
["Rune of Vitae", 898, "12020824", 900], _
["Rune of Attunement", 898, "11020824", 600], _
["Warrior Rune of Minor Absorption", 903, "EA02E827", 0], _
["Warrior Rune of Minor Tactics", 903, "0115E821", 500], _
["Warrior Rune of Minor Strength", 903, "0111E821", 1000], _
["Warrior Rune of Minor Axe Mastery", 903, "0112E821", 0], _
["Warrior Rune of Minor Hammer Mastery", 903, "0113E821", 0], _
["Warrior Rune of Minor Swordmanship", 903, "0114E821", 0], _
["Ranger Rune of Minor Wilderness Survival", 904, "0118E821", 0], _
["Ranger Rune of Minor Expertise", 904, "0117E821", 400], _
["Ranger Rune of Minor Beast Mastery", 904, "0116E821", 0], _
["Ranger Rune of Minor Markmanship", 904, "0119E821", 0], _
["Monk Rune of Minor Healing Prayers", 902, "010DE821", 0], _
["Monk Rune of Minor Smiting Prayers", 902, "010EE821", 0], _
["Monk Rune of Minor Protection Prayers", 902, "010FE821", 500], _
["Monk Rune of Minor Divine Favor", 902, "0110E821", 1600], _
["Necromancer Rune of Minor Blood Magic", 900, "0104E821", 0], _
["Necromancer Rune of Minor Death Magic", 900, "0105E821", 0], _
["Necromancer Rune of Minor Curses", 900, "0107E821", 0], _
["Necromancer Rune of Minor Soul Reaping", 900, "0106E821", 800], _
["Mesmer Rune of Minor Fast Casting", 899, "0100E821", 3000], _
["Mesmer Rune of Minor Domination Magic", 899, "0102E821", 0], _
["Mesmer Rune of Minor Illusion Magic", 899, "0101E821", 0], _
["Mesmer Rune of Minor Inspiration Magic", 899, "0103E821", 5000], _
["Elementalist Rune of Minor Energy Storage", 901, "010CE821", 2200], _
["Elementalist Rune of Minor Fire Magic", 901, "010AE821", 0], _
["Elementalist Rune of Minor Air Magic", 901, "0108E821", 0], _
["Elementalist Rune of Minor Earth Magic", 901, "0109E821", 0], _
["Elementalist Rune of Minor Water Magic", 901, "010BE821", 0], _
["Assassin Rune of Minor Critical Strikes", 6324, "0123E821", 0], _
["Assassin Rune of Minor Dagger Mastery", 6324, "011DE821", 0], _
["Assassin Rune of Minor Deadly Arts", 6324, "011EE821", 0], _
["Assassin Rune of Minor Shadow Arts", 6324, "011FE821", 0], _
["Ritualist Rune of Minor Channeling Magic", 6327, "0122E821", 0], _
["Ritualist Rune of Minor Restoration Magic", 6327, "0121E821", 0], _
["Ritualist Rune of Minor Communing", 6327, "0120E821", 0], _
["Ritualist Rune of Minor Spawning Power", 6327, "0124E821", 2000], _
["Dervish Rune of Minor Mysticism", 15545, "012CE821", 0], _
["Dervish Rune of Minor Earth Prayers", 15545, "012BE821", 0], _
["Dervish Rune of Minor Scythe Mastery", "0129E821", 1000], _
["Dervish Rune of Minor Wind Prayers", 15545, "012AE821", 0], _
["Paragon Rune of Minor Leadership", 15548, "0128E821", 0], _
["Paragon Rune of Minor Motivation", 15548, "0127E821", 0], _
["Paragon Rune of Minor Command", 15548, "0126E821", 0], _
["Paragon Rune of Minor Spear Mastery", 15548, "0125E821", 0] ]

; Name, ModelID, ModString, Value
Global Const $array_rune_major[][$rune_enum_size] = [ _
["Rune of Major Vigor", 5550, "C202E927", 17000], _
["Rune of Recovery", 5550, "13020824", 0], _
["Rune of Restoration", 5550, "14020824", 0], _
["Rune of Clarity", 5550, "15020824", 0], _
["Rune of Purity", 5550, "16020824", 0], _
["Warrior Rune of Major Absorption", 5558, "EA02E927", 0], _
["Warrior Rune of Major Tactics", 5558, "0215E821", 0], _
["Warrior Rune of Major Strength", 5558, "0211E821", 0], _
["Warrior Rune of Major Axe Mastery", 5558, "0212E821", 0], _
["Warrior Rune of Major Hammer Mastery", 5558, "0213E821", 0], _
["Warrior Rune of Major Swordmanship", 5558, "0214E821", 0], _
["Ranger Rune of Major Wilderness Survival", 5560, "0218E821", 0], _
["Ranger Rune of Major Expertise", 5560, "0217E821", 0], _
["Ranger Rune of Major Beast Mastery", 5560, "0216E821", 0], _
["Ranger Rune of Major Markmanship", 5560, "0219E821", 0], _
["Monk Rune of Major Healing Prayers", 5556, "020DE821", 0], _
["Monk Rune of Major Smiting Prayers", 5556, "020EE821", 0], _
["Monk Rune of Major Protection Prayers", 5556, "020FE821", 0], _
["Monk Rune of Major Divine Favor", 5556, "0210E821", 0], _
["Necromancer Rune of Major Blood Magic", 5552, "0204E821", 0], _
["Necromancer Rune of Major Death Magic", 5552, "0205E821", 0], _
["Necromancer Rune of Major Curses", 5552, "0207E821", 0], _
["Necromancer Rune of Major Soul Reaping", 5552, "0206E821", 0], _
["Mesmer Rune of Major Fast Casting", 3612, "0200E821", 1000], _
["Mesmer Rune of Major Domination Magic", 3612, "0202E821", 0], _
["Mesmer Rune of Major Illusion Magic", 3612, "0201E821", 0], _
["Mesmer Rune of Major Inspiration Magic", 3612, "0203E821", 0], _
["Elementalist Rune of Major Energy Storage", 5554, "020CE821", 0], _
["Elementalist Rune of Major Fire Magic", 5554, "020AE821", 0], _
["Elementalist Rune of Major Air Magic", 5554, "0208E821", 0], _
["Elementalist Rune of Major Earth Magic", 5554, "0209E821", 0], _
["Elementalist Rune of Major Water Magic", 5554, "020BE821", 0], _
["Assassin Rune of Major Critical Strikes", 6325, "0223E821", 0], _
["Assassin Rune of Major Dagger Mastery", 6325, "021DE821", 0], _
["Assassin Rune of Major Deadly Arts", 6325, "021EE821", 0], _
["Assassin Rune of Major Shadow Arts", 6325, "021FE821", 0], _
["Ritualist Rune of Major Channeling Magic", 6328, "0222E821", 0], _
["Ritualist Rune of Major Restoration Magic", 6328, "0221E821", 0], _
["Ritualist Rune of Major Communing", 6328, "0220E821", 0], _
["Ritualist Rune of Major Spawning Power", 6328, "0224E821", 0], _
["Dervish Rune of Major Mysticism", 15546, "022CE821", 0], _
["Dervish Rune of Major Earth Prayers", 15546, "022BE821", 0], _
["Dervish Rune of Major Scythe Mastery", 15546, "0229E821", 0], _
["Dervish Rune of Major Wind Prayers", 15546, "022AE821", 0], _
["Paragon Rune of Major Leadership", 15549, "0228E821", 0], _
["Paragon Rune of Major Motivation", 15549, "0227E821", 0], _
["Paragon Rune of Major Command", 15549, "0226E821", 0], _
["Paragon Rune of Major Spear Mastery", 15549, "0225E821", 0] ]

; Name, ModelID, ModString, Value
Global Const $array_rune_superior[][$rune_enum_size] = [ _
["Rune of Superior Vigor", 5551, "C202EA27", 0], _
["Warrior Rune of Superior Absorption", 5559, "EA02EA27", 0], _
["Warrior Rune of Superior Tactics", 5559, "0315E821", 0], _
["Warrior Rune of Superior Strength", 5559, "0311E821", 0], _
["Warrior Rune of Superior Axe Mastery", 5559, "0312E821", 0], _
["Warrior Rune of Superior Hammer Mastery", 5559, "0313E821", 0], _
["Warrior Rune of Superior Swordmanship", 5559, "0314E821", 0], _
["Ranger Rune of Superior Wilderness Survival", 5561, "0318E821", 0], _
["Ranger Rune of Superior Expertise", 5561, "0317E821", 0], _
["Ranger Rune of Superior Beast Mastery", 5561, "0316E821", 0], _
["Ranger Rune of Superior Markmanship", 5561, "0319E821", 0], _
["Monk Rune of Superior Healing Prayers", 5557, "030DE821", 0], _
["Monk Rune of Superior Smiting Prayers", 5557, "030EE821", 500], _
["Monk Rune of Superior Protection Prayers", 5557, "030FE821", 0], _
["Monk Rune of Superior Divine Favor", 5557, "0310E821", 0], _
["Necromancer Rune of Superior Blood Magic", 5553, "0304E821", 400], _
["Necromancer Rune of Superior Death Magic", 5553, "0305E821", 700], _
["Necromancer Rune of Superior Curses", 5553, "0307E821", 0], _
["Necromancer Rune of Superior Soul Reaping", 5553, "0306E821", 0], _
["Mesmer Rune of Superior Fast Casting", 5549, "0300E821", 0], _
["Mesmer Rune of Superior Domination Magic", 5549, "0302E821", 9000], _
["Mesmer Rune of Superior Illusion Magic", 5549, "0301E821", 0], _
["Mesmer Rune of Superior Inspiration Magic", 5549, "0303E821", 0], _
["Elementalist Rune of Superior Energy Storage", 5555, "030CE821", 0], _
["Elementalist Rune of Superior Fire Magic", 5555, "030AE821", 0], _
["Elementalist Rune of Superior Air Magic", 5555, "0308E821", 1500], _
["Elementalist Rune of Superior Earth Magic", 5555, "0309E821", 0], _
["Elementalist Rune of Superior Water Magic", 5555, "030BE821", 0], _
["Assassin Rune of Superior Critical Strikes", 6326, "0323E821", 0], _
["Assassin Rune of Superior Dagger Mastery", 6326, "031DE821", 0], _
["Assassin Rune of Superior Deadly Arts", 6326, "031EE821", 0], _
["Assassin Rune of Superior Shadow Arts", 6326, "031FE821", 0], _
["Ritualist Rune of Superior Channeling Magic", 6329, "0322E821", 0], _
["Ritualist Rune of Superior Restoration Magic", 6329, "0321E821", 0], _
["Ritualist Rune of Superior Communing", 6329, "0320E821", 600], _
["Ritualist Rune of Superior Spawning Power", 6329, "0324E821", 0], _
["Dervish Rune of Superior Mysticism", 15547, "032CE821", 0], _
["Dervish Rune of Superior Earth Prayers", 15547, "032BE821", 0], _
["Dervish Rune of Superior Scythe Mastery", 15547, "0329E821", 0], _
["Dervish Rune of Superior Wind Prayers", 15547, "032AE821", 0], _
["Paragon Rune of Superior Leadership", 15550, "0328E821", 0], _
["Paragon Rune of Superior Motivation", 15550, "0327E821", 0], _
["Paragon Rune of Superior Command", 15550, "0326E821", 0], _
["Paragon Rune of Superior Spear Mastery", 15550, "0325E821", 0] ]