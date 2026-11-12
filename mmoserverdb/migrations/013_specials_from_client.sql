-- Specials where the client's own command descriptions (Publish 14,
-- string/en/cmd_d.stf) contradict An Empire Divided's special moves table
-- (pp. 76-81, migrations 010 and 012). The client is the baseline
-- (docs/SOURCES.md); the guide's values stay in
-- mmoserverdb/reference/prima_ed/specials.csv as printed.
--
--   melee2hArea3      "can blind, and damage and lower the posture of
--                     multiple targets"; the table has dizzy. Blind with the
--                     table's dizzy chance and duration (30%, 30 s).
--   burstShot2        "This area ranged attack is more damaging than Burst
--                     Shot 1"; the table has a single target. An area of the
--                     weapon's range, like the other areas without a size.
--   pointBlankArea2   "This advanced ranged area attack can be performed at
--                     point blank range"; the table has a single target. The
--                     12 m of Point Blank Area 1.

UPDATE command_table SET blind_chance = dizzy_chance, blind_duration = dizzy_duration,
    dizzy_chance = 0, dizzy_duration = 0
  WHERE LOWER(commandname) = 'melee2harea3' AND dizzy_chance > 0;

UPDATE command_table SET area_shape = 'area', area_length = 0, area_width = 0
  WHERE LOWER(commandname) = 'burstshot2';

UPDATE command_table SET area_shape = 'area', area_length = 12, area_width = 0
  WHERE LOWER(commandname) = 'pointblankarea2';
