function _coral_open_jira --argument-names branch
    _coral_load_config

    set -f key (string match -r (_coral_jira_pattern) "$branch")
    if test -z "$key"
        echo "coral: no Jira key found in branch: $branch" >&2
        return 1
    end

    set -f url (_coral_jira_url "$key")
    if test -z "$url"
        echo "coral: CORAL_JIRA_URL_TEMPLATE is not set" >&2
        return 1
    end

    # macOS uses `open`; Linux uses `xdg-open`. Match the cross-platform handling
    # the rest of coral already does (stat, date, key labels).
    if command -q open
        open "$url" 2>/dev/null
        or echo "coral: could not open browser" >&2
    else if command -q xdg-open
        xdg-open "$url" >/dev/null 2>&1
        or echo "coral: could not open browser" >&2
    else
        echo "coral: no browser opener found (need open or xdg-open)" >&2
        return 1
    end
end
