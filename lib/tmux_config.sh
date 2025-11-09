#!/bin/bash

#=============================================================================
# tmux_config.sh - Configuration handling and management
#=============================================================================
#
# PURPOSE:
#   Shared functions for loading and managing configuration files,
#   including YAML/TOML parsing and default value handling.
#
# USAGE:
#   source lib/tmux_config.sh
#   load_config [config_file]
#
#=============================================================================

# Default configuration file locations (in order of preference)
readonly DEFAULT_CONFIG_LOCATIONS=(
  "$HOME/.tmux-tools.yaml"
  "$HOME/.tmux-tools.yml"
  "$HOME/.config/tmux-tools/config.yaml"
  "$HOME/.config/tmux-tools/config.yml"
  "./tmux-tools.yaml"
  "./tmux-tools.yml"
)

# Configuration variables (set defaults)
TMUX_TOOLS_THEME="${TMUX_TOOLS_THEME:-default}"
TMUX_TOOLS_SESSION_POOL="${TMUX_TOOLS_SESSION_POOL:-cities}"
TMUX_TOOLS_ATTACHMENT_INDICATOR="${TMUX_TOOLS_ATTACHMENT_INDICATOR:-•}"
TMUX_TOOLS_DEFAULT_FORMAT="${TMUX_TOOLS_DEFAULT_FORMAT:-compact}"
TMUX_TOOLS_SHOW_TIMESTAMPS="${TMUX_TOOLS_SHOW_TIMESTAMPS:-true}"
TMUX_TOOLS_GROUP_SESSIONS="${TMUX_TOOLS_GROUP_SESSIONS:-true}"

# Name pools
declare -a CITY_NAMES=(
  "rio" "oslo" "lima" "bern"
  "cairo" "tokyo" "paris"
  "milan" "berlin" "sydney"
  "boston" "madrid"
)

# Custom name pools (can be overridden by config)
declare -a CUSTOM_SESSION_NAMES=()

# Find the first existing configuration file
find_config_file() {
  local config_file=""

  for location in "${DEFAULT_CONFIG_LOCATIONS[@]}"; do
    if [[ -f "$location" ]]; then
      config_file="$location"
      break
    fi
  done

  echo "$config_file"
}

# Simple YAML parser for basic key-value pairs
# Args: yaml_file key [default_value]
parse_yaml_value() {
  local yaml_file="$1"
  local key="$2"
  local default_value="$3"
  local value

  if [[ ! -f "$yaml_file" ]]; then
    echo "$default_value"
    return
  fi

  # Simple regex-based YAML parsing for basic values
  # Handles: key: value, key:"value", key: "value", and strips comments
  value=$(grep -E "^[[:space:]]*${key}[[:space:]]*:" "$yaml_file" | head -1 | sed -E 's/^[[:space:]]*[^:]+:[[:space:]]*//; s/[[:space:]]*#.*$//; s/^["'"'"']//; s/["'"'"']$//')

  if [[ -n "$value" ]]; then
    echo "$value"
  else
    echo "$default_value"
  fi
}

# Parse YAML array values (simple implementation)
# Args: yaml_file section key
parse_yaml_array() {
  local yaml_file="$1"
  local section="$2"
  local key="$3"
  local in_section=false
  local in_array=false
  local array_values=()

  if [[ ! -f "$yaml_file" ]]; then
    return
  fi

  while IFS= read -r line; do
    # Remove leading whitespace
    local trimmed_line="${line#"${line%%[![:space:]]*}"}"

    # Check if we're entering the section
    if [[ "$trimmed_line" =~ ^${section}: ]]; then
      in_section=true
      continue
    fi

    # Check if we're leaving the section (new top-level key)
    if [[ "$in_section" = true && "$trimmed_line" =~ ^[a-zA-Z] ]]; then
      break
    fi

    # Check if we're in the section and found our key
    if [[ "$in_section" = true && "$trimmed_line" =~ ^${key}: ]]; then
      in_array=true
      continue
    fi

    # If we're in the array, parse values
    if [[ "$in_array" = true ]]; then
      if [[ "$trimmed_line" =~ ^- ]]; then
        # Array item: - value or - "value"
        local value="${trimmed_line#- }"
        value="${value#\"}"
        value="${value%\"}"
        array_values+=("$value")
      elif [[ "$trimmed_line" =~ ^[a-zA-Z] ]]; then
        # New key, exit array
        break
      fi
    fi
  done < "$yaml_file"

  if [[ ${#array_values[@]} -gt 0 ]]; then
    printf '%s\n' "${array_values[@]}"
  fi
}

# Load configuration from file
# Args: [config_file]
load_config() {
  local config_file="${1:-}"

  if [[ -z "$config_file" ]]; then
    config_file=$(find_config_file)
  fi

  if [[ -z "$config_file" || ! -f "$config_file" ]]; then
    # No config file found, use defaults
    return 0
  fi

  # Load display settings
  TMUX_TOOLS_THEME=$(parse_yaml_value "$config_file" "theme" "$TMUX_TOOLS_THEME")
  TMUX_TOOLS_ATTACHMENT_INDICATOR=$(parse_yaml_value "$config_file" "attachment_indicator" "$TMUX_TOOLS_ATTACHMENT_INDICATOR")
  TMUX_TOOLS_DEFAULT_FORMAT=$(parse_yaml_value "$config_file" "default_format" "$TMUX_TOOLS_DEFAULT_FORMAT")
  TMUX_TOOLS_SHOW_TIMESTAMPS=$(parse_yaml_value "$config_file" "show_timestamps" "$TMUX_TOOLS_SHOW_TIMESTAMPS")
  TMUX_TOOLS_GROUP_SESSIONS=$(parse_yaml_value "$config_file" "group_sessions" "$TMUX_TOOLS_GROUP_SESSIONS")

  # Load naming settings
  TMUX_TOOLS_SESSION_POOL=$(parse_yaml_value "$config_file" "session_pool" "$TMUX_TOOLS_SESSION_POOL")

  # Load custom name arrays
  local custom_sessions
  custom_sessions=$(parse_yaml_array "$config_file" "naming" "custom_sessions")
  if [[ -n "$custom_sessions" ]]; then
    readarray -t CUSTOM_SESSION_NAMES <<< "$custom_sessions"
  fi

  return 0
}

# Get session names based on configuration
get_session_names() {
  case "$TMUX_TOOLS_SESSION_POOL" in
    "custom")
      if [[ ${#CUSTOM_SESSION_NAMES[@]} -gt 0 ]]; then
        printf '%s\n' "${CUSTOM_SESSION_NAMES[@]}"
      else
        printf '%s\n' "${CITY_NAMES[@]}"
      fi
      ;;
    *)  # "cities" or any other value defaults to cities
      printf '%s\n' "${CITY_NAMES[@]}"
      ;;
  esac
}

# Create example configuration file
# Args: output_file
create_example_config() {
  local output_file="$1"

  cat > "$output_file" << 'EOF'
# tmux-tools configuration file
# Save as ~/.tmux-tools.yaml

# Display settings
display:
  theme: "default"              # default, vibrant, subtle, monochrome, none
  attachment_indicator: "•"     # Character to show attached sessions
  colors_enabled: true          # Enable/disable color output

# Naming settings
naming:
  session_pool: "cities"        # cities, custom

  # Custom session names (used when session_pool is "custom")
  custom_sessions:
    - "dev"
    - "work"
    - "personal"
    - "testing"

# Output settings
output:
  default_format: "compact"     # compact, detailed
  show_timestamps: true         # Show timestamps in headers
  group_sessions: true          # Group windows by session
EOF
}

# Get configuration value with fallback
# Args: key [default_value]
get_config_value() {
  local key="$1"
  local default_value="${2:-}"

  case "$key" in
    "theme") echo "$TMUX_TOOLS_THEME" ;;
    "session_pool") echo "$TMUX_TOOLS_SESSION_POOL" ;;
    "attachment_indicator") echo "$TMUX_TOOLS_ATTACHMENT_INDICATOR" ;;
    "default_format") echo "$TMUX_TOOLS_DEFAULT_FORMAT" ;;
    "show_timestamps") echo "$TMUX_TOOLS_SHOW_TIMESTAMPS" ;;
    "group_sessions") echo "$TMUX_TOOLS_GROUP_SESSIONS" ;;
    *) echo "$default_value" ;;
  esac
}

# Check if a configuration file exists
config_exists() {
  local config_file
  config_file=$(find_config_file)
  [[ -n "$config_file" ]]
}