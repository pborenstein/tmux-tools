# Changelog

All notable changes to tmux-tools will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- **Control mode indicator redesign**
  - Removed separate control mode column (`c`) from status display
  - Control mode now indicated by underlining the attachment indicator (• or number)
  - More compact display with better visual integration
  - Updated `format_attachment_display()` to accept control_mode parameter
  - Removed `format_control_mode_display()` function (no longer needed)

## [1.3.0] - 2025-11-11

### Added
- **Control mode indicator** (`+`) for sessions with control mode clients
  - Displays in status view, overview (both summary and detailed)
  - Detects control mode via `#{client_control_mode}` flag or `0x0` client dimensions
  - New `get_session_control_mode()` function in `tmux_core.sh`
  - New `format_control_mode_display()` function in `tmux_display.sh`
- **Client information view** with `--show-clients` flag
  - Shows all tmux client connections including detached sessions
  - Displays TTY, created/activity timestamps (HH:MM format), dimensions, control mode, and user
  - Detached sessions shown with `-` placeholders for clarity
  - New `get_detailed_client_data()` function to fetch comprehensive client info
  - New `format_time_hhmm()` function for timestamp formatting
  - New `print_client_header()` and `print_client_row()` functions for client display
- **Client dimensions in WxH format**
  - Status view now shows dimensions as "172x53" instead of just width
  - New `get_current_client_size()` function for current client dimensions
  - Renamed `get_session_width()` to `get_session_size()` for WxH output
  - Updated `get_client_data()` to fetch both width and height

### Changed
- Status header column changed from "w" to "size" with adjusted spacing
- Control mode indicator changed from "C" to "+" for cleaner display
- Updated all display functions to handle control mode indicator parameter
- Client data now includes both width and height by default
- Created timestamp in client view displays without dark color for better visibility

### Fixed
- Empty TTY values for control mode clients now display as "-"
- All sessions shown in `--show-clients` view, including detached ones

## [1.2.0] - 2025-11-09

### Added
- **Configurable pager support** for help command with automatic detection
  - New `pager` configuration option in display section
  - Auto-detect mode: tries `glow`, then `bat`, falls back to `less`
  - Support for custom pagers: `glow`, `bat`, `less`, `cat`, or any custom command
  - Smart colorization: applies custom colors only for `less`/`cat`, uses native rendering for `glow`/`bat`
  - Environment variable `TMUX_TOOLS_PAGER` for runtime override
- **Color support in help command**
  - H1 headings colored with HIGHLIGHT_COLOR (purple in default theme)
  - H2 headings colored with INFO_COLOR (blue in default theme)
  - Table headers and separators colored with ACTIVE_COLOR (green in default theme)
  - `colorize_markdown()` function for markdown syntax highlighting
  - Respects existing theme system and `NO_COLOR` environment variable

### Changed
- Updated `tt help` and `tt help <topic>` to use configurable pager
- Help output now displays with beautiful markdown rendering when `glow` is available
- Updated configuration documentation in README.md
- Updated example configuration file with pager options
- `tt config show` now displays current pager setting

### Fixed
- Color support when piping through pagers (force mode for `colorize_markdown`)
- Terminal detection for color output in pipeline scenarios

## [1.1.1] - 2025-11-08

### Changed
- Updated README output section with improved examples

## [1.1.0] - 2025-11-08

### Added
- Usability improvements to application
- Enhanced command aliases and shortcuts
- Improved error messaging

### Changed
- Cleaned up documentation directory structure
- Reorganized documentation files to uppercase naming

## [1.0.0] - 2025-11-07

### Added
- Initial stable release
- `tmux-tools status` command for compact session display
- `tmux-tools overview` command for tree-style session view
- `tmux-tools rename` command for smart session/window renaming
- `tmux-tools config` command for configuration management
- `tmux-tools help` command for tmux command reference
- Theme support (default, vibrant, subtle, monochrome, none)
- YAML configuration file support
- City names for session naming
- Directory-based window naming
- JSON output support for scripting
- Short `tt` alias for all commands
- Comprehensive documentation
  - README.md with quick start and examples
  - ARCHITECTURE.md with technical details
  - DESIGN-PRINCIPLES.md with project philosophy
  - TROUBLESHOOTING.md with common issues
  - ROADMAP.md with future plans
  - CONTRIBUTING.md with development guidelines

### Features
- Tabular display fits more information on screen
- Smart renaming: cities for sessions, directory names for windows
- Client width column shows device type detection
- Built-in tmux command reference
- Multiple color schemes
- Backward compatible with original scripts

[1.3.0]: https://github.com/pborenstein/tmux-tools/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/pborenstein/tmux-tools/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/pborenstein/tmux-tools/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/pborenstein/tmux-tools/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/pborenstein/tmux-tools/releases/tag/v1.0.0
