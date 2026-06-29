source (dirname (status --current-filename))/helpers.fish

@test "open PR summary includes open status" (_coral_pr_status_summary OPEN NONE) = "● open"
@test "draft PR summary includes draft status" (_coral_pr_status_summary OPEN NONE true) = "◌ draft"
@test "approved PR summary includes approved status" (_coral_pr_status_summary OPEN APPROVED) = "✓ approved"
@test "changes requested PR summary includes review status" (_coral_pr_status_summary OPEN CHANGES_REQUESTED) = "! changes requested"
@test "merged PR summary includes merged status" (_coral_pr_status_summary MERGED NONE) = "󰘬 merged"
@test "closed PR summary includes closed status" (_coral_pr_status_summary CLOSED NONE) = "● closed"
