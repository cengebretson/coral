function _coral_cache_file
    set -f remote_url (git remote get-url origin 2>/dev/null)
    test -n "$remote_url"; or return 1

    set -f repo_key (_coral_hash_key "$remote_url")
    test -n "$repo_key"; or return 1

    set -f cache_dir (_coral_cache_dir)
    mkdir -p "$cache_dir" 2>/dev/null
    or return 1

    printf '%s/%s.cache\n' "$cache_dir" "$repo_key"
end
