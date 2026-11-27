#!/usr/bin/env python3
"""Writes migration 075: Fort Tusken's own Tuskens, from the swganh wiki.

    python3 tools/reference/fort_tusken_sql.py > mmoserverdb/migrations/075_fort_tusken_wiki_tuskens.sql

Fort Tusken was the hard place: players remember Jedi grinding there. An
Empire Divided's Tuskens (levels 9-20) made it easy, so the fort gets its
own commoner, captain, chief and elite guard with the stats of the swganh
wiki's Tusken pages (mmoserverdb/reference/swganh_wiki/tuskens.csv; levels
16-44, killers and stalkers but the commoner). The Tusken village and the
Tusken camps keep the book's. The wiki has no raider, sniper, warlord,
King or bantha: those stay the book's (An Empire Divided, p. 476).

It replaces migration 073's three fort lairs (6001-6003) with four
(6101-6104) in the same spawn area (901):
  4 x commoner (wiki), raider, sniper (book)
  3 x captain, chief (wiki)
  2 x elite guard (wiki)
  1 x warlord, King, bantha (book)
Reconstructed, and data to tune: the mix and counts; the Tusken rifle each
one carries (reach 64 m). The armour is shown on examine only: combat does
not use creature armour yet. Waves (Publish 1 notes, 13 August 2003: "Set
up Fort Tusken to spawn in waves") come later.
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creatures_sql import REF, sql_str, stat_rows  # noqa: E402

NPC_FIRST = 12001
LAIR_FIRST = 6101
GROUP_ROW_FIRST = 1001
ATTR_FIRST = 81001
SPAWN = 901
OLD_LAIRS = (6001, 6002, 6003)
WEAPON = "object/weapon/ranged/rifle/shared_rifle_tusken.iff"
REACH = 64
LAIR_OBJECT = "object/tangible/lair/base/shared_objective_banner_generic_1.iff"  # never shown: invisible

# (count, [(source, key)]): "wiki" is this migration's template, "book"
# the An Empire Divided template the other spawns use.
MIXES = [
    (4, [("wiki", "tusken_commoner"), ("book", "tusken_raider"), ("book", "tusken_sniper")]),
    (3, [("wiki", "tusken_captain"), ("wiki", "tusken_chief")]),
    (2, [("wiki", "tusken_elite_guard")]),
    (1, [("book", "tusken_warlord"), ("book", "tusken_king"), ("book", "tusken_bantha")]),
]

KINDS = {"acid": "armor_eff_elemental_acid", "blast": "armor_eff_blast",
         "cold": "armor_eff_elemental_cold", "electricity": "armor_eff_elemental_electrical",
         "energy": "armor_eff_energy", "heat": "armor_eff_elemental_heat",
         "kinetic": "armor_eff_kinetic", "stun": "armor_eff_stun"}


def armor(field, category):
    out = []
    for pair in filter(None, field.split(";")):
        kind, value = pair.split()
        out.append(("%s.%s" % (category, KINDS[kind]), value))
    return out


def main():
    with open(os.path.join(REF, "swganh_wiki", "tuskens.csv"), newline="") as f:
        wiki = {r["key"]: r for r in csv.DictReader(f)}
    yes = lambda r, k: int(r[k] == "yes")

    ids = {}
    npcs, stats, table = [], [], []
    for n, (key, r) in enumerate(wiki.items()):
        npc_id = NPC_FIRST + n
        ids[key] = npc_id
        ham = {pool: (int(r["ham_min"]), int(r["ham_max"])) for pool in ("health", "action", "mind")}
        values = {
            "creature_tohit": r["to_hit"],
            "creature_damage_min": r["damage_min"], "creature_damage_max": r["damage_max"],
            "creature_xp": r["xp"], "creature_social_group": "Tusken Raider",
            "killer": yes(r, "killer"), "Pack": yes(r, "pack"), "Herd": yes(r, "herd"),
            "stalking": yes(r, "stalker"), "creature_is_aggressive": yes(r, "aggro"),
            "creature_group_assist": yes(r, "pack"), "tamable": 0,
            "creature_weapon": WEAPON, "creature_humanoid": 1, "creature_damage_max_range": REACH,
            "creature_is_roaming": 1, "creature_roaming_delay": 30000,
            "creature_roaming_speed": "1.0", "creature_roaming_max_distance": "30.0",
        }
        rows = stat_rows(npc_id, ham, values)
        rows += [(npc_id, a, v) for a, v in armor(r["effectiveness"], "cat_armor_effectiveness")]
        rows += [(npc_id, a, v) for a, v in armor(r["special_protection"], "cat_armor_special_protection")]
        stats.extend(rows)
        npcs.append("  (%d, 8, 1, 1, 'object/mobile/shared_tusken_raider.iff', %s, 'mob/creature_names', %s, 1, 0, 0, 0, 1)" % (
            npc_id, sql_str(key), r["level"]))
        table.append("--   %d %-19s lvl %-2s HAM %s-%s, %s-%s dmg, %s%% to hit, %s XP%s (oldid %s)" % (
            npc_id, r["name"], r["level"], r["ham_min"], r["ham_max"], r["damage_min"], r["damage_max"],
            r["to_hit"], r["xp"], ", killer, stalker" if r["killer"] == "yes" else "", r["oldid"]))

    templates, groups, lairs, attrs = [], [], [], []
    lair_id, group_row, attr_id = LAIR_FIRST, GROUP_ROW_FIRST, ATTR_FIRST
    for count, members in MIXES:
        templates.append("  (%d, %s, 'global_outlaw_neutral_none', 'lair_n', '', '')" % (lair_id, sql_str(LAIR_OBJECT)))
        for source, key in members:
            if source == "wiki":
                creature = str(ids[key])
            else:
                creature = ("(SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8"
                            " AND id >= 3001 AND id < %d AND stf_variable_id = %s)" % (NPC_FIRST, sql_str(key)))
            groups.append("SELECT %d, %d, %s" % (group_row, lair_id, creature))
            group_row += 1
        lairs.append("  (%d, %d, 9, 1, %d, %d, %d, 0, 0, 0, 1, 0)" % (lair_id, SPAWN, lair_id, lair_id, count))
        for a, v in (("lair_fix_position", 0), ("lair_at_poi", 1), ("lair_invisible", 1),
                     ("lair_wave_size", 4), ("lair_passive_waves", 3),
                     ("lair_respawn_delay", 300000), ("lair_creatures_max_spawn_distance", 25),
                     ("lair_creatures_respawn_delay", 60000), ("creature_xp", 0),
                     ("creature_health", 1000), ("creature_strength", 1000), ("creature_constitution", 1000)):
            attrs.append((attr_id, lair_id, a, v))
            attr_id += 1
        lair_id += 1

    out = sys.stdout
    out.write(__doc__.split("\n\n", 1)[1].replace("\n", "\n-- ").join(["-- ", "\n"]))
    out.write("-- Written by tools/reference/fort_tusken_sql.py; edit that, not this.\n--\n")
    out.write("\n".join(table) + "\n--\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
    old = ", ".join(str(i) for i in OLD_LAIRS)
    out.write("-- Migration 073's fort lairs.\n")
    out.write("DELETE FROM swganh.lair_attributes WHERE lair_id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.creature_groups WHERE creature_group_id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.lairs WHERE id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.lair_templates WHERE id IN (%s);\n\n" % old)
    out.write("INSERT IGNORE INTO swganh.non_persistent_npcs\n"
              "  (id, family, species_id, loot_group_id, type, stf_variable_id, stf_file_id, level, faction, posture, moodID, state, scale)\n  VALUES\n")
    out.write(",\n".join(npcs) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.non_persistent_npc_attributes (npc_id, attribute_id, value, `order`)\n"
              "  SELECT v.npc_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS npc_id, %s AS name, %s AS value" % (i, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %s, %s" % (i, sql_str(a), sql_str(v)) for n, (i, a, v) in enumerate(stats)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")
    out.write("INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)\n  VALUES\n")
    out.write(",\n".join(templates) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)\n  ")
    out.write("\n  UNION ALL ".join(groups) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.lairs\n"
              "  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)\n  VALUES\n")
    out.write(",\n".join(lairs) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)\n"
              "  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS id, %d AS lair_id, %s AS name, %s AS value" % (i, l, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %d, %s, %s" % (i, l, sql_str(a), sql_str(v)) for n, (i, l, a, v) in enumerate(attrs)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


WAVES_DOC = """\
-- Fort Tusken in waves (docs/SPAWNS.md). The Publish 1 notes (13 August
-- 2003, wiki.swganh.org/index.php/Publish_1_Notes:_13_August_03): "Set up
-- Fort Tusken to spawn in waves"; the wiki's carnage champion page: "three
-- waves of progressively more difficult NPCs before starting over"; its
-- elite guard page: the bunker's last room held "five of these NPCs along
-- with the Tusken King". Written by tools/reference/fort_tusken_sql.py
-- --waves; edit that, not this.
--
-- Replaces 075's four fort lairs (6101-6104) with %d wave lairs (6111),
-- each calling waves of %d:
--   wave 1: commoners (wiki), raiders, snipers (book)
--   wave 2: captains, chiefs (wiki), warlords (book)
--   wave 3: the Tusken King (book) and five elite guards (wiki)
-- A wave follows %d s after the last one is down; after the third, the
-- first comes back after %d minutes. Reconstructed, and data to tune: the
-- waves' members and size, the delays, the number of lairs. The bantha is
-- left out of the fort (a lair holds 8 kinds; the village has them).
--
"""

WAVE_LAIR = 6111
WAVE_LAIRS = 3
WAVE_SIZE = 6
WAVE_DELAY_MS = 30000
CYCLE_MS = 300000
WAVE_GROUP_ROW = 1101
WAVE_ATTR_FIRST = 81101
STAGES = [
    [("wiki", "tusken_commoner"), ("book", "tusken_raider"), ("book", "tusken_sniper")],
    [("wiki", "tusken_captain"), ("wiki", "tusken_chief"), ("book", "tusken_warlord")],
    # The last kind is the wave's leader (lair_wave_boss): one King.
    [("wiki", "tusken_elite_guard"), ("book", "tusken_king")],
]


def waves():
    """Migration 076, the fort in waves:

    python3 tools/reference/fort_tusken_sql.py --waves > mmoserverdb/migrations/076_fort_tusken_waves.sql
    """
    wiki_ids = {}
    with open(os.path.join(REF, "swganh_wiki", "tuskens.csv"), newline="") as f:
        for n, r in enumerate(csv.DictReader(f)):
            wiki_ids[r["key"]] = NPC_FIRST + n
    out = sys.stdout
    out.write(WAVES_DOC % (WAVE_LAIRS, WAVE_SIZE, WAVE_DELAY_MS // 1000, CYCLE_MS // 60000))
    out.write("\nSET FOREIGN_KEY_CHECKS = 0;\n\n")
    out.write("INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)\n  VALUES "
              "('lair_wave_stages', 1, 'A lair in waves: how many of its kinds (in group order) each wave calls from, e.g. 3,3,2'),\n"
              "         ('lair_wave_boss', 1, 'A lair in waves: its last kind leads the last wave, one of it'),\n"
              "         ('lair_wave_delay', 1, 'A lair in waves: ms from a wave''s end to the next');\n\n")
    old = ", ".join(str(LAIR_FIRST + i) for i in range(len(MIXES)))
    out.write("-- Migration 075's fort lairs.\n")
    out.write("DELETE FROM swganh.lair_attributes WHERE lair_id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.creature_groups WHERE creature_group_id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.lairs WHERE id IN (%s);\n" % old)
    out.write("DELETE FROM swganh.lair_templates WHERE id IN (%s);\n\n" % old)
    out.write("INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)\n"
              "  VALUES (%d, %s, 'global_outlaw_neutral_none', 'lair_n', '', '');\n\n" % (WAVE_LAIR, sql_str(LAIR_OBJECT)))
    groups, row = [], WAVE_GROUP_ROW
    for stage in STAGES:
        for source, key in stage:
            if source == "wiki":
                creature = str(wiki_ids[key])
            else:
                creature = ("(SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8"
                            " AND id >= 3001 AND id < %d AND stf_variable_id = %s)" % (NPC_FIRST, sql_str(key)))
            groups.append("SELECT %d, %d, %s" % (row, WAVE_LAIR, creature))
            row += 1
    out.write("-- In wave order: the lair reads its kinds by row id.\n")
    out.write("INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)\n  ")
    out.write("\n  UNION ALL ".join(groups) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.lairs\n"
              "  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)\n"
              "  VALUES (%d, %d, 9, 1, %d, %d, %d, 0, 0, 0, 1, 0);\n\n" % (WAVE_LAIR, SPAWN, WAVE_LAIR, WAVE_LAIR, WAVE_LAIRS))
    attrs = [("lair_fix_position", 0), ("lair_at_poi", 1), ("lair_invisible", 1),
             ("lair_wave_size", WAVE_SIZE), ("lair_passive_waves", 3),
             ("lair_wave_stages", ",".join(str(len(s)) for s in STAGES)), ("lair_wave_boss", 1),
             ("lair_wave_delay", WAVE_DELAY_MS), ("lair_respawn_delay", CYCLE_MS),
             ("lair_creatures_max_spawn_distance", 25), ("lair_creatures_respawn_delay", 3000),
             ("creature_xp", 0), ("creature_health", 1000), ("creature_strength", 1000), ("creature_constitution", 1000)]
    out.write("INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)\n"
              "  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS id, %d AS lair_id, %s AS name, %s AS value" % (WAVE_ATTR_FIRST + n, WAVE_LAIR, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %d, %s, %s" % (WAVE_ATTR_FIRST + n, WAVE_LAIR, sql_str(a), sql_str(v)) for n, (a, v) in enumerate(attrs)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


# Spots in the fort clear of its walls, from the VM (in game, November
# 2026): (name, x, z, spread in metres, King's wave). The catwalks (-4010,
# 6290 and -3957, 6288, height 68) wait: creatures are put on the terrain.
SPOTS = [
    ("courtyard", -3980, 6253, 6, True),
    ("gate", -3982, 6292, 3, False),
    ("back left, by the cave", -3962, 6232, 4, False),
    ("opposite corner", -4009, 6235, 4, False),
]
SPOT_LAIR_FIRST = 6121
SPOT_GROUP_KING = 6121
SPOT_GROUP_GUARDS = 6122
SPOT_GROUP_ROW = 1201
SPOT_ATTR_FIRST = 81201


def spots():
    """Migration 079, the waves at fixed spots:

    python3 tools/reference/fort_tusken_sql.py --spots > mmoserverdb/migrations/079_fort_tusken_spots.sql
    """
    wiki_ids = {}
    with open(os.path.join(REF, "swganh_wiki", "tuskens.csv"), newline="") as f:
        for n, r in enumerate(csv.DictReader(f)):
            wiki_ids[r["key"]] = NPC_FIRST + n
    out = sys.stdout
    out.write("""\
-- Fort Tusken's waves at fixed spots (docs/SPAWNS.md). 076's three wave
-- lairs were placed at random in the fort's area, and the server has no
-- wall shapes: Tuskens stood inside the walls. Four spots clear of them,
-- found in game (November 2026), each a wave lair; their Tuskens appear
-- within a few metres of it:
""")
    for name, x, z, spread, king in SPOTS:
        out.write("--   %-24s %6d, %5d  within %d m%s\n" % (name, x, z, spread, ", the King's wave" if king else ""))
    out.write("""\
-- Each calls 076's waves of six; only the courtyard's third wave has the
-- King, the others' are elite guards (one King in the fort, not four).
-- The catwalks wait: the server puts creatures on the terrain, under them.
-- Written by tools/reference/fort_tusken_sql.py --spots; edit that, not this.
--

SET FOREIGN_KEY_CHECKS = 0;

-- Migration 076's wave lair.
""")
    out.write("DELETE FROM swganh.lair_attributes WHERE lair_id = %d;\n" % WAVE_LAIR)
    out.write("DELETE FROM swganh.creature_groups WHERE creature_group_id = %d;\n" % WAVE_LAIR)
    out.write("DELETE FROM swganh.lairs WHERE id = %d;\n" % WAVE_LAIR)
    out.write("DELETE FROM swganh.lair_templates WHERE id = %d;\n\n" % WAVE_LAIR)

    def creature(source, key):
        if source == "wiki":
            return str(wiki_ids[key])
        return ("(SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8"
                " AND id >= 3001 AND id < %d AND stf_variable_id = %s)" % (NPC_FIRST, sql_str(key)))

    groups, row = [], SPOT_GROUP_ROW
    for group, stages in ((SPOT_GROUP_KING, STAGES), (SPOT_GROUP_GUARDS, STAGES[:-1] + [STAGES[-1][:-1]])):
        for stage in stages:
            for source, key in stage:
                groups.append("SELECT %d, %d, %s" % (row, group, creature(source, key)))
                row += 1
    out.write("INSERT IGNORE INTO swganh.lair_templates (id, lair_object_string, stf_name, stf_file, stf_detail_name, stf_detail_file)\n  VALUES ")
    out.write(",\n         ".join("(%d, %s, 'global_outlaw_neutral_none', 'lair_n', '', '')" % (SPOT_LAIR_FIRST + n, sql_str(LAIR_OBJECT))
                                    for n in range(len(SPOTS))) + ";\n\n")
    out.write("-- In wave order: the lair reads its kinds by row id. %d with the King, %d without.\n" % (SPOT_GROUP_KING, SPOT_GROUP_GUARDS))
    out.write("INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)\n  ")
    out.write("\n  UNION ALL ".join(groups) + ";\n\n")
    lairs, attrs = [], []
    attr_id = SPOT_ATTR_FIRST
    for n, (name, x, z, spread, king) in enumerate(SPOTS):
        lair_id = SPOT_LAIR_FIRST + n
        group = SPOT_GROUP_KING if king else SPOT_GROUP_GUARDS
        lairs.append("  (%d, %d, 9, 1, %d, %d, 1, %d, 0, %d, 1, 0)" % (lair_id, SPAWN, lair_id, group, x, z))
        stages = STAGES if king else STAGES[:-1] + [STAGES[-1][:-1]]
        for a, v in (("lair_fix_position", 1), ("lair_invisible", 1),
                     ("lair_wave_size", WAVE_SIZE), ("lair_passive_waves", 3),
                     ("lair_wave_stages", ",".join(str(len(s)) for s in stages)), ("lair_wave_boss", 1 if king else 0),
                     ("lair_wave_delay", WAVE_DELAY_MS), ("lair_respawn_delay", CYCLE_MS),
                     ("lair_creatures_max_spawn_distance", spread), ("lair_creatures_respawn_delay", 3000),
                     ("creature_xp", 0), ("creature_health", 1000), ("creature_strength", 1000), ("creature_constitution", 1000)):
            attrs.append((attr_id, lair_id, a, v))
            attr_id += 1
    out.write("INSERT IGNORE INTO swganh.lairs\n"
              "  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)\n  VALUES\n")
    out.write(",\n".join(lairs) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)\n"
              "  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS id, %d AS lair_id, %s AS name, %s AS value" % (i, l, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %d, %s, %s" % (i, l, sql_str(a), sql_str(v)) for n, (i, l, a, v) in enumerate(attrs)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


if __name__ == "__main__":
    if "--waves" in sys.argv[1:]:
        waves()
    elif "--spots" in sys.argv[1:]:
        spots()
    else:
        main()
