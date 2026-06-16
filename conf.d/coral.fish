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
else if _coral_fzf_outdated
    _coral_startup_warn_once "coral: fzf "(_coral_fzf_version)" found; 0.57+ required - run: brew upgrade fzf"
end

if not command -q jq
    _coral_startup_warn_once 'coral: jq not found - run: brew install jq'
end
