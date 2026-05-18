#!/usr/bin/env bash
# agentFlow Harness Dashboard Launcher — Codex Edition
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DASHBOARD="$SCRIPT_DIR/harness-dashboard.html"

EVENTS_FILE="${1:-}"
if [ -z "$EVENTS_FILE" ]; then
    EVENTS_FILE=$(find . -name "events.jsonl" -type f -not -path "*/node_modules/*" 2>/dev/null | sort -r | head -1)
fi

echo "[agentFlow:Codex] Opening dashboard: $DASHBOARD"

case "$(uname -s)" in
    Linux*)  xdg-open "$DASHBOARD" 2>/dev/null || open "$DASHBOARD" 2>/dev/null || echo "Please open $DASHBOARD manually" ;;
    Darwin*) open "$DASHBOARD" ;;
    CYGWIN*|MINGW*|MSYS*) start "$DASHBOARD" ;;
    *)       echo "Please open $DASHBOARD manually" ;;
esac
