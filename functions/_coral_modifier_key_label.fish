function _coral_modifier_key_label --argument-names modifier
    set -f system (uname -s 2>/dev/null)

    switch "$modifier"
        case ctrl
            if test "$system" = Darwin
                printf '⌃\n'
            else
                printf 'Ctrl\n'
            end
        case alt
            if test "$system" = Darwin
                printf '⌥\n'
            else
                printf 'Alt\n'
            end
    end
end
