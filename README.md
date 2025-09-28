# tmux-tools

A tmux session management toolkit that provides tabular status display, session overview, and intelligent renaming with a unified command interface.

## Features

- Single `tmux-tools` command with consistent options
- Compact tabular view of all sessions, windows, and panes
- Tree structure with summary and detailed views
- Session and window naming with city/mammal schemes
- JSON output for scripting and automation
- YAML-based configuration with custom name pools
- Multiple color schemes including accessibility options
- Client width display identifies device type (89 = iPad, 142+ = desktop)
- Shows which sessions are actively connected
- Original scripts work unchanged

## Quick Start

### Basic Usage

```bash
# Unified interface (recommended)
tmux-tools status                    # Compact tabular view
tmux-tools overview                  # Session summary
tmux-tools overview --detailed       # Full tree with panes
tmux-tools rename auto               # Smart renaming

# Original scripts (backward compatible)
./tmux-status.sh                     # Traditional status display
./tmux-overview                      # Traditional overview
```

### Installation

```bash
# Make executable and add to PATH
chmod +x tmux-tools tmux-status.sh tmux-overview

# Optional: Create configuration
tmux-tools config create
```

## Usage

```bash
tmux-tools <command> [options]
```

| Command | Purpose | Key Options |
|---------|---------|-------------|
| `status` | Tabular session display | `--show-pid`, `--rename-auto` |
| `overview` | Tree overview | `--detailed`, `--json`, `-s <session>` |
| `rename` | Session/window renaming | `sessions`, `windows`, `auto` |
| `config` | Configuration management | `show`, `create`, `edit` |

Common patterns:
```bash
tmux-tools status                    # Quick status check
tmux-tools overview --detailed       # Full session tree
tmux-tools rename auto               # Clean up default names
tmux-tools config create             # Generate config file
```

## Output Examples

### Compact Status View

```
TMUX STATUS Fri Sep 27 14:30:22 EDT 2025

session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

### Detailed Status View

```bash
tmux-tools status --show-pid
```

```
session       win  name      p  cmd      w    pid    path
-------       ---  --------  -  -------  ---  -----  ----
oslo          0    elk       0  fish     142  55066  /Users/philip/projects/tmux-tools
              0              1  fish          54634  /Users/philip/projects/tmux-tools
              1    cat       0  node          55294  /Users/philip/Obsidian/amoxtli
milan         0    mouse     0  fish     89   55586  /Users/philip/Obsidian
```

### Overview Summary

```bash
tmux-tools overview
```

```
Tmux Sessions Overview
2025-09-27 14:30:22

* lima (2025-09-24 23:31:12) [detached]
    - 0:fox (1 panes)

* milan (2025-09-24 23:44:03) [attached]
    - 0:otter (1 panes)
    - 1:bear (1 panes)

* oslo (2025-09-24 23:30:47) [attached]
    - 0:seal (3 panes) [active]
    - 1:bear (1 panes)

Total: 3 sessions, 5 windows
```

### JSON Output

```bash
tmux-tools overview --json
```

```json
{
  "sessions": [
    {
      "name": "oslo",
      "created": "2025-09-24 23:30:47",
      "attached": true,
      "windows": [
        {
          "index": 0,
          "name": "seal",
          "panes": 3,
          "active": true,
          "pane_details": [
            {
              "index": 0,
              "command": "fish",
              "path": "/Users/philip/projects/tmux-tools",
              "active": false
            }
          ]
        }
      ]
    }
  ]
}
```

## Configuration

### Configuration File

Create `~/.tmux-tools.yaml` for customization:

```yaml
# tmux-tools configuration
display:
  theme: "default"              # default, vibrant, subtle, monochrome, none
  attachment_indicator: "*"     # Character to show attached sessions
  colors_enabled: true          # Enable/disable color output

naming:
  session_pool: "cities"        # cities, custom
  window_pool: "mammals"        # mammals, custom

  custom_sessions:
    - "dev"
    - "work"
    - "personal"

  custom_windows:
    - "editor"
    - "terminal"
    - "browser"

output:
  default_format: "compact"     # compact, detailed
  show_timestamps: true         # Show timestamps in headers
  group_sessions: true          # Group windows by session
```

### Environment Variables

Configuration can also be controlled via environment variables:

| Variable | Default | Purpose |
|----------|---------|-------------|
| `TMUX_TOOLS_THEME` | "default" | Color theme |
| `TMUX_TOOLS_SESSION_POOL` | "cities" | Session naming pool |
| `TMUX_TOOLS_WINDOW_POOL` | "mammals" | Window naming pool |
| `NO_COLOR` | - | Disable colors when set |

## Naming Schemes

Sessions use city names: rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid

Windows use mammal names: cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse

Conflicts are resolved by using the next available name. Windows only need unique names within each session. No number suffixes are added.

## Display Reference

### Status Symbols

- `*` - Active/attached sessions, windows, or panes
- `[attached]` - Session is currently connected
- `[detached]` - Session is running but not connected
- Indentation shows hierarchy structure
- Active items marked with [active]

### Color Themes

- **default**: Balanced colors for general use
- **vibrant**: Bright colors for high-contrast displays
- **subtle**: Muted colors for professional environments
- **monochrome**: Single color for accessibility
- **none**: No colors for scripting/automation

## Architecture

The toolkit uses a modular library architecture:

```
tmux-tools/
- lib/
    - tmux_core.sh      # Core tmux operations
    - tmux_display.sh   # Display formatting
    - tmux_colors.sh    # Color management
    - tmux_config.sh    # Configuration handling
- tmux-tools            # Unified command interface
- tmux-status.sh        # Backward compatible script
- tmux-overview         # Backward compatible script
```

For detailed technical information, see [docs/architecture.md](docs/architecture.md).

## Scripting and Integration

JSON output enables integration with other tools:

```bash
# Count total panes across all sessions
tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add'

# List all running commands
tmux-tools overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with more than 2 windows
tmux-tools overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'

# Monitor session health
if tmux-tools overview --json | jq -e '.sessions | length > 0' >/dev/null; then
  echo "tmux is running with sessions"
fi

# Auto-organize sessions
tmux-tools rename auto
```

## Migration from Original Scripts

Original scripts work unchanged. To use the unified interface:

```bash
# Old → New
./tmux-status.sh              → tmux-tools status
./tmux-status.sh --show-pid   → tmux-tools status --show-pid
./tmux-overview               → tmux-tools overview
./tmux-overview --detailed    → tmux-tools overview --detailed
```

## Requirements

- **tmux**: Session manager (any recent version)
- **bash**: Version 4.0 or later
- **Standard Unix tools**: date, sort, etc.

Optional: **jq** for JSON processing, **YAML tools** for advanced configuration editing

## Troubleshooting

**No tmux sessions found**: Start a session with `tmux new-session -d -s test`

**Colors not displaying**: Check terminal with `echo $TERM` or disable with `export NO_COLOR=1`

**Configuration not loading**: Check location with `tmux-tools config show` or create with `tmux-tools config create`

**"tmux not found"**: Install tmux
**"tmux server not running"**: Start tmux with `tmux new-session`
**"Config file not found"**: Use `tmux-tools config create`

## Development

The modular architecture makes extension straightforward. Core logic lives in `lib/` modules with separated display formatting. The configuration system supports new options and the color theming system accommodates new themes.

See [docs/design-principles.md](docs/design-principles.md) for design rationale and [docs/roadmap.md](docs/roadmap.md) for planned enhancements.

## License

MIT License - see LICENSE file for details.