function _coral_write_pr_cache --argument-names cache_file
    test -n "$cache_file"; or return 1

    set -f cache_tmp "$cache_file.tmp"
    printf '%s\n' $argv[2..] > "$cache_tmp"; and mv "$cache_tmp" "$cache_file"
end
