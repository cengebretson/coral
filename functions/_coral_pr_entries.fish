function _coral_pr_entries
    command -q gh; or return 1
    command -q jq; or return 1
    test (count $argv) -gt 1; or return 1

    set -f sep (printf '\x01')
    set -f since (_coral_since_date (_coral_pr_history_days))
    set -f origin (git remote get-url origin 2>/dev/null)
    set -f repo_path (string replace -r '^git@github\.com:' '' -- "$origin" | string replace -r '^https?://github\.com/' '' | string replace -r '\.git$' '')
    set -f repo_parts (string split / -- "$repo_path")
    test (count $repo_parts) -ge 2; or return 1
    set -f owner $repo_parts[1]
    set -f repo $repo_parts[2]

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

    set -f query_fields
    for idx in (seq (count $want_branches))
        set -f branch_json (printf '%s' "$want_branches[$idx]" | jq -Rs .)
        set query_fields $query_fields "b$idx: pullRequests(headRefName: $branch_json, first: 5, states: [OPEN, MERGED, CLOSED], orderBy: {field: UPDATED_AT, direction: DESC}) { nodes { headRefName state reviewDecision isDraft title baseRefName updatedAt url labels(first: 20) { nodes { name } } } }"
    end

    set -f query "query(\$owner: String!, \$repo: String!) { repository(owner: \$owner, name: \$repo) { "(string join ' ' $query_fields)" } }"
    set -f pr_json (gh api graphql -f owner="$owner" -f repo="$repo" -f query="$query" 2>/dev/null)
    echo "$pr_json" | jq -e '.data.repository | type == "object"' >/dev/null 2>&1; or return 1

    # For each requested local branch, use only PRs for that branch. Open PRs are
    # always eligible; merged/closed PRs are eligible only inside the history window.
    # Prefer OPEN > MERGED > CLOSED, then newest updatedAt.
    set -f pr_rows (printf '%s\n' "$pr_json" | jq -r --arg sep "$sep" --arg since "$since" '
        [
          .data.repository
          | to_entries[]
          | .value.nodes[]
          | select(.state == "OPEN" or ($since != "" and (.updatedAt[0:10] >= $since)))
        ]
        | group_by(.headRefName)[]
        | sort_by(
            if .state == "OPEN" then 0 elif .state == "MERGED" then 1 else 2 end,
            -((.updatedAt // "1970-01-01T00:00:00Z") | fromdateiso8601)
          )
        | .[0]
        | [.headRefName, .state, (.reviewDecision // ""), (if .isDraft then "true" else "false" end),
           ([.labels.nodes[].name] | join(",")), .title, (.baseRefName // ""), (.url // "")]
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
            printf '%s\n' (string join "$sep" "$branch" "$sha" '' '' '' '' '' '' '')
        end
    end
end
