#!/bin/bash

#=============================================================================
# tmux_display.sh - Display formatting utilities
#=============================================================================
#
# PURPOSE:
#   Shared functions for formatting tmux session, window, and pane information
#   for consistent display across multiple tools.
#
# USAGE:
#   source lib/tmux_display.sh
#
#=============================================================================

# Print formatted table row for tmux-status display
# Args: attachment_indicator session_display win_index window_display pane_index cmd width_display [pid] [path]
print_status_row() {
  local attachment_indicator="$1"
  local session_display="$2"
  local win_index="$3"
  local window_display="$4"
  local pane_index="$5"
  local cmd="$6"
  local width_display="$7"
  local pid="$8"
  local path="$9"

  if [[ -n "$pid" && -n "$path" ]]; then
    # Detailed output with PID and path
    printf "%-1s %-13s %-3s  %-8s  %-1s  %-7s  %-3s  %-5s  %s\n" \
      "$attachment_indicator" "$session_display" "$win_index" "$window_display" \
      "$pane_index" "$cmd" "$width_display" "$pid" "$path"
  else
    # Compact output
    printf "%-1s %-13s %-3s  %-8s  %-1s  %-7s  %-3s\n" \
      "$attachment_indicator" "$session_display" "$win_index" "$window_display" \
      "$pane_index" "$cmd" "$width_display"
  fi
}

# Print header for tmux-status display
# Args: show_pid
print_status_header() {
  local show_pid="$1"

  echo "TMUX STATUS $(date)"
  echo

  if [[ "$show_pid" = true ]]; then
    echo "  session       win  name      p  cmd      w    pid    path"
    echo "- -------       ---  --------  -  -------  ---  -----  ----"
  else
    echo "  session       win  name      p  cmd      w"
    echo "- -------       ---  --------  -  -------  ---"
  fi
}

# Format session display name (empty if repeat)
# Args: session_name last_session
format_session_display() {
  local session_name="$1"
  local last_session="$2"

  if [[ "$session_name" == "$last_session" ]]; then
    echo ""
  else
    echo "$session_name"
  fi
}

# Format window display name (empty if repeat)
# Args: session_name win_index last_window
format_window_display() {
  local session_name="$1"
  local win_index="$2"
  local win_name="$3"
  local last_window="$4"

  local current_window="${session_name}:${win_index}"
  if [[ "$current_window" == "$last_window" ]]; then
    echo ""
  else
    echo "$win_name"
  fi
}

# Format width display (only for new sessions)
# Args: session_name last_session width
format_width_display() {
  local session_name="$1"
  local last_session="$2"
  local width="$3"

  if [[ "$session_name" != "$last_session" ]]; then
    echo "${width:-"-"}"
  else
    echo ""
  fi
}

# Format attachment indicator (only for new sessions)
# Args: session_name last_session session_attached
format_attachment_display() {
  local session_name="$1"
  local last_session="$2"
  local session_attached="$3"

  if [[ "$session_name" != "$last_session" ]]; then
    case $session_attached in
      0) echo " " ;;
      1) echo "•" ;;
      *) echo "$session_attached" ;;
    esac
  else
    echo ""
  fi
}

# Check if session separator is needed
# Args: session_name last_session first_session
needs_session_separator() {
  local session_name="$1"
  local last_session="$2"
  local first_session="$3"

  if [[ "$first_session" = false && "$session_name" != "$last_session" ]]; then
    return 0  # true
  else
    return 1  # false
  fi
}

# Print overview row with background coloring
# Args: bg_color attachment_indicator session_display window_indicator window_display pane_display
print_overview_row() {
  local bg_color="$1"
  local attachment_indicator="$2"
  local session_display="$3"
  local window_indicator="$4"
  local window_display="$5"
  local pane_display="$6"
  local NC="$7"

  if [[ -n "$session_display" ]]; then
    # First window of session
    echo -e "${bg_color}${attachment_indicator} $(printf "%-11s" "$session_display") ${window_indicator} $(printf "%-11s" "$window_display")$(printf "%-2s" "$pane_display")${NC}"
  else
    # Additional windows in session
    echo -e "${bg_color}$(printf "%-13s" "") ${window_indicator} $(printf "%-11s" "$window_display")$(printf "%-2s" "$pane_display")${NC}"
  fi
}

# Print detailed overview row
# Args: bg_color attachment_indicator session_display window_indicator window_display command path first_window first_pane
print_detailed_overview_row() {
  local bg_color="$1"
  local attachment_indicator="$2"
  local session_display="$3"
  local window_indicator="$4"
  local window_display="$5"
  local command="$6"
  local path="$7"
  local first_window="$8"
  local first_pane="$9"
  local NC="${10}"

  if [[ "$first_window" = true && "$first_pane" = true ]]; then
    # First pane of first window in session
    echo -e "${bg_color}${attachment_indicator} $(printf "%-11s" "$session_display") ${window_indicator} $(printf "%-11s" "$window_display") $(printf "%-12s" "$command") ${path}${NC}"
  elif [[ "$first_pane" = true ]]; then
    # First pane of non-first window
    echo -e "${bg_color}$(printf "%-13s" "") ${window_indicator} $(printf "%-11s" "$window_display") $(printf "%-12s" "$command") ${path}${NC}"
  else
    # Additional panes
    echo -e "${bg_color}$(printf "%-13s" "") $(printf "%-13s" "") $(printf "%-12s" "$command") ${path}${NC}"
  fi
}

# Get window status indicator
# Args: win_active
get_window_indicator() {
  local win_active="$1"
  if [[ "$win_active" == "1" ]]; then
    echo "•"
  else
    echo " "
  fi
}

# Get session status indicator
# Args: session_attached
get_session_indicator() {
  local session_attached="$1"
  if [[ "$session_attached" == "1" ]]; then
    echo "●"
  elif [[ "$session_attached" -gt "1" ]]; then
    echo "$session_attached"
  else
    echo "○"
  fi
}

# Format pane count display
# Args: win_panes
format_pane_display() {
  local win_panes="$1"
  if [[ "$win_panes" -gt 1 ]]; then
    echo " $win_panes"
  else
    echo ""
  fi
}

# Get alternating background color
# Args: session_count bg_subtle
get_background_color() {
  local session_count="$1"
  local bg_subtle="$2"

  if [[ $((session_count % 2)) -eq 1 ]]; then
    echo "$bg_subtle"
  else
    echo ""
  fi
}