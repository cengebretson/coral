source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set bin_dir "$temp_root/bin"
mkdir -p "$bin_dir"
set response_json "$temp_root/response.json"

printf '%s\n' \
    '{' \
    '  "data": {' \
    '    "repository": {' \
    '      "b1": {' \
    '        "nodes": [' \
    '          {"headRefName":"feature/open","state":"OPEN","reviewDecision":"APPROVED","isDraft":false,"labels":{"nodes":[{"name":"ready"}]},"title":"Open PR","baseRefName":"develop","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/2"},' \
    '          {"headRefName":"feature/open","state":"MERGED","reviewDecision":null,"isDraft":false,"labels":{"nodes":[{"name":"old"}]},"title":"Old merged","baseRefName":"main","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/1"}' \
    '        ]' \
    '      },' \
    '      "b2": {"nodes": []},' \
    '      "b3": {' \
    '        "nodes": [' \
    '          {"headRefName":"feature/closed","state":"CLOSED","reviewDecision":null,"isDraft":false,"labels":{"nodes":[]},"title":"Closed PR","baseRefName":"main","updatedAt":"2026-06-15T00:00:00Z","url":"https://github.com/example/repo/pull/3"}' \
    '        ]' \
    '      },' \
    '      "b4": {' \
    '        "nodes": [' \
    '          {"headRefName":"feature/draft","state":"OPEN","reviewDecision":null,"isDraft":true,"labels":{"nodes":[{"name":"wip"}]},"title":"Draft PR","baseRefName":"develop","updatedAt":"2024-01-02T00:00:00Z","url":"https://github.com/example/repo/pull/4"}' \
    '        ]' \
    '      }' \
    '    }' \
    '  }' \
    '}' \
    > "$response_json"

function coral_write_gh_stub --argument-names dest response_src
    printf '%s\n' \
        '#!/bin/sh' \
        'if [ "$1" = api ] && [ "$2" = graphql ]; then' \
        "    $response_src" \
        'else' \
        '    echo not-json' \
        'fi' \
        > "$dest"
    chmod +x "$dest"
end

set -gx PATH "$bin_dir" $PATH
set -g CORAL_PR_HISTORY_DAYS 30
set sep (printf '\x01')

coral_write_gh_stub "$bin_dir/gh" "cat '$response_json'"
set rows (_coral_pr_entries feature/open sha-open feature/none sha-none feature/closed sha-closed feature/draft sha-draft)

set open_row
set none_row
set closed_row
set draft_row
for row in $rows
    set parts (string split "$sep" $row)
    switch $parts[1]
        case feature/open
            set open_row $row
        case feature/none
            set none_row $row
        case feature/closed
            set closed_row $row
        case feature/draft
            set draft_row $row
    end
end
set open_parts (string split "$sep" $open_row)
set closed_parts (string split "$sep" $closed_row)
set draft_parts (string split "$sep" $draft_row)
set none_prefix "feature/none"$sep"sha-none"

@test "open PR kept regardless of age and wins dedup over merged" (test "$open_parts[3]" = OPEN -a "$open_parts[4]" = APPROVED -a "$open_parts[5]" = false -a "$open_parts[7]" = "Open PR"; echo $status) = 0
@test "recent closed PR for a requested local branch is included" (test "$closed_parts[3]" = CLOSED -a "$closed_parts[7]" = "Closed PR"; echo $status) = 0
@test "draft PR carries draft marker" (test "$draft_parts[3]" = OPEN -a "$draft_parts[5]" = true -a "$draft_parts[6]" = wip -a "$draft_parts[7]" = "Draft PR"; echo $status) = 0
@test "branch with no PR is cached as a 9-field miss" (string match -q "$none_prefix*"(string repeat -n7 "$sep") "$none_row"; echo $status) = 0

coral_write_gh_stub "$bin_dir/gh" "echo not-json"
set fail_rows (_coral_pr_entries feature/open sha-open)
set fail_status $status

@test "gh failure returns nonzero" "$fail_status" = 1
@test "gh failure emits no rows" (count $fail_rows) = 0

rm -rf "$temp_root"
