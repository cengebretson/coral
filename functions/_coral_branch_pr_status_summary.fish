function _coral_branch_pr_status_summary --argument-names branch
    # Prefer the cached PR row (no network) — this drives the delete confirm
    # prompt. Fall back to a live lookup only when the branch isn't cached.
    set -f row (_coral_cached_pr_row "$branch")
    if test -n "$row"
        set -f parts (string split \x01 -- $row)
        set -f state $parts[3]
        set -f draft ''
        test (count $parts) -ge 9; and set draft $parts[5]
        test -n "$state"; or return 1
        _coral_pr_status_summary "$state" "$parts[4]" "$draft"
        return 0
    end

    _coral_is_github_repo; or return 1
    command -q gh; or return 1

    set -f pr (gh pr view "$branch" --json state,reviewDecision,isDraft 2>/dev/null)
    test -n "$pr"; or return 1
    echo $pr | jq -e . >/dev/null 2>&1; or return 1

    set -f state (echo $pr | jq -r '.state // ""' 2>/dev/null)
    set -f review (echo $pr | jq -r '.reviewDecision // ""' 2>/dev/null)
    set -f draft (echo $pr | jq -r 'if .isDraft then "true" else "false" end' 2>/dev/null)
    test -n "$state"; or return 1

    _coral_pr_status_summary "$state" "$review" "$draft"
end
