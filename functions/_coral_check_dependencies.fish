function _coral_check_dependencies --description "Validate coral hard dependencies"
    set -f failures 0

    for required in git fzf jq shasum
        if not command -q $required
            echo "coral: $required not found." >&2
            set failures (math $failures + 1)
        end
    end

    if not functions -q _fzf_wrapper
        echo 'coral: _fzf_wrapper not found - install fzf.fish (https://github.com/PatrickF1/fzf.fish)' >&2
        set failures (math $failures + 1)
    end

    if command -q fzf
        set -f fzf_ver (fzf --version 2>/dev/null | string match -r '\d+\.\d+' | head -1)
        if test -n "$fzf_ver"
            set -f major (string split . $fzf_ver)[1]
            set -f minor (string split . $fzf_ver)[2]
            if test "$major" -eq 0 -a "$minor" -lt 57
                echo "coral: fzf $fzf_ver found; 0.57+ required." >&2
                set failures (math $failures + 1)
            end
        end
    end

    test $failures -eq 0
end
