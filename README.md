# ≈ ψ coral ψ ≈

Git branch browser for fish shell, built on fzf with GitHub PR status, inline preview, Jira shortcuts, Slack export, and tmux-aware branch actions.

## Install

Install the required tools first:

```fish
brew install fzf jq
fisher install PatrickF1/fzf.fish
```

Then install coral with Fisher:

```fish
fisher install cengebretson/coral
```

Run a quick health check:

```fish
coral --doctor
```

## Requirements

| Tool | Required | Notes |
|------|----------|-------|
| fish 3.3+ | yes | Coral is a fish plugin. |
| git | yes | Branch discovery and checkout. |
| fzf 0.57+ | yes | Coral uses modern fzf border flags. |
| fzf.fish | yes | Provides `_fzf_wrapper`. |
| jq | yes | Parses GitHub PR data. |
| gh | no | Adds GitHub PR enrichment when available and authenticated. |
| gum | no | Improves confirmation prompts. |
| tmux | no | Enables popup-friendly branch actions. |

PR actions are enabled only when `origin` is a GitHub remote. In non-GitHub repositories, coral keeps branch browsing, checkout, worktree, delete, and rebase behavior available without calling `gh`.

## Usage

Run `coral` inside a Git repository:

```fish
coral
```

Filter the initial branch list:

```fish
coral feature-name
```

Utility commands:

| Command | Action |
|---------|--------|
| `coral --doctor` | Print dependency, configuration, repo, cache, and GitHub auth diagnostics. |
| `coral --full [filter]` | Use the full branch list view for this run. |
| `coral --slack [filter ...]` | Print open local-branch PRs as Slack-friendly `<url|title>` links. |
| `coral --short [filter]` | Use the short branch list view for this run. |
| `coral --version` | Print the coral version. |

## Keybindings

| Key | Action |
|-----|--------|
| `?` | Toggle the help/keybinding header. |
| `Enter` | Checkout the selected branch, or go to its linked worktree when already checked out elsewhere. |
| `Ctrl-o` | Open the selected branch's GitHub PR. |
| `Ctrl-j` | Open the Jira issue parsed from the branch name. |
| `Ctrl-p` | Toggle the preview pane. |
| `Alt-e` | Rebase the selected branch. |
| `Alt-d` | Force-delete the selected local branch (`git branch -D`) after confirmation. Removes the branch even if it is not fully merged. |
| `Alt-r` | Clear this repo's PR cache, prune stale worktree metadata, and refresh the list. |

## Tips

- Use fzf inverse matching to hide tags or text. Type `!ready` to show rows that do not match `ready`, which is useful for finding PRs not ready for review.
- Combine fzf terms to narrow results. For example, `FLYWL !ready` shows rows matching `FLYWL` that do not match `ready`.
- Use `coral --short` when you want a quieter branch picker with just branch names and PR status.
- Use `coral --full` when filtering by labels or age, since full mode renders tags, stale markers, and ahead/behind counts into the searchable list.
- Press `Alt-r` after rebases or worktree cleanup. It clears Coral's PR cache, prunes stale worktree metadata, and reloads the list.
- Set `CORAL_LIST_MODE short` in `~/.config/coral/config.fish` if you usually prefer the compact view.

## Configuration

Coral reads optional native fish config from:

```text
$XDG_CONFIG_HOME/coral/config.fish
```

with fallback to:

```text
~/.config/coral/config.fish
```

Example:

```fish
set -g CORAL_JIRA_URL_TEMPLATE 'https://yourorg.atlassian.net/browse/{key}'
set -g CORAL_LIST_MODE full
set -g CORAL_PR_BATCH_SIZE 10
set -g CORAL_PR_HISTORY_DAYS 30
```

| Setting | Default | Purpose |
|---------|---------|---------|
| `CORAL_BASE_BRANCHES` | `develop main master release hotfix trunk staging` | Fish list for base branch detection. Values match exact branch names and `<value>/*` branch families. |
| `CORAL_CACHE_TTL` | `300` | Repo PR cache TTL in seconds. |
| `CORAL_JIRA_KEY_PATTERN` | `[A-Z]+-[0-9]+` | Regex used to parse Jira issue keys from branch names. |
| `CORAL_JIRA_URL_TEMPLATE` | unset | Jira URL template. Include `{key}`. |
| `CORAL_LIST_MODE` | `full` | Branch list density. Use `full` for the rich view or `short` for branch name plus PR status. |
| `CORAL_PR_BATCH_SIZE` | `10` | Number of branch-scoped PR lookups per cache refresh batch. |
| `CORAL_PR_HISTORY_DAYS` | `30` | How far back to include merged or closed PRs by update date. Set `0` for open PRs only. |
| `CORAL_COLOR_ACCENT` | `#CBA6F7` | Accent color for status badges. |
| `CORAL_COLOR_BG` | `#1E1E2E` | Background-oriented color used by prompts. |
| `CORAL_COLOR_DANGER` | `#F38BA8` | Danger color for destructive actions. |
| `CORAL_COLOR_MUTED` | `#6C7086` | Muted text color. |
| `CORAL_COLOR_TEXT` | `#CDD6F4` | Primary text color. |

Cache files live under `$XDG_CACHE_HOME/coral/pr`, with fallback to `~/.cache/coral/pr`.

## Worktrees

If the selected branch is already checked out in a linked worktree, coral avoids a duplicate checkout. Inside tmux, when the `tmux` command is available, it opens that worktree in a new tmux window. Otherwise, it changes the current shell to that worktree path.

## Jira

Set `CORAL_JIRA_URL_TEMPLATE` to enable `Ctrl-j`:

```fish
set -g CORAL_JIRA_URL_TEMPLATE 'https://yourorg.atlassian.net/browse/{key}'
```

The default branch key pattern is `[A-Z]+-[0-9]+`, so branches like `feature/ABC-123-widget` resolve to `ABC-123`.

## Development

Syntax-check the plugin:

```fish
fish -n functions/*.fish conf.d/*.fish completions/*.fish
```

Run the fishtape suite:

```fish
fishtape tests/*.test.fish
```
