#!/bin/bash
# Shared model-family checks; this file only defines functions.
is_carbon_model() {
    local compact
    compact=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    [[ "$compact" == gemini4carbon* ]]
}

is_neon_model() {
    case "${1:-}" in
        gemini-4-neon|gemini-4-neon-low|gemini-4-neon-medium|gemini-4-neon-high|gemini-4-neon-xhigh) return 0 ;;
        *) return 1 ;;
    esac
}

is_pinned_gemini_model() {
    is_carbon_model "${1:-}" || is_neon_model "${1:-}"
}
