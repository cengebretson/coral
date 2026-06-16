function _coral_cached_pr_row --argument-names branch
    # Return the cached PR row for a branch (the 8-field \x01-joined line written
    # by _coral_list), or fail if there is no cache or no row for the branch.
    # Lets the preview, delete prompt, and rebase reuse already-fetched PR data
    # instead of each making their own `gh` network call.
    test -n "$branch"; or return 1

    set -f cache_file (_coral_cache_file); or return 1
    test -f "$cache_file"; or return 1

    for entry in (cat "$cache_file")
        set -f parts (string split \x01 -- $entry)
        test (count $parts) -ge 8; or continue
        if test "$parts[1]" = "$branch"
            printf '%s\n' "$entry"
            return 0
        end
    end

    return 1
end
