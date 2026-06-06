function _coral_pr_status_summary --argument-names state review
    set -f display (string split \t (_coral_pr_status_display "$state" "$review"))
    set -f icon $display[3]

    switch $state
        case OPEN
            switch $review
                case APPROVED
                    printf '%s approved\n' $icon
                case CHANGES_REQUESTED
                    printf '%s changes requested\n' $icon
                case '*'
                    printf '%s open\n' $icon
            end
        case MERGED
            printf '%s merged\n' $icon
        case CLOSED
            printf '%s closed\n' $icon
        case '*'
            printf '%s %s\n' $icon (string lower -- "$state")
    end
end
