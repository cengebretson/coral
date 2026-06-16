function _coral_delete_common --argument-names branch
    _coral_load_config

    set -f current (git branch --show-current 2>/dev/null)
    if test "$branch" = "$current"
        printf 'Cannot delete the current branch.\n'
        sleep 1.5
        return 1
    end

    set -f pr_status (_coral_branch_pr_status_summary "$branch")
    if test -n "$pr_status"
        set -f force_prompt "Force delete this local branch? $pr_status"
    else
        set -f force_prompt "Force delete this local branch?"
    end

    if command -q gum
        gum style --foreground="$CORAL_COLOR_DANGER" --bold --border=rounded \
            --border-foreground="$CORAL_COLOR_DANGER" --padding="0 1" --margin="1 2" "$branch"
    else
        printf '\n  %s\n\n' "$branch"
    end
    if _coral_confirm "$force_prompt"
        git branch -D "$branch" 2>&1
        or printf 'Delete failed.\n' >&2
    end
end
