# Known issues

Problems found while running the servers on Linux with a real client
(pre-CU SWGANH client, Ubuntu 26.04 server VM, MariaDB 11.8). Kept here
because Issues are disabled on this fork; move them to GitHub Issues when
they are enabled.

Status: **open**, **fix needs testing** (fixed in code, not yet confirmed
with a client), or **fixed**.

---

## Connection and stability

### 1. Client disconnects 20-30 seconds after entering the tutorial — open

After loading into the tutorial and standing idle, the client is
disconnected. The zone keeps running with the player link-dead.

- In one run the ConnectionServer dropped the tutorial zone's link after 60
  seconds without packets (`Session disconnect last received packet > 60`,
  then `Removing Session(127.0.0.1, 5010)`), taking the client with it.
- In a later run only the client session was removed and re-added; no
  timeout was logged.
- An idle zone with no players stays connected (tested for over 3 minutes),
  so the server-to-server keep-alive works without players.

Next step: capture `logs/connection.out` and `logs/tutorial.out` right after
the disconnect, and compare with the client's own log if it has one.

### 2. Zone crashes when a player reconnects — fix needs testing

Reconnecting while the character is still link-dead crashed the zone in
`SpatialIndexManager::InitializeObject`
(`CharacterLoginHandler::_processSelectCharacter`). On disconnect,
`WorldManager::addDisconnectedPlayer` deletes the player's private tutorial
NPCs with `destroyObject`, which left them behind in two places:

- the spatial grid kept a pointer to the freed NPC (fixed in ed5a637:
  `destroyObject` removes every non-player object from the grid);
- the cell kept the NPC's id, and `BuildingObject::getAllCellChilds`
  returned a null pointer for it (fixed: `destroyObject` removes creatures
  from their cell, and `getAllCellChilds` skips ids that no longer resolve).

### 3. Servers listen on all interfaces — open (security)

`Service.cpp` binds every UDP socket to `INADDR_ANY`, whatever
`BindAddress` says, so the internal cluster ports (ConnectionServer 5000,
zones 50xx) are reachable from the network. Only 44990-44992 should be
public. Until fixed, keep those internal ports closed in the firewall.

## Tutorial and gameplay

### 4. Debris blocking the tutorial path has no Attack option — open

The debris is spawned as an NPC by `data/script/TutorialPart_1_9.lua`
(`createAndSpawnNpc(npcDebrisTypeId, ...)`). Its radial menu only offers
Examine, so the tutorial cannot be completed. Likely the NPC is not sent with
attackable PvP flags, or attack handling rejects it. Combat is the thinnest
system in the code (see `docs/CODE_REVIEW_2026.md`).

### 5. Tutorial NPCs other than the debris do not appear — open

The tutorial script should spawn several private NPCs (officers, trainer,
etc.) as the player progresses, but none are seen in the client. The script
loads without errors. To check: whether `npcSpawnPrivate` reaches the client,
and whether the script advances past the first steps (it waits on client
events in `Tutorial::tutorialResponse`).

## Login

### 6. "Not allowed to create any more characters" after deleting one — open

Create a character, delete it, then try to create another in the same
session: the client refuses when the galaxy is selected. Logging out and in
again works. The server reports the delete as successful and sends the limit
(`account_characters_allowed`, default 2) only at login, so the client is
probably deciding from data cached at login. Possible fix: resend the
character list and cluster status after a delete. Low priority.

## Protocol

### 7. Unhandled client messages — open

| Server | Opcode | Notes |
|---|---|---|
| ZoneServer | 0x6B9E5323 (1805538083) | at zone-in and on reconnect; not defined anywhere in the source |
| ZoneServer | 0x0F5D5325 (257774373) | at zone-in; not defined anywhere in the source |
| ChatServer | 0x48F493C5 (1223988165) | `CmdSceneReady`, routed to chat as well; harmless |

The logs print opcodes in decimal; printing them in hex would make them
easier to match against protocol documentation.

## Data

### 8. Startup data warnings — open

- Tatooine: `Unable to load spawn regions with id: 8` (another path then
  loads `8 Creature Spawn Regions`) and `Unknown group [5]` (an object with a
  category the zone doesn't recognise is skipped).
- `SpawnRegionFactory::requestObject` reads `spawn_regions.mission` with
  `getUInt(9)`, but column 9 of its SELECT is `parent_id` (`mission` is
  column 10). Looks like an off-by-one.

## Cosmetic

### 9. `MessageFactory Heap at <garbage>` log lines — open

Every server prints this with a meaningless number (e.g. `7.27059e+31`);
the value being printed is not initialised or not a heap figure.

---

## Fixed while getting the servers running

For reference; details are in the commit messages on `phase2-db-installer`.

- Collation errors on MariaDB 11.5+ (`Illegal mix of collations`).
- Server config and Lua script file names that only matched on Windows
  (case-insensitive file systems).
- Stack overflow loading Naboo's spawn regions.
- Servers started in the background were stopped by the shell (SIGTTOU).
- ChatServer start-up race that left the galaxy "Loading...".
- A malformed client command (`getattributesbatch`, emotes, mood) crashed
  the zone; commands now fail individually.
- LoginServer crashed after a character was deleted (missing `break`).
- Missing `sp_DeleteMail`; SQL procedures broken by earlier bulk edits.
