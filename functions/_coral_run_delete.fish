function _coral_run_delete --argument-names branch force
    # string escape prevents command injection for branch names containing ; or special chars.
    set -f esc (string escape -- $branch)
    if test "$force" = force
        _coral_popup "_coral_delete_common $esc force" " Force Delete " "80%" 13
    else
        _coral_popup "_coral_delete_common $esc" " Delete Branch " "80%" 13
    end
end
