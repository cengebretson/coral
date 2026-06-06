source (dirname (status --current-filename))/helpers.fish

@test "open PR status uses list and preview dot" (_coral_pr_status_display OPEN NONE) = (printf '%s\t%s\t%s\n' green '\e[32m' ●)
@test "approved PR status uses checkmark" (_coral_pr_status_display OPEN APPROVED) = (printf '%s\t%s\t%s\n' green '\e[32m' ✓)
@test "changes requested PR status uses warning marker" (_coral_pr_status_display OPEN CHANGES_REQUESTED) = (printf '%s\t%s\t%s\n' yellow '\e[33m' !)
@test "merged PR status uses merge glyph" (_coral_pr_status_display MERGED NONE) = (printf '%s\t%s\t%s\n' magenta '\e[35m' 󰘬)
@test "closed PR status uses closed dot" (_coral_pr_status_display CLOSED NONE) = (printf '%s\t%s\t%s\n' red '\e[31m' ●)
