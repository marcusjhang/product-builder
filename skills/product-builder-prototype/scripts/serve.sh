#!/usr/bin/env bash
# Serve a prototype directory over HTTP on a free port. Usage: serve.sh <dir> [port] | serve.sh --stop <dir>
set -euo pipefail
if [ "${1:-}" = "--stop" ]; then
  dir="${2:?dir}"; if [ -f "$dir/.serve.pid" ]; then kill "$(cat "$dir/.serve.pid")" 2>/dev/null || true; rm -f "$dir/.serve.pid"; echo "stopped"; else echo "no server pid in $dir"; fi; exit 0
fi
dir="${1:?usage: serve.sh <dir> [port]}"; port="${2:-8765}"
command -v python3 >/dev/null || { echo "python3 not found; install it or run: npx serve $dir" >&2; exit 1; }
while lsof -iTCP:"$port" -sTCP:LISTEN >/dev/null 2>&1; do port=$((port+1)); done
nohup python3 -m http.server "$port" --directory "$dir" >"$dir/.serve.log" 2>&1 &
echo $! > "$dir/.serve.pid"
sleep 0.5
echo "http://127.0.0.1:$port/index.html (pid $(cat "$dir/.serve.pid"); stop with: serve.sh --stop $dir)"
