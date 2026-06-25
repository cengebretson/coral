function _coral_branch_checkout_path --argument-names branch
    # Path of the worktree (main OR linked) where <branch> is checked out, or
    # empty if it is not checked out anywhere. Unlike _coral_worktree_path, which
    # is linked-only and drives navigation and the list icon, this also sees the
    # main checkout, so callers can refuse operations git itself would block
    # (deleting or checking out a branch already checked out in another worktree).
    _coral_worktree_entries \
        | awk -F'\t' -v b="refs/heads/$branch" '$1 == b { print $2; exit }'
end
