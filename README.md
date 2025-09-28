# tmux-tools

A comprehensive tmux session management toolkit that provides tabular status display, session overview, and intelligent renaming with a unified command interface.

## Features

### Core Capabilities

- **Unified Interface**: Single `tmux-tools` command with consistent options
- **Tabular Status Display**: Compact view of all sessions, windows, and panes
- **Comprehensive Overview**: Tree structure with summary and detailed views
- **Smart Renaming**: Intelligent session and window naming with city/mammal schemes
- **JSON Output**: Machine-readable format for scripting and automation
- **Configuration Support**: YAML-based configuration with custom name pools
- **Color Themes**: Multiple color schemes including accessibility options
- **Backward Compatibility**: Original scripts work unchanged

### Display Modes

- **Compact View**: Essential information in tabular format
- **Detailed View**: Full process and path information
- **Summary Overview**: Session counts and window structure
- **Tree Overview**: Complete hierarchy with pane details
- **JSON Export**: Structured data for integration

### Visual Indicators

- **Client Width Display**: Identifies device type (89 = iPad, 142+ = desktop)
- **Attachment Status**: Shows which sessions are actively connected
- **Active Markers**: Highlights current windows and panes
- **Color Coding**: Theme-aware status indication

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

## Command Reference

### tmux-tools Commands

```bash
tmux-tools <command> [options]
```

**Commands**:

- `status` - Tabular session status display
- `overview` - Comprehensive session overview
- `rename` - Session and window renaming
- `config` - Configuration management
- `help` - Show help information
- `version` - Show version information

### Status Command

```bash
tmux-tools status [options]
```

**Options**:

- `--show-pid` - Include process IDs and full paths
- `--rename-auto` - Rename default-named sessions before display
- `--rename-sessions` - Rename all sessions to city names
- `--rename-windows` - Rename all windows to mammal names

### Overview Command

```bash
tmux-tools overview [options]
```

**Options**:

- `--detailed`, `-d` - Show all panes with commands and paths
- `--json`, `-j` - Output in JSON format
- `--session NAME`, `-s` - Show only specified session

### Rename Command

```bash
tmux-tools rename <target> [options]
```

**Targets**:

- `sessions` - Rename all sessions to city names
- `windows` - Rename all windows to mammal names
- `auto` - Smart rename only default-named sessions

### Configuration Command

```bash
tmux-tools config <action>
```

**Actions**:

- `show` - Display current configuration
- `create` - Create example configuration file
- `edit` - Edit configuration file

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

| Variable | Default | Description |
|----------|---------|-------------|
| `TMUX_TOOLS_THEME` | "default" | Color theme |
| `TMUX_TOOLS_SESSION_POOL` | "cities" | Session naming pool |
| `TMUX_TOOLS_WINDOW_POOL` | "mammals" | Window naming pool |
| `NO_COLOR` | - | Disable colors when set |

## Naming Schemes

### Session Names (Cities)
rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid

### Window Names (Mammals)
cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse

### Conflict Resolution

- Sessions: Avoids conflicts by using next available city name
- Windows: Names only need to be unique within each session
- No number suffixes - moves to next available name

## Visual Indicators

### Status Symbols

- `*` - Active/attached sessions, windows, or panes
- `[attached]` - Session is currently connected
- `[detached]` - Session is running but not connected

### Tree Structure

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

### JSON Processing

```bash
# Count total panes across all sessions
tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add'

# List all running commands
tmux-tools overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with more than 2 windows
tmux-tools overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'
```

### Automation Examples

```bash
# Monitor session health
if tmux-tools overview --json | jq -e '.sessions | length > 0' >/dev/null; then
  echo "tmux is running with sessions"
else
  echo "No tmux sessions found"
fi

# Auto-organize sessions
tmux-tools rename auto  # Only rename default sessions
```

## Migration from Original Scripts

The refactored toolkit maintains complete backward compatibility:

### Existing Usage Still Works

```bash
# These commands work unchanged
./tmux-status.sh
./tmux-status.sh --rename-auto
./tmux-overview --detailed
./tmux-overview --json
```

### Migrating to Unified Interface

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

### Optional Dependencies

- **jq**: For JSON processing examples
- **YAML tools**: For advanced configuration editing

## Troubleshooting

### Common Issues

**No tmux sessions found**
```bash
# Start a test session
tmux new-session -d -s test
```

**Colors not displaying**
```bash
# Check terminal capabilities
echo $TERM

# Disable colors if needed
export NO_COLOR=1
tmux-tools status
```

**Configuration not loading**
```bash
# Check configuration file location
tmux-tools config show

# Create example configuration
tmux-tools config create
```

### Error Messages

- **"tmux not found"**: Install tmux package manager
- **"tmux server not running"**: Start tmux with `tmux new-session`
- **"Config file not found"**: Use `tmux-tools config create`

## Development

### Design Philosophy

The toolkit follows these principles:

- **Space Efficiency**: Compact layouts maximize screen real estate
- **Device Awareness**: Width column reveals connection type
- **Smart Defaults**: Hide rarely-needed information unless requested
- **Memorable Names**: City/mammal scheme avoids conflicts naturally
- **Backward Compatibility**: Preserve existing workflows

For detailed design rationale, see [docs/design-principles.md](docs/design-principles.md).

### Contributing

The modular architecture makes the codebase easy to extend:

- Core logic in `lib/` modules
- Display formatting separated from data logic
- Configuration system supports new options
- Color theming system ready for new themes

See [docs/roadmap.md](docs/roadmap.md) for planned enhancements.

## License

MIT License - see LICENSE file for details.