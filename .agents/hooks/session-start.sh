#!/bin/bash
# Antigravity SessionStart adapter for Agent Harness Game Studios.
#
# Antigravity contract: stdin = JSON with workspacePaths; stdout = JSON
# {"injectSteps": [...]} or {}. Claude's session-start.sh + detect-gaps.sh
# emit plain-text observations, so this wrapper captures their output and
# re-emits it as an ephemeralMessage. If the workspace is missing or the
# scripts produce nothing, emit {} (valid, no injection). Never fail:
# a crashing SessionStart hook must not block the session.
set -u

INPUT=$(cat 2>/dev/null || true)

# Workspace: first workspacePaths entry, else cwd if it looks like a root.
ROOT=""
if command -v python3 >/dev/null 2>&1; then
  ROOT=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    paths = json.load(sys.stdin).get('workspacePaths') or []
    print(paths[0] if paths else '')
except Exception:
    print('')
" 2>/dev/null)
fi
[ -n "$ROOT" ] && [ -d "$ROOT" ] || ROOT="$PWD"
[ -d "$ROOT/.claude/hooks" ] || { printf '{}'; exit 0; }

cd "$ROOT" || { printf '{}'; exit 0; }

OUT=""
for script in .claude/hooks/session-start.sh .claude/hooks/detect-gaps.sh; do
  [ -x "$script" ] || [ -f "$script" ] || continue
  # Claude hooks read JSON on stdin; give them an empty object.
  TEXT=$(printf '{}' | bash "$script" 2>/dev/null || true)
  [ -n "$TEXT" ] && OUT="${OUT}${TEXT}"$'\n'
done

[ -z "$OUT" ] && { printf '{}'; exit 0; }

# Emit as a single ephemeralMessage step, JSON-escaped via python3.
printf '%s' "$OUT" | python3 -c "
import sys, json
text = sys.stdin.read().strip()
if not text:
    print('{}')
else:
    print(json.dumps({'injectSteps': [{'ephemeralMessage': text}]}))
" 2>/dev/null || printf '{}'
exit 0
