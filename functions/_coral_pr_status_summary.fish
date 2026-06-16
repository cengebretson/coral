function _coral_pr_status_summary --argument-names state review
    # icon + human label for a PR state/review (see _coral_pr_status).
    set -f f (string split \t (_coral_pr_status "$state" "$review"))
    printf '%s %s\n' $f[3] $f[4]
end
