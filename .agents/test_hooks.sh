#!/bin/bash
# Smoke tests for .agents/hooks/* adapters (Antigravity hook contract).
# Run: bash .agents/test_hooks.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT" || exit 1
FAIL=0

check() {
  # $1 = label, $2 = expected substring, $3 = actual
  if printf '%s' "$3" | grep -qF "$2"; then
    echo "PASS: $1"
  else
    echo "FAIL: $1 — expected [$2], got [$3]"
    FAIL=1
  fi
}

# hooks.json is valid JSON and lists the four hook groups.
python3 -m json.tool .agents/hooks.json >/dev/null && echo "PASS: hooks.json valid" || { echo "FAIL: hooks.json invalid"; FAIL=1; }
for key in studio-session studio-safety-gate studio-post-write studio-stop; do
  grep -q "\"$key\"" .agents/hooks.json && echo "PASS: hooks.json has $key" || { echo "FAIL: hooks.json missing $key"; FAIL=1; }
done

WS="\"workspacePaths\":[\"$ROOT\"]"

# SessionStart emits injectSteps JSON (or {}), never plain text.
OUT=$(echo "{\"conversationId\":\"t\",$WS}" | bash .agents/hooks/session-start.sh)
check "session-start outputs JSON" '"injectSteps"' "$OUT"

# PreToolUse: allow benign, deny dangerous, deny malformed, allow ungated.
OUT=$(echo "{\"toolCall\":{\"name\":\"run_command\",\"args\":{\"CommandLine\":\"ls\"}},$WS}" | bash .agents/hooks/pre-tool-use.sh)
check "pre-tool allow ls" '"decision":"allow"' "$OUT"

OUT=$(echo "{\"toolCall\":{\"name\":\"run_command\",\"args\":{\"CommandLine\":\"rm -rf /tmp/x\"}},$WS}" | bash .agents/hooks/pre-tool-use.sh)
check "pre-tool deny rm -rf" '"decision": "deny"' "$OUT"

OUT=$(echo "{\"toolCall\":{\"name\":\"run_command\",\"args\":{\"CommandLine\":\"git push --force origin main\"}},$WS}" | bash .agents/hooks/pre-tool-use.sh)
check "pre-tool deny force push" '"decision": "deny"' "$OUT"

OUT=$(echo 'not json' | bash .agents/hooks/pre-tool-use.sh)
check "pre-tool deny malformed (fail closed)" 'Malformed hook payload' "$OUT"

OUT=$(echo "{\"toolCall\":{\"name\":\"grep_search\",\"args\":{}},$WS}" | bash .agents/hooks/pre-tool-use.sh)
check "pre-tool allow ungated tool" '"decision":"allow"' "$OUT"

# PostToolUse always {}, Stop always allows stop.
OUT=$(echo "{\"toolCall\":{\"name\":\"write_to_file\",\"args\":{\"TargetFile\":\"/tmp/x\",\"CodeContent\":\"hi\"}},$WS}" | bash .agents/hooks/post-tool-use.sh)
check "post-tool outputs {}" '{}' "$OUT"

OUT=$(echo "{\"fullyIdle\":true,$WS}" | bash .agents/hooks/stop.sh)
check "stop allows stop" '"decision":"stop"' "$OUT"

exit $FAIL
