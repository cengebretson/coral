source (dirname (status --current-filename))/helpers.fish

set temp_remote (mktemp -d)
set temp_repo (mktemp -d)

git -C "$temp_remote" init --bare -q
git -C "$temp_repo" init -q
git -C "$temp_repo" config user.email coral@example.com
git -C "$temp_repo" config user.name Coral
git -C "$temp_repo" checkout -q -b main
touch "$temp_repo/README.md"
git -C "$temp_repo" add README.md
git -C "$temp_repo" commit -qm "Initial commit"
git -C "$temp_repo" remote add origin "$temp_remote"
git -C "$temp_repo" push -q -u origin main
git -C "$temp_repo" checkout -q -b feature/rebase
touch "$temp_repo/feature.txt"
git -C "$temp_repo" add feature.txt
git -C "$temp_repo" commit -qm "Feature commit"
git -C "$temp_repo" push -q -u origin feature/rebase
git -C "$temp_repo" checkout -q main

coral_test_reset
cd "$temp_repo"

function _coral_confirm --argument-names prompt
    string match -q 'Force push*' -- "$prompt"; and return 1
    return 0
end

_coral_rebase feature/rebase >/dev/null 2>&1
set rebase_status $status
set current_branch (git branch --show-current)

@test "rebase succeeds for a non-current branch" "$rebase_status" = 0
@test "rebase restores the original checkout" "$current_branch" = main

rm -rf "$temp_repo" "$temp_remote"
