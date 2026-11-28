-- The portable Blue Frog (the CSR frog's "Personal Blue Frog") is an item of
-- the terminal family (ItemFamily_Terminal = 31, src/ZoneServer/Item_Enums.h;
-- made as an ItemTerminal), which item_families lacked: creating one failed
-- on fk_items_family. No crate: it is never crafted.

INSERT IGNORE INTO swganh.item_families (id, family_name, crate_size, crate_type)
  VALUES (31, 'terminal', 0, 0);
