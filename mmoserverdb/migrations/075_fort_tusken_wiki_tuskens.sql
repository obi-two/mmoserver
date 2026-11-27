--     python3 tools/reference/fort_tusken_sql.py > mmoserverdb/migrations/075_fort_tusken_wiki_tuskens.sql
-- 
-- Fort Tusken was the hard place: players remember Jedi grinding there. An
-- Empire Divided's Tuskens (levels 9-20) made it easy, so the fort gets its
-- own commoner, captain, chief and elite guard with the stats of the swganh
-- wiki's Tusken pages (mmoserverdb/reference/swganh_wiki/tuskens.csv; levels
-- 16-44, killers and stalkers but the commoner). The Tusken village and the
-- Tusken camps keep the book's. The wiki has no raider, sniper, warlord,
-- King or bantha: those stay the book's (An Empire Divided, p. 476).
-- 
-- It replaces migration 073's three fort lairs (6001-6003) with four
-- (6101-6104) in the same spawn area (901):
--   4 x commoner (wiki), raider, sniper (book)
--   3 x captain, chief (wiki)
--   2 x elite guard (wiki)
--   1 x warlord, King, bantha (book)
-- Reconstructed, and data to tune: the mix and counts; the Tusken rifle each
-- one carries (reach 64 m). The armour is shown on examine only: combat does
-- not use creature armour yet. Waves (Publish 1 notes, 13 August 2003: "Set
-- up Fort Tusken to spawn in waves") come later.
-- 
-- Written by tools/reference/fort_tusken_sql.py; edit that, not this.
--
--   12001 Tusken commoner     lvl 16 HAM 2900-3500, 170-180 dmg, 31% to hit, 690 XP (oldid 74984)
--   12002 Tusken captain      lvl 40 HAM 9300-11300, 345-400 dmg, 44% to hit, 4006 XP, killer, stalker (oldid 74981)
--   12003 Tusken chief        lvl 43 HAM 9600-11800, 365-440 dmg, 46% to hit, 4279 XP, killer, stalker (oldid 74983)
--   12004 Tusken elite guard  lvl 44 HAM 9600-11800, 365-440 dmg, 46% to hit, 4370 XP, killer, stalker (oldid 74985)
--

SET FOREIGN_KEY_CHECKS = 0;

-- Migration 073's fort lairs.
DELETE FROM swganh.lair_attributes WHERE lair_id IN (6001, 6002, 6003);
DELETE FROM swganh.creature_groups WHERE creature_group_id IN (6001, 6002, 6003);
DELETE FROM swganh.lairs WHERE id IN (6001, 6002, 6003);
DELETE FROM swganh.lair_templates WHERE id IN (6001, 6002, 6003);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (12001, 8, 1, 1, 'object/mobile/shared_tusken_raider.iff', 'tusken_commoner', 'mob/creature_names', 16, 1, 0, 0, 0, 1),
  (12002, 8, 1, 1, 'object/mobile/shared_tusken_raider.iff', 'tusken_captain', 'mob/creature_names', 40, 1, 0, 0, 0, 1),
  (12003, 8, 1, 1, 'object/mobile/shared_tusken_raider.iff', 'tusken_chief', 'mob/creature_names', 43, 1, 0, 0, 0, 1),
  (12004, 8, 1, 1, 'object/mobile/shared_tusken_raider.iff', 'tusken_elite_guard', 'mob/creature_names', 44, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 12001 AS npc_id, 'creature_health' AS name, '3200' AS value
    UNION ALL SELECT 12001, 'creature_strength', '3200'
    UNION ALL SELECT 12001, 'creature_constitution', '3200'
    UNION ALL SELECT 12001, 'creature_action', '3200'
    UNION ALL SELECT 12001, 'creature_quickness', '3200'
    UNION ALL SELECT 12001, 'creature_stamina', '3200'
    UNION ALL SELECT 12001, 'creature_mind', '3200'
    UNION ALL SELECT 12001, 'creature_focus', '3200'
    UNION ALL SELECT 12001, 'creature_willpower', '3200'
    UNION ALL SELECT 12001, 'creature_ham_min', '2900'
    UNION ALL SELECT 12001, 'creature_ham_max', '3500'
    UNION ALL SELECT 12001, 'creature_tohit', '31'
    UNION ALL SELECT 12001, 'creature_damage_min', '170'
    UNION ALL SELECT 12001, 'creature_damage_max', '180'
    UNION ALL SELECT 12001, 'creature_xp', '690'
    UNION ALL SELECT 12001, 'creature_social_group', 'Tusken Raider'
    UNION ALL SELECT 12001, 'killer', '0'
    UNION ALL SELECT 12001, 'Pack', '1'
    UNION ALL SELECT 12001, 'Herd', '0'
    UNION ALL SELECT 12001, 'stalking', '0'
    UNION ALL SELECT 12001, 'creature_is_aggressive', '1'
    UNION ALL SELECT 12001, 'creature_group_assist', '1'
    UNION ALL SELECT 12001, 'tamable', '0'
    UNION ALL SELECT 12001, 'creature_weapon', 'object/weapon/ranged/rifle/shared_rifle_tusken.iff'
    UNION ALL SELECT 12001, 'creature_humanoid', '1'
    UNION ALL SELECT 12001, 'creature_damage_max_range', '64'
    UNION ALL SELECT 12001, 'creature_is_roaming', '1'
    UNION ALL SELECT 12001, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 12001, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 12001, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_elemental_acid', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_blast', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_elemental_cold', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_elemental_electrical', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_energy', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_elemental_heat', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_kinetic', '5'
    UNION ALL SELECT 12001, 'cat_armor_effectiveness.armor_eff_stun', '5'
    UNION ALL SELECT 12002, 'creature_health', '10300'
    UNION ALL SELECT 12002, 'creature_strength', '10300'
    UNION ALL SELECT 12002, 'creature_constitution', '10300'
    UNION ALL SELECT 12002, 'creature_action', '10300'
    UNION ALL SELECT 12002, 'creature_quickness', '10300'
    UNION ALL SELECT 12002, 'creature_stamina', '10300'
    UNION ALL SELECT 12002, 'creature_mind', '10300'
    UNION ALL SELECT 12002, 'creature_focus', '10300'
    UNION ALL SELECT 12002, 'creature_willpower', '10300'
    UNION ALL SELECT 12002, 'creature_ham_min', '9300'
    UNION ALL SELECT 12002, 'creature_ham_max', '11300'
    UNION ALL SELECT 12002, 'creature_tohit', '44'
    UNION ALL SELECT 12002, 'creature_damage_min', '345'
    UNION ALL SELECT 12002, 'creature_damage_max', '400'
    UNION ALL SELECT 12002, 'creature_xp', '4006'
    UNION ALL SELECT 12002, 'creature_social_group', 'Tusken Raider'
    UNION ALL SELECT 12002, 'killer', '1'
    UNION ALL SELECT 12002, 'Pack', '1'
    UNION ALL SELECT 12002, 'Herd', '0'
    UNION ALL SELECT 12002, 'stalking', '1'
    UNION ALL SELECT 12002, 'creature_is_aggressive', '1'
    UNION ALL SELECT 12002, 'creature_group_assist', '1'
    UNION ALL SELECT 12002, 'tamable', '0'
    UNION ALL SELECT 12002, 'creature_weapon', 'object/weapon/ranged/rifle/shared_rifle_tusken.iff'
    UNION ALL SELECT 12002, 'creature_humanoid', '1'
    UNION ALL SELECT 12002, 'creature_damage_max_range', '64'
    UNION ALL SELECT 12002, 'creature_is_roaming', '1'
    UNION ALL SELECT 12002, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 12002, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 12002, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 12002, 'cat_armor_effectiveness.armor_eff_elemental_acid', '30'
    UNION ALL SELECT 12002, 'cat_armor_effectiveness.armor_eff_blast', '30'
    UNION ALL SELECT 12002, 'cat_armor_effectiveness.armor_eff_energy', '30'
    UNION ALL SELECT 12002, 'cat_armor_effectiveness.armor_eff_kinetic', '30'
    UNION ALL SELECT 12002, 'cat_armor_effectiveness.armor_eff_stun', '30'
    UNION ALL SELECT 12002, 'cat_armor_special_protection.armor_eff_elemental_electrical', '40'
    UNION ALL SELECT 12002, 'cat_armor_special_protection.armor_eff_elemental_heat', '40'
    UNION ALL SELECT 12003, 'creature_health', '10700'
    UNION ALL SELECT 12003, 'creature_strength', '10700'
    UNION ALL SELECT 12003, 'creature_constitution', '10700'
    UNION ALL SELECT 12003, 'creature_action', '10700'
    UNION ALL SELECT 12003, 'creature_quickness', '10700'
    UNION ALL SELECT 12003, 'creature_stamina', '10700'
    UNION ALL SELECT 12003, 'creature_mind', '10700'
    UNION ALL SELECT 12003, 'creature_focus', '10700'
    UNION ALL SELECT 12003, 'creature_willpower', '10700'
    UNION ALL SELECT 12003, 'creature_ham_min', '9600'
    UNION ALL SELECT 12003, 'creature_ham_max', '11800'
    UNION ALL SELECT 12003, 'creature_tohit', '46'
    UNION ALL SELECT 12003, 'creature_damage_min', '365'
    UNION ALL SELECT 12003, 'creature_damage_max', '440'
    UNION ALL SELECT 12003, 'creature_xp', '4279'
    UNION ALL SELECT 12003, 'creature_social_group', 'Tusken Raider'
    UNION ALL SELECT 12003, 'killer', '1'
    UNION ALL SELECT 12003, 'Pack', '1'
    UNION ALL SELECT 12003, 'Herd', '0'
    UNION ALL SELECT 12003, 'stalking', '1'
    UNION ALL SELECT 12003, 'creature_is_aggressive', '1'
    UNION ALL SELECT 12003, 'creature_group_assist', '1'
    UNION ALL SELECT 12003, 'tamable', '0'
    UNION ALL SELECT 12003, 'creature_weapon', 'object/weapon/ranged/rifle/shared_rifle_tusken.iff'
    UNION ALL SELECT 12003, 'creature_humanoid', '1'
    UNION ALL SELECT 12003, 'creature_damage_max_range', '64'
    UNION ALL SELECT 12003, 'creature_is_roaming', '1'
    UNION ALL SELECT 12003, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 12003, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 12003, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 12003, 'cat_armor_effectiveness.armor_eff_blast', '30'
    UNION ALL SELECT 12003, 'cat_armor_effectiveness.armor_eff_energy', '30'
    UNION ALL SELECT 12003, 'cat_armor_special_protection.armor_eff_elemental_electrical', '40'
    UNION ALL SELECT 12003, 'cat_armor_special_protection.armor_eff_elemental_heat', '60'
    UNION ALL SELECT 12003, 'cat_armor_special_protection.armor_eff_kinetic', '45'
    UNION ALL SELECT 12004, 'creature_health', '10700'
    UNION ALL SELECT 12004, 'creature_strength', '10700'
    UNION ALL SELECT 12004, 'creature_constitution', '10700'
    UNION ALL SELECT 12004, 'creature_action', '10700'
    UNION ALL SELECT 12004, 'creature_quickness', '10700'
    UNION ALL SELECT 12004, 'creature_stamina', '10700'
    UNION ALL SELECT 12004, 'creature_mind', '10700'
    UNION ALL SELECT 12004, 'creature_focus', '10700'
    UNION ALL SELECT 12004, 'creature_willpower', '10700'
    UNION ALL SELECT 12004, 'creature_ham_min', '9600'
    UNION ALL SELECT 12004, 'creature_ham_max', '11800'
    UNION ALL SELECT 12004, 'creature_tohit', '46'
    UNION ALL SELECT 12004, 'creature_damage_min', '365'
    UNION ALL SELECT 12004, 'creature_damage_max', '440'
    UNION ALL SELECT 12004, 'creature_xp', '4370'
    UNION ALL SELECT 12004, 'creature_social_group', 'Tusken Raider'
    UNION ALL SELECT 12004, 'killer', '1'
    UNION ALL SELECT 12004, 'Pack', '1'
    UNION ALL SELECT 12004, 'Herd', '0'
    UNION ALL SELECT 12004, 'stalking', '1'
    UNION ALL SELECT 12004, 'creature_is_aggressive', '1'
    UNION ALL SELECT 12004, 'creature_group_assist', '1'
    UNION ALL SELECT 12004, 'tamable', '0'
    UNION ALL SELECT 12004, 'creature_weapon', 'object/weapon/ranged/rifle/shared_rifle_tusken.iff'
    UNION ALL SELECT 12004, 'creature_humanoid', '1'
    UNION ALL SELECT 12004, 'creature_damage_max_range', '64'
    UNION ALL SELECT 12004, 'creature_is_roaming', '1'
    UNION ALL SELECT 12004, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 12004, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 12004, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_elemental_acid', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_blast', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_elemental_cold', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_elemental_electrical', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_energy', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_elemental_heat', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_kinetic', '30'
    UNION ALL SELECT 12004, 'cat_armor_effectiveness.armor_eff_stun', '30'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (6101, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6102, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6103, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
  (6104, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  SELECT 1001, 6101, 12001
  UNION ALL SELECT 1002, 6101, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_raider')
  UNION ALL SELECT 1003, 6101, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_sniper')
  UNION ALL SELECT 1004, 6102, 12002
  UNION ALL SELECT 1005, 6102, 12003
  UNION ALL SELECT 1006, 6103, 12004
  UNION ALL SELECT 1007, 6104, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_warlord')
  UNION ALL SELECT 1008, 6104, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_king')
  UNION ALL SELECT 1009, 6104, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_bantha');

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (6101, 901, 9, 1, 6101, 6101, 4, 0, 0, 0, 1, 0),
  (6102, 901, 9, 1, 6102, 6102, 3, 0, 0, 0, 1, 0),
  (6103, 901, 9, 1, 6103, 6103, 2, 0, 0, 0, 1, 0),
  (6104, 901, 9, 1, 6104, 6104, 1, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 81001 AS id, 6101 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 81002, 6101, 'lair_at_poi', '1'
    UNION ALL SELECT 81003, 6101, 'lair_invisible', '1'
    UNION ALL SELECT 81004, 6101, 'lair_wave_size', '4'
    UNION ALL SELECT 81005, 6101, 'lair_passive_waves', '3'
    UNION ALL SELECT 81006, 6101, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81007, 6101, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 81008, 6101, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 81009, 6101, 'creature_xp', '0'
    UNION ALL SELECT 81010, 6101, 'creature_health', '1000'
    UNION ALL SELECT 81011, 6101, 'creature_strength', '1000'
    UNION ALL SELECT 81012, 6101, 'creature_constitution', '1000'
    UNION ALL SELECT 81013, 6102, 'lair_fix_position', '0'
    UNION ALL SELECT 81014, 6102, 'lair_at_poi', '1'
    UNION ALL SELECT 81015, 6102, 'lair_invisible', '1'
    UNION ALL SELECT 81016, 6102, 'lair_wave_size', '4'
    UNION ALL SELECT 81017, 6102, 'lair_passive_waves', '3'
    UNION ALL SELECT 81018, 6102, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81019, 6102, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 81020, 6102, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 81021, 6102, 'creature_xp', '0'
    UNION ALL SELECT 81022, 6102, 'creature_health', '1000'
    UNION ALL SELECT 81023, 6102, 'creature_strength', '1000'
    UNION ALL SELECT 81024, 6102, 'creature_constitution', '1000'
    UNION ALL SELECT 81025, 6103, 'lair_fix_position', '0'
    UNION ALL SELECT 81026, 6103, 'lair_at_poi', '1'
    UNION ALL SELECT 81027, 6103, 'lair_invisible', '1'
    UNION ALL SELECT 81028, 6103, 'lair_wave_size', '4'
    UNION ALL SELECT 81029, 6103, 'lair_passive_waves', '3'
    UNION ALL SELECT 81030, 6103, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81031, 6103, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 81032, 6103, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 81033, 6103, 'creature_xp', '0'
    UNION ALL SELECT 81034, 6103, 'creature_health', '1000'
    UNION ALL SELECT 81035, 6103, 'creature_strength', '1000'
    UNION ALL SELECT 81036, 6103, 'creature_constitution', '1000'
    UNION ALL SELECT 81037, 6104, 'lair_fix_position', '0'
    UNION ALL SELECT 81038, 6104, 'lair_at_poi', '1'
    UNION ALL SELECT 81039, 6104, 'lair_invisible', '1'
    UNION ALL SELECT 81040, 6104, 'lair_wave_size', '4'
    UNION ALL SELECT 81041, 6104, 'lair_passive_waves', '3'
    UNION ALL SELECT 81042, 6104, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81043, 6104, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 81044, 6104, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 81045, 6104, 'creature_xp', '0'
    UNION ALL SELECT 81046, 6104, 'creature_health', '1000'
    UNION ALL SELECT 81047, 6104, 'creature_strength', '1000'
    UNION ALL SELECT 81048, 6104, 'creature_constitution', '1000'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
