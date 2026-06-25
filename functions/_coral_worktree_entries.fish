function _coral_worktree_entries
    # Single source of worktree parsing: emits "refs/heads/<branch>\t<path>\t<index>"
    # for every worktree block that has a branch checked out, where index 1 is the
    # main worktree and 2+ are linked worktrees. Detached blocks (no branch line)
    # are skipped. _coral_worktree_list filters this to linked-only; the per-branch
    # lookups (_coral_worktree_path, _coral_branch_checkout_path) select from it, so
    # the porcelain awk lives in exactly one place.
    git worktree list --porcelain 2>/dev/null \
        | awk '
            /^worktree / { n++; path = substr($0, 10); branch = "" }
            /^branch /   { branch = $2 }
            /^$/         { if (branch != "") print branch "\t" path "\t" n; branch = ""; path = "" }
            END          { if (branch != "") print branch "\t" path "\t" n }
        '
end
