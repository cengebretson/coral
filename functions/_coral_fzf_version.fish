function _coral_fzf_version
    # Print fzf's major.minor (e.g. "0.57"), or fail if fzf is missing or its
    # version can't be parsed. Single source for the three places that report it.
    command -q fzf; or return 1
    set -f ver (fzf --version 2>/dev/null | string match -r '\d+\.\d+' | head -1)
    test -n "$ver"; or return 1
    printf '%s\n' "$ver"
end
