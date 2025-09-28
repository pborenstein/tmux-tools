# Basic Usage Examples

## Overview

This guide provides practical examples for everyday tmux-tools usage, from simple session inspection to organizing and monitoring tmux environments.

## Getting Started

### First Time Setup

```bash
# Make tmux-tools executable
chmod +x tmux-tools

# Create your first tmux session
tmux new-session -d -s development

# Check what's running
./tmux-tools status
```

**Output:**
```
TMUX STATUS Sat Sep 28 14:30:22 EDT 2025

session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
development   0    fish      0  fish     142
```

### Basic Session Inspection and Organization

**Inspect and organize existing sessions:**
```bash
# Check what tmux sessions are running
./tmux-tools status

# Get detailed view of all sessions
./tmux-tools overview

# Apply consistent naming to sessions with default names
./tmux-tools rename auto

# Rename all sessions to cities for better organization
./tmux-tools rename sessions

# Check the organized results
./tmux-tools status
```

**Result:**
```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    fish      0  fish     142
milan         0    fish      0  fish     142
berlin        0    fish      0  fish     142
```

## Daily Workflow Examples

### Development Session Organization

**Organize and monitor your development environment:**

```bash
#!/bin/bash
# dev-organize.sh - Organize existing development sessions

PROJECT_PATH="$HOME/projects/myapp"

echo "=== Development Session Organization ==="

# Show current session state
echo "Current tmux environment:"
./tmux-tools status
echo

# Apply smart renaming to clean up session names
echo "Applying consistent naming..."
./tmux-tools rename auto
echo

# Show organized state
echo "Organized sessions:"
./tmux-tools overview --detailed
echo

# Monitor specific session if it exists
if tmux has-session -t myapp 2>/dev/null; then
  echo "Detailed view of myapp session:"
  ./tmux-tools overview --session myapp
fi
```

### Quick Status Checks

**Monitor sessions throughout the day:**

```bash
# Quick status check (alias this as 'ts')
./tmux-tools status

# Detailed overview with all panes
./tmux-tools overview --detailed

# Focus on specific session
./tmux-tools overview --session oslo
```

### Session Analysis

**Analyze your tmux usage patterns:**

```bash
# Show comprehensive session overview
./tmux-tools overview

# Export session data for analysis
./tmux-tools overview --json > sessions.json

# Analyze common patterns
cat sessions.json | jq -r '
  .sessions[] |
  "Session: \(.name) | Windows: \(.windows | length) | Status: \(if .attached then "attached" else "detached" end)"
'

# Find busiest sessions
cat sessions.json | jq -r '
  .sessions[] |
  select((.windows | length) > 2) |
  "\(.name): \(.windows | length) windows"
'
```

## Window Management Examples

### Multi-Window Inspection

**Inspect and organize sessions with multiple windows:**

```bash
# Assume you have an existing session with multiple windows
# Check current window organization
./tmux-tools status

# Get detailed view of specific session
./tmux-tools overview --session webdev

# Rename windows with consistent animal names for better organization
./tmux-tools rename windows

# Check the organized result
./tmux-tools status
```

**Output:**
```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
webdev        0    cat       0  fish     142
              1    dog       0  fish
              2    fox       0  fish
              3    bat       0  fish
              4    elk       0  fish
```

### Split Pane Workflows

**Create split-pane layouts:**

```bash
# Create session with split panes
tmux new-session -d -s monitoring

# Split window horizontally
tmux split-window -t monitoring -h

# Split right pane vertically
tmux split-window -t monitoring:0.1 -v

# Add more panes
tmux split-window -t monitoring:0.0 -v

# Check the layout
./tmux-tools overview --detailed
```

## Configuration Examples

### Basic Configuration

**Create `~/.tmux-tools.yaml`:**

```yaml
# Personal tmux-tools configuration
display:
  theme: "vibrant"
  show_timestamps: true

naming:
  session_pool: "custom"
  custom_sessions:
    - "work"
    - "personal"
    - "learning"
    - "projects"

  window_pool: "custom"
  custom_windows:
    - "editor"
    - "terminal"
    - "browser"
    - "logs"
```

**Test the configuration:**

```bash
# Create sessions and windows
tmux new-session -d -s test1
tmux new-window -t test1 -n window1

# Apply custom naming
./tmux-tools rename sessions
./tmux-tools rename windows

# Check results
./tmux-tools status
```

### Environment-Specific Configuration

**Work environment (`work.yaml`):**

```yaml
display:
  theme: "subtle"
  attachment_indicator: "→"

naming:
  session_pool: "custom"
  custom_sessions:
    - "frontend"
    - "backend"
    - "database"
    - "testing"
    - "deployment"
```

**Personal environment (`personal.yaml`):**

```yaml
display:
  theme: "vibrant"

naming:
  session_pool: "custom"
  custom_sessions:
    - "learning"
    - "projects"
    - "experiments"
    - "writing"
```

**Switch between configurations:**

```bash
# Use work config
cp work.yaml ~/.tmux-tools.yaml
./tmux-tools config show

# Use personal config
cp personal.yaml ~/.tmux-tools.yaml
./tmux-tools config show
```

## JSON Output Examples

### Basic JSON Queries

**Get session information:**

```bash
# Get all session names
./tmux-tools overview --json | jq -r '.sessions[].name'

# Count total sessions
./tmux-tools overview --json | jq '.sessions | length'

# Get attached sessions only
./tmux-tools overview --json | jq '.sessions[] | select(.attached == true) | .name'
```

### Advanced JSON Processing

**Session analysis:**

```bash
#!/bin/bash
# session-analysis.sh - Analyze tmux sessions

JSON_DATA=$(./tmux-tools overview --json)

echo "=== Session Analysis ==="

# Total counts
TOTAL_SESSIONS=$(echo "$JSON_DATA" | jq '.sessions | length')
TOTAL_WINDOWS=$(echo "$JSON_DATA" | jq '[.sessions[].windows] | length')
TOTAL_PANES=$(echo "$JSON_DATA" | jq '[.sessions[].windows[].panes] | add')

echo "Sessions: $TOTAL_SESSIONS"
echo "Windows:  $TOTAL_WINDOWS"
echo "Panes:    $TOTAL_PANES"

# Active vs detached
ATTACHED=$(echo "$JSON_DATA" | jq '[.sessions[] | select(.attached == true)] | length')
DETACHED=$(echo "$JSON_DATA" | jq '[.sessions[] | select(.attached == false)] | length')

echo "Attached: $ATTACHED"
echo "Detached: $DETACHED"

# Busiest session
BUSIEST=$(echo "$JSON_DATA" | jq -r '
  .sessions[] |
  {name, window_count: (.windows | length)} |
  sort_by(.window_count) |
  reverse |
  .[0] |
  "\(.name) (\(.window_count) windows)"
')

echo "Busiest:  $BUSIEST"
```

## Automation Examples

### Session Health Check

**Monitor session health:**

```bash
#!/bin/bash
# health-check.sh - Check tmux session health

check_session_health() {
  local json_data
  json_data=$(./tmux-tools overview --json)

  echo "=== Tmux Health Check ==="
  echo "Time: $(date)"
  echo

  # Check for sessions with no attached clients
  local detached_sessions
  detached_sessions=$(echo "$json_data" | jq -r '
    .sessions[] |
    select(.attached == false) |
    .name
  ')

  if [[ -n "$detached_sessions" ]]; then
    echo "⚠️  Detached sessions:"
    echo "$detached_sessions" | while read -r session; do
      echo "   - $session"
    done
    echo
  fi

  # Check for sessions with many windows
  local busy_sessions
  busy_sessions=$(echo "$json_data" | jq -r '
    .sessions[] |
    select((.windows | length) > 5) |
    "\(.name): \(.windows | length) windows"
  ')

  if [[ -n "$busy_sessions" ]]; then
    echo "📊 Busy sessions (>5 windows):"
    echo "$busy_sessions" | while read -r session; do
      echo "   - $session"
    done
    echo
  fi

  # Overall summary
  local total_sessions total_windows
  total_sessions=$(echo "$json_data" | jq '.sessions | length')
  total_windows=$(echo "$json_data" | jq '[.sessions[].windows] | length')

  echo "📈 Summary: $total_sessions sessions, $total_windows windows"
}

check_session_health
```

### Automated Cleanup

**Clean up old sessions:**

```bash
#!/bin/bash
# cleanup.sh - Remove old/unused sessions

cleanup_sessions() {
  echo "=== Session Cleanup ==="

  # Get detached sessions
  local detached_sessions
  detached_sessions=$(./tmux-tools overview --json | jq -r '
    .sessions[] |
    select(.attached == false) |
    .name
  ')

  if [[ -z "$detached_sessions" ]]; then
    echo "✅ No detached sessions to clean up"
    return
  fi

  echo "Found detached sessions:"
  echo "$detached_sessions" | while read -r session; do
    echo "  - $session"
  done

  read -p "Remove these sessions? (y/N): " -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "$detached_sessions" | while read -r session; do
      if tmux kill-session -t "$session" 2>/dev/null; then
        echo "✅ Removed: $session"
      else
        echo "❌ Failed to remove: $session"
      fi
    done
  else
    echo "❌ Cleanup cancelled"
  fi

  echo
  echo "Current status:"
  ./tmux-tools status
}

cleanup_sessions
```

## Integration Examples

### Shell Aliases

**Add to your `.bashrc` or `.zshrc`:**

```bash
# tmux-tools aliases
alias ts='tmux-tools status'
alias to='tmux-tools overview'
alias tr='tmux-tools rename auto'

# Quick session management
alias tn='tmux new-session -d -s'  # tn myproject
alias ta='tmux attach-session -t'  # ta myproject
alias tk='tmux kill-session -t'    # tk myproject

# Show status after session operations
tn() {
  tmux new-session -d -s "$1" -c "${2:-$(pwd)}"
  ts
}

tk() {
  tmux kill-session -t "$1" && ts
}
```

### Editor Integration

**Vim/Neovim integration (add to `.vimrc`):**

```vim
" tmux-tools integration
function! TmuxStatus()
  let output = system('tmux-tools status')
  echo output
endfunction

function! TmuxNewSession(name)
  let cmd = 'tmux new-session -d -s ' . shellescape(a:name) . ' -c ' . shellescape(getcwd())
  call system(cmd)
  call TmuxStatus()
endfunction

" Commands
command! TS call TmuxStatus()
command! -nargs=1 TN call TmuxNewSession(<f-args>)

" Key mappings
nnoremap <leader>ts :TS<CR>
nnoremap <leader>tn :TN<Space>
```

## Troubleshooting Examples

### Common Issues

**No tmux sessions found:**

```bash
# Check if tmux server is running
tmux list-sessions

# If not, create a test session
tmux new-session -d -s test

# Now try tmux-tools
./tmux-tools status
```

**Colors not showing:**

```bash
# Check terminal color support
echo $TERM

# Test colors manually
./tmux-tools status

# Force color mode
FORCE_COLOR=1 ./tmux-tools status

# Disable colors
NO_COLOR=1 ./tmux-tools status
```

**Configuration not loading:**

```bash
# Check configuration file location
./tmux-tools config show | grep "Configuration File"

# Create example configuration
./tmux-tools config create

# Verify configuration syntax
cat ~/.tmux-tools.yaml
```

### Debug Mode

**Enable debug output:**

```bash
# Set debug environment variable
export TMUX_TOOLS_DEBUG=1

# Run commands with debug output
./tmux-tools status
./tmux-tools config show

# Disable debug
unset TMUX_TOOLS_DEBUG
```

## Performance Examples

### Caching for Frequent Calls

**Cache tmux-tools output:**

```bash
#!/bin/bash
# cached-status.sh - Cache status for better performance

CACHE_FILE="/tmp/tmux-status-$$"
CACHE_TTL=5  # seconds

get_cached_status() {
  local cache_age=0

  if [[ -f "$CACHE_FILE" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      cache_age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE")))
    else
      cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE")))
    fi
  fi

  if [[ $cache_age -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
  else
    ./tmux-tools status | tee "$CACHE_FILE"
  fi
}

# Cleanup on exit
trap 'rm -f "$CACHE_FILE"' EXIT

get_cached_status
```

### Batch Operations

**Process multiple sessions efficiently:**

```bash
#!/bin/bash
# batch-operations.sh - Efficient batch processing

batch_rename_sessions() {
  echo "=== Batch Session Rename ==="

  # Get all sessions at once
  local sessions
  sessions=$(./tmux-tools overview --json | jq -r '.sessions[].name')

  echo "Sessions to rename:"
  echo "$sessions"

  # Single rename operation
  ./tmux-tools rename sessions

  echo
  echo "Results:"
  ./tmux-tools status
}

batch_rename_sessions
```

These examples provide a foundation for using tmux-tools effectively in various scenarios. Adapt them to your specific workflow and requirements.