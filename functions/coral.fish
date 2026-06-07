function coral --description "Browse local branches with fzf"
    _coral_load_config

    if test (count $argv) -gt 0
        switch $argv[1]
            case --doctor
                _coral_doctor
                return $status
            case --version
                _coral_version
                return 0
            case --slack
                _coral_slack $argv[2..]
                return $status
        end
    end

    set -f list_mode (_coral_list_mode)
    set -f query_terms
    for arg in $argv
        switch $arg
            case --short
                set list_mode short
            case --full
                set list_mode full
            case '*'
                set query_terms $query_terms $arg
        end
    end

    if not _coral_check_dependencies
        return 1
    end

    if not git rev-parse --git-dir >/dev/null 2>&1
        echo 'coral: not in a git repository.' >&2
        return 1
    end

    set -f use_tmux 0
    if test -n "$TMUX"; and command -q tmux
        set use_tmux 1
    end

    # In tmux: execute-silent + popup keeps fzf visible.
    # Outside tmux: execute (blocking) runs the action inline.
    if test "$use_tmux" = 1
        set -f force_bind "alt-D:execute-silent(_coral_run_delete {1} force)+reload(_coral_list $list_mode)"
        set -f rebase_bind "alt-e:execute-silent(_coral_run_rebase {1})+reload(_coral_list $list_mode)"
        set -f extra_flags
    else
        set -f force_bind "alt-D:execute(_coral_force_delete_branch {1})+reload(_coral_list $list_mode)"
        set -f rebase_bind "alt-e:execute(_coral_rebase {1})+reload(_coral_list $list_mode)"
        set -f extra_flags
    end

    set -f query_flags
    if test (count $query_terms) -gt 0
        set -f query_flags --query (string join ' ' $query_terms)
    end

    set -f preview_toggle 'ctrl-p:toggle-preview'
    set -f help_toggle '?:toggle-header'
    set -f alt_key_label (_coral_alt_key_label)

    set -f jira_flags --bind 'ctrl-j:execute(_coral_open_jira {1})'
    set -f header_lines \
        "checkout  Enter   checkout branch or open linked worktree" \
        "pr        Ctrl-o  open GitHub PR"
    if set -q CORAL_JIRA_URL_TEMPLATE; and test -n "$CORAL_JIRA_URL_TEMPLATE"
        set header_lines $header_lines "jira      Ctrl-j  open Jira issue from branch name"
    end
    set header_lines $header_lines \
        "preview   Ctrl-p  toggle preview pane" \
        "rebase    $alt_key_label-e   rebase selected branch" \
        "delete    $alt_key_label-D   delete selected branch" \
        "refresh   $alt_key_label-r   clear cache, prune worktrees, reload"
    set -f header (string join \n $header_lines | string collect)

    # Strip input-border and list-border from global FZF_DEFAULT_OPTS — coral owns its layout.
    set -lx FZF_DEFAULT_OPTS (string replace --regex --all -- '--(?:input|list)-border\S*' '' "$FZF_DEFAULT_OPTS")

    set -f result (_coral_list $list_mode \
        | _fzf_wrapper \
            $extra_flags \
            $query_flags \
            --ansi \
            --layout=default \
            --border=none \
            --input-border=none \
            --list-border=none \
            --header-border=line \
            --header-label=' Help ' \
            --info=inline-right \
            --delimiter='\t' \
            --with-nth=2 \
            --bind 'start:hide-header' \
            --bind $preview_toggle \
            --bind $help_toggle \
            --bind 'ctrl-o:execute(_coral_open_pr {1})' \
            $jira_flags \
            --bind $force_bind \
            --bind "alt-r:execute(_coral_refresh)+reload(_coral_list $list_mode)" \
            --bind $rebase_bind \
            --prompt="Branch (? help)> " \
            --preview='_coral_preview {1}' \
            --preview-window='right:55%:wrap:border-left' \
            --header=$header
    )

    test (count $result) -eq 0; and return

    set -f branch (string split \t $result[1])[1]

    test -z "$branch"; and return

    set -f wt_path (_coral_worktree_path "$branch")
    if test -n "$wt_path"
        if test "$use_tmux" = 1
            tmux new-window -c "$wt_path"
        else
            echo "coral: branch is already checked out in linked worktree"
            cd "$wt_path"
            and pwd
        end
    else
        git checkout "$branch"
        or echo "coral: could not check out '$branch'" >&2
    end
end
