# Shim for the non-tmux fzf bind path in coral.fish:
#   'alt-d:execute(_coral_force_delete_branch {1})+reload(_coral_list)'
# Named wrapper needed because fzf execute() parses the command by whitespace,
# so calling _coral_delete_common directly from the bind is awkward to escape.
function _coral_force_delete_branch --argument-names branch
    _coral_delete_common "$branch"
end
