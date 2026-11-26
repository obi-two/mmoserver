-- Six lair creatures showed their name key, not their name, in a Publish 14
-- client (Corellia, Nov 2026: "mob/creature_names:[menagerie_murra]"). Their
-- keys were taken from a later client's mob/creature_names, which has
-- menagerie_* names the Publish 14 one lacks. They take the plain keys
-- (murra, mott, nuna, sand_panther, quenker, squill), as in
-- tools/reference/planet_lairs.csv.

UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'murra' WHERE stf_variable_id = 'menagerie_murra';
UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'mott' WHERE stf_variable_id = 'menagerie_mott';
UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'nuna' WHERE stf_variable_id = 'menagerie_nuna';
UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'sand_panther' WHERE stf_variable_id = 'menagerie_sand_panther';
UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'quenker' WHERE stf_variable_id = 'menagerie_quenker';
UPDATE swganh.non_persistent_npcs SET stf_variable_id = 'squill' WHERE stf_variable_id = 'menagerie_squill';
