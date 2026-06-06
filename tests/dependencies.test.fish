source (dirname (status --current-filename))/helpers.fish

function _fzf_wrapper
    command cat
end

@test "dependency check passes when local hard deps are available" (_coral_check_dependencies; echo $status) = 0

functions -e _fzf_wrapper
@test "dependency check fails without fzf.fish wrapper" (_coral_check_dependencies >/dev/null 2>&1; echo $status) = 1
