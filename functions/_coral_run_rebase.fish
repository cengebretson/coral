function _coral_run_rebase --argument-names branch
    set -f esc (string escape -- $branch)
    _coral_popup "_coral_rebase $esc" " Rebase Branch " "80%" 22
end
