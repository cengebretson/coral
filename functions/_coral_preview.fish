function _coral_preview --argument-names branch
    _coral_load_config

    set_color --bold white
    echo "  $branch"
    set_color normal

    set -f last (git log -1 --format='%cr by %an' "$branch" 2>/dev/null)
    set_color brblack
    echo "  $last"
    set_color normal

    # PR data: prefer the cache _coral_list already wrote. The preview renders on
    # every cursor move, so a per-move `gh pr view` (a network round-trip) makes
    # scrolling laggy. Fall back to a live lookup only when the branch is not yet
    # cached (e.g. while the initial fetch is still in flight).
    set -f pr_ok false
    set -f pr_state ''
    set -f pr_title ''
    set -f pr_url ''
    set -f pr_base ''
    set -f pr_labels

    set -f pr_row (_coral_cached_pr_row "$branch")
    if test -n "$pr_row"
        set -f parts (string split \x01 -- $pr_row)
        set pr_state $parts[3]
        if test -n "$pr_state"
            set pr_ok true
            set pr_title $parts[6]
            set pr_base $parts[7]
            set pr_url $parts[8]
            test -n "$parts[5]"; and set pr_labels (string split , -- $parts[5])
        end
    else if _coral_is_github_repo; and command -q gh
        set -f pr (gh pr view "$branch" --json title,state,url,labels,baseRefName 2>/dev/null)
        if test -n "$pr"; and echo $pr | jq -e . >/dev/null 2>&1
            set pr_ok true
            set pr_state (echo $pr | jq -r '.state // ""' 2>/dev/null)
            set pr_title (echo $pr | jq -r '.title // ""' 2>/dev/null)
            set pr_url (echo $pr | jq -r '.url // ""' 2>/dev/null)
            set pr_base (echo $pr | jq -r '.baseRefName // ""' 2>/dev/null)
            set pr_labels (echo $pr | jq -r '.labels[].name' 2>/dev/null)
        end
    end

    # baseRefName is the authoritative base for comparisons; fall back to the
    # inferred upstream when there is no PR or no GitHub remote.
    if test -n "$pr_base"
        set -f diff_base "origin/$pr_base"
    else
        set -f diff_base (_coral_upstream "$branch")
        test -n "$diff_base"; or return 1
    end

    set -f ahead (git rev-list --count "$diff_base..$branch" 2>/dev/null)
    set -f behind (git rev-list --count "$branch..$diff_base" 2>/dev/null)
    if test -n "$ahead"; and test -n "$behind"
        if test "$ahead" = 0; and test "$behind" = 0
            set_color brblack
            echo "  up to date with $diff_base"
        else
            set_color cyan
            printf '  ↑%s ahead' $ahead
            if test "$behind" -gt 0
                set_color yellow
                printf '  ↓%s behind' $behind
            end
            echo ''
        end
        set_color normal
    end

    if test "$pr_ok" = true
        set -f pr_display (string split \t (_coral_pr_status_display "$pr_state" ""))
        set_color $pr_display[1]
        set -f icon $pr_display[3]
        echo "  $icon $pr_title"
        set_color normal
        if test (count $pr_labels) -gt 0
            printf '  '
            for label in $pr_labels
                printf '%s ' (_coral_label_badge "$label")
            end
            echo ''
        end
        set_color brblack
        echo "  $pr_url"
        set_color normal
    end

    set -f jira_key (string match -r (_coral_jira_pattern) "$branch")
    if test -n "$jira_key"
        set -f jira_url (_coral_jira_url "$jira_key")
        if test -n "$jira_url"
            set_color brblack
            echo "  $jira_url"
            set_color normal
        end
    end

    set -f wt_path (_coral_worktree_path "$branch")
    if test -n "$wt_path"
        set_color yellow
        echo "  󰙅 $wt_path"
        set_color normal
    end

    echo ""
    set_color --bold cyan
    echo "  COMMITS AHEAD OF $diff_base"
    set_color normal
    # Double-dot: commits reachable from branch but not from base (what this branch added).
    set -f commits (git log --oneline --color=always "$diff_base..$branch" 2>/dev/null)
    if test (count $commits) -gt 0
        for line in $commits[1..10]
            echo "  $line"
        end
    else
        set_color brblack
        echo "  (none)"
        set_color normal
    end
    echo ""

    set_color --bold cyan
    echo "  CHANGED FILES"
    set_color normal
    # Triple-dot: diffs from the merge-base, showing files changed since the fork point.
    # Intentionally different from the double-dot above — correct for PR file review.
    set -f files (git diff --name-only "$diff_base...$branch" 2>/dev/null)
    set -f total (count $files)
    if test $total -gt 0
        for f in $files[1..30]
            echo "  $f"
        end
        if test $total -gt 30
            set_color brblack
            echo "  ... and "(math $total - 30)" more"
            set_color normal
        end
    else
        set_color brblack
        echo "  (none)"
        set_color normal
    end
end
