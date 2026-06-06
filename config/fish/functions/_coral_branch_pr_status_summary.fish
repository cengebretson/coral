function _coral_branch_pr_status_summary --argument-names branch
    command -q gh; or return 1

    set -f pr (gh pr view "$branch" --json state,reviewDecision 2>/dev/null)
    test -n "$pr"; or return 1
    echo $pr | jq -e . >/dev/null 2>&1; or return 1

    set -f state (echo $pr | jq -r '.state // ""' 2>/dev/null)
    set -f review (echo $pr | jq -r '.reviewDecision // ""' 2>/dev/null)
    test -n "$state"; or return 1

    _coral_pr_status_summary "$state" "$review"
end
