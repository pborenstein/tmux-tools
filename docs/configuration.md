# Configuration Guide

tmux-tools supports flexible configuration through YAML files, allowing you to customize appearance, naming schemes, and behavior to match your workflow.

## Configuration File Locations

tmux-tools searches for configuration files in this order:

1. `~/.tmux-tools.yaml`
2. `~/.tmux-tools.yml`
3. `~/.config/tmux-tools/config.yaml`
4. `~/.config/tmux-tools/config.yml`
5. `./tmux-tools.yaml`
6. `./tmux-tools.yml`

The first configuration file found is used. If no configuration file exists, default settings are applied.

## Creating Configuration

### Generate Example Configuration

```bash
# Create example configuration in ~/.tmux-tools.yaml
tmux-tools config create

# View current configuration
tmux-tools config show

# Edit configuration file
tmux-tools config edit
```

### Manual Configuration

Create `~/.tmux-tools.yaml`:

```yaml
# tmux-tools configuration file

# Display settings
display:
  theme: "default"              # Color theme
  attachment_indicator: "•"     # Character for attached sessions
  colors_enabled: true          # Enable/disable colors
  show_timestamps: true         # Show timestamps in headers
  group_sessions: true          # Group windows by session

# Naming settings
naming:
  session_pool: "cities"        # Session naming scheme
  window_pool: "mammals"        # Window naming scheme

  # Custom name pools (used when pool is "custom")
  custom_sessions:
    - "dev"
    - "work"
    - "personal"
    - "testing"
    - "experiments"

  custom_windows:
    - "editor"
    - "terminal"
    - "browser"
    - "docs"
    - "server"

# Output settings
output:
  default_format: "compact"     # Default display format
  max_session_name_length: 13   # Truncate long session names
  max_window_name_length: 8     # Truncate long window names
  max_command_length: 7         # Truncate long commands
```

## Configuration Sections

### Display Settings

Control visual appearance and themes.

#### Theme Options

| Theme | Description | Use Case |
|-------|-------------|----------|
| `default` | Balanced colors for general use | Standard terminals |
| `vibrant` | Bright colors for high contrast | Dark themes, outdoor use |
| `subtle` | Muted colors for professional environments | Work environments, presentations |
| `monochrome` | Single color scheme | Accessibility, consistency |
| `none` | No colors (plain text) | Scripting, automation, piping |

#### Display Configuration

```yaml
display:
  theme: "vibrant"                    # Color theme
  attachment_indicator: "●"           # Session attachment symbol
  colors_enabled: true                # Master color enable/disable
  show_timestamps: true               # Include timestamps in output
  group_sessions: true                # Visual session grouping
  background_contrast: "auto"         # auto, light, dark
```

### Naming Settings

Configure session and window naming schemes.

#### Built-in Name Pools

**Cities (session_pool: "cities")**:
`rio`, `oslo`, `lima`, `bern`, `cairo`, `tokyo`, `paris`, `milan`, `berlin`, `sydney`, `boston`, `madrid`

**Mammals (window_pool: "mammals")**:
`cat`, `dog`, `fox`, `bat`, `elk`, `bear`, `lion`, `wolf`, `seal`, `deer`, `otter`, `mouse`

#### Custom Name Pools

```yaml
naming:
  session_pool: "custom"              # Use custom session names
  window_pool: "custom"               # Use custom window names

  custom_sessions:
    - "frontend"
    - "backend"
    - "database"
    - "testing"
    - "staging"
    - "production"

  custom_windows:
    - "code"
    - "build"
    - "test"
    - "deploy"
    - "monitor"
    - "debug"
```

#### Project-Specific Names

```yaml
naming:
  session_pool: "projects"            # Use project directory names
  window_pool: "tools"                # Use development tools

  project_sessions:
    prefix: "proj-"                   # Optional prefix
    suffix: "-dev"                    # Optional suffix

  tool_windows:
    - "vim"
    - "git"
    - "make"
    - "docker"
    - "kubectl"
```

### Output Settings

Control formatting and display behavior.

```yaml
output:
  default_format: "detailed"          # compact, detailed, json
  max_session_name_length: 15         # Truncation limits
  max_window_name_length: 10
  max_command_length: 12
  show_full_paths: false               # Show abbreviated paths
  path_abbreviation: "~/..."           # Path abbreviation style
  table_spacing: 2                     # Column spacing
  header_style: "bold"                 # bold, underline, none
```

## Environment Variables

Configuration can be overridden with environment variables:

### Core Settings

```bash
# Theme settings
export TMUX_TOOLS_THEME=vibrant
export TMUX_TOOLS_COLORS=false

# Naming settings
export TMUX_TOOLS_SESSION_POOL=custom
export TMUX_TOOLS_WINDOW_POOL=mammals

# Display settings
export TMUX_TOOLS_ATTACHMENT_INDICATOR="★"
export TMUX_TOOLS_DEFAULT_FORMAT=detailed
```

### Temporary Overrides

```bash
# Override theme for single command
TMUX_TOOLS_THEME=none tmux-tools overview

# Disable colors for piping
TMUX_TOOLS_COLORS=false tmux-tools status > report.txt

# Use custom format
TMUX_TOOLS_DEFAULT_FORMAT=json tmux-tools overview > sessions.json
```

## Advanced Configuration

### Conditional Configuration

Use different settings based on environment:

```yaml
# Development environment
development:
  display:
    theme: "vibrant"
    show_timestamps: true
  naming:
    session_pool: "projects"
    window_pool: "tools"

# Production environment
production:
  display:
    theme: "subtle"
    colors_enabled: false
  output:
    default_format: "json"
```

Activate with:
```bash
export TMUX_TOOLS_ENV=development
tmux-tools overview
```

### Profile-Based Configuration

```yaml
profiles:
  work:
    display:
      theme: "subtle"
    naming:
      session_pool: "custom"
      custom_sessions:
        - "meetings"
        - "email"
        - "coding"
        - "research"

  home:
    display:
      theme: "vibrant"
    naming:
      session_pool: "cities"
      window_pool: "mammals"
```

Use with:
```bash
tmux-tools --profile work overview
```

### Integration Settings

```yaml
integration:
  git:
    auto_session_names: true          # Use git repo names
    branch_in_window_name: true       # Include branch in window names

  docker:
    show_container_status: true       # Show container status in names

  kubernetes:
    show_namespace: true              # Include k8s namespace
    show_context: true                # Include k8s context
```

## Configuration Validation

### Validate Configuration

```bash
# Check configuration syntax
tmux-tools config validate

# Show effective configuration
tmux-tools config show

# Test configuration with dry run
tmux-tools config test
```

### Common Validation Errors

```yaml
# ❌ Invalid theme
display:
  theme: "invalid-theme"              # Error: unknown theme

# ❌ Empty custom pool
naming:
  session_pool: "custom"
  custom_sessions: []                 # Error: empty custom pool

# ❌ Invalid format
output:
  default_format: "invalid"           # Error: unknown format
```

### Configuration Debugging

```bash
# Show configuration resolution
tmux-tools config debug

# Show which file is being used
tmux-tools config source

# Show all available options
tmux-tools config help
```

## Configuration Examples

### Minimal Configuration

```yaml
# ~/.tmux-tools.yaml
display:
  theme: "default"
naming:
  session_pool: "cities"
  window_pool: "mammals"
```

### Developer Configuration

```yaml
# ~/.tmux-tools.yaml
display:
  theme: "vibrant"
  attachment_indicator: "●"
  show_timestamps: true

naming:
  session_pool: "custom"
  window_pool: "custom"
  custom_sessions:
    - "frontend"
    - "backend"
    - "database"
    - "testing"
    - "docs"
  custom_windows:
    - "editor"
    - "terminal"
    - "browser"
    - "server"
    - "test"

output:
  default_format: "compact"
  max_session_name_length: 15
  show_full_paths: false
```

### Scripting Configuration

```yaml
# ~/.tmux-tools.yaml
display:
  theme: "none"
  colors_enabled: false
  show_timestamps: false

output:
  default_format: "json"
  table_spacing: 1

integration:
  git:
    auto_session_names: true
```

### Multi-Environment Configuration

```yaml
# ~/.tmux-tools.yaml
default:
  display:
    theme: "default"
  naming:
    session_pool: "cities"

environments:
  laptop:
    display:
      theme: "subtle"
    output:
      max_session_name_length: 10

  desktop:
    display:
      theme: "vibrant"
    output:
      max_session_name_length: 20

  server:
    display:
      theme: "none"
      colors_enabled: false
    output:
      default_format: "json"
```

## Configuration Migration

### Migrating from Environment Variables

If you've been using environment variables:

```bash
# Create configuration from current environment
tmux-tools config export > ~/.tmux-tools.yaml

# Review and edit
tmux-tools config edit
```

### Backup and Restore

```bash
# Backup current configuration
cp ~/.tmux-tools.yaml ~/.tmux-tools.yaml.backup

# Restore from backup
cp ~/.tmux-tools.yaml.backup ~/.tmux-tools.yaml

# Create version-controlled configuration
mkdir -p ~/.config/tmux-tools
cp ~/.tmux-tools.yaml ~/.config/tmux-tools/config.yaml
```

### Sharing Configuration

```bash
# Export shareable configuration (no personal paths)
tmux-tools config export --portable > tmux-tools-config.yaml

# Import configuration
tmux-tools config import tmux-tools-config.yaml
```

## Troubleshooting Configuration

### Configuration Not Loading

```bash
# Check file locations
tmux-tools config source

# Verify file syntax
tmux-tools config validate

# Show effective configuration
tmux-tools config show
```

### Common Issues

#### YAML Syntax Errors

```yaml
# ❌ Incorrect indentation
display:
theme: "default"                      # Missing indent

# ✅ Correct indentation
display:
  theme: "default"
```

#### Invalid Values

```bash
# Check available options
tmux-tools config options

# Validate specific setting
tmux-tools config validate display.theme
```

#### Permission Issues

```bash
# Check file permissions
ls -la ~/.tmux-tools.yaml

# Fix permissions
chmod 644 ~/.tmux-tools.yaml
```

## Performance Considerations

### Large Name Pools

```yaml
# Efficient for large pools
naming:
  session_pool: "custom"
  custom_sessions: !include sessions.yaml  # External file

# Avoid very large inline arrays
custom_sessions:
  - name1
  - name2
  # ... 100+ names (consider external file)
```

### Caching Configuration

```bash
# Configuration is cached automatically
# Force reload if needed
tmux-tools config reload
```

## Next Steps

- Review [Usage Guide](usage.md) for applying configuration in practice
- Explore [Architecture Overview](architecture.md) to understand configuration loading
- Check [Development Guide](development.md) for extending configuration options