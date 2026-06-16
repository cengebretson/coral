# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

### Changed

- The Jira keybinding is only registered when `CORAL_JIRA_URL_TEMPLATE` is set,
  matching the help header.

[Unreleased]: https://github.com/cengebretson/coral/commits/main
