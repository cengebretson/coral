function _coral_list --argument-names list_mode
    _coral_load_config
    test -n "$list_mode"; or set list_mode (_coral_list_mode)
    contains -- "$list_mode" short full; or set list_mode full

    set -f base_branch (_coral_base_branch); or return 1

    # Missing origin only disables PR enrichment; branch browsing should still work.
    set -f cache_file (_coral_cache_file)
    set -f cache_ttl (_coral_cache_ttl)
    set -f github_repo 0
    if _coral_is_github_repo
        set github_repo 1
    end

    set -f wt_branches (_coral_worktree_list | awk -F'\t' '{sub("refs/heads/", "", $1); print $1}')

    set -f current (git branch --show-current 2>/dev/null)

    # Single git call: branch name + relative date + upstream tracking (free, no extra subprocess)
    # Filter in fish rather than grep to avoid regex metachar issues with branch names
    # Use :track (e.g. "[ahead 1, behind 2]") not :trackshort (which is only =/>/<) so the
    # full-mode ahead/behind counts below have actual numbers to parse.
    set -f branch_data_all (git branch --sort=-committerdate \
        --format='%(refname:short)%09%(committerdate:relative)%09%(upstream:track)%09%(objectname)')
    set -f branch_data
    for line in $branch_data_all
        set -f _b (string split \t $line)[1]
        if test "$_b" = "$current"; or not _coral_is_base_branch "$_b"
            set -f branch_data $branch_data $line
        end
    end

    # Extract branch names and compute col_width in one pass
    set -f branches
    set -f branch_shas
    set -f col_width 0
    for line in $branch_data
        set -f parts (string split \t $line)
        set -f b $parts[1]
        set -f sha $parts[4]
        set -f branches $branches $b
        set -f branch_shas $branch_shas $sha
        set -f len (string length $b)
        if test $len -gt $col_width
            set -f col_width $len
        end
    end
    set -f col_width (math $col_width + 2)

    set -f pr_entries
    set -f cache_stale 0
    set -f cache_age
    if test -n "$cache_file"; and test -f $cache_file
        # Separate stat from math so a missing mtime doesn't produce a bad cache_age
        set -f mtime (_coral_file_mtime "$cache_file")
        if test -n "$mtime"
            set -f cache_age (math (date +%s) - $mtime)
            set -f pr_entries (cat $cache_file)
            if test $cache_age -ge $cache_ttl
                set cache_stale 1
            end
        end
    end

    # Validate cached entries have the branch-aware format:
    # branch, local sha, state, review, labels, title, base, url.
    if test -n "$pr_entries"
        set -f valid_entries
        for entry in $pr_entries
            if test (count (string split \x01 $entry)) -ge 8
                set -f valid_entries $valid_entries $entry
            end
        end
        set -f pr_entries $valid_entries
    end

    set -f pr_keys
    set -f pr_vals
    set -f fetch_pairs
    for idx in (seq (count $branches))
        set -f branch $branches[$idx]
        set -f sha $branch_shas[$idx]
        set -f cached_line ''
        if set -f pr_idx (contains --index -- $branch $pr_keys)
            set cached_line $pr_vals[$pr_idx]
        else if test -n "$pr_entries"
            for entry in $pr_entries
                set -f cached_parts (string split \x01 $entry)
                if test "$cached_parts[1]" = "$branch"
                    set cached_line $entry
                    break
                end
            end
        end

        if test -n "$cached_line"
            set -f cached_parts (string split \x01 $cached_line)
            if test "$cached_parts[2]" = "$sha"
                set pr_keys $pr_keys $branch
                set pr_vals $pr_vals $cached_line
                if test "$cache_stale" = 0
                    continue
                end
            end
        end

        set fetch_pairs $fetch_pairs $branch $sha
    end

    if test (count $fetch_pairs) -gt 0; and test -n "$cache_file"; and test "$github_repo" = 1
        if not command -q gh
            printf 'coral: gh not found — install the GitHub CLI for PR status\n' >&2
        else
            set -f fetched_entries (_coral_pr_entries $fetch_pairs)
            if test -n "$fetched_entries"
                for entry in $fetched_entries
                    set -f fetched_parts (string split \x01 $entry)
                    if set -f fetched_idx (contains --index -- $fetched_parts[1] $pr_keys)
                        set pr_vals[$fetched_idx] $entry
                    else
                        set pr_keys $pr_keys $fetched_parts[1]
                        set pr_vals $pr_vals $entry
                    end
                end

                set -f cache_tmp $cache_file.tmp
                printf '%s\n' $pr_vals > $cache_tmp && mv $cache_tmp $cache_file
                set cache_stale 0
            else
                printf 'coral: no PR data returned — run gh auth login if not authenticated\n' >&2
            end
        end
    end

    for line in $branch_data
        set -f parts (string split \t $line)
        set -f branch $parts[1]
        set -f age $parts[2]
        set -f track $parts[3]

        set -f pr_line ''
        set -f pr_state ''
        set -f pr_review ''
        set -f pr_labels ''
        if set -f pr_idx (contains --index -- $branch $pr_keys)
            set -f pr_line $pr_vals[$pr_idx]
        end

        if contains -- $branch $wt_branches
            set -f wt_marker (printf '\e[33m󰙅\e[0m ')
        else
            set -f wt_marker '  '
        end

        if test -n "$pr_line"
            set -f pr_parts (string split \x01 $pr_line)
            set -f pr_state $pr_parts[3]
            set -f pr_review $pr_parts[4]
            set -f pr_labels $pr_parts[5]
        end

        if test -n "$pr_state"
            set -f pr_display (string split \t (_coral_pr_status_display "$pr_state" "$pr_review"))
            set -f dot_color $pr_display[2]
            set -f dot $pr_display[3]
        end

        if test "$list_mode" = short
            set -f suffix $wt_marker
            if test -n "$pr_state"
                set suffix (printf '%s'"$dot_color"'%s\e[0m' $wt_marker $dot)
            end
        else if test -n "$pr_state"
            set -f suffix (printf '%s'"$dot_color"'%s\e[0m  %s' $wt_marker $dot $age)
            if test -n "$pr_labels"
                for label in (string split , $pr_labels)
                    set suffix $suffix(printf '  \e[2m[%s]\e[0m' $label)
                end
            end
            if test "$cache_stale" = 1
                set suffix $suffix(printf '  \e[2m[stale]\e[0m')
            end
        else
            set -f suffix (printf '%s   %s' $wt_marker $age)
        end

        if test "$list_mode" = full
            set -f ahead (string match -r 'ahead ([0-9]+)' $track)[2]
            set -f behind (string match -r 'behind ([0-9]+)' $track)[2]
            if test -n "$ahead"
                set suffix $suffix(printf '  \e[36m↑%s\e[0m' $ahead)
            end
            if test -n "$behind"
                set suffix $suffix(printf '  \e[33m↓%s\e[0m' $behind)
            end
        end

        set -f padded (string pad -r -w $col_width $branch)
        if test "$branch" = "$current"
            printf '%s\t\e[1;36m▶ %s  %s\e[0m\n' $branch $padded $suffix
        else
            printf '%s\t  %s  %s\n' $branch $padded $suffix
        end
    end
end
