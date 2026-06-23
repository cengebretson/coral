function _coral_branch_checkout_path --argument-names branch
    # Path of the worktree (main OR linked) where <branch> is checked out, or
    # empty if it is not checked out anywhere. Unlike _coral_worktree_path, which
    # is linked-only and drives navigation and the list icon, this also sees the
    # main checkout, so callers can refuse operations git itself would block
    # (deleting or checking out a branch already checked out in another worktree).
    git worktree list --porcelain 2>/dev/null \
        | awk -v b="refs/heads/$branch" '
            /^worktree / { path = substr($0, 10) }
            /^branch /   { if ($2 == b) { print path; exit } }
        '
end
