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
AI_CONSULTANTS_CONFIG_DIR="$TMP/cache-config" CACHE_DIR="$TMP/cache" bash -c '
    set -euo pipefail
    source "$1/lib/common.sh"
    source "$1/lib/cache.sh"
    export ENABLE_SEMANTIC_CACHE=true
    apply_model_tier maximum
    build_synthesis_args claude
    [[ "${SYNTHESIS_ARGS[*]}" == *"--effort max"* ]]
    build_synthesis_args codex "" "$CACHE_DIR/payload"
    [[ "${SYNTHESIS_ARGS[*]}" == *"model_reasoning_effort=max"* ]]
    store_cache "same question" GENERAL claude "{\"response\":{\"summary\":\"maximum answer\"}}"
    check_cache "same question" GENERAL claude >/dev/null
    apply_model_tier standard
    build_synthesis_args claude
    [[ "${SYNTHESIS_ARGS[*]}" == *"--effort medium"* ]]
    CLAUDE_REASONING_EFFORT=low
    build_synthesis_args claude
    [[ "${SYNTHESIS_ARGS[*]}" == *"--effort low"* ]]
    unset CLAUDE_REASONING_EFFORT
    [[ "$CLAUDE_MODEL" == claude-opus-5-5 ]]
    if check_cache "same question" GENERAL claude >/dev/null; then
        echo "standard tier reused a maximum-effort answer" >&2
        exit 1
    fi
' _ "$SCRIPT_DIR"
printf '%s\n' 'AA v5 managed Claude default migrates; an explicit Fable pin survives'
