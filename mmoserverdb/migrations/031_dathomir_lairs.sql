-- Dathomir: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
-- tools/reference/planet_lairs_sql.py; edit that, not this.
--
-- The planet's wild creatures in the 2004 guide's table (levels 1-11; the
-- bio-engineered ones are crafted, not wild), each with its stats from the
-- table, the client's model and name, and the client's lair model. A
-- creature with no model of its own (diseased bocatt, death kreetle, ...)
-- takes its species'.
--
-- Where: neither guide says where on the planet a creature lives, and the
-- client has no spawn tables, so placement is reconstructed: lairs are
-- placed at random on the planet within a distance band from the nearest
-- city's edge, by level, so no strong creature lives by a town:
--   levels 1-5    50-600 m
--   levels 6-8    600-1,500 m
--   levels 9-11   1,500 m and further
-- The counts and the lairs' own settings (hit points 500 per level, waves,
-- respawn times) are reconstructed too. All of it is data, to tune.
--
--   cavern spider broodling  lvl 8  600-1500 m  6 lairs  model gaping_spider_broodling (key cave_gaping_spider_broodling)  (Prima 2004, pp. 172-173)
--   female Kwi               lvl 11 1500 m+     6 lairs  model kwi (key female_kwi)  (Prima 2004, pp. 176-177)
--   gaping spider broodling  lvl 8  600-1500 m  6 lairs  model gaping_spider_broodling  (Prima 2004, pp. 176-177)
--   infant brackaset         lvl 6  600-1500 m  6 lairs  model infant_brackaset  (Prima 2004, pp. 178-179)
--   injured Kwi              lvl 8  600-1500 m  6 lairs  model kwi (key injured_kwi)  (Prima 2004, pp. 178-179)
--   injured verne            lvl 6  600-1500 m  6 lairs  model verne (key injured_verne)  (Prima 2004, pp. 178-179)
--   kwi                      lvl 10 1500 m+     6 lairs  model kwi  (Prima 2004, pp. 180-181)
--   lowland brackaset        lvl 10 1500 m+     6 lairs  model brackaset (key brackaset_lowlands)  (Prima 2004, pp. 180-181)
--   shear mite broodling     lvl 8  600-1500 m  6 lairs  model shear_mite_broodling  (Prima 2004, pp. 182-183)
--   young reptilian flier    lvl 10 1500 m+     6 lairs  model young_reptilian_flier  (Prima 2004, pp. 186-187)
--

-- creature_groups.creature_id has a foreign key to a `creatures` table that
-- does not exist (it is a non_persistent_npcs id), so no row could be
-- added with the checks on; the base data is loaded with them off too.
SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)
  VALUES ('creature_ham_min', 1, 'Lowest health, action and mind a spawn rolls (guide HAM range)'),
         ('creature_ham_max', 1, 'Highest health, action and mind a spawn rolls (guide HAM range)'),
         ('creature_social_group', 1, 'Social group: pack creatures assist their own'),
         ('creature_meat_qty', 1, 'Meat a scout harvests'),
         ('creature_hide_qty', 1, 'Hide a scout harvests'),
         ('creature_bone_qty', 1, 'Bone a scout harvests'),
         ('creature_milk', 1, 'Milk: milk, wild, or empty'),
         ('lair_min_city_distance', 1, 'Random lairs: least distance from the nearest city\'s edge (m)'),
         ('lair_max_city_distance', 1, 'Random lairs: greatest distance from the nearest city\'s edge (m)');

-- The whole map, for random lairs.
INSERT IGNORE INTO swganh.spawns (id, spawn_x, spawn_z, spawn_width, spawn_length, spawn_planet, spawn_density)
  VALUES (804, -7600, -7600, 15200, 15200, 2, 1);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (3301, 8, 1, 1, 'object/mobile/shared_gaping_spider_broodling.iff', 'cave_gaping_spider_broodling', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3302, 8, 1, 1, 'object/mobile/shared_kwi.iff', 'female_kwi', 'mob/creature_names', 11, 1, 0, 0, 0, 1),
  (3303, 8, 1, 1, 'object/mobile/shared_gaping_spider_broodling.iff', 'gaping_spider_broodling', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3304, 8, 1, 1, 'object/mobile/shared_infant_brackaset.iff', 'infant_brackaset', 'mob/creature_names', 6, 1, 0, 0, 0, 1),
  (3305, 8, 1, 1, 'object/mobile/shared_kwi.iff', 'injured_kwi', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3306, 8, 1, 1, 'object/mobile/shared_verne.iff', 'injured_verne', 'mob/creature_names', 6, 1, 0, 0, 0, 1),
  (3307, 8, 1, 1, 'object/mobile/shared_kwi.iff', 'kwi', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3308, 8, 1, 1, 'object/mobile/shared_brackaset.iff', 'brackaset_lowlands', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3309, 8, 1, 1, 'object/mobile/shared_shear_mite_broodling.iff', 'shear_mite_broodling', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3310, 8, 1, 1, 'object/mobile/shared_young_reptilian_flier.iff', 'young_reptilian_flier', 'mob/creature_names', 10, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 3301 AS npc_id, 'creature_health' AS name, '455' AS value
    UNION ALL SELECT 3301, 'creature_strength', '455'
    UNION ALL SELECT 3301, 'creature_constitution', '455'
    UNION ALL SELECT 3301, 'creature_action', '455'
    UNION ALL SELECT 3301, 'creature_quickness', '455'
    UNION ALL SELECT 3301, 'creature_stamina', '455'
    UNION ALL SELECT 3301, 'creature_mind', '455'
    UNION ALL SELECT 3301, 'creature_focus', '455'
    UNION ALL SELECT 3301, 'creature_willpower', '455'
    UNION ALL SELECT 3301, 'creature_ham_min', '410'
    UNION ALL SELECT 3301, 'creature_ham_max', '500'
    UNION ALL SELECT 3301, 'creature_tohit', '27'
    UNION ALL SELECT 3301, 'creature_damage_min', '70'
    UNION ALL SELECT 3301, 'creature_damage_max', '75'
    UNION ALL SELECT 3301, 'creature_xp', '292'
    UNION ALL SELECT 3301, 'creature_social_group', 'Spider Nightsister'
    UNION ALL SELECT 3301, 'killer', '1'
    UNION ALL SELECT 3301, 'Pack', '1'
    UNION ALL SELECT 3301, 'Herd', '0'
    UNION ALL SELECT 3301, 'stalking', '1'
    UNION ALL SELECT 3301, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3301, 'creature_group_assist', '1'
    UNION ALL SELECT 3301, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3301, 'creature_meat_qty', '15'
    UNION ALL SELECT 3301, 'creature_hide_qty', '0'
    UNION ALL SELECT 3301, 'creature_bone_qty', '0'
    UNION ALL SELECT 3302, 'creature_health', '455'
    UNION ALL SELECT 3302, 'creature_strength', '455'
    UNION ALL SELECT 3302, 'creature_constitution', '455'
    UNION ALL SELECT 3302, 'creature_action', '455'
    UNION ALL SELECT 3302, 'creature_quickness', '455'
    UNION ALL SELECT 3302, 'creature_stamina', '455'
    UNION ALL SELECT 3302, 'creature_mind', '455'
    UNION ALL SELECT 3302, 'creature_focus', '455'
    UNION ALL SELECT 3302, 'creature_willpower', '455'
    UNION ALL SELECT 3302, 'creature_ham_min', '410'
    UNION ALL SELECT 3302, 'creature_ham_max', '500'
    UNION ALL SELECT 3302, 'creature_tohit', '28'
    UNION ALL SELECT 3302, 'creature_damage_min', '120'
    UNION ALL SELECT 3302, 'creature_damage_max', '130'
    UNION ALL SELECT 3302, 'creature_xp', '430'
    UNION ALL SELECT 3302, 'creature_social_group', 'Kwi'
    UNION ALL SELECT 3302, 'killer', '0'
    UNION ALL SELECT 3302, 'Pack', '1'
    UNION ALL SELECT 3302, 'Herd', '1'
    UNION ALL SELECT 3302, 'stalking', '0'
    UNION ALL SELECT 3302, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3302, 'creature_group_assist', '1'
    UNION ALL SELECT 3302, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3302, 'creature_meat_qty', '100'
    UNION ALL SELECT 3302, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3302, 'creature_hide_qty', '86'
    UNION ALL SELECT 3302, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3302, 'creature_bone_qty', '76'
    UNION ALL SELECT 3303, 'creature_health', '455'
    UNION ALL SELECT 3303, 'creature_strength', '455'
    UNION ALL SELECT 3303, 'creature_constitution', '455'
    UNION ALL SELECT 3303, 'creature_action', '455'
    UNION ALL SELECT 3303, 'creature_quickness', '455'
    UNION ALL SELECT 3303, 'creature_stamina', '455'
    UNION ALL SELECT 3303, 'creature_mind', '455'
    UNION ALL SELECT 3303, 'creature_focus', '455'
    UNION ALL SELECT 3303, 'creature_willpower', '455'
    UNION ALL SELECT 3303, 'creature_ham_min', '410'
    UNION ALL SELECT 3303, 'creature_ham_max', '500'
    UNION ALL SELECT 3303, 'creature_tohit', '27'
    UNION ALL SELECT 3303, 'creature_damage_min', '70'
    UNION ALL SELECT 3303, 'creature_damage_max', '75'
    UNION ALL SELECT 3303, 'creature_xp', '235'
    UNION ALL SELECT 3303, 'creature_social_group', 'Gaping'
    UNION ALL SELECT 3303, 'killer', '0'
    UNION ALL SELECT 3303, 'Pack', '1'
    UNION ALL SELECT 3303, 'Herd', '0'
    UNION ALL SELECT 3303, 'stalking', '1'
    UNION ALL SELECT 3303, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3303, 'creature_group_assist', '1'
    UNION ALL SELECT 3303, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3303, 'creature_meat_qty', '5'
    UNION ALL SELECT 3303, 'creature_hide_qty', '0'
    UNION ALL SELECT 3303, 'creature_bone_qty', '0'
    UNION ALL SELECT 3304, 'creature_health', '155'
    UNION ALL SELECT 3304, 'creature_strength', '155'
    UNION ALL SELECT 3304, 'creature_constitution', '155'
    UNION ALL SELECT 3304, 'creature_action', '155'
    UNION ALL SELECT 3304, 'creature_quickness', '155'
    UNION ALL SELECT 3304, 'creature_stamina', '155'
    UNION ALL SELECT 3304, 'creature_mind', '155'
    UNION ALL SELECT 3304, 'creature_focus', '155'
    UNION ALL SELECT 3304, 'creature_willpower', '155'
    UNION ALL SELECT 3304, 'creature_ham_min', '140'
    UNION ALL SELECT 3304, 'creature_ham_max', '170'
    UNION ALL SELECT 3304, 'creature_tohit', '25'
    UNION ALL SELECT 3304, 'creature_damage_min', '55'
    UNION ALL SELECT 3304, 'creature_damage_max', '65'
    UNION ALL SELECT 3304, 'creature_xp', '113'
    UNION ALL SELECT 3304, 'creature_social_group', 'Brackaset'
    UNION ALL SELECT 3304, 'killer', '0'
    UNION ALL SELECT 3304, 'Pack', '0'
    UNION ALL SELECT 3304, 'Herd', '1'
    UNION ALL SELECT 3304, 'stalking', '0'
    UNION ALL SELECT 3304, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3304, 'creature_group_assist', '0'
    UNION ALL SELECT 3304, 'res_meat', 'Wild Meat'
    UNION ALL SELECT 3304, 'creature_meat_qty', '75'
    UNION ALL SELECT 3304, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3304, 'creature_hide_qty', '65'
    UNION ALL SELECT 3304, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3304, 'creature_bone_qty', '60'
    UNION ALL SELECT 3305, 'creature_health', '455'
    UNION ALL SELECT 3305, 'creature_strength', '455'
    UNION ALL SELECT 3305, 'creature_constitution', '455'
    UNION ALL SELECT 3305, 'creature_action', '455'
    UNION ALL SELECT 3305, 'creature_quickness', '455'
    UNION ALL SELECT 3305, 'creature_stamina', '455'
    UNION ALL SELECT 3305, 'creature_mind', '455'
    UNION ALL SELECT 3305, 'creature_focus', '455'
    UNION ALL SELECT 3305, 'creature_willpower', '455'
    UNION ALL SELECT 3305, 'creature_ham_min', '410'
    UNION ALL SELECT 3305, 'creature_ham_max', '500'
    UNION ALL SELECT 3305, 'creature_tohit', '27'
    UNION ALL SELECT 3305, 'creature_damage_min', '70'
    UNION ALL SELECT 3305, 'creature_damage_max', '75'
    UNION ALL SELECT 3305, 'creature_xp', '187'
    UNION ALL SELECT 3305, 'creature_social_group', 'Kwi'
    UNION ALL SELECT 3305, 'killer', '0'
    UNION ALL SELECT 3305, 'Pack', '0'
    UNION ALL SELECT 3305, 'Herd', '1'
    UNION ALL SELECT 3305, 'stalking', '0'
    UNION ALL SELECT 3305, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3305, 'creature_group_assist', '0'
    UNION ALL SELECT 3305, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3305, 'creature_meat_qty', '100'
    UNION ALL SELECT 3305, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3305, 'creature_hide_qty', '85'
    UNION ALL SELECT 3305, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3305, 'creature_bone_qty', '75'
    UNION ALL SELECT 3306, 'creature_health', '200'
    UNION ALL SELECT 3306, 'creature_strength', '200'
    UNION ALL SELECT 3306, 'creature_constitution', '200'
    UNION ALL SELECT 3306, 'creature_action', '200'
    UNION ALL SELECT 3306, 'creature_quickness', '200'
    UNION ALL SELECT 3306, 'creature_stamina', '200'
    UNION ALL SELECT 3306, 'creature_mind', '200'
    UNION ALL SELECT 3306, 'creature_focus', '200'
    UNION ALL SELECT 3306, 'creature_willpower', '200'
    UNION ALL SELECT 3306, 'creature_ham_min', '180'
    UNION ALL SELECT 3306, 'creature_ham_max', '220'
    UNION ALL SELECT 3306, 'creature_tohit', '25'
    UNION ALL SELECT 3306, 'creature_damage_min', '50'
    UNION ALL SELECT 3306, 'creature_damage_max', '55'
    UNION ALL SELECT 3306, 'creature_xp', '113'
    UNION ALL SELECT 3306, 'creature_social_group', 'Verne'
    UNION ALL SELECT 3306, 'killer', '0'
    UNION ALL SELECT 3306, 'Pack', '0'
    UNION ALL SELECT 3306, 'Herd', '1'
    UNION ALL SELECT 3306, 'stalking', '0'
    UNION ALL SELECT 3306, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3306, 'creature_group_assist', '0'
    UNION ALL SELECT 3306, 'res_meat', 'Wild Meat'
    UNION ALL SELECT 3306, 'creature_meat_qty', '30'
    UNION ALL SELECT 3306, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3306, 'creature_hide_qty', '25'
    UNION ALL SELECT 3306, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3306, 'creature_bone_qty', '22'
    UNION ALL SELECT 3307, 'creature_health', '300'
    UNION ALL SELECT 3307, 'creature_strength', '300'
    UNION ALL SELECT 3307, 'creature_constitution', '300'
    UNION ALL SELECT 3307, 'creature_action', '300'
    UNION ALL SELECT 3307, 'creature_quickness', '300'
    UNION ALL SELECT 3307, 'creature_stamina', '300'
    UNION ALL SELECT 3307, 'creature_mind', '300'
    UNION ALL SELECT 3307, 'creature_focus', '300'
    UNION ALL SELECT 3307, 'creature_willpower', '300'
    UNION ALL SELECT 3307, 'creature_ham_min', '270'
    UNION ALL SELECT 3307, 'creature_ham_max', '330'
    UNION ALL SELECT 3307, 'creature_tohit', '27'
    UNION ALL SELECT 3307, 'creature_damage_min', '90'
    UNION ALL SELECT 3307, 'creature_damage_max', '110'
    UNION ALL SELECT 3307, 'creature_xp', '356'
    UNION ALL SELECT 3307, 'creature_social_group', 'Kwi'
    UNION ALL SELECT 3307, 'killer', '0'
    UNION ALL SELECT 3307, 'Pack', '1'
    UNION ALL SELECT 3307, 'Herd', '1'
    UNION ALL SELECT 3307, 'stalking', '0'
    UNION ALL SELECT 3307, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3307, 'creature_group_assist', '1'
    UNION ALL SELECT 3307, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3307, 'creature_meat_qty', '100'
    UNION ALL SELECT 3307, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3307, 'creature_hide_qty', '85'
    UNION ALL SELECT 3307, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3307, 'creature_bone_qty', '75'
    UNION ALL SELECT 3308, 'creature_health', '755'
    UNION ALL SELECT 3308, 'creature_strength', '755'
    UNION ALL SELECT 3308, 'creature_constitution', '755'
    UNION ALL SELECT 3308, 'creature_action', '755'
    UNION ALL SELECT 3308, 'creature_quickness', '755'
    UNION ALL SELECT 3308, 'creature_stamina', '755'
    UNION ALL SELECT 3308, 'creature_mind', '755'
    UNION ALL SELECT 3308, 'creature_focus', '755'
    UNION ALL SELECT 3308, 'creature_willpower', '755'
    UNION ALL SELECT 3308, 'creature_ham_min', '680'
    UNION ALL SELECT 3308, 'creature_ham_max', '830'
    UNION ALL SELECT 3308, 'creature_tohit', '28'
    UNION ALL SELECT 3308, 'creature_damage_min', '120'
    UNION ALL SELECT 3308, 'creature_damage_max', '130'
    UNION ALL SELECT 3308, 'creature_xp', '292'
    UNION ALL SELECT 3308, 'creature_social_group', 'Brackaset'
    UNION ALL SELECT 3308, 'killer', '0'
    UNION ALL SELECT 3308, 'Pack', '0'
    UNION ALL SELECT 3308, 'Herd', '1'
    UNION ALL SELECT 3308, 'stalking', '0'
    UNION ALL SELECT 3308, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3308, 'creature_group_assist', '0'
    UNION ALL SELECT 3308, 'res_meat', 'Wild Meat'
    UNION ALL SELECT 3308, 'creature_meat_qty', '75'
    UNION ALL SELECT 3308, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3308, 'creature_hide_qty', '65'
    UNION ALL SELECT 3308, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3308, 'creature_bone_qty', '60'
    UNION ALL SELECT 3308, 'creature_milk', 'wild'
    UNION ALL SELECT 3309, 'creature_health', '455'
    UNION ALL SELECT 3309, 'creature_strength', '455'
    UNION ALL SELECT 3309, 'creature_constitution', '455'
    UNION ALL SELECT 3309, 'creature_action', '455'
    UNION ALL SELECT 3309, 'creature_quickness', '455'
    UNION ALL SELECT 3309, 'creature_stamina', '455'
    UNION ALL SELECT 3309, 'creature_mind', '455'
    UNION ALL SELECT 3309, 'creature_focus', '455'
    UNION ALL SELECT 3309, 'creature_willpower', '455'
    UNION ALL SELECT 3309, 'creature_ham_min', '410'
    UNION ALL SELECT 3309, 'creature_ham_max', '500'
    UNION ALL SELECT 3309, 'creature_tohit', '27'
    UNION ALL SELECT 3309, 'creature_damage_min', '70'
    UNION ALL SELECT 3309, 'creature_damage_max', '75'
    UNION ALL SELECT 3309, 'creature_xp', '235'
    UNION ALL SELECT 3309, 'creature_social_group', 'Shearmite'
    UNION ALL SELECT 3309, 'killer', '0'
    UNION ALL SELECT 3309, 'Pack', '1'
    UNION ALL SELECT 3309, 'Herd', '0'
    UNION ALL SELECT 3309, 'stalking', '1'
    UNION ALL SELECT 3309, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3309, 'creature_group_assist', '1'
    UNION ALL SELECT 3309, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3309, 'creature_meat_qty', '15'
    UNION ALL SELECT 3309, 'res_hide', 'Scaley Hide'
    UNION ALL SELECT 3309, 'creature_hide_qty', '3'
    UNION ALL SELECT 3309, 'creature_bone_qty', '0'
    UNION ALL SELECT 3310, 'creature_health', '1095'
    UNION ALL SELECT 3310, 'creature_strength', '1095'
    UNION ALL SELECT 3310, 'creature_constitution', '1095'
    UNION ALL SELECT 3310, 'creature_action', '1095'
    UNION ALL SELECT 3310, 'creature_quickness', '1095'
    UNION ALL SELECT 3310, 'creature_stamina', '1095'
    UNION ALL SELECT 3310, 'creature_mind', '1095'
    UNION ALL SELECT 3310, 'creature_focus', '1095'
    UNION ALL SELECT 3310, 'creature_willpower', '1095'
    UNION ALL SELECT 3310, 'creature_ham_min', '990'
    UNION ALL SELECT 3310, 'creature_ham_max', '1200'
    UNION ALL SELECT 3310, 'creature_tohit', '28'
    UNION ALL SELECT 3310, 'creature_damage_min', '90'
    UNION ALL SELECT 3310, 'creature_damage_max', '110'
    UNION ALL SELECT 3310, 'creature_xp', '356'
    UNION ALL SELECT 3310, 'creature_social_group', 'Reptilian Flier'
    UNION ALL SELECT 3310, 'killer', '0'
    UNION ALL SELECT 3310, 'Pack', '1'
    UNION ALL SELECT 3310, 'Herd', '0'
    UNION ALL SELECT 3310, 'stalking', '0'
    UNION ALL SELECT 3310, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3310, 'creature_group_assist', '1'
    UNION ALL SELECT 3310, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3310, 'creature_meat_qty', '120'
    UNION ALL SELECT 3310, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3310, 'creature_hide_qty', '75'
    UNION ALL SELECT 3310, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3310, 'creature_bone_qty', '70'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (401, 'object/tangible/lair/base/shared_poi_all_lair_insecthill_large.iff', 'cave_gaping_spider_broodling', 'lair_n', '', ''),
  (402, 'object/tangible/lair/kwi/shared_lair_kwi.iff', 'female_kwi', 'lair_n', '', ''),
  (403, 'object/tangible/lair/base/shared_poi_all_lair_insecthill_large.iff', 'gaping_spider_broodling', 'lair_n', '', ''),
  (404, 'object/tangible/lair/brackaset/shared_lair_brackaset.iff', 'infant_brackaset', 'lair_n', '', ''),
  (405, 'object/tangible/lair/kwi/shared_lair_kwi.iff', 'injured_kwi', 'lair_n', '', ''),
  (406, 'object/tangible/lair/verne/shared_lair_verne.iff', 'injured_verne', 'lair_n', '', ''),
  (407, 'object/tangible/lair/kwi/shared_lair_kwi.iff', 'kwi', 'lair_n', '', ''),
  (408, 'object/tangible/lair/brackaset/shared_lair_brackaset.iff', 'brackaset_lowlands', 'lair_n', '', ''),
  (409, 'object/tangible/lair/base/shared_poi_all_lair_insecthill_large.iff', 'shear_mite_broodling', 'lair_n', '', ''),
  (410, 'object/tangible/lair/base/shared_poi_all_lair_nest_large.iff', 'young_reptilian_flier', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (401, 401, 3301),
  (402, 402, 3302),
  (403, 403, 3303),
  (404, 404, 3304),
  (405, 405, 3305),
  (406, 406, 3306),
  (407, 407, 3307),
  (408, 408, 3308),
  (409, 409, 3309),
  (410, 410, 3310);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (401, 804, 9, 1, 401, 401, 6, 0, 0, 0, 1, 0),
  (402, 804, 9, 1, 402, 402, 6, 0, 0, 0, 1, 0),
  (403, 804, 9, 1, 403, 403, 6, 0, 0, 0, 1, 0),
  (404, 804, 9, 1, 404, 404, 6, 0, 0, 0, 1, 0),
  (405, 804, 9, 1, 405, 405, 6, 0, 0, 0, 1, 0),
  (406, 804, 9, 1, 406, 406, 6, 0, 0, 0, 1, 0),
  (407, 804, 9, 1, 407, 407, 6, 0, 0, 0, 1, 0),
  (408, 804, 9, 1, 408, 408, 6, 0, 0, 0, 1, 0),
  (409, 804, 9, 1, 409, 409, 6, 0, 0, 0, 1, 0),
  (410, 804, 9, 1, 410, 410, 6, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 4001 AS id, 401 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 4002, 401, 'lair_wave_size', '5'
    UNION ALL SELECT 4003, 401, 'lair_passive_waves', '3'
    UNION ALL SELECT 4004, 401, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4005, 401, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4006, 401, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4007, 401, 'creature_xp', '292'
    UNION ALL SELECT 4008, 401, 'creature_health', '4000'
    UNION ALL SELECT 4009, 401, 'creature_strength', '4000'
    UNION ALL SELECT 4010, 401, 'creature_constitution', '4000'
    UNION ALL SELECT 4011, 401, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4012, 401, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4013, 402, 'lair_fix_position', '0'
    UNION ALL SELECT 4014, 402, 'lair_wave_size', '5'
    UNION ALL SELECT 4015, 402, 'lair_passive_waves', '3'
    UNION ALL SELECT 4016, 402, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4017, 402, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4018, 402, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4019, 402, 'creature_xp', '430'
    UNION ALL SELECT 4020, 402, 'creature_health', '5500'
    UNION ALL SELECT 4021, 402, 'creature_strength', '5500'
    UNION ALL SELECT 4022, 402, 'creature_constitution', '5500'
    UNION ALL SELECT 4023, 402, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 4024, 403, 'lair_fix_position', '0'
    UNION ALL SELECT 4025, 403, 'lair_wave_size', '5'
    UNION ALL SELECT 4026, 403, 'lair_passive_waves', '3'
    UNION ALL SELECT 4027, 403, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4028, 403, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4029, 403, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4030, 403, 'creature_xp', '235'
    UNION ALL SELECT 4031, 403, 'creature_health', '4000'
    UNION ALL SELECT 4032, 403, 'creature_strength', '4000'
    UNION ALL SELECT 4033, 403, 'creature_constitution', '4000'
    UNION ALL SELECT 4034, 403, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4035, 403, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4036, 404, 'lair_fix_position', '0'
    UNION ALL SELECT 4037, 404, 'lair_wave_size', '5'
    UNION ALL SELECT 4038, 404, 'lair_passive_waves', '3'
    UNION ALL SELECT 4039, 404, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4040, 404, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4041, 404, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4042, 404, 'creature_xp', '113'
    UNION ALL SELECT 4043, 404, 'creature_health', '3000'
    UNION ALL SELECT 4044, 404, 'creature_strength', '3000'
    UNION ALL SELECT 4045, 404, 'creature_constitution', '3000'
    UNION ALL SELECT 4046, 404, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4047, 404, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4048, 405, 'lair_fix_position', '0'
    UNION ALL SELECT 4049, 405, 'lair_wave_size', '5'
    UNION ALL SELECT 4050, 405, 'lair_passive_waves', '3'
    UNION ALL SELECT 4051, 405, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4052, 405, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4053, 405, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4054, 405, 'creature_xp', '187'
    UNION ALL SELECT 4055, 405, 'creature_health', '4000'
    UNION ALL SELECT 4056, 405, 'creature_strength', '4000'
    UNION ALL SELECT 4057, 405, 'creature_constitution', '4000'
    UNION ALL SELECT 4058, 405, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4059, 405, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4060, 406, 'lair_fix_position', '0'
    UNION ALL SELECT 4061, 406, 'lair_wave_size', '5'
    UNION ALL SELECT 4062, 406, 'lair_passive_waves', '3'
    UNION ALL SELECT 4063, 406, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4064, 406, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4065, 406, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4066, 406, 'creature_xp', '113'
    UNION ALL SELECT 4067, 406, 'creature_health', '3000'
    UNION ALL SELECT 4068, 406, 'creature_strength', '3000'
    UNION ALL SELECT 4069, 406, 'creature_constitution', '3000'
    UNION ALL SELECT 4070, 406, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4071, 406, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4072, 407, 'lair_fix_position', '0'
    UNION ALL SELECT 4073, 407, 'lair_wave_size', '5'
    UNION ALL SELECT 4074, 407, 'lair_passive_waves', '3'
    UNION ALL SELECT 4075, 407, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4076, 407, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4077, 407, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4078, 407, 'creature_xp', '356'
    UNION ALL SELECT 4079, 407, 'creature_health', '5000'
    UNION ALL SELECT 4080, 407, 'creature_strength', '5000'
    UNION ALL SELECT 4081, 407, 'creature_constitution', '5000'
    UNION ALL SELECT 4082, 407, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 4083, 408, 'lair_fix_position', '0'
    UNION ALL SELECT 4084, 408, 'lair_wave_size', '5'
    UNION ALL SELECT 4085, 408, 'lair_passive_waves', '3'
    UNION ALL SELECT 4086, 408, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4087, 408, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4088, 408, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4089, 408, 'creature_xp', '292'
    UNION ALL SELECT 4090, 408, 'creature_health', '5000'
    UNION ALL SELECT 4091, 408, 'creature_strength', '5000'
    UNION ALL SELECT 4092, 408, 'creature_constitution', '5000'
    UNION ALL SELECT 4093, 408, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 4094, 409, 'lair_fix_position', '0'
    UNION ALL SELECT 4095, 409, 'lair_wave_size', '5'
    UNION ALL SELECT 4096, 409, 'lair_passive_waves', '3'
    UNION ALL SELECT 4097, 409, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4098, 409, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4099, 409, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4100, 409, 'creature_xp', '235'
    UNION ALL SELECT 4101, 409, 'creature_health', '4000'
    UNION ALL SELECT 4102, 409, 'creature_strength', '4000'
    UNION ALL SELECT 4103, 409, 'creature_constitution', '4000'
    UNION ALL SELECT 4104, 409, 'lair_min_city_distance', '600'
    UNION ALL SELECT 4105, 409, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 4106, 410, 'lair_fix_position', '0'
    UNION ALL SELECT 4107, 410, 'lair_wave_size', '5'
    UNION ALL SELECT 4108, 410, 'lair_passive_waves', '3'
    UNION ALL SELECT 4109, 410, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 4110, 410, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 4111, 410, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 4112, 410, 'creature_xp', '356'
    UNION ALL SELECT 4113, 410, 'creature_health', '5000'
    UNION ALL SELECT 4114, 410, 'creature_strength', '5000'
    UNION ALL SELECT 4115, 410, 'creature_constitution', '5000'
    UNION ALL SELECT 4116, 410, 'lair_min_city_distance', '1500'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
