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
tap_output="$(mktemp)"
trap 'rm -f "${tap_output}"' EXIT

set +e
fish --private -c 'fishtape tests/*.test.fish' 2>&1 | tee "${tap_output}"
fish_status="${PIPESTATUS[0]}"
set -e

if grep -q '^not ok ' "${tap_output}"; then
    exit 1
fi

exit "${fish_status}"
