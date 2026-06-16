function _coral_fzf_outdated
    # Succeed (return 0) when fzf is present but older than 0.57, the minimum
    # coral needs for its border flags. Fail when fzf is missing or new enough.
    set -f ver (_coral_fzf_version); or return 1
    set -f major (string split . $ver)[1]
    set -f minor (string split . $ver)[2]
    test "$major" -eq 0 -a "$minor" -lt 57
end
