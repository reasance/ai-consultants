#!/bin/bash
# Offline regression for the managed-default boundary introduced by AA v5.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
chmod 700 "$TMP"
unset CLAUDE_MODEL CLAUDE_REASONING_EFFORT
export AI_CONSULTANTS_CONFIG_DIR="$TMP/config"
mkdir -p "$AI_CONSULTANTS_CONFIG_DIR"
printf '%s\n' 'CLAUDE_MODEL=claude-fable-5-1 # ai-consultants:default' > "$AI_CONSULTANTS_CONFIG_DIR/.env"
chmod 600 "$AI_CONSULTANTS_CONFIG_DIR/.env"
bash "$SCRIPT_DIR/configure.sh" --force >/dev/null 2>&1
grep -Eq '^CLAUDE_MODEL=claude-opus-5-5[[:space:]]+# ai-consultants:default' "$AI_CONSULTANTS_CONFIG_DIR/.env"
bash "$SCRIPT_DIR/configure.sh" --force --set CLAUDE_MODEL=claude-fable-5-1 >/dev/null 2>&1
bash "$SCRIPT_DIR/configure.sh" --force >/dev/null 2>&1
grep -Eq '^CLAUDE_MODEL=claude-fable-5-1[[:space:]]+# ai-consultants:pin' "$AI_CONSULTANTS_CONFIG_DIR/.env"
printf '%s\n' 'AA v5 managed Claude default migrates; an explicit Fable pin survives'
