source (dirname (status --current-filename))/helpers.fish

set temp_config_home (mktemp -d)
set -gx XDG_CONFIG_HOME $temp_config_home

coral_test_reset
_coral_load_config

@test "default base branches are a fish list" (contains -- trunk $CORAL_BASE_BRANCHES; and contains -- staging $CORAL_BASE_BRANCHES; echo $status) = 0
@test "base branch matcher matches exact values" (_coral_is_base_branch trunk; echo $status) = 0
@test "base branch matcher matches slash families" (_coral_is_base_branch release/2026.06; echo $status) = 0
@test "base branch matcher rejects feature branches" (_coral_is_base_branch feature/work; echo $status) = 1

coral_test_reset
set -g CORAL_BASE_BRANCHES 'develop|main|master|release/|hotfix/'
_coral_load_config

@test "legacy regex base branch config is normalized to a fish list" (contains -- release $CORAL_BASE_BRANCHES; and contains -- hotfix $CORAL_BASE_BRANCHES; echo $status) = 0

rm -rf "$temp_config_home"
