--     python3 tools/reference/poi_spawns_sql.py > mmoserverdb/migrations/073_poi_spawns.sql
-- 
-- The named outdoor places that had their own inhabitants pre-CU (Fort
-- Tusken's Sandpeople, the Dantooine tribes' strongholds, the Mauler
-- stronghold, the canyon corsairs' hideout...): each gets a small spawn area
-- centred on the place's position in planet_regions (the base data, from the
-- client's region files), and a few invisible lairs placed at random in it
-- (lair_at_poi: the place is a no-build area, so the usual tests would refuse
-- every spot) calling the place's people, from the templates the creature and
-- camp migrations made (027-071).
-- 
-- Who lives where follows the place's name (the swganh wiki's POI pages, from
-- the live game: "Sandpeople, Commoners, Raiders, Snipers, Warlords, and even
-- the Tusken King roam" Fort Tusken); how many, and in which mixes, is
-- reconstructed: data to tune. Caves and dungeons (their insides) and the
-- battle sites (two sides fighting each other) are not here: the server
-- spawns outdoors only, and NPCs do not fight NPCs yet.
-- 
-- Written by tools/reference/poi_spawns_sql.py; edit that, not this.
--
--   Tatooine  forttusken                   4 x tusken_commoner, tusken_raider, tusken_sniper; 2 x tusken_captain, tusken_chief; 1 x tusken_warlord, tusken_king, tusken_bantha
--   Tatooine  Jawa Fortress                3 x jawa, jawa_engineer, jawa_healer, jawa_henchman, jawa_smuggler, jawa_thief; 1 x jawa_leader, jawa_warlord
--   Tatooine  Beggar's Canyon              2 x womprat, lesser_desert_womprat
--   Dantooine Junta Stronghold             3 x janta_tribesman, janta_herbalist, janta_harvester, janta_hunter; 2 x janta_primalist, janta_loreweaver, janta_scout, janta_rockshaper; 1 x janta_shaman, janta_soothsayer, janta_warrior, janta_clan_leader
--   Dantooine Kunga Stronghold             3 x kunga_tribesman, kunga_herbalist, kunga_harvester, kunga_soothsayer; 2 x kunga_clan_primalist, kunga_hunter, kunga_loreweaver, kunga_scout; 1 x kunga_shaman, kunga_rockshaper, kunga_warrior
--   Dantooine Mokk Stronghold              3 x mokk_tribesman, mokk_herbalist, mokk_harvester, mokk_hunter; 2 x mokk_soothsayer, mokk_primalist, mokk_loreweaver, mokk_scout; 1 x mokk_shaman, mokk_rockshaper, mokk_warrior, mokk_clan_leader
--   Dantooine dantari1                     2 x dantari_raider, dantari_raider_strategist; 1 x dantari_raider_battlelord, dantari_raider_chief
--   Dantooine dantari2                     2 x dantari_raider, dantari_raider_strategist; 1 x dantari_raider_battlelord, dantari_raider_chief
--   Dantooine dantari3                     2 x dantari_raider, dantari_raider_strategist; 1 x dantari_raider_battlelord, dantari_raider_chief
--   Dathomir  nightsister                  3 x nightsister_sentry, nightsister_initiate, nightsister_ranger; 1 x nightsister_stalker, nightsister_rancor_tamer, nightsister_rancor
--   Dathomir  singing                      3 x singing_mountain_clan_sentry, singing_mtn_clan_initiate, singing_mtn_clan_scout; 1 x singing_mtn_clan_huntress, singing_mtn_clan_rancor_tamer, singing_mountain_clan_rancor, singing_mtn_clan_dragoon
--   Endor     dulok1                       3 x donkuwah_tribesman, donkuwah_scout, donkuwah_shaman, donkuwah_laborer; 1 x donkuwah_battlelord, donkuwah_spiritmaster, donkuwah_chieftan
--   Endor     dulok2                       3 x pubam_tribesman, pubam_scout, pubam_dark_shaman; 1 x pubam_battlelord, pubam_chieftan
--   Endor     marauder                     3 x marauder, feral_marauder, frenzied_marauder; 1 x blood_crazed_plains_marauder, grassland_blood_marauder
--   Lok       Canyon Corsair Hideout       4 x canyon_corsair_pirate_weak, canyon_corsair_scout, canyon_corsair_cutthroat, canyon_corsair_pirate_strong; 2 x canyon_corsair_guard, canyon_corsair_destroyer, canyon_corsair_pirate_elite; 1 x elite_canyon_corsair, canyon_corsair_captain
--   Lok       bloodrazor                   3 x blood_razor_pirate_weak, blood_razor_pirate_strong, blood_razor_scout, blood_razor_cutthroat; 1 x blood_razor_officer, blood_razor_captain, blood_razor_berzerker
--   Naboo     Mauler Stronghold            3 x mauler_apprentice, mauler_acolyte, mauler; 1 x mauler_lord, mauler_master
--   Naboo     Gungan Warrior Stronghold    3 x gungan_scout, gungan_grand_army_soldier, gungan_hunter, gungan_guard; 1 x gungan_captain, gungan_general, gungan_war_chief, gungan_boss
--   Rori      Cobral Hideout               3 x cobral_thug, cobral_thief, cobral_runner, cobral_bandit; 1 x cobral_hitman, cobral_assassin, cobral_boss, cobral_overlord
--   Rori      Rori Gungan Swamp Town       3 x rorgungan_scout, rorgungan_commoner, rorgungan_warrior; 1 x rorgungan_warchief, rorgungan_boss
--   Rori      kobala                       3 x kobola_miner, kobola_smuggler, kobola_thief, kobola_guard; 1 x kobola_assassin, kobola_pitboss, kobola_underboss
--   Talus     Binyare Pirate Base          3 x binayre_hooligan, binayre_scalawag, binayre_ruffian, binayre_pirate; 1 x binayre_smuggler, binayre_swindler, binayre_chief
--   Corellia  Nyax Cultists Outpost        3 x lord_nyax_minion, lord_nyax_servant, lord_nyax_disciple; 1 x lord_nyax_fanatic, lord_nyax_zealot, lord_nyax_fiend, lord_nyax_visionary
--   Corellia  afarathu                     2 x afarathu_cult_follower, afarathu_cult_ruffian, afarathu_cult_savage, afarathu_cult_brute, afarathu_cult_hellion
--   Corellia  drall                        2 x drall_sentry, drall_monk, drall_guard, drall_patriot, drall_abbot
--

SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)
  VALUES ('lair_at_poi', 1, 'A point of interest''s lair: anywhere in its own area, no no-build or band test'),
         ('lair_invisible', 1, 'A lair not shown to players: a spawn point for its creatures');

-- Each place's spawn area, centred on its position in planet_regions.
INSERT IGNORE INTO swganh.spawns (id, spawn_x, spawn_z, spawn_width, spawn_length, spawn_planet, spawn_density)
  SELECT 901, x - 150, z - 150, 300, 300, 8, 1 FROM swganh.planet_regions WHERE planet_id = 8 AND region_name = 'forttusken'
  UNION ALL SELECT 902, x - 100, z - 100, 200, 200, 8, 1 FROM swganh.planet_regions WHERE planet_id = 8 AND region_name = 'Jawa Fortress'
  UNION ALL SELECT 903, x - 60, z - 60, 120, 120, 8, 1 FROM swganh.planet_regions WHERE planet_id = 8 AND region_name = 'Beggar\'s Canyon'
  UNION ALL SELECT 904, x - 100, z - 100, 200, 200, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'Junta Stronghold'
  UNION ALL SELECT 905, x - 100, z - 100, 200, 200, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'Kunga Stronghold'
  UNION ALL SELECT 906, x - 150, z - 150, 300, 300, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'Mokk Stronghold'
  UNION ALL SELECT 907, x - 80, z - 80, 160, 160, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'dantari1'
  UNION ALL SELECT 908, x - 80, z - 80, 160, 160, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'dantari2'
  UNION ALL SELECT 909, x - 80, z - 80, 160, 160, 1, 1 FROM swganh.planet_regions WHERE planet_id = 1 AND region_name = 'dantari3'
  UNION ALL SELECT 910, x - 100, z - 100, 200, 200, 2, 1 FROM swganh.planet_regions WHERE planet_id = 2 AND region_name = 'nightsister'
  UNION ALL SELECT 911, x - 100, z - 100, 200, 200, 2, 1 FROM swganh.planet_regions WHERE planet_id = 2 AND region_name = 'singing'
  UNION ALL SELECT 912, x - 80, z - 80, 160, 160, 3, 1 FROM swganh.planet_regions WHERE planet_id = 3 AND region_name = 'dulok1'
  UNION ALL SELECT 913, x - 80, z - 80, 160, 160, 3, 1 FROM swganh.planet_regions WHERE planet_id = 3 AND region_name = 'dulok2'
  UNION ALL SELECT 914, x - 80, z - 80, 160, 160, 3, 1 FROM swganh.planet_regions WHERE planet_id = 3 AND region_name = 'marauder'
  UNION ALL SELECT 915, x - 200, z - 200, 400, 400, 4, 1 FROM swganh.planet_regions WHERE planet_id = 4 AND region_name = 'Canyon Corsair Hideout'
  UNION ALL SELECT 916, x - 80, z - 80, 160, 160, 4, 1 FROM swganh.planet_regions WHERE planet_id = 4 AND region_name = 'bloodrazor'
  UNION ALL SELECT 917, x - 150, z - 150, 300, 300, 5, 1 FROM swganh.planet_regions WHERE planet_id = 5 AND region_name = 'Mauler Stronghold'
  UNION ALL SELECT 918, x - 150, z - 150, 300, 300, 5, 1 FROM swganh.planet_regions WHERE planet_id = 5 AND region_name = 'Gungan Warrior Stronghold'
  UNION ALL SELECT 919, x - 120, z - 120, 240, 240, 6, 1 FROM swganh.planet_regions WHERE planet_id = 6 AND region_name = 'Cobral Hideout'
  UNION ALL SELECT 920, x - 150, z - 150, 300, 300, 6, 1 FROM swganh.planet_regions WHERE planet_id = 6 AND region_name = 'Rori Gungan Swamp Town'
  UNION ALL SELECT 921, x - 80, z - 80, 160, 160, 6, 1 FROM swganh.planet_regions WHERE planet_id = 6 AND region_name = 'kobala'
  UNION ALL SELECT 922, x - 100, z - 100, 200, 200, 7, 1 FROM swganh.planet_regions WHERE planet_id = 7 AND region_name = 'Binyare Pirate Base'
  UNION ALL SELECT 923, x - 150, z - 150, 300, 300, 0, 1 FROM swganh.planet_regions WHERE planet_id = 0 AND region_name = 'Nyax Cultists Outpost'
  UNION ALL SELECT 924, x - 60, z - 60, 120, 120, 0, 1 FROM swganh.planet_regions WHERE planet_id = 0 AND region_name = 'afarathu'
  UNION ALL SELECT 925, x - 60, z - 60, 120, 120, 0, 1 FROM swganh.planet_regions WHERE planet_id = 0 AND region_name = 'drall';

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (6001, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6002, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6003, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6004, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6005, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6006, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6007, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6008, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6009, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6010, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6011, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6012, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6013, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6014, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6015, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6016, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6017, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6018, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6019, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6020, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6021, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6022, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6023, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6024, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6025, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6026, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6027, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6028, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6029, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6030, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6031, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6032, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6033, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6034, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6035, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6036, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6037, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6038, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6039, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6040, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6041, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6042, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6043, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6044, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6045, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6046, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6047, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6048, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6049, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6050, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6051, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6052, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  SELECT 1, 6001, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_commoner')
  UNION ALL SELECT 2, 6001, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_raider')
  UNION ALL SELECT 3, 6001, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_sniper')
  UNION ALL SELECT 4, 6002, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_captain')
  UNION ALL SELECT 5, 6002, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_chief')
  UNION ALL SELECT 6, 6003, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_warlord')
  UNION ALL SELECT 7, 6003, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_king')
  UNION ALL SELECT 8, 6003, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'tusken_bantha')
  UNION ALL SELECT 9, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa')
  UNION ALL SELECT 10, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_engineer')
  UNION ALL SELECT 11, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_healer')
  UNION ALL SELECT 12, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_henchman')
  UNION ALL SELECT 13, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_smuggler')
  UNION ALL SELECT 14, 6004, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_thief')
  UNION ALL SELECT 15, 6005, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_leader')
  UNION ALL SELECT 16, 6005, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'jawa_warlord')
  UNION ALL SELECT 17, 6006, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'womprat')
  UNION ALL SELECT 18, 6006, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lesser_desert_womprat')
  UNION ALL SELECT 19, 6007, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_tribesman')
  UNION ALL SELECT 20, 6007, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_herbalist')
  UNION ALL SELECT 21, 6007, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_harvester')
  UNION ALL SELECT 22, 6007, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_hunter')
  UNION ALL SELECT 23, 6008, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_primalist')
  UNION ALL SELECT 24, 6008, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_loreweaver')
  UNION ALL SELECT 25, 6008, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_scout')
  UNION ALL SELECT 26, 6008, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_rockshaper')
  UNION ALL SELECT 27, 6009, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_shaman')
  UNION ALL SELECT 28, 6009, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_soothsayer')
  UNION ALL SELECT 29, 6009, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_warrior')
  UNION ALL SELECT 30, 6009, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'janta_clan_leader')
  UNION ALL SELECT 31, 6010, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_tribesman')
  UNION ALL SELECT 32, 6010, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_herbalist')
  UNION ALL SELECT 33, 6010, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_harvester')
  UNION ALL SELECT 34, 6010, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_soothsayer')
  UNION ALL SELECT 35, 6011, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_clan_primalist')
  UNION ALL SELECT 36, 6011, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_hunter')
  UNION ALL SELECT 37, 6011, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_loreweaver')
  UNION ALL SELECT 38, 6011, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_scout')
  UNION ALL SELECT 39, 6012, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_shaman')
  UNION ALL SELECT 40, 6012, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_rockshaper')
  UNION ALL SELECT 41, 6012, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kunga_warrior')
  UNION ALL SELECT 42, 6013, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_tribesman')
  UNION ALL SELECT 43, 6013, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_herbalist')
  UNION ALL SELECT 44, 6013, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_harvester')
  UNION ALL SELECT 45, 6013, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_hunter')
  UNION ALL SELECT 46, 6014, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_soothsayer')
  UNION ALL SELECT 47, 6014, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_primalist')
  UNION ALL SELECT 48, 6014, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_loreweaver')
  UNION ALL SELECT 49, 6014, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_scout')
  UNION ALL SELECT 50, 6015, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_shaman')
  UNION ALL SELECT 51, 6015, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_rockshaper')
  UNION ALL SELECT 52, 6015, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_warrior')
  UNION ALL SELECT 53, 6015, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mokk_clan_leader')
  UNION ALL SELECT 54, 6016, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider')
  UNION ALL SELECT 55, 6016, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_strategist')
  UNION ALL SELECT 56, 6017, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_battlelord')
  UNION ALL SELECT 57, 6017, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_chief')
  UNION ALL SELECT 58, 6018, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider')
  UNION ALL SELECT 59, 6018, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_strategist')
  UNION ALL SELECT 60, 6019, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_battlelord')
  UNION ALL SELECT 61, 6019, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_chief')
  UNION ALL SELECT 62, 6020, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider')
  UNION ALL SELECT 63, 6020, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_strategist')
  UNION ALL SELECT 64, 6021, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_battlelord')
  UNION ALL SELECT 65, 6021, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'dantari_raider_chief')
  UNION ALL SELECT 66, 6022, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_sentry')
  UNION ALL SELECT 67, 6022, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_initiate')
  UNION ALL SELECT 68, 6022, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_ranger')
  UNION ALL SELECT 69, 6023, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_stalker')
  UNION ALL SELECT 70, 6023, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_rancor_tamer')
  UNION ALL SELECT 71, 6023, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'nightsister_rancor')
  UNION ALL SELECT 72, 6024, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mountain_clan_sentry')
  UNION ALL SELECT 73, 6024, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mtn_clan_initiate')
  UNION ALL SELECT 74, 6024, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mtn_clan_scout')
  UNION ALL SELECT 75, 6025, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mtn_clan_huntress')
  UNION ALL SELECT 76, 6025, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mtn_clan_rancor_tamer')
  UNION ALL SELECT 77, 6025, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mountain_clan_rancor')
  UNION ALL SELECT 78, 6025, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'singing_mtn_clan_dragoon')
  UNION ALL SELECT 79, 6026, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_tribesman')
  UNION ALL SELECT 80, 6026, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_scout')
  UNION ALL SELECT 81, 6026, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_shaman')
  UNION ALL SELECT 82, 6026, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_laborer')
  UNION ALL SELECT 83, 6027, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_battlelord')
  UNION ALL SELECT 84, 6027, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_spiritmaster')
  UNION ALL SELECT 85, 6027, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'donkuwah_chieftan')
  UNION ALL SELECT 86, 6028, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'pubam_tribesman')
  UNION ALL SELECT 87, 6028, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'pubam_scout')
  UNION ALL SELECT 88, 6028, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'pubam_dark_shaman')
  UNION ALL SELECT 89, 6029, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'pubam_battlelord')
  UNION ALL SELECT 90, 6029, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'pubam_chieftan')
  UNION ALL SELECT 91, 6030, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'marauder')
  UNION ALL SELECT 92, 6030, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'feral_marauder')
  UNION ALL SELECT 93, 6030, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'frenzied_marauder')
  UNION ALL SELECT 94, 6031, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_crazed_plains_marauder')
  UNION ALL SELECT 95, 6031, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'grassland_blood_marauder')
  UNION ALL SELECT 96, 6032, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_pirate_weak')
  UNION ALL SELECT 97, 6032, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_scout')
  UNION ALL SELECT 98, 6032, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_cutthroat')
  UNION ALL SELECT 99, 6032, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_pirate_strong')
  UNION ALL SELECT 100, 6033, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_guard')
  UNION ALL SELECT 101, 6033, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_destroyer')
  UNION ALL SELECT 102, 6033, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_pirate_elite')
  UNION ALL SELECT 103, 6034, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'elite_canyon_corsair')
  UNION ALL SELECT 104, 6034, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'canyon_corsair_captain')
  UNION ALL SELECT 105, 6035, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_pirate_weak')
  UNION ALL SELECT 106, 6035, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_pirate_strong')
  UNION ALL SELECT 107, 6035, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_scout')
  UNION ALL SELECT 108, 6035, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_cutthroat')
  UNION ALL SELECT 109, 6036, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_officer')
  UNION ALL SELECT 110, 6036, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_captain')
  UNION ALL SELECT 111, 6036, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'blood_razor_berzerker')
  UNION ALL SELECT 112, 6037, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mauler_apprentice')
  UNION ALL SELECT 113, 6037, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mauler_acolyte')
  UNION ALL SELECT 114, 6037, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mauler')
  UNION ALL SELECT 115, 6038, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mauler_lord')
  UNION ALL SELECT 116, 6038, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'mauler_master')
  UNION ALL SELECT 117, 6039, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_scout')
  UNION ALL SELECT 118, 6039, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_grand_army_soldier')
  UNION ALL SELECT 119, 6039, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_hunter')
  UNION ALL SELECT 120, 6039, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_guard')
  UNION ALL SELECT 121, 6040, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_captain')
  UNION ALL SELECT 122, 6040, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_general')
  UNION ALL SELECT 123, 6040, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_war_chief')
  UNION ALL SELECT 124, 6040, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'gungan_boss')
  UNION ALL SELECT 125, 6041, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_thug')
  UNION ALL SELECT 126, 6041, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_thief')
  UNION ALL SELECT 127, 6041, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_runner')
  UNION ALL SELECT 128, 6041, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_bandit')
  UNION ALL SELECT 129, 6042, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_hitman')
  UNION ALL SELECT 130, 6042, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_assassin')
  UNION ALL SELECT 131, 6042, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_boss')
  UNION ALL SELECT 132, 6042, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'cobral_overlord')
  UNION ALL SELECT 133, 6043, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'rorgungan_scout')
  UNION ALL SELECT 134, 6043, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'rorgungan_commoner')
  UNION ALL SELECT 135, 6043, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'rorgungan_warrior')
  UNION ALL SELECT 136, 6044, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'rorgungan_warchief')
  UNION ALL SELECT 137, 6044, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'rorgungan_boss')
  UNION ALL SELECT 138, 6045, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_miner')
  UNION ALL SELECT 139, 6045, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_smuggler')
  UNION ALL SELECT 140, 6045, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_thief')
  UNION ALL SELECT 141, 6045, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_guard')
  UNION ALL SELECT 142, 6046, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_assassin')
  UNION ALL SELECT 143, 6046, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_pitboss')
  UNION ALL SELECT 144, 6046, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'kobola_underboss')
  UNION ALL SELECT 145, 6047, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_hooligan')
  UNION ALL SELECT 146, 6047, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_scalawag')
  UNION ALL SELECT 147, 6047, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_ruffian')
  UNION ALL SELECT 148, 6047, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_pirate')
  UNION ALL SELECT 149, 6048, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_smuggler')
  UNION ALL SELECT 150, 6048, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_swindler')
  UNION ALL SELECT 151, 6048, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'binayre_chief')
  UNION ALL SELECT 152, 6049, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_minion')
  UNION ALL SELECT 153, 6049, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_servant')
  UNION ALL SELECT 154, 6049, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_disciple')
  UNION ALL SELECT 155, 6050, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_fanatic')
  UNION ALL SELECT 156, 6050, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_zealot')
  UNION ALL SELECT 157, 6050, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_fiend')
  UNION ALL SELECT 158, 6050, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'lord_nyax_visionary')
  UNION ALL SELECT 159, 6051, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'afarathu_cult_follower')
  UNION ALL SELECT 160, 6051, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'afarathu_cult_ruffian')
  UNION ALL SELECT 161, 6051, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'afarathu_cult_savage')
  UNION ALL SELECT 162, 6051, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'afarathu_cult_brute')
  UNION ALL SELECT 163, 6051, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'afarathu_cult_hellion')
  UNION ALL SELECT 164, 6052, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'drall_sentry')
  UNION ALL SELECT 165, 6052, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'drall_monk')
  UNION ALL SELECT 166, 6052, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'drall_guard')
  UNION ALL SELECT 167, 6052, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'drall_patriot')
  UNION ALL SELECT 168, 6052, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND stf_variable_id = 'drall_abbot');

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (6001, 901, 9, 1, 6001, 6001, 4, 0, 0, 0, 1, 0),
  (6002, 901, 9, 1, 6002, 6002, 2, 0, 0, 0, 1, 0),
  (6003, 901, 9, 1, 6003, 6003, 1, 0, 0, 0, 1, 0),
  (6004, 902, 9, 1, 6004, 6004, 3, 0, 0, 0, 1, 0),
  (6005, 902, 9, 1, 6005, 6005, 1, 0, 0, 0, 1, 0),
  (6006, 903, 9, 1, 6006, 6006, 2, 0, 0, 0, 1, 0),
  (6007, 904, 9, 1, 6007, 6007, 3, 0, 0, 0, 1, 0),
  (6008, 904, 9, 1, 6008, 6008, 2, 0, 0, 0, 1, 0),
  (6009, 904, 9, 1, 6009, 6009, 1, 0, 0, 0, 1, 0),
  (6010, 905, 9, 1, 6010, 6010, 3, 0, 0, 0, 1, 0),
  (6011, 905, 9, 1, 6011, 6011, 2, 0, 0, 0, 1, 0),
  (6012, 905, 9, 1, 6012, 6012, 1, 0, 0, 0, 1, 0),
  (6013, 906, 9, 1, 6013, 6013, 3, 0, 0, 0, 1, 0),
  (6014, 906, 9, 1, 6014, 6014, 2, 0, 0, 0, 1, 0),
  (6015, 906, 9, 1, 6015, 6015, 1, 0, 0, 0, 1, 0),
  (6016, 907, 9, 1, 6016, 6016, 2, 0, 0, 0, 1, 0),
  (6017, 907, 9, 1, 6017, 6017, 1, 0, 0, 0, 1, 0),
  (6018, 908, 9, 1, 6018, 6018, 2, 0, 0, 0, 1, 0),
  (6019, 908, 9, 1, 6019, 6019, 1, 0, 0, 0, 1, 0),
  (6020, 909, 9, 1, 6020, 6020, 2, 0, 0, 0, 1, 0),
  (6021, 909, 9, 1, 6021, 6021, 1, 0, 0, 0, 1, 0),
  (6022, 910, 9, 1, 6022, 6022, 3, 0, 0, 0, 1, 0),
  (6023, 910, 9, 1, 6023, 6023, 1, 0, 0, 0, 1, 0),
  (6024, 911, 9, 1, 6024, 6024, 3, 0, 0, 0, 1, 0),
  (6025, 911, 9, 1, 6025, 6025, 1, 0, 0, 0, 1, 0),
  (6026, 912, 9, 1, 6026, 6026, 3, 0, 0, 0, 1, 0),
  (6027, 912, 9, 1, 6027, 6027, 1, 0, 0, 0, 1, 0),
  (6028, 913, 9, 1, 6028, 6028, 3, 0, 0, 0, 1, 0),
  (6029, 913, 9, 1, 6029, 6029, 1, 0, 0, 0, 1, 0),
  (6030, 914, 9, 1, 6030, 6030, 3, 0, 0, 0, 1, 0),
  (6031, 914, 9, 1, 6031, 6031, 1, 0, 0, 0, 1, 0),
  (6032, 915, 9, 1, 6032, 6032, 4, 0, 0, 0, 1, 0),
  (6033, 915, 9, 1, 6033, 6033, 2, 0, 0, 0, 1, 0),
  (6034, 915, 9, 1, 6034, 6034, 1, 0, 0, 0, 1, 0),
  (6035, 916, 9, 1, 6035, 6035, 3, 0, 0, 0, 1, 0),
  (6036, 916, 9, 1, 6036, 6036, 1, 0, 0, 0, 1, 0),
  (6037, 917, 9, 1, 6037, 6037, 3, 0, 0, 0, 1, 0),
  (6038, 917, 9, 1, 6038, 6038, 1, 0, 0, 0, 1, 0),
  (6039, 918, 9, 1, 6039, 6039, 3, 0, 0, 0, 1, 0),
  (6040, 918, 9, 1, 6040, 6040, 1, 0, 0, 0, 1, 0),
  (6041, 919, 9, 1, 6041, 6041, 3, 0, 0, 0, 1, 0),
  (6042, 919, 9, 1, 6042, 6042, 1, 0, 0, 0, 1, 0),
  (6043, 920, 9, 1, 6043, 6043, 3, 0, 0, 0, 1, 0),
  (6044, 920, 9, 1, 6044, 6044, 1, 0, 0, 0, 1, 0),
  (6045, 921, 9, 1, 6045, 6045, 3, 0, 0, 0, 1, 0),
  (6046, 921, 9, 1, 6046, 6046, 1, 0, 0, 0, 1, 0),
  (6047, 922, 9, 1, 6047, 6047, 3, 0, 0, 0, 1, 0),
  (6048, 922, 9, 1, 6048, 6048, 1, 0, 0, 0, 1, 0),
  (6049, 923, 9, 1, 6049, 6049, 3, 0, 0, 0, 1, 0),
  (6050, 923, 9, 1, 6050, 6050, 1, 0, 0, 0, 1, 0),
  (6051, 924, 9, 1, 6051, 6051, 2, 0, 0, 0, 1, 0),
  (6052, 925, 9, 1, 6052, 6052, 2, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 80001 AS id, 6001 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 80002, 6001, 'lair_at_poi', '1'
    UNION ALL SELECT 80003, 6001, 'lair_invisible', '1'
    UNION ALL SELECT 80004, 6001, 'lair_wave_size', '4'
    UNION ALL SELECT 80005, 6001, 'lair_passive_waves', '3'
    UNION ALL SELECT 80006, 6001, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80007, 6001, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80008, 6001, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80009, 6001, 'creature_xp', '0'
    UNION ALL SELECT 80010, 6001, 'creature_health', '1000'
    UNION ALL SELECT 80011, 6001, 'creature_strength', '1000'
    UNION ALL SELECT 80012, 6001, 'creature_constitution', '1000'
    UNION ALL SELECT 80013, 6002, 'lair_fix_position', '0'
    UNION ALL SELECT 80014, 6002, 'lair_at_poi', '1'
    UNION ALL SELECT 80015, 6002, 'lair_invisible', '1'
    UNION ALL SELECT 80016, 6002, 'lair_wave_size', '4'
    UNION ALL SELECT 80017, 6002, 'lair_passive_waves', '3'
    UNION ALL SELECT 80018, 6002, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80019, 6002, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80020, 6002, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80021, 6002, 'creature_xp', '0'
    UNION ALL SELECT 80022, 6002, 'creature_health', '1000'
    UNION ALL SELECT 80023, 6002, 'creature_strength', '1000'
    UNION ALL SELECT 80024, 6002, 'creature_constitution', '1000'
    UNION ALL SELECT 80025, 6003, 'lair_fix_position', '0'
    UNION ALL SELECT 80026, 6003, 'lair_at_poi', '1'
    UNION ALL SELECT 80027, 6003, 'lair_invisible', '1'
    UNION ALL SELECT 80028, 6003, 'lair_wave_size', '4'
    UNION ALL SELECT 80029, 6003, 'lair_passive_waves', '3'
    UNION ALL SELECT 80030, 6003, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80031, 6003, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80032, 6003, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80033, 6003, 'creature_xp', '0'
    UNION ALL SELECT 80034, 6003, 'creature_health', '1000'
    UNION ALL SELECT 80035, 6003, 'creature_strength', '1000'
    UNION ALL SELECT 80036, 6003, 'creature_constitution', '1000'
    UNION ALL SELECT 80037, 6004, 'lair_fix_position', '0'
    UNION ALL SELECT 80038, 6004, 'lair_at_poi', '1'
    UNION ALL SELECT 80039, 6004, 'lair_invisible', '1'
    UNION ALL SELECT 80040, 6004, 'lair_wave_size', '4'
    UNION ALL SELECT 80041, 6004, 'lair_passive_waves', '3'
    UNION ALL SELECT 80042, 6004, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80043, 6004, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80044, 6004, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80045, 6004, 'creature_xp', '0'
    UNION ALL SELECT 80046, 6004, 'creature_health', '1000'
    UNION ALL SELECT 80047, 6004, 'creature_strength', '1000'
    UNION ALL SELECT 80048, 6004, 'creature_constitution', '1000'
    UNION ALL SELECT 80049, 6005, 'lair_fix_position', '0'
    UNION ALL SELECT 80050, 6005, 'lair_at_poi', '1'
    UNION ALL SELECT 80051, 6005, 'lair_invisible', '1'
    UNION ALL SELECT 80052, 6005, 'lair_wave_size', '4'
    UNION ALL SELECT 80053, 6005, 'lair_passive_waves', '3'
    UNION ALL SELECT 80054, 6005, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80055, 6005, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80056, 6005, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80057, 6005, 'creature_xp', '0'
    UNION ALL SELECT 80058, 6005, 'creature_health', '1000'
    UNION ALL SELECT 80059, 6005, 'creature_strength', '1000'
    UNION ALL SELECT 80060, 6005, 'creature_constitution', '1000'
    UNION ALL SELECT 80061, 6006, 'lair_fix_position', '0'
    UNION ALL SELECT 80062, 6006, 'lair_at_poi', '1'
    UNION ALL SELECT 80063, 6006, 'lair_invisible', '1'
    UNION ALL SELECT 80064, 6006, 'lair_wave_size', '4'
    UNION ALL SELECT 80065, 6006, 'lair_passive_waves', '3'
    UNION ALL SELECT 80066, 6006, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80067, 6006, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80068, 6006, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80069, 6006, 'creature_xp', '0'
    UNION ALL SELECT 80070, 6006, 'creature_health', '1000'
    UNION ALL SELECT 80071, 6006, 'creature_strength', '1000'
    UNION ALL SELECT 80072, 6006, 'creature_constitution', '1000'
    UNION ALL SELECT 80073, 6007, 'lair_fix_position', '0'
    UNION ALL SELECT 80074, 6007, 'lair_at_poi', '1'
    UNION ALL SELECT 80075, 6007, 'lair_invisible', '1'
    UNION ALL SELECT 80076, 6007, 'lair_wave_size', '4'
    UNION ALL SELECT 80077, 6007, 'lair_passive_waves', '3'
    UNION ALL SELECT 80078, 6007, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80079, 6007, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80080, 6007, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80081, 6007, 'creature_xp', '0'
    UNION ALL SELECT 80082, 6007, 'creature_health', '1000'
    UNION ALL SELECT 80083, 6007, 'creature_strength', '1000'
    UNION ALL SELECT 80084, 6007, 'creature_constitution', '1000'
    UNION ALL SELECT 80085, 6008, 'lair_fix_position', '0'
    UNION ALL SELECT 80086, 6008, 'lair_at_poi', '1'
    UNION ALL SELECT 80087, 6008, 'lair_invisible', '1'
    UNION ALL SELECT 80088, 6008, 'lair_wave_size', '4'
    UNION ALL SELECT 80089, 6008, 'lair_passive_waves', '3'
    UNION ALL SELECT 80090, 6008, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80091, 6008, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80092, 6008, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80093, 6008, 'creature_xp', '0'
    UNION ALL SELECT 80094, 6008, 'creature_health', '1000'
    UNION ALL SELECT 80095, 6008, 'creature_strength', '1000'
    UNION ALL SELECT 80096, 6008, 'creature_constitution', '1000'
    UNION ALL SELECT 80097, 6009, 'lair_fix_position', '0'
    UNION ALL SELECT 80098, 6009, 'lair_at_poi', '1'
    UNION ALL SELECT 80099, 6009, 'lair_invisible', '1'
    UNION ALL SELECT 80100, 6009, 'lair_wave_size', '4'
    UNION ALL SELECT 80101, 6009, 'lair_passive_waves', '3'
    UNION ALL SELECT 80102, 6009, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80103, 6009, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80104, 6009, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80105, 6009, 'creature_xp', '0'
    UNION ALL SELECT 80106, 6009, 'creature_health', '1000'
    UNION ALL SELECT 80107, 6009, 'creature_strength', '1000'
    UNION ALL SELECT 80108, 6009, 'creature_constitution', '1000'
    UNION ALL SELECT 80109, 6010, 'lair_fix_position', '0'
    UNION ALL SELECT 80110, 6010, 'lair_at_poi', '1'
    UNION ALL SELECT 80111, 6010, 'lair_invisible', '1'
    UNION ALL SELECT 80112, 6010, 'lair_wave_size', '4'
    UNION ALL SELECT 80113, 6010, 'lair_passive_waves', '3'
    UNION ALL SELECT 80114, 6010, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80115, 6010, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80116, 6010, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80117, 6010, 'creature_xp', '0'
    UNION ALL SELECT 80118, 6010, 'creature_health', '1000'
    UNION ALL SELECT 80119, 6010, 'creature_strength', '1000'
    UNION ALL SELECT 80120, 6010, 'creature_constitution', '1000'
    UNION ALL SELECT 80121, 6011, 'lair_fix_position', '0'
    UNION ALL SELECT 80122, 6011, 'lair_at_poi', '1'
    UNION ALL SELECT 80123, 6011, 'lair_invisible', '1'
    UNION ALL SELECT 80124, 6011, 'lair_wave_size', '4'
    UNION ALL SELECT 80125, 6011, 'lair_passive_waves', '3'
    UNION ALL SELECT 80126, 6011, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80127, 6011, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80128, 6011, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80129, 6011, 'creature_xp', '0'
    UNION ALL SELECT 80130, 6011, 'creature_health', '1000'
    UNION ALL SELECT 80131, 6011, 'creature_strength', '1000'
    UNION ALL SELECT 80132, 6011, 'creature_constitution', '1000'
    UNION ALL SELECT 80133, 6012, 'lair_fix_position', '0'
    UNION ALL SELECT 80134, 6012, 'lair_at_poi', '1'
    UNION ALL SELECT 80135, 6012, 'lair_invisible', '1'
    UNION ALL SELECT 80136, 6012, 'lair_wave_size', '4'
    UNION ALL SELECT 80137, 6012, 'lair_passive_waves', '3'
    UNION ALL SELECT 80138, 6012, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80139, 6012, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80140, 6012, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80141, 6012, 'creature_xp', '0'
    UNION ALL SELECT 80142, 6012, 'creature_health', '1000'
    UNION ALL SELECT 80143, 6012, 'creature_strength', '1000'
    UNION ALL SELECT 80144, 6012, 'creature_constitution', '1000'
    UNION ALL SELECT 80145, 6013, 'lair_fix_position', '0'
    UNION ALL SELECT 80146, 6013, 'lair_at_poi', '1'
    UNION ALL SELECT 80147, 6013, 'lair_invisible', '1'
    UNION ALL SELECT 80148, 6013, 'lair_wave_size', '4'
    UNION ALL SELECT 80149, 6013, 'lair_passive_waves', '3'
    UNION ALL SELECT 80150, 6013, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80151, 6013, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80152, 6013, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80153, 6013, 'creature_xp', '0'
    UNION ALL SELECT 80154, 6013, 'creature_health', '1000'
    UNION ALL SELECT 80155, 6013, 'creature_strength', '1000'
    UNION ALL SELECT 80156, 6013, 'creature_constitution', '1000'
    UNION ALL SELECT 80157, 6014, 'lair_fix_position', '0'
    UNION ALL SELECT 80158, 6014, 'lair_at_poi', '1'
    UNION ALL SELECT 80159, 6014, 'lair_invisible', '1'
    UNION ALL SELECT 80160, 6014, 'lair_wave_size', '4'
    UNION ALL SELECT 80161, 6014, 'lair_passive_waves', '3'
    UNION ALL SELECT 80162, 6014, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80163, 6014, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80164, 6014, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80165, 6014, 'creature_xp', '0'
    UNION ALL SELECT 80166, 6014, 'creature_health', '1000'
    UNION ALL SELECT 80167, 6014, 'creature_strength', '1000'
    UNION ALL SELECT 80168, 6014, 'creature_constitution', '1000'
    UNION ALL SELECT 80169, 6015, 'lair_fix_position', '0'
    UNION ALL SELECT 80170, 6015, 'lair_at_poi', '1'
    UNION ALL SELECT 80171, 6015, 'lair_invisible', '1'
    UNION ALL SELECT 80172, 6015, 'lair_wave_size', '4'
    UNION ALL SELECT 80173, 6015, 'lair_passive_waves', '3'
    UNION ALL SELECT 80174, 6015, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80175, 6015, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80176, 6015, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80177, 6015, 'creature_xp', '0'
    UNION ALL SELECT 80178, 6015, 'creature_health', '1000'
    UNION ALL SELECT 80179, 6015, 'creature_strength', '1000'
    UNION ALL SELECT 80180, 6015, 'creature_constitution', '1000'
    UNION ALL SELECT 80181, 6016, 'lair_fix_position', '0'
    UNION ALL SELECT 80182, 6016, 'lair_at_poi', '1'
    UNION ALL SELECT 80183, 6016, 'lair_invisible', '1'
    UNION ALL SELECT 80184, 6016, 'lair_wave_size', '4'
    UNION ALL SELECT 80185, 6016, 'lair_passive_waves', '3'
    UNION ALL SELECT 80186, 6016, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80187, 6016, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80188, 6016, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80189, 6016, 'creature_xp', '0'
    UNION ALL SELECT 80190, 6016, 'creature_health', '1000'
    UNION ALL SELECT 80191, 6016, 'creature_strength', '1000'
    UNION ALL SELECT 80192, 6016, 'creature_constitution', '1000'
    UNION ALL SELECT 80193, 6017, 'lair_fix_position', '0'
    UNION ALL SELECT 80194, 6017, 'lair_at_poi', '1'
    UNION ALL SELECT 80195, 6017, 'lair_invisible', '1'
    UNION ALL SELECT 80196, 6017, 'lair_wave_size', '4'
    UNION ALL SELECT 80197, 6017, 'lair_passive_waves', '3'
    UNION ALL SELECT 80198, 6017, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80199, 6017, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80200, 6017, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80201, 6017, 'creature_xp', '0'
    UNION ALL SELECT 80202, 6017, 'creature_health', '1000'
    UNION ALL SELECT 80203, 6017, 'creature_strength', '1000'
    UNION ALL SELECT 80204, 6017, 'creature_constitution', '1000'
    UNION ALL SELECT 80205, 6018, 'lair_fix_position', '0'
    UNION ALL SELECT 80206, 6018, 'lair_at_poi', '1'
    UNION ALL SELECT 80207, 6018, 'lair_invisible', '1'
    UNION ALL SELECT 80208, 6018, 'lair_wave_size', '4'
    UNION ALL SELECT 80209, 6018, 'lair_passive_waves', '3'
    UNION ALL SELECT 80210, 6018, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80211, 6018, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80212, 6018, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80213, 6018, 'creature_xp', '0'
    UNION ALL SELECT 80214, 6018, 'creature_health', '1000'
    UNION ALL SELECT 80215, 6018, 'creature_strength', '1000'
    UNION ALL SELECT 80216, 6018, 'creature_constitution', '1000'
    UNION ALL SELECT 80217, 6019, 'lair_fix_position', '0'
    UNION ALL SELECT 80218, 6019, 'lair_at_poi', '1'
    UNION ALL SELECT 80219, 6019, 'lair_invisible', '1'
    UNION ALL SELECT 80220, 6019, 'lair_wave_size', '4'
    UNION ALL SELECT 80221, 6019, 'lair_passive_waves', '3'
    UNION ALL SELECT 80222, 6019, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80223, 6019, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80224, 6019, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80225, 6019, 'creature_xp', '0'
    UNION ALL SELECT 80226, 6019, 'creature_health', '1000'
    UNION ALL SELECT 80227, 6019, 'creature_strength', '1000'
    UNION ALL SELECT 80228, 6019, 'creature_constitution', '1000'
    UNION ALL SELECT 80229, 6020, 'lair_fix_position', '0'
    UNION ALL SELECT 80230, 6020, 'lair_at_poi', '1'
    UNION ALL SELECT 80231, 6020, 'lair_invisible', '1'
    UNION ALL SELECT 80232, 6020, 'lair_wave_size', '4'
    UNION ALL SELECT 80233, 6020, 'lair_passive_waves', '3'
    UNION ALL SELECT 80234, 6020, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80235, 6020, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80236, 6020, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80237, 6020, 'creature_xp', '0'
    UNION ALL SELECT 80238, 6020, 'creature_health', '1000'
    UNION ALL SELECT 80239, 6020, 'creature_strength', '1000'
    UNION ALL SELECT 80240, 6020, 'creature_constitution', '1000'
    UNION ALL SELECT 80241, 6021, 'lair_fix_position', '0'
    UNION ALL SELECT 80242, 6021, 'lair_at_poi', '1'
    UNION ALL SELECT 80243, 6021, 'lair_invisible', '1'
    UNION ALL SELECT 80244, 6021, 'lair_wave_size', '4'
    UNION ALL SELECT 80245, 6021, 'lair_passive_waves', '3'
    UNION ALL SELECT 80246, 6021, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80247, 6021, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80248, 6021, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80249, 6021, 'creature_xp', '0'
    UNION ALL SELECT 80250, 6021, 'creature_health', '1000'
    UNION ALL SELECT 80251, 6021, 'creature_strength', '1000'
    UNION ALL SELECT 80252, 6021, 'creature_constitution', '1000'
    UNION ALL SELECT 80253, 6022, 'lair_fix_position', '0'
    UNION ALL SELECT 80254, 6022, 'lair_at_poi', '1'
    UNION ALL SELECT 80255, 6022, 'lair_invisible', '1'
    UNION ALL SELECT 80256, 6022, 'lair_wave_size', '4'
    UNION ALL SELECT 80257, 6022, 'lair_passive_waves', '3'
    UNION ALL SELECT 80258, 6022, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80259, 6022, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80260, 6022, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80261, 6022, 'creature_xp', '0'
    UNION ALL SELECT 80262, 6022, 'creature_health', '1000'
    UNION ALL SELECT 80263, 6022, 'creature_strength', '1000'
    UNION ALL SELECT 80264, 6022, 'creature_constitution', '1000'
    UNION ALL SELECT 80265, 6023, 'lair_fix_position', '0'
    UNION ALL SELECT 80266, 6023, 'lair_at_poi', '1'
    UNION ALL SELECT 80267, 6023, 'lair_invisible', '1'
    UNION ALL SELECT 80268, 6023, 'lair_wave_size', '4'
    UNION ALL SELECT 80269, 6023, 'lair_passive_waves', '3'
    UNION ALL SELECT 80270, 6023, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80271, 6023, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80272, 6023, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80273, 6023, 'creature_xp', '0'
    UNION ALL SELECT 80274, 6023, 'creature_health', '1000'
    UNION ALL SELECT 80275, 6023, 'creature_strength', '1000'
    UNION ALL SELECT 80276, 6023, 'creature_constitution', '1000'
    UNION ALL SELECT 80277, 6024, 'lair_fix_position', '0'
    UNION ALL SELECT 80278, 6024, 'lair_at_poi', '1'
    UNION ALL SELECT 80279, 6024, 'lair_invisible', '1'
    UNION ALL SELECT 80280, 6024, 'lair_wave_size', '4'
    UNION ALL SELECT 80281, 6024, 'lair_passive_waves', '3'
    UNION ALL SELECT 80282, 6024, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80283, 6024, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80284, 6024, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80285, 6024, 'creature_xp', '0'
    UNION ALL SELECT 80286, 6024, 'creature_health', '1000'
    UNION ALL SELECT 80287, 6024, 'creature_strength', '1000'
    UNION ALL SELECT 80288, 6024, 'creature_constitution', '1000'
    UNION ALL SELECT 80289, 6025, 'lair_fix_position', '0'
    UNION ALL SELECT 80290, 6025, 'lair_at_poi', '1'
    UNION ALL SELECT 80291, 6025, 'lair_invisible', '1'
    UNION ALL SELECT 80292, 6025, 'lair_wave_size', '4'
    UNION ALL SELECT 80293, 6025, 'lair_passive_waves', '3'
    UNION ALL SELECT 80294, 6025, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80295, 6025, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80296, 6025, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80297, 6025, 'creature_xp', '0'
    UNION ALL SELECT 80298, 6025, 'creature_health', '1000'
    UNION ALL SELECT 80299, 6025, 'creature_strength', '1000'
    UNION ALL SELECT 80300, 6025, 'creature_constitution', '1000'
    UNION ALL SELECT 80301, 6026, 'lair_fix_position', '0'
    UNION ALL SELECT 80302, 6026, 'lair_at_poi', '1'
    UNION ALL SELECT 80303, 6026, 'lair_invisible', '1'
    UNION ALL SELECT 80304, 6026, 'lair_wave_size', '4'
    UNION ALL SELECT 80305, 6026, 'lair_passive_waves', '3'
    UNION ALL SELECT 80306, 6026, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80307, 6026, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80308, 6026, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80309, 6026, 'creature_xp', '0'
    UNION ALL SELECT 80310, 6026, 'creature_health', '1000'
    UNION ALL SELECT 80311, 6026, 'creature_strength', '1000'
    UNION ALL SELECT 80312, 6026, 'creature_constitution', '1000'
    UNION ALL SELECT 80313, 6027, 'lair_fix_position', '0'
    UNION ALL SELECT 80314, 6027, 'lair_at_poi', '1'
    UNION ALL SELECT 80315, 6027, 'lair_invisible', '1'
    UNION ALL SELECT 80316, 6027, 'lair_wave_size', '4'
    UNION ALL SELECT 80317, 6027, 'lair_passive_waves', '3'
    UNION ALL SELECT 80318, 6027, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80319, 6027, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80320, 6027, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80321, 6027, 'creature_xp', '0'
    UNION ALL SELECT 80322, 6027, 'creature_health', '1000'
    UNION ALL SELECT 80323, 6027, 'creature_strength', '1000'
    UNION ALL SELECT 80324, 6027, 'creature_constitution', '1000'
    UNION ALL SELECT 80325, 6028, 'lair_fix_position', '0'
    UNION ALL SELECT 80326, 6028, 'lair_at_poi', '1'
    UNION ALL SELECT 80327, 6028, 'lair_invisible', '1'
    UNION ALL SELECT 80328, 6028, 'lair_wave_size', '4'
    UNION ALL SELECT 80329, 6028, 'lair_passive_waves', '3'
    UNION ALL SELECT 80330, 6028, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80331, 6028, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80332, 6028, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80333, 6028, 'creature_xp', '0'
    UNION ALL SELECT 80334, 6028, 'creature_health', '1000'
    UNION ALL SELECT 80335, 6028, 'creature_strength', '1000'
    UNION ALL SELECT 80336, 6028, 'creature_constitution', '1000'
    UNION ALL SELECT 80337, 6029, 'lair_fix_position', '0'
    UNION ALL SELECT 80338, 6029, 'lair_at_poi', '1'
    UNION ALL SELECT 80339, 6029, 'lair_invisible', '1'
    UNION ALL SELECT 80340, 6029, 'lair_wave_size', '4'
    UNION ALL SELECT 80341, 6029, 'lair_passive_waves', '3'
    UNION ALL SELECT 80342, 6029, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80343, 6029, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80344, 6029, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80345, 6029, 'creature_xp', '0'
    UNION ALL SELECT 80346, 6029, 'creature_health', '1000'
    UNION ALL SELECT 80347, 6029, 'creature_strength', '1000'
    UNION ALL SELECT 80348, 6029, 'creature_constitution', '1000'
    UNION ALL SELECT 80349, 6030, 'lair_fix_position', '0'
    UNION ALL SELECT 80350, 6030, 'lair_at_poi', '1'
    UNION ALL SELECT 80351, 6030, 'lair_invisible', '1'
    UNION ALL SELECT 80352, 6030, 'lair_wave_size', '4'
    UNION ALL SELECT 80353, 6030, 'lair_passive_waves', '3'
    UNION ALL SELECT 80354, 6030, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80355, 6030, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80356, 6030, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80357, 6030, 'creature_xp', '0'
    UNION ALL SELECT 80358, 6030, 'creature_health', '1000'
    UNION ALL SELECT 80359, 6030, 'creature_strength', '1000'
    UNION ALL SELECT 80360, 6030, 'creature_constitution', '1000'
    UNION ALL SELECT 80361, 6031, 'lair_fix_position', '0'
    UNION ALL SELECT 80362, 6031, 'lair_at_poi', '1'
    UNION ALL SELECT 80363, 6031, 'lair_invisible', '1'
    UNION ALL SELECT 80364, 6031, 'lair_wave_size', '4'
    UNION ALL SELECT 80365, 6031, 'lair_passive_waves', '3'
    UNION ALL SELECT 80366, 6031, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80367, 6031, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80368, 6031, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80369, 6031, 'creature_xp', '0'
    UNION ALL SELECT 80370, 6031, 'creature_health', '1000'
    UNION ALL SELECT 80371, 6031, 'creature_strength', '1000'
    UNION ALL SELECT 80372, 6031, 'creature_constitution', '1000'
    UNION ALL SELECT 80373, 6032, 'lair_fix_position', '0'
    UNION ALL SELECT 80374, 6032, 'lair_at_poi', '1'
    UNION ALL SELECT 80375, 6032, 'lair_invisible', '1'
    UNION ALL SELECT 80376, 6032, 'lair_wave_size', '4'
    UNION ALL SELECT 80377, 6032, 'lair_passive_waves', '3'
    UNION ALL SELECT 80378, 6032, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80379, 6032, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80380, 6032, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80381, 6032, 'creature_xp', '0'
    UNION ALL SELECT 80382, 6032, 'creature_health', '1000'
    UNION ALL SELECT 80383, 6032, 'creature_strength', '1000'
    UNION ALL SELECT 80384, 6032, 'creature_constitution', '1000'
    UNION ALL SELECT 80385, 6033, 'lair_fix_position', '0'
    UNION ALL SELECT 80386, 6033, 'lair_at_poi', '1'
    UNION ALL SELECT 80387, 6033, 'lair_invisible', '1'
    UNION ALL SELECT 80388, 6033, 'lair_wave_size', '4'
    UNION ALL SELECT 80389, 6033, 'lair_passive_waves', '3'
    UNION ALL SELECT 80390, 6033, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80391, 6033, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80392, 6033, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80393, 6033, 'creature_xp', '0'
    UNION ALL SELECT 80394, 6033, 'creature_health', '1000'
    UNION ALL SELECT 80395, 6033, 'creature_strength', '1000'
    UNION ALL SELECT 80396, 6033, 'creature_constitution', '1000'
    UNION ALL SELECT 80397, 6034, 'lair_fix_position', '0'
    UNION ALL SELECT 80398, 6034, 'lair_at_poi', '1'
    UNION ALL SELECT 80399, 6034, 'lair_invisible', '1'
    UNION ALL SELECT 80400, 6034, 'lair_wave_size', '4'
    UNION ALL SELECT 80401, 6034, 'lair_passive_waves', '3'
    UNION ALL SELECT 80402, 6034, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80403, 6034, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80404, 6034, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80405, 6034, 'creature_xp', '0'
    UNION ALL SELECT 80406, 6034, 'creature_health', '1000'
    UNION ALL SELECT 80407, 6034, 'creature_strength', '1000'
    UNION ALL SELECT 80408, 6034, 'creature_constitution', '1000'
    UNION ALL SELECT 80409, 6035, 'lair_fix_position', '0'
    UNION ALL SELECT 80410, 6035, 'lair_at_poi', '1'
    UNION ALL SELECT 80411, 6035, 'lair_invisible', '1'
    UNION ALL SELECT 80412, 6035, 'lair_wave_size', '4'
    UNION ALL SELECT 80413, 6035, 'lair_passive_waves', '3'
    UNION ALL SELECT 80414, 6035, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80415, 6035, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80416, 6035, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80417, 6035, 'creature_xp', '0'
    UNION ALL SELECT 80418, 6035, 'creature_health', '1000'
    UNION ALL SELECT 80419, 6035, 'creature_strength', '1000'
    UNION ALL SELECT 80420, 6035, 'creature_constitution', '1000'
    UNION ALL SELECT 80421, 6036, 'lair_fix_position', '0'
    UNION ALL SELECT 80422, 6036, 'lair_at_poi', '1'
    UNION ALL SELECT 80423, 6036, 'lair_invisible', '1'
    UNION ALL SELECT 80424, 6036, 'lair_wave_size', '4'
    UNION ALL SELECT 80425, 6036, 'lair_passive_waves', '3'
    UNION ALL SELECT 80426, 6036, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80427, 6036, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80428, 6036, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80429, 6036, 'creature_xp', '0'
    UNION ALL SELECT 80430, 6036, 'creature_health', '1000'
    UNION ALL SELECT 80431, 6036, 'creature_strength', '1000'
    UNION ALL SELECT 80432, 6036, 'creature_constitution', '1000'
    UNION ALL SELECT 80433, 6037, 'lair_fix_position', '0'
    UNION ALL SELECT 80434, 6037, 'lair_at_poi', '1'
    UNION ALL SELECT 80435, 6037, 'lair_invisible', '1'
    UNION ALL SELECT 80436, 6037, 'lair_wave_size', '4'
    UNION ALL SELECT 80437, 6037, 'lair_passive_waves', '3'
    UNION ALL SELECT 80438, 6037, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80439, 6037, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80440, 6037, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80441, 6037, 'creature_xp', '0'
    UNION ALL SELECT 80442, 6037, 'creature_health', '1000'
    UNION ALL SELECT 80443, 6037, 'creature_strength', '1000'
    UNION ALL SELECT 80444, 6037, 'creature_constitution', '1000'
    UNION ALL SELECT 80445, 6038, 'lair_fix_position', '0'
    UNION ALL SELECT 80446, 6038, 'lair_at_poi', '1'
    UNION ALL SELECT 80447, 6038, 'lair_invisible', '1'
    UNION ALL SELECT 80448, 6038, 'lair_wave_size', '4'
    UNION ALL SELECT 80449, 6038, 'lair_passive_waves', '3'
    UNION ALL SELECT 80450, 6038, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80451, 6038, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80452, 6038, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80453, 6038, 'creature_xp', '0'
    UNION ALL SELECT 80454, 6038, 'creature_health', '1000'
    UNION ALL SELECT 80455, 6038, 'creature_strength', '1000'
    UNION ALL SELECT 80456, 6038, 'creature_constitution', '1000'
    UNION ALL SELECT 80457, 6039, 'lair_fix_position', '0'
    UNION ALL SELECT 80458, 6039, 'lair_at_poi', '1'
    UNION ALL SELECT 80459, 6039, 'lair_invisible', '1'
    UNION ALL SELECT 80460, 6039, 'lair_wave_size', '4'
    UNION ALL SELECT 80461, 6039, 'lair_passive_waves', '3'
    UNION ALL SELECT 80462, 6039, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80463, 6039, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80464, 6039, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80465, 6039, 'creature_xp', '0'
    UNION ALL SELECT 80466, 6039, 'creature_health', '1000'
    UNION ALL SELECT 80467, 6039, 'creature_strength', '1000'
    UNION ALL SELECT 80468, 6039, 'creature_constitution', '1000'
    UNION ALL SELECT 80469, 6040, 'lair_fix_position', '0'
    UNION ALL SELECT 80470, 6040, 'lair_at_poi', '1'
    UNION ALL SELECT 80471, 6040, 'lair_invisible', '1'
    UNION ALL SELECT 80472, 6040, 'lair_wave_size', '4'
    UNION ALL SELECT 80473, 6040, 'lair_passive_waves', '3'
    UNION ALL SELECT 80474, 6040, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80475, 6040, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80476, 6040, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80477, 6040, 'creature_xp', '0'
    UNION ALL SELECT 80478, 6040, 'creature_health', '1000'
    UNION ALL SELECT 80479, 6040, 'creature_strength', '1000'
    UNION ALL SELECT 80480, 6040, 'creature_constitution', '1000'
    UNION ALL SELECT 80481, 6041, 'lair_fix_position', '0'
    UNION ALL SELECT 80482, 6041, 'lair_at_poi', '1'
    UNION ALL SELECT 80483, 6041, 'lair_invisible', '1'
    UNION ALL SELECT 80484, 6041, 'lair_wave_size', '4'
    UNION ALL SELECT 80485, 6041, 'lair_passive_waves', '3'
    UNION ALL SELECT 80486, 6041, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80487, 6041, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80488, 6041, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80489, 6041, 'creature_xp', '0'
    UNION ALL SELECT 80490, 6041, 'creature_health', '1000'
    UNION ALL SELECT 80491, 6041, 'creature_strength', '1000'
    UNION ALL SELECT 80492, 6041, 'creature_constitution', '1000'
    UNION ALL SELECT 80493, 6042, 'lair_fix_position', '0'
    UNION ALL SELECT 80494, 6042, 'lair_at_poi', '1'
    UNION ALL SELECT 80495, 6042, 'lair_invisible', '1'
    UNION ALL SELECT 80496, 6042, 'lair_wave_size', '4'
    UNION ALL SELECT 80497, 6042, 'lair_passive_waves', '3'
    UNION ALL SELECT 80498, 6042, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80499, 6042, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80500, 6042, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80501, 6042, 'creature_xp', '0'
    UNION ALL SELECT 80502, 6042, 'creature_health', '1000'
    UNION ALL SELECT 80503, 6042, 'creature_strength', '1000'
    UNION ALL SELECT 80504, 6042, 'creature_constitution', '1000'
    UNION ALL SELECT 80505, 6043, 'lair_fix_position', '0'
    UNION ALL SELECT 80506, 6043, 'lair_at_poi', '1'
    UNION ALL SELECT 80507, 6043, 'lair_invisible', '1'
    UNION ALL SELECT 80508, 6043, 'lair_wave_size', '4'
    UNION ALL SELECT 80509, 6043, 'lair_passive_waves', '3'
    UNION ALL SELECT 80510, 6043, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80511, 6043, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80512, 6043, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80513, 6043, 'creature_xp', '0'
    UNION ALL SELECT 80514, 6043, 'creature_health', '1000'
    UNION ALL SELECT 80515, 6043, 'creature_strength', '1000'
    UNION ALL SELECT 80516, 6043, 'creature_constitution', '1000'
    UNION ALL SELECT 80517, 6044, 'lair_fix_position', '0'
    UNION ALL SELECT 80518, 6044, 'lair_at_poi', '1'
    UNION ALL SELECT 80519, 6044, 'lair_invisible', '1'
    UNION ALL SELECT 80520, 6044, 'lair_wave_size', '4'
    UNION ALL SELECT 80521, 6044, 'lair_passive_waves', '3'
    UNION ALL SELECT 80522, 6044, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80523, 6044, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80524, 6044, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80525, 6044, 'creature_xp', '0'
    UNION ALL SELECT 80526, 6044, 'creature_health', '1000'
    UNION ALL SELECT 80527, 6044, 'creature_strength', '1000'
    UNION ALL SELECT 80528, 6044, 'creature_constitution', '1000'
    UNION ALL SELECT 80529, 6045, 'lair_fix_position', '0'
    UNION ALL SELECT 80530, 6045, 'lair_at_poi', '1'
    UNION ALL SELECT 80531, 6045, 'lair_invisible', '1'
    UNION ALL SELECT 80532, 6045, 'lair_wave_size', '4'
    UNION ALL SELECT 80533, 6045, 'lair_passive_waves', '3'
    UNION ALL SELECT 80534, 6045, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80535, 6045, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80536, 6045, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80537, 6045, 'creature_xp', '0'
    UNION ALL SELECT 80538, 6045, 'creature_health', '1000'
    UNION ALL SELECT 80539, 6045, 'creature_strength', '1000'
    UNION ALL SELECT 80540, 6045, 'creature_constitution', '1000'
    UNION ALL SELECT 80541, 6046, 'lair_fix_position', '0'
    UNION ALL SELECT 80542, 6046, 'lair_at_poi', '1'
    UNION ALL SELECT 80543, 6046, 'lair_invisible', '1'
    UNION ALL SELECT 80544, 6046, 'lair_wave_size', '4'
    UNION ALL SELECT 80545, 6046, 'lair_passive_waves', '3'
    UNION ALL SELECT 80546, 6046, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80547, 6046, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80548, 6046, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80549, 6046, 'creature_xp', '0'
    UNION ALL SELECT 80550, 6046, 'creature_health', '1000'
    UNION ALL SELECT 80551, 6046, 'creature_strength', '1000'
    UNION ALL SELECT 80552, 6046, 'creature_constitution', '1000'
    UNION ALL SELECT 80553, 6047, 'lair_fix_position', '0'
    UNION ALL SELECT 80554, 6047, 'lair_at_poi', '1'
    UNION ALL SELECT 80555, 6047, 'lair_invisible', '1'
    UNION ALL SELECT 80556, 6047, 'lair_wave_size', '4'
    UNION ALL SELECT 80557, 6047, 'lair_passive_waves', '3'
    UNION ALL SELECT 80558, 6047, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80559, 6047, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80560, 6047, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80561, 6047, 'creature_xp', '0'
    UNION ALL SELECT 80562, 6047, 'creature_health', '1000'
    UNION ALL SELECT 80563, 6047, 'creature_strength', '1000'
    UNION ALL SELECT 80564, 6047, 'creature_constitution', '1000'
    UNION ALL SELECT 80565, 6048, 'lair_fix_position', '0'
    UNION ALL SELECT 80566, 6048, 'lair_at_poi', '1'
    UNION ALL SELECT 80567, 6048, 'lair_invisible', '1'
    UNION ALL SELECT 80568, 6048, 'lair_wave_size', '4'
    UNION ALL SELECT 80569, 6048, 'lair_passive_waves', '3'
    UNION ALL SELECT 80570, 6048, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80571, 6048, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80572, 6048, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80573, 6048, 'creature_xp', '0'
    UNION ALL SELECT 80574, 6048, 'creature_health', '1000'
    UNION ALL SELECT 80575, 6048, 'creature_strength', '1000'
    UNION ALL SELECT 80576, 6048, 'creature_constitution', '1000'
    UNION ALL SELECT 80577, 6049, 'lair_fix_position', '0'
    UNION ALL SELECT 80578, 6049, 'lair_at_poi', '1'
    UNION ALL SELECT 80579, 6049, 'lair_invisible', '1'
    UNION ALL SELECT 80580, 6049, 'lair_wave_size', '4'
    UNION ALL SELECT 80581, 6049, 'lair_passive_waves', '3'
    UNION ALL SELECT 80582, 6049, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80583, 6049, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80584, 6049, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80585, 6049, 'creature_xp', '0'
    UNION ALL SELECT 80586, 6049, 'creature_health', '1000'
    UNION ALL SELECT 80587, 6049, 'creature_strength', '1000'
    UNION ALL SELECT 80588, 6049, 'creature_constitution', '1000'
    UNION ALL SELECT 80589, 6050, 'lair_fix_position', '0'
    UNION ALL SELECT 80590, 6050, 'lair_at_poi', '1'
    UNION ALL SELECT 80591, 6050, 'lair_invisible', '1'
    UNION ALL SELECT 80592, 6050, 'lair_wave_size', '4'
    UNION ALL SELECT 80593, 6050, 'lair_passive_waves', '3'
    UNION ALL SELECT 80594, 6050, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80595, 6050, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80596, 6050, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80597, 6050, 'creature_xp', '0'
    UNION ALL SELECT 80598, 6050, 'creature_health', '1000'
    UNION ALL SELECT 80599, 6050, 'creature_strength', '1000'
    UNION ALL SELECT 80600, 6050, 'creature_constitution', '1000'
    UNION ALL SELECT 80601, 6051, 'lair_fix_position', '0'
    UNION ALL SELECT 80602, 6051, 'lair_at_poi', '1'
    UNION ALL SELECT 80603, 6051, 'lair_invisible', '1'
    UNION ALL SELECT 80604, 6051, 'lair_wave_size', '4'
    UNION ALL SELECT 80605, 6051, 'lair_passive_waves', '3'
    UNION ALL SELECT 80606, 6051, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80607, 6051, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80608, 6051, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80609, 6051, 'creature_xp', '0'
    UNION ALL SELECT 80610, 6051, 'creature_health', '1000'
    UNION ALL SELECT 80611, 6051, 'creature_strength', '1000'
    UNION ALL SELECT 80612, 6051, 'creature_constitution', '1000'
    UNION ALL SELECT 80613, 6052, 'lair_fix_position', '0'
    UNION ALL SELECT 80614, 6052, 'lair_at_poi', '1'
    UNION ALL SELECT 80615, 6052, 'lair_invisible', '1'
    UNION ALL SELECT 80616, 6052, 'lair_wave_size', '4'
    UNION ALL SELECT 80617, 6052, 'lair_passive_waves', '3'
    UNION ALL SELECT 80618, 6052, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 80619, 6052, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 80620, 6052, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 80621, 6052, 'creature_xp', '0'
    UNION ALL SELECT 80622, 6052, 'creature_health', '1000'
    UNION ALL SELECT 80623, 6052, 'creature_strength', '1000'
    UNION ALL SELECT 80624, 6052, 'creature_constitution', '1000'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
