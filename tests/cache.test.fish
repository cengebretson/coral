source (dirname (status --current-filename))/helpers.fish

set temp_cache_home (mktemp -d)
set -gx XDG_CACHE_HOME $temp_cache_home

set temp_repo (mktemp -d)
git -C "$temp_repo" init -q
git -C "$temp_repo" remote add origin git@github.com:example/repo.git

coral_test_reset
cd "$temp_repo"
set cache_file (_coral_cache_file)

@test "cache file is under XDG cache dir" (string match -q "$temp_cache_home/coral/pr/*.cache" "$cache_file"; echo $status) = 0
@test "cache dir is created" -d "$temp_cache_home/coral/pr"

printf stale > "$cache_file"

git -C "$temp_repo" config user.email coral@example.com
git -C "$temp_repo" config user.name Coral
touch "$temp_repo/README.md"
git -C "$temp_repo" add README.md
git -C "$temp_repo" commit -qm "Initial commit"
git -C "$temp_repo" branch feature/worktree
set linked_repo (mktemp -d)
rm -rf "$linked_repo"
git -C "$temp_repo" worktree add -q "$linked_repo" feature/worktree
rm -rf "$linked_repo"

_coral_refresh

@test "refresh clears cache file" ! -e "$cache_file"
@test "refresh prunes stale worktree metadata" -z (_coral_worktree_path feature/worktree)

rm -rf "$temp_repo" "$temp_cache_home" "$linked_repo"
