source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set bin_dir "$temp_root/bin"
mkdir -p "$bin_dir"
set open_json "$temp_root/open.json"
set recent_json "$temp_root/recent.json"

# Open set: the always-shown PRs (gh --state open). feature/open is OPEN here with
# an ancient updatedAt — it must survive regardless of the history window.
printf '%s\n' \
    '[' \
    '  {"headRefName":"feature/open","state":"OPEN","reviewDecision":"APPROVED","labels":[{"name":"ready"}],"title":"Open PR","baseRefName":"develop","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/2"}' \
    ']' \
    > "$open_json"

# Recent set: all states updated within the window (gh --state all --search). It
# also re-lists feature/open as an old MERGED PR; the dedup must prefer the OPEN
# row from the open set. feature/closed is only here.
printf '%s\n' \
    '[' \
    '  {"headRefName":"feature/open","state":"MERGED","reviewDecision":null,"labels":[{"name":"old"}],"title":"Old merged","baseRefName":"main","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/1"},' \
    '  {"headRefName":"feature/closed","state":"CLOSED","reviewDecision":null,"labels":[],"title":"Closed PR","baseRefName":"main","updatedAt":"2024-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/3"}' \
    ']' \
    > "$recent_json"

# Stub gh, dispatching on the two bulk shapes instead of per-branch --head:
#   --search ...      -> recent set
#   --state open ...  -> open set
function coral_write_gh_stub --argument-names dest open_src recent_src
    printf '%s\n' \
        '#!/bin/sh' \
        'state=""; search=""' \
        'while [ "$#" -gt 0 ]; do' \
        '    case "$1" in' \
        '        --state) state="$2"; shift 2; continue ;;' \
        '        --search) search="$2"; shift 2; continue ;;' \
        '    esac' \
        '    shift' \
        'done' \
        'if [ -n "$search" ]; then' \
        "    $recent_src" \
        'elif [ "$state" = open ]; then' \
        "    $open_src" \
        'else' \
        '    echo not-json' \
        'fi' \
        > "$dest"
    chmod +x "$dest"
end

set -gx PATH "$bin_dir" $PATH
set -g CORAL_PR_HISTORY_DAYS 30
set sep (printf '\x01')

# --- Happy path: both bulk calls succeed -------------------------------------
coral_write_gh_stub "$bin_dir/gh" "cat '$open_json'" "cat '$recent_json'"
set rows (_coral_pr_entries feature/open sha-open feature/none sha-none feature/closed sha-closed)

set open_row
set none_row
set closed_row
for row in $rows
    set parts (string split "$sep" $row)
    switch $parts[1]
        case feature/open
            set open_row $row
        case feature/none
            set none_row $row
        case feature/closed
            set closed_row $row
    end
end
set open_parts (string split "$sep" $open_row)
set closed_parts (string split "$sep" $closed_row)
set none_prefix "feature/none"$sep"sha-none"

@test "open PR kept regardless of age and wins dedup over merged" (test "$open_parts[3]" = OPEN -a "$open_parts[4]" = APPROVED -a "$open_parts[6]" = "Open PR"; echo $status) = 0
@test "recent closed PR from the search query is included" (test "$closed_parts[3]" = CLOSED -a "$closed_parts[6]" = "Closed PR"; echo $status) = 0
@test "branch with no PR is cached as an 8-field miss" (string match -q "$none_prefix*"(string repeat -n6 "$sep") "$none_row"; echo $status) = 0

# --- Partial failure: search call errors, open call still resolves ------------
coral_write_gh_stub "$bin_dir/gh" "cat '$open_json'" "echo not-json"
set partial_rows (_coral_pr_entries feature/open sha-open feature/closed sha-closed)
set partial_status $status
set partial_open
for row in $partial_rows
    set parts (string split "$sep" $row)
    test "$parts[1]" = feature/open; and set partial_open $row
end
set partial_open_parts (string split "$sep" $partial_open)

@test "partial failure still returns rows" "$partial_status" = 0
@test "partial failure resolves branches from the surviving call" "$partial_open_parts[3]" = OPEN

# --- Total failure: both calls error -> no rows, nonzero (don't poison cache) -
coral_write_gh_stub "$bin_dir/gh" "echo not-json" "echo not-json"
set fail_rows (_coral_pr_entries feature/open sha-open)
set fail_status $status

@test "total gh failure returns nonzero" "$fail_status" = 1
@test "total gh failure emits no rows" (count $fail_rows) = 0

rm -rf "$temp_root"
