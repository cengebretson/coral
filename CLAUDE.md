# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Does

coral is a fish-shell git branch browser built on fzf. It lists local branches with GitHub PR status, an inline preview, Jira shortcuts, a Slack export, and tmux-aware branch actions (checkout, worktree, delete, rebase). PR enrichment is layered on via `gh`/`jq` and degrades gracefully when `origin` is not a GitHub remote or `gh` is unavailable.

## Layout

It is a Fisher plugin, so the source tree mirrors what Fisher installs:

```
functions/coral.fish      # entry point — arg parsing, fzf invocation, keybindings
functions/_coral_*.fish   # one private helper per file (autoloaded)
conf.d/coral.fish         # startup dependency warnings
completions/coral.fish    # `coral` completions
tests/*.test.fish         # fishtape suite
```

Fisher only installs `functions/`, `conf.d/`, and `completions/`. Anything at the repo root (`VERSION`, `README.md`, `CHANGELOG.md`) is **not** present at runtime — keep that in mind before relying on a root file from within a function.

## Development

Syntax-check everything before finishing:

```fish
fish -n functions/*.fish conf.d/*.fish completions/*.fish tests/*.fish
```

Run the test suite (this is also what CI and `git release` run):

```bash
tests/check.sh          # wraps: fish --private -c 'fishtape tests/*.test.fish'
```

The wrapper uses fish private mode for test isolation and treats TAP `not ok`
lines as failures even if the underlying `fishtape` process exits successfully.

`.release-sync` and `tests/check.sh` are bash; run `shellcheck` on them before finishing.

## Versioning and releases

SemVer. The version exists in **two** places that must stay in sync:

- `VERSION` — the canonical release file, bumped by `git release`.
- `functions/_coral_version.fish` — the runtime source (because the root `VERSION` file is not installed by Fisher).

`.release-sync` is a `git release` after-bump hook that rewrites `_coral_version.fish` from `VERSION`, so a release keeps them aligned automatically. `tests/version.test.fish` asserts the two match, so they cannot silently drift. Do not hand-edit `_coral_version.fish` to change the version — let a release do it.

**Keep the changelog current:** every user-facing change adds a bullet to the `## [Unreleased]` section of `CHANGELOG.md` in the same commit that makes the change. `git release` promotes and dates that section but does **not** author the notes — and it **blocks a release when `[Unreleased]` is empty** (override with `--allow-empty-changelog`), so write the notes as work lands.

Cut a release with `git release <x.y.z|major|minor|patch>` (bumps `VERSION`, runs `.release-sync`, promotes the changelog, runs the tests, commits, and tags). Pushing a `v*` tag triggers `.github/workflows/release.yml`, which re-runs the checks, verifies the tag matches both `VERSION` and `_coral_version`, and publishes a GitHub release from that version's changelog section.

## Configuration and conventions

User-facing settings are `CORAL_*` variables (see README for the full table), read in `_coral_load_config`. Code aims to stay cross-platform (macOS + Linux): use the existing patterns for `stat`, `date`, browser-open (`open`/`xdg-open`), and key labels rather than hardcoding a single OS.
