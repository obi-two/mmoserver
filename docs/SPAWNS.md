# Creature spawns and lairs

How the world gets its creatures, and the plan for roadmap step 3, **Fill
the world** (`docs/ROADMAP.md`). Today only the area around Bestine has
any.

## How it works today

All of it is data in the game database; the ZoneServer reads it at start.

| Table | What it holds |
|---|---|
| `spawns` | Spawn areas: rectangles per planet (`spawn_x`, `spawn_z` the low corner, `spawn_width`, `spawn_length`). Every planet has a handful, most covering large parts of the map |
| `lairs` | One row per kind of lair in an area: the area (`creature_spawn_region`), the lair's model (`lair_template`), the creatures it calls (`creature_group`), and either a fixed position or `count` lairs placed at random in the area (`lair_fix_position` 0) |
| `lair_templates` | The lair's object template and name |
| `lair_attributes` | Per lair: its hit points, XP, wave size, waves, respawn delays, how far its creatures roam |
| `creature_groups` | Which creature templates a lair calls |
| `non_persistent_npcs` | Creature templates: the client model (`type`, an `object/mobile/` template), the name (`stf_file_id`:`stf_variable_id`), level |
| `non_persistent_npc_attributes` | Creature stats: HAM, to-hit, damage, XP, behaviour, resources. Written from the guides' tables by `tools/reference/creatures_sql.py` (migration 011) |

`NpcManager::loadLairs` reads the planet's lairs; each `LairObject` places
itself (at random in its area when not fixed), spawns its first wave and
calls more when attacked (KNOWN_ISSUES and `docs/COMBAT.md`). Destroy
missions spawn a lair of their own.

What exists: 29 creature templates (womp rats, rill, dune lizards), four
`lairs` rows near Bestine (two fixed, two of 25 random lairs).

Gaps:
- A random lair's position ignored cities: it could land inside one.
  Fixed: placement tests the no-build areas (the cities among them,
  migration 003), as structure placement does
  (`StructureManager::checkNoBuildRegion`), and tries again, up to 20
  times.
- Only six of the 2004 guide's Tatooine creatures had a template.
- `creature_groups.creature_id` has a foreign key to a `creatures` table
  that does not exist; the generated migrations add their rows with the
  key checks off, as the base data does.

## What each creature needs

| Piece | Source |
|---|---|
| Stats: level, HAM range, to-hit, damage, XP, behaviour, resources | The guides' creature tables, already transcribed with page citations (`mmoserverdb/reference/`) |
| Model | The client's `object/mobile/shared_<creature>.iff`; the template names are in the database (`object_models`) |
| Name | The client's `mob/creature_names` string file |
| Lair model | The client's `object/tangible/lair/<creature>/shared_lair_<creature>*.iff` (674 lair templates), or a generic one from `object/tangible/lair/base/` |
| Where it lives | The guides' planet chapters (2004 guide, pp. 118-159), cited by page |
| How many, how often | Not in any source: the client has no spawn tables (they were server data). Reconstructed, labelled, and kept in data so a community can tune it |

## Distance bands

Neither guide says where on a planet a creature lives, and the client has
no spawn tables, so placement is our own design (decided Nov 2026): lairs
are placed at random on the planet, but only within a band of distance
from the nearest city's edge that depends on the creature's level, so no
strong creature lives by a town.

- The cities are the planet's `cities` rows and their areas in
  `planet_regions` (for Tatooine, the client's city circles, migration
  003). `NpcManager` reads them before the lairs.
- A lair's band is two lair attributes, `lair_min_city_distance` and
  `lair_max_city_distance` (metres from the nearest city's edge); a random
  lair retries its spot until it is inside its band and outside every
  no-build area (up to 100 times, then logs and keeps the last).
- `tools/reference/planet_lairs_sql.py <planet>` writes a planet's
  migration: one creature template per wild creature in the 2004 guide's
  table (stats as `creatures_sql.py` writes them, the client's model and
  name), a lair template with the client's lair model, and a lairs row
  placing a number of them at random over the whole map within the
  creature's band. The bands (levels 1-5 at 50-600 m, 6-8 at 600-1,500 m,
  9-11 beyond), the counts (6 lairs per creature) and the lairs' settings
  are constants at the top of the script, and data in the database once
  applied.

Tatooine: migration 027, 30 creatures, 180 lairs. Its area first reached
past the map's edge (the map covers -7680 to 7680 m) and the first test
crashed the zone: a lair placed past the edge read the height cache out of
bounds. Migration 028 keeps the area inside the map, and the height lookup
takes the edge's height for a point past it. The old test lairs near
Bestine (25 level-10 womp rat lairs and 25 rill lairs by the city) are
switched off.

Not yet: creatures above level 11 (krayt dragons, Tusken camps, ...): An
Empire Divided's tables have them but no planet, so they need matching by
name; and the lairs' names (`lair_n` keys are guessed from the creature).

Parked (ROADMAP): levels that change with how much an area is hunted; spawn
areas set up by a community from the portal.

## Plan

1. **Tatooine first** (the planet the housing tests need populated):
   - templates for its wild creatures from the 2004 guide's table (149
     Tatooine rows, of which about 40 are wild creatures; the rest are NPCs,
     for later), generated by extending `creatures_sql.py`;
   - spawn areas and lairs from the guide's Tatooine chapter;
   - random lairs kept out of cities;
   - tested on the VM: lairs around each city, the right creatures in the
     right places, nothing inside a city.
2. **Then the other planets**, one pull request each or in pairs, the same
   way.
3. NPC camps and the planets' named NPCs (the other rows of the tables) come
   with factions (roadmap step 4) and content (step 8).
