source (dirname (status --current-filename))/helpers.fish

function coral_make_delete_repo
    set -f temp_root (mktemp -d)
    set -f main_repo "$temp_root/main"
    set -f linked_repo "$temp_root/linked"

    mkdir -p "$main_repo"
    git -C "$main_repo" init -q
    git -C "$main_repo" config user.email coral@example.com
    git -C "$main_repo" config user.name Coral
    touch "$main_repo/README.md"
    git -C "$main_repo" add README.md
    git -C "$main_repo" commit -qm "Initial commit"
    git -C "$main_repo" branch feature/delete
    git -C "$main_repo" worktree add -q "$linked_repo" feature/delete

    printf '%s\n%s\n' "$temp_root" "$main_repo"
end

function _coral_confirm --argument-names prompt
    set -g coral_confirm_prompts $coral_confirm_prompts "$prompt"
    set -f answer $coral_confirm_answers[1]
    set -e coral_confirm_answers[1]
    test "$answer" = yes
end

set delete_repo_info (coral_make_delete_repo)
set temp_root_decline $delete_repo_info[1]
set main_repo_decline $delete_repo_info[2]
printf 'dirty\n' > "$temp_root_decline/linked/dirty.txt"
cd "$main_repo_decline"

set -g coral_confirm_answers yes no
set -g coral_confirm_prompts
_coral_delete_common feature/delete >/tmp/coral-delete-decline.out 2>/tmp/coral-delete-decline.err
set decline_status $status

@test "dirty worktree delete asks before force removal" (test "$coral_confirm_prompts[2]" = "Worktree removal failed. Force remove this worktree and delete the local branch? This can delete uncommitted changes."; echo $status) = 0
@test "declining force removal fails delete" "$decline_status" = 1
@test "declining force removal keeps branch" (git -C "$main_repo_decline" rev-parse --verify --quiet feature/delete >/dev/null; echo $status) = 0
@test "declining force removal keeps worktree" (test -d "$temp_root_decline/linked"; echo $status) = 0

rm -rf "$temp_root_decline"

set delete_repo_info (coral_make_delete_repo)
set temp_root_force $delete_repo_info[1]
set main_repo_force $delete_repo_info[2]
printf 'dirty\n' > "$temp_root_force/linked/dirty.txt"
cd "$main_repo_force"

set -g coral_confirm_answers yes yes
set -g coral_confirm_prompts
_coral_delete_common feature/delete >/tmp/coral-delete-force.out 2>/tmp/coral-delete-force.err
set force_status $status

@test "accepting force removal deletes dirty worktree branch" "$force_status" = 0
@test "accepting force removal removes branch" (not git -C "$main_repo_force" rev-parse --verify --quiet feature/delete >/dev/null; echo $status) = 0
@test "accepting force removal removes worktree" (not test -d "$temp_root_force/linked"; echo $status) = 0

rm -rf "$temp_root_force"
