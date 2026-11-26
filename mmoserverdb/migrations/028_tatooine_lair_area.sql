-- Tatooine's lair area (migration 027) reached past the map's edge (the
-- map covers -7680 to 7680 m), and a lair placed there crashed the zone
-- reading the height cache outside its bounds (docs/SPAWNS.md). Kept inside
-- the map, with a margin. The height lookup is also bounded now.
UPDATE swganh.spawns SET spawn_x = -7600, spawn_z = -7600, spawn_width = 15200, spawn_length = 15200
  WHERE id = 801;
