function _coral_hash_key --argument-names value
    printf '%s' "$value" | git hash-object --stdin 2>/dev/null | string sub -l 16
end
