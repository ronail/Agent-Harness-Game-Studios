#!/bin/bash
# Antigravity PreToolUse adapter for Agent Harness Game Studios.
#
# Antigravity contract: stdin = JSON {toolCall:{name,args}, workspacePaths};
# stdout MUST be JSON {"decision":"allow"|"deny"|"ask","reason":...}.
# Empty/malformed stdout FAILS CLOSED (blocks the tool) on agy 1.4.x, so
# this script always prints exactly one JSON decision and exits 0.
#
# Claude hooks use a different contract (stdin {tool_name,tool_input},
# exit 2 = block, no stdout), so this adapter translates both ways:
#   run_command                -> Bash  {command: CommandLine}
#   write_to_file              -> Write {file_path: TargetFile, content: CodeContent}
#   replace_file_content       -> Edit  {file_path: TargetFile, ...}
#   multi_replace_file_content -> Edit  {file_path: TargetFile, ...}
#   view_file / read tools     -> Read  {file_path: AbsolutePath}
# and maps exit 2 + stderr to {"decision":"deny","reason":stderr}.
set -u

INPUT=$(cat 2>/dev/null || true)

# Parse Antigravity payload with python3 (stdlib only, no jq dependency).
PARSED=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
except Exception:
    print('MALFORMED||'); sys.exit(0)
tc = d.get('toolCall') or {}
name = tc.get('name') or ''
args = tc.get('args') or {}
paths = d.get('workspacePaths') or []
root = paths[0] if paths else ''
if name == 'run_command':
    print('Bash|' + (args.get('CommandLine') or '') + '|' + (args.get('Cwd') or root))
elif name in ('write_to_file', 'replace_file_content', 'multi_replace_file_content'):
    tool = 'Write' if name == 'write_to_file' else 'Edit'
    content = args.get('CodeContent') or args.get('ReplacementContent') or ''
    print(tool + '|' + (args.get('TargetFile') or '') + '|' + root + '|' + content.replace(chr(10), '\\\\n'))
elif name == 'view_file':
    print('Read|' + (args.get('AbsolutePath') or '') + '|' + root)
else:
    print('|||')
" 2>/dev/null)

TOOL=$(printf '%s' "$PARSED" | cut -d'|' -f1)
ARG1=$(printf '%s' "$PARSED" | cut -d'|' -f2)
CWD=$(printf '%s' "$PARSED" | cut -d'|' -f3)
CONTENT=$(printf '%s' "$PARSED" | cut -d'|' -f4)

allow() { printf '{"decision":"allow"}'; exit 0; }
deny() {
  REASON=$(printf '%s' "$1" | head -c 500)
  printf '%s' "$REASON" | python3 -c "
import sys, json
r = sys.stdin.read().strip() or 'Blocked by project hook'
print(json.dumps({'decision': 'deny', 'reason': r}))
" 2>/dev/null || printf '{"decision":"deny","reason":"Blocked by project hook"}'
  exit 0
}

# Nothing we gate -> allow (explicit decision, never empty).
# Malformed input fails closed, matching Antigravity's own policy:
# an unparseable payload must not silently allow a tool call.
[ "$TOOL" = "MALFORMED" ] && deny "Malformed hook payload"
[ -z "$TOOL" ] && allow

ROOT="${CWD:-$PWD}"
[ -f "$ROOT/.claude/hooks/validate-commit.sh" ] || ROOT="$PWD"
[ -d "$ROOT/.claude/hooks" ] || allow
cd "$ROOT" || allow

# Build the Claude-format payload for the downstream scripts.
CLAUDE_INPUT=$(python3 -c "
import sys, json
tool, arg1 = sys.argv[1], sys.argv[2]
if tool == 'Bash':
    print(json.dumps({'tool_name': 'Bash', 'tool_input': {'command': arg1}, 'cwd': sys.argv[3]}))
elif tool in ('Write', 'Edit'):
    print(json.dumps({'tool_name': tool, 'tool_input': {'file_path': arg1, 'content': sys.argv[4]}}))
elif tool == 'Read':
    print(json.dumps({'tool_name': 'Read', 'tool_input': {'file_path': arg1}}))
else:
    print('{}')
" "$TOOL" "$ARG1" "$ROOT" "$CONTENT" 2>/dev/null)
[ -n "$CLAUDE_INPUT" ] || allow

run_hook() {
  # $1 = script path; returns script exit code, stderr captured to $HOOK_ERR
  HOOK_ERR=$(printf '%s' "$CLAUDE_INPUT" | bash "$1" 2>&1 >/dev/null)
  return $?
}

case "$TOOL" in
  Bash)
    for script in .codex/hooks/guard-command.sh .claude/hooks/validate-commit.sh .claude/hooks/validate-push.sh; do
      [ -f "$script" ] || continue
      run_hook "$script"
      [ $? -eq 2 ] && deny "$HOOK_ERR"
    done
    ;;
  Write|Edit)
    for script in .claude/hooks/validate-registry.sh .claude/hooks/validate-write.sh; do
      [ -f "$script" ] || continue
      run_hook "$script"
      [ $? -eq 2 ] && deny "$HOOK_ERR"
    done
    ;;
  Read)
    [ -f .claude/hooks/validate-read.sh ] || allow
    run_hook .claude/hooks/validate-read.sh
    [ $? -eq 2 ] && deny "$HOOK_ERR"
    ;;
esac

allow
