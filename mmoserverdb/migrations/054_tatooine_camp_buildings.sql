-- Tatooine: the NPC camps' buildings (docs/SPAWNS.md, NPC camps). Migration 053
-- put each camp at a destroyable banner; pre-CU a wild camp was the
-- group's camp building with its NPCs and nothing to destroy (the swganh
-- wiki's "Lairs": wild lairs, invisible lairs; destroyable lairs for
-- missions), so each camp's lair is now invisible and puts up the client's
-- camp building for its group (object/building/poi/), sized as the
-- group's camp name in the client's lair_n. Camps whose client name ends
-- "_none" (the cannibal enclave, the kitonaks, the Jawa warband) had no
-- building and are spawn points only. Written by
-- tools/reference/npc_camps_sql.py --buildings tatooine.

SET FOREIGN_KEY_CHECKS = 0;

INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)
  VALUES ('lair_invisible', 1, 'A lair not shown to players: a spawn point for its creatures'),
         ('lair_building', 1, 'A camp\'s building: the client building template put up at the lair');

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
    SELECT 49001 AS id, 3101 AS lair_id, 'lair_invisible' AS name, '1' AS value
    UNION ALL SELECT 49002, 3102, 'lair_invisible', '1'
    UNION ALL SELECT 49003, 3102, 'lair_building', 'object/building/poi/shared_tatooine_dervishcamp_medium.iff'
    UNION ALL SELECT 49004, 3103, 'lair_invisible', '1'
    UNION ALL SELECT 49005, 3103, 'lair_building', 'object/building/poi/shared_tatooine_desert_demons_camp_large1.iff'
    UNION ALL SELECT 49006, 3104, 'lair_invisible', '1'
    UNION ALL SELECT 49007, 3104, 'lair_building', 'object/building/poi/shared_tatooine_swoop_medium.iff'
    UNION ALL SELECT 49008, 3105, 'lair_invisible', '1'
    UNION ALL SELECT 49009, 3105, 'lair_building', 'object/building/poi/shared_tatooine_dim_u_medium.iff'
    UNION ALL SELECT 49010, 3106, 'lair_invisible', '1'
    UNION ALL SELECT 49011, 3106, 'lair_building', 'object/building/poi/shared_tatooine_dunestalkers_medium.iff'
    UNION ALL SELECT 49012, 3107, 'lair_invisible', '1'
    UNION ALL SELECT 49013, 3107, 'lair_building', 'object/building/poi/shared_tatooine_evil_settlers_medium.iff'
    UNION ALL SELECT 49014, 3108, 'lair_invisible', '1'
    UNION ALL SELECT 49015, 3108, 'lair_building', 'object/building/poi/shared_tatooine_fugitive_camp_medium.iff'
    UNION ALL SELECT 49016, 3109, 'lair_invisible', '1'
    UNION ALL SELECT 49017, 3109, 'lair_building', 'object/building/poi/shared_tatooine_nomad_squatter_medium1.iff'
    UNION ALL SELECT 49018, 3110, 'lair_invisible', '1'
    UNION ALL SELECT 49019, 3110, 'lair_building', 'object/building/poi/shared_tatooine_swoop_medium2.iff'
    UNION ALL SELECT 49020, 3111, 'lair_invisible', '1'
    UNION ALL SELECT 49021, 3111, 'lair_building', 'object/building/poi/shared_tatooine_hutt_assassin_camp_medium1.iff'
    UNION ALL SELECT 49022, 3112, 'lair_invisible', '1'
    UNION ALL SELECT 49023, 3113, 'lair_invisible', '1'
    UNION ALL SELECT 49024, 3114, 'lair_invisible', '1'
    UNION ALL SELECT 49025, 3115, 'lair_invisible', '1'
    UNION ALL SELECT 49026, 3115, 'lair_building', 'object/building/poi/shared_tatooine_rodianhunter_large1.iff'
    UNION ALL SELECT 49027, 3116, 'lair_invisible', '1'
    UNION ALL SELECT 49028, 3116, 'lair_building', 'object/building/poi/shared_tatooine_slaver_medium.iff'
    UNION ALL SELECT 49029, 3117, 'lair_invisible', '1'
    UNION ALL SELECT 49030, 3117, 'lair_building', 'object/building/poi/shared_tatooine_valariangang_medium.iff'
    UNION ALL SELECT 49031, 3118, 'lair_invisible', '1'
    UNION ALL SELECT 49032, 3118, 'lair_building', 'object/building/poi/shared_tatooine_valariangang_medium.iff'
    UNION ALL SELECT 49033, 3119, 'lair_invisible', '1'
    UNION ALL SELECT 49034, 3119, 'lair_building', 'object/building/poi/shared_tatooine_weequayzealots_large1.iff'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
