# Usage Guide

This comprehensive guide covers all tmux-tools features with practical examples and use cases.

## Getting Started

### First Run

Start with a basic session to explore tmux-tools:

```bash
# Create a test session
tmux new-session -d -s demo
tmux new-window -t demo -n work
tmux split-window -t demo:work

# View your sessions
./tmux-tools status
./tmux-tools overview
```

## tmux-status.sh - Tabular Status Display

The status tool provides a compact, table-based view of all tmux sessions, windows, and panes.

### Basic Usage

```bash
# Compact view (default)
./tmux-status.sh

# Output:
# TMUX STATUS Fri Sep 26 22:42:45 EDT 2025
#
# session       win  name      p  cmd      w
# -------       ---  --------  -  -------  ---
# demo          0    work      0  fish     142
#               0              1  fish
#               1    bash      0  bash
```

### Detailed View

```bash
# Show PIDs and full paths
./tmux-status.sh --show-pid

# Output:
# session       win  name      p  cmd      w    pid    path
# -------       ---  --------  -  -------  ---  -----  ----
# demo          0    work      0  fish     142  12345  /Users/philip/projects
#               0              1  fish          12346  /Users/philip/projects
#               1    bash      0  bash          12347  /Users/philip
```

### Renaming Operations

```bash
# Rename sessions with default names to cities
./tmux-status.sh --rename-defaults

# Rename ALL sessions to random city names
./tmux-status.sh --rename-sessions

# Rename ALL windows to random mammal names
./tmux-status.sh --rename-windows

# Smart rename: only rename default-named sessions/windows
./tmux-status.sh --rename-auto
```

### Column Reference

| Column | Description | Example | Notes |
|--------|-------------|---------|-------|
| **session** | Session name | `oslo`, `milan` | Shown once per group |
| **win** | Window index | `0`, `1`, `2` | Within session |
| **name** | Window name | `cat`, `bear`, `fox` | Shown once per window |
| **p** | Pane index | `0`, `1`, `2` | Within window |
| **cmd** | Running command | `fish`, `vim`, `node` | Current process |
| **w** | Terminal width | `89`, `142` | Device identification |
| **pid** | Process ID | `12345` | With --show-pid only |
| **path** | Working directory | `/Users/philip/projects` | With --show-pid only |

### Device Identification by Width

| Width | Device Type | Use Case |
|-------|-------------|----------|
| 80-100 | Mobile/iPad | Remote work |
| 120-140 | Laptop | Development |
| 140+ | Desktop | Full setup |

## tmux-overview - Session Overview

The overview tool provides a hierarchical view with multiple output formats.

### Summary View (Default)

```bash
./tmux-overview

# Output:
# Tmux Sessions Overview
# 2025-09-26 14:30:22
#
# ● oslo (2025-09-24 23:30:47) [attached]
#   ├─● 0:seal (3 panes)
#   ├─ 1:bear (1 panes)
#
# ● milan (2025-09-24 23:44:03) [detached]
#   ├─ 0:otter (1 panes)
#   ├─ 1:cat (1 panes)
#
# Total: 2 sessions, 4 windows
```

### Detailed View

```bash
./tmux-overview --detailed

# Output:
# Tmux Sessions (Detailed)
# 2025-09-26 14:30:22
#
# ● oslo (2025-09-24 23:30:47) [attached]
# ├─● 0:seal (3 panes)
# │   ├─ 0 fish /Users/philip/projects/tmux-tools
# │   ├─ 1 fish /Users/philip/projects/tmux-tools
# │   └─● 2 node /Users/philip/projects/tmux-tools
# └─ 1:bear (1 panes)
#     └─ 0 node /Users/philip/Obsidian/amoxtli
```

### Session Filtering

```bash
# Show specific session
./tmux-overview --session oslo

# Show multiple sessions
./tmux-overview --session "oslo,milan"
```

### JSON Output

```bash
# JSON format for scripting
./tmux-overview --json

# Pretty-printed JSON
./tmux-overview --json | jq '.'
```

### Visual Indicators

| Symbol | Meaning | Context |
|--------|---------|----------|
| `●` | Active/current | Sessions, windows, panes |
| `[attached]` | Client connected | Session status |
| `[detached]` | No client | Session status |
| `├─` | Tree branch | More items follow |
| `└─` | Last item | End of group |
| `│` | Continuation | Detailed view lines |

## tmux-tools - Unified Interface

The unified interface provides consistent access to all functionality.

### Status Commands

```bash
# Compact status
tmux-tools status

# Detailed status with PIDs
tmux-tools status --show-pid

# Status with smart renaming
tmux-tools status --rename-auto
```

### Overview Commands

```bash
# Summary overview
tmux-tools overview

# Detailed overview
tmux-tools overview --detailed

# JSON output
tmux-tools overview --json

# Filter by session
tmux-tools overview -s oslo
```

### Renaming Commands

```bash
# Rename all sessions to cities
tmux-tools rename sessions

# Rename all windows to mammals
tmux-tools rename windows

# Smart rename (only defaults)
tmux-tools rename auto
```

### Configuration Commands

```bash
# Show current configuration
tmux-tools config show

# Create example configuration file
tmux-tools config create

# Edit configuration file
tmux-tools config edit

# Validate configuration
tmux-tools config validate
```

### Information Commands

```bash
# Show help
tmux-tools help
tmux-tools --help

# Show version
tmux-tools version
tmux-tools --version
```

## Advanced Usage

### Color Themes

| Theme | Characteristics | Use Case | Command |
|-------|----------------|----------|----------|
| `default` | Balanced colors | General use | `export TMUX_TOOLS_THEME=default` |
| `vibrant` | Bright colors | High contrast | `export TMUX_TOOLS_THEME=vibrant` |
| `subtle` | Muted colors | Professional | `export TMUX_TOOLS_THEME=subtle` |
| `monochrome` | Single color | Accessibility | `export TMUX_TOOLS_THEME=monochrome` |
| `none` | No colors | Scripting | `export TMUX_TOOLS_THEME=none` |

### JSON Scripting Examples

```bash
# Count total panes across all sessions
tmux-overview --json | jq '[.sessions[].windows[].panes] | add'

# List all unique running commands
tmux-overview --json | jq -r '.sessions[].windows[].pane_details[].command' | sort | uniq

# Find sessions with more than 2 windows
tmux-overview --json | jq -r '.sessions[] | select(.windows | length > 2) | .name'

# Get session creation times
tmux-overview --json | jq -r '.sessions[] | "\(.name): \(.created)"'

# Count windows per session
tmux-overview --json | jq -r '.sessions[] | "\(.name): \(.windows | length) windows"'

# Find inactive sessions (detached)
tmux-overview --json | jq -r '.sessions[] | select(.attached == false) | .name'

# Get memory usage summary (if available)
tmux-overview --json | jq '.sessions | length as $sessions | [.[].windows | length] | add as $windows | [.[].windows[].panes] | add as $panes | {sessions: $sessions, windows: $windows, panes: $panes}'
```

### Automation Examples

#### Daily Session Cleanup

```bash
#!/bin/bash
# cleanup-old-sessions.sh

# Find sessions older than 7 days
old_sessions=$(tmux-overview --json | jq -r --arg week_ago "$(date -d '7 days ago' '+%Y-%m-%d')" '.sessions[] | select(.created < $week_ago) | .name')

for session in $old_sessions; do
    echo "Removing old session: $session"
    tmux kill-session -t "$session"
done
```

#### Session Health Check

```bash
#!/bin/bash
# session-health.sh

echo "=== Session Health Report ==="
echo "$(date)"
echo

# Count sessions
session_count=$(tmux-overview --json | jq '.sessions | length')
echo "Total sessions: $session_count"

# Check for default names
default_sessions=$(tmux-overview --json | jq -r '.sessions[] | select(.name | test("^[0-9]+$")) | .name')
if [[ -n "$default_sessions" ]]; then
    echo "⚠️  Sessions with default names: $default_sessions"
    echo "   Run: tmux-tools rename auto"
fi

# Find idle sessions (detached > 1 hour)
idle_sessions=$(tmux-overview --json | jq -r --arg hour_ago "$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S')" '.sessions[] | select(.attached == false and .created < $hour_ago) | .name')
if [[ -n "$idle_sessions" ]]; then
    echo "😴 Idle sessions (detached > 1 hour): $idle_sessions"
fi

# Check for high pane count
busy_sessions=$(tmux-overview --json | jq -r '.sessions[] | select([.windows[].panes] | add > 10) | "\(.name) (\([.windows[].panes] | add) panes)"')
if [[ -n "$busy_sessions" ]]; then
    echo "🔥 Busy sessions (>10 panes): $busy_sessions"
fi
```

#### Session Backup

```bash
#!/bin/bash
# backup-sessions.sh

backup_dir="$HOME/.tmux-backups"
mkdir -p "$backup_dir"

# Save session layout
tmux-overview --json > "$backup_dir/sessions-$(date +%Y%m%d-%H%M%S).json"

# Save tmux server info
tmux list-sessions -F "#{session_name}|#{session_created}|#{session_attached}" > "$backup_dir/server-$(date +%Y%m%d-%H%M%S).txt"

echo "Sessions backed up to $backup_dir"
```

### Integration Examples

#### Git Integration

```bash
# Create development session for current project
create-dev-session() {
    local project_name=$(basename "$(pwd)")
    local session_name="${project_name}-dev"

    if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Session $session_name already exists"
        tmux attach-session -t "$session_name"
    else
        tmux new-session -d -s "$session_name"
        tmux new-window -t "$session_name" -n "editor"
        tmux new-window -t "$session_name" -n "server"
        tmux new-window -t "$session_name" -n "git"

        # Send commands to windows
        tmux send-keys -t "$session_name:editor" "vim ." Enter
        tmux send-keys -t "$session_name:server" "npm run dev" Enter
        tmux send-keys -t "$session_name:git" "git status" Enter

        tmux attach-session -t "$session_name"
    fi
}
```

#### Directory Watching

```bash
# Auto-create sessions for new projects
watch-projects() {
    local projects_dir="$HOME/projects"

    # Monitor directory for new projects
    fswatch -o "$projects_dir" | while read f; do
        for dir in "$projects_dir"/*; do
            if [[ -d "$dir" ]] && [[ ! -f "$dir/.tmux-session" ]]; then
                local project_name=$(basename "$dir")
                echo "New project detected: $project_name"

                # Create session
                tmux new-session -d -s "$project_name" -c "$dir"
                touch "$dir/.tmux-session"

                echo "Created session: $project_name"
            fi
        done
    done
}
```

## Workflow Examples

### Development Workflow

```bash
# 1. Start development session
tmux new-session -d -s myproject
tmux new-window -t myproject -n code
tmux new-window -t myproject -n serve
tmux split-window -t myproject:serve

# 2. Rename for clarity
tmux-tools rename windows

# 3. Check status
tmux-tools status

# 4. Monitor throughout day
tmux-tools overview --detailed
```

### Multi-Project Workflow

```bash
# Morning routine
tmux-tools overview                    # See what's running
tmux-tools rename auto                 # Clean up names
tmux-tools status --show-pid          # Debug any issues

# Create project sessions
for project in web-app api-service; do
    tmux new-session -d -s "$project"
    tmux new-window -t "$project" -n dev
    tmux new-window -t "$project" -n test
done

# Evening cleanup
tmux-tools overview --json | jq -r '.sessions[] | select(.attached == false) | .name' | xargs -I {} tmux kill-session -t {}
```

### Remote Work Workflow

```bash
# Connect from iPad (narrow terminal)
export TMUX_TOOLS_THEME=subtle        # Easier on eyes
tmux-tools status                      # Compact view perfect for mobile

# Later from desktop (wide terminal)
export TMUX_TOOLS_THEME=vibrant       # Full colors
tmux-tools overview --detailed        # Full information

# Width column shows connection history
tmux-tools status --show-pid          # See which device used what
```

## Performance Tips

### Large Session Counts

When managing many sessions:

```bash
# Use JSON for processing
tmux-tools overview --json | jq '.sessions | length'

# Filter specific sessions
tmux-tools overview -s "project1,project2"

# Use status for quick overview
tmux-tools status  # Faster than detailed overview
```

### Automation Performance

```bash
# Cache session data for scripts
tmux-tools overview --json > /tmp/sessions.json
jq '.sessions[] | .name' /tmp/sessions.json

# Use specific filters
tmux-tools overview -s "$session_name" --json
```

## Troubleshooting Common Issues

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| No sessions showing | tmux not running | `tmux new-session -d -s test && tmux-tools status` |
| Inconsistent renaming | Mixed naming schemes | `tmux-tools rename auto` for gentle cleanup |
| Color display issues | Terminal compatibility | `export TMUX_TOOLS_THEME=none` to disable |

## Next Steps

| Priority | Guide | Purpose |
|----------|-------|----------|
| 1 | [Configuration](configuration.md) | Customize for your workflow |
| 2 | [Architecture](architecture.md) | Understand system design |
| 3 | [Development](development.md) | Contribute to project |