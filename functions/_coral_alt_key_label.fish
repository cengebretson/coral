function _coral_alt_key_label
    if test (uname -s 2>/dev/null) = Darwin
        printf 'Opt\n'
    else
        printf 'Alt\n'
    end
end
