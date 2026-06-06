source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set bin_dir "$temp_root/bin"
mkdir -p "$bin_dir"
set open_json "$temp_root/open.json"
set none_json "$temp_root/none.json"

printf '%s\n' \
    '[' \
    '  {"headRefName":"feature/open","state":"MERGED","reviewDecision":null,"labels":[{"name":"old"}],"title":"Old merged","baseRefName":"main","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/1"},' \
    '  {"headRefName":"feature/open","state":"OPEN","reviewDecision":"APPROVED","labels":[{"name":"ready"}],"title":"Open PR","baseRefName":"develop","updatedAt":"2000-01-01T00:00:00Z","url":"https://github.com/example/repo/pull/2"}' \
    ']' \
    > "$open_json"
printf '[]\n' > "$none_json"

printf '%s\n' \
    '#!/bin/sh' \
    'branch=""' \
    'while [ "$#" -gt 0 ]; do' \
    '    if [ "$1" = "--head" ]; then' \
    '        branch="$2"' \
    '        shift 2' \
    '        continue' \
    '    fi' \
    '    shift' \
    'done' \
    'case "$branch" in' \
    "    feature/open) cat '$open_json' ;;" \
    "    feature/none) cat '$none_json' ;;" \
    '    *) echo not-json ;;' \
    'esac' \
    > "$bin_dir/gh"
chmod +x "$bin_dir/gh"

set -gx PATH "$bin_dir" $PATH
set -g CORAL_PR_HISTORY_DAYS 30
set rows (_coral_pr_entries feature/open sha-open feature/none sha-none feature/bad sha-bad)
set sep (printf '\x01')
set open_row
set none_row
for row in $rows
    set parts (string split "$sep" $row)
    if test $parts[1] = feature/open
        set open_row $row
    else if test $parts[1] = feature/none
        set none_row $row
    end
end
set open_parts (string split "$sep" $open_row)
set none_parts (string split "$sep" $none_row)
set none_prefix "feature/none"$sep"sha-none"

@test "PR entries keep open PRs regardless of age" (test "$open_parts[3]" = OPEN -a "$open_parts[4]" = APPROVED -a "$open_parts[6]" = "Open PR"; echo $status) = 0
@test "PR entries cache no-PR rows as misses" (string match -q "$none_prefix*" "$none_row"; echo $status) = 0
@test "PR entries ignore invalid gh JSON" (string match -q "feature/bad*" $rows; echo $status) = 1

rm -rf "$temp_root"
