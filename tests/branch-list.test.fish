source (dirname (status --current-filename))/helpers.fish

set temp_config_home (mktemp -d)
set temp_cache_home (mktemp -d)
set -gx XDG_CONFIG_HOME $temp_config_home
set -gx XDG_CACHE_HOME $temp_cache_home
coral_test_reset

function coral_make_branch_list_repo
    set temp_repo (mktemp -d)
    git -C "$temp_repo" init -q
    git -C "$temp_repo" config user.email coral@example.com
    git -C "$temp_repo" config user.name Coral
    touch "$temp_repo/README.md"
    git -C "$temp_repo" add README.md
    git -C "$temp_repo" commit -qm "Initial commit"
    git -C "$temp_repo" branch develop
    git -C "$temp_repo" branch feature/list
    git -C "$temp_repo" branch trunk
    git -C "$temp_repo" branch staging
    git -C "$temp_repo" remote add origin git@example.com:example/repo.git
    printf '%s\n' "$temp_repo"
end

set temp_repo (coral_make_branch_list_repo)
cd "$temp_repo"
git checkout -q feature/list
set list_output (_coral_list 2>/dev/null)
set branch_names
for line in $list_output
    set branch_names $branch_names (string split \t $line)[1]
end

@test "branch list includes feature branches" (contains -- feature/list $branch_names; echo $status) = 0
@test "branch list hides configured base branches" (contains -- develop $branch_names; echo $status) = 1
@test "branch list hides trunk by default" (contains -- trunk $branch_names; echo $status) = 1
@test "branch list hides staging by default" (contains -- staging $branch_names; echo $status) = 1

set sep (printf '\x01')
set feature_sha (git rev-parse feature/list)
set cache_file (_coral_cache_file)
printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' feature/list "$sep" "$feature_sha" "$sep" OPEN "$sep" APPROVED "$sep" ready "$sep" "Ready PR" "$sep" main "$sep" https://github.com/example/repo/pull/1 > "$cache_file"
set full_output (_coral_list full 2>/dev/null)
set short_output (_coral_list short 2>/dev/null)
@test "full list includes PR labels" (string match -q "*[ready]*" "$full_output"; echo $status) = 0
@test "short list keeps PR status" (string match -q "*✓*" "$short_output"; echo $status) = 0
@test "short list hides PR labels" (string match -q "*[ready]*" "$short_output"; echo $status) = 1

git checkout -q trunk
set trunk_output (_coral_list 2>/dev/null)
set trunk_branch_names
for line in $trunk_output
    set trunk_branch_names $trunk_branch_names (string split \t $line)[1]
end
@test "branch list shows current branch even when it is a base branch" (contains -- trunk $trunk_branch_names; echo $status) = 0

rm -rf "$temp_repo"
rm -rf "$temp_config_home" "$temp_cache_home"
