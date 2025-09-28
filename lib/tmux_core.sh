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
# Default format: "#{client_session} #{client_width}"
get_client_data() {
  local format="${1:-#{client_session} #{client_width}}"
  tmux list-clients -F "$format" 2>/dev/null || return 1
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

# Get current client width
get_current_client_width() {
  tmux display-message -p '#{client_width}' 2>/dev/null || echo ""
}

# Get client width for a specific session
# Args: session_name client_data
get_session_width() {
  local session_name="$1"
  local client_data="$2"
  local current_session

  current_session=$(get_current_session)

  if [[ "$session_name" = "$current_session" ]]; then
    get_current_client_width
  else
    echo "$client_data" | grep "^$session_name " | head -1 | cut -d' ' -f2 || echo "-"
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