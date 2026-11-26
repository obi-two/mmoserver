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
takes the edge's height for a point past it.

Confirmed on the VM (Nov 2026, T44): walking out of Bestine, lesser desert
womp rats (level 5) 312 m and domestic eopies (4) 537 m from Bestine's
edge; gorgs (6) 1,222 m from Bestine; eopies (7) 798 m from Anchorhead's
edge, with their lair. Each in its band, with its client model, its name
("an eopie", "an eopie lair") and the guide's stats. The old test lairs near
Bestine (25 level-10 womp rat lairs and 25 rill lairs by the city) are
switched off.

The other planets (Nov 2026): migrations 029-037, from the same generator.
The creatures' client names, models and lair models are in
`tools/reference/planet_lairs.csv` (names only), matched to the client's
lists and checked by hand where a creature has no model or lair of its own
(it takes its species' model, or a generic lair: insect hill, nest, warren
or rock shelter by kind). Lairs (6 per creature) by planet: Corellia 252,
Naboo 234, Tatooine 180, Rori 138, Talus 108, Lok 72, Yavin 4 72, Dathomir
60, Dantooine 24, Endor 24. The secondary planets have few creatures at
these levels: the 2004 guide's tables stop at level 11.

Lair names: 027-037 named each lair after its creature, and the client's
`lair_n` string file mostly lacks those keys (a lair showed
`lair_n:[corellian_butterfly_drone]`). Its keys follow the lair model's
file name, so each lair now takes its model's (migration 038; the generic
lairs "an insect hill", "a nest", "a warren", "a rocky shelter"...).
Confirmed on Corellia (Nov 2026): "a Corellian butterfly lair" with its
drones outside Coronet; the lair's examine shows its hit points (2,500
health, strength and constitution; KNOWN_ISSUES #49).

Above level 11 (Nov 2026): migrations 039-048, from the same generator
(`planet_lairs_sql.py <planet> --guide ed`). The creatures are An Empire
Divided's table (pp. 396-483), transcribed with page citations to
`mmoserverdb/reference/prima_ed/creatures.csv` (364 wild creatures above
level 11, each with its planet from the table's planet headings; read from
the text layer and two OCR passes, and every row checked by eye against the
page). Their client names, models and lair models are the `ed` rows of
`planet_lairs.csv` (362; the shamaff has no client model). Bands and counts:

| Levels | Distance from the nearest city's edge | Lairs per creature |
|---|---|---|
| 12-20 | 2,500 m and further | 4 |
| 21-50 | 3,500 m and further | 3 |
| 51+ | 4,500 m and further | 2 |

A lair's hit points are 500 per level as before, at most 50,000 (a level
300 krayt dragon's would otherwise have 150,000). By planet: Endor 75
creatures, Lok 51, Rori 36, Dathomir 32, Naboo 31, Yavin 4 31, Talus 30,
Tatooine 27, Corellia 26, Dantooine 23; 1,258 lairs in all. Their ids start
apart from the lower levels' (templates 5001+, lairs 2101+, lair
attributes 20001+, 100 or 1,000 per planet).

Movement: the creatures stood still. A creature only wanders when its
template has `creature_is_roaming` set, and only the six old womp rat and
rill templates had it. Migration 049 gives every creature template without
its own settings: wander when a player is near, to a random spot within
15 m every 30-45 s, at 1 m/s, within 30 m of where it spawned
(reconstructed; the attributes `creature_roaming_delay`,
`creature_roaming_speed`, `creature_roaming_max_distance`).

Still too still on the VM (Nov 2026): a creature woke only for a player
within 64 m, though players see creatures to 128 m, and its first wander
came 30-45 s after waking, so most were seen standing. Now a creature wakes
for a player within the viewing range (`Zone_Player_ViewingRange`, 128 m)
and first wanders within 8 s of waking.

Krayt dragons (migration 050): only at the Krayt Graveyard, as they were
rare. The client's POI list puts the graveyard at (6839, 4320); its two
no-build circles keep random lairs out, so the krayt lairs there have
fixed positions: 2 juvenile canyon krayt lairs, 1 canyon krayt dragon lair
and 1 giant canyon krayt dragon lair, each calling one krayt at a time (a
killed krayt back after 10 minutes, a destroyed lair after 30). 039's random
krayt lairs are switched off (count 0). The first test found none: a
lair's first spawn after a zone start waited one to two times its respawn
delay, so 30-60 minutes for these; the wait's base is now at most 5
minutes, so every lair appears within 10 minutes of a start. That cap is
the server setting `Lair_First_Spawn_Max_Minutes` (`config_server`,
migration 051; default 5): set it to 0 on a test server and every lair
spawns at once, then restart the zones.

Confirmed on the VM (Nov 2026): all four graveyard lairs spawned with one
krayt each (at 7250, 4330; 7540, 4620; 6960, 4440; 6700, 4230); a juvenile
canyon krayt dragon by "a krayt dragon lair", with the client's model.

The base data's `persistent_npcs` had 15 wild animals placed by hand
(Tatooine's desert razorbacks and giant sand beetles, Lok's fanned rawls,
a fynock youth on Rori, a gubbur on Corellia) as conversing NPCs that could
not be attacked; 050 removes them, as the lairs now place those creatures.

## NPC camps

Hostile, non-faction NPC groups (gangs, thugs, cults, Jawas...) in camps,
placed as the creature lairs are (decided Nov 2026: NPCs first, the camp
buildings next).

- The NPCs: the 2004 guide's NPC rows for the planet (pp. 188-206), without
  townspeople, Imperials and Rebels (factions, roadmap step 4), the mission
  and named NPCs, and those that "can't be harmed". Each gets the table's
  stats and the client's model (`dressed_tatooine_<name>` for most) and
  name.
- Weapons: the table gives each NPC a weapon set ("Pirate weapons
  (light)", "Rebel weapons (hard)", "Tusken weapons") but not what is in
  it, so each set is one client weapon (reconstructed): CDEF pistol and
  carbine for the pirate sets, DL-44, DH-17 carbine and T-21 for the rebel
  ones, the Tusken rifle. An NPC holds its weapon (`creature_weapon`),
  attacks with that weapon's animation (`creature_humanoid`), and reaches 35
  m with a pistol, 50 m with a carbine, 64 m with a rifle; its damage is the
  table's. NPCs without a set fight unarmed.
- A camp: a lair whose object is the client's objective banner, named
  after the group's camp in the client's `lair_n` ("a Dune Stalker camp",
  "a Trandosian slaver camp"), calling the group's NPCs 4 at a time, placed
  at random in the band of its strongest NPC's level. 4 camps of each kind.
- `tools/reference/npc_camps.csv` (names only) pairs each NPC with its
  client name, model, weapon set and camp; `npc_camps_sql.py <planet>`
  writes the migration.

Tatooine (migration 053): 49 NPCs in 19 kinds of camp, 76 camps: the
Cannibal enclave, dervish camp, Desert Demon settlement, swoop gang camp,
Dim-U chapel, Dune Stalker camp, evil settlement, outlaw camp, moisture
thief camp, Jabba swooper and enforcer camps, the kitonaks, the Jawa
warband, the Rodian clan camp, the Trandosian slaver camp, the Valarian
swooper and enforcer outposts and the Weequay settlement. Confirmed on the
VM (Nov 2026): a dervish camp, its banner named, its dervishes shooting
with their carbines; the radar much busier. Not yet: Tusken
Raiders (not in the 2004 table's NPC rows), the other planets.

Camp buildings (migration 054). The swganh wiki's "Lairs" page describes
three kinds of spawn: mission lairs (spawned by a mission, named, to
destroy), wild lairs, and invisible lairs (spawn points: a group with
nothing to destroy). The client's camp names fit: `_theater` camps ("a Dune
Stalker camp") had a building, `_none` ones ("a Jawa warband camp", "a
Desert Demon patrol outpost") did not. So a wild camp is now its group's
building with its NPCs, and the destroyable banner is left to destroy
missions:

- each camp's lair is invisible (`lair_invisible`): in the world for its
  NPCs but never shown, and it replaces its NPCs without end (60 s after
  each death), as it cannot be destroyed to reset;
- a camp with a building (`lair_building`) puts up the client's camp for
  its group (`object/building/poi/shared_tatooine_dunestalkers_medium.iff`
  and so on, sized as the client's camp name) at the lair's spot, once; not
  stored, it comes back with the zone (at a new spot);
- the cannibal enclave, the kitonaks and the Jawa warband are spawn points
  only, as their client names say.

Confirmed on the VM (Nov 2026): a Weequay settlement, the client's camp
(tents, banner, a crashed hull) on the ground with its zealots and thugs
around it, and the client stable.

The other planets (migrations 055-059, Nov 2026): Corellia 14 kinds of
camp, Naboo 14, Rori 6, Talus 8, Endor 5; 138 NPCs, 188 camps, from the
same generator (`npc_camps_sql.py <planet>`, which now writes the
buildings and invisible lairs from the start; `npc_camps.csv` has a
building column for them). Notes:

- Models: groups the client dresses (Binayre, Cobral, Kobola, Narmle,
  First Brigade, Fed-Dub, Lost Aqualish, Spice Collective, Liberation
  Party, Borvos, Maulers, RSF, plasma thieves) keep their own; species
  groups their species (Drall, Selonians and the Afarathu cult, Gungans,
  Ewoks for Gondula and Panshee, Jinda, Duloks for Korga and Pubam); the
  street gangs the client has no outfit for (Meatlumps, Chunkers, Sleemos,
  Mummers, Skaak Tippers, Ragtags, Gundarks, smashball) one of its generic
  ones by kind (goon, hoodlum, crook, ruffian, desperado). Reconstructed.
- Buildings: Corellia, Naboo and Endor have the client's camps (Afarathu,
  Drall, Greck, Meatlump, Selonian, Nyax, smashball, swoop; Borvos, Mauler,
  RSF, plasma thieves, Trade Federation, swamp rat gang, Gungans; Ewok and
  Dulok villages). The Publish 14 client has no camp buildings for Rori
  and Talus, so their camps are their NPCs only.
- Two groups have more kinds than a lair holds and are two camps, as the
  client names them: Selonian separatists and raiders (Corellia), the
  Chunker bruiser and goon camps (Talus).
- Left out: townspeople and officials, the Corellia Times reporters, the
  Kahmurra bio-engineer, the Warren's scientists (Dantooine) and the
  Dathomir prison camps' slaves (content to come); and three NPCs the
  client has no name for (Cobral hooligan, Cobral mugger, Sleemo vandal).
- More weapon sets: "Pirate weapons (hard)" a CDEF rifle, "Imperial weapons
  (medium)" an E-11 carbine, "Nyax Pirate weapons (medium)" a CDEF carbine,
  "general melee weapons" a vibroblade, "Ewok weapons" a stone knife.

Aggression is the table's: a group marked Aggro (dervishes, Dune Stalkers,
the evil settlers, Afarathu, Pubam...) attacks players who come near; the
others (the Weequay, most gangs) fight only when attacked, and then as a
pack.

The wiki also says wild creature lairs had plain names ("a pile of rocks",
"a pile of leaves") and only mission lairs were named after their
creatures; ours are all named. To revisit.

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
3. **NPC camps**: hostile, non-faction NPCs (thugs, gangs, Tusken Raiders
   and the like, from the 2004 table's NPC rows with their planets and
   levels) in camps placed in the same bands. Faction NPCs (patrols,
   bases) come with factions (roadmap step 4); named NPCs and quests with
   content (step 8).
