set -g __coral_startup_notice_shown 0

function _coral_startup_warn_once
    test $__coral_startup_notice_shown -eq 1; and return

    echo $argv >&2
    set -g __coral_startup_notice_shown 1
end

if not functions -q _fzf_wrapper
    _coral_startup_warn_once 'coral: fzf.fish not installed - run: fisher install PatrickF1/fzf.fish'
end

if not command -q fzf
    _coral_startup_warn_once 'coral: fzf not found - run: brew install fzf'
else
    set -l fzf_ver (fzf --version 2>/dev/null | string match -r '\d+\.\d+' | head -1)
    if test -n "$fzf_ver"
        set -l major (string split . $fzf_ver)[1]
        set -l minor (string split . $fzf_ver)[2]
        if test "$major" -eq 0 -a "$minor" -lt 57
            _coral_startup_warn_once "coral: fzf $fzf_ver found; 0.57+ required - run: brew upgrade fzf"
        end
    end
end

if not command -q jq
    _coral_startup_warn_once 'coral: jq not found - run: brew install jq'
end
