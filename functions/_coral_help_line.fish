function _coral_help_line --argument-names action key description
    set -f action_col (string pad -r -w 9 -- "$action")
    set -f key_col (string pad -r -w 7 -- "$key")
    printf '%s %s %s\n' "$action_col" "$key_col" "$description"
end
