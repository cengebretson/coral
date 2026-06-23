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

# _coral_branch_checkout_path also sees the main checkout (used to refuse deletes
# and checkouts of a branch already checked out elsewhere), unlike the linked-only
# _coral_worktree_path above.
set main_branch (git -C "$main_repo" branch --show-current)
set main_repo_real (realpath "$main_repo")

@test "checkout path finds the main worktree" (_coral_branch_checkout_path "$main_branch") = "$main_repo_real"
@test "checkout path finds a linked worktree" (_coral_branch_checkout_path feature/worktree) = "$linked_repo_real"
@test "checkout path is empty for an unchecked-out branch" (test -z (_coral_branch_checkout_path no-such-branch); echo $status) = 0

rm -rf "$temp_root"
