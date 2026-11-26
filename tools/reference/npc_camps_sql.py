#!/usr/bin/env python3
"""Writes a planet's NPC camps migration (docs/SPAWNS.md, NPC camps).

    python3 tools/reference/npc_camps_sql.py tatooine > mmoserverdb/migrations/053_tatooine_npc_camps.sql

For each hostile, non-faction group of the planet's NPCs in the 2004
guide's table (mmoserverdb/reference/prima_2004/creatures.csv): a template
for each of its NPCs (the table's stats, as creatures_sql.py writes them;
the client's model and name; a weapon) and a camp: a lair whose object is
the client's objective banner, named after the group's camp in the
client's lair_n string file ("a Dune Stalker camp"), calling the group's
NPCs, placed at random on the planet within the distance band of its
strongest NPC's level (planet_lairs_sql.py's bands).

The NPCs, their camps' names and their models are in
tools/reference/npc_camps.csv (names only, from the Publish 14 client).
Townspeople, Imperials, Rebels and the guide's mission and named NPCs are
not camps. The camp buildings (the client's object/building/poi/ theaters)
come later; for now a camp is its banner and its NPCs.

Reconstructed, and data to tune: the weapon each of the guide's weapon
sets stands for (the guide names the sets, not their weapons), each
weapon's reach, the number of camps and the camps' settings.
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creatures_sql import REF, NEW_ATTRIBUTES, sql_str, stat_rows, stats_2004  # noqa: E402
from planet_lairs_sql import PLANETS, AREA, band_for, lair_hp  # noqa: E402

# The guide's weapon sets (its NPC table's Weapons column) as one client
# weapon each. The damage stays the NPC's own; the weapon gives the model
# in its hands, the attack animation and, below, its reach.
WEAPON_SETS = {
    "Pirate weapons (light)": "object/weapon/ranged/pistol/shared_pistol_cdef.iff",
    "Pirate weapons (medium)": "object/weapon/ranged/carbine/shared_carbine_cdef.iff",
    "Rebel weapons (light)": "object/weapon/ranged/pistol/shared_pistol_dl44.iff",
    "Rebel weapons (medium)": "object/weapon/ranged/carbine/shared_carbine_dh17.iff",
    "Rebel weapons (hard)": "object/weapon/ranged/rifle/shared_rifle_t21.iff",
    "Tusken weapons": "object/weapon/ranged/rifle/shared_rifle_tusken.iff",
    "ranged weapons": "object/weapon/ranged/carbine/shared_carbine_cdef.iff",
}
# Reach by weapon kind, in metres; an NPC without a weapon fights unarmed.
REACH = {"pistol": 35, "carbine": 50, "rifle": 64}
UNARMED_REACH = 4

# The camp object: the client's objective banner for the planet.
BANNER = {
    "tatooine": "object/tangible/lair/base/shared_objective_banner_tatooine.iff",
    "corellia": "object/tangible/lair/base/shared_objective_banner_corellia.iff",
}
GENERIC_BANNER = "object/tangible/lair/base/shared_objective_banner_generic_1.iff"

CAMPS_PER_KIND = 4
WAVE_SIZE = 4
PASSIVE_WAVES = 3
CAMP_RESPAWN_MS = 300000
NPC_RESPAWN_MS = 60000
NPC_RANGE = 25

NPC_ATTRIBUTES = [
    ("creature_weapon", "An NPC's weapon: the client weapon template it holds"),
    ("creature_humanoid", "An NPC that attacks as a person with its weapon, not as a creature"),
]


def reach(weapon):
    for kind, metres in REACH.items():
        if "/%s/" % kind in weapon:
            return metres
    return UNARMED_REACH


def main():
    planet = sys.argv[1] if len(sys.argv) > 1 else "tatooine"
    location, planet_id, index = PLANETS[planet]
    with open(os.path.join(REF, "prima_2004", "creatures.csv"), newline="") as f:
        table = {r["name"]: r for r in csv.DictReader(f) if r["section"] == "NPCs"}
    with open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "npc_camps.csv"), newline="") as f:
        rows = [r for r in csv.DictReader(f) if r["planet"] == location]

    ids = {"npc": 7001 + 100 * index, "camp": 3101 + 100 * index,
           "group_row": 1, "lair_attribute": 40001 + 1000 * index}
    spawn = 801 + index
    camps = {}
    for r in rows:
        camps.setdefault(r["camp"], {"key": r["camp_key"], "npcs": []})["npcs"].append(r)

    npcs, stats, templates, groups, lairs, lair_attrs, summary = [], [], [], [], [], [], []
    for camp, info in camps.items():
        camp_id = ids["camp"]
        ids["camp"] += 1
        levels, group_flags, members = [], False, []
        for r in info["npcs"]:
            t = table[r["name"]]
            level = int(t["level"])
            levels.append(level)
            npc_id = ids["npc"]
            ids["npc"] += 1
            ham, values = stats_2004(t)
            group_flags = group_flags or bool(values["Pack"] or values["Herd"])
            # NPCs have no meat, hide or bone.
            for k in ("res_meat", "creature_meat_qty", "res_hide", "creature_hide_qty",
                      "res_bone", "creature_bone_qty", "creature_milk"):
                values.pop(k, None)
            weapon = WEAPON_SETS.get(r["weapons"], "")
            values["creature_humanoid"] = 1
            if weapon:
                values["creature_weapon"] = weapon
            values["creature_damage_max_range"] = reach(weapon)
            # Wander near players, as every creature does (migration 049).
            values.update({"creature_is_roaming": 1, "creature_roaming_delay": 30000,
                           "creature_roaming_speed": "1.0", "creature_roaming_max_distance": "30.0"})
            npcs.append("  (%d, 8, 1, 1, %s, %s, 'mob/creature_names', %d, 1, 0, 0, 0, 1)" % (
                npc_id, sql_str("object/mobile/shared_%s.iff" % r["model"]), sql_str(r["key"]), level))
            stats.extend(stat_rows(npc_id, ham, values))
            groups.append("  (%d, %d, %d)" % (ids["group_row"], camp_id, npc_id))
            ids["group_row"] += 1
            members.append("%s (%d, %s)" % (r["name"], level, weapon.split("/")[-1][len("shared_"):-len(".iff")] if weapon else "unarmed"))
        top = max(levels)
        dmin, dmax, _ = band_for(top)
        templates.append("  (%d, %s, %s, 'lair_n', '', '')" % (
            camp_id, sql_str(BANNER.get(planet, GENERIC_BANNER)), sql_str(info["key"])))
        lairs.append("  (%d, %d, 9, 1, %d, %d, %d, 0, 0, 0, 1, 0)" % (camp_id, spawn, camp_id, camp_id, CAMPS_PER_KIND))
        lair_attrs += [
            (camp_id, "lair_fix_position", 0),
            (camp_id, "lair_wave_size", WAVE_SIZE),
            (camp_id, "lair_passive_waves", PASSIVE_WAVES),
            (camp_id, "lair_respawn_delay", CAMP_RESPAWN_MS),
            (camp_id, "lair_creatures_max_spawn_distance", NPC_RANGE),
            (camp_id, "lair_creatures_respawn_delay", NPC_RESPAWN_MS),
            (camp_id, "creature_xp", max(int(table[r["name"]]["xp"]) for r in info["npcs"])),
            (camp_id, "creature_health", lair_hp(top)),
            (camp_id, "creature_strength", lair_hp(top)),
            (camp_id, "creature_constitution", lair_hp(top)),
            (camp_id, "lair_min_city_distance", dmin),
        ]
        if dmax < 1.0e9:
            lair_attrs.append((camp_id, "lair_max_city_distance", dmax))
        far = "%d m+" % dmin if dmax >= 1.0e9 else "%d-%d m" % (dmin, dmax)
        pages = sorted({table[r["name"]]["page"] for r in info["npcs"]})
        summary.append("--   %-45s up to lvl %-2d %-10s %s; pp. %s" % (
            info["key"], top, far, ", ".join(members), ", ".join(pages)))

    out = sys.stdout
    out.write("""\
-- %s: NPC camps (docs/SPAWNS.md, roadmap step 3). Written by
-- tools/reference/npc_camps_sql.py; edit that, not this.
--
-- The planet's hostile, non-faction NPC groups in the 2004 guide's table
-- (Prima 2004, pp. 188-206): each NPC a template with the table's stats,
-- the client's model and name, and a weapon; each group a camp, %d of each
-- kind, placed at random on the planet in the distance band of its
-- strongest NPC's level (as the creature lairs). A camp is the client's
-- objective banner, named after the group's camp in the client's lair_n
-- ("a Dune Stalker camp"), calling its NPCs; the camp buildings come later.
--
-- Reconstructed, and data to tune: the guide names each NPC's weapon set
-- ("Pirate weapons (light)") but not the weapons in it, so each set is one
-- client weapon (pistols reach 35 m, carbines 50 m, rifles 64 m); the
-- damage is the NPC's own, from the table. Camps call %d NPCs at a time.
--
""" % (planet.capitalize(), CAMPS_PER_KIND, WAVE_SIZE))
    out.write("\n".join(summary) + "\n--\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 0;\n\n")
    out.write("INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)\n  VALUES ")
    out.write(",\n         ".join("(%s, 1, %s)" % (sql_str(n), sql_str(d)) for n, d in NEW_ATTRIBUTES + NPC_ATTRIBUTES))
    out.write(";\n\n")
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
    base = ids["lair_attribute"]
    out.write("INSERT IGNORE INTO swganh.lair_attributes (id, lair_id, attribute_id, value, `order`)\n"
              "  SELECT v.id, v.lair_id, a.id, v.value, 0 FROM (\n")
    out.write("\n    UNION ALL ".join("    SELECT %d AS id, %d AS lair_id, %s AS name, %s AS value" % (base + n, i, sql_str(a), sql_str(v)) if n == 0 else
                                     "SELECT %d, %d, %s, %s" % (base + n, i, sql_str(a), sql_str(v)) for n, (i, a, v) in enumerate(lair_attrs)))
    out.write("\n  ) v JOIN swganh.attributes a ON a.name = v.name;\n\n")
    out.write("SET FOREIGN_KEY_CHECKS = 1;\n")


if __name__ == "__main__":
    main()
