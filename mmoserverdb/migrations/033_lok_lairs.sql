-- Lok: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
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
--   flit                     lvl 8  600-1500 m  6 lairs  model flit  (Prima 2004, pp. 176-177)
--   flit bloodsucker         lvl 9  1500 m+     6 lairs  model flit (key flit_bloodsucker)  (Prima 2004, pp. 176-177)
--   flit harasser            lvl 10 1500 m+     6 lairs  model flit (key flit_harasser)  (Prima 2004, pp. 176-177)
--   flit youth               lvl 6  600-1500 m  6 lairs  model flit_youth  (Prima 2004, pp. 176-177)
--   giant pharple            lvl 7  600-1500 m  6 lairs  model giant_pharple  (Prima 2004, pp. 176-177)
--   gurnaset hatchling       lvl 5  50-600 m    6 lairs  model gurnaset_hatchling  (Prima 2004, pp. 178-179)
--   juvenile langlatch       lvl 8  600-1500 m  6 lairs  model langlatch_juvenile  (Prima 2004, pp. 178-179)
--   kusak pup                lvl 8  600-1500 m  6 lairs  model kusak_pup  (Prima 2004, pp. 178-179)
--   langlatch hatchling      lvl 4  50-600 m    6 lairs  model langlatch_hatchling  (Prima 2004, pp. 180-181)
--   pharple                  lvl 5  50-600 m    6 lairs  model pharple  (Prima 2004, pp. 182-183)
--   runty pharple            lvl 3  50-600 m    6 lairs  model runty_pharple  (Prima 2004, pp. 182-183)
--   young spined snake       lvl 11 1500 m+     6 lairs  model young_spined_snake  (Prima 2004, pp. 186-187)
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
  VALUES (806, -7600, -7600, 15200, 15200, 4, 1);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (3501, 8, 1, 1, 'object/mobile/shared_flit.iff', 'flit', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3502, 8, 1, 1, 'object/mobile/shared_flit.iff', 'flit_bloodsucker', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3503, 8, 1, 1, 'object/mobile/shared_flit.iff', 'flit_harasser', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3504, 8, 1, 1, 'object/mobile/shared_flit_youth.iff', 'flit_youth', 'mob/creature_names', 6, 1, 0, 0, 0, 1),
  (3505, 8, 1, 1, 'object/mobile/shared_giant_pharple.iff', 'giant_pharple', 'mob/creature_names', 7, 1, 0, 0, 0, 1),
  (3506, 8, 1, 1, 'object/mobile/shared_gurnaset_hatchling.iff', 'gurnaset_hatchling', 'mob/creature_names', 5, 1, 0, 0, 0, 1),
  (3507, 8, 1, 1, 'object/mobile/shared_langlatch_juvenile.iff', 'langlatch_juvenile', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3508, 8, 1, 1, 'object/mobile/shared_kusak_pup.iff', 'kusak_pup', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3509, 8, 1, 1, 'object/mobile/shared_langlatch_hatchling.iff', 'langlatch_hatchling', 'mob/creature_names', 4, 1, 0, 0, 0, 1),
  (3510, 8, 1, 1, 'object/mobile/shared_pharple.iff', 'pharple', 'mob/creature_names', 5, 1, 0, 0, 0, 1),
  (3511, 8, 1, 1, 'object/mobile/shared_runty_pharple.iff', 'runty_pharple', 'mob/creature_names', 3, 1, 0, 0, 0, 1),
  (3512, 8, 1, 1, 'object/mobile/shared_young_spined_snake.iff', 'young_spined_snake', 'mob/creature_names', 11, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 3501 AS npc_id, 'creature_health' AS name, '455' AS value
    UNION ALL SELECT 3501, 'creature_strength', '455'
    UNION ALL SELECT 3501, 'creature_constitution', '455'
    UNION ALL SELECT 3501, 'creature_action', '455'
    UNION ALL SELECT 3501, 'creature_quickness', '455'
    UNION ALL SELECT 3501, 'creature_stamina', '455'
    UNION ALL SELECT 3501, 'creature_mind', '455'
    UNION ALL SELECT 3501, 'creature_focus', '455'
    UNION ALL SELECT 3501, 'creature_willpower', '455'
    UNION ALL SELECT 3501, 'creature_ham_min', '410'
    UNION ALL SELECT 3501, 'creature_ham_max', '500'
    UNION ALL SELECT 3501, 'creature_tohit', '27'
    UNION ALL SELECT 3501, 'creature_damage_min', '70'
    UNION ALL SELECT 3501, 'creature_damage_max', '75'
    UNION ALL SELECT 3501, 'creature_xp', '235'
    UNION ALL SELECT 3501, 'creature_social_group', 'Flit'
    UNION ALL SELECT 3501, 'killer', '0'
    UNION ALL SELECT 3501, 'Pack', '1'
    UNION ALL SELECT 3501, 'Herd', '0'
    UNION ALL SELECT 3501, 'stalking', '0'
    UNION ALL SELECT 3501, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3501, 'creature_group_assist', '1'
    UNION ALL SELECT 3501, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3501, 'creature_meat_qty', '9'
    UNION ALL SELECT 3501, 'creature_hide_qty', '0'
    UNION ALL SELECT 3501, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3501, 'creature_bone_qty', '10'
    UNION ALL SELECT 3502, 'creature_health', '755'
    UNION ALL SELECT 3502, 'creature_strength', '755'
    UNION ALL SELECT 3502, 'creature_constitution', '755'
    UNION ALL SELECT 3502, 'creature_action', '755'
    UNION ALL SELECT 3502, 'creature_quickness', '755'
    UNION ALL SELECT 3502, 'creature_stamina', '755'
    UNION ALL SELECT 3502, 'creature_mind', '755'
    UNION ALL SELECT 3502, 'creature_focus', '755'
    UNION ALL SELECT 3502, 'creature_willpower', '755'
    UNION ALL SELECT 3502, 'creature_ham_min', '680'
    UNION ALL SELECT 3502, 'creature_ham_max', '830'
    UNION ALL SELECT 3502, 'creature_tohit', '27'
    UNION ALL SELECT 3502, 'creature_damage_min', '80'
    UNION ALL SELECT 3502, 'creature_damage_max', '90'
    UNION ALL SELECT 3502, 'creature_xp', '292'
    UNION ALL SELECT 3502, 'creature_social_group', 'Flit'
    UNION ALL SELECT 3502, 'killer', '0'
    UNION ALL SELECT 3502, 'Pack', '1'
    UNION ALL SELECT 3502, 'Herd', '0'
    UNION ALL SELECT 3502, 'stalking', '0'
    UNION ALL SELECT 3502, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3502, 'creature_group_assist', '1'
    UNION ALL SELECT 3502, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3502, 'creature_meat_qty', '9'
    UNION ALL SELECT 3502, 'creature_hide_qty', '0'
    UNION ALL SELECT 3502, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3502, 'creature_bone_qty', '10'
    UNION ALL SELECT 3503, 'creature_health', '900'
    UNION ALL SELECT 3503, 'creature_strength', '900'
    UNION ALL SELECT 3503, 'creature_constitution', '900'
    UNION ALL SELECT 3503, 'creature_action', '900'
    UNION ALL SELECT 3503, 'creature_quickness', '900'
    UNION ALL SELECT 3503, 'creature_stamina', '900'
    UNION ALL SELECT 3503, 'creature_mind', '900'
    UNION ALL SELECT 3503, 'creature_focus', '900'
    UNION ALL SELECT 3503, 'creature_willpower', '900'
    UNION ALL SELECT 3503, 'creature_ham_min', '810'
    UNION ALL SELECT 3503, 'creature_ham_max', '990'
    UNION ALL SELECT 3503, 'creature_tohit', '28'
    UNION ALL SELECT 3503, 'creature_damage_min', '90'
    UNION ALL SELECT 3503, 'creature_damage_max', '110'
    UNION ALL SELECT 3503, 'creature_xp', '356'
    UNION ALL SELECT 3503, 'creature_social_group', 'Flit'
    UNION ALL SELECT 3503, 'killer', '0'
    UNION ALL SELECT 3503, 'Pack', '1'
    UNION ALL SELECT 3503, 'Herd', '0'
    UNION ALL SELECT 3503, 'stalking', '0'
    UNION ALL SELECT 3503, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3503, 'creature_group_assist', '1'
    UNION ALL SELECT 3503, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3503, 'creature_meat_qty', '9'
    UNION ALL SELECT 3503, 'creature_hide_qty', '0'
    UNION ALL SELECT 3503, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3503, 'creature_bone_qty', '10'
    UNION ALL SELECT 3504, 'creature_health', '200'
    UNION ALL SELECT 3504, 'creature_strength', '200'
    UNION ALL SELECT 3504, 'creature_constitution', '200'
    UNION ALL SELECT 3504, 'creature_action', '200'
    UNION ALL SELECT 3504, 'creature_quickness', '200'
    UNION ALL SELECT 3504, 'creature_stamina', '200'
    UNION ALL SELECT 3504, 'creature_mind', '200'
    UNION ALL SELECT 3504, 'creature_focus', '200'
    UNION ALL SELECT 3504, 'creature_willpower', '200'
    UNION ALL SELECT 3504, 'creature_ham_min', '180'
    UNION ALL SELECT 3504, 'creature_ham_max', '220'
    UNION ALL SELECT 3504, 'creature_tohit', '25'
    UNION ALL SELECT 3504, 'creature_damage_min', '50'
    UNION ALL SELECT 3504, 'creature_damage_max', '55'
    UNION ALL SELECT 3504, 'creature_xp', '147'
    UNION ALL SELECT 3504, 'creature_social_group', 'Flit'
    UNION ALL SELECT 3504, 'killer', '0'
    UNION ALL SELECT 3504, 'Pack', '1'
    UNION ALL SELECT 3504, 'Herd', '0'
    UNION ALL SELECT 3504, 'stalking', '0'
    UNION ALL SELECT 3504, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3504, 'creature_group_assist', '1'
    UNION ALL SELECT 3504, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3504, 'creature_meat_qty', '5'
    UNION ALL SELECT 3504, 'creature_hide_qty', '0'
    UNION ALL SELECT 3504, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3504, 'creature_bone_qty', '5'
    UNION ALL SELECT 3505, 'creature_health', '300'
    UNION ALL SELECT 3505, 'creature_strength', '300'
    UNION ALL SELECT 3505, 'creature_constitution', '300'
    UNION ALL SELECT 3505, 'creature_action', '300'
    UNION ALL SELECT 3505, 'creature_quickness', '300'
    UNION ALL SELECT 3505, 'creature_stamina', '300'
    UNION ALL SELECT 3505, 'creature_mind', '300'
    UNION ALL SELECT 3505, 'creature_focus', '300'
    UNION ALL SELECT 3505, 'creature_willpower', '300'
    UNION ALL SELECT 3505, 'creature_ham_min', '270'
    UNION ALL SELECT 3505, 'creature_ham_max', '330'
    UNION ALL SELECT 3505, 'creature_tohit', '26'
    UNION ALL SELECT 3505, 'creature_damage_min', '55'
    UNION ALL SELECT 3505, 'creature_damage_max', '65'
    UNION ALL SELECT 3505, 'creature_xp', '187'
    UNION ALL SELECT 3505, 'creature_social_group', 'Pharple'
    UNION ALL SELECT 3505, 'killer', '0'
    UNION ALL SELECT 3505, 'Pack', '1'
    UNION ALL SELECT 3505, 'Herd', '1'
    UNION ALL SELECT 3505, 'stalking', '0'
    UNION ALL SELECT 3505, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3505, 'creature_group_assist', '1'
    UNION ALL SELECT 3505, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3505, 'creature_meat_qty', '21'
    UNION ALL SELECT 3505, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3505, 'creature_hide_qty', '12'
    UNION ALL SELECT 3505, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3505, 'creature_bone_qty', '9'
    UNION ALL SELECT 3506, 'creature_health', '155'
    UNION ALL SELECT 3506, 'creature_strength', '155'
    UNION ALL SELECT 3506, 'creature_constitution', '155'
    UNION ALL SELECT 3506, 'creature_action', '155'
    UNION ALL SELECT 3506, 'creature_quickness', '155'
    UNION ALL SELECT 3506, 'creature_stamina', '155'
    UNION ALL SELECT 3506, 'creature_mind', '155'
    UNION ALL SELECT 3506, 'creature_focus', '155'
    UNION ALL SELECT 3506, 'creature_willpower', '155'
    UNION ALL SELECT 3506, 'creature_ham_min', '140'
    UNION ALL SELECT 3506, 'creature_ham_max', '170'
    UNION ALL SELECT 3506, 'creature_tohit', '25'
    UNION ALL SELECT 3506, 'creature_damage_min', '45'
    UNION ALL SELECT 3506, 'creature_damage_max', '50'
    UNION ALL SELECT 3506, 'creature_xp', '85'
    UNION ALL SELECT 3506, 'creature_social_group', 'Gurnaset'
    UNION ALL SELECT 3506, 'killer', '0'
    UNION ALL SELECT 3506, 'Pack', '0'
    UNION ALL SELECT 3506, 'Herd', '1'
    UNION ALL SELECT 3506, 'stalking', '0'
    UNION ALL SELECT 3506, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3506, 'creature_group_assist', '0'
    UNION ALL SELECT 3506, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3506, 'creature_meat_qty', '351'
    UNION ALL SELECT 3506, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3506, 'creature_hide_qty', '278'
    UNION ALL SELECT 3506, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3506, 'creature_bone_qty', '303'
    UNION ALL SELECT 3507, 'creature_health', '455'
    UNION ALL SELECT 3507, 'creature_strength', '455'
    UNION ALL SELECT 3507, 'creature_constitution', '455'
    UNION ALL SELECT 3507, 'creature_action', '455'
    UNION ALL SELECT 3507, 'creature_quickness', '455'
    UNION ALL SELECT 3507, 'creature_stamina', '455'
    UNION ALL SELECT 3507, 'creature_mind', '455'
    UNION ALL SELECT 3507, 'creature_focus', '455'
    UNION ALL SELECT 3507, 'creature_willpower', '455'
    UNION ALL SELECT 3507, 'creature_ham_min', '410'
    UNION ALL SELECT 3507, 'creature_ham_max', '500'
    UNION ALL SELECT 3507, 'creature_tohit', '27'
    UNION ALL SELECT 3507, 'creature_damage_min', '70'
    UNION ALL SELECT 3507, 'creature_damage_max', '75'
    UNION ALL SELECT 3507, 'creature_xp', '235'
    UNION ALL SELECT 3507, 'creature_social_group', 'Langlatch'
    UNION ALL SELECT 3507, 'killer', '0'
    UNION ALL SELECT 3507, 'Pack', '1'
    UNION ALL SELECT 3507, 'Herd', '0'
    UNION ALL SELECT 3507, 'stalking', '0'
    UNION ALL SELECT 3507, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3507, 'creature_group_assist', '1'
    UNION ALL SELECT 3507, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3507, 'creature_meat_qty', '7'
    UNION ALL SELECT 3507, 'res_hide', 'Wooly Hide'
    UNION ALL SELECT 3507, 'creature_hide_qty', '6'
    UNION ALL SELECT 3507, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3507, 'creature_bone_qty', '6'
    UNION ALL SELECT 3508, 'creature_health', '455'
    UNION ALL SELECT 3508, 'creature_strength', '455'
    UNION ALL SELECT 3508, 'creature_constitution', '455'
    UNION ALL SELECT 3508, 'creature_action', '455'
    UNION ALL SELECT 3508, 'creature_quickness', '455'
    UNION ALL SELECT 3508, 'creature_stamina', '455'
    UNION ALL SELECT 3508, 'creature_mind', '455'
    UNION ALL SELECT 3508, 'creature_focus', '455'
    UNION ALL SELECT 3508, 'creature_willpower', '455'
    UNION ALL SELECT 3508, 'creature_ham_min', '410'
    UNION ALL SELECT 3508, 'creature_ham_max', '500'
    UNION ALL SELECT 3508, 'creature_tohit', '27'
    UNION ALL SELECT 3508, 'creature_damage_min', '70'
    UNION ALL SELECT 3508, 'creature_damage_max', '75'
    UNION ALL SELECT 3508, 'creature_xp', '235'
    UNION ALL SELECT 3508, 'creature_social_group', 'Kusak'
    UNION ALL SELECT 3508, 'killer', '0'
    UNION ALL SELECT 3508, 'Pack', '1'
    UNION ALL SELECT 3508, 'Herd', '0'
    UNION ALL SELECT 3508, 'stalking', '1'
    UNION ALL SELECT 3508, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3508, 'creature_group_assist', '1'
    UNION ALL SELECT 3508, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3508, 'creature_meat_qty', '10'
    UNION ALL SELECT 3508, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3508, 'creature_hide_qty', '7'
    UNION ALL SELECT 3508, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3508, 'creature_bone_qty', '5'
    UNION ALL SELECT 3509, 'creature_health', '125'
    UNION ALL SELECT 3509, 'creature_strength', '125'
    UNION ALL SELECT 3509, 'creature_constitution', '125'
    UNION ALL SELECT 3509, 'creature_action', '125'
    UNION ALL SELECT 3509, 'creature_quickness', '125'
    UNION ALL SELECT 3509, 'creature_stamina', '125'
    UNION ALL SELECT 3509, 'creature_mind', '125'
    UNION ALL SELECT 3509, 'creature_focus', '125'
    UNION ALL SELECT 3509, 'creature_willpower', '125'
    UNION ALL SELECT 3509, 'creature_ham_min', '110'
    UNION ALL SELECT 3509, 'creature_ham_max', '140'
    UNION ALL SELECT 3509, 'creature_tohit', '24'
    UNION ALL SELECT 3509, 'creature_damage_min', '40'
    UNION ALL SELECT 3509, 'creature_damage_max', '45'
    UNION ALL SELECT 3509, 'creature_xp', '85'
    UNION ALL SELECT 3509, 'creature_social_group', 'Langlatch'
    UNION ALL SELECT 3509, 'killer', '0'
    UNION ALL SELECT 3509, 'Pack', '1'
    UNION ALL SELECT 3509, 'Herd', '0'
    UNION ALL SELECT 3509, 'stalking', '0'
    UNION ALL SELECT 3509, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3509, 'creature_group_assist', '1'
    UNION ALL SELECT 3509, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3509, 'creature_meat_qty', '5'
    UNION ALL SELECT 3509, 'res_hide', 'Wooly Hide'
    UNION ALL SELECT 3509, 'creature_hide_qty', '3'
    UNION ALL SELECT 3509, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3509, 'creature_bone_qty', '3'
    UNION ALL SELECT 3510, 'creature_health', '155'
    UNION ALL SELECT 3510, 'creature_strength', '155'
    UNION ALL SELECT 3510, 'creature_constitution', '155'
    UNION ALL SELECT 3510, 'creature_action', '155'
    UNION ALL SELECT 3510, 'creature_quickness', '155'
    UNION ALL SELECT 3510, 'creature_stamina', '155'
    UNION ALL SELECT 3510, 'creature_mind', '155'
    UNION ALL SELECT 3510, 'creature_focus', '155'
    UNION ALL SELECT 3510, 'creature_willpower', '155'
    UNION ALL SELECT 3510, 'creature_ham_min', '140'
    UNION ALL SELECT 3510, 'creature_ham_max', '170'
    UNION ALL SELECT 3510, 'creature_tohit', '25'
    UNION ALL SELECT 3510, 'creature_damage_min', '45'
    UNION ALL SELECT 3510, 'creature_damage_max', '50'
    UNION ALL SELECT 3510, 'creature_xp', '113'
    UNION ALL SELECT 3510, 'creature_social_group', 'Pharple'
    UNION ALL SELECT 3510, 'killer', '0'
    UNION ALL SELECT 3510, 'Pack', '1'
    UNION ALL SELECT 3510, 'Herd', '1'
    UNION ALL SELECT 3510, 'stalking', '0'
    UNION ALL SELECT 3510, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3510, 'creature_group_assist', '1'
    UNION ALL SELECT 3510, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3510, 'creature_meat_qty', '18'
    UNION ALL SELECT 3510, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3510, 'creature_hide_qty', '10'
    UNION ALL SELECT 3510, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3510, 'creature_bone_qty', '7'
    UNION ALL SELECT 3511, 'creature_health', '100'
    UNION ALL SELECT 3511, 'creature_strength', '100'
    UNION ALL SELECT 3511, 'creature_constitution', '100'
    UNION ALL SELECT 3511, 'creature_action', '100'
    UNION ALL SELECT 3511, 'creature_quickness', '100'
    UNION ALL SELECT 3511, 'creature_stamina', '100'
    UNION ALL SELECT 3511, 'creature_mind', '100'
    UNION ALL SELECT 3511, 'creature_focus', '100'
    UNION ALL SELECT 3511, 'creature_willpower', '100'
    UNION ALL SELECT 3511, 'creature_ham_min', '90'
    UNION ALL SELECT 3511, 'creature_ham_max', '110'
    UNION ALL SELECT 3511, 'creature_tohit', '23'
    UNION ALL SELECT 3511, 'creature_damage_min', '35'
    UNION ALL SELECT 3511, 'creature_damage_max', '45'
    UNION ALL SELECT 3511, 'creature_xp', '62'
    UNION ALL SELECT 3511, 'creature_social_group', 'Pharple'
    UNION ALL SELECT 3511, 'killer', '0'
    UNION ALL SELECT 3511, 'Pack', '1'
    UNION ALL SELECT 3511, 'Herd', '1'
    UNION ALL SELECT 3511, 'stalking', '0'
    UNION ALL SELECT 3511, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3511, 'creature_group_assist', '1'
    UNION ALL SELECT 3511, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3511, 'creature_meat_qty', '15'
    UNION ALL SELECT 3511, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3511, 'creature_hide_qty', '7'
    UNION ALL SELECT 3511, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3511, 'creature_bone_qty', '5'
    UNION ALL SELECT 3512, 'creature_health', '1095'
    UNION ALL SELECT 3512, 'creature_strength', '1095'
    UNION ALL SELECT 3512, 'creature_constitution', '1095'
    UNION ALL SELECT 3512, 'creature_action', '1095'
    UNION ALL SELECT 3512, 'creature_quickness', '1095'
    UNION ALL SELECT 3512, 'creature_stamina', '1095'
    UNION ALL SELECT 3512, 'creature_mind', '1095'
    UNION ALL SELECT 3512, 'creature_focus', '1095'
    UNION ALL SELECT 3512, 'creature_willpower', '1095'
    UNION ALL SELECT 3512, 'creature_ham_min', '990'
    UNION ALL SELECT 3512, 'creature_ham_max', '1200'
    UNION ALL SELECT 3512, 'creature_tohit', '29'
    UNION ALL SELECT 3512, 'creature_damage_min', '120'
    UNION ALL SELECT 3512, 'creature_damage_max', '130'
    UNION ALL SELECT 3512, 'creature_xp', '430'
    UNION ALL SELECT 3512, 'creature_social_group', 'Spinesnake'
    UNION ALL SELECT 3512, 'killer', '0'
    UNION ALL SELECT 3512, 'Pack', '1'
    UNION ALL SELECT 3512, 'Herd', '0'
    UNION ALL SELECT 3512, 'stalking', '0'
    UNION ALL SELECT 3512, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3512, 'creature_group_assist', '1'
    UNION ALL SELECT 3512, 'res_meat', 'Reptilian Meat'
    UNION ALL SELECT 3512, 'creature_meat_qty', '7'
    UNION ALL SELECT 3512, 'res_hide', 'Leathery Hide'
    UNION ALL SELECT 3512, 'creature_hide_qty', '2'
    UNION ALL SELECT 3512, 'creature_bone_qty', '0'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (601, 'object/tangible/lair/flit/shared_lair_flit.iff', 'flit', 'lair_n', '', ''),
  (602, 'object/tangible/lair/flit/shared_lair_flit.iff', 'flit_bloodsucker', 'lair_n', '', ''),
  (603, 'object/tangible/lair/flit/shared_lair_flit.iff', 'flit_harasser', 'lair_n', '', ''),
  (604, 'object/tangible/lair/flit/shared_lair_flit.iff', 'flit_youth', 'lair_n', '', ''),
  (605, 'object/tangible/lair/pharple/shared_lair_pharple.iff', 'giant_pharple', 'lair_n', '', ''),
  (606, 'object/tangible/lair/gurnaset/shared_lair_gurnaset.iff', 'gurnaset_hatchling', 'lair_n', '', ''),
  (607, 'object/tangible/lair/langlatch/shared_lair_langlatch.iff', 'langlatch_juvenile', 'lair_n', '', ''),
  (608, 'object/tangible/lair/kusak/shared_lair_kusak.iff', 'kusak_pup', 'lair_n', '', ''),
  (609, 'object/tangible/lair/langlatch/shared_lair_langlatch.iff', 'langlatch_hatchling', 'lair_n', '', ''),
  (610, 'object/tangible/lair/pharple/shared_lair_pharple.iff', 'pharple', 'lair_n', '', ''),
  (611, 'object/tangible/lair/pharple/shared_lair_pharple.iff', 'runty_pharple', 'lair_n', '', ''),
  (612, 'object/tangible/lair/spined_snake/shared_lair_spined_snake.iff', 'young_spined_snake', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (601, 601, 3501),
  (602, 602, 3502),
  (603, 603, 3503),
  (604, 604, 3504),
  (605, 605, 3505),
  (606, 606, 3506),
  (607, 607, 3507),
  (608, 608, 3508),
  (609, 609, 3509),
  (610, 610, 3510),
  (611, 611, 3511),
  (612, 612, 3512);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (601, 806, 9, 1, 601, 601, 6, 0, 0, 0, 1, 0),
  (602, 806, 9, 1, 602, 602, 6, 0, 0, 0, 1, 0),
  (603, 806, 9, 1, 603, 603, 6, 0, 0, 0, 1, 0),
  (604, 806, 9, 1, 604, 604, 6, 0, 0, 0, 1, 0),
  (605, 806, 9, 1, 605, 605, 6, 0, 0, 0, 1, 0),
  (606, 806, 9, 1, 606, 606, 6, 0, 0, 0, 1, 0),
  (607, 806, 9, 1, 607, 607, 6, 0, 0, 0, 1, 0),
  (608, 806, 9, 1, 608, 608, 6, 0, 0, 0, 1, 0),
  (609, 806, 9, 1, 609, 609, 6, 0, 0, 0, 1, 0),
  (610, 806, 9, 1, 610, 610, 6, 0, 0, 0, 1, 0),
  (611, 806, 9, 1, 611, 611, 6, 0, 0, 0, 1, 0),
  (612, 806, 9, 1, 612, 612, 6, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 6001 AS id, 601 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 6002, 601, 'lair_wave_size', '5'
    UNION ALL SELECT 6003, 601, 'lair_passive_waves', '3'
    UNION ALL SELECT 6004, 601, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6005, 601, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6006, 601, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6007, 601, 'creature_xp', '235'
    UNION ALL SELECT 6008, 601, 'creature_health', '4000'
    UNION ALL SELECT 6009, 601, 'creature_strength', '4000'
    UNION ALL SELECT 6010, 601, 'creature_constitution', '4000'
    UNION ALL SELECT 6011, 601, 'lair_min_city_distance', '600'
    UNION ALL SELECT 6012, 601, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 6013, 602, 'lair_fix_position', '0'
    UNION ALL SELECT 6014, 602, 'lair_wave_size', '5'
    UNION ALL SELECT 6015, 602, 'lair_passive_waves', '3'
    UNION ALL SELECT 6016, 602, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6017, 602, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6018, 602, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6019, 602, 'creature_xp', '292'
    UNION ALL SELECT 6020, 602, 'creature_health', '4500'
    UNION ALL SELECT 6021, 602, 'creature_strength', '4500'
    UNION ALL SELECT 6022, 602, 'creature_constitution', '4500'
    UNION ALL SELECT 6023, 602, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 6024, 603, 'lair_fix_position', '0'
    UNION ALL SELECT 6025, 603, 'lair_wave_size', '5'
    UNION ALL SELECT 6026, 603, 'lair_passive_waves', '3'
    UNION ALL SELECT 6027, 603, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6028, 603, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6029, 603, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6030, 603, 'creature_xp', '356'
    UNION ALL SELECT 6031, 603, 'creature_health', '5000'
    UNION ALL SELECT 6032, 603, 'creature_strength', '5000'
    UNION ALL SELECT 6033, 603, 'creature_constitution', '5000'
    UNION ALL SELECT 6034, 603, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 6035, 604, 'lair_fix_position', '0'
    UNION ALL SELECT 6036, 604, 'lair_wave_size', '5'
    UNION ALL SELECT 6037, 604, 'lair_passive_waves', '3'
    UNION ALL SELECT 6038, 604, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6039, 604, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6040, 604, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6041, 604, 'creature_xp', '147'
    UNION ALL SELECT 6042, 604, 'creature_health', '3000'
    UNION ALL SELECT 6043, 604, 'creature_strength', '3000'
    UNION ALL SELECT 6044, 604, 'creature_constitution', '3000'
    UNION ALL SELECT 6045, 604, 'lair_min_city_distance', '600'
    UNION ALL SELECT 6046, 604, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 6047, 605, 'lair_fix_position', '0'
    UNION ALL SELECT 6048, 605, 'lair_wave_size', '5'
    UNION ALL SELECT 6049, 605, 'lair_passive_waves', '3'
    UNION ALL SELECT 6050, 605, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6051, 605, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6052, 605, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6053, 605, 'creature_xp', '187'
    UNION ALL SELECT 6054, 605, 'creature_health', '3500'
    UNION ALL SELECT 6055, 605, 'creature_strength', '3500'
    UNION ALL SELECT 6056, 605, 'creature_constitution', '3500'
    UNION ALL SELECT 6057, 605, 'lair_min_city_distance', '600'
    UNION ALL SELECT 6058, 605, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 6059, 606, 'lair_fix_position', '0'
    UNION ALL SELECT 6060, 606, 'lair_wave_size', '5'
    UNION ALL SELECT 6061, 606, 'lair_passive_waves', '3'
    UNION ALL SELECT 6062, 606, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6063, 606, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6064, 606, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6065, 606, 'creature_xp', '85'
    UNION ALL SELECT 6066, 606, 'creature_health', '2500'
    UNION ALL SELECT 6067, 606, 'creature_strength', '2500'
    UNION ALL SELECT 6068, 606, 'creature_constitution', '2500'
    UNION ALL SELECT 6069, 606, 'lair_min_city_distance', '50'
    UNION ALL SELECT 6070, 606, 'lair_max_city_distance', '600'
    UNION ALL SELECT 6071, 607, 'lair_fix_position', '0'
    UNION ALL SELECT 6072, 607, 'lair_wave_size', '5'
    UNION ALL SELECT 6073, 607, 'lair_passive_waves', '3'
    UNION ALL SELECT 6074, 607, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6075, 607, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6076, 607, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6077, 607, 'creature_xp', '235'
    UNION ALL SELECT 6078, 607, 'creature_health', '4000'
    UNION ALL SELECT 6079, 607, 'creature_strength', '4000'
    UNION ALL SELECT 6080, 607, 'creature_constitution', '4000'
    UNION ALL SELECT 6081, 607, 'lair_min_city_distance', '600'
    UNION ALL SELECT 6082, 607, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 6083, 608, 'lair_fix_position', '0'
    UNION ALL SELECT 6084, 608, 'lair_wave_size', '5'
    UNION ALL SELECT 6085, 608, 'lair_passive_waves', '3'
    UNION ALL SELECT 6086, 608, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6087, 608, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6088, 608, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6089, 608, 'creature_xp', '235'
    UNION ALL SELECT 6090, 608, 'creature_health', '4000'
    UNION ALL SELECT 6091, 608, 'creature_strength', '4000'
    UNION ALL SELECT 6092, 608, 'creature_constitution', '4000'
    UNION ALL SELECT 6093, 608, 'lair_min_city_distance', '600'
    UNION ALL SELECT 6094, 608, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 6095, 609, 'lair_fix_position', '0'
    UNION ALL SELECT 6096, 609, 'lair_wave_size', '5'
    UNION ALL SELECT 6097, 609, 'lair_passive_waves', '3'
    UNION ALL SELECT 6098, 609, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6099, 609, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6100, 609, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6101, 609, 'creature_xp', '85'
    UNION ALL SELECT 6102, 609, 'creature_health', '2000'
    UNION ALL SELECT 6103, 609, 'creature_strength', '2000'
    UNION ALL SELECT 6104, 609, 'creature_constitution', '2000'
    UNION ALL SELECT 6105, 609, 'lair_min_city_distance', '50'
    UNION ALL SELECT 6106, 609, 'lair_max_city_distance', '600'
    UNION ALL SELECT 6107, 610, 'lair_fix_position', '0'
    UNION ALL SELECT 6108, 610, 'lair_wave_size', '5'
    UNION ALL SELECT 6109, 610, 'lair_passive_waves', '3'
    UNION ALL SELECT 6110, 610, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6111, 610, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6112, 610, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6113, 610, 'creature_xp', '113'
    UNION ALL SELECT 6114, 610, 'creature_health', '2500'
    UNION ALL SELECT 6115, 610, 'creature_strength', '2500'
    UNION ALL SELECT 6116, 610, 'creature_constitution', '2500'
    UNION ALL SELECT 6117, 610, 'lair_min_city_distance', '50'
    UNION ALL SELECT 6118, 610, 'lair_max_city_distance', '600'
    UNION ALL SELECT 6119, 611, 'lair_fix_position', '0'
    UNION ALL SELECT 6120, 611, 'lair_wave_size', '5'
    UNION ALL SELECT 6121, 611, 'lair_passive_waves', '3'
    UNION ALL SELECT 6122, 611, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6123, 611, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6124, 611, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6125, 611, 'creature_xp', '62'
    UNION ALL SELECT 6126, 611, 'creature_health', '1500'
    UNION ALL SELECT 6127, 611, 'creature_strength', '1500'
    UNION ALL SELECT 6128, 611, 'creature_constitution', '1500'
    UNION ALL SELECT 6129, 611, 'lair_min_city_distance', '50'
    UNION ALL SELECT 6130, 611, 'lair_max_city_distance', '600'
    UNION ALL SELECT 6131, 612, 'lair_fix_position', '0'
    UNION ALL SELECT 6132, 612, 'lair_wave_size', '5'
    UNION ALL SELECT 6133, 612, 'lair_passive_waves', '3'
    UNION ALL SELECT 6134, 612, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 6135, 612, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 6136, 612, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 6137, 612, 'creature_xp', '430'
    UNION ALL SELECT 6138, 612, 'creature_health', '5500'
    UNION ALL SELECT 6139, 612, 'creature_strength', '5500'
    UNION ALL SELECT 6140, 612, 'creature_constitution', '5500'
    UNION ALL SELECT 6141, 612, 'lair_min_city_distance', '1500'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
