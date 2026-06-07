function _coral_refresh
    _coral_clear_cache

    if git rev-parse --git-dir >/dev/null 2>&1
        command git worktree prune >/dev/null 2>&1
    end

    return 0
end
