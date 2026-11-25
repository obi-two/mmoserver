#!/usr/bin/env python3
"""Writes a planet's creature lairs migration (docs/SPAWNS.md).

    python3 tools/reference/planet_lairs_sql.py tatooine > mmoserverdb/migrations/027_tatooine_lairs.sql
    python3 tools/reference/planet_lairs_sql.py corellia > mmoserverdb/migrations/029_corellia_lairs.sql

For each of the planet's wild creatures in the 2004 guide's table
(mmoserverdb/reference/prima_2004/creatures.csv): a creature template
(non_persistent_npcs, with the client's model and name) and its stats, as
tools/reference/creatures_sql.py writes them; a lair template with the
client's lair model; and a lairs row placing a number of those lairs at
random on the planet, within the creature's distance band from the nearest
city: weak creatures near the cities, stronger ones further out.

The guides give each creature's planet but not where on it, and the client
has no spawn tables, so the bands, the lair counts and the lairs' own
settings are reconstructed. They are data: tune them in the database.
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creatures_sql import REF, NEW_ATTRIBUTES, sql_str, stat_rows, stats_2004, stats_ed  # noqa: E402

# Distance bands from the nearest city's edge, in metres, by guide level.
# (lowest level, highest level, min distance, max distance, lairs per creature)
BANDS = [
    (1, 5, 50, 600, 6),
    (6, 8, 600, 1500, 6),
    (9, 11, 1500, 1.0e9, 6),
    # An Empire Divided's creatures above level 11 (migrations 039-048):
    # further out, and fewer of the strongest.
    (12, 20, 2500, 1.0e9, 4),
    (21, 50, 3500, 1.0e9, 3),
    (51, 1000, 4500, 1.0e9, 2),
]

# The planets: the name in the guide's location column, the planet's id in
# the database, and the order the ids below are given out in (Tatooine,
# the first done, is 0). Each planet's spawn area is the whole map, inside
# its -7680 to 7680 edge (migration 027 was written with -7900 to 7900;
# 028 corrects it).
PLANETS = {
    "tatooine": ("Tatooine", 8, 0),
    "corellia": ("Corellia", 0, 1),
    "dantooine": ("Dantooine", 1, 2),
    "dathomir": ("Dathomir", 2, 3),
    "endor": ("Endor", 3, 4),
    "lok": ("Lok", 4, 5),
    "naboo": ("Naboo", 5, 6),
    "rori": ("Rori", 6, 7),
    "talus": ("Talus", 7, 8),
    "yavin4": ("Yavin 4", 9, 9),
}
AREA = (-7600, -7600, 15200, 15200)

# Each planet's creatures, in tools/reference/planet_lairs.csv: the name in
# the 2004 table, the string key in the client's mob/creature_names, the
# client model under object/mobile/, and the client lair model under
# object/tangible/lair/. Names only, from the Publish 14 client. A creature
# with no model of its own takes its species'; one with no lair model of
# its own a generic one (base/: insect hill, nest, warren or rock shelter).


def planet_info(planet, guide="2004"):
    """A planet's creatures from one guide: "2004" (levels 1-11, migrations
    027 and 029-037) or "ed" (An Empire Divided, above level 11, 039-048),
    each with its own range of ids."""
    location, planet_id, index = PLANETS[planet]
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "planet_lairs.csv"), newline="") as f:
        creatures = [(r["name"], r["key"], r["model"], r["lair"]) for r in csv.DictReader(f)
                     if r["planet"] == location and r["guide"] == guide]
    if guide == "2004":
        ids = {"npc": 3001 + 100 * index, "lair_template": 101 + 100 * index,
               "creature_group": 101 + 100 * index, "lair": 101 + 100 * index,
               "spawn": 801 + index, "lair_attribute": 1001 + 1000 * index}
    else:
        ids = {"npc": 5001 + 100 * index, "lair_template": 2101 + 100 * index,
               "creature_group": 2101 + 100 * index, "lair": 2101 + 100 * index,
               "spawn": 801 + index, "lair_attribute": 20001 + 1000 * index}
    return {"planet_id": planet_id, "area": AREA, "ids": ids, "creatures": creatures, "guide": guide}


# Lair settings (reconstructed): its own hit points per creature level, the
# creatures it calls at a time (more for pack and herd animals), how many
# quiet waves, how long until it respawns after destruction and until a
# killed creature is replaced, and how far its creatures range.
LAIR_HP_PER_LEVEL = 500
LAIR_HP_MAX = 50000  # a level 300 krayt dragon's lair would otherwise have 150,000


def lair_hp(level):
    return min(LAIR_HP_PER_LEVEL * level, LAIR_HP_MAX)

WAVE_SIZE = {"group": 5, "solo": 3}
PASSIVE_WAVES = 3
LAIR_RESPAWN_MS = 300000
CREATURE_RESPAWN_MS = 60000
CREATURE_RANGE = 30

LAIR_ATTRIBUTES = [
    ("lair_min_city_distance", "Random lairs: least distance from the nearest city's edge (m)"),
    ("lair_max_city_distance", "Random lairs: greatest distance from the nearest city's edge (m)"),
]


# The lair's name: a key in the client's lair_n string file, which follows
# the lair model's file name (lair/bantha/shared_lair_bantha_desert.iff ->
# bantha_desert, "a desert bantha lair"). The generic lairs and the bark
# mite's have names under other keys.
LAIR_NAME_KEYS = {
    "bark_mite/shared_lair_bark_mite.iff": "barkmite",
    "garbage": "lair_garbage",
}


def lair_name_key(lair):
    if lair in LAIR_NAME_KEYS:
        return LAIR_NAME_KEYS[lair]
    stem = lair.split("/")[-1][len("shared_"):-len(".iff")]
    if stem.startswith("poi_all_lair_"):
        # base/shared_poi_all_lair_<kind>_<small|large>.iff
        kind = stem[len("poi_all_lair_"):].rsplit("_", 1)[0]
        return LAIR_NAME_KEYS.get(kind, kind)
    return stem[len("lair_"):] if stem.startswith("lair_") else stem


def band_for(level):
    for lo, hi, dmin, dmax, count in BANDS:
        if lo <= level <= hi:
            return dmin, dmax, count
    raise SystemExit("no band for level %d" % level)


def lair_names():
    """Migration 038: the lairs' names for the planets' lairs already loaded
    (027-037 gave each lair its creature's key, which lair_n mostly lacks)."""
    out = sys.stdout
    out.write("""\
-- The lairs' names (docs/SPAWNS.md). Migrations 027-037 named each lair
-- after its creature (lair_n:<creature key>), and the client's lair_n string
-- file has most of those keys under the lair model's name instead: a lair
-- showed "lair_n:[corellian_butterfly_drone]". Each lair now takes the key
-- for its model (lair/bantha/shared_lair_bantha_desert.iff -> bantha_desert,
-- "a desert bantha lair"; the generic ones "an insect hill", "a nest", "a
-- warren", ...). Written by tools/reference/planet_lairs_sql.py --lair-names.

""")
    for planet in PLANETS:
        p = planet_info(planet)
        template_id = p["ids"]["lair_template"]
        for _, _, _, lair_model in p["creatures"]:
            out.write("UPDATE swganh.lair_templates SET stf_name = %s WHERE id = %d;\n" % (
                sql_str(lair_name_key(lair_model)), template_id))
            template_id += 1


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--lair-names":
        lair_names()
        return
    args = sys.argv[1:]
    guide = "2004"
    if "--guide" in args:
        k = args.index("--guide")
        guide = args[k + 1]
        del args[k:k + 2]
    planet = args[0] if args else "tatooine"
    p = planet_info(planet, guide)
    if guide == "2004":
        with open(os.path.join(REF, "prima_2004", "creatures.csv"), newline="") as f:
            table = {r["name"]: r for r in csv.DictReader(f) if r["section"] == "Creatures"}
        stats_of, book = stats_2004, "Prima 2004"
    else:
        with open(os.path.join(REF, "prima_ed", "creatures.csv"), newline="") as f:
            table = {r["name"]: r for r in csv.DictReader(f) if r["planet"] == PLANETS[planet][0]}
        stats_of, book = stats_ed, "An Empire Divided"

    ids = dict(p["ids"])
    npcs, stats, templates, groups, lairs, lair_attrs, summary, names = [], [], [], [], [], [], [], []
    for name, key, model, lair_model in p["creatures"]:
        r = table[name]
        level = int(r["level"])
        dmin, dmax, count = band_for(level)
        npc_id = ids["npc"]
        template_id = ids["lair_template"]
        group_id = ids["creature_group"]
        lair_id = ids["lair"]
        ids["npc"] += 1
        ids["lair_template"] += 1
        ids["creature_group"] += 1
        ids["lair"] += 1

        ham, values = stats_of(r)
        npcs.append("  (%d, 8, 1, 1, %s, %s, 'mob/creature_names', %d, 1, 0, 0, 0, 1)" % (
            npc_id, sql_str("object/mobile/shared_%s.iff" % model), sql_str(key), level))
        stats.extend(stat_rows(npc_id, ham, values))
        templates.append("  (%d, %s, %s, 'lair_n', '', '')" % (
            template_id, sql_str("object/tangible/lair/" + lair_model), sql_str(lair_name_key(lair_model))))
        names.append((template_id, lair_name_key(lair_model)))
        groups.append("  (%d, %d, %d)" % (group_id, group_id, npc_id))
        lairs.append("  (%d, %d, 9, 1, %d, %d, %d, 0, 0, 0, 1, 0)" % (
            lair_id, p["ids"]["spawn"], template_id, group_id, count))
        group = values["Pack"] or values["Herd"]
        lair_attrs += [
            (lair_id, "lair_fix_position", 0),
            (lair_id, "lair_wave_size", WAVE_SIZE["group" if group else "solo"]),
            (lair_id, "lair_passive_waves", PASSIVE_WAVES),
            (lair_id, "lair_respawn_delay", LAIR_RESPAWN_MS),
            (lair_id, "lair_creatures_max_spawn_distance", CREATURE_RANGE),
            (lair_id, "lair_creatures_respawn_delay", CREATURE_RESPAWN_MS),
            (lair_id, "creature_xp", r["xp"]),
            (lair_id, "creature_health", lair_hp(level)),
            (lair_id, "creature_strength", lair_hp(level)),
            (lair_id, "creature_constitution", lair_hp(level)),
            (lair_id, "lair_min_city_distance", dmin),
        ]
        if dmax < 1.0e9:
            lair_attrs.append((lair_id, "lair_max_city_distance", dmax))
        far = "%d m+" % dmin if dmax >= 1.0e9 else "%d-%d m" % (dmin, dmax)
        summary.append("--   %-24s lvl %-2d %-11s %d lairs  model %s%s  (%s, pp. %s-%s)" % (
            name, level, far, count, model, "" if model == key else " (key %s)" % key, book, r["page"], r["facing"]))

    out = sys.stdout
    if guide == "2004":
        out.write(HEADER_2004 % (planet.capitalize(), LAIR_HP_PER_LEVEL))
    else:
        out.write(HEADER_ED % (planet.capitalize(), LAIR_HP_PER_LEVEL, LAIR_HP_MAX))
    out.write("\n".join(summary) + "\n--\n")
    if planet == "tatooine" and guide == "2004":
        out.write("-- The old test lairs near Bestine (25 womp rat and 25 rill lairs at random,\n"
                  "-- level 10 by the city) are switched off: count 0.\n")
    out.write("\n")
    _body(out, p, planet, guide, npcs, stats, templates, groups, lairs, lair_attrs)


HEADER_2004 = """\
-- %s: creature lairs (docs/SPAWNS.md, roadmap step 3). Written by
-- tools/reference/planet_lairs_sql.py; edit that, not this.
--
-- The planet's wild creatures in the 2004 guide's table (levels 1-11; the
-- bio-engineered ones are crafted, not wild), each with its stats from the
-- table, the client's model and name, and the client's lair model. A
-- creature with no model of its own (diseased bocatt, death kreetle, ...)
-- takes its species'.
--
-- Where: neither guide says where on the planet a creature lives, and the
-- client has no spawn tables, so placement is reconstructed: lairs are
-- placed at random on the planet within a distance band from the nearest
-- city's edge, by level, so no strong creature lives by a town:
--   levels 1-5    50-600 m
--   levels 6-8    600-1,500 m
--   levels 9-11   1,500 m and further
-- The counts and the lairs' own settings (hit points %d per level, waves,
-- respawn times) are reconstructed too. All of it is data, to tune.
--
"""

HEADER_ED = """\
-- %s: creature lairs above level 11 (docs/SPAWNS.md, roadmap step 3).
-- Written by tools/reference/planet_lairs_sql.py --guide ed; edit that, not
-- this.
--
-- The planet's wild creatures in An Empire Divided's table above level 11
-- (mmoserverdb/reference/prima_ed/creatures.csv; levels 1-11 came from the
-- 2004 guide, migrations 027-037), each with its stats from the table, the
-- client's model and name, and the client's lair model. A creature with no
-- model or lair of its own takes its species'.
--
-- Where: as for the lower levels, lairs are placed at random on the planet
-- within a distance band from the nearest city's edge, by level, further
-- out and fewer the stronger the creature:
--   levels 12-20  2,500 m and further, 4 lairs each
--   levels 21-50  3,500 m and further, 3 lairs each
--   levels 51+    4,500 m and further, 2 lairs each
-- The counts and the lairs' own settings (hit points %d per level, at most
-- %d; waves, respawn times) are reconstructed. All of it is data, to tune.
--
"""


def _body(out, p, planet, guide, npcs, stats, templates, groups, lairs, lair_attrs):
    x, z, w, l = p["area"]

    out.write("-- creature_groups.creature_id has a foreign key to a `creatures` table that\n"
              "-- does not exist (it is a non_persistent_npcs id), so no row could be\n"
              "-- added with the checks on; the base data is loaded with them off too.\n"
              "SET FOREIGN_KEY_CHECKS = 0;\n\n")
    out.write("INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)\n  VALUES ")
    out.write(",\n         ".join("(%s, 1, %s)" % (sql_str(n), sql_str(d)) for n, d in NEW_ATTRIBUTES + LAIR_ATTRIBUTES))
    out.write(";\n\n")

    out.write("-- The whole map, for random lairs.\n")
    out.write("INSERT IGNORE INTO swganh.spawns (id, spawn_x, spawn_z, spawn_width, spawn_length, spawn_planet, spawn_density)\n"
              "  VALUES (%d, %d, %d, %d, %d, %d, 1);\n\n" % (p["ids"]["spawn"], x, z, w, l, p["planet_id"]))

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
    out.write("INSERT IGNORE INTO swganh.creature_groups (id, creature_group_id, creature_id)\n  VALUES\n")
    out.write(",\n".join(groups) + ";\n\n")
    out.write("INSERT IGNORE INTO swganh.lairs\n"
              "  (id, creature_spawn_region, family, faction, lair_template, creature_group, count, spawn_x, spawn_y, spawn_z, spawn_dir_Y, spawn_dir_W)\n  VALUES\n")
    out.write(",\n".join(lairs) + ";\n\n")

    # lair_attributes.id is not numbered by the database: one per row.
    base = p["ids"]["lair_attribute"]
    out.write("INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)\n"
              "  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS id, %d AS lair_id, %s AS name, %s AS value" % (base + n, i, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %d, %s, %s" % (base + n, i, sql_str(a), sql_str(v)) for n, (i, a, v) in enumerate(lair_attrs)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")

    if planet == "tatooine" and guide == "2004":
        out.write("UPDATE swganh.lairs SET count = 0 WHERE id IN (3, 4);\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


if __name__ == "__main__":
    main()
