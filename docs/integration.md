# Integration and Automation

## Overview

tmux-tools provides multiple integration points for automation, scripting, and workflow optimization. This guide covers common integration patterns, automation examples, and best practices for incorporating tmux-tools into your development workflow.

## JSON API Integration

### Machine-Readable Output

The `overview` command provides comprehensive JSON output for programmatic access:

```bash
tmux-tools overview --json
```

### JSON Schema

```json
{
  "sessions": [
    {
      "name": "session_name",
      "created": "YYYY-MM-DD HH:MM:SS",
      "attached": true|false,
      "windows": [
        {
          "index": 0,
          "name": "window_name",
          "panes": 3,
          "active": true|false,
          "pane_details": [
            {
              "index": 0,
              "command": "command_name",
              "path": "/full/path",
              "active": true|false
            }
          ]
        }
      ]
    }
  ]
}
```

### Common JSON Queries

| Task | Command | jq Pattern |
|:-----|:--------|:-----------|
| **Count total sessions** | `tmux-tools overview --json` | `[.sessions] \| length` |
| **Count total windows** | `tmux-tools overview --json` | `[.sessions[].windows] \| length` |
| **Count total panes** | `tmux-tools overview --json` | `[.sessions[].windows[].panes] \| add` |
| **List all commands** | `tmux-tools overview --json` | `.sessions[].windows[].pane_details[].command \| unique` |
| **Find active sessions** | `tmux-tools overview --json` | `.sessions[] \| select(.attached == true) \| .name` |
| **Get session by name** | `tmux-tools overview --json` | `.sessions[] \| select(.name == "oslo")` |
| **Find busy sessions** | `tmux-tools overview --json` | `.sessions[] \| select(.windows \| length > 3) \| .name` |
| **List all paths** | `tmux-tools overview --json` | `.sessions[].windows[].pane_details[].path \| unique` |

## Automation Scripts

### Session Health Monitoring

**Monitor session activity and alert on idle sessions:**

```bash
#!/bin/bash
# monitor-sessions.sh - Alert on idle sessions

check_idle_sessions() {
  local max_idle_hours=${1:-24}
  local current_time=$(date +%s)

  tmux-tools overview --json | jq -r --argjson max_hours "$max_idle_hours" '
    .sessions[] |
    select(.attached == false) |
    select((now - (.created | strptime("%Y-%m-%d %H:%M:%S") | mktime)) > ($max_hours * 3600)) |
    "Session \(.name) has been idle for over \($max_hours) hours"
  '
}

# Alert on sessions idle for more than 48 hours
check_idle_sessions 48
```

### Automated Session Cleanup

**Clean up sessions based on criteria:**

```bash
#!/bin/bash
# cleanup-sessions.sh - Remove sessions matching criteria

cleanup_old_sessions() {
  local days_old=${1:-7}

  # Get sessions older than N days
  old_sessions=$(tmux-tools overview --json | jq -r --argjson days "$days_old" '
    .sessions[] |
    select(.attached == false) |
    select((now - (.created | strptime("%Y-%m-%d %H:%M:%S") | mktime)) > ($days * 86400)) |
    .name
  ')

  for session in $old_sessions; do
    echo "Removing old session: $session"
    tmux kill-session -t "$session"
  done
}

# Remove sessions older than 7 days
cleanup_old_sessions 7
```

### Development Environment Setup

**Automatically create development sessions:**

```bash
#!/bin/bash
# dev-setup.sh - Create standardized development environment

create_dev_session() {
  local project_name="$1"
  local project_path="$2"

  # Create session with project name
  tmux new-session -d -s "$project_name" -c "$project_path"

  # Create windows for different purposes
  tmux new-window -t "$project_name" -n "editor" -c "$project_path"
  tmux new-window -t "$project_name" -n "server" -c "$project_path"
  tmux new-window -t "$project_name" -n "tests" -c "$project_path"
  tmux new-window -t "$project_name" -n "logs" -c "$project_path"

  # Send commands to specific windows
  tmux send-keys -t "$project_name:editor" "nvim ." Enter
  tmux send-keys -t "$project_name:server" "npm run dev" Enter
  tmux send-keys -t "$project_name:tests" "npm run test:watch" Enter
  tmux send-keys -t "$project_name:logs" "tail -f logs/app.log" Enter

  # Use tmux-tools to rename with consistent naming
  tmux-tools rename auto

  # Show status
  tmux-tools status
}

# Usage: ./dev-setup.sh myproject ~/projects/myproject
create_dev_session "$1" "$2"
```

### Session Backup and Restore

**Backup and restore session configurations:**

```bash
#!/bin/bash
# session-backup.sh - Backup/restore session state

backup_sessions() {
  local backup_file="${1:-tmux-sessions-$(date +%Y%m%d-%H%M%S).json}"

  # Create comprehensive backup
  {
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"hostname\": \"$(hostname)\","
    echo "  \"sessions\": $(tmux-tools overview --json | jq '.sessions')"
    echo "}"
  } > "$backup_file"

  echo "Sessions backed up to: $backup_file"
}

restore_sessions() {
  local backup_file="$1"

  if [[ ! -f "$backup_file" ]]; then
    echo "Backup file not found: $backup_file"
    return 1
  fi

  # Parse backup and recreate sessions
  jq -r '.sessions[] |
    "tmux new-session -d -s \(.name); " +
    (.windows[] | "tmux new-window -t \(.session):\(.index) -n \(.name); ") +
    "echo \"Restored session: \(.name)\""
  ' "$backup_file" | bash

  # Apply naming
  tmux-tools rename auto
}

# Usage:
# ./session-backup.sh backup
# ./session-backup.sh restore backup-file.json
case "$1" in
  backup) backup_sessions "$2" ;;
  restore) restore_sessions "$2" ;;
  *) echo "Usage: $0 {backup|restore} [file]" ;;
esac
```

## Workflow Integration

### Git Integration

**Create sessions for git branches:**

```bash
#!/bin/bash
# git-session.sh - Create sessions for git branches

create_branch_sessions() {
  local repo_path="${1:-$(pwd)}"

  cd "$repo_path" || exit 1

  # Get all branches
  git branch -a | grep -v HEAD | sed 's/^[* ]*//' | while read -r branch; do
    # Clean branch name for session
    session_name=$(echo "$branch" | sed 's/origin\///' | tr '/' '-')

    # Create session for branch
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
      tmux new-session -d -s "$session_name" -c "$repo_path"
      tmux send-keys -t "$session_name" "git checkout $branch" Enter
      echo "Created session '$session_name' for branch '$branch'"
    fi
  done

  # Rename sessions consistently
  tmux-tools rename auto
  tmux-tools status
}

create_branch_sessions "$1"
```

### Project Discovery

**Auto-create sessions for projects:**

```bash
#!/bin/bash
# project-discovery.sh - Auto-discover and create project sessions

discover_projects() {
  local projects_dir="${1:-$HOME/projects}"

  find "$projects_dir" -maxdepth 2 -type d -name ".git" | while read -r git_dir; do
    project_dir=$(dirname "$git_dir")
    project_name=$(basename "$project_dir")

    # Check if session already exists
    if ! tmux has-session -t "$project_name" 2>/dev/null; then
      # Create session for project
      tmux new-session -d -s "$project_name" -c "$project_dir"

      # Add development windows if package.json exists
      if [[ -f "$project_dir/package.json" ]]; then
        tmux new-window -t "$project_name" -n "server" -c "$project_dir"
        tmux new-window -t "$project_name" -n "tests" -c "$project_dir"
      fi

      echo "Created session for project: $project_name"
    fi
  done

  tmux-tools rename auto
  tmux-tools overview
}

discover_projects "$1"
```

### System Monitoring Integration

**Integrate with system monitoring:**

```bash
#!/bin/bash
# tmux-metrics.sh - Export tmux metrics for monitoring

export_metrics() {
  local metrics_file="${1:-/tmp/tmux-metrics.json}"

  # Generate comprehensive metrics
  {
    echo "{"
    echo "  \"timestamp\": $(date +%s),"
    echo "  \"hostname\": \"$(hostname)\","

    # Session metrics
    local session_count=$(tmux-tools overview --json | jq '[.sessions] | length')
    local attached_count=$(tmux-tools overview --json | jq '[.sessions[] | select(.attached == true)] | length')
    local window_count=$(tmux-tools overview --json | jq '[.sessions[].windows] | length')
    local pane_count=$(tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add')

    echo "  \"sessions\": {"
    echo "    \"total\": $session_count,"
    echo "    \"attached\": $attached_count,"
    echo "    \"detached\": $((session_count - attached_count))"
    echo "  },"
    echo "  \"windows\": {"
    echo "    \"total\": $window_count,"
    echo "    \"avg_per_session\": $(echo "scale=2; $window_count / $session_count" | bc -l)"
    echo "  },"
    echo "  \"panes\": {"
    echo "    \"total\": $pane_count,"
    echo "    \"avg_per_window\": $(echo "scale=2; $pane_count / $window_count" | bc -l)"
    echo "  }"
    echo "}"
  } > "$metrics_file"

  echo "Metrics exported to: $metrics_file"
}

# Export metrics every 5 minutes for monitoring
while true; do
  export_metrics
  sleep 300
done
```

## Shell Integration

### Bash/Zsh Functions

Add these functions to your shell profile:

```bash
# ~/.bashrc or ~/.zshrc

# Quick tmux-tools commands
alias ts='tmux-tools status'
alias to='tmux-tools overview'
alias tr='tmux-tools rename auto'

# Function to create named session and switch to it
tmux-session() {
  local session_name="$1"
  local start_dir="${2:-$(pwd)}"

  if [[ -z "$session_name" ]]; then
    echo "Usage: tmux-session <name> [directory]"
    return 1
  fi

  # Create session if it doesn't exist
  if ! tmux has-session -t "$session_name" 2>/dev/null; then
    tmux new-session -d -s "$session_name" -c "$start_dir"
    echo "Created new session: $session_name"
  fi

  # Attach to session
  tmux attach-session -t "$session_name"
}

# Function to kill session and show updated status
tmux-kill() {
  local session_name="$1"

  if [[ -z "$session_name" ]]; then
    tmux-tools overview
    echo "Usage: tmux-kill <session_name>"
    return 1
  fi

  if tmux kill-session -t "$session_name" 2>/dev/null; then
    echo "Killed session: $session_name"
    tmux-tools status
  else
    echo "Session not found: $session_name"
  fi
}

# Function to show session with filtering
tmux-find() {
  local pattern="$1"

  if [[ -z "$pattern" ]]; then
    tmux-tools overview
  else
    tmux-tools overview --json | jq --arg pattern "$pattern" '
      .sessions[] |
      select(.name | contains($pattern)) |
      {name, attached, windows: [.windows[].name]}
    '
  fi
}
```

### Fish Shell Integration

```fish
# ~/.config/fish/config.fish

# Abbreviations for quick access
abbr ts 'tmux-tools status'
abbr to 'tmux-tools overview'
abbr tr 'tmux-tools rename auto'

# Function to create and attach to session
function tmux-session
    set session_name $argv[1]
    set start_dir (test -n "$argv[2]"; and echo $argv[2]; or pwd)

    if test -z "$session_name"
        echo "Usage: tmux-session <name> [directory]"
        return 1
    end

    if not tmux has-session -t "$session_name" 2>/dev/null
        tmux new-session -d -s "$session_name" -c "$start_dir"
        echo "Created new session: $session_name"
    end

    tmux attach-session -t "$session_name"
end

# Auto-completion for session names
complete -c tmux-session -a '(tmux-tools overview --json | jq -r ".sessions[].name")'
complete -c tmux-kill -a '(tmux-tools overview --json | jq -r ".sessions[].name")'
```

## Editor Integration

### Vim/Neovim Integration

```vim
" ~/.vimrc or ~/.config/nvim/init.vim

" Function to show tmux status in vim
function! TmuxStatus()
  let output = system('tmux-tools status')
  echo output
endfunction

" Function to create new tmux session from vim
function! TmuxNewSession(name)
  let cmd = 'tmux new-session -d -s ' . shellescape(a:name) . ' -c ' . shellescape(getcwd())
  call system(cmd)
  echo 'Created session: ' . a:name
  call TmuxStatus()
endfunction

" Commands
command! TmuxStatus call TmuxStatus()
command! -nargs=1 TmuxNew call TmuxNewSession(<f-args>)

" Key mappings
nnoremap <leader>ts :TmuxStatus<CR>
nnoremap <leader>tn :TmuxNew
```

### VSCode Integration

Create a VSCode task in `.vscode/tasks.json`:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Show Tmux Status",
      "type": "shell",
      "command": "tmux-tools",
      "args": ["status"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "Create Dev Session",
      "type": "shell",
      "command": "tmux",
      "args": [
        "new-session", "-d", "-s", "${workspaceFolderBasename}-dev",
        "-c", "${workspaceFolder}"
      ],
      "group": "build"
    }
  ]
}
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/tmux-test.yml
name: Test tmux-tools Integration

on: [push, pull_request]

jobs:
  test-tmux-integration:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Install tmux
      run: sudo apt-get update && sudo apt-get install -y tmux

    - name: Setup tmux-tools
      run: |
        chmod +x tmux-tools
        ./tmux-tools help

    - name: Test session creation
      run: |
        tmux new-session -d -s test-session
        ./tmux-tools status
        ./tmux-tools overview --json > sessions.json
        cat sessions.json

    - name: Test automation scripts
      run: |
        # Test JSON parsing
        SESSION_COUNT=$(./tmux-tools overview --json | jq '[.sessions] | length')
        echo "Found $SESSION_COUNT sessions"
        test "$SESSION_COUNT" -gt 0
```

### Docker Integration

```dockerfile
# Dockerfile for tmux-tools environment
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    tmux \
    jq \
    curl \
    && rm -rf /var/lib/apt/lists/*

COPY tmux-tools /usr/local/bin/
COPY lib/ /usr/local/lib/tmux-tools/
RUN chmod +x /usr/local/bin/tmux-tools

# Example automation script
COPY scripts/monitor-sessions.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/monitor-sessions.sh

ENTRYPOINT ["tmux-tools"]
CMD ["help"]
```

## Performance Optimization

### Caching Strategies

```bash
#!/bin/bash
# cached-status.sh - Cache tmux status for better performance

CACHE_FILE="/tmp/tmux-status-cache"
CACHE_TTL=5  # seconds

get_cached_status() {
  local cache_age=0

  if [[ -f "$CACHE_FILE" ]]; then
    cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || stat -f %m "$CACHE_FILE")))
  fi

  if [[ $cache_age -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
  else
    tmux-tools status | tee "$CACHE_FILE"
  fi
}

get_cached_status
```

### Parallel Processing

```bash
#!/bin/bash
# parallel-metrics.sh - Collect metrics in parallel

collect_metrics() {
  # Run multiple commands in parallel
  {
    echo "sessions: $(tmux-tools overview --json | jq '[.sessions] | length')" &
    echo "windows: $(tmux-tools overview --json | jq '[.sessions[].windows] | length')" &
    echo "panes: $(tmux-tools overview --json | jq '[.sessions[].windows[].panes] | add')" &
    wait
  } | sort
}

collect_metrics
```

## Best Practices

### Automation Guidelines

1. **Error Handling**: Always check return codes and handle failures gracefully
2. **Resource Limits**: Avoid creating excessive sessions/windows
3. **Cleanup**: Implement cleanup mechanisms for automated session creation
4. **Logging**: Log automation activities for debugging
5. **Testing**: Test automation scripts in safe environments

### Integration Patterns

1. **Idempotent Operations**: Scripts should be safe to run multiple times
2. **Configuration**: Use environment variables for customization
3. **Graceful Degradation**: Handle missing dependencies gracefully
4. **Documentation**: Document integration points and requirements
5. **Monitoring**: Include health checks and monitoring capabilities