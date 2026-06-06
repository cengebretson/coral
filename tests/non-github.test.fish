source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set repo "$temp_root/repo"
set bin_dir "$temp_root/bin"
mkdir -p "$repo" "$bin_dir"

git -C "$repo" init -q
git -C "$repo" config user.email coral@example.com
git -C "$repo" config user.name Coral
touch "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -qm "Initial commit"
git -C "$repo" branch feature/non-github
git -C "$repo" remote add origin git@example.com:example/repo.git

printf '%s\n' \
    '#!/bin/sh' \
    'echo "gh should not be called" >&2' \
    'exit 42' \
    > "$bin_dir/gh"
chmod +x "$bin_dir/gh"
set -gx PATH "$bin_dir" $PATH

cd "$repo"
git checkout -q feature/non-github

@test "non-GitHub remote is detected" (_coral_is_github_repo; echo $status) = 1
@test "branch list does not call gh for non-GitHub remotes" (_coral_list >/dev/null 2>"$temp_root/stderr"; echo $status) = 0
@test "non-GitHub branch list has no gh failure output" (test -z (cat "$temp_root/stderr"); echo $status) = 0
@test "open PR reports non-GitHub remotes" (_coral_open_pr feature/non-github >/dev/null 2>"$temp_root/open-pr"; string match -q "*not a GitHub remote*" (cat "$temp_root/open-pr"); echo $status) = 0

rm -rf "$temp_root"
