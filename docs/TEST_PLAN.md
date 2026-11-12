# Test plan

Client tests for everything fixed so far, so each fix is confirmed with a
real client before moving on to the Windows build. Details of each issue are
in `docs/KNOWN_ISSUES.md` (numbers in brackets).

**Status:** ✅ confirmed with a client · 🧪 to test · ⚙️ server-side
check only (no client test needed).

## Before testing

```bash
cd ~/mmoserver && ./server.sh stop && git pull && ./build_server.sh
```
```bash
sudo ./mmoserverdb/setup.sh update-procedures
```
```bash
./server.sh debug -g
```

Logs are in `~/mmoserver/build/linux-debug/bin/logs/<server>.out`. If a
server crashes, gdb stops it and the backtrace is at the end of its log.

## To test

| # | Area | What was wrong | How to test | Expect |
|---|---|---|---|---|
| T3 | Login | Refusals were silent [6] | If anything is refused at the galaxy screen | `connection.out` has a `Refusing account N: <reason>` line; send it to me |
| T4 | Script events | New | `sudo ./mmoserverdb/setup.sh update`, then on Tatooine: log in, walk into Mos Eisley, talk to an NPC and pick an option, use a radial menu item, kill a creature, log out. Watch `tail -f tatooine.out \| grep 'event:'` | one `event:` line per action, with the player's id as `source` |
| T5 | Scripts | `print` output was lost [15] | Start Tatooine | `tatooine.out` has `[script] WeatherController v.0.2` and `[script] event_logger: listening to 9 events` |
| T12 | Combat | Incaps all lasted 30 s | Get incapacitated twice within 10 minutes | The first incap lasts 30 s, the second 60 s, the third kills; `tatooine.out`: `incapacitated (N in the window) for S s` |
| T13 | Combat | Taunt never switched a creature's target | With a second player fighting a creature, Taunt it | The creature turns on the taunter; `tatooine.out`: `Creature ... taunted by ...` |
| T14 | Creatures | Lairs never spawned [5j] | Wait 3-6 minutes after Tatooine starts, then visit a lair region (about -2200,-4700 to -1500,-3950) | Lairs with creatures; `tatooine.out`: `Lair ... spawned` |
| T15 | Combat | Still in combat after the opponent dies [5i] | Kill a creature that was your only opponent | Combat music and state end without `/peace` |
| T16 | Creatures | Stats from the creature tables (migration 011) | `sudo ./mmoserverdb/setup.sh update`, then near Bestine walk up to womp rats and rills | They no longer attack on sight; attacked, they fight back; womp rats hit less often than before (28%) |
| T17 | Creatures | No pack assist | Attack one womp rat with others nearby | The other womp rats join; `tatooine.out`: `assists its pack against` |
| T21 | Security | Internal ports open to the network [3] | Restart all servers, then `sudo ss -ulnp \| grep -E "Server\|44990\|5000"` | 44990-44992 on 0.0.0.0, 5000, the zones' and chat's ports on 127.0.0.1; the Windows client still logs in and plays |
| T22 | Security | Unknown usernames created accounts [3a] | `sudo ./mmoserverdb/setup.sh update`, restart, then log in with a name that has no account | Refused like a wrong password; `login.out`: `Unknown usernames are refused`; existing accounts log in |
| T18 | Creatures | No killers | Get incapacitated by a killer (none spawn on Tatooine yet; for now check that a womp rat leaves you incapacitated) | A womp rat does not deathblow; `deathblows` appears only for creatures marked Killer |

## Confirmed

| Area | What was wrong | Confirmed by |
|---|---|---|
| Mail | No welcome mail; empty bodies; lost attachments [22] | New character on the VM: the welcome and profession mails arrive with their full text; a mail with a waypoint attached arrives with it (Nov 2026) |
| Tutorial | Parts 3-9: refusals, the oath, the grenade [19, 21] | Raced through on the VM: weapon, documents and Quartermaster first time, the oath, the bandit killed by his own grenade (Nov 2026). Still in combat after his death [5i] |
| Tutorial | Racing ahead got parts 1-2 stuck [21] | New character raced through rooms 1-2 (chat, zoom, drum, food before the prompts) and on to the end of the tutorial, Nov 2026 |
| Regions | Cities never matched on the server [16] | Walked in and out of Bestine on the VM: `region_entered` / `region_left` logged with the client's "You have entered/left Bestine" (Nov 2026) |
| Regions | Badge areas never matched [16] | Walked to the Lars homestead on the VM: badge "Location: Lars Homestead" awarded (Nov 2026) |
| Install | Database install, collation errors on MariaDB 11.5+ | Installed on the Ubuntu 26.04 VM with MariaDB 11.8 |
| Install | No resources on a fresh install [5a] | Survey found resources after `spawn-resources` |
| Install | Stored procedures could not be reloaded | `update-procedures` installed the rotation procedure on the VM |
| Launcher | `server.sh debug -g` stopped at gdb's debuginfod prompt | Servers run under gdb in tmux |
| Galaxy | Galaxy stuck on "Loading..." (ChatServer race) | Galaxy online |
| Login | LoginServer crashed after a character was deleted | Deletes work |
| Login | Quick reconnect after killing the client refused, at login and at the galaxy [6] (T2) | Killed the client at profession selection, logged straight back in and created a character; `connection.out`: `Account 31 connected again; replacing its previous connection`; no `Login failed` |
| Login | Characters with a surname couldn't be deleted (T4) | `delete First Last` on the fixed build |
| Login | No character creation after a delete until logging in again [6] (T1) | Deleted and created twice without logging out; both loaded into Tatooine |
| Login | Characters with a surname couldn't be deleted | Typing the hidden trailing space deleted one (diagnosis); see T4 for the fixed build |
| Stability | Zone crash on reconnect [2] | Disconnect and reconnect, no crash |
| Stability | Character switching after a disconnect hung [2c] | New character transferred to Tatooine |
| Stability | Servers crashed after a long idle period [2d] | Overnight: ConnectionServer 9, Tatooine 16, tutorial 6 reconnects, all running |
| Stability | Idle client never cleaned up | `Player left` after the client timed out overnight |
| Tutorial | Skipping the tutorial crashed zones (garbled starting city) | Skipped to Tatooine |
| Tutorial | NPCs inside buildings invisible [5, 5b-2] | NPCs in every room, item room officer visible |
| Tutorial | "Out of range" talking to any NPC indoors | Conversations work |
| Tutorial | Crash at the item room drum ("open me" fly text) | Got past the item room |
| Tutorial | Debris had no Attack option, and stayed after dying [4] | Debris attackable and destroyed |
| Tutorial | Bandit never spawned [5f]; killed creatures stayed standing | Bandit fights, collapses when killed, XP awarded |
| Tutorial | Ending (Quartermaster, travel terminal) | Travelled to Tatooine from the end of the tutorial |
| Resources | Survey and sample | Resources found, samples taken at good concentrations |
| Resources | Resources never rotated [5b] | Expired resource replaced while running (`Replaced 1 expired resources`) |
| World | Tatooine NPCs | Patrol NPCs around Bestine |
| World | Killed creatures stayed on screen (T6) | The bandit's corpse disappeared after a few minutes |
| Tutorial | Looting the bandit; Loot all locked up the zone [10] (T5) | Loot shows the corpse's items and they can be taken; the zone stays responsive and near 120 MB. Still in combat afterwards: see KNOWN_ISSUES 5i (`/peace` works around it) |
| Resources | A sample continued after its resource expired (T8) | Expired by hand while sampling: gone from the survey list, sampling stopped |
| Text | Client text garbled on Linux [2a] (T9) | Chat with punctuation and numbers |
| Stability | Early disconnect in the tutorial [1] (T10) | Idle in the tutorial, still connected and loaded |
| Stability | Out-of-memory kill of the tutorial zone [10] | Reproduced with heaptrack: Loot all on the bandit's corpse; fixed, see T5 |
| Travel | Tickets to "Nym's Stronghold" never created [5k]; boarding a cross-planet shuttle did nothing [5l] | Bought a Bestine Starport to Nym's Stronghold ticket and landed on Lok |
| Stability | Overnight run with a player (T11) | Character logged in on Lok overnight with tutorial, Tatooine and Lok zones under gdb: all seven servers running in the morning, the player still in Lok's saves, no crash, zone memory flat at its fresh size (tutorial 106 MB, Tatooine 274 MB, Lok 239 MB) |
| Windows | Native build | Windows 11, Visual Studio 2022 (MSVC 14.44): `build_server.ps1 -Test` built everything with vcpkg, 134/134 tests pass |
| Windows | Servers on Windows | All servers started with `server.ps1` against the database on the Linux VM; logged in and played in Bestine on Tatooine (after fixing the grid crash, KNOWN_ISSUES #11) |
| Linux | No regression from the Windows changes | `windows-dev-env` built and played on the Ubuntu VM |
| Stability | Idle memory | 22 hours with no client: every server at its fresh size (tutorial 116 MB, Tatooine 274 MB, ConnectionServer 137 MB), heaptrack peaks only startup allocations |
| Creatures | Creatures never fought back, roamed or aggroed [5f] | Womp rats near Bestine attack on sight, fight back and change stance under Unarmed Lunge (Nov 2026) |
| Death | A cloned player stayed a corpse [24] | Killed and cloned in Bestine: standing, full HAM (Nov 2026) |
| Combat | No wounds or battle fatigue | The character sheet shows wounds and battle fatigue after fights (Nov 2026) |
| Combat | Brawler moves did nothing | Intimidate, Warcry and Taunt roll and report; Berserk and Center of Being start and wear off (`Brawler move`, `Self buff` in the log, Nov 2026) |
| Combat | No bleeding | Wounds bleed on players and creatures, on health, action and mind, and stop after 30 s; First Aid stops a bleed (`Bleeding ...` in the log, Nov 2026) |
| Healing | Entertainers never healed; medic skill mods ignored [25] | A dancer in a Bestine cantina healed a watcher's mind wounds and battle fatigue; `/tendwound` healed health and action wounds (Nov 2026) |

## Not implemented yet

| Test | Why |
|---|---|
| Scout harvesting of corpses | Not implemented [23]; waits on the creature tables |

## Known open issues (not tested)

Tracked in `docs/KNOWN_ISSUES.md`; not expected to pass yet:
positions inside buildings
mirrored [5c], low sampling yield at low concentration [5d], tutorial
prompts lagging behind [5e], no debris explosion [5g], unhandled opcodes
[7], startup data warnings [8], garbage "MessageFactory Heap" log lines
[9]. Killer creatures, pack assist and creature stats wait on the creature
tables (`docs/COMBAT.md`).

## Recording results

Tell me the T number and what happened. For a failure, the end of the
relevant log helps most:

```bash
tail -n 60 ~/mmoserver/build/linux-debug/bin/logs/<server>.out
```
