# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.0] - 2025-03-25
- feat: add ps3 platform for coolrom repo
- feat: add new platforms for vimm repo (Sega 32X, Atari 2600, Atari 5200, Atari 7800, Game Gear, Lynx, Sega CD, Master System, TurboGrafx-16, TurboGrafx-CD, Virtual Boy, XBox, XBox 360)
- feat: remove deprecated romnation repo
- feat: use ruby 3.4.2 and update all dependencies
- feat: format progress bars (colored pacman style)
- feat: handle SIGINT and SIGTERM
- fix: vimm repo game install
- fix: coolrom repo broken progress
- fix: vimm repo unable to get local issuer
- fix: vimm repo update datase (404 not found)

## [0.4.1] - 2021-05-18
- Enables specifying game identifier without using quotes

## [0.4.0] - 2021-05-18
- Refactor code #2
- Fix all rubocop errors/warnings
- Run executable inside container as the same userID/groupID than host user
- Fix info when game not found
- Update to ruby version 3.0.1
- Add `--install` option to search command for installing all games from the search results #3

## [0.3.0] - 2021-05-14
- Use progress bar on the update database commands
- Add romnation repo

## [0.2.2] - 2021-05-09
- Fix download from some vimm’s repo platforms

## [0.2.1] - 2021-05-09
- Fix downloading of multiple disk ROMs

## [0.2.0] - 2021-05-08
- Add support for downloading multiple disc ROMs on vimm repo
- Add progress bar to the install process

## [0.1.0] - 2021-05-07
- Initial release

[Unreleased]: https://github.com/lucasmundim/gamerom/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/lucasmundim/gamerom/compare/v0.4.1...v0.5.0
[0.4.1]: https://github.com/lucasmundim/gamerom/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/lucasmundim/gamerom/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/lucasmundim/gamerom/compare/v0.2.2...v0.3.0
[0.2.2]: https://github.com/lucasmundim/gamerom/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/lucasmundim/gamerom/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/lucasmundim/gamerom/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/lucasmundim/gamerom/releases/tag/v0.1.0
