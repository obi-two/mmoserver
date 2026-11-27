-- Fort Tusken's waves at fixed spots (docs/SPAWNS.md). 076's three wave
-- lairs were placed at random in the fort's area, and the server has no
-- wall shapes: Tuskens stood inside the walls. Four spots clear of them,
-- found in game (November 2026), each a wave lair; their Tuskens appear
-- within a few metres of it:
--   courtyard                 -3980,  6253  within 6 m, the King's wave
--   gate                      -3982,  6292  within 3 m
--   back left, by the cave    -3962,  6232  within 4 m
--   opposite corner           -4009,  6235  within 4 m
-- Each calls 076's waves of six; only the courtyard's third wave has the
-- King, the others' are elite guards (one King in the fort, not four).
-- The catwalks wait: the server puts creatures on the terrain, under them.
-- Written by tools/reference/fort_tusken_sql.py --spots; edit that, not this.
--

SET FOREIGN_KEY_CHECKS = 0;

-- Migration 076's wave lair.
DELETE FROM swganh.lair_attributes WHERE lair_id = 6111;
DELETE FROM swganh.creature_groups WHERE creature_group_id = 6111;
DELETE FROM swganh.lairs WHERE id = 6111;
DELETE FROM swganh.lair_templates WHERE id = 6111;

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES (6121, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
         (6122, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
         (6123, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', ''),
         (6124, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', '');

-- In wave order: the lair reads its kinds by row id. 6121 with the King, 6122 without.
INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  SELECT 1201, 6121, 12001
  UNION ALL SELECT 1202, 6121, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_raider')
  UNION ALL SELECT 1203, 6121, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_sniper')
  UNION ALL SELECT 1204, 6121, 12002
  UNION ALL SELECT 1205, 6121, 12003
  UNION ALL SELECT 1206, 6121, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_warlord')
  UNION ALL SELECT 1207, 6121, 12004
  UNION ALL SELECT 1208, 6121, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_king')
  UNION ALL SELECT 1209, 6122, 12001
  UNION ALL SELECT 1210, 6122, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_raider')
  UNION ALL SELECT 1211, 6122, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_sniper')
  UNION ALL SELECT 1212, 6122, 12002
  UNION ALL SELECT 1213, 6122, 12003
  UNION ALL SELECT 1214, 6122, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_warlord')
  UNION ALL SELECT 1215, 6122, 12004;

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (6121, 901, 9, 1, 6121, 6121, 1, -3980, 0, 6253, 1, 0),
  (6122, 901, 9, 1, 6122, 6122, 1, -3982, 0, 6292, 1, 0),
  (6123, 901, 9, 1, 6123, 6122, 1, -3962, 0, 6232, 1, 0),
  (6124, 901, 9, 1, 6124, 6122, 1, -4009, 0, 6235, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 81201 AS id, 6121 AS lair_id, 'lair_fix_position' AS name, '1' AS value
    UNION ALL SELECT 81202, 6121, 'lair_invisible', '1'
    UNION ALL SELECT 81203, 6121, 'lair_wave_size', '6'
    UNION ALL SELECT 81204, 6121, 'lair_passive_waves', '3'
    UNION ALL SELECT 81205, 6121, 'lair_wave_stages', '3,3,2'
    UNION ALL SELECT 81206, 6121, 'lair_wave_boss', '1'
    UNION ALL SELECT 81207, 6121, 'lair_wave_delay', '30000'
    UNION ALL SELECT 81208, 6121, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81209, 6121, 'lair_creatures_max_spawn_distance', '6'
    UNION ALL SELECT 81210, 6121, 'lair_creatures_respawn_delay', '3000'
    UNION ALL SELECT 81211, 6121, 'creature_xp', '0'
    UNION ALL SELECT 81212, 6121, 'creature_health', '1000'
    UNION ALL SELECT 81213, 6121, 'creature_strength', '1000'
    UNION ALL SELECT 81214, 6121, 'creature_constitution', '1000'
    UNION ALL SELECT 81215, 6122, 'lair_fix_position', '1'
    UNION ALL SELECT 81216, 6122, 'lair_invisible', '1'
    UNION ALL SELECT 81217, 6122, 'lair_wave_size', '6'
    UNION ALL SELECT 81218, 6122, 'lair_passive_waves', '3'
    UNION ALL SELECT 81219, 6122, 'lair_wave_stages', '3,3,1'
    UNION ALL SELECT 81220, 6122, 'lair_wave_boss', '0'
    UNION ALL SELECT 81221, 6122, 'lair_wave_delay', '30000'
    UNION ALL SELECT 81222, 6122, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81223, 6122, 'lair_creatures_max_spawn_distance', '3'
    UNION ALL SELECT 81224, 6122, 'lair_creatures_respawn_delay', '3000'
    UNION ALL SELECT 81225, 6122, 'creature_xp', '0'
    UNION ALL SELECT 81226, 6122, 'creature_health', '1000'
    UNION ALL SELECT 81227, 6122, 'creature_strength', '1000'
    UNION ALL SELECT 81228, 6122, 'creature_constitution', '1000'
    UNION ALL SELECT 81229, 6123, 'lair_fix_position', '1'
    UNION ALL SELECT 81230, 6123, 'lair_invisible', '1'
    UNION ALL SELECT 81231, 6123, 'lair_wave_size', '6'
    UNION ALL SELECT 81232, 6123, 'lair_passive_waves', '3'
    UNION ALL SELECT 81233, 6123, 'lair_wave_stages', '3,3,1'
    UNION ALL SELECT 81234, 6123, 'lair_wave_boss', '0'
    UNION ALL SELECT 81235, 6123, 'lair_wave_delay', '30000'
    UNION ALL SELECT 81236, 6123, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81237, 6123, 'lair_creatures_max_spawn_distance', '4'
    UNION ALL SELECT 81238, 6123, 'lair_creatures_respawn_delay', '3000'
    UNION ALL SELECT 81239, 6123, 'creature_xp', '0'
    UNION ALL SELECT 81240, 6123, 'creature_health', '1000'
    UNION ALL SELECT 81241, 6123, 'creature_strength', '1000'
    UNION ALL SELECT 81242, 6123, 'creature_constitution', '1000'
    UNION ALL SELECT 81243, 6124, 'lair_fix_position', '1'
    UNION ALL SELECT 81244, 6124, 'lair_invisible', '1'
    UNION ALL SELECT 81245, 6124, 'lair_wave_size', '6'
    UNION ALL SELECT 81246, 6124, 'lair_passive_waves', '3'
    UNION ALL SELECT 81247, 6124, 'lair_wave_stages', '3,3,1'
    UNION ALL SELECT 81248, 6124, 'lair_wave_boss', '0'
    UNION ALL SELECT 81249, 6124, 'lair_wave_delay', '30000'
    UNION ALL SELECT 81250, 6124, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81251, 6124, 'lair_creatures_max_spawn_distance', '4'
    UNION ALL SELECT 81252, 6124, 'lair_creatures_respawn_delay', '3000'
    UNION ALL SELECT 81253, 6124, 'creature_xp', '0'
    UNION ALL SELECT 81254, 6124, 'creature_health', '1000'
    UNION ALL SELECT 81255, 6124, 'creature_strength', '1000'
    UNION ALL SELECT 81256, 6124, 'creature_constitution', '1000'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
