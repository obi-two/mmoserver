-- Endor: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
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
--   diminutive bounding jax  lvl 7  600-1500 m  6 lairs  model bearded_jax (key jax_bounding_dwarf)  (Prima 2004, pp. 174-175)
--   elder squall             lvl 9  1500 m+     6 lairs  model squall (key elder_squall)  (Prima 2004, pp. 174-175)
--   rabid squall             lvl 9  1500 m+     6 lairs  model squall (key rabid_squall)  (Prima 2004, pp. 182-183)
--   squall                   lvl 6  600-1500 m  6 lairs  model squall  (Prima 2004, pp. 184-185)
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
  VALUES (805, -7600, -7600, 15200, 15200, 3, 1);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (3401, 8, 1, 1, 'object/mobile/shared_bearded_jax.iff', 'jax_bounding_dwarf', 'mob/creature_names', 7, 1, 0, 0, 0, 1),
  (3402, 8, 1, 1, 'object/mobile/shared_squall.iff', 'elder_squall', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3403, 8, 1, 1, 'object/mobile/shared_squall.iff', 'rabid_squall', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3404, 8, 1, 1, 'object/mobile/shared_squall.iff', 'squall', 'mob/creature_names', 6, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 3401 AS npc_id, 'creature_health' AS name, '75' AS value
    UNION ALL SELECT 3401, 'creature_strength', '75'
    UNION ALL SELECT 3401, 'creature_constitution', '75'
    UNION ALL SELECT 3401, 'creature_action', '75'
    UNION ALL SELECT 3401, 'creature_quickness', '75'
    UNION ALL SELECT 3401, 'creature_stamina', '75'
    UNION ALL SELECT 3401, 'creature_mind', '75'
    UNION ALL SELECT 3401, 'creature_focus', '75'
    UNION ALL SELECT 3401, 'creature_willpower', '75'
    UNION ALL SELECT 3401, 'creature_ham_min', '68'
    UNION ALL SELECT 3401, 'creature_ham_max', '83'
    UNION ALL SELECT 3401, 'creature_tohit', '27'
    UNION ALL SELECT 3401, 'creature_damage_min', '80'
    UNION ALL SELECT 3401, 'creature_damage_max', '90'
    UNION ALL SELECT 3401, 'creature_xp', '187'
    UNION ALL SELECT 3401, 'creature_social_group', 'Jax'
    UNION ALL SELECT 3401, 'killer', '0'
    UNION ALL SELECT 3401, 'Pack', '1'
    UNION ALL SELECT 3401, 'Herd', '0'
    UNION ALL SELECT 3401, 'stalking', '0'
    UNION ALL SELECT 3401, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3401, 'creature_group_assist', '1'
    UNION ALL SELECT 3401, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3401, 'creature_meat_qty', '0'
    UNION ALL SELECT 3401, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3401, 'creature_hide_qty', '35'
    UNION ALL SELECT 3401, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3401, 'creature_bone_qty', '25'
    UNION ALL SELECT 3402, 'creature_health', '755'
    UNION ALL SELECT 3402, 'creature_strength', '755'
    UNION ALL SELECT 3402, 'creature_constitution', '755'
    UNION ALL SELECT 3402, 'creature_action', '755'
    UNION ALL SELECT 3402, 'creature_quickness', '755'
    UNION ALL SELECT 3402, 'creature_stamina', '755'
    UNION ALL SELECT 3402, 'creature_mind', '755'
    UNION ALL SELECT 3402, 'creature_focus', '755'
    UNION ALL SELECT 3402, 'creature_willpower', '755'
    UNION ALL SELECT 3402, 'creature_ham_min', '680'
    UNION ALL SELECT 3402, 'creature_ham_max', '830'
    UNION ALL SELECT 3402, 'creature_tohit', '27'
    UNION ALL SELECT 3402, 'creature_damage_min', '80'
    UNION ALL SELECT 3402, 'creature_damage_max', '90'
    UNION ALL SELECT 3402, 'creature_xp', '292'
    UNION ALL SELECT 3402, 'creature_social_group', 'Squall'
    UNION ALL SELECT 3402, 'killer', '0'
    UNION ALL SELECT 3402, 'Pack', '1'
    UNION ALL SELECT 3402, 'Herd', '1'
    UNION ALL SELECT 3402, 'stalking', '0'
    UNION ALL SELECT 3402, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3402, 'creature_group_assist', '1'
    UNION ALL SELECT 3402, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3402, 'creature_meat_qty', '0'
    UNION ALL SELECT 3402, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3402, 'creature_hide_qty', '12'
    UNION ALL SELECT 3402, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3402, 'creature_bone_qty', '8'
    UNION ALL SELECT 3403, 'creature_health', '755'
    UNION ALL SELECT 3403, 'creature_strength', '755'
    UNION ALL SELECT 3403, 'creature_constitution', '755'
    UNION ALL SELECT 3403, 'creature_action', '755'
    UNION ALL SELECT 3403, 'creature_quickness', '755'
    UNION ALL SELECT 3403, 'creature_stamina', '755'
    UNION ALL SELECT 3403, 'creature_mind', '755'
    UNION ALL SELECT 3403, 'creature_focus', '755'
    UNION ALL SELECT 3403, 'creature_willpower', '755'
    UNION ALL SELECT 3403, 'creature_ham_min', '680'
    UNION ALL SELECT 3403, 'creature_ham_max', '830'
    UNION ALL SELECT 3403, 'creature_tohit', '27'
    UNION ALL SELECT 3403, 'creature_damage_min', '80'
    UNION ALL SELECT 3403, 'creature_damage_max', '90'
    UNION ALL SELECT 3403, 'creature_xp', '292'
    UNION ALL SELECT 3403, 'creature_social_group', 'Rabid Squall'
    UNION ALL SELECT 3403, 'killer', '0'
    UNION ALL SELECT 3403, 'Pack', '1'
    UNION ALL SELECT 3403, 'Herd', '0'
    UNION ALL SELECT 3403, 'stalking', '0'
    UNION ALL SELECT 3403, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3403, 'creature_group_assist', '1'
    UNION ALL SELECT 3403, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3403, 'creature_meat_qty', '0'
    UNION ALL SELECT 3403, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3403, 'creature_hide_qty', '12'
    UNION ALL SELECT 3403, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3403, 'creature_bone_qty', '8'
    UNION ALL SELECT 3404, 'creature_health', '200'
    UNION ALL SELECT 3404, 'creature_strength', '200'
    UNION ALL SELECT 3404, 'creature_constitution', '200'
    UNION ALL SELECT 3404, 'creature_action', '200'
    UNION ALL SELECT 3404, 'creature_quickness', '200'
    UNION ALL SELECT 3404, 'creature_stamina', '200'
    UNION ALL SELECT 3404, 'creature_mind', '200'
    UNION ALL SELECT 3404, 'creature_focus', '200'
    UNION ALL SELECT 3404, 'creature_willpower', '200'
    UNION ALL SELECT 3404, 'creature_ham_min', '180'
    UNION ALL SELECT 3404, 'creature_ham_max', '220'
    UNION ALL SELECT 3404, 'creature_tohit', '25'
    UNION ALL SELECT 3404, 'creature_damage_min', '50'
    UNION ALL SELECT 3404, 'creature_damage_max', '55'
    UNION ALL SELECT 3404, 'creature_xp', '147'
    UNION ALL SELECT 3404, 'creature_social_group', 'Squall'
    UNION ALL SELECT 3404, 'killer', '0'
    UNION ALL SELECT 3404, 'Pack', '1'
    UNION ALL SELECT 3404, 'Herd', '1'
    UNION ALL SELECT 3404, 'stalking', '0'
    UNION ALL SELECT 3404, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3404, 'creature_group_assist', '1'
    UNION ALL SELECT 3404, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3404, 'creature_meat_qty', '0'
    UNION ALL SELECT 3404, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3404, 'creature_hide_qty', '12'
    UNION ALL SELECT 3404, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3404, 'creature_bone_qty', '8'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (501, 'object/tangible/lair/base/shared_poi_all_lair_warren_small.iff', 'jax_bounding_dwarf', 'lair_n', '', ''),
  (502, 'object/tangible/lair/squall/shared_lair_squall.iff', 'elder_squall', 'lair_n', '', ''),
  (503, 'object/tangible/lair/squall/shared_lair_squall.iff', 'rabid_squall', 'lair_n', '', ''),
  (504, 'object/tangible/lair/squall/shared_lair_squall.iff', 'squall', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (501, 501, 3401),
  (502, 502, 3402),
  (503, 503, 3403),
  (504, 504, 3404);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (501, 805, 9, 1, 501, 501, 6, 0, 0, 0, 1, 0),
  (502, 805, 9, 1, 502, 502, 6, 0, 0, 0, 1, 0),
  (503, 805, 9, 1, 503, 503, 6, 0, 0, 0, 1, 0),
  (504, 805, 9, 1, 504, 504, 6, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 5001 AS id, 501 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 5002, 501, 'lair_wave_size', '5'
    UNION ALL SELECT 5003, 501, 'lair_passive_waves', '3'
    UNION ALL SELECT 5004, 501, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 5005, 501, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 5006, 501, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 5007, 501, 'creature_xp', '187'
    UNION ALL SELECT 5008, 501, 'creature_health', '3500'
    UNION ALL SELECT 5009, 501, 'creature_strength', '3500'
    UNION ALL SELECT 5010, 501, 'creature_constitution', '3500'
    UNION ALL SELECT 5011, 501, 'lair_min_city_distance', '600'
    UNION ALL SELECT 5012, 501, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 5013, 502, 'lair_fix_position', '0'
    UNION ALL SELECT 5014, 502, 'lair_wave_size', '5'
    UNION ALL SELECT 5015, 502, 'lair_passive_waves', '3'
    UNION ALL SELECT 5016, 502, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 5017, 502, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 5018, 502, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 5019, 502, 'creature_xp', '292'
    UNION ALL SELECT 5020, 502, 'creature_health', '4500'
    UNION ALL SELECT 5021, 502, 'creature_strength', '4500'
    UNION ALL SELECT 5022, 502, 'creature_constitution', '4500'
    UNION ALL SELECT 5023, 502, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 5024, 503, 'lair_fix_position', '0'
    UNION ALL SELECT 5025, 503, 'lair_wave_size', '5'
    UNION ALL SELECT 5026, 503, 'lair_passive_waves', '3'
    UNION ALL SELECT 5027, 503, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 5028, 503, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 5029, 503, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 5030, 503, 'creature_xp', '292'
    UNION ALL SELECT 5031, 503, 'creature_health', '4500'
    UNION ALL SELECT 5032, 503, 'creature_strength', '4500'
    UNION ALL SELECT 5033, 503, 'creature_constitution', '4500'
    UNION ALL SELECT 5034, 503, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 5035, 504, 'lair_fix_position', '0'
    UNION ALL SELECT 5036, 504, 'lair_wave_size', '5'
    UNION ALL SELECT 5037, 504, 'lair_passive_waves', '3'
    UNION ALL SELECT 5038, 504, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 5039, 504, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 5040, 504, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 5041, 504, 'creature_xp', '147'
    UNION ALL SELECT 5042, 504, 'creature_health', '3000'
    UNION ALL SELECT 5043, 504, 'creature_strength', '3000'
    UNION ALL SELECT 5044, 504, 'creature_constitution', '3000'
    UNION ALL SELECT 5045, 504, 'lair_min_city_distance', '600'
    UNION ALL SELECT 5046, 504, 'lair_max_city_distance', '1500'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
