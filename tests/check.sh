#!/usr/bin/env bash
#
# Run coral's fishtape suite. This is the conventional entry point git-release
# looks for (tests/check.sh) and is also used by the release workflow.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v fish >/dev/null 2>&1; then
    echo "check: fish not found" >&2
    exit 1
fi

# fishtape is a fish function (installed via Fisher); fish autoloads it from
# the function path even non-interactively.
exec fish -c 'fishtape tests/*.test.fish'
