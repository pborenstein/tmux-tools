#!/bin/bash

#=============================================================================
# tmux_colors.sh - Color management and theming
#=============================================================================
#
# PURPOSE:
#   Shared color definitions and theming functions for consistent color
#   usage across multiple tmux tools.
#
# USAGE:
#   source lib/tmux_colors.sh
#   init_colors [theme_name]
#
#=============================================================================

# Color constants
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[0;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_GRAY='\033[0;90m'
readonly COLOR_BG_SUBTLE='\033[48;5;237m'
readonly COLOR_NC='\033[0m' # No Color

# Bright color variants
readonly COLOR_BRIGHT_RED='\033[1;31m'
readonly COLOR_BRIGHT_GREEN='\033[1;32m'
readonly COLOR_BRIGHT_YELLOW='\033[1;33m'
readonly COLOR_BRIGHT_BLUE='\033[1;34m'
readonly COLOR_BRIGHT_PURPLE='\033[1;35m'
readonly COLOR_BRIGHT_CYAN='\033[1;36m'

# Theme variables (will be set by init_colors)
SESSION_COLOR=""
ACTIVE_COLOR=""
ERROR_COLOR=""
WARNING_COLOR=""
INFO_COLOR=""
HIGHLIGHT_COLOR=""
BACKGROUND_COLOR=""
RESET_COLOR=""

# Initialize colors based on theme
# Args: [theme_name]
init_colors() {
  local theme="${1:-default}"

  case "$theme" in
    "vibrant")
      SESSION_COLOR="$COLOR_BRIGHT_CYAN"
      ACTIVE_COLOR="$COLOR_BRIGHT_GREEN"
      ERROR_COLOR="$COLOR_BRIGHT_RED"
      WARNING_COLOR="$COLOR_BRIGHT_YELLOW"
      INFO_COLOR="$COLOR_BRIGHT_BLUE"
      HIGHLIGHT_COLOR="$COLOR_BRIGHT_PURPLE"
      BACKGROUND_COLOR="$COLOR_BG_SUBTLE"
      ;;
    "subtle")
      SESSION_COLOR="$COLOR_CYAN"
      ACTIVE_COLOR="$COLOR_GREEN"
      ERROR_COLOR="$COLOR_RED"
      WARNING_COLOR="$COLOR_YELLOW"
      INFO_COLOR="$COLOR_BLUE"
      HIGHLIGHT_COLOR="$COLOR_PURPLE"
      BACKGROUND_COLOR="$COLOR_BG_SUBTLE"
      ;;
    "monochrome")
      SESSION_COLOR="$COLOR_WHITE"
      ACTIVE_COLOR="$COLOR_WHITE"
      ERROR_COLOR="$COLOR_WHITE"
      WARNING_COLOR="$COLOR_WHITE"
      INFO_COLOR="$COLOR_WHITE"
      HIGHLIGHT_COLOR="$COLOR_WHITE"
      BACKGROUND_COLOR=""
      ;;
    "none"|"off"|"disabled")
      SESSION_COLOR=""
      ACTIVE_COLOR=""
      ERROR_COLOR=""
      WARNING_COLOR=""
      INFO_COLOR=""
      HIGHLIGHT_COLOR=""
      BACKGROUND_COLOR=""
      ;;
    *)  # default theme
      SESSION_COLOR="$COLOR_CYAN"
      ACTIVE_COLOR="$COLOR_GREEN"
      ERROR_COLOR="$COLOR_RED"
      WARNING_COLOR="$COLOR_YELLOW"
      INFO_COLOR="$COLOR_BLUE"
      HIGHLIGHT_COLOR="$COLOR_PURPLE"
      BACKGROUND_COLOR=""
      ;;
  esac

  RESET_COLOR="$COLOR_NC"
}

# Check if colors are supported
colors_supported() {
  # Check if we're in a terminal that supports colors
  if [[ -t 1 ]] && [[ "${TERM:-}" != "dumb" ]]; then
    # Check if NO_COLOR environment variable is set
    if [[ -z "${NO_COLOR:-}" ]]; then
      return 0  # true
    fi
  fi
  return 1  # false
}

# Colorize text with specified color
# Args: color text
colorize() {
  local color="$1"
  local text="$2"

  if colors_supported; then
    echo -e "${color}${text}${RESET_COLOR}"
  else
    echo "$text"
  fi
}

# Convenience functions for common colors
colorize_session() {
  colorize "$SESSION_COLOR" "$1"
}

colorize_active() {
  colorize "$ACTIVE_COLOR" "$1"
}

colorize_error() {
  colorize "$ERROR_COLOR" "$1"
}

colorize_warning() {
  colorize "$WARNING_COLOR" "$1"
}

colorize_info() {
  colorize "$INFO_COLOR" "$1"
}

colorize_highlight() {
  colorize "$HIGHLIGHT_COLOR" "$1"
}

# Get the raw color code for use in printf/echo -e
# Args: color_name
get_color() {
  local color_name="$1"

  case "$color_name" in
    "session") echo "$SESSION_COLOR" ;;
    "active") echo "$ACTIVE_COLOR" ;;
    "error") echo "$ERROR_COLOR" ;;
    "warning") echo "$WARNING_COLOR" ;;
    "info") echo "$INFO_COLOR" ;;
    "highlight") echo "$HIGHLIGHT_COLOR" ;;
    "background") echo "$BACKGROUND_COLOR" ;;
    "reset"|"nc") echo "$RESET_COLOR" ;;
    "red") echo "$COLOR_RED" ;;
    "green") echo "$COLOR_GREEN" ;;
    "yellow") echo "$COLOR_YELLOW" ;;
    "blue") echo "$COLOR_BLUE" ;;
    "purple") echo "$COLOR_PURPLE" ;;
    "cyan") echo "$COLOR_CYAN" ;;
    "white") echo "$COLOR_WHITE" ;;
    "gray") echo "$COLOR_GRAY" ;;
    *) echo "" ;;
  esac
}

# Auto-detect theme from environment
# Checks TMUX_TOOLS_THEME, TMUX_TOOLS_COLOR, or falls back to default
detect_theme() {
  local theme="${TMUX_TOOLS_THEME:-}"

  if [[ -z "$theme" ]]; then
    theme="${TMUX_TOOLS_COLOR:-}"
  fi

  if [[ -z "$theme" ]]; then
    if colors_supported; then
      theme="default"
    else
      theme="none"
    fi
  fi

  echo "$theme"
}

# Initialize with auto-detected theme if not already initialized
auto_init_colors() {
  if [[ -z "$SESSION_COLOR$ACTIVE_COLOR$ERROR_COLOR" ]]; then
    local theme
    theme=$(detect_theme)
    init_colors "$theme"
  fi
}

# Colorize markdown content for help display
# Colors H1 headings, H2 headings, and table headers
# Reads from stdin, outputs to stdout
colorize_markdown() {
  local in_table=0
  local line
  local prev_line=""

  while IFS= read -r line; do
    # H1 heading (# Title)
    if [[ "$line" =~ ^#[[:space:]] ]]; then
      if colors_supported; then
        echo -e "${HIGHLIGHT_COLOR}${line}${RESET_COLOR}"
      else
        echo "$line"
      fi
    # H2 heading (## Section)
    elif [[ "$line" =~ ^##[[:space:]] ]]; then
      in_table=1  # Next table row will be a header
      if colors_supported; then
        echo -e "${INFO_COLOR}${line}${RESET_COLOR}"
      else
        echo "$line"
      fi
    # Table header row (first row with | after H2)
    elif [[ $in_table -eq 1 ]] && [[ "$line" =~ ^\|.*\| ]]; then
      if colors_supported; then
        # Color the entire header row
        echo -e "${ACTIVE_COLOR}${line}${RESET_COLOR}"
      else
        echo "$line"
      fi
      in_table=2  # Mark that we've seen the header
    # Table separator row (|:---|:---|)
    elif [[ $in_table -eq 2 ]] && [[ "$line" =~ ^\|[[:space:]]*:?-+:? ]]; then
      if colors_supported; then
        echo -e "${ACTIVE_COLOR}${line}${RESET_COLOR}"
      else
        echo "$line"
      fi
      in_table=0  # Reset after separator
    # Regular lines
    else
      # Reset table tracking on blank lines (unless we just saw H2)
      if [[ -z "$line" ]] && [[ $in_table -ne 1 ]]; then
        in_table=0
      fi
      echo "$line"
    fi

    prev_line="$line"
  done
}