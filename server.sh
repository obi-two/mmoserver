#!/usr/bin/env bash
#
# Starts, stops and checks the MMOServer processes of a build made with
# build_server.sh. Run with -h for usage.

set -euo pipefail

basedir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

usage() {
    cat <<EOF
Usage: $(basename "$0") [-r] <command> [zone ...]

Commands:
  start [zone ...]   Start the ConnectionServer, LoginServer and PingServer,
                     then the given zones (default: tutorial tatooine)
  stop               Stop every server started by this script
  status             Show which servers are running
  restart [zone ...] stop, then start

Options:
  -r                 Use the release build (build/linux-release)
  -h, --help         Show this help and exit

Each server runs detached from the terminal and logs to bin/logs/<name>.out.
Zones other than tutorial need their heightmap: ./build_server.sh --heightmaps <zone>
EOF
}

preset=linux-debug
if [[ ${1:-} == -r ]]; then
    preset=linux-release
    shift
fi

bin_dir="$basedir/build/$preset/bin"
run_dir="$bin_dir/run"
log_dir="$bin_dir/logs"

# Order matters: the other servers register with the ConnectionServer.
core_servers=(connection login ping)

executable() {
    case "$1" in
        connection) echo ConnectionServer ;;
        login) echo LoginServer ;;
        ping) echo PingServer ;;
        chat) echo ChatServer ;;
        *) echo ZoneServer ;;
    esac
}

pid_of() {
    local pid_file="$run_dir/$1.pid" pid
    [[ -f $pid_file ]] || return 1
    pid=$(<"$pid_file")
    # Only trust the pid if it still belongs to one of our servers.
    if [[ -d /proc/$pid ]] && grep -q "Server" "/proc/$pid/cmdline" 2>/dev/null; then
        echo "$pid"
        return 0
    fi
    rm -f "$pid_file"
    return 1
}

start_one() {
    local name=$1 exe args=() pid
    exe=$(executable "$name")
    [[ $exe == ZoneServer ]] && args=(--ZoneName "$name")

    if pid=$(pid_of "$name"); then
        echo "$name: already running (pid $pid)"
        return
    fi
    if [[ $exe == ZoneServer && $name != tutorial && ! -f $bin_dir/heightmaps/$name.hmpw ]]; then
        echo "$name: skipped, no heightmap (./build_server.sh --heightmaps $name)" >&2
        return
    fi

    # setsid detaches from the terminal; with stdin from /dev/null the
    # server's console command check stays out of the way.
    (cd "$bin_dir" && exec setsid "./$exe" "${args[@]}" < /dev/null > "$log_dir/$name.out" 2>&1) &
    echo $! > "$run_dir/$name.pid"
    echo "$name: started (pid $!, log logs/$name.out)"
}

start() {
    [[ -x $bin_dir/ConnectionServer ]] || { echo "error: no build in $bin_dir (run ./build_server.sh)" >&2; exit 1; }
    [[ -f $bin_dir/config/general.cfg ]] || { echo "error: $bin_dir/config missing (run ./build_server.sh)" >&2; exit 1; }
    mkdir -p "$run_dir" "$log_dir"

    local zones=("$@") name
    [[ ${#zones[@]} -eq 0 ]] && zones=(tutorial tatooine)
    for name in "${zones[@]}"; do
        [[ -f $bin_dir/config/$name.cfg ]] || { echo "error: unknown zone '$name' (no config/$name.cfg)" >&2; exit 1; }
    done

    for name in "${core_servers[@]}" "${zones[@]}"; do
        start_one "$name"
        sleep 2
    done
    echo
    echo "Zones take a minute or two to load. Check with: $(basename "$0") status"
}

stop() {
    local pid_file name pid stopped=()
    for pid_file in "$run_dir"/*.pid; do
        [[ -e $pid_file ]] || continue
        name=$(basename "$pid_file" .pid)
        if pid=$(pid_of "$name"); then
            kill "$pid" 2>/dev/null || true
            stopped+=("$name:$pid")
        fi
    done

    # Give them a few seconds to exit, then force it.
    local entry deadline=$((SECONDS + 10))
    for entry in "${stopped[@]}"; do
        name=${entry%%:*}
        pid=${entry##*:}
        while [[ -d /proc/$pid ]] && (( SECONDS < deadline )); do
            sleep 0.5
        done
        if [[ -d /proc/$pid ]]; then
            kill -KILL "$pid" 2>/dev/null || true
            echo "$name: killed (did not exit in time)"
        else
            echo "$name: stopped"
        fi
        rm -f "$run_dir/$name.pid"
    done
    [[ ${#stopped[@]} -gt 0 ]] || echo "No servers running."
}

status() {
    local pid_file name pid found=
    for pid_file in "$run_dir"/*.pid; do
        [[ -e $pid_file ]] || continue
        name=$(basename "$pid_file" .pid)
        if pid=$(pid_of "$name"); then
            found=1
            printf '%-12s running (pid %s)  %s\n' "$name" "$pid" \
                "$(grep -v '^[[:space:]]*$' "$log_dir/$name.out" 2>/dev/null | tail -n 1)"
        else
            printf '%-12s not running (see logs/%s.out)\n' "$name" "$name"
        fi
    done
    [[ $found ]] || echo "No servers running."

    # The rules themselves are only readable by root, so just remind.
    if grep -qs '^ENABLED=yes' /etc/ufw/ufw.conf; then
        echo
        echo "Note: the ufw firewall is enabled. Game clients on other machines need"
        echo "UDP 44990-44992 open: sudo ufw allow 44990:44992/udp (check: sudo ufw status)"
    fi

    local others
    others=$(pgrep -a -f '/?(Connection|Login|Ping|Chat|Zone)Server( |$)' | grep -v -F -f <(cat "$run_dir"/*.pid 2>/dev/null) || true)
    if [[ $others ]]; then
        echo
        echo "Also running, not started by this script (stop them to avoid port clashes):"
        echo "$others"
    fi
}

case "${1:-}" in
    start) shift; start "$@" ;;
    stop) stop ;;
    status) status ;;
    restart) shift; stop; start "$@" ;;
    -h|--help) usage ;;
    *) usage >&2; exit 2 ;;
esac
