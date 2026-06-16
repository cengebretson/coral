# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/cengebretson/coral/compare/v0.3.1...HEAD
[0.3.1]: https://github.com/cengebretson/coral/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/cengebretson/coral/releases/tag/v0.3.0
