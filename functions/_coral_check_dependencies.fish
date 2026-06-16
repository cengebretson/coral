function _coral_check_dependencies --description "Validate coral hard dependencies"
    set -f failures 0

    for required in git fzf jq
        if not command -q $required
            echo "coral: $required not found." >&2
            set failures (math $failures + 1)
        end
    end

    if not functions -q _fzf_wrapper
        echo 'coral: _fzf_wrapper not found - install fzf.fish (https://github.com/PatrickF1/fzf.fish)' >&2
        set failures (math $failures + 1)
    end

    if _coral_fzf_outdated
        echo "coral: fzf "(_coral_fzf_version)" found; 0.57+ required." >&2
        set failures (math $failures + 1)
    end

    test $failures -eq 0
end
