#!/bin/bash
# Antigravity Stop adapter for Agent Harness Game Studios.
#
# Antigravity Stop contract: stdout {"decision":"continue","reason":...}
# prevents stopping; any other decision value allows the stop. This
# adapter runs Claude's session-stop.sh for logging, then always allows
# the stop (never traps the agent in a continue loop).
set -u

INPUT=$(cat 2>/dev/null || true)

ROOT=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    paths = json.load(sys.stdin).get('workspacePaths') or []
    print(paths[0] if paths else '')
except Exception:
    print('')
" 2>/dev/null)
[ -n "$ROOT" ] && [ -d "$ROOT/.claude/hooks" ] || ROOT="$PWD"

if [ -f "$ROOT/.claude/hooks/session-stop.sh" ]; then
  (cd "$ROOT" && printf '%s' "$INPUT" | bash .claude/hooks/session-stop.sh >/dev/null 2>&1) || true
fi

printf '{"decision":"stop"}'
exit 0
