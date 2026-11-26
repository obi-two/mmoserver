-- Lair_First_Spawn_Max_Minutes (docs/SPAWNS.md): after a zone starts, each
-- lair's first spawn waits one to two times its respawn delay, with the
-- base at most this many minutes. 5 (the default) brings every lair up
-- within 10 minutes of a start, spread out; 0 spawns them all straight
-- away, for a test server. A server setting for every zone ('all'); a
-- zone's own row overrides it.

-- The tables' ids are not numbered by the database: take the next free one,
-- and find the setting by name.
INSERT INTO swganh.config_server_attributes (id, attribute, attribute_description)
  SELECT m.next_id, 'Lair_First_Spawn_Max_Minutes',
         'Lairs - longest base wait for a lair''s first spawn after a zone start, in minutes (0: at once)'
  FROM (SELECT COALESCE(MAX(id), 0) + 1 AS next_id FROM swganh.config_server_attributes) m
  WHERE NOT EXISTS (SELECT 1 FROM swganh.config_server_attributes WHERE attribute = 'Lair_First_Spawn_Max_Minutes');

INSERT INTO swganh.config_server (id, server_name, config_attributes_id, value)
  SELECT (SELECT COALESCE(MAX(id), 0) + 1 FROM swganh.config_server), 'all', csa.id, '5'
  FROM swganh.config_server_attributes csa
  WHERE csa.attribute = 'Lair_First_Spawn_Max_Minutes'
    AND NOT EXISTS (SELECT 1 FROM swganh.config_server cs WHERE cs.server_name = 'all' AND cs.config_attributes_id = csa.id);
