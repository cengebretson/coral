function _coral_delete_common --argument-names branch
    _coral_load_config

    set -f current (git branch --show-current 2>/dev/null)
    if test "$branch" = "$current"
        printf 'Cannot delete the current branch.\n'
        sleep 1.5
        return 1
    end

    # A branch checked out in a linked worktree cannot be deleted with
    # `git branch -D` (git refuses with "used by worktree"). Detect that case so
    # the worktree is removed first, otherwise the delete silently no-ops.
    set -f wt_path (_coral_worktree_path "$branch")

    # When it's not a coral-managed linked worktree, it may still be checked out
    # in the main worktree (which the linked-only lookup skips). git would refuse
    # the delete, and we must never auto-remove the user's primary checkout, so
    # refuse up front with a clear message instead of a raw git error.
    if test -z "$wt_path"
        set -f other_wt (_coral_branch_checkout_path "$branch")
        if test -n "$other_wt"
            printf 'Cannot delete: %s is checked out in the worktree at %s.\n' "$branch" "$other_wt"
            sleep 1.5
            return 1
        end
    end

    set -f pr_status (_coral_branch_pr_status_summary "$branch")
    if test -n "$wt_path"
        set -f force_prompt "Remove the worktree at $wt_path, then force delete this local branch?"
        test -n "$pr_status"; and set force_prompt "$force_prompt $pr_status"
    else if test -n "$pr_status"
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
        if test -n "$wt_path"
            if test -d "$wt_path"
                # Plain remove (no --force): refuses on a dirty worktree so we
                # never silently destroy uncommitted work. When it fails, ask
                # once more before forcing removal and deleting the branch.
                set -f remove_output (git worktree remove "$wt_path" 2>&1)
                set -f remove_status $status
                if test "$remove_status" -ne 0
                    printf '%s\n' $remove_output >&2
                    if not _coral_confirm "Worktree removal failed. Force remove this worktree and delete the local branch? This can delete uncommitted changes."
                        printf 'Worktree removal failed; branch not deleted.\n' >&2
                        return 1
                    end

                    if not git worktree remove --force "$wt_path" 2>&1
                        printf 'Forced worktree removal failed; branch not deleted.\n' >&2
                        return 1
                    end
                end
            else
                # Stale entry: the directory is already gone but the admin record
                # remains and still blocks `git branch -D`. Prune it, no removal.
                command git worktree prune >/dev/null 2>&1
            end
        end
        git branch -D "$branch" 2>&1
        or printf 'Delete failed.\n' >&2
    end
end
