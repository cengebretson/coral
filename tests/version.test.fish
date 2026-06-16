source (dirname (status --current-filename))/helpers.fish

# VERSION is the canonical release version (bumped by git-release). The runtime
# _coral_version function is kept in sync by .release-sync; this test guards
# against the two drifting apart.
set expected (string trim < "$CORAL_REPO_ROOT/VERSION")

@test "VERSION file is non-empty" -n "$expected"
@test "_coral_version matches VERSION file" (_coral_version) = "$expected"
@test "coral --version matches VERSION file" (coral --version) = "$expected"
