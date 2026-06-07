source (dirname (status --current-filename))/helpers.fish
source "$CORAL_REPO_ROOT/completions/coral.fish"

set completions (complete -C "coral --" | string replace -r '\t.*$' '')

@test "coral completes --doctor" (contains -- --doctor $completions; echo $status) = 0
@test "coral completes --full" (contains -- --full $completions; echo $status) = 0
@test "coral completes --short" (contains -- --short $completions; echo $status) = 0
@test "coral completes --slack" (contains -- --slack $completions; echo $status) = 0
@test "coral completes --version" (contains -- --version $completions; echo $status) = 0
