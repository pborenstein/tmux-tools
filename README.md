# tmux-tools

A unified toolkit for tmux session management that provides session status displays, comprehensive overviews, and intelligent renaming capabilities through a single command interface.

## Quick Start

```bash
# Clone and make executable
git clone <repository-url>
cd tmux-tools
chmod +x tmux-tools

# Basic usage
./tmux-tools status              # Show session status table
./tmux-tools overview            # Show detailed session tree
./tmux-tools rename auto         # Smart rename sessions/windows
./tmux-tools help                # Show all available commands
```

## Overview

tmux-tools combines the functionality of multiple tmux utilities into a single, modular system:

- **Session Status Display**: Tabular view of all sessions, windows, and panes
- **Detailed Overview**: Tree-structured view with comprehensive session information
- **Smart Renaming**: Intelligent renaming of sessions and windows with conflict resolution
- **Configuration Management**: Customizable themes, naming pools, and display options
- **JSON Output**: Machine-readable format for scripting and automation

## Architecture

The project uses a unified command interface (`tmux-tools`) with modular libraries:

| Component | Purpose |
|:----------|:--------|
| `tmux-tools` | Main command interface and dispatcher |
| `lib/tmux_core.sh` | Core tmux interaction functions |
| `lib/tmux_display.sh` | Display formatting and output logic |
| `lib/tmux_colors.sh` | Color schemes and terminal formatting |
| `lib/tmux_config.sh` | Configuration management and YAML parsing |

Legacy scripts (`tmux-status.sh`, `tmux-overview`) remain available for backward compatibility.

## Commands

### Status Display

```bash
# Basic status table
tmux-tools status

# Detailed view with PIDs and paths
tmux-tools status --show-pid

# Session and window renaming
tmux-tools status --rename-defaults
tmux-tools status --rename-sessions
tmux-tools status --rename-windows
```

**Status Output Example:**
```
TMUX STATUS Fri Sep 26 22:42:45 EDT 2025

session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

### Session Overview

```bash
# Summary view (default)
tmux-tools overview

# Detailed tree view
tmux-tools overview --detailed

# Filter specific session
tmux-tools overview --session milan

# JSON output for scripting
tmux-tools overview --json
```

**Overview Output Example:**
```
Tmux Sessions Overview
2025-09-26 14:30:22

● lima (2025-09-24 23:31:12) [detached]
  ├─ 0:fox (1 panes)

● milan (2025-09-24 23:44:03) [attached]
  ├─ 0:otter (1 panes)
  ├─ 1:bear (1 panes)

Total: 2 sessions, 3 windows
```

### Smart Renaming

```bash
# Rename only default-named sessions
tmux-tools rename auto

# Rename all sessions to cities
tmux-tools rename sessions

# Rename all windows to mammals
tmux-tools rename windows
```

The rename system uses configurable name pools with intelligent conflict resolution - no ugly number suffixes, just moves to the next available name.

**Default Name Pools:**

| Pool | Names |
|:-----|:------|
| Cities | rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid |
| Mammals | cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse |

### Configuration Management

```bash
# Show current configuration
tmux-tools config show

# Create example config file
tmux-tools config create

# Edit configuration
tmux-tools config edit
```

**Configuration File Locations** (searched in order):
- `~/.tmux-tools.yaml`
- `~/.tmux-tools.yml`
- `~/.config/tmux-tools/config.yaml`
- `~/.config/tmux-tools/config.yml`
- `./tmux-tools.yaml`
- `./tmux-tools.yml`

## Command Reference

| Command | Description | Key Options |
|:--------|:------------|:------------|
| `status` | Tabular session status | `--show-pid`, `--rename-*` |
| `overview` | Tree-structured overview | `--detailed`, `--json`, `--session` |
| `rename` | Session/window renaming | `auto`, `sessions`, `windows` |
| `config` | Configuration management | `show`, `create`, `edit` |
| `help` | Command documentation | `[command]` for specific help |
| `version` | Version information | |

## Visual Indicators

### Status Display
- **Width Column (w)**: Terminal dimensions for device identification (89 = iPad, 142 = desktop)
- **Process Column (p)**: Pane index within window
- **Command Column (cmd)**: Running process in each pane

### Overview Display
- `●` Active/attached sessions, windows, or panes
- `[attached]` / `[detached]` Session attachment status
- `├─` / `└─` Tree structure indicators
- **Colors**: Blue sessions, yellow active windows, green active panes, purple commands

## JSON Output

The overview command supports JSON output for integration with other tools:

```bash
# Count total panes across all sessions
tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add'

# List all running commands
tmux-tools overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with more than 2 windows
tmux-tools overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'
```

## Installation

### Manual Installation
```bash
# Make main script executable
chmod +x tmux-tools

# Optionally symlink to PATH
ln -sf "$(pwd)/tmux-tools" /usr/local/bin/tmux-tools
```

### Verification
```bash
tmux-tools version
tmux-tools help
```

## Legacy Compatibility

The project maintains backward compatibility with original scripts:

| Legacy Script | Equivalent Command |
|:--------------|:-------------------|
| `./tmux-status.sh` | `tmux-tools status` |
| `./tmux-overview` | `tmux-tools overview` |

Legacy scripts continue to work with their original command-line interfaces.

## Requirements

- **tmux**: Must be installed with running sessions
- **bash**: Version 4.0 or later
- **Standard Unix tools**: date, sort, awk, sed
- **Optional**: jq for JSON processing examples

## Troubleshooting

### No tmux sessions found
Start a test session:
```bash
tmux new-session -d -s test
```

### Permission denied during installation
Use appropriate permissions for your target directory:
```bash
sudo ln -sf "$(pwd)/tmux-tools" /usr/local/bin/tmux-tools
```

### Colors not displaying
Most modern terminals support ANSI colors by default. Color output is automatically disabled when piping to other commands.

### Configuration issues
Check configuration file syntax and location:
```bash
tmux-tools config show
```

## Development

The modular architecture separates concerns:

- **Core Functions** (`tmux_core.sh`): Direct tmux API interaction
- **Display Logic** (`tmux_display.sh`): Formatting and presentation
- **Color Management** (`tmux_colors.sh`): Terminal color handling
- **Configuration** (`tmux_config.sh`): Settings and customization

The unified interface provides consistent command-line experience while maintaining separation between functional components.

## Documentation

### Complete Documentation

For comprehensive documentation, see the [`docs/`](docs/) directory:

| Document | Description |
|:---------|:------------|
| **[Architecture](docs/architecture.md)** | Detailed system design, component architecture, and extension points |
| **[Configuration](docs/configuration.md)** | Complete configuration reference with examples and best practices |
| **[Integration](docs/integration.md)** | Automation examples, JSON API, and workflow integration |
| **[Development](docs/development.md)** | Contributing guide, coding standards, and testing framework |
| **[Examples](docs/examples/)** | Practical usage examples and advanced workflows |

### Quick Reference

| Need | See |
|:-----|:----|
| **Getting started** | Quick Start section above |
| **Advanced usage** | [Integration Guide](docs/integration.md) |
| **Custom configuration** | [Configuration Reference](docs/configuration.md) |
| **Contributing** | [Development Guide](docs/development.md) |
| **System design** | [Architecture Documentation](docs/architecture.md) |
| **Real-world examples** | [Examples Directory](docs/examples/) |

## License

MIT License - See LICENSE file for details.