function _coral_worktree_list
    # Outputs "refs/heads/<branch>\t<path>" for each LINKED worktree.
    # Skips the main worktree (index 1); see _coral_worktree_entries.
    _coral_worktree_entries | awk -F'\t' '$3 > 1 { print $1 "\t" $2 }'
end
