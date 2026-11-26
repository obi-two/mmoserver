-- Creatures wander (docs/SPAWNS.md, roadmap step 3). AttackableCreature only
-- roams when its template has creature_is_roaming = 1, and of the 563
-- creature templates (family 8) only the six old womp rat and rill
-- templates had it: the lairs' creatures from migrations 027-048 stood
-- still. Every creature template without its own roaming settings now
-- roams: when a player is within 64 m it walks to a random spot within 15 m
-- every 30-45 s, at 1 m/s, staying within 30 m of where it spawned (the
-- lairs call their creatures within 30 m). Reconstructed values: data, to
-- tune. Templates that already have a setting keep it.

INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)
  SELECT n.id, a.id, v.value, 0
  FROM swganh.non_persistent_npcs n
  JOIN (SELECT 'creature_is_roaming' AS name, '1' AS value
        UNION ALL SELECT 'creature_roaming_delay', '30000'
        UNION ALL SELECT 'creature_roaming_speed', '1.0'
        UNION ALL SELECT 'creature_roaming_max_distance', '30.0') v
  JOIN swganh.attributes a ON a.name = v.name
  WHERE n.family = 8;
