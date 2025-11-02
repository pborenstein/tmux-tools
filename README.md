# tmux-tools

Compact tabular view of tmux sessions, windows, and panes with smart renaming.

## Installation

```bash
# Clone and add to PATH
git clone <repository-url> ~/.tmux-tools
export PATH="$HOME/.tmux-tools:$PATH"

# Or symlink to a directory already in PATH
ln -s ~/.tmux-tools/tmux-tools /usr/local/bin/tmux-tools
```

Add the export to your `.bashrc` or `.zshrc` for persistence.

## Quick Start

```bash
tmux-tools status                    # See all sessions/windows/panes
tmux-tools overview                  # Tree view with summary
tmux-tools rename auto               # Clean up default names
```

## Commands

| Command | Description | Common Options |
|---------|-------------|----------------|
| `status` | Compact table of all sessions | `--show-pid`, `--rename-auto` |
| `overview` | Tree view of sessions | `--detailed`, `--json`, `-s <session>` |
| `rename` | Rename sessions/windows | `sessions`, `windows`, `auto` |
| `config` | Manage configuration | `show`, `create`, `edit` |

## Features

- Tabular display fits more information on screen
- Smart renaming: cities for sessions, mammals for windows
- Client width column shows device type (89 = iPad, 142+ = desktop)
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

**Rename default sessions:**
```bash
tmux-tools rename auto              # Only rename auto-generated names
tmux-tools rename sessions          # Rename all sessions
tmux-tools rename windows           # Rename all windows
```

## Output

**Compact status:**
```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

**Tree overview:**
```
* oslo (2025-09-24 23:30:47) [attached]
    - 0:seal (3 panes) [active]
    - 1:bear (1 panes)

* milan (2025-09-24 23:44:03) [detached]
    - 0:otter (1 panes)

Total: 2 sessions, 3 windows
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

Sessions: rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid

Windows: cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse

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