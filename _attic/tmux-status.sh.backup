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
#   6. Optionally renames tmux windows using predefined mammal names
#   7. Groups output by session with visual separation between sessions
#   8. Shows window names only for first pane of each window
#
# COMMAND-LINE ARGUMENTS:
#   --no-rename         Skip all session renaming operations. Only display status.
#                       This is the default behavior.
#
#   --rename-auto       Rename sessions that are not city names and windows that
#                       are not mammal names to unused names, then display status.
#                       This combines session and window renaming in one command.
#
#   --rename-sessions   Rename ALL existing sessions to random city names.
#
#   --rename-windows    Rename ALL windows to random mammal names.
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
#   ./tmux-status.sh --rename-auto      # Rename non-city/non-mammal names
#   ./tmux-status.sh --rename-sessions  # Rename all sessions to city names
#   ./tmux-status.sh --rename-windows   # Rename all windows to mammal names
#
# RENAMING POOLS:
#   City names for sessions (3-8 letters, lowercase):
#   rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney,
#   boston, madrid
#
#   Mammal names for windows (3-8 letters, lowercase):
#   cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse
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

# Check if tmux is available
if ! command -v tmux >/dev/null 2>&1; then
  echo "Error: tmux is not installed or not in PATH" >&2
  exit 1
fi

# Check if tmux server is running
if ! tmux list-sessions >/dev/null 2>&1; then
  echo "No tmux sessions found (tmux server may not be running)" >&2
  exit 0
fi

# Parse arguments
no_rename=true  # Default: no renaming
rename_sessions=false
rename_windows=false
show_pid=false
while [[ $# -gt 0 ]]; do
  case $1 in
    --help|-h)
      cat << 'EOF'
tmux-status.sh - Tmux Session Status Display and Renaming Tool

USAGE:
  ./tmux-status.sh [OPTIONS]

OPTIONS:
  --help, -h          Show this help message
  --no-rename         Skip all session renaming (default)
  --rename-auto       Rename non-city sessions and non-mammal windows (both)
  --rename-sessions   Rename ALL sessions to random city names
  --rename-windows    Rename all windows to random mammal names
  --show-pid          Show PID and path columns (hidden by default)

EXAMPLES:
  ./tmux-status.sh                    # Show compact status
  ./tmux-status.sh --show-pid         # Show status with PID and path details
  ./tmux-status.sh --rename-auto      # Rename non-city/non-mammal names
  ./tmux-status.sh --rename-sessions  # Rename all sessions
  ./tmux-status.sh --rename-windows   # Rename all windows to mammals
EOF
      exit 0
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

# Configuration

# City names for renaming sessions (3-8 letters, lowercase)
cities=(
  "rio" "oslo" "lima" "bern"
  "cairo" "tokyo" "paris"
  "milan" "berlin" "sydney"
  "boston" "madrid"
)

# Mammal names for window renaming (3-8 letters, lowercase)
mammals=(
  "cat" "dog" "fox" "bat"
  "elk" "bear" "lion"
  "wolf" "seal" "deer"
  "otter" "mouse"
)

# Handle renaming based on flags
if [ "$no_rename" = false ]; then
  # Get all existing session names
  existing_sessions=$(tmux list-sessions -F '#{session_name}')
  if [ $? -ne 0 ]; then
    echo "Error: Failed to get tmux session list" >&2
    exit 1
  fi

  if [ "$rename_sessions" = true ]; then
    # Rename ALL sessions to unique city names
    # Create a shuffled copy of cities array: "${cities[@]}" expands all array elements
    shuffled_cities=("${cities[@]}")

    # Simple shuffle using sort -R (BSD compatible)
    # printf '%s\n' prints each array element on separate line for sort -R to shuffle
    city_list=$(printf '%s\n' "${shuffled_cities[@]}" | sort -R)

    session_count=0
    echo "$existing_sessions" | while read -r session; do
      # Get the next available city name
      # sed -n "Np" prints only line N; $((expr)) does arithmetic expansion
      new_name=$(echo "$city_list" | sed -n "$((session_count + 1))p")

      # If we run out of city names, add numbers to the last city
      if [ -z "$new_name" ]; then
        last_city=$(echo "$city_list" | tail -1)
        # ${#cities[@]} expands to the number of elements in cities array
        overflow=$((session_count - ${#cities[@]} + 1))
        new_name="${last_city}${overflow}"
      fi

      if [ "$new_name" != "$session" ]; then
        if ! tmux rename-session -t "$session" "$new_name"; then
          echo "Warning: Failed to rename session '$session' to '$new_name'" >&2
        fi
      fi
      session_count=$((session_count + 1))
    done
  else
    # New behavior: rename sessions that are not in the city names list
    # Get all session names (including any that might already be city names)
    all_current_sessions=$(tmux list-sessions -F '#{session_name}')

    echo "$existing_sessions" | while read -r session; do
      # Check if session name is NOT in the cities array
      session_is_city=false
      for city in "${cities[@]}"; do
        if [[ "$session" == "$city" ]]; then
          session_is_city=true
          break
        fi
      done

      if [[ "$session_is_city" == false ]]; then
        # Find an unused city name (check against current session list)
        for city in "${cities[@]}"; do
          if ! echo "$all_current_sessions" | grep -q "^${city}$"; then
            if ! tmux rename-session -t "$session" "$city"; then
              echo "Warning: Failed to rename session '$session' to '$city'" >&2
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
  sessions=$(tmux list-sessions -F '#{session_name}')
  if [ $? -ne 0 ]; then
    echo "Error: Failed to get tmux session list for window renaming" >&2
    exit 1
  fi

  echo "$sessions" | while read -r session; do
    # Get windows for this session
    windows=$(tmux list-windows -t "$session" -F '#{window_index} #{window_name}')
    if [ $? -ne 0 ]; then
      echo "Warning: Failed to get windows for session '$session'" >&2
      continue
    fi

    # Create a shuffled copy of mammals array for this session
    # Same pattern as cities: expand array elements and shuffle with sort -R
    shuffled_mammals=$(printf '%s\n' "${mammals[@]}" | sort -R)

    # Get existing window names in this session to avoid conflicts
    # cut -d' ' -f2- splits on space, takes from field 2 to end (window names)
    existing_names=$(echo "$windows" | cut -d' ' -f2-)

    mammal_index=0
    echo "$windows" | while read -r win_index win_name; do
      # Check if window name is already a valid mammal name
      window_is_mammal=false
      for mammal in "${mammals[@]}"; do
        if [[ "$win_name" == "$mammal" ]]; then
          window_is_mammal=true
          break
        fi
      done

      # Only rename if window name is not already a mammal name
      if [[ "$window_is_mammal" == false ]]; then
        # Find next available mammal name
        while true; do
          new_name=$(echo "$shuffled_mammals" | sed -n "$((mammal_index + 1))p")

          # If we run out of mammals, cycle back to the beginning
          if [ -z "$new_name" ]; then
            mammal_index=0
            new_name=$(echo "$shuffled_mammals" | sed -n "1p")
          fi

          # Check if this name is already used in this session
          # grep -q is quiet mode; "^name$" anchors ensure exact match
          if ! echo "$existing_names" | grep -q "^${new_name}$"; then
            break
          fi

          mammal_index=$((mammal_index + 1))
        done

        if [ "$new_name" != "$win_name" ]; then
          if ! tmux rename-window -t "${session}:${win_index}" "$new_name"; then
            echo "Warning: Failed to rename window '${session}:${win_index}' to '$new_name'" >&2
          fi
        fi

        mammal_index=$((mammal_index + 1))
      fi
    done
  done
fi

echo "TMUX STATUS $(date)"
echo
# Print headers based on show_pid flag
if [ "$show_pid" = true ]; then
  echo "  session       win  name      p  cmd      w    pid    path"
  echo "- -------       ---  --------  -  -------  ---  -----  ----"
else
  echo "  session       win  name      p  cmd      w"
  echo "- -------       ---  --------  -  -------  ---"
fi

last_session=""
last_window=""
first_session=true

# Get client width data for sessions
# Store as simple text for lookup (bash 3 compatible)
client_data=$(tmux list-clients -F '#{client_session} #{client_width}')

# Get session attachment data
session_data=$(tmux list-sessions -F '#{session_name} #{session_attached}')

# Get pane data and handle empty case
pane_data=$(tmux list-panes -a -F '#{session_name} #{window_index} #{window_name} #{pane_index} #{pane_pid} #{pane_current_command} #{pane_current_path}')
if [ $? -ne 0 ]; then
  echo "Error: Failed to get tmux pane information" >&2
  exit 1
fi

if [ -z "$pane_data" ]; then
  echo "No tmux sessions or panes found"
  exit 0
fi

echo "$pane_data" | while read -r session win_index win_name pane_index pid cmd path; do
  if [ "$first_session" = false ] && [ "$session" != "$last_session" ]; then
    echo
  fi
  first_session=false

  # Determine what to show in session and window name columns
  session_display="$session"
  window_display="$win_name"
  current_window="${session}:${win_index}"

  # Get attachment indicator for this session (only show on first line of session)
  attachment_indicator=""
  if [ "$session" != "$last_session" ]; then
    session_attached=$(echo "$session_data" | grep "^$session " | cut -d' ' -f2)
    if [ "$session_attached" = "0" ]; then
      attachment_indicator=" "
    elif [ "$session_attached" = "1" ]; then
      attachment_indicator="•"
    else
      attachment_indicator="$session_attached"
    fi
  fi

  if [ "$session" == "$last_session" ]; then
    session_display=""
  fi

  if [ "$current_window" == "$last_window" ]; then
    window_display=""
  fi

  # Get client width for this session (only show on first line of session)
  width_display=""
  if [ "$session" != "$last_session" ]; then
    # Get current client's width if we're in that session, otherwise use first client
    if [ "$session" = "$(tmux display-message -p '#{session_name}' 2>/dev/null)" ]; then
      width_display=$(tmux display-message -p '#{client_width}' 2>/dev/null)
    else
      width_display=$(echo "$client_data" | grep "^$session " | head -1 | cut -d' ' -f2)
    fi
    width_display="${width_display:-"-"}"
  fi

  # Print output based on show_pid flag with tighter column widths
  if [ "$show_pid" = true ]; then
    printf "%-1s %-13s %-3s  %-8s  %-1s  %-7s  %-3s  %-5s  %s\n" "$attachment_indicator" "$session_display" "$win_index" "$window_display" "$pane_index" "$cmd" "$width_display" "$pid" "$path"
  else
    printf "%-1s %-13s %-3s  %-8s  %-1s  %-7s  %-3s\n" "$attachment_indicator" "$session_display" "$win_index" "$window_display" "$pane_index" "$cmd" "$width_display"
  fi

  last_session="$session"
  last_window="$current_window"
done