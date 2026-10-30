# Roadmap

Where the revival of MMOServer (pre-CU SWG server) stands and where it is
going. It extends the plan in section 6 of `docs/CODE_REVIEW_2026.md`; open
bugs are in `docs/KNOWN_ISSUES.md`, and the scripting plan is in
`docs/SCRIPTING.md`.

## Vision

- **Communities run Linux** dedicated servers: one machine (or VM) with
  MariaDB and the servers, set up with `build_server.sh`,
  `mmoserverdb/setup.sh` and `server.sh`.
- **Developers work on Windows**, building and debugging the servers in
  Visual Studio against a database on a Linux VM or a remote host.
- **The C++ core provides mechanics; content lives in Lua scripts** that
  can be changed without rebuilding (`docs/SCRIPTING.md`). Everything stays
  GPL.
- **Tools for the people running a server**: a management portal for
  admins, QA and community leaders, and a load-testing tool to know how many
  players a server can take.

## Content sources

Pre-CU content (creature spawns, NPCs, quests, the tutorial) is recreated
from the client's own files (datatables, string files, object templates,
sounds) and from public material from the time: player guides, creature
databases, wiki pages, recordings. The leaked SOE server source is not used,
for reference or otherwise: it was never licensed, and anything derived from
it puts the project and every community hosting it at legal risk.

## Status

Tested end to end on Ubuntu 26.04 with MariaDB 11.8 and a real client:
galaxy online, account login, character creation, the full tutorial to
Tatooine, tutorial skip, character switching after a disconnect, surveying
and sampling. Long idle runs recover from database connection timeouts.
Resource rotation is tested on the server only so far.

| Phase | State |
|---|---|
| 1. Reproducible build | Linux done (merged). Windows build still to do |
| 2. Runnable server | Installer, launcher and many runtime fixes done (PR #2 on the fork); security and remote database access to do |
| 3. Modernisation and robustness | Not started |
| 4. Scripting and content | Planned (`docs/SCRIPTING.md`) |
| 5. Pre-CU gameplay | Not started |
| Tools: portal, load testing | Planned (below) |

## Phase 1: reproducible build

Done for Linux: CMake with imported targets, presets, vcpkg manifest with
Lua 5.1 and tolua++ overlay ports, `build_server.sh`, verified heightmap
downloads, CI on Ubuntu 24.04 and 26.04 plus the vcpkg route.

**Remaining: Windows.**
- `windows-x64` debug and release presets using vcpkg (the manifest and
  overlay ports are already platform-neutral).
- Rewrite `build_server.bat` as a thin wrapper like `build_server.sh`;
  remove `deps/build_deps.bat` and `tools/windows/postbuild.bat`.
- Heightmaps with `curl.exe` and the same SHA-256 checks.
- A Windows job in CI.
- `server.ps1` (or the existing `.bat` launchers updated) to start and stop
  the servers like `server.sh`.

## Phase 2: runnable server for a community

Done: `mmoserverdb/setup.sh` (install, accounts, galaxy address, resource
spawning, reloading procedures), SQL repairs, `server.sh` (start, stop,
status, debug sessions in tmux with gdb), and the runtime fixes listed in
`docs/KNOWN_ISSUES.md`.

Remaining:
- **Remote database access** for the Windows development setup:
  `setup.sh allow-host <address>` to create the `swganh` user for one
  development machine and print the MariaDB `bind-address` change. Never
  open the database port to the internet; document an SSH tunnel as the
  alternative.
- **Security** (code review section 4, before any public server):
  bounds-checked `Message` reads; player text out of fixed SQL buffers and
  into prepared statements; hashed passwords (Argon2id or bcrypt) with
  re-hash on next login; servers binding only to `BindAddress` instead of
  every interface (`KNOWN_ISSUES.md` #3).
- **Docker Compose** stack (MariaDB plus servers) as an alternative to the
  manual install.
- **Operations**: database backup and restore commands in `setup.sh`, log
  rotation, and running the servers as systemd services for unattended
  servers.

## Phase 3: modernisation and robustness

Once Linux and Windows both build:
- **Dependency upgrades**: current Boost, oneTBB, Connector/C++; replace
  `boost::thread`/`mutex`/`future` with `std::`. Lua stays 5.1.
- **Warnings to zero** with `-Wall -Wextra` / `/W4`, and ASan/UBSan builds
  in CI.
- **Tests**: a ZoneServer unit test target (its `main` lives in
  `ZoneServer.cpp`, which the test layout expects in `main.cpp`), tests for
  the mechanics fixed during testing (health and death, posture, spawning,
  visibility), and a fuzz harness for `Message` parsing.
- **Refactoring where the bugs were**: object creation and destruction
  sent to clients, the spatial grid (its bucket maths has negative-coordinate
  and size quirks; positions inside buildings are mirrored), the database
  layer (prepared statements throughout), and creature AI (largely
  missing).

## Phase 4: scripting and content

See `docs/SCRIPTING.md`: inventory of what is in Lua versus C++, event
hooks instead of polling, a small documented script API, the tutorial moved
onto it, and bindings that build on both platforms. Then content research
for pre-CU creature spawns, lairs, NPCs and quests from the sources above,
written as scripts and data.

## Phase 5: pre-CU gameplay

From the code review: combat first (the heart of pre-CU and thin today),
then factions and the GCW, loot, guilds, vendors and the bazaar, vehicles
and pets, then Jedi. Crafting and the entertainer systems show what a
complete system looks like in this codebase.

## Tools

### Management portal

For admins, QA and community leaders; a web application, reachable only
from trusted networks or behind a login, never open by default.

- **Read and edit data** (works against the database directly): accounts
  (create, ban, reset password, permissions), characters (find, inspect,
  move, restore), galaxy settings (address, lock to staff, settings now in
  `config_server` such as the resource rotation interval), resources
  (current spawn, force a rotation).
- **Live server control** (needs an admin channel into the running
  servers): status and players per zone, broadcast messages, kick, shut down
  with a countdown, reload scripts. The servers have no such channel today
  beyond console keys (`q` to quit, `l` to lock the galaxy in the
  ConnectionServer). Options: a small authenticated HTTP/JSON endpoint on
  the ConnectionServer bound to localhost, or an admin message type on the
  existing cluster protocol relayed by a portal backend.
- **QA helpers**: issue reports from in game (with position and
  character), test-character presets, and server metrics (below).
- Existing in-game admin and CSR commands should be inventoried first; the
  portal can reuse what they already do.

### Load and stress testing

- A **headless bot client** that speaks the SWG protocol: session setup,
  login, galaxy and character selection, zoning in, then scripted
  behaviour (move, chat, travel, fight, log out and back in). The servers'
  own `NetworkManager` implements the protocol, so building the bot on it is
  the quickest route.
- Run hundreds of bots from another machine, ramping up, to find limits
  per zone and per galaxy.
- **Server-side metrics** to read alongside: players per zone, zone tick
  duration, database job queue depth, message queue sizes, memory. Exposed
  in the logs first, then in the portal.
- The same bots make **regression tests** for the bugs found in manual
  testing: reconnect and character switching, link-dead cleanup, zone
  transfers, idle disconnects.
