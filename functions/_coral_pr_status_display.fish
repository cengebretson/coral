function _coral_pr_status_display --argument-names state review
    switch $state
        case OPEN
            switch $review
                case APPROVED
                    printf '%s\t%s\t%s\n' green '\e[32m' ✓
                case CHANGES_REQUESTED
                    printf '%s\t%s\t%s\n' yellow '\e[33m' !
                case '*'
                    printf '%s\t%s\t%s\n' green '\e[32m' ●
            end
        case MERGED
            printf '%s\t%s\t%s\n' magenta '\e[35m' 󰘬
        case CLOSED
            printf '%s\t%s\t%s\n' red '\e[31m' ●
        case '*'
            printf '%s\t%s\t%s\n' green '\e[32m' ●
    end
end
