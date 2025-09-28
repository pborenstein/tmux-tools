# Advanced Workflows

## Overview

This guide covers sophisticated tmux-tools usage patterns for power users, including complex automation, multi-environment management, and integration with development tools.

## Multi-Environment Management

### Environment-Specific Sessions

**Maintain separate environments with consistent naming:**

```bash
#!/bin/bash
# env-manager.sh - Manage multiple development environments

create_environment() {
  local env_name="$1"
  local base_path="$2"

  case "$env_name" in
    development)
      create_dev_environment "$base_path"
      ;;
    staging)
      create_staging_environment "$base_path"
      ;;
    production)
      create_prod_environment "$base_path"
      ;;
    *)
      echo "Unknown environment: $env_name"
      return 1
      ;;
  esac
}

create_dev_environment() {
  local base_path="$1"

  # Development configuration
  cat > /tmp/dev-config.yaml << EOF
naming:
  session_pool: "custom"
  custom_sessions:
    - "frontend-dev"
    - "backend-dev"
    - "database-dev"
    - "testing-dev"
    - "monitoring-dev"

  window_pool: "custom"
  custom_windows:
    - "editor"
    - "server"
    - "logs"
    - "terminal"
    - "browser"
EOF

  # Create sessions with development setup
  TMUX_TOOLS_CONFIG=/tmp/dev-config.yaml create_project_sessions "$base_path"
}

create_staging_environment() {
  local base_path="$1"

  cat > /tmp/staging-config.yaml << EOF
naming:
  session_pool: "custom"
  custom_sessions:
    - "frontend-staging"
    - "backend-staging"
    - "database-staging"
    - "monitoring-staging"

display:
  theme: "subtle"
  attachment_indicator: "→"
EOF

  TMUX_TOOLS_CONFIG=/tmp/staging-config.yaml create_project_sessions "$base_path"
}

create_prod_environment() {
  local base_path="$1"

  cat > /tmp/prod-config.yaml << EOF
naming:
  session_pool: "custom"
  custom_sessions:
    - "frontend-prod"
    - "backend-prod"
    - "database-prod"
    - "monitoring-prod"
    - "alerts-prod"

display:
  theme: "monochrome"
  show_timestamps: true
EOF

  TMUX_TOOLS_CONFIG=/tmp/prod-config.yaml create_project_sessions "$base_path"
}

create_project_sessions() {
  local base_path="$1"

  # Create core sessions
  tmux new-session -d -s "frontend" -c "$base_path/frontend"
  tmux new-session -d -s "backend" -c "$base_path/backend"
  tmux new-session -d -s "database" -c "$base_path/database"
  tmux new-session -d -s "monitoring" -c "$base_path/monitoring"

  # Apply environment-specific naming
  ./tmux-tools rename sessions

  # Show environment status
  ./tmux-tools overview
}

# Usage examples
create_environment "development" "$HOME/projects/myapp"
create_environment "staging" "$HOME/projects/myapp"
create_environment "production" "$HOME/deploy/myapp"
```

### Environment Switching

**Switch between environments seamlessly:**

```bash
#!/bin/bash
# env-switch.sh - Switch between environments

switch_environment() {
  local target_env="$1"

  echo "=== Switching to $target_env environment ==="

  # Save current environment state
  save_current_environment

  # Kill current sessions (with confirmation)
  if confirm_environment_switch; then
    cleanup_current_environment
    load_environment "$target_env"
  fi
}

save_current_environment() {
  local backup_file="$HOME/.tmux-tools/environment-backup-$(date +%Y%m%d-%H%M%S).json"

  mkdir -p "$(dirname "$backup_file")"

  # Save comprehensive environment state
  {
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"environment\": \"$(get_current_environment)\","
    echo "  \"sessions\": $(./tmux-tools overview --json | jq '.sessions')"
    echo "}"
  } > "$backup_file"

  echo "Environment saved to: $backup_file"
}

get_current_environment() {
  # Detect current environment from session names
  ./tmux-tools overview --json | jq -r '
    .sessions[].name |
    if contains("-dev") then "development"
    elif contains("-staging") then "staging"
    elif contains("-prod") then "production"
    else "unknown"
    end
  ' | head -1
}

confirm_environment_switch() {
  echo "Current sessions:"
  ./tmux-tools status

  read -p "Switch environment? This will close all current sessions (y/N): " -r
  [[ $REPLY =~ ^[Yy]$ ]]
}

cleanup_current_environment() {
  echo "Cleaning up current environment..."
  tmux kill-server 2>/dev/null || true
  sleep 1
}

load_environment() {
  local env_name="$1"
  local env_config="$HOME/.tmux-tools/environments/$env_name.yaml"

  if [[ -f "$env_config" ]]; then
    echo "Loading $env_name environment..."
    TMUX_TOOLS_CONFIG="$env_config" create_environment "$env_name"
  else
    echo "Environment config not found: $env_config"
    return 1
  fi
}

# Usage
switch_environment "staging"
```

## Advanced Session Management

### Session Templates

**Create reusable session templates:**

```bash
#!/bin/bash
# session-templates.sh - Reusable session templates

# Template definitions
declare -A TEMPLATES

TEMPLATES[web-development]="
  session_name=web-dev
  windows='frontend:3 backend:2 database:1 testing:2'
  commands='
    frontend:0:npm run dev
    frontend:1:npm run build:watch
    frontend:2:npm run lint:watch
    backend:0:npm run server:dev
    backend:1:npm run api:test
    database:0:docker-compose up -d
    testing:0:npm run test:watch
    testing:1:npm run e2e:watch
  '
"

TEMPLATES[data-science]="
  session_name=data-analysis
  windows='notebook:1 processing:2 visualization:1 experiments:3'
  commands='
    notebook:0:jupyter lab
    processing:0:python data_pipeline.py
    processing:1:python -i analysis.py
    visualization:0:python viz_server.py
    experiments:0:python experiment_1.py
    experiments:1:python experiment_2.py
    experiments:2:python -i scratch.py
  '
"

TEMPLATES[devops]="
  session_name=infrastructure
  windows='monitoring:2 deployment:1 logs:3 alerts:1'
  commands='
    monitoring:0:htop
    monitoring:1:docker stats
    deployment:0:kubectl get pods -w
    logs:0:tail -f /var/log/app.log
    logs:1:tail -f /var/log/nginx.log
    logs:2:tail -f /var/log/error.log
    alerts:0:python alert_monitor.py
  '
"

create_from_template() {
  local template_name="$1"
  local project_path="${2:-$(pwd)}"

  if [[ -z "${TEMPLATES[$template_name]}" ]]; then
    echo "Unknown template: $template_name"
    echo "Available templates: ${!TEMPLATES[*]}"
    return 1
  fi

  # Parse template
  eval "${TEMPLATES[$template_name]}"

  echo "Creating session from template: $template_name"
  echo "Session name: $session_name"
  echo "Project path: $project_path"

  # Create base session
  tmux new-session -d -s "$session_name" -c "$project_path"

  # Create windows with specified pane counts
  for window_spec in $windows; do
    IFS=':' read -r window_name pane_count <<< "$window_spec"

    # Create window
    tmux new-window -t "$session_name" -n "$window_name" -c "$project_path"

    # Create additional panes
    for ((i=1; i<pane_count; i++)); do
      tmux split-window -t "$session_name:$window_name" -c "$project_path"
      tmux select-layout -t "$session_name:$window_name" tiled
    done
  done

  # Execute commands in specific panes
  while IFS= read -r command_spec; do
    [[ -z "$command_spec" ]] && continue

    IFS=':' read -r window_name pane_index command <<< "$command_spec"
    if [[ -n "$command" ]]; then
      tmux send-keys -t "$session_name:$window_name.$pane_index" "$command" Enter
    fi
  done <<< "$commands"

  # Apply consistent naming
  ./tmux-tools rename windows

  # Show created session
  ./tmux-tools overview --session "$session_name"

  echo "Template created successfully!"
  echo "Attach with: tmux attach-session -t $session_name"
}

list_templates() {
  echo "Available session templates:"
  for template in "${!TEMPLATES[@]}"; do
    echo "  - $template"
  done
}

# Usage examples
case "${1:-list}" in
  list)
    list_templates
    ;;
  *)
    create_from_template "$1" "$2"
    ;;
esac
```

### Session Orchestration

**Orchestrate complex multi-session workflows:**

```bash
#!/bin/bash
# session-orchestrator.sh - Orchestrate complex workflows

# Workflow definitions
declare -A WORKFLOWS

WORKFLOWS[microservices-dev]="
  description='Full microservices development environment'
  dependencies='docker,kubectl,node,python'
  sessions='
    api-gateway:$HOME/projects/api-gateway
    user-service:$HOME/projects/user-service
    order-service:$HOME/projects/order-service
    payment-service:$HOME/projects/payment-service
    notification-service:$HOME/projects/notification-service
    database:$HOME/projects/infrastructure
    monitoring:$HOME/projects/monitoring
  '
  post_create='setup_microservices_networking'
"

WORKFLOWS[ml-pipeline]="
  description='Machine learning pipeline development'
  dependencies='python,jupyter,docker'
  sessions='
    data-ingestion:$HOME/ml-project/ingestion
    preprocessing:$HOME/ml-project/preprocessing
    training:$HOME/ml-project/training
    evaluation:$HOME/ml-project/evaluation
    deployment:$HOME/ml-project/deployment
    monitoring:$HOME/ml-project/monitoring
  '
  post_create='setup_ml_environment'
"

WORKFLOWS[fullstack-app]="
  description='Full-stack application development'
  dependencies='node,docker,postgres'
  sessions='
    frontend:$HOME/projects/app/frontend
    backend:$HOME/projects/app/backend
    database:$HOME/projects/app/database
    testing:$HOME/projects/app/tests
    docs:$HOME/projects/app/docs
  '
  post_create='setup_fullstack_environment'
"

create_workflow() {
  local workflow_name="$1"

  if [[ -z "${WORKFLOWS[$workflow_name]}" ]]; then
    echo "Unknown workflow: $workflow_name"
    list_workflows
    return 1
  fi

  # Parse workflow definition
  eval "${WORKFLOWS[$workflow_name]}"

  echo "=== Creating workflow: $workflow_name ==="
  echo "Description: $description"

  # Check dependencies
  if ! check_dependencies "$dependencies"; then
    echo "❌ Dependency check failed"
    return 1
  fi

  echo "✅ Dependencies satisfied"

  # Create sessions
  echo "Creating sessions..."
  while IFS= read -r session_spec; do
    [[ -z "$session_spec" ]] && continue

    IFS=':' read -r session_name session_path <<< "$session_spec"

    if [[ -d "$session_path" ]]; then
      tmux new-session -d -s "$session_name" -c "$session_path"
      echo "  ✅ Created: $session_name ($session_path)"
    else
      echo "  ⚠️  Path not found: $session_path (creating session anyway)"
      tmux new-session -d -s "$session_name"
    fi
  done <<< "$sessions"

  # Apply consistent naming
  ./tmux-tools rename sessions

  # Run post-creation setup
  if [[ -n "$post_create" ]] && declare -f "$post_create" >/dev/null; then
    echo "Running post-creation setup..."
    "$post_create"
  fi

  echo
  echo "=== Workflow created successfully ==="
  ./tmux-tools overview
}

check_dependencies() {
  local deps="$1"
  local missing_deps=()

  IFS=',' read -ra dep_array <<< "$deps"
  for dep in "${dep_array[@]}"; do
    if ! command -v "$dep" >/dev/null 2>&1; then
      missing_deps+=("$dep")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    echo "Missing dependencies: ${missing_deps[*]}"
    return 1
  fi

  return 0
}

# Post-creation setup functions
setup_microservices_networking() {
  echo "Setting up microservices networking..."

  # Start infrastructure
  tmux send-keys -t database "docker-compose up -d" Enter

  # Wait for database
  sleep 5

  # Start services in order
  for service in api-gateway user-service order-service payment-service notification-service; do
    tmux send-keys -t "$service" "npm run dev" Enter
    sleep 2
  done

  # Start monitoring
  tmux send-keys -t monitoring "docker-compose -f monitoring.yml up -d" Enter
}

setup_ml_environment() {
  echo "Setting up ML environment..."

  # Start Jupyter lab
  tmux send-keys -t data-ingestion "jupyter lab --no-browser" Enter

  # Start MLflow tracking
  tmux send-keys -t monitoring "mlflow server" Enter

  # Activate virtual environments for each service
  for session in preprocessing training evaluation deployment; do
    tmux send-keys -t "$session" "source venv/bin/activate" Enter
  done
}

setup_fullstack_environment() {
  echo "Setting up full-stack environment..."

  # Start database
  tmux send-keys -t database "docker-compose up -d postgres" Enter

  # Wait for database
  sleep 3

  # Start backend
  tmux send-keys -t backend "npm run dev" Enter

  # Start frontend
  tmux send-keys -t frontend "npm run dev" Enter

  # Start test runner
  tmux send-keys -t testing "npm run test:watch" Enter

  # Start documentation server
  tmux send-keys -t docs "npm run docs:dev" Enter
}

destroy_workflow() {
  local workflow_name="$1"

  if [[ -z "${WORKFLOWS[$workflow_name]}" ]]; then
    echo "Unknown workflow: $workflow_name"
    return 1
  fi

  eval "${WORKFLOWS[$workflow_name]}"

  echo "=== Destroying workflow: $workflow_name ==="

  # Extract session names and kill them
  echo "$sessions" | while IFS= read -r session_spec; do
    [[ -z "$session_spec" ]] && continue

    IFS=':' read -r session_name _ <<< "$session_spec"

    if tmux has-session -t "$session_name" 2>/dev/null; then
      tmux kill-session -t "$session_name"
      echo "  ✅ Destroyed: $session_name"
    else
      echo "  ⚠️  Session not found: $session_name"
    fi
  done

  echo "Workflow destroyed"
}

list_workflows() {
  echo "Available workflows:"
  for workflow in "${!WORKFLOWS[@]}"; do
    eval "${WORKFLOWS[$workflow]}"
    echo "  $workflow - $description"
  done
}

save_workflow_state() {
  local workflow_name="$1"
  local state_file="$HOME/.tmux-tools/workflows/$workflow_name-$(date +%Y%m%d-%H%M%S).json"

  mkdir -p "$(dirname "$state_file")"

  ./tmux-tools overview --json > "$state_file"
  echo "Workflow state saved to: $state_file"
}

# Usage
case "${1:-list}" in
  list)
    list_workflows
    ;;
  create)
    create_workflow "$2"
    ;;
  destroy)
    destroy_workflow "$2"
    ;;
  save)
    save_workflow_state "$2"
    ;;
  *)
    echo "Usage: $0 {list|create|destroy|save} [workflow_name]"
    ;;
esac
```

## Advanced Monitoring and Analytics

### Real-time Session Monitoring

**Monitor tmux sessions with real-time updates:**

```bash
#!/bin/bash
# session-monitor.sh - Real-time session monitoring

monitor_sessions() {
  local update_interval="${1:-2}"
  local log_file="$HOME/.tmux-tools/session-monitor.log"

  mkdir -p "$(dirname "$log_file")"

  echo "=== tmux-tools Session Monitor ==="
  echo "Update interval: ${update_interval}s"
  echo "Log file: $log_file"
  echo "Press Ctrl+C to stop"
  echo

  # Initialize monitoring
  local previous_state=""
  local start_time=$(date +%s)

  while true; do
    clear
    echo "=== tmux Session Monitor ($(date)) ==="
    echo "Running for: $(($(date +%s) - start_time))s"
    echo

    # Get current state
    local current_state
    current_state=$(./tmux-tools overview --json)

    # Display current status
    ./tmux-tools status
    echo

    # Analyze changes
    if [[ -n "$previous_state" ]] && [[ "$current_state" != "$previous_state" ]]; then
      echo "🔄 Changes detected:"
      analyze_session_changes "$previous_state" "$current_state"
      echo
    fi

    # Display analytics
    display_session_analytics "$current_state"

    # Log current state
    {
      echo "$(date -Iseconds) - Session State"
      echo "$current_state"
      echo "---"
    } >> "$log_file"

    previous_state="$current_state"
    sleep "$update_interval"
  done
}

analyze_session_changes() {
  local previous="$1"
  local current="$2"

  # Compare session counts
  local prev_count curr_count
  prev_count=$(echo "$previous" | jq '.sessions | length')
  curr_count=$(echo "$current" | jq '.sessions | length')

  if [[ $curr_count -gt $prev_count ]]; then
    echo "  ➕ $((curr_count - prev_count)) new session(s)"
  elif [[ $curr_count -lt $prev_count ]]; then
    echo "  ➖ $((prev_count - curr_count)) session(s) removed"
  fi

  # Find new sessions
  local new_sessions
  new_sessions=$(comm -13 \
    <(echo "$previous" | jq -r '.sessions[].name' | sort) \
    <(echo "$current" | jq -r '.sessions[].name' | sort)
  )

  if [[ -n "$new_sessions" ]]; then
    echo "$new_sessions" | while read -r session; do
      echo "    📝 New session: $session"
    done
  fi

  # Find removed sessions
  local removed_sessions
  removed_sessions=$(comm -23 \
    <(echo "$previous" | jq -r '.sessions[].name' | sort) \
    <(echo "$current" | jq -r '.sessions[].name' | sort)
  )

  if [[ -n "$removed_sessions" ]]; then
    echo "$removed_sessions" | while read -r session; do
      echo "    🗑️  Removed session: $session"
    done
  fi
}

display_session_analytics() {
  local json_data="$1"

  echo "📊 Analytics:"

  # Basic counts
  local sessions windows panes
  sessions=$(echo "$json_data" | jq '.sessions | length')
  windows=$(echo "$json_data" | jq '[.sessions[].windows] | length')
  panes=$(echo "$json_data" | jq '[.sessions[].windows[].panes] | add // 0')

  echo "  Sessions: $sessions | Windows: $windows | Panes: $panes"

  # Attachment status
  local attached detached
  attached=$(echo "$json_data" | jq '[.sessions[] | select(.attached == true)] | length')
  detached=$(echo "$json_data" | jq '[.sessions[] | select(.attached == false)] | length')

  echo "  Attached: $attached | Detached: $detached"

  # Busiest session
  if [[ $sessions -gt 0 ]]; then
    local busiest
    busiest=$(echo "$json_data" | jq -r '
      .sessions[] |
      {name, windows: (.windows | length)} |
      sort_by(.windows) |
      reverse |
      .[0] |
      "\(.name) (\(.windows) windows)"
    ')
    echo "  Busiest: $busiest"
  fi

  # Resource usage (if available)
  if command -v ps >/dev/null 2>&1; then
    local tmux_processes
    tmux_processes=$(ps aux | grep tmux | grep -v grep | wc -l)
    echo "  tmux processes: $tmux_processes"
  fi
}

# Alert system
setup_alerts() {
  local alert_config="$HOME/.tmux-tools/alerts.conf"

  cat > "$alert_config" << 'EOF'
# tmux-tools alert configuration
MAX_SESSIONS=20
MAX_DETACHED_TIME=3600  # 1 hour in seconds
MAX_WINDOWS_PER_SESSION=10
ALERT_EMAIL=""  # Set email for notifications
EOF

  echo "Alert configuration created: $alert_config"
  echo "Edit this file to customize alert thresholds"
}

check_alerts() {
  local alert_config="$HOME/.tmux-tools/alerts.conf"

  if [[ -f "$alert_config" ]]; then
    source "$alert_config"
  else
    # Default values
    MAX_SESSIONS=20
    MAX_DETACHED_TIME=3600
    MAX_WINDOWS_PER_SESSION=10
  fi

  local json_data
  json_data=$(./tmux-tools overview --json)

  local alerts=()

  # Check session count
  local session_count
  session_count=$(echo "$json_data" | jq '.sessions | length')
  if [[ $session_count -gt $MAX_SESSIONS ]]; then
    alerts+=("Too many sessions: $session_count > $MAX_SESSIONS")
  fi

  # Check for sessions with too many windows
  local busy_sessions
  busy_sessions=$(echo "$json_data" | jq -r --argjson max "$MAX_WINDOWS_PER_SESSION" '
    .sessions[] |
    select((.windows | length) > $max) |
    "\(.name): \(.windows | length) windows"
  ')

  if [[ -n "$busy_sessions" ]]; then
    alerts+=("Sessions with too many windows:")
    while read -r session; do
      alerts+=("  $session")
    done <<< "$busy_sessions"
  fi

  # Display alerts
  if [[ ${#alerts[@]} -gt 0 ]]; then
    echo "🚨 ALERTS:"
    printf '%s\n' "${alerts[@]}"
    echo
  fi
}

# Performance monitoring
monitor_performance() {
  local duration="${1:-60}"  # seconds
  local samples=()

  echo "Monitoring tmux-tools performance for ${duration}s..."

  local start_time=$(date +%s)
  while [[ $(($(date +%s) - start_time)) -lt $duration ]]; do
    local cmd_start=$(date +%s.%N)
    ./tmux-tools status >/dev/null 2>&1
    local cmd_end=$(date +%s.%N)

    local cmd_time=$(echo "$cmd_end - $cmd_start" | bc -l)
    samples+=("$cmd_time")

    sleep 1
  done

  # Calculate statistics
  local total=0
  local count=${#samples[@]}
  local min=${samples[0]}
  local max=${samples[0]}

  for time in "${samples[@]}"; do
    total=$(echo "$total + $time" | bc -l)
    if (( $(echo "$time < $min" | bc -l) )); then
      min=$time
    fi
    if (( $(echo "$time > $max" | bc -l) )); then
      max=$time
    fi
  done

  local avg=$(echo "scale=4; $total / $count" | bc -l)

  echo "Performance Statistics:"
  echo "  Samples: $count"
  echo "  Average: ${avg}s"
  echo "  Min: ${min}s"
  echo "  Max: ${max}s"
}

# Usage
case "${1:-monitor}" in
  monitor)
    monitor_sessions "$2"
    ;;
  alerts)
    check_alerts
    ;;
  setup-alerts)
    setup_alerts
    ;;
  performance)
    monitor_performance "$2"
    ;;
  *)
    echo "Usage: $0 {monitor|alerts|setup-alerts|performance} [args]"
    ;;
esac
```

### Session Analytics Dashboard

**Generate comprehensive session analytics:**

```bash
#!/bin/bash
# analytics-dashboard.sh - Comprehensive session analytics

generate_dashboard() {
  local output_file="${1:-dashboard.html}"
  local json_data
  json_data=$(./tmux-tools overview --json)

  cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>tmux-tools Analytics Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .card { background: white; padding: 20px; margin: 20px 0; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .metric { display: inline-block; margin: 10px 20px; text-align: center; }
        .metric-value { font-size: 2em; font-weight: bold; color: #333; }
        .metric-label { color: #666; }
        .session-list { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .session-card { border-left: 4px solid #007acc; }
        .attached { border-left-color: #28a745; }
        .detached { border-left-color: #dc3545; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
    </style>
</head>
<body>
    <div class="container">
        <h1>tmux-tools Analytics Dashboard</h1>
        <p>Generated: <span id="timestamp"></span></p>

        <div class="card">
            <h2>Overview Metrics</h2>
            <div id="metrics"></div>
        </div>

        <div class="card">
            <h2>Session Status</h2>
            <div id="sessions" class="session-list"></div>
        </div>

        <div class="card">
            <h2>Detailed Session Table</h2>
            <table id="session-table">
                <thead>
                    <tr>
                        <th>Session</th>
                        <th>Status</th>
                        <th>Windows</th>
                        <th>Total Panes</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>

        <div class="card">
            <h2>Window Distribution</h2>
            <div id="window-chart"></div>
        </div>
    </div>

    <script>
        const data = DATA_PLACEHOLDER;

        // Set timestamp
        document.getElementById('timestamp').textContent = new Date().toLocaleString();

        // Generate metrics
        function generateMetrics() {
            const sessions = data.sessions;
            const totalSessions = sessions.length;
            const totalWindows = sessions.reduce((sum, s) => sum + s.windows.length, 0);
            const totalPanes = sessions.reduce((sum, s) => sum + s.windows.reduce((wsum, w) => wsum + w.panes, 0), 0);
            const attachedSessions = sessions.filter(s => s.attached).length;

            const metricsHtml = `
                <div class="metric">
                    <div class="metric-value">${totalSessions}</div>
                    <div class="metric-label">Total Sessions</div>
                </div>
                <div class="metric">
                    <div class="metric-value">${totalWindows}</div>
                    <div class="metric-label">Total Windows</div>
                </div>
                <div class="metric">
                    <div class="metric-value">${totalPanes}</div>
                    <div class="metric-label">Total Panes</div>
                </div>
                <div class="metric">
                    <div class="metric-value">${attachedSessions}</div>
                    <div class="metric-label">Attached Sessions</div>
                </div>
            `;

            document.getElementById('metrics').innerHTML = metricsHtml;
        }

        // Generate session cards
        function generateSessionCards() {
            const sessions = data.sessions;
            const sessionsHtml = sessions.map(session => `
                <div class="card session-card ${session.attached ? 'attached' : 'detached'}">
                    <h3>${session.name}</h3>
                    <p><strong>Status:</strong> ${session.attached ? 'Attached' : 'Detached'}</p>
                    <p><strong>Windows:</strong> ${session.windows.length}</p>
                    <p><strong>Total Panes:</strong> ${session.windows.reduce((sum, w) => sum + w.panes, 0)}</p>
                    <p><strong>Created:</strong> ${session.created}</p>
                    <details>
                        <summary>Windows</summary>
                        <ul>
                            ${session.windows.map(w => `<li>${w.index}:${w.name} (${w.panes} panes)</li>`).join('')}
                        </ul>
                    </details>
                </div>
            `).join('');

            document.getElementById('sessions').innerHTML = sessionsHtml;
        }

        // Generate session table
        function generateSessionTable() {
            const sessions = data.sessions;
            const tableBody = document.querySelector('#session-table tbody');

            sessions.forEach(session => {
                const row = tableBody.insertRow();
                row.insertCell(0).textContent = session.name;
                row.insertCell(1).textContent = session.attached ? 'Attached' : 'Detached';
                row.insertCell(2).textContent = session.windows.length;
                row.insertCell(3).textContent = session.windows.reduce((sum, w) => sum + w.panes, 0);
                row.insertCell(4).textContent = session.created;
            });
        }

        // Generate window distribution chart
        function generateWindowChart() {
            const sessions = data.sessions;
            const windowCounts = sessions.map(s => ({ name: s.name, windows: s.windows.length }));
            windowCounts.sort((a, b) => b.windows - a.windows);

            const maxWindows = Math.max(...windowCounts.map(s => s.windows));
            const chartHtml = windowCounts.map(session => `
                <div style="display: flex; align-items: center; margin: 10px 0;">
                    <div style="width: 150px; text-align: right; padding-right: 10px;">${session.name}</div>
                    <div style="background: #007acc; height: 20px; width: ${(session.windows / maxWindows) * 300}px;"></div>
                    <div style="padding-left: 10px;">${session.windows}</div>
                </div>
            `).join('');

            document.getElementById('window-chart').innerHTML = chartHtml;
        }

        // Initialize dashboard
        generateMetrics();
        generateSessionCards();
        generateSessionTable();
        generateWindowChart();
    </script>
</body>
</html>
EOF

  # Replace placeholder with actual data
  local escaped_json
  escaped_json=$(echo "$json_data" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr -d '\n')
  sed -i.bak "s/DATA_PLACEHOLDER/$escaped_json/" "$output_file"
  rm -f "$output_file.bak"

  echo "Dashboard generated: $output_file"
  echo "Open in browser: file://$(pwd)/$output_file"
}

# Usage
generate_dashboard "$1"
```

These advanced workflows provide sophisticated tools for managing complex tmux environments, monitoring session health, and analyzing usage patterns. They demonstrate the power of combining tmux-tools with shell scripting for comprehensive session management.