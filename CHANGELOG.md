# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Types of changes:
  - **Added** for new features.
  - **Changed** for changes in existing functionality.
  - **Deprecated** for soon-to-be removed features.
  - **Removed** for now removed features.
  - **Fixed** for any bug fixes.
  - **Security** in case of vulnerabilities.

Please include the Github issue or pull request number when applicable

## [Unreleased]
## Added
- A way to get the scopes that Acts As Span defines on a class: `.span_scopes`
- Methods to get Arel nodes instead of ActiveRecord relations for the span class
  scopes:
  * `current` -> `current_condition`
  * `expired` (aka `past`) -> `expired_condition`
  * `future` -> `future_condition`

## 1.2.2
### Added
- A change log #31
### Fixed
- Syntax error in EndDatePropagator#propagate #30
