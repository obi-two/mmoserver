-- Dantooine: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
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
--   baby bol                 lvl 10 1500 m+     6 lairs  model baby_bol  (Prima 2004, pp. 172-173)
--   huurton pup              lvl 2  50-600 m    6 lairs  model huurton_pup  (Prima 2004, pp. 178-179)
--   lesser plains bol        lvl 10 1500 m+     6 lairs  model bol (key bol_lesser_plains)  (Prima 2004, pp. 180-181)
--   slice hound (warren)     lvl 9  1500 m+     6 lairs  model corellian_slice_hound (key warren_slicehound)  (Prima 2004, pp. 182-183)
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
  VALUES (803, -7600, -7600, 15200, 15200, 1, 1);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (3201, 8, 1, 1, 'object/mobile/shared_baby_bol.iff', 'baby_bol', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3202, 8, 1, 1, 'object/mobile/shared_huurton_pup.iff', 'huurton_pup', 'mob/creature_names', 2, 1, 0, 0, 0, 1),
  (3203, 8, 1, 1, 'object/mobile/shared_bol.iff', 'bol_lesser_plains', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3204, 8, 1, 1, 'object/mobile/shared_corellian_slice_hound.iff', 'warren_slicehound', 'mob/creature_names', 9, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 3201 AS npc_id, 'creature_health' AS name, '900' AS value
    UNION ALL SELECT 3201, 'creature_strength', '900'
    UNION ALL SELECT 3201, 'creature_constitution', '900'
    UNION ALL SELECT 3201, 'creature_action', '900'
    UNION ALL SELECT 3201, 'creature_quickness', '900'
    UNION ALL SELECT 3201, 'creature_stamina', '900'
    UNION ALL SELECT 3201, 'creature_mind', '900'
    UNION ALL SELECT 3201, 'creature_focus', '900'
    UNION ALL SELECT 3201, 'creature_willpower', '900'
    UNION ALL SELECT 3201, 'creature_ham_min', '810'
    UNION ALL SELECT 3201, 'creature_ham_max', '990'
    UNION ALL SELECT 3201, 'creature_tohit', '28'
    UNION ALL SELECT 3201, 'creature_damage_min', '90'
    UNION ALL SELECT 3201, 'creature_damage_max', '110'
    UNION ALL SELECT 3201, 'creature_xp', '292'
    UNION ALL SELECT 3201, 'creature_social_group', 'Bol'
    UNION ALL SELECT 3201, 'killer', '0'
    UNION ALL SELECT 3201, 'Pack', '0'
    UNION ALL SELECT 3201, 'Herd', '1'
    UNION ALL SELECT 3201, 'stalking', '0'
    UNION ALL SELECT 3201, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3201, 'creature_group_assist', '0'
    UNION ALL SELECT 3201, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3201, 'creature_meat_qty', '0'
    UNION ALL SELECT 3201, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3201, 'creature_hide_qty', '300'
    UNION ALL SELECT 3201, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3201, 'creature_bone_qty', '180'
    UNION ALL SELECT 3201, 'creature_milk', 'milk'
    UNION ALL SELECT 3202, 'creature_health', '75'
    UNION ALL SELECT 3202, 'creature_strength', '75'
    UNION ALL SELECT 3202, 'creature_constitution', '75'
    UNION ALL SELECT 3202, 'creature_action', '75'
    UNION ALL SELECT 3202, 'creature_quickness', '75'
    UNION ALL SELECT 3202, 'creature_stamina', '75'
    UNION ALL SELECT 3202, 'creature_mind', '75'
    UNION ALL SELECT 3202, 'creature_focus', '75'
    UNION ALL SELECT 3202, 'creature_willpower', '75'
    UNION ALL SELECT 3202, 'creature_ham_min', '68'
    UNION ALL SELECT 3202, 'creature_ham_max', '83'
    UNION ALL SELECT 3202, 'creature_tohit', '21'
    UNION ALL SELECT 3202, 'creature_damage_min', '35'
    UNION ALL SELECT 3202, 'creature_damage_max', '40'
    UNION ALL SELECT 3202, 'creature_xp', '45'
    UNION ALL SELECT 3202, 'creature_social_group', 'Huurton'
    UNION ALL SELECT 3202, 'killer', '0'
    UNION ALL SELECT 3202, 'Pack', '1'
    UNION ALL SELECT 3202, 'Herd', '1'
    UNION ALL SELECT 3202, 'stalking', '0'
    UNION ALL SELECT 3202, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3202, 'creature_group_assist', '1'
    UNION ALL SELECT 3202, 'res_meat', 'Wild Meat'
    UNION ALL SELECT 3202, 'creature_meat_qty', '10'
    UNION ALL SELECT 3202, 'res_hide', 'Wooly Hide'
    UNION ALL SELECT 3202, 'creature_hide_qty', '0'
    UNION ALL SELECT 3202, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3202, 'creature_bone_qty', '5'
    UNION ALL SELECT 3203, 'creature_health', '900'
    UNION ALL SELECT 3203, 'creature_strength', '900'
    UNION ALL SELECT 3203, 'creature_constitution', '900'
    UNION ALL SELECT 3203, 'creature_action', '900'
    UNION ALL SELECT 3203, 'creature_quickness', '900'
    UNION ALL SELECT 3203, 'creature_stamina', '900'
    UNION ALL SELECT 3203, 'creature_mind', '900'
    UNION ALL SELECT 3203, 'creature_focus', '900'
    UNION ALL SELECT 3203, 'creature_willpower', '900'
    UNION ALL SELECT 3203, 'creature_ham_min', '810'
    UNION ALL SELECT 3203, 'creature_ham_max', '990'
    UNION ALL SELECT 3203, 'creature_tohit', '28'
    UNION ALL SELECT 3203, 'creature_damage_min', '90'
    UNION ALL SELECT 3203, 'creature_damage_max', '110'
    UNION ALL SELECT 3203, 'creature_xp', '292'
    UNION ALL SELECT 3203, 'creature_social_group', 'Bol'
    UNION ALL SELECT 3203, 'killer', '0'
    UNION ALL SELECT 3203, 'Pack', '0'
    UNION ALL SELECT 3203, 'Herd', '1'
    UNION ALL SELECT 3203, 'stalking', '0'
    UNION ALL SELECT 3203, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3203, 'creature_group_assist', '0'
    UNION ALL SELECT 3203, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3203, 'creature_meat_qty', '0'
    UNION ALL SELECT 3203, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3203, 'creature_hide_qty', '300'
    UNION ALL SELECT 3203, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3203, 'creature_bone_qty', '180'
    UNION ALL SELECT 3203, 'creature_milk', 'milk'
    UNION ALL SELECT 3204, 'creature_health', '455'
    UNION ALL SELECT 3204, 'creature_strength', '455'
    UNION ALL SELECT 3204, 'creature_constitution', '455'
    UNION ALL SELECT 3204, 'creature_action', '455'
    UNION ALL SELECT 3204, 'creature_quickness', '455'
    UNION ALL SELECT 3204, 'creature_stamina', '455'
    UNION ALL SELECT 3204, 'creature_mind', '455'
    UNION ALL SELECT 3204, 'creature_focus', '455'
    UNION ALL SELECT 3204, 'creature_willpower', '455'
    UNION ALL SELECT 3204, 'creature_ham_min', '410'
    UNION ALL SELECT 3204, 'creature_ham_max', '500'
    UNION ALL SELECT 3204, 'creature_tohit', '27'
    UNION ALL SELECT 3204, 'creature_damage_min', '120'
    UNION ALL SELECT 3204, 'creature_damage_max', '130'
    UNION ALL SELECT 3204, 'creature_xp', '292'
    UNION ALL SELECT 3204, 'creature_social_group', 'Slice Hound'
    UNION ALL SELECT 3204, 'killer', '0'
    UNION ALL SELECT 3204, 'Pack', '1'
    UNION ALL SELECT 3204, 'Herd', '1'
    UNION ALL SELECT 3204, 'stalking', '0'
    UNION ALL SELECT 3204, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3204, 'creature_group_assist', '1'
    UNION ALL SELECT 3204, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3204, 'creature_meat_qty', '65'
    UNION ALL SELECT 3204, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3204, 'creature_hide_qty', '35'
    UNION ALL SELECT 3204, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3204, 'creature_bone_qty', '30'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (301, 'object/tangible/lair/bol/shared_lair_bol.iff', 'baby_bol', 'lair_n', '', ''),
  (302, 'object/tangible/lair/huurton/shared_lair_huurton.iff', 'huurton_pup', 'lair_n', '', ''),
  (303, 'object/tangible/lair/bol/shared_lair_bol.iff', 'bol_lesser_plains', 'lair_n', '', ''),
  (304, 'object/tangible/lair/base/shared_poi_all_lair_warren_large.iff', 'warren_slicehound', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (301, 301, 3201),
  (302, 302, 3202),
  (303, 303, 3203),
  (304, 304, 3204);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (301, 803, 9, 1, 301, 301, 6, 0, 0, 0, 1, 0),
  (302, 803, 9, 1, 302, 302, 6, 0, 0, 0, 1, 0),
  (303, 803, 9, 1, 303, 303, 6, 0, 0, 0, 1, 0),
  (304, 803, 9, 1, 304, 304, 6, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 3001 AS id, 301 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 3002, 301, 'lair_wave_size', '5'
    UNION ALL SELECT 3003, 301, 'lair_passive_waves', '3'
    UNION ALL SELECT 3004, 301, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 3005, 301, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 3006, 301, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 3007, 301, 'creature_xp', '292'
    UNION ALL SELECT 3008, 301, 'creature_health', '5000'
    UNION ALL SELECT 3009, 301, 'creature_strength', '5000'
    UNION ALL SELECT 3010, 301, 'creature_constitution', '5000'
    UNION ALL SELECT 3011, 301, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 3012, 302, 'lair_fix_position', '0'
    UNION ALL SELECT 3013, 302, 'lair_wave_size', '5'
    UNION ALL SELECT 3014, 302, 'lair_passive_waves', '3'
    UNION ALL SELECT 3015, 302, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 3016, 302, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 3017, 302, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 3018, 302, 'creature_xp', '45'
    UNION ALL SELECT 3019, 302, 'creature_health', '1000'
    UNION ALL SELECT 3020, 302, 'creature_strength', '1000'
    UNION ALL SELECT 3021, 302, 'creature_constitution', '1000'
    UNION ALL SELECT 3022, 302, 'lair_min_city_distance', '50'
    UNION ALL SELECT 3023, 302, 'lair_max_city_distance', '600'
    UNION ALL SELECT 3024, 303, 'lair_fix_position', '0'
    UNION ALL SELECT 3025, 303, 'lair_wave_size', '5'
    UNION ALL SELECT 3026, 303, 'lair_passive_waves', '3'
    UNION ALL SELECT 3027, 303, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 3028, 303, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 3029, 303, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 3030, 303, 'creature_xp', '292'
    UNION ALL SELECT 3031, 303, 'creature_health', '5000'
    UNION ALL SELECT 3032, 303, 'creature_strength', '5000'
    UNION ALL SELECT 3033, 303, 'creature_constitution', '5000'
    UNION ALL SELECT 3034, 303, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 3035, 304, 'lair_fix_position', '0'
    UNION ALL SELECT 3036, 304, 'lair_wave_size', '5'
    UNION ALL SELECT 3037, 304, 'lair_passive_waves', '3'
    UNION ALL SELECT 3038, 304, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 3039, 304, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 3040, 304, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 3041, 304, 'creature_xp', '292'
    UNION ALL SELECT 3042, 304, 'creature_health', '4500'
    UNION ALL SELECT 3043, 304, 'creature_strength', '4500'
    UNION ALL SELECT 3044, 304, 'creature_constitution', '4500'
    UNION ALL SELECT 3045, 304, 'lair_min_city_distance', '1500'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
