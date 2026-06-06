function _coral_open_pr --argument-names branch
    if not _coral_is_github_repo
        echo 'coral: current origin is not a GitHub remote; PR actions are unavailable' >&2
        return 1
    end

    if not command -q gh
        echo 'coral: gh not found — install the GitHub CLI to open PRs' >&2
        return 1
    end

    gh pr view "$branch" --web 2>/dev/null
    or echo "coral: no PR found for '$branch' or gh is not authenticated" >&2
end
