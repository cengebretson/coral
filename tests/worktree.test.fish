source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set main_repo "$temp_root/main"
set linked_repo "$temp_root/linked"

mkdir -p "$main_repo"
git -C "$main_repo" init -q
git -C "$main_repo" config user.email coral@example.com
git -C "$main_repo" config user.name Coral
touch "$main_repo/README.md"
git -C "$main_repo" add README.md
git -C "$main_repo" commit -qm "Initial commit"
git -C "$main_repo" branch feature/worktree
git -C "$main_repo" worktree add -q "$linked_repo" feature/worktree
set linked_repo_real (realpath "$linked_repo")

cd "$main_repo"

set worktree_list (_coral_worktree_list)
set expected_worktree "refs/heads/feature/worktree	$linked_repo_real"

@test "worktree list skips main checkout and includes linked branch" (test "$worktree_list" = "$expected_worktree"; echo $status) = 0
@test "worktree path returns linked checkout path" (_coral_worktree_path feature/worktree) = "$linked_repo_real"

rm -rf "$temp_root"
