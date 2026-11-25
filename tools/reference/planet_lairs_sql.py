#!/usr/bin/env python3
"""Writes a planet's creature lairs migration (docs/SPAWNS.md).

    python3 tools/reference/planet_lairs_sql.py tatooine > mmoserverdb/migrations/027_tatooine_lairs.sql

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
from creatures_sql import REF, NEW_ATTRIBUTES, sql_str, stat_rows, stats_2004  # noqa: E402

# Distance bands from the nearest city's edge, in metres, by guide level.
# (lowest level, highest level, min distance, max distance, lairs per creature)
BANDS = [
    (1, 5, 50, 600, 6),
    (6, 8, 600, 1500, 6),
    (9, 11, 1500, 1.0e9, 6),
]

# Per planet: the planet's id, its spawn area (the whole map), and its
# creatures: (name in the 2004 table, string key in the client's
# mob/creature_names, client model under object/mobile/, client lair model
# under object/tangible/lair/). Names only, from the Publish 14 client. A
# creature with no model of its own takes its species' (noted).
PLANETS = {
    "tatooine": {
        "planet_id": 8,
        # The whole map, inside its -7680 to 7680 edge (migration 027 was
        # written with -7900 to 7900; 028 corrects it).
        "area": (-7600, -7600, 15200, 15200),
        "ids": {"npc": 3001, "lair_template": 101, "creature_group": 101, "lair": 101, "spawn": 801, "lair_attribute": 1001},
        "creatures": [
            ("Tatooine mynock", "tatooine_mynock", "mynock", "mynock/shared_lair_mynock.iff"),
            ("dwarf eopie", "dwarf_eopie", "dwarf_eopie", "eopie/shared_lair_eopie_desert.iff"),
            ("kreetle", "kreetle", "kreetle", "base/shared_poi_all_lair_insecthill_small.iff"),
            ("domestic eopie", "domestic_eopie", "eopie", "eopie/shared_lair_eopie.iff"),
            ("dwarf nuna", "dwarf_nuna", "dwarf_nuna", "dwarf_nuna/shared_lair_dwarf_nuna.iff"),
            ("lesser desert womp rat", "lesser_desert_womprat", "lesser_desert_womp_rat", "womp_rat/shared_lair_womp_rat_desert.iff"),
            ("minor worrt", "minor_worrt", "minor_worrt", "worrt/shared_lair_worrt_desert.iff"),
            ("drooling nuna", "dwarf_nuna_drooling", "dwarf_nuna", "dwarf_nuna/shared_lair_dwarf_nuna.iff"),
            ("gorg", "gorg", "gorg", "base/shared_poi_all_lair_mound_small.iff"),
            ("kreetle swarmling", "kreetle_swarming", "kreetle", "base/shared_poi_all_lair_insecthill_large.iff"),
            ("rill", "rill", "rill", "base/shared_poi_all_lair_nest_small.iff"),
            ("slum rat", "womprat_city", "womp_rat", "base/shared_poi_all_lair_garbage_small.iff"),
            ("worrt", "worrt", "worrt", "worrt/shared_lair_worrt.iff"),
            ("eopie", "eopie", "eopie", "eopie/shared_lair_eopie_dune.iff"),
            ("gorg glutton", "gorg_glutton", "gorg", "base/shared_poi_all_lair_mound_large.iff"),
            ("sevorrt", "sevorrt", "sevorrt", "base/shared_poi_all_lair_nest_large.iff"),
            ("diseased bocatt", "bocatt_diseased", "bocatt", "bocatt/shared_lair_bocatt.iff"),
            ("rockmite", "rockmite", "mound_mite", "base/shared_poi_all_lair_insecthill_small.iff"),
            ("death kreetle", "kreetle_death", "kreetle", "base/shared_poi_all_lair_insecthill_large.iff"),
            ("eopie herdmaster", "eopie_herdmaster", "eopie", "eopie/shared_lair_eopie_wasteland.iff"),
            ("lesser dewback", "lesser_dewback", "dewback", "dewback/shared_lair_dewback_desert.iff"),
            ("mound mite", "mound_mite", "mound_mite", "base/shared_poi_all_lair_insecthill_large.iff"),
            ("tempest rill", "rill_tempest", "rill", "base/shared_poi_all_lair_nest_large.iff"),
            ("bantha E3", "bantha", "bantha", "bantha/shared_lair_bantha_desert.iff"),
            ("jundland eopie", "jundland_eopie", "eopie", "eopie/shared_lair_eopie_mountain.iff"),
            ("womp rat", "womprat", "womp_rat", "womp_rat/shared_lair_womp_rat.iff"),
            ("young mountain squill", "young_mountain_squill", "mountain_squill", "squill/shared_lair_squill_desert.iff"),
            ("zucca boar", "zucca_boar", "zucca_boar", "zucca_boar/shared_lair_zucca_boar_desert.iff"),
            ("cu pa", "cu_pa", "cu_pa", "cu_pa/shared_lair_cu_pa_dune.iff"),
            ("dwarf bantha", "dwarf_bantha", "dwarf_bantha", "bantha/shared_lair_bantha_dune.iff"),
        ],
    },
}

# Lair settings (reconstructed): its own hit points per creature level, the
# creatures it calls at a time (more for pack and herd animals), how many
# quiet waves, how long until it respawns after destruction and until a
# killed creature is replaced, and how far its creatures range.
LAIR_HP_PER_LEVEL = 500
WAVE_SIZE = {"group": 5, "solo": 3}
PASSIVE_WAVES = 3
LAIR_RESPAWN_MS = 300000
CREATURE_RESPAWN_MS = 60000
CREATURE_RANGE = 30

LAIR_ATTRIBUTES = [
    ("lair_min_city_distance", "Random lairs: least distance from the nearest city's edge (m)"),
    ("lair_max_city_distance", "Random lairs: greatest distance from the nearest city's edge (m)"),
]


def band_for(level):
    for lo, hi, dmin, dmax, count in BANDS:
        if lo <= level <= hi:
            return dmin, dmax, count
    raise SystemExit("no band for level %d" % level)


def main():
    planet = sys.argv[1] if len(sys.argv) > 1 else "tatooine"
    p = PLANETS[planet]
    with open(os.path.join(REF, "prima_2004", "creatures.csv"), newline="") as f:
        table = {r["name"]: r for r in csv.DictReader(f) if r["section"] == "Creatures"}

    ids = dict(p["ids"])
    npcs, stats, templates, groups, lairs, lair_attrs, summary = [], [], [], [], [], [], []
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

        ham, values = stats_2004(r)
        npcs.append("  (%d, 8, 1, 1, %s, %s, 'mob/creature_names', %d, 1, 0, 0, 0, 1)" % (
            npc_id, sql_str("object/mobile/shared_%s.iff" % model), sql_str(key), level))
        stats.extend(stat_rows(npc_id, ham, values))
        templates.append("  (%d, %s, %s, 'lair_n', '', '')" % (
            template_id, sql_str("object/tangible/lair/" + lair_model), sql_str(key)))
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
            (lair_id, "creature_health", LAIR_HP_PER_LEVEL * level),
            (lair_id, "creature_strength", LAIR_HP_PER_LEVEL * level),
            (lair_id, "creature_constitution", LAIR_HP_PER_LEVEL * level),
            (lair_id, "lair_min_city_distance", dmin),
        ]
        if dmax < 1.0e9:
            lair_attrs.append((lair_id, "lair_max_city_distance", dmax))
        far = "%d m+" % dmin if dmax >= 1.0e9 else "%d-%d m" % (dmin, dmax)
        summary.append("--   %-24s lvl %-2d %-11s %d lairs  model %s%s  (Prima 2004, pp. %s-%s)" % (
            name, level, far, count, model, "" if model == key else " (key %s)" % key, r["page"], r["facing"]))

    x, z, w, l = p["area"]
    out = sys.stdout
    out.write("""\
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
""" % (planet.capitalize(), LAIR_HP_PER_LEVEL))
    out.write("\n".join(summary) + "\n--\n")
    out.write("-- The old test lairs near Bestine (25 womp rat and 25 rill lairs at random,\n"
              "-- level 10 by the city) are switched off: count 0.\n\n")

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

    if planet == "tatooine":
        out.write("UPDATE swganh.lairs SET count = 0 WHERE id IN (3, 4);\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


if __name__ == "__main__":
    main()
