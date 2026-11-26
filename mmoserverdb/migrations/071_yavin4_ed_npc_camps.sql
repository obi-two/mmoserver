-- Yavin4: An Empire Divided's NPC camps (docs/SPAWNS.md, roadmap step 3).
-- Written by tools/reference/npc_camps_sql.py --guide ed; edit that, not
-- this.
--
-- The planet's hostile, non-faction NPCs in An Empire Divided's tables
-- (pp. 480-480; mmoserverdb/reference/prima_ed/npcs.csv): those above level 11
-- and those the 2004 guide's table lacks. Each a template with the book's
-- stats, the client's model and name, and a weapon; each group in camps of
-- up to six kinds by level, 4 of each, placed at random on the planet in
-- the band of its strongest NPC's level, named after the group's camp in
-- the client's lair_n, each the client's camp building for the group where
-- the client has one, with an invisible lair (nothing to destroy).
--
-- Reconstructed, and data to tune: the book gives no weapons, so each NPC
-- carries one by group (Tusken rifles, Jawa ion rifles, stone knives for
-- the tribes, vibroblades for the Nightsisters and the Singing Mountain
-- clan) or by level (pistol below 15, carbine to 29, rifle above); models
-- for NPCs the client has no outfit of their own for (the group's);
-- splitting large groups by level; the camps. Camps call 4 at a time.
--
--   yavin4_hutt_expedition_force_camp_hutt_medium_theater up to lvl 16 2500 m+    Hutt expedition force surveyer (10, pistol_dh17), Hutt expedition force member (12, pistol_dh17), Hutt expedition force leader (16, carbine_dh17); pp. 480
--

SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)
  VALUES ('creature_ham_min', 1, 'Lowest health, action and mind a spawn rolls (guide HAM range)'),
         ('creature_ham_max', 1, 'Highest health, action and mind a spawn rolls (guide HAM range)'),
         ('creature_social_group', 1, 'Social group: pack creatures assist their own'),
         ('creature_meat_qty', 1, 'Meat a scout harvests'),
         ('creature_hide_qty', 1, 'Hide a scout harvests'),
         ('creature_bone_qty', 1, 'Bone a scout harvests'),
         ('creature_milk', 1, 'Milk: milk, wild, or empty'),
         ('creature_weapon', 1, 'An NPC\'s weapon: the client weapon template it holds'),
         ('creature_humanoid', 1, 'An NPC that attacks as a person with its weapon, not as a creature'),
         ('lair_invisible', 1, 'A lair not shown to players: a spawn point for its creatures'),
         ('lair_building', 1, 'A camp\'s building: the client building template put up at the lair');

INSERT IGNORE INTO swganh.non_persistent_npcs
  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)
  VALUES
  (11801, 8, 1, 1, 'object/mobile/shared_dressed_hutt_expedition_force_member.iff', 'hutt_expedition_force_surveyer', 'mob/creature_names', 10, 1, 0, 0, 0, 1),
  (11802, 8, 1, 1, 'object/mobile/shared_dressed_hutt_expedition_force_member.iff', 'hutt_expedition_force_member', 'mob/creature_names', 12, 1, 0, 0, 0, 1),
  (11803, 8, 1, 1, 'object/mobile/shared_dressed_hutt_expedition_force_leader.iff', 'hutt_expedition_force_leader', 'mob/creature_names', 16, 1, 0, 0, 0, 1);

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT v.npc_id, a.id, v.value, 0 FROM (
    SELECT 11801 AS npc_id, 'creature_health' AS name, '500' AS value
    UNION ALL SELECT 11801, 'creature_strength', '500'
    UNION ALL SELECT 11801, 'creature_constitution', '500'
    UNION ALL SELECT 11801, 'creature_action', '500'
    UNION ALL SELECT 11801, 'creature_quickness', '500'
    UNION ALL SELECT 11801, 'creature_stamina', '500'
    UNION ALL SELECT 11801, 'creature_mind', '500'
    UNION ALL SELECT 11801, 'creature_focus', '500'
    UNION ALL SELECT 11801, 'creature_willpower', '500'
    UNION ALL SELECT 11801, 'creature_ham_min', '375'
    UNION ALL SELECT 11801, 'creature_ham_max', '625'
    UNION ALL SELECT 11801, 'creature_tohit', '30'
    UNION ALL SELECT 11801, 'creature_damage_min', '40'
    UNION ALL SELECT 11801, 'creature_damage_max', '45'
    UNION ALL SELECT 11801, 'creature_xp', '413'
    UNION ALL SELECT 11801, 'creature_social_group', 'Hutt'
    UNION ALL SELECT 11801, 'killer', '1'
    UNION ALL SELECT 11801, 'Pack', '1'
    UNION ALL SELECT 11801, 'Herd', '0'
    UNION ALL SELECT 11801, 'stalking', '0'
    UNION ALL SELECT 11801, 'creature_is_aggressive', '1'
    UNION ALL SELECT 11801, 'creature_group_assist', '1'
    UNION ALL SELECT 11801, 'creature_humanoid', '1'
    UNION ALL SELECT 11801, 'tamable', '0'
    UNION ALL SELECT 11801, 'creature_weapon', 'object/weapon/ranged/pistol/shared_pistol_dh17.iff'
    UNION ALL SELECT 11801, 'creature_damage_max_range', '35'
    UNION ALL SELECT 11801, 'creature_is_roaming', '1'
    UNION ALL SELECT 11801, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 11801, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 11801, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 11802, 'creature_health', '700'
    UNION ALL SELECT 11802, 'creature_strength', '700'
    UNION ALL SELECT 11802, 'creature_constitution', '700'
    UNION ALL SELECT 11802, 'creature_action', '700'
    UNION ALL SELECT 11802, 'creature_quickness', '700'
    UNION ALL SELECT 11802, 'creature_stamina', '700'
    UNION ALL SELECT 11802, 'creature_mind', '700'
    UNION ALL SELECT 11802, 'creature_focus', '700'
    UNION ALL SELECT 11802, 'creature_willpower', '700'
    UNION ALL SELECT 11802, 'creature_ham_min', '525'
    UNION ALL SELECT 11802, 'creature_ham_max', '875'
    UNION ALL SELECT 11802, 'creature_tohit', '35'
    UNION ALL SELECT 11802, 'creature_damage_min', '50'
    UNION ALL SELECT 11802, 'creature_damage_max', '55'
    UNION ALL SELECT 11802, 'creature_xp', '747'
    UNION ALL SELECT 11802, 'creature_social_group', 'Hutt'
    UNION ALL SELECT 11802, 'killer', '1'
    UNION ALL SELECT 11802, 'Pack', '1'
    UNION ALL SELECT 11802, 'Herd', '0'
    UNION ALL SELECT 11802, 'stalking', '0'
    UNION ALL SELECT 11802, 'creature_is_aggressive', '1'
    UNION ALL SELECT 11802, 'creature_group_assist', '1'
    UNION ALL SELECT 11802, 'creature_humanoid', '1'
    UNION ALL SELECT 11802, 'tamable', '0'
    UNION ALL SELECT 11802, 'creature_weapon', 'object/weapon/ranged/pistol/shared_pistol_dh17.iff'
    UNION ALL SELECT 11802, 'creature_damage_max_range', '35'
    UNION ALL SELECT 11802, 'creature_is_roaming', '1'
    UNION ALL SELECT 11802, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 11802, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 11802, 'creature_roaming_max_distance', '30.0'
    UNION ALL SELECT 11803, 'creature_health', '1300'
    UNION ALL SELECT 11803, 'creature_strength', '1300'
    UNION ALL SELECT 11803, 'creature_constitution', '1300'
    UNION ALL SELECT 11803, 'creature_action', '1300'
    UNION ALL SELECT 11803, 'creature_quickness', '1300'
    UNION ALL SELECT 11803, 'creature_stamina', '1300'
    UNION ALL SELECT 11803, 'creature_mind', '1300'
    UNION ALL SELECT 11803, 'creature_focus', '1300'
    UNION ALL SELECT 11803, 'creature_willpower', '1300'
    UNION ALL SELECT 11803, 'creature_ham_min', '975'
    UNION ALL SELECT 11803, 'creature_ham_max', '1625'
    UNION ALL SELECT 11803, 'creature_tohit', '40'
    UNION ALL SELECT 11803, 'creature_damage_min', '70'
    UNION ALL SELECT 11803, 'creature_damage_max', '75'
    UNION ALL SELECT 11803, 'creature_xp', '1355'
    UNION ALL SELECT 11803, 'creature_social_group', 'Hutt'
    UNION ALL SELECT 11803, 'killer', '1'
    UNION ALL SELECT 11803, 'Pack', '1'
    UNION ALL SELECT 11803, 'Herd', '0'
    UNION ALL SELECT 11803, 'stalking', '0'
    UNION ALL SELECT 11803, 'creature_is_aggressive', '1'
    UNION ALL SELECT 11803, 'creature_group_assist', '1'
    UNION ALL SELECT 11803, 'creature_humanoid', '1'
    UNION ALL SELECT 11803, 'tamable', '0'
    UNION ALL SELECT 11803, 'creature_weapon', 'object/weapon/ranged/carbine/shared_carbine_dh17.iff'
    UNION ALL SELECT 11803, 'creature_damage_max_range', '50'
    UNION ALL SELECT 11803, 'creature_is_roaming', '1'
    UNION ALL SELECT 11803, 'creature_roaming_delay', '30000'
    UNION ALL SELECT 11803, 'creature_roaming_speed', '1.0'
    UNION ALL SELECT 11803, 'creature_roaming_max_distance', '30.0'
  ) v JOIN swganh.attributes a ON a.name = v.name;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES
  (5001, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'yavin4_hutt_expedition_force_camp_hutt_medium_theater', 'lair_n', '', '');

INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  VALUES
  (1, 5001, 11801),
  (2, 5001, 11802),
  (3, 5001, 11803);

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (5001, 810, 9, 1, 5001, 5001, 4, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 69001 AS id, 5001 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 69002, 5001, 'lair_wave_size', '4'
    UNION ALL SELECT 69003, 5001, 'lair_passive_waves', '3'
    UNION ALL SELECT 69004, 5001, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 69005, 5001, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 69006, 5001, 'lair_creatures_respawn_delay', '60000'
    UNION ALL SELECT 69007, 5001, 'creature_xp', '1355'
    UNION ALL SELECT 69008, 5001, 'creature_health', '8000'
    UNION ALL SELECT 69009, 5001, 'creature_strength', '8000'
    UNION ALL SELECT 69010, 5001, 'creature_constitution', '8000'
    UNION ALL SELECT 69011, 5001, 'lair_min_city_distance', '2500'
    UNION ALL SELECT 69012, 5001, 'lair_invisible', '1'
    UNION ALL SELECT 69013, 5001, 'lair_building', 'object/building/poi/shared_yavin4_hutt_scavenger_camp_medium1.iff'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
