#!/bin/bash

#=============================================================================
# tmux-status.sh - Tmux Session Status Display and Renaming Tool
#=============================================================================
#
# PURPOSE:
#   Displays a tabular view of all tmux sessions, windows, and panes
#   with process information and optional session/window renaming capabilities.
#   Provides a clean tabular format showing the complete tmux environment.
#
# FUNCTIONALITY:
#   1. Displays all tmux sessions, windows, and panes in a compact table
#   2. Shows running command and client width by default
#   3. Shows process ID (PID) and full paths only with --show-pid flag
#   4. Displays client width to help identify device connections
#   5. Optionally renames tmux sessions using predefined city names
#   6. Optionally renames tmux windows based on their active pane's directory
#   7. Groups output by session with visual separation between sessions
#   8. Shows window names only for first pane of each window
#
# COMMAND-LINE ARGUMENTS:
#   --no-rename         Skip all session renaming operations. Only display status.
#                       This is the default behavior.
#
#   --rename-auto       Rename sessions that are not city names and windows based
#                       on their active pane's directory, then display status.
#                       This combines session and window renaming in one command.
#
#   --rename-sessions   Rename ALL existing sessions to random city names.
#
#   --rename-windows    Rename ALL windows based on their active pane's current directory.
#
#   --show-pid          Show PID and path columns (hidden by default).
#
#   (no flags)          Default behavior: compact display, no renaming.
#
# OUTPUT FORMAT (COMPACT - DEFAULT):
#   session       win  name      p  cmd      w
#   -------       ---  --------  -  -------  ---
#   tokyo         0    bear      0  fish     142
#                 0              1  vim
#                 1    cat       0  zsh
#
#   berlin        0    fox       0  bash     89
#
# OUTPUT FORMAT (DETAILED - WITH --show-pid):
#   session       win  name      p  cmd      w    pid    path
#   -------       ---  --------  -  -------  ---  -----  ----
#   tokyo         0    bear      0  fish     142  1234   /home/user
#                 0              1  vim           5678   /home/user/project
#                 1    cat       0  zsh           9012   /tmp
#
# USAGE EXAMPLES:
#   ./tmux-status.sh                    # Show compact status (default)
#   ./tmux-status.sh --show-pid         # Show detailed status with PID and paths
#   ./tmux-status.sh --rename-auto      # Rename sessions to cities, windows to directories
#   ./tmux-status.sh --rename-sessions  # Rename all sessions to city names
#   ./tmux-status.sh --rename-windows   # Rename all windows to directory names
#
# RENAMING BEHAVIOR:
#   City names for sessions (3-8 letters, lowercase):
#   rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney,
#   boston, madrid
#
#   Directory-based names for windows:
#   Windows are renamed to the basename of their active pane's current directory,
#   truncated to 20 characters max. For example: /home/user/my-project -> my-project
#
# BEHAVIOR NOTES:
#   - Compact layout by default maximizes screen real estate
#   - Client width column (w) shows terminal dimensions for device identification
#   - Sessions are grouped visually with blank lines between them
#   - Session names appear only on the first row of each session group
#   - Window names appear only on the first pane of each window
#   - Session renaming avoids conflicts by skipping to next available name
#   - Window renaming is per-session (names only need to be unique within session)
#   - PID and path columns hidden by default, shown with --show-pid
#   - Timestamp is included in the output header
#
#=============================================================================

# Get the directory where this script is located (resolving symlinks)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# Source shared libraries
source "$SCRIPT_DIR/lib/tmux_core.sh"
source "$SCRIPT_DIR/lib/tmux_display.sh"
source "$SCRIPT_DIR/lib/tmux_colors.sh"
source "$SCRIPT_DIR/lib/tmux_config.sh"

# Load configuration
load_config

# Parse arguments
no_rename=true  # Default: no renaming
rename_sessions=false
rename_windows=false
show_pid=false
theme_override=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      cat << 'EOF'
tmux-status.sh - Tmux Session Status Display and Renaming Tool

USAGE:
  ./tmux-status.sh [OPTIONS]

OPTIONS:
  --help, -h          Show this help message
  --theme THEME       Color theme (default, vibrant, subtle, monochrome, none)
  --no-rename         Skip all session renaming (default)
  --rename-auto       Rename sessions to cities, windows to directory names
  --rename-sessions   Rename ALL sessions to random city names
  --rename-windows    Rename all windows to their active pane's directory name
  --show-pid          Show PID and path columns (hidden by default)

EXAMPLES:
  ./tmux-status.sh                    # Show compact status
  ./tmux-status.sh --show-pid         # Show status with PID and path details
  ./tmux-status.sh --theme vibrant    # Use vibrant color theme
  ./tmux-status.sh --rename-auto      # Rename sessions to cities, windows to dirs
  ./tmux-status.sh --rename-sessions  # Rename all sessions to city names
  ./tmux-status.sh --rename-windows   # Rename all windows to directory names
EOF
      exit 0
      ;;
    --theme)
      if [[ -z "$2" || "$2" == --* ]]; then
        echo "Error: --theme requires a theme name" >&2
        exit 1
      fi
      theme_override="$2"
      shift 2
      ;;
    --no-rename)
      no_rename=true
      shift
      ;;
    --rename-auto)
      no_rename=false
      rename_windows=true
      shift
      ;;
    --rename-sessions)
      rename_sessions=true
      no_rename=false
      shift
      ;;
    --rename-windows)
      rename_windows=true
      shift
      ;;
    --show-pid)
      show_pid=true
      shift
      ;;
    *)
      echo "Error: Unknown option '$1'" >&2
      echo "Use --help for usage information" >&2
      exit 1
      ;;
  esac
done

# Initialize colors based on configuration or override
if [[ -n "$theme_override" ]]; then
  init_colors "$theme_override"
else
  init_colors "$(get_config_value "theme")"
fi

# Check tmux availability and status
if ! check_tmux_available; then
  exit 1
fi

if ! check_tmux_running; then
  exit 0
fi

# Get available session names from configuration
# Use mapfile if available, otherwise use while loop for compatibility
if command -v mapfile >/dev/null 2>&1; then
  mapfile -t session_names < <(get_session_names)
elif command -v readarray >/dev/null 2>&1; then
  readarray -t session_names < <(get_session_names)
else
  # Fallback for older bash versions
  session_names=()
  while IFS= read -r line; do
    session_names+=("$line")
  done < <(get_session_names)
fi

# Handle renaming based on flags
if [ "$no_rename" = false ]; then
  # Get all existing session names
  existing_sessions=$(get_session_data "#{session_name}")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to get tmux session list" >&2
    exit 1
  fi

  if [ "$rename_sessions" = true ]; then
    # Rename ALL sessions to unique city names
    shuffled_cities=("${session_names[@]}")

    # Simple shuffle using sort -R (BSD compatible)
    city_list=$(printf '%s\n' "${shuffled_cities[@]}" | sort -R)

    session_count=0
    echo "$existing_sessions" | while read -r session; do
      # Get the next available city name
      new_name=$(echo "$city_list" | sed -n "$((session_count + 1))p")

      # If we run out of city names, add numbers to the last city
      if [ -z "$new_name" ]; then
        last_city=$(echo "$city_list" | tail -1)
        overflow=$((session_count - ${#session_names[@]} + 1))
        new_name="${last_city}${overflow}"
      fi

      if [ "$new_name" != "$session" ]; then
        if ! rename_session "$session" "$new_name"; then
          echo "Warning: Failed to rename session '$session' to '$new_name'" >&2
        fi
      fi
      session_count=$((session_count + 1))
    done
  else
    # New behavior: rename sessions that are not in the city names list
    all_current_sessions=$(get_session_data "#{session_name}")

    echo "$existing_sessions" | while read -r session; do
      # Check if session name is NOT in the session names array
      session_is_valid=false
      for valid_name in "${session_names[@]}"; do
        if [[ "$session" == "$valid_name" ]]; then
          session_is_valid=true
          break
        fi
      done

      if [[ "$session_is_valid" == false ]]; then
        # Find an unused session name
        for name in "${session_names[@]}"; do
          if ! echo "$all_current_sessions" | grep -q "^${name}$"; then
            if ! rename_session "$session" "$name"; then
              echo "Warning: Failed to rename session '$session' to '$name'" >&2
            fi
            break
          fi
        done
      fi
    done
  fi
fi

# Handle window renaming
if [ "$rename_windows" = true ]; then
  # Get all sessions
  sessions=$(get_session_data "#{session_name}")
  if [ $? -ne 0 ]; then
    echo "Error: Failed to get tmux session list for window renaming" >&2
    exit 1
  fi

  echo "$sessions" | while read -r session; do
    # Get windows for this session
    windows=$(get_window_data "$session" "#{window_index} #{window_name}")
    if [ $? -ne 0 ]; then
      echo "Warning: Failed to get windows for session '$session'" >&2
      continue
    fi

    echo "$windows" | while read -r win_index win_name; do
      # Get smart name based on active pane's directory
      new_name=$(get_smart_window_name "$session" "$win_index")

      # Only rename if we got a valid name and it's different from current
      if [[ -n "$new_name" && "$new_name" != "$win_name" ]]; then
        if ! rename_window "$session" "$win_index" "$new_name"; then
          echo "Warning: Failed to rename window '${session}:${win_index}' to '$new_name'" >&2
        fi
      fi
    done
  done
fi

# Print header
print_status_header "$show_pid"

last_session=""
last_window=""
first_session=true

# Get client width data for sessions
client_data=$(get_client_data)

# Get session attachment data
session_data=$(get_session_data "#{session_name} #{session_attached}")

# Get pane data and handle empty case
pane_data=$(get_pane_data "" "#{session_name} #{window_index} #{window_name} #{pane_index} #{pane_pid} #{pane_current_command} #{pane_current_path}")
if [ $? -ne 0 ]; then
  echo "Error: Failed to get tmux pane information" >&2
  exit 1
fi

if [ -z "$pane_data" ]; then
  echo "No tmux sessions or panes found"
  exit 0
fi

echo "$pane_data" | while read -r session win_index win_name pane_index pid cmd path; do
  # Check if we need a session separator
  if needs_session_separator "$session" "$last_session" "$first_session"; then
    echo
  fi
  first_session=false

  # Format display elements
  session_display=$(format_session_display "$session" "$last_session")
  window_display=$(format_window_display "$session" "$win_index" "$win_name" "$last_window")
  current_window="${session}:${win_index}"

  # Get attachment indicator for this session (only show on first line of session)
  attachment_indicator=""
  if [ "$session" != "$last_session" ]; then
    session_attached=$(echo "$session_data" | grep "^$session " | cut -d' ' -f2)
    if [ -z "$session_attached" ]; then
      session_attached="0"
    fi
    attachment_indicator=$(format_attachment_display "$session" "$last_session" "$session_attached")
  fi

  # Get client width for this session (only show on first line of session)
  width_display=$(format_width_display "$session" "$last_session" "$(get_session_width "$session" "$client_data")")

  # Print output based on show_pid flag
  if [ "$show_pid" = true ]; then
    print_status_row "$attachment_indicator" "$session_display" "$win_index" "$window_display" "$pane_index" "$cmd" "$width_display" "$pid" "$path"
  else
    print_status_row "$attachment_indicator" "$session_display" "$win_index" "$window_display" "$pane_index" "$cmd" "$width_display"
  fi

  last_session="$session"
  last_window="$current_window"
done