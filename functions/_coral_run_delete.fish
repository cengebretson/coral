function _coral_run_delete --argument-names branch
    # string escape prevents command injection for branch names containing ; or special chars.
    set -f esc (string escape -- $branch)
    _coral_popup "_coral_delete_common $esc" " Force Delete " "80%" 13
end
