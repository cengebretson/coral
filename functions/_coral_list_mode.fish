function _coral_list_mode
    if set -q CORAL_LIST_MODE
        switch "$CORAL_LIST_MODE"
            case short full
                printf '%s\n' "$CORAL_LIST_MODE"
                return 0
        end
    end

    printf 'full\n'
end
