function _coral_load_config
    set -q __coral_config_loaded; and return 0

    set -f config_file (_coral_config_file)
    if test -f "$config_file"
        source "$config_file"
    end

    set -f config_names CORAL_BASE_BRANCHES CORAL_CACHE_TTL CORAL_COLOR_ACCENT CORAL_COLOR_BG CORAL_COLOR_DANGER CORAL_COLOR_MUTED CORAL_COLOR_TEXT CORAL_JIRA_KEY_PATTERN CORAL_JIRA_URL_TEMPLATE CORAL_LIST_MODE CORAL_PR_HISTORY_DAYS
    set -g __coral_config_explicit
    for name in $config_names
        if set -q $name
            set __coral_config_explicit $__coral_config_explicit $name
        end
    end

    set -q CORAL_BASE_BRANCHES; or set -g CORAL_BASE_BRANCHES develop main master release hotfix trunk staging
    if test (count $CORAL_BASE_BRANCHES) -eq 1; and string match -q '*|*' -- "$CORAL_BASE_BRANCHES"
        set -f base_values
        for base in (string split '|' -- "$CORAL_BASE_BRANCHES")
            set -f normalized (string replace -r '/$' '' -- "$base")
            test -n "$normalized"; and set base_values $base_values $normalized
        end
        if test (count $base_values) -gt 0
            set -g CORAL_BASE_BRANCHES $base_values
        end
    end
    set -q CORAL_CACHE_TTL; or set -g CORAL_CACHE_TTL 300
    set -q CORAL_COLOR_ACCENT; or set -g CORAL_COLOR_ACCENT '#CBA6F7'
    set -q CORAL_COLOR_BG; or set -g CORAL_COLOR_BG '#1E1E2E'
    set -q CORAL_COLOR_DANGER; or set -g CORAL_COLOR_DANGER '#F38BA8'
    set -q CORAL_COLOR_MUTED; or set -g CORAL_COLOR_MUTED '#6C7086'
    set -q CORAL_COLOR_TEXT; or set -g CORAL_COLOR_TEXT '#CDD6F4'
    set -q CORAL_JIRA_KEY_PATTERN; or set -g CORAL_JIRA_KEY_PATTERN '[A-Z]+-[0-9]+'
    set -q CORAL_LIST_MODE; or set -g CORAL_LIST_MODE full
    set -q CORAL_PR_HISTORY_DAYS; or set -g CORAL_PR_HISTORY_DAYS 30

    set -g __coral_config_loaded 1
end
