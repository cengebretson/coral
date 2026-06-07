source (dirname (status --current-filename))/helpers.fish

coral_test_reset
set -g CORAL_CACHE_TTL abc
@test "invalid cache TTL falls back to 300" (_coral_cache_ttl) = 300

coral_test_reset
set -g CORAL_CACHE_TTL 42
@test "valid cache TTL is used" (_coral_cache_ttl) = 42

coral_test_reset
set -g CORAL_PR_BATCH_SIZE nope
@test "invalid PR batch size falls back to 10" (_coral_pr_batch_size) = 10

coral_test_reset
set -g CORAL_PR_BATCH_SIZE 12
@test "valid PR batch size is used" (_coral_pr_batch_size) = 12

coral_test_reset
set -g CORAL_PR_HISTORY_DAYS bad
@test "invalid PR history days falls back to 30" (_coral_pr_history_days) = 30

coral_test_reset
set -g CORAL_PR_HISTORY_DAYS 0
@test "PR history days accepts zero" (_coral_pr_history_days) = 0

coral_test_reset
@test "default list mode is full" (_coral_list_mode) = full

coral_test_reset
set -g CORAL_LIST_MODE short
@test "short list mode is accepted" (_coral_list_mode) = short

coral_test_reset
set -g CORAL_LIST_MODE compact
@test "invalid list mode falls back to full" (_coral_list_mode) = full
