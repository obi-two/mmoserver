#!/usr/bin/env python3
"""Writes the points of interest's spawns (docs/SPAWNS.md, roadmap step 3).

    python3 tools/reference/poi_spawns_sql.py > mmoserverdb/migrations/073_poi_spawns.sql

The named outdoor places that had their own inhabitants pre-CU (Fort
Tusken's Sandpeople, the Dantooine tribes' strongholds, the Mauler
stronghold, the canyon corsairs' hideout...): each gets a small spawn area
centred on the place's position in planet_regions (the base data, from the
client's region files), and a few invisible lairs placed at random in it
(lair_at_poi: the place is a no-build area, so the usual tests would refuse
every spot) calling the place's people, from the templates the creature and
camp migrations made (027-071).

Who lives where follows the place's name (the swganh wiki's POI pages, from
the live game: "Sandpeople, Commoners, Raiders, Snipers, Warlords, and even
the Tusken King roam" Fort Tusken); how many, and in which mixes, is
reconstructed: data to tune. Caves and dungeons (their insides) and the
battle sites (two sides fighting each other) are not here: the server
spawns outdoors only, and NPCs do not fight NPCs yet.
"""

import csv
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from creatures_sql import sql_str  # noqa: E402
from planet_lairs_sql import PLANETS  # noqa: E402

# planet, region name in planet_regions, half-size of the spawn area (m),
# then (number of lairs, [name keys of the people a lair calls]).
POIS = [
    ("tatooine", "forttusken", 150, [
        (4, ["tusken_commoner", "tusken_raider", "tusken_sniper"]),
        (2, ["tusken_captain", "tusken_chief"]),
        (1, ["tusken_warlord", "tusken_king", "tusken_bantha"])]),
    ("tatooine", "Jawa Fortress", 100, [
        (3, ["jawa", "jawa_engineer", "jawa_healer", "jawa_henchman", "jawa_smuggler", "jawa_thief"]),
        (1, ["jawa_leader", "jawa_warlord"])]),
    ("tatooine", "Beggar's Canyon", 60, [
        (2, ["womprat", "lesser_desert_womprat"])]),
    ("dantooine", "Junta Stronghold", 100, [
        (3, ["janta_tribesman", "janta_herbalist", "janta_harvester", "janta_hunter"]),
        (2, ["janta_primalist", "janta_loreweaver", "janta_scout", "janta_rockshaper"]),
        (1, ["janta_shaman", "janta_soothsayer", "janta_warrior", "janta_clan_leader"])]),
    ("dantooine", "Kunga Stronghold", 100, [
        (3, ["kunga_tribesman", "kunga_herbalist", "kunga_harvester", "kunga_soothsayer"]),
        (2, ["kunga_clan_primalist", "kunga_hunter", "kunga_loreweaver", "kunga_scout"]),
        (1, ["kunga_shaman", "kunga_rockshaper", "kunga_warrior"])]),
    ("dantooine", "Mokk Stronghold", 150, [
        (3, ["mokk_tribesman", "mokk_herbalist", "mokk_harvester", "mokk_hunter"]),
        (2, ["mokk_soothsayer", "mokk_primalist", "mokk_loreweaver", "mokk_scout"]),
        (1, ["mokk_shaman", "mokk_rockshaper", "mokk_warrior", "mokk_clan_leader"])]),
    ("dantooine", "dantari1", 80, [
        (2, ["dantari_raider", "dantari_raider_strategist"]),
        (1, ["dantari_raider_battlelord", "dantari_raider_chief"])]),
    ("dantooine", "dantari2", 80, [
        (2, ["dantari_raider", "dantari_raider_strategist"]),
        (1, ["dantari_raider_battlelord", "dantari_raider_chief"])]),
    ("dantooine", "dantari3", 80, [
        (2, ["dantari_raider", "dantari_raider_strategist"]),
        (1, ["dantari_raider_battlelord", "dantari_raider_chief"])]),
    ("dathomir", "nightsister", 100, [
        (3, ["nightsister_sentry", "nightsister_initiate", "nightsister_ranger"]),
        (1, ["nightsister_stalker", "nightsister_rancor_tamer", "nightsister_rancor"])]),
    ("dathomir", "singing", 100, [
        (3, ["singing_mountain_clan_sentry", "singing_mtn_clan_initiate", "singing_mtn_clan_scout"]),
        (1, ["singing_mtn_clan_huntress", "singing_mtn_clan_rancor_tamer", "singing_mountain_clan_rancor",
             "singing_mtn_clan_dragoon"])]),
    ("endor", "dulok1", 80, [
        (3, ["donkuwah_tribesman", "donkuwah_scout", "donkuwah_shaman", "donkuwah_laborer"]),
        (1, ["donkuwah_battlelord", "donkuwah_spiritmaster", "donkuwah_chieftan"])]),
    ("endor", "dulok2", 80, [
        (3, ["pubam_tribesman", "pubam_scout", "pubam_dark_shaman"]),
        (1, ["pubam_battlelord", "pubam_chieftan"])]),
    ("endor", "marauder", 80, [
        (3, ["marauder", "feral_marauder", "frenzied_marauder"]),
        (1, ["blood_crazed_plains_marauder", "grassland_blood_marauder"])]),
    ("lok", "Canyon Corsair Hideout", 200, [
        (4, ["canyon_corsair_pirate_weak", "canyon_corsair_scout", "canyon_corsair_cutthroat",
             "canyon_corsair_pirate_strong"]),
        (2, ["canyon_corsair_guard", "canyon_corsair_destroyer", "canyon_corsair_pirate_elite"]),
        (1, ["elite_canyon_corsair", "canyon_corsair_captain"])]),
    ("lok", "bloodrazor", 80, [
        (3, ["blood_razor_pirate_weak", "blood_razor_pirate_strong", "blood_razor_scout", "blood_razor_cutthroat"]),
        (1, ["blood_razor_officer", "blood_razor_captain", "blood_razor_berzerker"])]),
    ("naboo", "Mauler Stronghold", 150, [
        (3, ["mauler_apprentice", "mauler_acolyte", "mauler"]),
        (1, ["mauler_lord", "mauler_master"])]),
    ("naboo", "Gungan Warrior Stronghold", 150, [
        (3, ["gungan_scout", "gungan_grand_army_soldier", "gungan_hunter", "gungan_guard"]),
        (1, ["gungan_captain", "gungan_general", "gungan_war_chief", "gungan_boss"])]),
    ("rori", "Cobral Hideout", 120, [
        (3, ["cobral_thug", "cobral_thief", "cobral_runner", "cobral_bandit"]),
        (1, ["cobral_hitman", "cobral_assassin", "cobral_boss", "cobral_overlord"])]),
    ("rori", "Rori Gungan Swamp Town", 150, [
        (3, ["rorgungan_scout", "rorgungan_commoner", "rorgungan_warrior"]),
        (1, ["rorgungan_warchief", "rorgungan_boss"])]),
    ("rori", "kobala", 80, [
        (3, ["kobola_miner", "kobola_smuggler", "kobola_thief", "kobola_guard"]),
        (1, ["kobola_assassin", "kobola_pitboss", "kobola_underboss"])]),
    ("talus", "Binyare Pirate Base", 100, [
        (3, ["binayre_hooligan", "binayre_scalawag", "binayre_ruffian", "binayre_pirate"]),
        (1, ["binayre_smuggler", "binayre_swindler", "binayre_chief"])]),
    ("corellia", "Nyax Cultists Outpost", 150, [
        (3, ["lord_nyax_minion", "lord_nyax_servant", "lord_nyax_disciple"]),
        (1, ["lord_nyax_fanatic", "lord_nyax_zealot", "lord_nyax_fiend", "lord_nyax_visionary"])]),
    ("corellia", "afarathu", 60, [
        (2, ["afarathu_cult_follower", "afarathu_cult_ruffian", "afarathu_cult_savage", "afarathu_cult_brute",
             "afarathu_cult_hellion"])]),
    ("corellia", "drall", 60, [
        (2, ["drall_sentry", "drall_monk", "drall_guard", "drall_patriot", "drall_abbot"])]),
]

LAIR_OBJECT = "object/tangible/lair/base/shared_objective_banner_generic_1.iff"  # never shown: invisible
WAVE_SIZE = 4
PASSIVE_WAVES = 3
NPC_RESPAWN_MS = 60000
NPC_RANGE = 25


def known_keys():
    here = os.path.dirname(os.path.abspath(__file__))
    keys = set()
    for name in ("npc_camps.csv", "planet_lairs.csv"):
        with open(os.path.join(here, name), newline="") as f:
            keys |= {r["key"] for r in csv.DictReader(f)}
    return keys


def main():
    keys = known_keys()
    out = sys.stdout
    out.write(__doc__.split("\n\n", 1)[1].replace("\n", "\n-- ").join(["-- ", "\n"]))
    out.write("-- Written by tools/reference/poi_spawns_sql.py; edit that, not this.\n--\n")
    spawn_id, lair_id, group_row, attr_id = 901, 6001, 1, 80001
    spawns, templates, groups, lairs, attrs = [], [], [], [], []
    for planet, region, half, mixes in POIS:
        location, planet_id, _ = PLANETS[planet]
        out.write("--   %-9s %-28s %s\n" % (location, region, "; ".join(
            "%d x %s" % (n, ", ".join(k)) for n, k in mixes)))
        spawns.append("SELECT %d, x - %d, z - %d, %d, %d, %d, 1 FROM swganh.planet_regions"
                      " WHERE planet_id = %d AND region_name = %s" % (
                          spawn_id, half, half, 2 * half, 2 * half, planet_id, planet_id, sql_str(region)))
        for count, members in mixes:
            for k in members:
                if k not in keys:
                    raise SystemExit("no template for %s" % k)
            templates.append("  (%d, %s, 'global_outlaw_neutral_none', 'lair_n', '', '')" % (lair_id, sql_str(LAIR_OBJECT)))
            for k in members:
                groups.append("SELECT %d, %d, (SELECT MIN(id) FROM swganh.non_persistent_npcs WHERE family = 8"
                              " AND id >= 3001 AND stf_variable_id = %s)" % (group_row, lair_id, sql_str(k)))
                group_row += 1
            lairs.append("  (%d, %d, 9, 1, %d, %d, %d, 0, 0, 0, 1, 0)" % (lair_id, spawn_id, lair_id, lair_id, count))
            for a, v in (("lair_fix_position", 0), ("lair_at_poi", 1), ("lair_invisible", 1),
                         ("lair_wave_size", WAVE_SIZE), ("lair_passive_waves", PASSIVE_WAVES),
                         ("lair_respawn_delay", 300000), ("lair_creatures_max_spawn_distance", NPC_RANGE),
                         ("lair_creatures_respawn_delay", NPC_RESPAWN_MS), ("creature_xp", 0),
                         ("creature_health", 1000), ("creature_strength", 1000), ("creature_constitution", 1000)):
                attrs.append((attr_id, lair_id, a, v))
                attr_id += 1
            lair_id += 1
        spawn_id += 1
    out.write("--\n\nSET FOREIGN_KEY_CHECKS = 0;\n\n")
    out.write("INSERT IGNORE INTO swganh.attributes (name, internal, attribute_internal_description)\n  VALUES "
              "('lair_at_poi', 1, 'A point of interest''s lair: anywhere in its own area, no no-build or band test'),\n"
              "         ('lair_invisible', 1, 'A lair not shown to players: a spawn point for its creatures');\n\n")
    out.write("-- Each place's spawn area, centred on its position in planet_regions.\n")
    out.write("INSERT IGNORE INTO swganh.spawns (id, spawn_x, spawn_z, spawn_width, spawn_length, spawn_planet, spawn_density)\n  ")
    out.write("\n  UNION ALL ".join(spawns) + ";\n\n")
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
