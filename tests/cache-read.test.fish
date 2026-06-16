source (dirname (status --current-filename))/helpers.fish

set temp_config_home (mktemp -d)
set temp_cache_home (mktemp -d)
set -gx XDG_CONFIG_HOME $temp_config_home
set -gx XDG_CACHE_HOME $temp_cache_home
coral_test_reset

# A gh stub that fails loudly: any code path that reaches the network instead of
# the cache will error, so these tests prove the cache path makes no gh call.
set bin_dir (mktemp -d)
printf '%s\n' '#!/bin/sh' 'echo "gh should not be called" >&2' 'exit 1' > "$bin_dir/gh"
chmod +x "$bin_dir/gh"
set -gx PATH "$bin_dir" $PATH

set temp_repo (mktemp -d)
git -C "$temp_repo" init -q
git -C "$temp_repo" config user.email coral@example.com
git -C "$temp_repo" config user.name Coral
touch "$temp_repo/README.md"
git -C "$temp_repo" add README.md
git -C "$temp_repo" commit -qm "Initial commit"
git -C "$temp_repo" branch feature/cached
git -C "$temp_repo" remote add origin git@github.com:example/repo.git
cd "$temp_repo"
git checkout -q feature/cached

set feature_sha (git rev-parse feature/cached)
set sep (printf '\x01')
set cache_file (_coral_cache_file)
printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' feature/cached "$sep" "$feature_sha" "$sep" OPEN "$sep" APPROVED "$sep" ready "$sep" "Ready PR" "$sep" develop "$sep" https://github.com/example/repo/pull/9 > "$cache_file"

set row (_coral_cached_pr_row feature/cached)
set parts (string split \x01 $row)

@test "cached pr row returns the matching branch row" "$parts[1]" = feature/cached
@test "cached pr row carries the PR state" "$parts[3]" = OPEN
@test "cached pr row carries the base branch" "$parts[7]" = develop
@test "cached pr row fails for an unknown branch" (_coral_cached_pr_row no/such/branch; echo $status) = 1

set summary (_coral_branch_pr_status_summary feature/cached)
@test "branch pr status summary reads approved state from the cache" (string match -q "*approved*" "$summary"; echo $status) = 0

set nofetch_output (_coral_list full nofetch 2>/dev/null)
@test "nofetch list renders cached PR label without calling gh" (string match -q "*[ready]*" "$nofetch_output"; echo $status) = 0

rm -rf "$temp_repo" "$temp_config_home" "$temp_cache_home" "$bin_dir"
