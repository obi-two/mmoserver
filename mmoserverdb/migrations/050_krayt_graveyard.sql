-- Krayt dragons only at the Krayt Graveyard, and the base data's
-- hand-placed animals removed (docs/SPAWNS.md, roadmap step 3).
--
-- 1. The base data's persistent_npcs had 15 wild animals placed by hand
--    (desert razorbacks and giant sand beetles on Tatooine, fanned rawls on
--    Lok, a fearful fynock youth on Rori, a gubbur on Corellia) as family 2,
--    conversing NPCs: players could talk to them but not attack them, and
--    they never moved. The lairs (027-048) now place these creatures.
--
-- 2. Migration 039 placed 2 lairs each of the three krayts (juvenile canyon
--    krayt, canyon krayt dragon, giant canyon krayt dragon) at random 4,500 m
--    or more from a city. Krayts were rare, so they now live only at the
--    Krayt Graveyard: the client's POI list puts it at (6839, 4320), and its
--    two no-build circles at (6839, 4320) and (7462, 4480). A random lair
--    cannot be placed inside a no-build area, so these lairs have fixed
--    positions in the graveyard (the zone takes the ground height from the
--    heightmap): 2 juvenile canyon krayt lairs, 1 canyon krayt dragon lair
--    and 1 giant canyon krayt dragon lair, each calling one krayt at a time,
--    a killed krayt back after 10 minutes and a destroyed lair after 30. The
--    positions, counts and times are reconstructed: data, to tune.

DELETE FROM swganh.persistent_npcs
  WHERE family = 2 AND id IN (
    47513078507, 47513078509,                 -- Tatooine: desert razorbacks
    47513078525, 47513078527,                 -- Tatooine: giant sand beetles
    47513080017,                              -- Rori: fearful fynock youth
    47513081755, 47513081757, 47513082037,    -- Lok: fanned rawls
    47513082099, 47513082101, 47513082109,
    47513082187, 47513082829, 47513082831,
    47513085391);                             -- Corellia: gubbur

-- The random krayt lairs from 039: none.
UPDATE swganh.lairs SET count = 0 WHERE id IN (2104, 2111, 2116);

-- creature_groups.creature_id has a foreign key to a `creatures` table that
-- does not exist; lairs rows are added with the checks off (as in 027-048).
SET FOREIGN_KEY_CHECKS = 0;

-- The graveyard lairs, on the same templates and creature groups as 039's
-- (2116 juvenile canyon krayt, 2104 canyon krayt dragon, 2111 giant canyon
-- krayt dragon), in Tatooine's spawn area 801.
INSERT IGNORE INTO swganh.lairs
  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)
  VALUES
  (2191, 801, 9, 1, 2116, 2116, 1, 6700, 0, 4230, 0, 1),
  (2192, 801, 9, 1, 2116, 2116, 1, 6960, 0, 4440, 0, 1),
  (2193, 801, 9, 1, 2104, 2104, 1, 7250, 0, 4330, 0, 1),
  (2194, 801, 9, 1, 2111, 2111, 1, 7540, 0, 4620, 0, 1);

INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)
  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (
              SELECT 20901 AS id, 2191 AS lair_id, 'lair_fix_position' AS name, '1' AS value
    UNION ALL SELECT 20902, 2191, 'lair_wave_size', '1'
    UNION ALL SELECT 20903, 2191, 'lair_passive_waves', '1'
    UNION ALL SELECT 20904, 2191, 'lair_respawn_delay', '1800000'
    UNION ALL SELECT 20905, 2191, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 20906, 2191, 'lair_creatures_respawn_delay', '600000'
    UNION ALL SELECT 20907, 2191, 'creature_xp', '43972'
    UNION ALL SELECT 20908, 2191, 'creature_health', '50000'
    UNION ALL SELECT 20909, 2191, 'creature_strength', '50000'
    UNION ALL SELECT 20910, 2191, 'creature_constitution', '50000'
    UNION ALL SELECT 20911, 2192, 'lair_fix_position', '1'
    UNION ALL SELECT 20912, 2192, 'lair_wave_size', '1'
    UNION ALL SELECT 20913, 2192, 'lair_passive_waves', '1'
    UNION ALL SELECT 20914, 2192, 'lair_respawn_delay', '1800000'
    UNION ALL SELECT 20915, 2192, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 20916, 2192, 'lair_creatures_respawn_delay', '600000'
    UNION ALL SELECT 20917, 2192, 'creature_xp', '43972'
    UNION ALL SELECT 20918, 2192, 'creature_health', '50000'
    UNION ALL SELECT 20919, 2192, 'creature_strength', '50000'
    UNION ALL SELECT 20920, 2192, 'creature_constitution', '50000'
    UNION ALL SELECT 20921, 2193, 'lair_fix_position', '1'
    UNION ALL SELECT 20922, 2193, 'lair_wave_size', '1'
    UNION ALL SELECT 20923, 2193, 'lair_passive_waves', '1'
    UNION ALL SELECT 20924, 2193, 'lair_respawn_delay', '1800000'
    UNION ALL SELECT 20925, 2193, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 20926, 2193, 'lair_creatures_respawn_delay', '600000'
    UNION ALL SELECT 20927, 2193, 'creature_xp', '192335'
    UNION ALL SELECT 20928, 2193, 'creature_health', '50000'
    UNION ALL SELECT 20929, 2193, 'creature_strength', '50000'
    UNION ALL SELECT 20930, 2193, 'creature_constitution', '50000'
    UNION ALL SELECT 20931, 2194, 'lair_fix_position', '1'
    UNION ALL SELECT 20932, 2194, 'lair_wave_size', '1'
    UNION ALL SELECT 20933, 2194, 'lair_passive_waves', '1'
    UNION ALL SELECT 20934, 2194, 'lair_respawn_delay', '1800000'
    UNION ALL SELECT 20935, 2194, 'lair_creatures_max_spawn_distance', '30'
    UNION ALL SELECT 20936, 2194, 'lair_creatures_respawn_delay', '600000'
    UNION ALL SELECT 20937, 2194, 'creature_xp', '224144'
    UNION ALL SELECT 20938, 2194, 'creature_health', '50000'
    UNION ALL SELECT 20939, 2194, 'creature_strength', '50000'
    UNION ALL SELECT 20940, 2194, 'creature_constitution', '50000'
  ) v JOIN swganh.attributes a ON a.name = v.name;

SET FOREIGN_KEY_CHECKS = 1;
