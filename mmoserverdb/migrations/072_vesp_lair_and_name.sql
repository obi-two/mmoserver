-- Two Lok fixes from the VM (Nov 2026):
-- - The vesp lair (object/tangible/lair/vesp/shared_lair_vesp.iff) shows
--   the client's red "default appearance" box: the Publish 14 client has
--   the template but no model for it. The vesps' lairs take the generic
--   nest (base/shared_poi_all_lair_nest_large.iff, "a nest"), as creatures
--   without a lair of their own do.
-- - The mountain vesp (044) had the name key mission_mountain_villager, a
--   wrong match: it takes the vesp's ("a vesp").

UPDATE swganh.lair_templates
   SET lair_object_string = 'object/tangible/lair/base/shared_poi_all_lair_nest_large.iff', stf_name = 'nest'
 WHERE lair_object_string = 'object/tangible/lair/vesp/shared_lair_vesp.iff';

UPDATE swganh.non_persistent_npcs
   SET stf_variable_id = 'vesp'
 WHERE stf_variable_id = 'mission_mountain_villager' AND type = 'object/mobile/shared_vesp.iff';
