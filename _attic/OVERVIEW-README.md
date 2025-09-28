# tmux-overview

A command line tool that provides a comprehensive overview of all tmux sessions, windows, and panes running on your machine.

## Features

- **Summary view**: Quick overview of all sessions with window counts
- **Detailed view**: Full tree structure showing sessions → windows → panes
- **JSON output**: Machine-readable format for scripting and automation
- **Session filtering**: Focus on specific sessions
- **Visual indicators**: Colors and symbols to show active/attached status
- **Smart formatting**: Handles long paths and commands gracefully

## Installation

### Quick Install
```bash
./install.sh
```

### Manual Install
```bash
chmod +x tmux-overview
cp tmux-overview /usr/local/bin/
```

### Uninstall
```bash
./install.sh uninstall
```

## Usage

### Basic Commands

```bash
# Show summary of all sessions (default)
tmux-overview

# Show detailed view with all panes
tmux-overview --detailed

# Show only a specific session
tmux-overview --session milan

# Output in JSON format
tmux-overview --json

# Show help
tmux-overview --help
```

### Options

| Option | Short | Description |
|--------|-------|-------------|
| `--detailed` | `-d` | Show detailed view with all panes and commands |
| `--json` | `-j` | Output in JSON format for scripting |
| `--session NAME` | `-s` | Show only the specified session |
| `--help` | `-h` | Show help message |

## Examples

### Summary View (Default)
```
Tmux Sessions Overview
2025-09-26 14:30:22

● lima (2025-09-24 23:31:12) [detached]
  ├─ 0:fox (1 panes)

● milan (2025-09-24 23:44:03) [attached]
  ├─ 0:otter (1 panes)
  ├─ 1:bear (1 panes)

● oslo (2025-09-24 23:30:47) [attached]
  ├─● 0:seal (3 panes)
  ├─ 1:bear (1 panes)

● rio (2025-09-24 23:45:21) [attached]
  ├─ 0:seal (3 panes)
  ├─ 1:dog (1 panes)

Total: 4 sessions, 7 windows
```

### Detailed View
```bash
tmux-overview --detailed
```
```
Tmux Sessions (Detailed)
2025-09-26 14:30:22

● lima (2025-09-24 23:31:12) [detached]
└─ 0:fox (1 panes)
    └─ 0 fish /Users/philip/Obsidian

● milan (2025-09-24 23:44:03) [attached]
├─ 0:otter (1 panes)
│   └─ 0 fish /Users/philip/Obsidian
└─ 1:bear (1 panes)
    └─● 0 fish /Users/philip/Obsidian

● oslo (2025-09-24 23:30:47) [attached]
├─● 0:seal (3 panes)
│   ├─ 0 fish /Users/philip/projects/tmux-tools
│   ├─ 1 fish /Users/philip/projects/tmux-tools
│   └─● 2 node /Users/philip/projects/tmux-tools
└─ 1:bear (1 panes)
    └─ 0 node /Users/philip/Obsidian/amoxtli
```

### Session Filter
```bash
tmux-overview --session oslo
```
Shows only the "oslo" session with all its windows and panes.

### JSON Output
```bash
tmux-overview --json
```
```json
{
  "sessions": [
    {
      "name": "lima",
      "created": "2025-09-24 23:31:12",
      "attached": false,
      "windows": [
        {
          "index": 0,
          "name": "fox",
          "panes": 1,
          "active": true,
          "pane_details": [
            {
              "index": 0,
              "command": "fish",
              "path": "/Users/philip/Obsidian",
              "active": true
            }
          ]
        }
      ]
    }
  ]
}
```

## Visual Indicators

### Status Indicators
- `●` - Active/attached sessions, windows, or panes
- `[attached]` - Session is currently attached
- `[detached]` - Session is running but not attached

### Tree Structure
- `├─` - Branch (has more items below)
- `└─` - Last item in a group
- `│` - Continuation line for detailed view

### Colors
- **Blue**: Session names
- **Yellow**: Active windows
- **Green**: Active panes and detached sessions
- **Cyan**: Attached sessions
- **Purple**: Commands/processes
- **Gray**: Timestamps, paths, and secondary info

## Scripting with JSON Output

The JSON output makes it easy to integrate with other tools:

```bash
# Count total panes across all sessions
tmux-overview --json | jq '[.sessions[].windows[].panes] | add'

# List all running commands
tmux-overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with more than 2 windows
tmux-overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'
```

## Requirements

- **tmux**: Must be installed and have running sessions
- **bash**: Version 4.0 or later
- **Standard Unix tools**: date, sort, etc.

## Troubleshooting

### No tmux sessions found
If you see "No tmux sessions are currently running", start a new tmux session:
```bash
tmux new-session -d -s test
```

### Permission denied during install
The installer may need sudo access to write to `/usr/local/bin`:
```bash
sudo ./install.sh
```

### Colors not showing
If colors aren't displaying properly, check that your terminal supports ANSI color codes. Most modern terminals do by default.

## Development

The tool is written in bash for maximum compatibility. Key features:

- Uses tmux's built-in formatting options for reliable data extraction
- Handles edge cases like missing sessions or malformed data
- Color output can be disabled by piping to other commands
- Follows standard Unix conventions for options and output

## License

This project is released under the MIT License.