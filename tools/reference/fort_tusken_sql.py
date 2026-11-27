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


if __name__ == "__main__":
    main()
