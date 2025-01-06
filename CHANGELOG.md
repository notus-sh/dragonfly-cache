# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

* Add Ruby 3.4 to the test matrix (#20)
* Update test matrix (#14)  
  Add Ruby 3.3. Drop Ruby 2.6 and Ruby 2.7
* Migrate from Travis CI to Github Actions
* Add Ruby 3.2 to the test matrix
* Introduce `rubocop-performance` and simplify configuration

### Fixed

* Fix tests to be compatible Dragonfly 1.4

## Version 0.1.8 (2021-04-03)

### Breaking changes

* Drop support for Ruby 2.5

### Changed

* Compatibility with Ruby 3.0

## Version 0.1.7 (2020-11-02)

### Breaking changes

* Drop support for Ruby < 2.5

### Added

* Introduce Travis CI to run unit tests on all supported Ruby versions

## Version 0.1.6 (2019-04-29)

### Changed

* Loosen version constraint to Dragonfly

## Version 0.1.5 (2018-12-17)

### Fixed

* Strengthen cache key validation to avoid collisions (#1)

## Version 0.1.4 (2018-10-08)

### Fixed

* Load existing map on startup

## Version 0.1.3 (2018-09-13)

### Fixed

* Ensure job are only processed once

### Other changes

* Refactor cache logic

## Version 0.1.2 (2018-09-07)

### Fixed

* Ensure normalized filenames keep their extension

## Version 0.1.1 (2018-09-07)

### Added

* Add automatic filenames cleaning

## Version 0.1.0 (2028-09-07)

Initial release.
