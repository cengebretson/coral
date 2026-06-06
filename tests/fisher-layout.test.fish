source (dirname (status --current-filename))/helpers.fish

set helper_count (command find "$CORAL_REPO_ROOT/functions" -name '_coral*.fish' | wc -l | string trim)

@test "Fisher functions directory exists" -d "$CORAL_REPO_ROOT/functions"
@test "main coral function is top-level for Fisher" -f "$CORAL_REPO_ROOT/functions/coral.fish"
@test "private coral helpers are top-level for Fisher" (test "$helper_count" -gt 20; echo $status) = 0
@test "Fisher conf.d startup file exists" -f "$CORAL_REPO_ROOT/conf.d/coral.fish"
@test "Fisher completion file exists" -f "$CORAL_REPO_ROOT/completions/coral.fish"
