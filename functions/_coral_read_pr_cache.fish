function _coral_read_pr_cache --argument-names cache_file
    test -n "$cache_file"; or return 1
    test -f "$cache_file"; or return 1

    cat "$cache_file"
end
