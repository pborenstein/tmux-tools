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

# Pad a colored string to a specific width
# Args: string width color reset_color
# Returns: padded colored string
pad_colored() {
  local string="$1"
  local width="$2"
  local color="$3"
  local reset_color="$4"

  if [[ -z "$color" ]]; then
    # No color, use regular printf
    printf "%-${width}s" "$string"
  else
    # Calculate padding needed (width - visible string length)
    local visible_len=${#string}
    local padding=$((width - visible_len))

    # Build padded colored string (use %b to interpret escape sequences)
    if [[ $padding -gt 0 ]]; then
      printf "%b%s%b%*s" "$color" "$string" "$reset_color" "$padding" ""
    else
      printf "%b%s%b" "$color" "$string" "$reset_color"
    fi
  fi
}

# Print formatted table row for tmux-status display
# Args: attachment_indicator session_display win_index window_display pane_index cmd width_display control_mode_display [pid] [path]
print_status_row() {
  local attachment_indicator="$1"
  local session_display="$2"
  local win_index="$3"
  local window_display="$4"
  local pane_index="$5"
  local cmd="$6"
  local width_display="$7"
  local control_mode_display="$8"
  local pid="$9"
  local path="${10}"

  # Determine colors
  local active_color=""
  local session_color=""
  local highlight_color=""
  local info_color=""
  local gray_color=""
  local reset_color=""

  if colors_supported; then
    active_color=$(get_color "active")
    session_color=$(get_color "session")
    highlight_color=$(get_color "highlight")
    info_color=$(get_color "info")
    gray_color=$(get_color "gray")
    reset_color=$(get_color "reset")
  fi

  # Build formatted row with proper padding for colored fields
  local formatted_row=""

  # Attachment indicator (1 char)
  if [[ -n "$attachment_indicator" && "$attachment_indicator" != " " ]]; then
    formatted_row+=$(pad_colored "$attachment_indicator" 1 "$active_color" "$reset_color")
  else
    formatted_row+=$(printf "%-1s" "$attachment_indicator")
  fi
  formatted_row+=" "

  # Session display (13 chars)
  if [[ -n "$session_display" ]]; then
    formatted_row+=$(pad_colored "$session_display" 13 "$session_color" "$reset_color")
  else
    formatted_row+=$(printf "%-13s" "")
  fi
  formatted_row+=" "

  # Window index (3 chars)
  formatted_row+=$(printf "%-3s" "$win_index")
  formatted_row+="  "

  # Window display (20 chars)
  if [[ -n "$window_display" ]]; then
    formatted_row+=$(pad_colored "$window_display" 20 "$highlight_color" "$reset_color")
  else
    formatted_row+=$(printf "%-20s" "")
  fi
  formatted_row+="  "

  # Pane index (1 char)
  formatted_row+=$(printf "%-1s" "$pane_index")
  formatted_row+="  "

  # Command (7 chars)
  formatted_row+=$(pad_colored "$cmd" 7 "$info_color" "$reset_color")
  formatted_row+="  "

  # Width display (3 chars)
  formatted_row+=$(printf "%-3s" "$width_display")
  formatted_row+="  "

  # Control mode display (1 char)
  formatted_row+=$(printf "%-1s" "$control_mode_display")

  # Optional PID and path
  if [[ -n "$pid" && -n "$path" ]]; then
    formatted_row+="  "
    formatted_row+=$(printf "%-5s" "$pid")
    formatted_row+="  "
    if [[ -n "$gray_color" ]]; then
      # Use printf %b to interpret escape sequences
      formatted_row+=$(printf "%b%s%b" "$gray_color" "$path" "$reset_color")
    else
      formatted_row+="$path"
    fi
  fi

  printf "%b\n" "$formatted_row"
}

# Print header for tmux-status display
# Args: show_pid
print_status_header() {
  local show_pid="$1"

  echo "TMUX STATUS $(date)"
  echo

  if [[ "$show_pid" = true ]]; then
    echo "  session       win  name                  p  cmd      w    c  pid    path"
    echo "- -------       ---  --------------------  -  -------  ---  -  -----  ----"
  else
    echo "  session       win  name                  p  cmd      w    c"
    echo "- -------       ---  --------------------  -  -------  ---  -"
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

# Format control mode display (only for new sessions)
# Args: session_name last_session control_mode
format_control_mode_display() {
  local session_name="$1"
  local last_session="$2"
  local control_mode="$3"

  if [[ "$session_name" != "$last_session" ]]; then
    if [[ "$control_mode" == "1" ]]; then
      echo "+"
    else
      echo ""
    fi
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
# Args: bg_color attachment_indicator session_display control_mode_indicator window_indicator window_display pane_display
print_overview_row() {
  local bg_color="$1"
  local attachment_indicator="$2"
  local session_display="$3"
  local control_mode_indicator="$4"
  local window_indicator="$5"
  local window_display="$6"
  local pane_display="$7"
  local NC="$8"

  if [[ -n "$session_display" ]]; then
    # First window of session
    local session_with_control
    if [[ -n "$control_mode_indicator" ]]; then
      session_with_control=$(printf "%-10s%s" "$session_display" "$control_mode_indicator")
    else
      session_with_control=$(printf "%-11s" "$session_display")
    fi
    echo -e "${bg_color}${attachment_indicator} ${session_with_control} ${window_indicator} $(printf "%-11s" "$window_display")$(printf "%-2s" "$pane_display")${NC}"
  else
    # Additional windows in session
    echo -e "${bg_color}$(printf "%-13s" "") ${window_indicator} $(printf "%-11s" "$window_display")$(printf "%-2s" "$pane_display")${NC}"
  fi
}

# Print detailed overview row
# Args: bg_color attachment_indicator session_display control_mode_indicator window_indicator window_display command path first_window first_pane
print_detailed_overview_row() {
  local bg_color="$1"
  local attachment_indicator="$2"
  local session_display="$3"
  local control_mode_indicator="$4"
  local window_indicator="$5"
  local window_display="$6"
  local command="$7"
  local path="$8"
  local first_window="$9"
  local first_pane="${10}"
  local NC="${11}"

  if [[ "$first_window" = true && "$first_pane" = true ]]; then
    # First pane of first window in session
    local session_with_control
    if [[ -n "$control_mode_indicator" ]]; then
      session_with_control=$(printf "%-10s%s" "$session_display" "$control_mode_indicator")
    else
      session_with_control=$(printf "%-11s" "$session_display")
    fi
    echo -e "${bg_color}${attachment_indicator} ${session_with_control} ${window_indicator} $(printf "%-11s" "$window_display") $(printf "%-12s" "$command") ${path}${NC}"
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

# Print client info header
print_client_header() {
  echo "TMUX CLIENTS $(date)"
  echo
  echo "session       tty            created  activity  size      ctrl  user"
  echo "-------       -----------    -------  --------  --------  ----  ----"
}

# Print client info row
# Args: session tty created activity width height control_mode user
print_client_row() {
  local session="$1"
  local tty="$2"
  local created="$3"
  local activity="$4"
  local width="$5"
  local height="$6"
  local control_mode="$7"
  local user="$8"

  # Format TTY (strip /dev/ prefix and truncate)
  local tty_short="${tty#/dev/}"
  tty_short=$(printf "%-13s" "$tty_short")

  # Format dimensions
  local size=$(printf "%4sx%-4s" "$width" "$height")

  # Format control mode indicator
  local ctrl_indicator=""
  if [[ "$control_mode" == "1" ]] || [[ "$width" == "0" ]]; then
    ctrl_indicator="+"
  fi

  # Determine colors
  local session_color=""
  local info_color=""
  local gray_color=""
  local reset_color=""

  if colors_supported; then
    session_color=$(get_color "session")
    info_color=$(get_color "info")
    gray_color=$(get_color "gray")
    reset_color=$(get_color "reset")
  fi

  # Build formatted row
  local formatted_row=""

  # Session (13 chars)
  if [[ -n "$session_color" ]]; then
    formatted_row+=$(pad_colored "$session" 13 "$session_color" "$reset_color")
  else
    formatted_row+=$(printf "%-13s" "$session")
  fi
  formatted_row+=" "

  # TTY (13 chars)
  formatted_row+="$tty_short  "

  # Created time (7 chars)
  if [[ -n "$gray_color" ]]; then
    formatted_row+=$(printf "%b%-7s%b" "$gray_color" "$created" "$reset_color")
  else
    formatted_row+=$(printf "%-7s" "$created")
  fi
  formatted_row+="  "

  # Activity time (8 chars)
  if [[ -n "$info_color" ]]; then
    formatted_row+=$(pad_colored "$activity" 8 "$info_color" "$reset_color")
  else
    formatted_row+=$(printf "%-8s" "$activity")
  fi
  formatted_row+="  "

  # Size (9 chars)
  formatted_row+=$(printf "%-9s" "$size")
  formatted_row+=" "

  # Control mode (4 chars)
  formatted_row+=$(printf "%-4s" "$ctrl_indicator")
  formatted_row+="  "

  # User
  formatted_row+="$user"

  printf "%b\n" "$formatted_row"
}