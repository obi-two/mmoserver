-- CSR switches kept per character (the CSR frog, docs/SPAWNS.md): with
-- npcs_ignore set, creatures and NPCs do not notice or attack the character
-- first, nor join a fight against it; a creature it attacks still fights
-- back. A new table: the characters and account tables are unchanged.

CREATE TABLE IF NOT EXISTS swganh.character_csr_flags (
  character_id bigint(20) unsigned NOT NULL,
  npcs_ignore tinyint(3) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
