source (dirname (status --current-filename))/helpers.fish

set temp_root (mktemp -d)
set repo "$temp_root/repo"
set cache_home "$temp_root/cache"
mkdir -p "$repo" "$cache_home"

git -C "$repo" init -q
git -C "$repo" config user.email coral@example.com
git -C "$repo" config user.name Coral
touch "$repo/README.md"
git -C "$repo" add README.md
git -C "$repo" commit -qm "Initial commit"
git -C "$repo" branch feature/stale
git -C "$repo" remote add origin git@example.com:example/repo.git

set -gx XDG_CACHE_HOME "$cache_home"
cd "$repo"
git checkout -q feature/stale
set cache_file (_coral_cache_file)
set sha (git rev-parse feature/stale)
set sep (printf '\x01')
mkdir -p (dirname "$cache_file")
printf '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s\n' feature/stale "$sep" "$sha" "$sep" OPEN "$sep" APPROVED "$sep" cached "$sep" "Cached PR" "$sep" main "$sep" https://github.com/example/repo/pull/9 > "$cache_file"
touch -t 200001010000 "$cache_file"

set -g CORAL_CACHE_TTL 1
set output (_coral_list 2>/dev/null)

@test "stale cache rows are reused when refresh is unavailable" (printf '%s\n' $output | string match -q "*[cached]*"; echo $status) = 0
@test "stale cache rows are marked in the list" (printf '%s\n' $output | string match -q "*[stale]*"; echo $status) = 0

rm -rf "$temp_root"
