function _coral_pr_status_display --argument-names state review draft
    # color, ansi code, and icon for a PR state/review (see _coral_pr_status).
    set -f f (string split \t (_coral_pr_status "$state" "$review" "$draft"))
    printf '%s\t%s\t%s\n' $f[1] $f[2] $f[3]
end
