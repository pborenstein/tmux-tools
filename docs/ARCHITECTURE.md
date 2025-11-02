# Architecture

## Overview

tmux-tools uses a modular library architecture with separated concerns:

```
tmux-tools/
├── lib/
│   ├── tmux_core.sh      # Core tmux operations
│   ├── tmux_display.sh   # Display formatting
│   ├── tmux_colors.sh    # Color theming
│   └── tmux_config.sh    # Configuration handling
├── tmux-tools            # Unified command interface
├── tmux-status.sh        # Backward compatible script
└── tmux-overview         # Backward compatible script
```

### Component Relationships

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                     │
├─────────────────────────────────────────────────────────────┤
│  tmux-tools (unified CLI)    tmux-status.sh  tmux-overview  │
│       │                              │              │        │
│       └──────────────┬───────────────┴──────────────┘        │
└──────────────────────┼──────────────────────────────────────┘
                       │ sources all libraries
         ┌─────────────┼─────────────┬──────────────┐
         │             │             │              │
         ▼             ▼             ▼              ▼
   ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐
   │  Core   │  │ Display  │  │  Colors  │  │  Config  │
   │  195    │  │   225    │  │   205    │  │   284    │
   │  lines  │  │  lines   │  │  lines   │  │  lines   │
   └────┬────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘
        │            │             │             │
        │ queries    │ formats     │ colorizes   │ loads
        │            │             │             │
        ▼            ▼             ▼             ▼
   ┌─────────────────────────────────────────────────────┐
   │              tmux Server & Config File              │
   │   list-sessions  list-windows  list-panes  etc.     │
   │              ~/.tmux-tools.yaml                     │
   └─────────────────────────────────────────────────────┘
```

## Library Components

### tmux_core.sh

Core tmux operations and data retrieval:

**Data Retrieval Pipeline**:

```
User runs: tmux-tools status
         │
         ▼
  ┌──────────────┐
  │ check_tmux_  │  Verify tmux installed
  │  available() │
  └──────┬───────┘
         ▼
  ┌──────────────┐
  │ check_tmux_  │  Verify server running
  │  running()   │
  └──────┬───────┘
         │
    ┌────┴────┬──────────────┬─────────────┐
    │         │              │             │
    ▼         ▼              ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌──────────┐
│ get_    │ │ get_    │ │ get_    │ │ get_     │
│session_ │ │window_  │ │ pane_   │ │ client_  │
│ data()  │ │ data()  │ │ data()  │ │  data()  │
└────┬────┘ └────┬────┘ └────┬────┘ └────┬─────┘
     │           │           │           │
     │ tmux list-sessions    │           │
     │           │ tmux list-windows     │
     │           │           │ tmux list-panes
     │           │           │           │ tmux list-clients
     │           │           │           │
     └───────────┴───────────┴───────────┘
                  │
                  ▼
          Formatted data returned
          to display layer
```

**Functions**:
- `check_tmux_available()` / `check_tmux_running()` - Validation
- `get_session_data()` / `get_window_data()` / `get_pane_data()` - Data retrieval
- `get_client_data()` - Terminal dimensions and device identification
- `rename_session()` / `rename_window()` - Safe renaming with conflict resolution

### tmux_display.sh

Display formatting and layout:

- `print_status_row()` / `print_status_header()` - Tabular formatting
- `format_session_display()` / `format_window_display()` - Visual grouping
- `print_overview_row()` - Tree structure rendering

### tmux_colors.sh

Theme management:

**Themes**: default, vibrant, subtle, monochrome, none

**Theme Selection Flow**:

```
      Command execution starts
              │
              ▼
       ┌──────────────┐
       │ NO_COLOR set?│ → yes → Disable all colors, done
       └──────┬───────┘
              │ no
              ▼
       ┌──────────────┐
       │ Get theme    │  1. TMUX_TOOLS_THEME env var
       │   setting    │  2. Config file display.theme
       │              │  3. Default: "default"
       └──────┬───────┘
              │
              ▼
       ┌──────────────┐
       │ init_colors()│
       └──────┬───────┘
              │
     ┌────────┴────────┬─────────┬──────────┬──────────┐
     │                 │         │          │          │
     ▼                 ▼         ▼          ▼          ▼
┌─────────┐      ┌─────────┐ ┌────────┐ ┌────────┐ ┌──────┐
│ default │      │ vibrant │ │ subtle │ │ mono   │ │ none │
│ Balanced│      │ Bright  │ │ Muted  │ │ Single │ │  No  │
│ colors  │      │ colors  │ │ colors │ │ color  │ │colors│
└────┬────┘      └────┬────┘ └───┬────┘ └───┬────┘ └──┬───┘
     │                │          │          │         │
     └────────────────┴──────────┴──────────┴─────────┘
                       │
                       ▼
          Set SESSION_COLOR, WINDOW_COLOR,
          PANE_COLOR, BACKGROUND_COLOR, etc.
```

**Environment**: `TMUX_TOOLS_THEME`, `NO_COLOR`

**Usage**:
```bash
init_colors "$(get_config_value "theme")"
colorize_session "oslo"
```

### tmux_config.sh

YAML configuration parsing:

**Configuration Loading Flow**:

```
      Start: load_config()
              │
              ▼
       ┌──────────────┐
       │ Check env    │  NO_COLOR set? → disable colors
       │ variables    │  TMUX_TOOLS_THEME → override theme
       └──────┬───────┘  TMUX_TOOLS_*_POOL → override pools
              │
              ▼
       ┌──────────────┐
       │ Search for   │  1. ~/.tmux-tools.yaml
       │ config file  │  2. ~/.tmux-tools.yml
       │ (6 locations)│  3. ~/.config/tmux-tools/config.yaml
       └──────┬───────┘  4. ~/.config/tmux-tools/config.yml
              │          5. ./tmux-tools.yaml
        ┌─────┴─────┐   6. ./tmux-tools.yml
        │           │
     Found        Not Found
        │           │
        ▼           ▼
  ┌─────────┐  ┌─────────┐
  │  Parse  │  │  Use    │
  │  YAML   │  │ Defaults│
  └────┬────┘  └────┬────┘
       │            │
       └─────┬──────┘
             ▼
      ┌──────────────┐
      │ Apply config │ → Theme, name pools, display options
      │   values     │
      └──────────────┘
```

**Search order**:
1. `~/.tmux-tools.yaml`
2. `~/.tmux-tools.yml`
3. `~/.config/tmux-tools/config.yaml`
4. `~/.config/tmux-tools/config.yml`
5. `./tmux-tools.yaml`
6. `./tmux-tools.yml`

**Functions**:
- `load_config()` - Parse YAML configuration
- `get_session_names()` / `get_window_names()` - Name pool retrieval

## Configuration

Example `~/.tmux-tools.yaml`:

```yaml
display:
  theme: "default"
  attachment_indicator: "*"

naming:
  session_pool: "cities"
  window_pool: "mammals"

  custom_sessions:
    - "dev"
    - "work"

  custom_windows:
    - "editor"
    - "terminal"
```

**Environment overrides**:

| Variable | Default | Purpose |
|----------|---------|---------|
| `TMUX_TOOLS_THEME` | "default" | Override theme |
| `TMUX_TOOLS_SESSION_POOL` | "cities" | Override session names |
| `TMUX_TOOLS_WINDOW_POOL` | "mammals" | Override window names |
| `NO_COLOR` | - | Disable colors |

## Command Dispatch

The `tmux-tools` script routes commands to implementations:

### Command Routing Flow

```
User: tmux-tools status --show-pid
              │
              ▼
       ┌─────────────┐
       │  tmux-tools │  Parse command and options
       │ dispatcher  │
       └──────┬──────┘
              │
        ┌─────┴─────┬──────────┬────────────┐
        │           │          │            │
        ▼           ▼          ▼            ▼
    ┌────────┐ ┌────────┐ ┌────────┐ ┌──────────┐
    │ status │ │overview│ │ rename │ │  config  │
    │  exec  │ │  exec  │ │internal│ │ internal │
    │   ↓    │ │   ↓    │ │        │ │          │
    │ tmux-  │ │ tmux-  │ └────────┘ └──────────┘
    │status  │ │overview│
    │  .sh   │ │        │
    └────────┘ └────────┘
```

| Command | Target | Implementation |
|---------|--------|----------------|
| `status` | tmux-status.sh | Exec to script |
| `overview` | tmux-overview | Exec to script |
| `rename` | Internal | Uses lib functions |
| `config` | Internal | Uses lib functions |

```bash
case "$command" in
  "status")
    exec "$SCRIPT_DIR/tmux-status.sh" "$@"
    ;;
  "rename")
    # Internal implementation
    ;;
esac
```

## Backward Compatibility

Original scripts work unchanged:

```bash
./tmux-status.sh              # Same as tmux-tools status
./tmux-overview --detailed    # Same as tmux-tools overview --detailed
```

Scripts now source lib files but maintain identical interfaces.

## Implementation Notes

### Parameter Handling

Bash parameter expansion conflicts with tmux format strings. Use explicit checks:

```bash
# Avoid
local format="${2:-#{session_name}}"

# Use
local format="${2:-}"
if [[ -z "$format" ]]; then
  format="#{session_name}"
fi
```

### Error Handling

Standardized validation:

```bash
check_tmux_available() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux not found" >&2
    return 1
  fi
}
```

## Extension Points

The architecture supports:

- New display formats in `tmux_display.sh`
- Additional themes in `tmux_colors.sh`
- New configuration options in `tmux_config.sh`
- New commands in `tmux-tools` dispatch