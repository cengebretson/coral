function _coral_int_or_default --argument-names value default min
    # Echo value when it is an integer >= min, otherwise default. Centralises the
    # validation shared by the numeric CORAL_* config getters.
    if string match -qr '^[0-9]+$' -- "$value"; and test "$value" -ge "$min"
        printf '%s\n' "$value"
    else
        printf '%s\n' "$default"
    end
end
