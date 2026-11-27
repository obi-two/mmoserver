# Reference data: An Empire Divided

Facts from Prima's Official Strategy Guide, *Star Wars Galaxies: An Empire
Divided* (2003, the launch guide; `docs/SOURCES.md`), appendix, transcribed
from the page images; `page` is the printed page (PDF page = page + 3).
Reference data: migrations take their values from here and cite the page.

- `weapons.csv` (pp. 390, 392; Mind cost pp. 391, 393): looted/vendor
  weapons. `zero_range_mod`, `mid_range_mod`, `max_range_mod`: accuracy
  modifiers at point blank, at `mid_range` (the ideal range) and at
  `max_range`, in metres. `attack_speed`: seconds between attacks.
  Health/action/mind costs: multiplied by a special move's modifiers;
  default attacks cost nothing (p. 389). Damage/minute = 60 / speed x
  average damage (p. 389).
- `armor.csv` (p. 394): generic effectiveness (% of damage absorbed) and
  per damage type: a number replaces the generic value, `0` means no
  protection against that type, `+` means the generic value (p. 395).

- `specials.csv` (pp. 76-83, each row across a page pair): the special
  moves table, 134 moves. `time_mod`, `damage_mod` and the costs multiply
  the weapon's attack speed, damage and HAM costs; `to_hit_mod` adds to
  the accuracy; the end postures and effects (with one chance for all of a
  move's effects, durations in seconds) apply on a hit. `area_length`
  "weapon" means the weapon's range. ActionShot2's name is missing from the
  page; it follows ActionShot1 with the same description. Polearm Sweep2's
  to-hit is printed 15 where the other polearm moves have 10; kept as
  printed.

- `creatures.csv` (creature tables, pp. 396-483, each row across a page
  pair: `page` the names and stats, `facing` the to-hit, XP and flags):
  every wild creature above level 11 in the planets' sections (the 2004
  guide's table, `../prima_2004/`, covers levels 1-11), with the planet of
  the section it is printed in (`planet`). Not the NPCs (humanoids, tribes,
  townspeople, named characters), nor the section "not bound to a
  particular planet". HAM is per pool here, one range for the three in
  2004; the guide prints the same range for all three. `invulnerable`
  and the specials as printed (one bantha, p. 472, is marked
  invulnerable).

  Read from the page images (Nov 2026): three OCR readings of each row
  (the PDF's text layer, tesseract on the page, tesseract on each column)
  merged, then every row checked against the page image by eye and
  corrected; social groups normalised where the scan garbled them. The two
  womp rats transcribed earlier by hand came out the same.

- `npcs.csv`: the hostile, non-faction NPCs of the same tables (pp.
  396-483), 432 rows on ten planets: every one above level 11, and the
  ones the 2004 guide's table lacks at any level (Tusken Raiders, Alkhara,
  Nym's men and the Lok pirates, the Dantooine and Endor tribes,
  Nightsisters and the Singing Mountain clan, Garyn, Cobral, Narmle...).
  Same columns as `creatures.csv`. Left out: townspeople, Imperials,
  Rebels, named characters, droids, mounts and pets, and NPCs the 2004
  table already has (it is used for those). Read the same way, every row
  checked by eye against the page; social groups normalised.

  The tables run over two facing pages. On the three pages where a
  planet's table starts partway down (pp. 424, 428, 468), the rows below
  the heading were first paired with the wrong facing row; they were read
  again from the whole page, paired by position (the book's XP by level
  confirms it). 23 creatures in `creatures.csv` were corrected the same
  way (KNOWN_ISSUES #60).

Used by: migrations 007 (`tools/reference/weapons_sql.py`, from
`weapons.csv`) and 010 (`tools/reference/specials_sql.py`, from
`specials.csv`), 011 (`tools/reference/creatures_sql.py`, with
`../prima_2004/creatures.csv`) and the combat rules (`data/script/combat/rules.lua`).

Not transcribed yet: the crafting ranges (pp. 391, 393; the range of each
stat a crafted weapon can have) and the armour's per-piece HAM costs
(pp. 394-395).

Read with care where the scan was faint: please report any value that
looks wrong against the page.
