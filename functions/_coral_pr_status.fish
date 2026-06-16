function _coral_pr_status --argument-names state review
    # Single source of truth for how a PR state/review maps to display attributes:
    #   color  ansi  icon  label
    # _coral_pr_status_display consumes color/ansi/icon; _coral_pr_status_summary
    # consumes icon/label. Keeping the switch here avoids duplicating it in both.
    switch $state
        case OPEN
            switch $review
                case APPROVED
                    printf '%s\t%s\t%s\t%s\n' green '\e[32m' ✓ approved
                case CHANGES_REQUESTED
                    printf '%s\t%s\t%s\t%s\n' yellow '\e[33m' ! 'changes requested'
                case '*'
                    printf '%s\t%s\t%s\t%s\n' green '\e[32m' ● open
            end
        case MERGED
            printf '%s\t%s\t%s\t%s\n' magenta '\e[35m' 󰘬 merged
        case CLOSED
            printf '%s\t%s\t%s\t%s\n' red '\e[31m' ● closed
        case '*'
            printf '%s\t%s\t%s\t%s\n' green '\e[32m' ● (string lower -- "$state")
    end
end
