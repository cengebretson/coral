function _coral_is_github_repo
    set -f origin (git remote get-url origin 2>/dev/null)
    test -n "$origin"; or return 1

    string match -qr '(^git@github\.com:|://github\.com/)' -- "$origin"
end
