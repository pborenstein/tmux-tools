# tmux-tools

A tmux session status display and renaming tool that shows all sessions, windows, and panes in a clean tabular format.

## Features

- Compact tabular view of all tmux sessions, windows, and panes
- Shows running command and client width for device identification
- Optional detailed view with process ID (PID) and full paths
- Optional session renaming with predefined city names
- Optional window renaming with predefined mammal names
- Clean grouping with visual separation between sessions
- Window names shown only for first pane of each window
- Client width display helps identify iPad vs desktop connections

## Output Format

**Compact Mode (Default):**
```
TMUX STATUS Fri Sep 26 22:42:45 EDT 2025

session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

**Detailed Mode (--show-pid):**
```
session       win  name      p  cmd      w    pid    path
-------       ---  --------  -  -------  ---  -----  ----
oslo          0    elk       0  fish     142  55066  /Users/philip/projects/tmux-tools
              0              1  fish          54634  /Users/philip/projects/tmux-tools
              1    cat       0  node          55294  /Users/philip/Obsidian/amoxtli
milan         0    mouse     0  fish     89   55586  /Users/philip/Obsidian
```

The width column (w) shows terminal dimensions - useful for identifying connections (e.g., 89 = iPad, 142 = desktop).

## Usage

```bash
./tmux-status.sh                    # Show compact status (default)
./tmux-status.sh --show-pid         # Show detailed status with PID and paths
./tmux-status.sh --rename-defaults  # Rename default-named sessions
./tmux-status.sh --rename-sessions  # Rename all sessions to city names
./tmux-status.sh --rename-windows   # Rename all windows to mammal names
./tmux-status.sh --help             # Show help
```

## Options

- `--no-rename` - Skip all session renaming (default behavior)
- `--rename-defaults` - Rename sessions with default prefix to city names
- `--rename-sessions` - Rename ALL sessions to random city names
- `--rename-windows` - Rename ALL windows to random mammal names
- `--show-pid` - Show PID and path columns (hidden by default for compact display)
- `--help`, `-h` - Show help message


## Renaming

Sessions get renamed to cities and windows get renamed to mammals, with intelligent conflict resolution.

### City Names for Sessions
rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid

### Mammal Names for Windows
cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse

### Conflict Resolution

- Session renaming avoids conflicts by skipping to the next available city name
- Window renaming is per-session (names only need to be unique within each session)
- No ugly number suffixes - just moves to the next available name

## Requirements

- bash
- tmux

## License

MIT