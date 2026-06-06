function _coral_popup --argument-names cmd title w h
    if test -z "$w"; set w 52; end
    if test -z "$h"; set h 5; end
    tmux display-popup -E -d "#{pane_current_path}" -w $w -h $h -T "$title" \
        -- fish -c "$cmd"
end
