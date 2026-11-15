#!/bin/bash
# Shared model-family checks; this file only defines functions.
is_carbon_model() {
    local compact
    compact=$(printf '%s' "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]')
    [[ "$compact" == gemini4carbon* ]]
}
