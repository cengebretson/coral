function _coral_xdg_path --argument-names xdg_value fallback suffix
    # Resolve an XDG-based path: use xdg_value when non-empty (an unset or empty
    # XDG_* var falls back), then append suffix. Shared by the cache dir and
    # config file resolvers.
    set -f base "$fallback"
    test -n "$xdg_value"; and set base "$xdg_value"
    printf '%s/%s\n' "$base" "$suffix"
end
