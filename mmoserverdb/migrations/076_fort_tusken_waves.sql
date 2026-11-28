-- Fort Tusken in waves (docs/SPAWNS.md). The Publish 1 notes (13 August
-- 2003, wiki.swganh.org/index.php/Publish_1_Notes:_13_August_03): "Set up
-- Fort Tusken to spawn in waves"; the wiki's carnage champion page: "three
-- waves of progressively more difficult NPCs before starting over"; its
-- elite guard page: the bunker's last room held "five of these NPCs along
-- with the Tusken King". Written by tools/reference/fort_tusken_sql.py
-- --waves; edit that, not this.
--
-- Replaces 075's four fort lairs (6101-6104) with 3 wave lairs (6111),
-- each calling waves of 6:
--   wave 1: commoners (wiki), raiders, snipers (book)
--   wave 2: captains, chiefs (wiki), warlords (book)
--   wave 3: the Tusken King (book) and five elite guards (wiki)
-- A wave follows 30 s after the last one is down; after the third, the
-- first comes back after 5 minutes. Reconstructed, and data to tune: the
-- waves' members and size, the delays, the number of lairs. The bantha is
-- left out of the fort (a lair holds 8 kinds; the village has them).
--

SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)
  VALUES ('lair_wave_stages', 1, 'A lair in waves: how many of its kinds (in group order) each wave calls from, e.g. 3,3,2'),
         ('lair_wave_boss', 1, 'A lair in waves: its last kind leads the last wave, one of it'),
         ('lair_wave_delay', 1, 'A lair in waves: ms from a wave''s end to the next');

-- Migration 075's fort lairs.
DELETE FROM swganh.lair_attributes WHERE lair_id IN (6101, 6102, 6103, 6104);
DELETE FROM swganh.creature_groups WHERE creature_group_id IN (6101, 6102, 6103, 6104);
DELETE FROM swganh.lairs WHERE id IN (6101, 6102, 6103, 6104);
DELETE FROM swganh.lair_templates WHERE id IN (6101, 6102, 6103, 6104);

INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)
  VALUES (6111, 'object/tangible/lair/base/shared_objective_banner_generic_1.iff', 'global_outlaw_neutral_none', 'lair_n', '', '');

-- In wave order: the lair reads its kinds by row id.
INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)
  SELECT 1101, 6111, 12001
  UNION ALL SELECT 1102, 6111, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_raider')
  UNION ALL SELECT 1103, 6111, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_sniper')
  UNION ALL SELECT 1104, 6111, 12002
  UNION ALL SELECT 1105, 6111, 12003
  UNION ALL SELECT 1106, 6111, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_warlord')
  UNION ALL SELECT 1107, 6111, 12004
  UNION ALL SELECT 1108, 6111, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8 AND id >= 3001 AND id < 12001 AND stf_variable_id = 'tusken_king');

INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES (6111, 901, 9, 1, 6111, 6111, 3, 0, 0, 0, 1, 0);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 81101 AS id, 6111 AS lair_id, 'lair_fix_position' AS name, '0' AS value
    UNION ALL SELECT 81102, 6111, 'lair_at_poi', '1'
    UNION ALL SELECT 81103, 6111, 'lair_invisible', '1'
    UNION ALL SELECT 81104, 6111, 'lair_wave_size', '6'
    UNION ALL SELECT 81105, 6111, 'lair_passive_waves', '3'
    UNION ALL SELECT 81106, 6111, 'lair_wave_stages', '3,3,2'
    UNION ALL SELECT 81107, 6111, 'lair_wave_boss', '1'
    UNION ALL SELECT 81108, 6111, 'lair_wave_delay', '30000'
    UNION ALL SELECT 81109, 6111, 'lair_respawn_delay', '300000'
    UNION ALL SELECT 81110, 6111, 'lair_creatures_max_spawn_distance', '25'
    UNION ALL SELECT 81111, 6111, 'lair_creatures_respawn_delay', '3000'
    UNION ALL SELECT 81112, 6111, 'creature_xp', '0'
    UNION ALL SELECT 81113, 6111, 'creature_health', '1000'
    UNION ALL SELECT 81114, 6111, 'creature_strength', '1000'
    UNION ALL SELECT 81115, 6111, 'creature_constitution', '1000'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
