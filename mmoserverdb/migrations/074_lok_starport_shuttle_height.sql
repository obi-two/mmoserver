-- The Nym's Stronghold starport transport on Lok landed on the ground
-- under the outpost starport's deck instead of on it (VM, Nov 2026).
-- Every other transport at an outpost starport
-- (object/building/military/shared_outpost_starport.iff) sits 7.09 m
-- above its building's base: Dantooine 3 -> 10.09, Endor 73 -> 80.09,
-- Rori 96 -> 103.09 and so on. Lok's was 16.9 over a base of 9 (7.90),
-- a likely typo of 16.09. Matched to the others' offset; the position
-- and facing already match the building.

UPDATE swganh.shuttles
   SET y = 16.09
 WHERE id = 47781511192 AND planet_id = 4 AND ABS(y - 16.9) < 0.01;
