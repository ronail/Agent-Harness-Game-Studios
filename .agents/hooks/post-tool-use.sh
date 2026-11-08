#!/bin/bash
# Antigravity PostToolUse adapter for Agent Harness Game Studios.
#
# Antigravity PostToolUse cannot gate: stdout must be {}. This adapter
# runs the Claude post-write validators (validate-assets,
# validate-skill-change) for their side effects / diagnostics, then
# always prints {} and exits 0. Their exit-2 feedback has no equivalent
# here — PreToolUse (pre-tool-use.sh) carries the gating.
set -u

INPUT=$(cat 2>/dev/null || true)

PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print('||'); sys.exit(0)
tc = d.get('toolCall') or {}
name = tc.get('name') or ''
args = tc.get('args') or {}
paths = d.get('workspacePaths') or []
root = paths[0] if paths else ''
if name in ('write_to_file', 'replace_file_content', 'multi_replace_file_content'):
    print('Write|' + (args.get('TargetFile') or '') + '|' + root)
else:
    print('||')
" 2>/dev/null)

TOOL=$(printf '%s' "$PARSED" | cut -d'|' -f1)
TARGET=$(printf '%s' "$PARSED" | cut -d'|' -f2)
ROOT=$(printf '%s' "$PARSED" | cut -d'|' -f3)

if [ -n "$TOOL" ] && [ -n "$ROOT" ] && [ -d "$ROOT/.claude/hooks" ]; then
  cd "$ROOT" || true
  CLAUDE_INPUT=$(python3 -c "
import sys, json
print(json.dumps({'tool_name': 'Write', 'tool_input': {'file_path': sys.argv[1], 'content': ''}}))
" "$TARGET" 2>/dev/null)
  if [ -n "$CLAUDE_INPUT" ]; then
    for script in .claude/hooks/validate-assets.sh .claude/hooks/validate-skill-change.sh; do
      [ -f "$script" ] || continue
      printf '%s' "$CLAUDE_INPUT" | bash "$script" >/dev/null 2>&1 || true
    done
  fi
fi

# PostToolUse contract: empty JSON object, always.
printf '{}'
exit 0
