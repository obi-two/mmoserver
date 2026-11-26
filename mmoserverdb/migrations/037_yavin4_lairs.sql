-- Yavin4: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
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
--   angler hatchling         lvl 8  600-1500 m  6 lairs  model angler_hatchling  (Prima 2004, pp. 172-173)
--   choku pup                lvl 8  600-1500 m  6 lairs  model choku_pup  (Prima 2004, pp. 174-175)
--   gackle bat               lvl 10 1500 m+     6 lairs  model gackle_bat  (Prima 2004, pp. 176-177)
--   mamien youth             lvl 9  1500 m+     6 lairs  model mamien (key mamien_youth)  (Prima 2004, pp. 180-181)
--   puny gackle bat          lvl 6  600-1500 m  6 lairs  model puny_gackle_bat  (Prima 2004, pp. 182-183)
--   puny stintaril           lvl 9  1500 m+     6 lairs  model puny_stintaril  (Prima 2004, pp. 182-183)
--   puny tanc mite           lvl 2  50-600 m    6 lairs  model puny_tanc_mite  (Prima 2004, pp. 182-183)
--   skreeg infant            lvl 4  50-600 m    6 lairs  model skreeg_infant  (Prima 2004, pp. 182-183)
--   stintaril scavenger      lvl 11 1500 m+     6 lairs  model stintaril (key stintaril_scavenger)  (Prima 2004, pp. 184-185)
--   swarming kliknik         lvl 10 1500 m+     6 lairs  model kliknik (key kliknik_swarming)  (Prima 2004, pp. 184-185)
--   tanc mite                lvl 9  1500 m+     6 lairs  model tanc_mite  (Prima 2004, pp. 184-185)
--   whisper bird hatchling   lvl 7  600-1500 m  6 lairs  model whisper_bird_hatchling  (Prima 2004, pp. 184-185)
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
  VALUES (810, -7600, -7600, 15200, 15200, 9, 1);

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (3901, 8, 1, 1, 'object/mobile/shared_angler_hatchling.iff', 'angler_hatchling', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3902, 8, 1, 1, 'object/mobile/shared_choku_pup.iff', 'choku_pup', 'mob/creature_names', 8, 1, 0, 0, 0, 1),
  (3903, 8, 1, 1, 'object/mobile/shared_gackle_bat.iff', 'gackle_bat', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3904, 8, 1, 1, 'object/mobile/shared_mamien.iff', 'mamien_youth', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3905, 8, 1, 1, 'object/mobile/shared_puny_gackle_bat.iff', 'puny_gackle_bat', 'mob/creature_names', 6, 1, 0, 0, 0, 1),
  (3906, 8, 1, 1, 'object/mobile/shared_puny_stintaril.iff', 'puny_stintaril', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3907, 8, 1, 1, 'object/mobile/shared_puny_tanc_mite.iff', 'puny_tanc_mite', 'mob/creature_names', 2, 1, 0, 0, 0, 1),
  (3908, 8, 1, 1, 'object/mobile/shared_skreeg_infant.iff', 'skreeg_infant', 'mob/creature_names', 4, 1, 0, 0, 0, 1),
  (3909, 8, 1, 1, 'object/mobile/shared_stintaril.iff', 'stintaril_scavenger', 'mob/creature_names', 11, 1, 0, 0, 0, 1),
  (3910, 8, 1, 1, 'object/mobile/shared_kliknik.iff', 'kliknik_swarming', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (3911, 8, 1, 1, 'object/mobile/shared_tanc_mite.iff', 'tanc_mite', 'mob/creature_names', 9, 1, 0, 0, 0, 1),
  (3912, 8, 1, 1, 'object/mobile/shared_whisper_bird_hatchling.iff', 'whisper_bird_hatchling', 'mob/creature_names', 7, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 3901 AS npc_id, 'creature_health' AS name, '455' AS value
    UNION ALL SELECT 3901, 'creature_strength', '455'
    UNION ALL SELECT 3901, 'creature_constitution', '455'
    UNION ALL SELECT 3901, 'creature_action', '455'
    UNION ALL SELECT 3901, 'creature_quickness', '455'
    UNION ALL SELECT 3901, 'creature_stamina', '455'
    UNION ALL SELECT 3901, 'creature_mind', '455'
    UNION ALL SELECT 3901, 'creature_focus', '455'
    UNION ALL SELECT 3901, 'creature_willpower', '455'
    UNION ALL SELECT 3901, 'creature_ham_min', '410'
    UNION ALL SELECT 3901, 'creature_ham_max', '500'
    UNION ALL SELECT 3901, 'creature_tohit', '27'
    UNION ALL SELECT 3901, 'creature_damage_min', '70'
    UNION ALL SELECT 3901, 'creature_damage_max', '75'
    UNION ALL SELECT 3901, 'creature_xp', '235'
    UNION ALL SELECT 3901, 'creature_social_group', 'Angler'
    UNION ALL SELECT 3901, 'killer', '0'
    UNION ALL SELECT 3901, 'Pack', '1'
    UNION ALL SELECT 3901, 'Herd', '0'
    UNION ALL SELECT 3901, 'stalking', '1'
    UNION ALL SELECT 3901, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3901, 'creature_group_assist', '1'
    UNION ALL SELECT 3901, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3901, 'creature_meat_qty', '2'
    UNION ALL SELECT 3901, 'creature_hide_qty', '0'
    UNION ALL SELECT 3901, 'creature_bone_qty', '0'
    UNION ALL SELECT 3902, 'creature_health', '455'
    UNION ALL SELECT 3902, 'creature_strength', '455'
    UNION ALL SELECT 3902, 'creature_constitution', '455'
    UNION ALL SELECT 3902, 'creature_action', '455'
    UNION ALL SELECT 3902, 'creature_quickness', '455'
    UNION ALL SELECT 3902, 'creature_stamina', '455'
    UNION ALL SELECT 3902, 'creature_mind', '455'
    UNION ALL SELECT 3902, 'creature_focus', '455'
    UNION ALL SELECT 3902, 'creature_willpower', '455'
    UNION ALL SELECT 3902, 'creature_ham_min', '410'
    UNION ALL SELECT 3902, 'creature_ham_max', '500'
    UNION ALL SELECT 3902, 'creature_tohit', '27'
    UNION ALL SELECT 3902, 'creature_damage_min', '70'
    UNION ALL SELECT 3902, 'creature_damage_max', '75'
    UNION ALL SELECT 3902, 'creature_xp', '235'
    UNION ALL SELECT 3902, 'creature_social_group', 'Choku'
    UNION ALL SELECT 3902, 'killer', '0'
    UNION ALL SELECT 3902, 'Pack', '1'
    UNION ALL SELECT 3902, 'Herd', '0'
    UNION ALL SELECT 3902, 'stalking', '1'
    UNION ALL SELECT 3902, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3902, 'creature_group_assist', '1'
    UNION ALL SELECT 3902, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3902, 'creature_meat_qty', '7'
    UNION ALL SELECT 3902, 'creature_hide_qty', '0'
    UNION ALL SELECT 3902, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3902, 'creature_bone_qty', '5'
    UNION ALL SELECT 3903, 'creature_health', '455'
    UNION ALL SELECT 3903, 'creature_strength', '455'
    UNION ALL SELECT 3903, 'creature_constitution', '455'
    UNION ALL SELECT 3903, 'creature_action', '455'
    UNION ALL SELECT 3903, 'creature_quickness', '455'
    UNION ALL SELECT 3903, 'creature_stamina', '455'
    UNION ALL SELECT 3903, 'creature_mind', '455'
    UNION ALL SELECT 3903, 'creature_focus', '455'
    UNION ALL SELECT 3903, 'creature_willpower', '455'
    UNION ALL SELECT 3903, 'creature_ham_min', '410'
    UNION ALL SELECT 3903, 'creature_ham_max', '500'
    UNION ALL SELECT 3903, 'creature_tohit', '28'
    UNION ALL SELECT 3903, 'creature_damage_min', '120'
    UNION ALL SELECT 3903, 'creature_damage_max', '130'
    UNION ALL SELECT 3903, 'creature_xp', '356'
    UNION ALL SELECT 3903, 'creature_social_group', 'Gacklebat'
    UNION ALL SELECT 3903, 'killer', '0'
    UNION ALL SELECT 3903, 'Pack', '1'
    UNION ALL SELECT 3903, 'Herd', '0'
    UNION ALL SELECT 3903, 'stalking', '0'
    UNION ALL SELECT 3903, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3903, 'creature_group_assist', '1'
    UNION ALL SELECT 3903, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3903, 'creature_meat_qty', '4'
    UNION ALL SELECT 3903, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3903, 'creature_hide_qty', '2'
    UNION ALL SELECT 3903, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3903, 'creature_bone_qty', '3'
    UNION ALL SELECT 3904, 'creature_health', '755'
    UNION ALL SELECT 3904, 'creature_strength', '755'
    UNION ALL SELECT 3904, 'creature_constitution', '755'
    UNION ALL SELECT 3904, 'creature_action', '755'
    UNION ALL SELECT 3904, 'creature_quickness', '755'
    UNION ALL SELECT 3904, 'creature_stamina', '755'
    UNION ALL SELECT 3904, 'creature_mind', '755'
    UNION ALL SELECT 3904, 'creature_focus', '755'
    UNION ALL SELECT 3904, 'creature_willpower', '755'
    UNION ALL SELECT 3904, 'creature_ham_min', '680'
    UNION ALL SELECT 3904, 'creature_ham_max', '830'
    UNION ALL SELECT 3904, 'creature_tohit', '27'
    UNION ALL SELECT 3904, 'creature_damage_min', '80'
    UNION ALL SELECT 3904, 'creature_damage_max', '90'
    UNION ALL SELECT 3904, 'creature_xp', '235'
    UNION ALL SELECT 3904, 'creature_social_group', 'Marnien'
    UNION ALL SELECT 3904, 'killer', '0'
    UNION ALL SELECT 3904, 'Pack', '0'
    UNION ALL SELECT 3904, 'Herd', '0'
    UNION ALL SELECT 3904, 'stalking', '0'
    UNION ALL SELECT 3904, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3904, 'creature_group_assist', '0'
    UNION ALL SELECT 3904, 'res_meat', 'Wild Meat'
    UNION ALL SELECT 3904, 'creature_meat_qty', '35'
    UNION ALL SELECT 3904, 'res_hide', 'Wooly Hide'
    UNION ALL SELECT 3904, 'creature_hide_qty', '20'
    UNION ALL SELECT 3904, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3904, 'creature_bone_qty', '20'
    UNION ALL SELECT 3905, 'creature_health', '200'
    UNION ALL SELECT 3905, 'creature_strength', '200'
    UNION ALL SELECT 3905, 'creature_constitution', '200'
    UNION ALL SELECT 3905, 'creature_action', '200'
    UNION ALL SELECT 3905, 'creature_quickness', '200'
    UNION ALL SELECT 3905, 'creature_stamina', '200'
    UNION ALL SELECT 3905, 'creature_mind', '200'
    UNION ALL SELECT 3905, 'creature_focus', '200'
    UNION ALL SELECT 3905, 'creature_willpower', '200'
    UNION ALL SELECT 3905, 'creature_ham_min', '180'
    UNION ALL SELECT 3905, 'creature_ham_max', '220'
    UNION ALL SELECT 3905, 'creature_tohit', '25'
    UNION ALL SELECT 3905, 'creature_damage_min', '50'
    UNION ALL SELECT 3905, 'creature_damage_max', '55'
    UNION ALL SELECT 3905, 'creature_xp', '147'
    UNION ALL SELECT 3905, 'creature_social_group', 'Gacklebat'
    UNION ALL SELECT 3905, 'killer', '0'
    UNION ALL SELECT 3905, 'Pack', '1'
    UNION ALL SELECT 3905, 'Herd', '0'
    UNION ALL SELECT 3905, 'stalking', '0'
    UNION ALL SELECT 3905, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3905, 'creature_group_assist', '1'
    UNION ALL SELECT 3905, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3905, 'creature_meat_qty', '2'
    UNION ALL SELECT 3905, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3905, 'creature_hide_qty', '1'
    UNION ALL SELECT 3905, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3905, 'creature_bone_qty', '1'
    UNION ALL SELECT 3906, 'creature_health', '755'
    UNION ALL SELECT 3906, 'creature_strength', '755'
    UNION ALL SELECT 3906, 'creature_constitution', '755'
    UNION ALL SELECT 3906, 'creature_action', '755'
    UNION ALL SELECT 3906, 'creature_quickness', '755'
    UNION ALL SELECT 3906, 'creature_stamina', '755'
    UNION ALL SELECT 3906, 'creature_mind', '755'
    UNION ALL SELECT 3906, 'creature_focus', '755'
    UNION ALL SELECT 3906, 'creature_willpower', '755'
    UNION ALL SELECT 3906, 'creature_ham_min', '680'
    UNION ALL SELECT 3906, 'creature_ham_max', '830'
    UNION ALL SELECT 3906, 'creature_tohit', '27'
    UNION ALL SELECT 3906, 'creature_damage_min', '80'
    UNION ALL SELECT 3906, 'creature_damage_max', '90'
    UNION ALL SELECT 3906, 'creature_xp', '292'
    UNION ALL SELECT 3906, 'creature_social_group', 'Stinaril'
    UNION ALL SELECT 3906, 'killer', '0'
    UNION ALL SELECT 3906, 'Pack', '1'
    UNION ALL SELECT 3906, 'Herd', '0'
    UNION ALL SELECT 3906, 'stalking', '0'
    UNION ALL SELECT 3906, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3906, 'creature_group_assist', '1'
    UNION ALL SELECT 3906, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3906, 'creature_meat_qty', '2'
    UNION ALL SELECT 3906, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3906, 'creature_hide_qty', '1'
    UNION ALL SELECT 3906, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3906, 'creature_bone_qty', '1'
    UNION ALL SELECT 3907, 'creature_health', '75'
    UNION ALL SELECT 3907, 'creature_strength', '75'
    UNION ALL SELECT 3907, 'creature_constitution', '75'
    UNION ALL SELECT 3907, 'creature_action', '75'
    UNION ALL SELECT 3907, 'creature_quickness', '75'
    UNION ALL SELECT 3907, 'creature_stamina', '75'
    UNION ALL SELECT 3907, 'creature_mind', '75'
    UNION ALL SELECT 3907, 'creature_focus', '75'
    UNION ALL SELECT 3907, 'creature_willpower', '75'
    UNION ALL SELECT 3907, 'creature_ham_min', '68'
    UNION ALL SELECT 3907, 'creature_ham_max', '83'
    UNION ALL SELECT 3907, 'creature_tohit', '21'
    UNION ALL SELECT 3907, 'creature_damage_min', '35'
    UNION ALL SELECT 3907, 'creature_damage_max', '40'
    UNION ALL SELECT 3907, 'creature_xp', '45'
    UNION ALL SELECT 3907, 'creature_social_group', 'Tancmite'
    UNION ALL SELECT 3907, 'killer', '0'
    UNION ALL SELECT 3907, 'Pack', '1'
    UNION ALL SELECT 3907, 'Herd', '1'
    UNION ALL SELECT 3907, 'stalking', '0'
    UNION ALL SELECT 3907, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3907, 'creature_group_assist', '1'
    UNION ALL SELECT 3907, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3907, 'creature_meat_qty', '2'
    UNION ALL SELECT 3907, 'creature_hide_qty', '0'
    UNION ALL SELECT 3907, 'creature_bone_qty', '0'
    UNION ALL SELECT 3908, 'creature_health', '125'
    UNION ALL SELECT 3908, 'creature_strength', '125'
    UNION ALL SELECT 3908, 'creature_constitution', '125'
    UNION ALL SELECT 3908, 'creature_action', '125'
    UNION ALL SELECT 3908, 'creature_quickness', '125'
    UNION ALL SELECT 3908, 'creature_stamina', '125'
    UNION ALL SELECT 3908, 'creature_mind', '125'
    UNION ALL SELECT 3908, 'creature_focus', '125'
    UNION ALL SELECT 3908, 'creature_willpower', '125'
    UNION ALL SELECT 3908, 'creature_ham_min', '110'
    UNION ALL SELECT 3908, 'creature_ham_max', '140'
    UNION ALL SELECT 3908, 'creature_tohit', '24'
    UNION ALL SELECT 3908, 'creature_damage_min', '40'
    UNION ALL SELECT 3908, 'creature_damage_max', '45'
    UNION ALL SELECT 3908, 'creature_xp', '85'
    UNION ALL SELECT 3908, 'creature_social_group', 'Skreeg'
    UNION ALL SELECT 3908, 'killer', '0'
    UNION ALL SELECT 3908, 'Pack', '1'
    UNION ALL SELECT 3908, 'Herd', '0'
    UNION ALL SELECT 3908, 'stalking', '0'
    UNION ALL SELECT 3908, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3908, 'creature_group_assist', '1'
    UNION ALL SELECT 3908, 'res_meat', 'Herbivore Meat'
    UNION ALL SELECT 3908, 'creature_meat_qty', '15'
    UNION ALL SELECT 3908, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3908, 'creature_hide_qty', '9'
    UNION ALL SELECT 3908, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3908, 'creature_bone_qty', '7'
    UNION ALL SELECT 3909, 'creature_health', '1095'
    UNION ALL SELECT 3909, 'creature_strength', '1095'
    UNION ALL SELECT 3909, 'creature_constitution', '1095'
    UNION ALL SELECT 3909, 'creature_action', '1095'
    UNION ALL SELECT 3909, 'creature_quickness', '1095'
    UNION ALL SELECT 3909, 'creature_stamina', '1095'
    UNION ALL SELECT 3909, 'creature_mind', '1095'
    UNION ALL SELECT 3909, 'creature_focus', '1095'
    UNION ALL SELECT 3909, 'creature_willpower', '1095'
    UNION ALL SELECT 3909, 'creature_ham_min', '990'
    UNION ALL SELECT 3909, 'creature_ham_max', '1200'
    UNION ALL SELECT 3909, 'creature_tohit', '29'
    UNION ALL SELECT 3909, 'creature_damage_min', '120'
    UNION ALL SELECT 3909, 'creature_damage_max', '130'
    UNION ALL SELECT 3909, 'creature_xp', '430'
    UNION ALL SELECT 3909, 'creature_social_group', 'Stinaril'
    UNION ALL SELECT 3909, 'killer', '0'
    UNION ALL SELECT 3909, 'Pack', '1'
    UNION ALL SELECT 3909, 'Herd', '0'
    UNION ALL SELECT 3909, 'stalking', '0'
    UNION ALL SELECT 3909, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3909, 'creature_group_assist', '1'
    UNION ALL SELECT 3909, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3909, 'creature_meat_qty', '5'
    UNION ALL SELECT 3909, 'res_hide', 'Bristley Hide'
    UNION ALL SELECT 3909, 'creature_hide_qty', '3'
    UNION ALL SELECT 3909, 'res_bone', 'Mammal Bone'
    UNION ALL SELECT 3909, 'creature_bone_qty', '2'
    UNION ALL SELECT 3910, 'creature_health', '755'
    UNION ALL SELECT 3910, 'creature_strength', '755'
    UNION ALL SELECT 3910, 'creature_constitution', '755'
    UNION ALL SELECT 3910, 'creature_action', '755'
    UNION ALL SELECT 3910, 'creature_quickness', '755'
    UNION ALL SELECT 3910, 'creature_stamina', '755'
    UNION ALL SELECT 3910, 'creature_mind', '755'
    UNION ALL SELECT 3910, 'creature_focus', '755'
    UNION ALL SELECT 3910, 'creature_willpower', '755'
    UNION ALL SELECT 3910, 'creature_ham_min', '680'
    UNION ALL SELECT 3910, 'creature_ham_max', '830'
    UNION ALL SELECT 3910, 'creature_tohit', '27'
    UNION ALL SELECT 3910, 'creature_damage_min', '170'
    UNION ALL SELECT 3910, 'creature_damage_max', '180'
    UNION ALL SELECT 3910, 'creature_xp', '356'
    UNION ALL SELECT 3910, 'creature_social_group', 'Kliknik'
    UNION ALL SELECT 3910, 'killer', '0'
    UNION ALL SELECT 3910, 'Pack', '1'
    UNION ALL SELECT 3910, 'Herd', '0'
    UNION ALL SELECT 3910, 'stalking', '0'
    UNION ALL SELECT 3910, 'creature_is_aggressive', '1'
    UNION ALL SELECT 3910, 'creature_group_assist', '1'
    UNION ALL SELECT 3910, 'res_meat', 'Carnivore Meat'
    UNION ALL SELECT 3910, 'creature_meat_qty', '5'
    UNION ALL SELECT 3910, 'res_hide', 'Scaley Hide'
    UNION ALL SELECT 3910, 'creature_hide_qty', '4'
    UNION ALL SELECT 3910, 'creature_bone_qty', '0'
    UNION ALL SELECT 3911, 'creature_health', '755'
    UNION ALL SELECT 3911, 'creature_strength', '755'
    UNION ALL SELECT 3911, 'creature_constitution', '755'
    UNION ALL SELECT 3911, 'creature_action', '755'
    UNION ALL SELECT 3911, 'creature_quickness', '755'
    UNION ALL SELECT 3911, 'creature_stamina', '755'
    UNION ALL SELECT 3911, 'creature_mind', '755'
    UNION ALL SELECT 3911, 'creature_focus', '755'
    UNION ALL SELECT 3911, 'creature_willpower', '755'
    UNION ALL SELECT 3911, 'creature_ham_min', '680'
    UNION ALL SELECT 3911, 'creature_ham_max', '830'
    UNION ALL SELECT 3911, 'creature_tohit', '27'
    UNION ALL SELECT 3911, 'creature_damage_min', '80'
    UNION ALL SELECT 3911, 'creature_damage_max', '90'
    UNION ALL SELECT 3911, 'creature_xp', '292'
    UNION ALL SELECT 3911, 'creature_social_group', 'Tancmite'
    UNION ALL SELECT 3911, 'killer', '0'
    UNION ALL SELECT 3911, 'Pack', '1'
    UNION ALL SELECT 3911, 'Herd', '1'
    UNION ALL SELECT 3911, 'stalking', '0'
    UNION ALL SELECT 3911, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3911, 'creature_group_assist', '1'
    UNION ALL SELECT 3911, 'res_meat', 'Insect Meat'
    UNION ALL SELECT 3911, 'creature_meat_qty', '4'
    UNION ALL SELECT 3911, 'creature_hide_qty', '0'
    UNION ALL SELECT 3911, 'creature_bone_qty', '0'
    UNION ALL SELECT 3912, 'creature_health', '300'
    UNION ALL SELECT 3912, 'creature_strength', '300'
    UNION ALL SELECT 3912, 'creature_constitution', '300'
    UNION ALL SELECT 3912, 'creature_action', '300'
    UNION ALL SELECT 3912, 'creature_quickness', '300'
    UNION ALL SELECT 3912, 'creature_stamina', '300'
    UNION ALL SELECT 3912, 'creature_mind', '300'
    UNION ALL SELECT 3912, 'creature_focus', '300'
    UNION ALL SELECT 3912, 'creature_willpower', '300'
    UNION ALL SELECT 3912, 'creature_ham_min', '270'
    UNION ALL SELECT 3912, 'creature_ham_max', '330'
    UNION ALL SELECT 3912, 'creature_tohit', '26'
    UNION ALL SELECT 3912, 'creature_damage_min', '55'
    UNION ALL SELECT 3912, 'creature_damage_max', '65'
    UNION ALL SELECT 3912, 'creature_xp', '187'
    UNION ALL SELECT 3912, 'creature_social_group', 'Whisperbird'
    UNION ALL SELECT 3912, 'killer', '0'
    UNION ALL SELECT 3912, 'Pack', '1'
    UNION ALL SELECT 3912, 'Herd', '1'
    UNION ALL SELECT 3912, 'stalking', '0'
    UNION ALL SELECT 3912, 'creature_is_aggressive', '0'
    UNION ALL SELECT 3912, 'creature_group_assist', '1'
    UNION ALL SELECT 3912, 'res_meat', 'Avian Meat'
    UNION ALL SELECT 3912, 'creature_meat_qty', '55'
    UNION ALL SELECT 3912, 'creature_hide_qty', '0'
    UNION ALL SELECT 3912, 'res_bone', 'Avian Bone'
    UNION ALL SELECT 3912, 'creature_bone_qty', '30'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (1001, 'object/tangible/lair/angler/shared_lair_angler.iff', 'angler_hatchling', 'lair_n', '', ''),
  (1002, 'object/tangible/lair/choku/shared_lair_choku.iff', 'choku_pup', 'lair_n', '', ''),
  (1003, 'object/tangible/lair/gackle_bat/shared_lair_gackle_bat.iff', 'gackle_bat', 'lair_n', '', ''),
  (1004, 'object/tangible/lair/base/shared_poi_all_lair_warren_large.iff', 'mamien_youth', 'lair_n', '', ''),
  (1005, 'object/tangible/lair/gackle_bat/shared_lair_gackle_bat.iff', 'puny_gackle_bat', 'lair_n', '', ''),
  (1006, 'object/tangible/lair/stintaril/shared_lair_stintaril.iff', 'puny_stintaril', 'lair_n', '', ''),
  (1007, 'object/tangible/lair/tanc_mite/shared_lair_tanc_mite.iff', 'puny_tanc_mite', 'lair_n', '', ''),
  (1008, 'object/tangible/lair/skreeg/shared_lair_skreeg.iff', 'skreeg_infant', 'lair_n', '', ''),
  (1009, 'object/tangible/lair/base/shared_poi_all_lair_warren_large.iff', 'stintaril_scavenger', 'lair_n', '', ''),
  (1010, 'object/tangible/lair/kliknik/shared_lair_kliknik.iff', 'kliknik_swarming', 'lair_n', '', ''),
  (1011, 'object/tangible/lair/tanc_mite/shared_lair_tanc_mite.iff', 'tanc_mite', 'lair_n', '', ''),
  (1012, 'object/tangible/lair/base/shared_poi_all_lair_nest_small.iff', 'whisper_bird_hatchling', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (1001, 1001, 3901),
  (1002, 1002, 3902),
  (1003, 1003, 3903),
  (1004, 1004, 3904),
  (1005, 1005, 3905),
  (1006, 1006, 3906),
  (1007, 1007, 3907),
  (1008, 1008, 3908),
  (1009, 1009, 3909),
  (1010, 1010, 3910),
  (1011, 1011, 3911),
  (1012, 1012, 3912);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (1001, 810, 9, 1, 1001, 1001, 6, 0, 0, 0, 1, 0),
  (1002, 810, 9, 1, 1002, 1002, 6, 0, 0, 0, 1, 0),
  (1003, 810, 9, 1, 1003, 1003, 6, 0, 0, 0, 1, 0),
  (1004, 810, 9, 1, 1004, 1004, 6, 0, 0, 0, 1, 0),
  (1005, 810, 9, 1, 1005, 1005, 6, 0, 0, 0, 1, 0),
  (1006, 810, 9, 1, 1006, 1006, 6, 0, 0, 0, 1, 0),
  (1007, 810, 9, 1, 1007, 1007, 6, 0, 0, 0, 1, 0),
  (1008, 810, 9, 1, 1008, 1008, 6, 0, 0, 0, 1, 0),
  (1009, 810, 9, 1, 1009, 1009, 6, 0, 0, 0, 1, 0),
  (1010, 810, 9, 1, 1010, 1010, 6, 0, 0, 0, 1, 0),
  (1011, 810, 9, 1, 1011, 1011, 6, 0, 0, 0, 1, 0),
  (1012, 810, 9, 1, 1012, 1012, 6, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 10001 AS id, 1001 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 10002, 1001, 'lair_wave_size', '5'
    UNION ALL SELECT 10003, 1001, 'lair_passive_waves', '3'
    UNION ALL SELECT 10004, 1001, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10005, 1001, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10006, 1001, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10007, 1001, 'creature_xp', '235'
    UNION ALL SELECT 10008, 1001, 'creature_health', '4000'
    UNION ALL SELECT 10009, 1001, 'creature_strength', '4000'
    UNION ALL SELECT 10010, 1001, 'creature_constitution', '4000'
    UNION ALL SELECT 10011, 1001, 'lair_min_city_distance', '600'
    UNION ALL SELECT 10012, 1001, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 10013, 1002, 'lair_fix_position', '0'
    UNION ALL SELECT 10014, 1002, 'lair_wave_size', '5'
    UNION ALL SELECT 10015, 1002, 'lair_passive_waves', '3'
    UNION ALL SELECT 10016, 1002, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10017, 1002, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10018, 1002, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10019, 1002, 'creature_xp', '235'
    UNION ALL SELECT 10020, 1002, 'creature_health', '4000'
    UNION ALL SELECT 10021, 1002, 'creature_strength', '4000'
    UNION ALL SELECT 10022, 1002, 'creature_constitution', '4000'
    UNION ALL SELECT 10023, 1002, 'lair_min_city_distance', '600'
    UNION ALL SELECT 10024, 1002, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 10025, 1003, 'lair_fix_position', '0'
    UNION ALL SELECT 10026, 1003, 'lair_wave_size', '5'
    UNION ALL SELECT 10027, 1003, 'lair_passive_waves', '3'
    UNION ALL SELECT 10028, 1003, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10029, 1003, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10030, 1003, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10031, 1003, 'creature_xp', '356'
    UNION ALL SELECT 10032, 1003, 'creature_health', '5000'
    UNION ALL SELECT 10033, 1003, 'creature_strength', '5000'
    UNION ALL SELECT 10034, 1003, 'creature_constitution', '5000'
    UNION ALL SELECT 10035, 1003, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10036, 1004, 'lair_fix_position', '0'
    UNION ALL SELECT 10037, 1004, 'lair_wave_size', '3'
    UNION ALL SELECT 10038, 1004, 'lair_passive_waves', '3'
    UNION ALL SELECT 10039, 1004, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10040, 1004, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10041, 1004, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10042, 1004, 'creature_xp', '235'
    UNION ALL SELECT 10043, 1004, 'creature_health', '4500'
    UNION ALL SELECT 10044, 1004, 'creature_strength', '4500'
    UNION ALL SELECT 10045, 1004, 'creature_constitution', '4500'
    UNION ALL SELECT 10046, 1004, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10047, 1005, 'lair_fix_position', '0'
    UNION ALL SELECT 10048, 1005, 'lair_wave_size', '5'
    UNION ALL SELECT 10049, 1005, 'lair_passive_waves', '3'
    UNION ALL SELECT 10050, 1005, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10051, 1005, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10052, 1005, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10053, 1005, 'creature_xp', '147'
    UNION ALL SELECT 10054, 1005, 'creature_health', '3000'
    UNION ALL SELECT 10055, 1005, 'creature_strength', '3000'
    UNION ALL SELECT 10056, 1005, 'creature_constitution', '3000'
    UNION ALL SELECT 10057, 1005, 'lair_min_city_distance', '600'
    UNION ALL SELECT 10058, 1005, 'lair_max_city_distance', '1500'
    UNION ALL SELECT 10059, 1006, 'lair_fix_position', '0'
    UNION ALL SELECT 10060, 1006, 'lair_wave_size', '5'
    UNION ALL SELECT 10061, 1006, 'lair_passive_waves', '3'
    UNION ALL SELECT 10062, 1006, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10063, 1006, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10064, 1006, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10065, 1006, 'creature_xp', '292'
    UNION ALL SELECT 10066, 1006, 'creature_health', '4500'
    UNION ALL SELECT 10067, 1006, 'creature_strength', '4500'
    UNION ALL SELECT 10068, 1006, 'creature_constitution', '4500'
    UNION ALL SELECT 10069, 1006, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10070, 1007, 'lair_fix_position', '0'
    UNION ALL SELECT 10071, 1007, 'lair_wave_size', '5'
    UNION ALL SELECT 10072, 1007, 'lair_passive_waves', '3'
    UNION ALL SELECT 10073, 1007, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10074, 1007, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10075, 1007, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10076, 1007, 'creature_xp', '45'
    UNION ALL SELECT 10077, 1007, 'creature_health', '1000'
    UNION ALL SELECT 10078, 1007, 'creature_strength', '1000'
    UNION ALL SELECT 10079, 1007, 'creature_constitution', '1000'
    UNION ALL SELECT 10080, 1007, 'lair_min_city_distance', '50'
    UNION ALL SELECT 10081, 1007, 'lair_max_city_distance', '600'
    UNION ALL SELECT 10082, 1008, 'lair_fix_position', '0'
    UNION ALL SELECT 10083, 1008, 'lair_wave_size', '5'
    UNION ALL SELECT 10084, 1008, 'lair_passive_waves', '3'
    UNION ALL SELECT 10085, 1008, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10086, 1008, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10087, 1008, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10088, 1008, 'creature_xp', '85'
    UNION ALL SELECT 10089, 1008, 'creature_health', '2000'
    UNION ALL SELECT 10090, 1008, 'creature_strength', '2000'
    UNION ALL SELECT 10091, 1008, 'creature_constitution', '2000'
    UNION ALL SELECT 10092, 1008, 'lair_min_city_distance', '50'
    UNION ALL SELECT 10093, 1008, 'lair_max_city_distance', '600'
    UNION ALL SELECT 10094, 1009, 'lair_fix_position', '0'
    UNION ALL SELECT 10095, 1009, 'lair_wave_size', '5'
    UNION ALL SELECT 10096, 1009, 'lair_passive_waves', '3'
    UNION ALL SELECT 10097, 1009, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10098, 1009, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10099, 1009, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10100, 1009, 'creature_xp', '430'
    UNION ALL SELECT 10101, 1009, 'creature_health', '5500'
    UNION ALL SELECT 10102, 1009, 'creature_strength', '5500'
    UNION ALL SELECT 10103, 1009, 'creature_constitution', '5500'
    UNION ALL SELECT 10104, 1009, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10105, 1010, 'lair_fix_position', '0'
    UNION ALL SELECT 10106, 1010, 'lair_wave_size', '5'
    UNION ALL SELECT 10107, 1010, 'lair_passive_waves', '3'
    UNION ALL SELECT 10108, 1010, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10109, 1010, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10110, 1010, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10111, 1010, 'creature_xp', '356'
    UNION ALL SELECT 10112, 1010, 'creature_health', '5000'
    UNION ALL SELECT 10113, 1010, 'creature_strength', '5000'
    UNION ALL SELECT 10114, 1010, 'creature_constitution', '5000'
    UNION ALL SELECT 10115, 1010, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10116, 1011, 'lair_fix_position', '0'
    UNION ALL SELECT 10117, 1011, 'lair_wave_size', '5'
    UNION ALL SELECT 10118, 1011, 'lair_passive_waves', '3'
    UNION ALL SELECT 10119, 1011, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10120, 1011, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10121, 1011, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10122, 1011, 'creature_xp', '292'
    UNION ALL SELECT 10123, 1011, 'creature_health', '4500'
    UNION ALL SELECT 10124, 1011, 'creature_strength', '4500'
    UNION ALL SELECT 10125, 1011, 'creature_constitution', '4500'
    UNION ALL SELECT 10126, 1011, 'lair_min_city_distance', '1500'
    UNION ALL SELECT 10127, 1012, 'lair_fix_position', '0'
    UNION ALL SELECT 10128, 1012, 'lair_wave_size', '5'
    UNION ALL SELECT 10129, 1012, 'lair_passive_waves', '3'
    UNION ALL SELECT 10130, 1012, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 10131, 1012, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 10132, 1012, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 10133, 1012, 'creature_xp', '187'
    UNION ALL SELECT 10134, 1012, 'creature_health', '3500'
    UNION ALL SELECT 10135, 1012, 'creature_strength', '3500'
    UNION ALL SELECT 10136, 1012, 'creature_constitution', '3500'
    UNION ALL SELECT 10137, 1012, 'lair_min_city_distance', '600'
    UNION ALL SELECT 10138, 1012, 'lair_max_city_distance', '1500'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
