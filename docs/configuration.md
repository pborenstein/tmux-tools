# Configuration Reference

## Overview

tmux-tools uses YAML configuration files to customize display themes, naming pools, and formatting options for session inspection and renaming. Configuration files are optional - the system works with sensible defaults.

## Configuration File Locations

Configuration files are searched in the following order (first found is used):

| Priority | Location | Description |
|:---------|:---------|:------------|
| 1 | `~/.tmux-tools.yaml` | User home directory (YAML) |
| 2 | `~/.tmux-tools.yml` | User home directory (YML) |
| 3 | `~/.config/tmux-tools/config.yaml` | XDG config directory (YAML) |
| 4 | `~/.config/tmux-tools/config.yml` | XDG config directory (YML) |
| 5 | `./tmux-tools.yaml` | Project directory (YAML) |
| 6 | `./tmux-tools.yml` | Project directory (YML) |

## Complete Configuration Example

```yaml
# tmux-tools configuration file
# Save as ~/.tmux-tools.yaml

# Display configuration
display:
  # Color theme: default, vibrant, subtle, monochrome, none
  theme: "default"

  # Enable/disable color output (overrides theme if false)
  colors_enabled: true

  # Character to show attached sessions (default: "•")
  attachment_indicator: "•"

  # Show timestamps in command headers
  show_timestamps: true

  # Group sessions visually in status display
  group_sessions: true

  # Default display format: compact, detailed
  default_format: "compact"

# Naming configuration
naming:
  # Session naming pool: cities, custom
  session_pool: "cities"

  # Window naming pool: mammals, custom
  window_pool: "mammals"

  # Custom session names (used when session_pool is "custom")
  custom_sessions:
    - "development"
    - "production"
    - "testing"
    - "monitoring"
    - "documentation"
    - "research"
    - "frontend"
    - "backend"
    - "database"
    - "deploy"

  # Custom window names (used when window_pool is "custom")
  custom_windows:
    - "editor"
    - "terminal"
    - "browser"
    - "logs"
    - "docs"
    - "server"
    - "client"
    - "tests"
    - "debug"
    - "build"

# Output formatting
output:
  # JSON formatting for machine-readable output
  json_pretty: true

  # Maximum width for command names in display
  max_command_width: 15

  # Show full paths or truncate them
  truncate_paths: true

  # Path truncation length
  max_path_length: 40

# Theme customization (advanced)
themes:
  # Define custom theme
  custom:
    session_color: "cyan"
    active_color: "green"
    command_color: "purple"
    path_color: "gray"
    background_color: "none"

    # Brightness: normal, bright, dim
    brightness: "normal"
```

## Configuration Sections

### Display Configuration

#### Theme Options

| Theme | Description | Use Case |
|:------|:------------|:---------|
| `default` | Balanced colors for general use | Standard terminal sessions |
| `vibrant` | Bright, high-contrast colors | High-resolution displays |
| `subtle` | Muted, professional colors | Work environments |
| `monochrome` | Single color scheme | Accessibility/preference |
| `none` | No colors (plain text) | Scripting/automation |

#### Display Settings

| Setting | Type | Default | Description |
|:--------|:-----|:--------|:------------|
| `colors_enabled` | boolean | `true` | Master color toggle |
| `attachment_indicator` | string | `"•"` | Symbol for attached sessions |
| `show_timestamps` | boolean | `true` | Include time in headers |
| `group_sessions` | boolean | `true` | Visual session grouping |
| `default_format` | string | `"compact"` | Default view mode |

### Naming Configuration

#### Session Naming Pools

**Built-in Cities Pool**:
```yaml
cities: [rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid]
```

**Custom Session Pool Example**:
```yaml
naming:
  session_pool: "custom"
  custom_sessions:
    - "web-dev"
    - "api-server"
    - "database"
    - "frontend"
    - "backend"
    - "testing"
    - "staging"
    - "production"
    - "monitoring"
    - "deployment"
```

#### Window Naming Pools

**Built-in Mammals Pool**:
```yaml
mammals: [cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse]
```

**Custom Window Pool Example**:
```yaml
naming:
  window_pool: "custom"
  custom_windows:
    - "editor"      # Code editing
    - "terminal"    # Command line
    - "browser"     # Web browsing
    - "server"      # Development server
    - "logs"        # Log monitoring
    - "tests"       # Running tests
    - "debug"       # Debugging sessions
    - "docs"        # Documentation
    - "client"      # Client applications
    - "admin"       # Administrative tasks
```

### Output Configuration

| Setting | Type | Default | Description |
|:--------|:-----|:--------|:------------|
| `json_pretty` | boolean | `true` | Format JSON output with indentation |
| `max_command_width` | integer | `15` | Truncate command names longer than this |
| `truncate_paths` | boolean | `true` | Shorten long file paths |
| `max_path_length` | integer | `40` | Maximum path length before truncation |

## Environment Variables

Configuration can also be set via environment variables, which take precedence over config files:

| Variable | Config Path | Default | Description |
|:---------|:------------|:--------|:------------|
| `TMUX_TOOLS_THEME` | `display.theme` | `"default"` | Color theme |
| `TMUX_TOOLS_SESSION_POOL` | `naming.session_pool` | `"cities"` | Session naming pool |
| `TMUX_TOOLS_WINDOW_POOL` | `naming.window_pool` | `"mammals"` | Window naming pool |
| `TMUX_TOOLS_ATTACHMENT_INDICATOR` | `display.attachment_indicator` | `"•"` | Attachment symbol |
| `TMUX_TOOLS_DEFAULT_FORMAT` | `display.default_format` | `"compact"` | Default display format |
| `TMUX_TOOLS_SHOW_TIMESTAMPS` | `display.show_timestamps` | `"true"` | Show timestamps |
| `TMUX_TOOLS_GROUP_SESSIONS` | `display.group_sessions` | `"true"` | Group sessions visually |
| `NO_COLOR` | `display.colors_enabled` | (unset) | Disable all colors when set |

## Configuration Management Commands

### View Current Configuration
```bash
tmux-tools config show
```

**Example Output**:
```
tmux-tools Configuration
========================

Configuration File: /Users/username/.tmux-tools.yaml

Display Settings:
  Theme: default
  Colors Enabled: true
  Attachment Indicator: •
  Show Timestamps: true
  Group Sessions: true
  Default Format: compact

Naming Settings:
  Session Pool: cities
  Window Pool: mammals

Current Session Names: rio, oslo, lima, bern, cairo, tokyo, paris, milan, berlin, sydney, boston, madrid
Current Window Names: cat, dog, fox, bat, elk, bear, lion, wolf, seal, deer, otter, mouse

Environment Overrides:
  TMUX_TOOLS_THEME: (not set)
  NO_COLOR: (not set)
```

### Create Example Configuration
```bash
tmux-tools config create
```

Creates `~/.tmux-tools.yaml` with example configuration and comments.

### Edit Configuration
```bash
tmux-tools config edit
```

Opens the configuration file in your default editor (`$EDITOR` or `vim`).

## Configuration Validation

### YAML Syntax Validation
The configuration parser handles common YAML syntax errors gracefully:

- **Missing quotes**: Values with spaces are handled correctly
- **Comments**: Inline and full-line comments are supported
- **Whitespace**: Flexible indentation and spacing
- **Case sensitivity**: Keys are case-sensitive

### Invalid Values
When invalid values are encountered:

| Issue | Behavior | Example |
|:------|:---------|:--------|
| Unknown theme | Falls back to "default" | `theme: "invalid"` → `"default"` |
| Empty name pool | Uses built-in pool | `custom_sessions: []` → cities |
| Invalid boolean | Uses default | `colors_enabled: "maybe"` → `true` |
| Missing section | Uses defaults | No `display:` section → all defaults |

## Advanced Configuration

### Custom Themes
Define completely custom color schemes:

```yaml
themes:
  corporate:
    session_color: "blue"
    active_color: "yellow"
    command_color: "white"
    path_color: "gray"
    background_color: "none"
    brightness: "normal"

  dark_mode:
    session_color: "bright_cyan"
    active_color: "bright_green"
    command_color: "bright_purple"
    path_color: "bright_black"
    background_color: "black"
    brightness: "bright"

# Use custom theme
display:
  theme: "corporate"
```

### Conditional Configuration
Use different configurations for different environments:

```bash
# Development environment
export TMUX_TOOLS_THEME="vibrant"
export TMUX_TOOLS_SESSION_POOL="custom"

# Production environment
export TMUX_TOOLS_THEME="subtle"
export TMUX_TOOLS_SHOW_TIMESTAMPS="false"
```

### Project-Specific Configuration
Place `.tmux-tools.yaml` in project directories for project-specific settings:

```yaml
# Project-specific naming
naming:
  session_pool: "custom"
  custom_sessions:
    - "myproject-dev"
    - "myproject-test"
    - "myproject-prod"

  window_pool: "custom"
  custom_windows:
    - "frontend"
    - "backend"
    - "database"
    - "nginx"
    - "redis"
```

## Troubleshooting Configuration

### Common Issues

**Configuration not loading**:
```bash
# Check which config file is being used
tmux-tools config show | grep "Configuration File"

# Verify file exists and is readable
ls -la ~/.tmux-tools.yaml
```

**YAML syntax errors**:
```bash
# Test YAML syntax with a YAML validator
python3 -c "import yaml; yaml.safe_load(open('~/.tmux-tools.yaml'))"
```

**Environment variables not working**:
```bash
# Check current environment
env | grep TMUX_TOOLS

# Test variable precedence
TMUX_TOOLS_THEME="vibrant" tmux-tools config show
```

### Debugging Configuration Loading

Enable debug output to see configuration loading process:

```bash
# Set debug mode
export TMUX_TOOLS_DEBUG=1

# Run command to see config loading
tmux-tools config show
```

**Debug Output Example**:
```
DEBUG: Searching for configuration file...
DEBUG: Checking /Users/username/.tmux-tools.yaml... found
DEBUG: Loading configuration from /Users/username/.tmux-tools.yaml
DEBUG: Parsed display.theme = "vibrant"
DEBUG: Parsed naming.session_pool = "cities"
DEBUG: Configuration loaded successfully
```

## Configuration Best Practices

### Organization
- **Use descriptive names** for custom pools
- **Group related settings** logically
- **Comment complex configurations** for future reference
- **Version control** project-specific configurations

### Performance
- **Avoid large name pools** (>50 names) for faster selection
- **Use simple themes** for better terminal compatibility
- **Disable colors** when using with scripts or pipes

### Maintainability
- **Document custom themes** and their intended use
- **Test configurations** after changes
- **Keep backups** of working configurations
- **Use environment variables** for temporary overrides