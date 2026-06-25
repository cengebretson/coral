# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- PR enrichment now fetches status with two bulk `gh pr list` calls (all open
  PRs, plus the merged/closed history window) instead of one `gh pr list --head`
  call per branch, so a refresh is a constant number of round-trips regardless
  of how many local branches you browse, and a single slow lookup can no longer
  stall a batch. PR status (open kept regardless of age, recent closed/merged,
  no-PR misses) is unchanged.
- `git worktree list --porcelain` parsing is now consolidated in a single
  `_coral_worktree_entries` helper that the linked-only list and the per-branch
  path lookups build on, instead of three near-identical awk copies.
- The Slack export and preview ahead/behind check reuse shared helpers and
  chained `test` conditions; the startup warning escapes its message with `--`.
  No user-facing behavior change.

### Removed

- `CORAL_PR_BATCH_SIZE` (and the `_coral_pr_batch_size` helper). The bulk PR
  fetch no longer runs per-branch parallel batches, so the setting had no
  effect; it is no longer read.

## [0.3.4] - 2026-06-24

### Fixed

- Dirty linked worktree deletion now offers a second explicit confirmation to
  force-remove the worktree and delete the local branch, instead of stopping
  after Git rejects the plain removal.

### Tests

- Added delete coverage for dirty linked worktrees when force removal is
  accepted or declined.

## [0.3.3] - 2026-06-23

### Fixed

- `Alt-d` can now delete a branch checked out in a linked worktree. coral removes
  the worktree first, then deletes the branch, instead of silently failing on
  git's "used by worktree" refusal. A dirty worktree is left intact (the delete
  is refused with git's reason) so uncommitted work is never destroyed.
- Deleting or opening a branch whose worktree directory was removed but never
  pruned (a stale entry) no longer errors. coral prunes the dead record and then
  deletes or checks out the branch.
- Deleting or checking out a branch that is checked out in the main worktree now
  fails with a clear message naming the worktree path, instead of a raw git
  error, and never auto-removes the primary checkout.
- The tmux worktree-open path reports an error when `tmux new-window` fails
  instead of failing silently.

### Tests

- Added coverage for `_coral_branch_checkout_path`, which resolves the main and
  linked worktree paths and is empty for an unchecked-out branch.

## [0.3.2] - 2026-06-17

### Fixed

- Restored the original checkout after rebasing a selected non-current branch.
- Made the test runner fail when TAP output contains `not ok`, even if the
  underlying `fishtape` process exits successfully.
- Quoted PR cache paths and centralized cache reads/writes to keep cache access
  safe for XDG paths containing spaces.

### Tests

- Added rebase coverage for restoring the original branch after rebasing a
  selected branch.

## [0.3.1] - 2026-06-15

### Changed

- Clarified that `Alt-d` force-deletes (`git branch -D`, removing unmerged
  branches) in the help header and README — the behavior was already force-delete
  with a force-labeled confirmation. Removed the unreachable safe-delete code path.

### Performance

- The preview no longer runs a `gh pr view` (a ~0.4s network round-trip) on every
  cursor move; it reads the PR data the branch list already cached, falling back
  to a live lookup only on a cache miss. Scrolling is now instant.
- The branch list paints instantly from cache on launch, then enriches with PR
  data via a background reload, instead of blocking on the initial fetch.
- The delete prompt and rebase reuse cached PR data instead of making their own
  `gh` calls.
- Cache-to-branch matching in the list is no longer quadratic (it pre-splits the
  cached rows once instead of re-splitting every row for every branch).

## [0.3.0] - 2026-06-15

### Added

- A `VERSION` file and a tag-triggered release workflow that verifies the tag
  against `VERSION` and `_coral_version`, runs the test suite, and publishes a
  GitHub release from this changelog.
- Bordered, toggleable fzf help header for the branch picker.

### Fixed

- Full-mode ahead/behind counts now render. The branch list read
  `%(upstream:trackshort)` (only `=`/`>`/`<`) but parsed it for numbers, so the
  `↑`/`↓` counts never appeared; it now reads `%(upstream:track)`.
- The Jira shortcut works on Linux, falling back to `xdg-open` when `open` is
  unavailable instead of always failing.
- Cache staleness works on Linux. `_coral_file_mtime` tried BSD `stat -f` first,
  but GNU `stat -f` prints filesystem info instead of erroring, so the mtime was
  garbage; it now tries GNU `stat -c` first and validates the result is numeric.

### Changed

- The Jira keybinding is only registered when `CORAL_JIRA_URL_TEMPLATE` is set,
  matching the help header.

[Unreleased]: https://github.com/cengebretson/coral/compare/v0.3.4...HEAD
[0.3.4]: https://github.com/cengebretson/coral/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/cengebretson/coral/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/cengebretson/coral/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/cengebretson/coral/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/cengebretson/coral/releases/tag/v0.3.0
