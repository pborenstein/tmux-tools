#!/bin/bash

#=============================================================================
# tmux_core.sh - Core tmux operations and utilities
#=============================================================================
#
# PURPOSE:
#   Shared functions for tmux server validation, session/window/pane data
#   retrieval, and common tmux operations used across multiple tools.
#
# USAGE:
#   source lib/tmux_core.sh
#
#=============================================================================

# Check if tmux is available and accessible
check_tmux_available() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed or not in PATH" >&2
    return 1
  fi
  return 0
}

# Check if tmux server is running
check_tmux_running() {
  if ! tmux list-sessions >/dev/null 2>&1; then
    echo "No tmux sessions found (tmux server may not be running)" >&2
    return 1
  fi
  return 0
}

# Get all session data with specified format
# Default format: "#{session_name}|#{session_created}|#{session_attached}|#{session_windows}"
get_session_data() {
  local format="${1:-}"
  if [[ -z "$format" ]]; then
    format="#{session_name}|#{session_created}|#{session_attached}|#{session_windows}"
  fi
  tmux list-sessions -F "$format" 2>/dev/null || return 1
}

# Get window data for all sessions or specific session
# Args: [session_name] [format]
get_window_data() {
  local session_name="${1:-}"
  local format="${2:-}"
  if [[ -z "$format" ]]; then
    format="#{session_name}|#{window_index}|#{window_name}|#{window_panes}|#{window_active}"
  fi

  if [[ -n "$session_name" ]]; then
    tmux list-windows -t "$session_name" -F "$format" 2>/dev/null || return 1
  else
    tmux list-windows -a -F "$format" 2>/dev/null || return 1
  fi
}

# Get pane data for all sessions or specific session
# Args: [session_name] [format]
get_pane_data() {
  local session_name="${1:-}"
  local format="${2:-}"
  if [[ -z "$format" ]]; then
    format="#{session_name}|#{window_index}|#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{pane_active}"
  fi

  local pane_data
  pane_data=$(tmux list-panes -a -F "$format" 2>/dev/null || return 1)

  if [[ -n "$session_name" ]]; then
    echo "$pane_data" | grep "^$session_name|" || true
  else
    echo "$pane_data"
  fi
}

# Get client data
# Default format: "#{client_session} #{client_width} #{client_height}"
get_client_data() {
  local format="${1:-#{client_session} #{client_width} #{client_height}}"
  tmux list-clients -F "$format" 2>/dev/null || return 1
}

# Get control mode status for a session
# Returns "1" if session has any control mode clients, "0" otherwise
# Args: session_name
get_session_control_mode() {
  local session_name="$1"
  local control_mode_clients

  # Get all clients for this session and check for control mode
  control_mode_clients=$(tmux list-clients -F "#{client_session} #{client_control_mode} #{client_width}x#{client_height}" 2>/dev/null | \
    grep "^$session_name " | \
    awk '{if ($2 == "1" || $3 == "0x0") print "1"}')

  if [[ -n "$control_mode_clients" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

# Get detailed client data
# Returns: tty|pid|session|termname|created|activity|width|height|user|control_mode
get_detailed_client_data() {
  tmux list-clients -F "#{client_tty}|#{client_pid}|#{client_session}|#{client_termname}|#{client_created}|#{client_activity}|#{client_width}|#{client_height}|#{client_user}|#{client_control_mode}" 2>/dev/null || return 1
}

# Format timestamp to HH:MM
# Args: timestamp
format_time_hhmm() {
  local timestamp="$1"
  if command -v gdate >/dev/null 2>&1; then
    gdate -d "@$timestamp" "+%H:%M" 2>/dev/null || echo "??:??"
  else
    date -r "$timestamp" "+%H:%M" 2>/dev/null || echo "??:??"
  fi
}

# Get attachment indicator for a session
# Args: session_name
get_attachment_indicator() {
  local session_name="$1"
  local session_attached

  session_attached=$(tmux list-sessions -F "#{session_name} #{session_attached}" | grep "^$session_name " | cut -d' ' -f2)

  case $session_attached in
    0) echo " " ;;
    1) echo "•" ;;
    *) echo "$session_attached" ;;
  esac
}

# Get current session name if we're inside tmux
get_current_session() {
  tmux display-message -p '#{session_name}' 2>/dev/null || echo ""
}

# Get current client dimensions (WxH format)
get_current_client_size() {
  local width height
  width=$(tmux display-message -p '#{client_width}' 2>/dev/null || echo "")
  height=$(tmux display-message -p '#{client_height}' 2>/dev/null || echo "")
  if [[ -n "$width" && -n "$height" ]]; then
    echo "${width}x${height}"
  else
    echo ""
  fi
}

# Get client dimensions for a specific session (WxH format)
# Args: session_name client_data
get_session_size() {
  local session_name="$1"
  local client_data="$2"
  local current_session

  current_session=$(get_current_session)

  if [[ "$session_name" = "$current_session" ]]; then
    get_current_client_size
  else
    local width height
    width=$(echo "$client_data" | grep "^$session_name " | head -1 | awk '{print $2}')
    height=$(echo "$client_data" | grep "^$session_name " | head -1 | awk '{print $3}')
    if [[ -n "$width" && -n "$height" ]]; then
      echo "${width}x${height}"
    else
      echo "-"
    fi
  fi
}

# Validate session exists
# Args: session_name
session_exists() {
  local session_name="$1"
  tmux has-session -t "$session_name" 2>/dev/null
}

# Validate window exists in session
# Args: session_name window_index
window_exists() {
  local session_name="$1"
  local window_index="$2"
  tmux list-windows -t "$session_name" -F "#{window_index}" 2>/dev/null | grep -q "^${window_index}$"
}

# Rename session if it exists
# Args: old_name new_name
rename_session() {
  local old_name="$1"
  local new_name="$2"

  if session_exists "$old_name"; then
    tmux rename-session -t "$old_name" "$new_name" 2>/dev/null
  else
    return 1
  fi
}

# Rename window if it exists
# Args: session_name window_index new_name
rename_window() {
  local session_name="$1"
  local window_index="$2"
  local new_name="$3"

  if window_exists "$session_name" "$window_index"; then
    tmux rename-window -t "${session_name}:${window_index}" "$new_name" 2>/dev/null
  else
    return 1
  fi
}

# Format timestamp
# Args: timestamp
format_timestamp() {
  local timestamp="$1"
  if command -v gdate >/dev/null 2>&1; then
    gdate -d "@$timestamp" "+%Y-%m-%d %H:%M:%S"
  else
    date -r "$timestamp" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Unknown"
  fi
}

# Format elapsed time compactly
# Args: timestamp
format_elapsed_time() {
  local timestamp="$1"
  local now=$(date +%s)
  local elapsed=$((now - timestamp))

  if [[ $elapsed -lt 60 ]]; then
    echo "${elapsed}s"
  elif [[ $elapsed -lt 3600 ]]; then
    echo "$((elapsed / 60))m"
  elif [[ $elapsed -lt 86400 ]]; then
    echo "$((elapsed / 3600))h"
  else
    echo "$((elapsed / 86400))d"
  fi
}

# Get the active pane's directory for a window
# Args: session_name window_index
get_window_active_pane_dir() {
  local session_name="$1"
  local window_index="$2"

  # Get the current path of the active pane in the window
  local pane_path
  pane_path=$(tmux list-panes -t "${session_name}:${window_index}" \
    -F "#{pane_active} #{pane_current_path}" 2>/dev/null | \
    grep "^1 " | cut -d' ' -f2-)

  echo "$pane_path"
}

# Extract and format directory name for window naming
# Args: directory_path [max_length]
format_directory_name() {
  local dir_path="$1"
  local max_length="${2:-20}"

  # Return empty if no path provided
  if [[ -z "$dir_path" ]]; then
    echo ""
    return
  fi

  # Get the basename of the directory
  local dir_name
  dir_name=$(basename "$dir_path")

  # Handle home directory specially
  if [[ "$dir_path" == "$HOME" ]]; then
    dir_name="home"
  fi

  # Truncate if longer than max_length
  if [[ ${#dir_name} -gt $max_length ]]; then
    dir_name="${dir_name:0:$max_length}"
  fi

  echo "$dir_name"
}

# Get a smart name for a window based on its active pane's directory
# Args: session_name window_index
get_smart_window_name() {
  local session_name="$1"
  local window_index="$2"

  local pane_dir
  pane_dir=$(get_window_active_pane_dir "$session_name" "$window_index")

  local window_name
  window_name=$(format_directory_name "$pane_dir" 20)

  # If we couldn't get a directory name, return empty (caller will handle fallback)
  echo "$window_name"
}