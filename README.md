# tmux-tools

A comprehensive tmux session management toolkit that provides tabular status display, session overview, and intelligent session/window renaming capabilities.

## Overview

tmux-tools consists of three main components that work together to provide a complete tmux session management experience:

| Tool | Purpose | Key Features |
|------|---------|--------------|
| `tmux-status.sh` | Tabular status display | Compact table format, client width detection, intelligent renaming |
| `tmux-overview` | Session overview | Tree structure, JSON output, detailed/summary views, color themes |
| `tmux-tools` | Unified interface | Single entry point, consistent commands, configuration management |

## Quick Start

```bash
# Show compact session status
./tmux-status.sh

# Show detailed session overview
./tmux-overview --detailed

# Use unified interface
./tmux-tools status
./tmux-tools overview --json
```

## Key Features

- **Compact Display**: Space-efficient tabular format showing sessions, windows, and panes
- **Device Identification**: Client width column reveals connection type (iPad vs desktop)
- **Intelligent Naming**: City names for sessions, mammal names for windows
- **Multiple Output Formats**: Compact tables, detailed trees, JSON for scripting
- **Color Themes**: Customizable visual themes for different environments
- **Configuration System**: YAML-based configuration with custom name pools
- **Session Filtering**: Focus on specific sessions or filter by criteria

## Installation

### Quick Setup
```bash
git clone <repository-url>
cd tmux-tools
chmod +x tmux-status.sh tmux-overview tmux-tools
```

### System Installation
```bash
# Copy to system path
sudo cp tmux-tools /usr/local/bin/
sudo cp tmux-status.sh /usr/local/bin/
sudo cp tmux-overview /usr/local/bin/
```

## Basic Usage

### Status Display
```bash
# Compact view (default)
./tmux-status.sh

# Detailed view with PIDs and paths
./tmux-status.sh --show-pid

# Rename sessions and show status
./tmux-status.sh --rename-sessions
```

### Session Overview
```bash
# Summary view
./tmux-overview

# Detailed view with all panes
./tmux-overview --detailed

# JSON output for scripting
./tmux-overview --json

# Focus on specific session
./tmux-overview --session oslo
```

### Unified Interface
```bash
# Status commands
tmux-tools status
tmux-tools status --show-pid

# Overview commands
tmux-tools overview --detailed
tmux-tools overview --json

# Renaming operations
tmux-tools rename sessions
tmux-tools rename windows
tmux-tools rename auto

# Configuration management
tmux-tools config show
tmux-tools config create
```

## Output Examples

### Compact Status Display
```
TMUX STATUS Fri Sep 26 22:42:45 EDT 2025

session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

### Detailed Overview
```
Tmux Sessions (Detailed)
2025-09-26 14:30:22

● oslo (2025-09-24 23:30:47) [attached]
├─● 0:seal (3 panes)
│   ├─ 0 fish /Users/philip/projects/tmux-tools
│   ├─ 1 fish /Users/philip/projects/tmux-tools
│   └─● 2 node /Users/philip/projects/tmux-tools
└─ 1:bear (1 panes)
    └─ 0 node /Users/philip/Obsidian/amoxtli
```

## Command Reference

### tmux-status.sh Options
| Option | Description |
|--------|-------------|
| `--show-pid` | Show PID and path columns |
| `--rename-defaults` | Rename sessions with default prefix |
| `--rename-sessions` | Rename ALL sessions to city names |
| `--rename-windows` | Rename ALL windows to mammal names |
| `--help` | Show help message |

### tmux-overview Options
| Option | Short | Description |
|--------|-------|-------------|
| `--detailed` | `-d` | Show detailed view with all panes |
| `--json` | `-j` | Output in JSON format |
| `--session NAME` | `-s` | Show only specified session |
| `--help` | `-h` | Show help message |

### tmux-tools Commands
| Command | Description |
|---------|-------------|
| `status [options]` | Show tabular session status |
| `overview [options]` | Show session overview |
| `rename <target>` | Rename sessions/windows/auto |
| `config <action>` | Manage configuration |
| `help` | Show help information |
| `version` | Show version information |

## Configuration

tmux-tools supports YAML configuration files for customization. Configuration is loaded from (in order):

1. `~/.tmux-tools.yaml`
2. `~/.config/tmux-tools/config.yaml`
3. `./tmux-tools.yaml`

Create an example configuration:
```bash
tmux-tools config create
```

See [Configuration Guide](docs/configuration.md) for detailed configuration options.

## Advanced Features

### Color Themes
Available themes: `default`, `vibrant`, `subtle`, `monochrome`, `none`

```bash
# Set theme via environment
export TMUX_TOOLS_THEME=vibrant
./tmux-overview

# Or via configuration file
tmux-tools config show
```

### JSON Scripting
```bash
# Count total panes
tmux-overview --json | jq '[.sessions[].windows[].panes] | add'

# List running commands
tmux-overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with >2 windows
tmux-overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'
```

### Session Filtering
```bash
# Show specific sessions
./tmux-overview --session "oslo,milan"

# Use with unified interface
tmux-tools overview -s dev
```

## Requirements

- **tmux**: Session manager (must be installed and running)
- **bash**: Version 4.0 or later
- **Standard Unix tools**: `date`, `sort`, etc.

## Documentation

- [Installation Guide](docs/installation.md)
- [Usage Examples](docs/usage.md)
- [Configuration Guide](docs/configuration.md)
- [Architecture Overview](docs/architecture.md)
- [Development Guide](docs/development.md)

## Troubleshooting

### No tmux sessions found
Start a new session:
```bash
tmux new-session -d -s test
```

### Colors not showing
Verify terminal supports ANSI colors or disable:
```bash
export TMUX_TOOLS_THEME=none
```

### Permission issues during installation
Use sudo for system installation:
```bash
sudo cp tmux-tools /usr/local/bin/
```

## License

MIT License - see LICENSE file for details.