function _coral_pr_entries
    command -q gh; or return 1
    command -q jq; or return 1
    test (count $argv) -gt 1; or return 1

    set -f sep (printf '\x01')
    set -f since (_coral_since_date (_coral_pr_history_days))

    # Unpack the requested branch/sha pairs — the set to produce rows for. The sha
    # is the branch's current local commit, stored so _coral_list can tell a fresh
    # cache row from a stale one without re-querying.
    set -f want_branches
    set -f want_shas
    while test (count $argv) -gt 1
        set -f want_branches $want_branches $argv[1]
        set -f want_shas $want_shas $argv[2]
        set -e argv[1]
        set -e argv[1]
    end

    set -f fields headRefName,state,reviewDecision,labels,title,baseRefName,updatedAt,url

    # Two bulk queries, regardless of how many branches were requested:
    #   1. every open PR — always shown, no age filter
    #   2. all states updated within the history window — recent closed/merged
    # (--state all is honored alongside --search, so query 2 also re-includes
    # recently-touched open PRs; the dedup below collapses the overlap.)
    set -f open_json (gh pr list --state open --limit 200 --json $fields 2>/dev/null)
    set -f recent_json '[]'
    test -n "$since"; and set recent_json (gh pr list --state all \
        --search "updated:>=$since sort:updated-desc" --limit 200 --json $fields 2>/dev/null)

    # Validity gate: a valid array (even []) is a real answer; a non-array means gh
    # errored. If BOTH calls failed, return nothing so _coral_list warns and skips
    # caching — never poison the cache with "no PR" misses during a gh/auth outage.
    set -f open_ok 1
    set -f recent_ok 1
    echo "$open_json" | jq -e 'type == "array"' >/dev/null 2>&1; or set open_ok 0
    echo "$recent_json" | jq -e 'type == "array"' >/dev/null 2>&1; or set recent_ok 0
    test "$open_ok" = 0; and test "$recent_ok" = 0; and return 1
    test "$open_ok" = 0; and set open_json '[]'
    test "$recent_ok" = 0; and set recent_json '[]'

    # Merge both sets, prefer OPEN > MERGED > CLOSED, one row per head branch. jq's
    # sort is stable, so unique_by keeps the highest-priority row per branch. Emits
    # "head SEP state SEP review SEP labels SEP title SEP base SEP url" per line.
    set -f pr_rows (jq -rn --arg sep "$sep" \
        --argjson open "$open_json" --argjson recent "$recent_json" '
        ($open + $recent)
        | sort_by(if .state == "OPEN" then 0 elif .state == "MERGED" then 1 else 2 end)
        | unique_by(.headRefName)[]
        | [.headRefName, .state, (.reviewDecision // ""),
           ([.labels[].name] | join(",")), .title, (.baseRefName // ""), (.url // "")]
        | join($sep)')

    # Index rows by head branch for O(1) lookup.
    set -f pr_keys
    for row in $pr_rows
        set pr_keys $pr_keys (string split -m1 "$sep" -- $row)[1]
    end

    # One 8-field row per requested branch: its PR row (head swapped for the
    # branch+local-sha key), or an empty miss so the branch isn't re-queried until
    # the cache goes stale.
    for idx in (seq (count $want_branches))
        set -f branch $want_branches[$idx]
        set -f sha $want_shas[$idx]
        if set -f j (contains --index -- $branch $pr_keys)
            set -f rest (string split -m1 "$sep" -- $pr_rows[$j])[2]
            printf '%s\n' (string join "$sep" "$branch" "$sha" "$rest")
        else
            printf '%s\n' (string join "$sep" "$branch" "$sha" '' '' '' '' '' '')
        end
    end
end
