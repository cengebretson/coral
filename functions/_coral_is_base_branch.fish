function _coral_is_base_branch --argument-names branch
    _coral_load_config

    for base in $CORAL_BASE_BRANCHES
        if string match -q -- "$base" "$branch"; or string match -q -- "$base/*" "$branch"
            return 0
        end
    end

    return 1
end
