# coral

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
| curl | no | Used for fzf reloads in tmux mode. |

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
| `coral --slack [filter ...]` | Print open local-branch PRs as Slack-friendly `<url|title>` links. |
| `coral --version` | Print the coral version. |

## Keybindings

| Key | Action |
|-----|--------|
| `Enter` | Checkout the selected branch, or go to its linked worktree when already checked out elsewhere. |
| `Ctrl-o` | Open the selected branch's GitHub PR. |
| `Ctrl-j` | Open the Jira issue parsed from the branch name. |
| `Ctrl-p` | Toggle the preview pane. |
| `Alt-e` | Rebase the selected branch. |
| `Alt-D` | Delete the selected branch after confirmation. |
| `Alt-r` | Clear this repo's PR cache and refresh the list. |

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
set -g CORAL_PR_BATCH_SIZE 10
set -g CORAL_PR_HISTORY_DAYS 30
```

| Setting | Default | Purpose |
|---------|---------|---------|
| `CORAL_BASE_BRANCHES` | `develop\|main\|master\|release/\|hotfix/` | ERE alternation for base branch detection. |
| `CORAL_CACHE_TTL` | `300` | Repo PR cache TTL in seconds. |
| `CORAL_JIRA_KEY_PATTERN` | `[A-Z]+-[0-9]+` | Regex used to parse Jira issue keys from branch names. |
| `CORAL_JIRA_URL_TEMPLATE` | unset | Jira URL template. Include `{key}`. |
| `CORAL_PR_BATCH_SIZE` | `10` | Number of branch-scoped PR lookups per cache refresh batch. |
| `CORAL_PR_HISTORY_DAYS` | `30` | How far back to include merged or closed PRs by update date. Set `0` for open PRs only. |
| `CORAL_COLOR_ACCENT` | `#CBA6F7` | Accent color for status badges. |
| `CORAL_COLOR_BG` | `#1E1E2E` | Background-oriented color used by prompts. |
| `CORAL_COLOR_DANGER` | `#F38BA8` | Danger color for destructive actions. |
| `CORAL_COLOR_MUTED` | `#6C7086` | Muted text color. |
| `CORAL_COLOR_TEXT` | `#CDD6F4` | Primary text color. |

Cache files live under `$XDG_CACHE_HOME/coral/pr`, with fallback to `~/.cache/coral/pr`.

## Worktrees

If the selected branch is already checked out in a linked worktree, coral avoids a duplicate checkout. Inside tmux, it opens that worktree in a new tmux window. Outside tmux, it changes the current shell to that worktree path.

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
