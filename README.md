# tmux-tools

Compact tabular view of tmux sessions, windows, and panes with smart renaming.

## Installation

```bash
# Clone the repository to your preferred location
git clone <repository-url> <install-directory>
# Examples: ~/tmux-tools, ~/projects/tmux-tools, ~/dev/tmux-tools, etc.

# Recommended: symlink to ~/.local/bin (no sudo required)
mkdir -p ~/.local/bin
ln -s <install-directory>/tmux-tools ~/.local/bin/tmux-tools
ln -s <install-directory>/tt ~/.local/bin/tt

# Ensure ~/.local/bin is in your PATH (add to .bashrc or .zshrc)
export PATH="$HOME/.local/bin:$PATH"
```

**Alternative:** Add the repo directory directly to PATH:
```bash
export PATH="<install-directory>:$PATH"
```

**Alternative:** Symlink to `/usr/local/bin` (requires sudo):
```bash
sudo ln -s <install-directory>/tmux-tools /usr/local/bin/tmux-tools
sudo ln -s <install-directory>/tt /usr/local/bin/tt
```

**Note:** Replace `<install-directory>` with the actual path where you cloned the repository (e.g., `~/projects/tmux-tools`).

The `tt` command is a short alias for `tmux-tools` - use whichever you prefer!

## Quick Start

```bash
tmux-tools                           # Show status (default command)
tt status                            # Same as above using short alias
tmux-tools overview                  # Tree view with summary
tmux-tools rename auto               # Clean up default names
tmux-tools help                      # Show tmux command reference
tmux-tools help sessions             # Show session commands
```

## Commands

| Command | Description | Common Options |
|---------|-------------|----------------|
| `status` | Compact table of all sessions (default) | `--show-pid`, `--rename-auto` |
| `overview` | Tree view of sessions | `--detailed`, `--json`, `-s <session>` |
| `rename` | Rename sessions/windows | `sessions`, `windows`, `auto` |
| `config` | Manage configuration | `show`, `create`, `edit` |
| `help` | Show tmux command reference | `sessions`, `windows`, `panes`, `layouts` |

## Features

- Tabular display fits more information on screen
- Smart renaming: cities for sessions, directory names for windows
- Client width column shows device type (89 = iPad, 142+ = desktop)
- Short `tt` alias for quick access
- Built-in tmux command reference via `help` command
- JSON output for scripting
- YAML config for custom name pools and themes
- Multiple color schemes
- Backward compatible with original `tmux-status.sh` and `tmux-overview` scripts

## Examples

**View all sessions compactly:**
```bash
tmux-tools status
```

**See process IDs and paths:**
```bash
tmux-tools status --show-pid
```

**Tree view with details:**
```bash
tmux-tools overview --detailed
```

**Export to JSON for scripting:**
```bash
tmux-tools overview --json | jq '.sessions[].name'
```

**Rename sessions and windows:**
```bash
tmux-tools rename auto              # Rename sessions to cities, windows to dirs
tmux-tools rename sessions          # Rename all sessions to city names
tmux-tools rename windows           # Rename all windows to directory names
```

**Get help and command reference:**
```bash
tmux-tools help                     # Show full tmux command reference
tmux-tools help sessions            # Show session-specific commands
tmux-tools help windows             # Show window-specific commands
tt help panes                       # Show pane commands (using short alias)
```

## Output

**Compact status:**
```
TMUX STATUS Sun Nov  9 00:08:00 EST 2025

  session       win  name                  p  cmd      w
- -------       ---  --------------------  -  -------  ---
• oslo          0    tmux-tools            0  bash     172
                1    apantli               0  fish
                2    apantli               0  bash
                3    docs                  0  fish

  rio           0    home                  0  bash     -
```

**Tree overview:**
```
● oslo        • tmux-tools
                apantli
                apantli
                docs
○ rio         • home
```

## Configuration

Optional: Create `~/.tmux-tools.yaml` to customize themes and naming:

```yaml
display:
  theme: "default"              # default, vibrant, subtle, monochrome, none

naming:
  session_pool: "cities"        # cities, custom
  window_pool: "mammals"        # mammals, custom

  custom_sessions:
    - "dev"
    - "work"

  custom_windows:
    - "editor"
    - "terminal"
```

Generate example config: `tmux-tools config create`

**Environment variables:**

| Variable | Default | Purpose |
|----------|---------|---------|
| `TMUX_TOOLS_THEME` | "default" | Color theme |
| `NO_COLOR` | - | Disable colors |

## Naming

**Sessions:** rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid

**Windows:** Automatically named based on the active pane's current directory (e.g., `/home/user/my-project` becomes `my-project`). Directory names are truncated to 20 characters maximum.

Conflicts are resolved by advancing to the next available name. No number suffixes.

## Scripting

Use JSON output for automation:

```bash
# Count panes
tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add'

# List commands
tmux-tools overview --json | jq -r '.sessions[].windows[].pane_details[].command'

# Find large sessions
tmux-tools overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'
```

## Requirements

- tmux (any recent version)
- bash 4.0+
- Optional: jq for JSON processing

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "tmux not found" | Install: `brew install tmux` (macOS) or `apt install tmux` (Linux) |
| No sessions found | Start session: `tmux new-session -s test` |
| Colors not working | Disable: `export NO_COLOR=1` or check: `echo $TERM` |
| Config not loading | Create: `tmux-tools config create` or verify: `tmux-tools config show` |
| Columns misaligned | Shorten names or increase terminal width |
| Slow with many sessions | Use `tmux-tools status` instead of `--show-pid` |

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for comprehensive troubleshooting including installation issues, display problems, configuration debugging, and platform-specific solutions.

## Documentation

| Document | Description | Audience |
|----------|-------------|----------|
| [CONTRIBUTING.md](CONTRIBUTING.md) | Development setup and guidelines | Contributors |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Technical architecture with diagrams | Developers |
| [docs/DESIGN-PRINCIPLES.md](docs/DESIGN-PRINCIPLES.md) | Design philosophy | Designers, Developers |
| [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) | Comprehensive troubleshooting | Users, Support |
| [docs/ROADMAP.md](docs/ROADMAP.md) | Future features and plans | Contributors, Users |
| [examples/tmux-tools.yaml](examples/tmux-tools.yaml) | Full configuration example | Users |

## Development

Core logic in `lib/` modules. See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for technical details.

## License

MIT License