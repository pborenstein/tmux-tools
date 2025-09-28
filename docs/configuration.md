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

| Theme | Colors | Use Case | Environment |
|-------|--------|----------|-------------|
| `default` | Balanced | General use | Standard terminals |
| `vibrant` | Bright/saturated | High contrast | Dark themes, outdoor |
| `subtle` | Muted/professional | Work environments | Presentations |
| `monochrome` | Single color | Accessibility | Consistency needs |
| `none` | No colors | Scripting/automation | Piping, logs |

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

| Pool Type | Pool Name | Sample Names | Count |
|-----------|-----------|--------------|-------|
| Sessions | `cities` | rio, oslo, lima, bern, cairo, tokyo | 12 |
| Windows | `mammals` | cat, dog, fox, bat, elk, bear | 12 |

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

| Category | Variable | Example | Purpose |
|----------|----------|---------|----------|
| **Theme** | `TMUX_TOOLS_THEME` | `vibrant` | Color scheme |
| | `TMUX_TOOLS_COLORS` | `false` | Enable/disable colors |
| **Naming** | `TMUX_TOOLS_SESSION_POOL` | `custom` | Session name source |
| | `TMUX_TOOLS_WINDOW_POOL` | `mammals` | Window name source |
| **Display** | `TMUX_TOOLS_ATTACHMENT_INDICATOR` | `"★"` | Session indicator |
| | `TMUX_TOOLS_DEFAULT_FORMAT` | `detailed` | Output format |

### Temporary Overrides

| Purpose | Command | Use Case |
|---------|---------|----------|
| Disable colors | `TMUX_TOOLS_THEME=none tmux-tools overview` | Single command |
| Disable for piping | `TMUX_TOOLS_COLORS=false tmux-tools status > report.txt` | File output |
| JSON format | `TMUX_TOOLS_DEFAULT_FORMAT=json tmux-tools overview > sessions.json` | Scripting |

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

| Error Type | Problem | Example | Fix |
|------------|---------|---------|-----|
| Invalid theme | Unknown theme name | `theme: "invalid-theme"` | Use valid theme |
| Empty pool | Custom pool with no names | `custom_sessions: []` | Add names to pool |
| Invalid format | Unknown output format | `default_format: "invalid"` | Use valid format |

### Configuration Debugging

| Command | Purpose | Output |
|---------|---------|--------|
| `tmux-tools config debug` | Show resolution process | Configuration loading steps |
| `tmux-tools config source` | Show active file | Which config file is used |
| `tmux-tools config help` | Show options | All available settings |

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

| Action | Command | Purpose |
|--------|---------|----------|
| Backup | `cp ~/.tmux-tools.yaml ~/.tmux-tools.yaml.backup` | Save current config |
| Restore | `cp ~/.tmux-tools.yaml.backup ~/.tmux-tools.yaml` | Restore from backup |
| Version control | `mkdir -p ~/.config/tmux-tools && cp ~/.tmux-tools.yaml ~/.config/tmux-tools/config.yaml` | Use XDG location |

### Sharing Configuration

| Action | Command | Use Case |
|--------|---------|----------|
| Export | `tmux-tools config export --portable > config.yaml` | Share with team |
| Import | `tmux-tools config import config.yaml` | Apply shared config |

## Troubleshooting Configuration

### Configuration Not Loading

| Issue | Command | Check |
|-------|---------|-------|
| File location | `tmux-tools config source` | Which file is used |
| Syntax errors | `tmux-tools config validate` | YAML validity |
| Effective config | `tmux-tools config show` | Final settings |

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

| Priority | Guide | Purpose |
|----------|-------|----------|
| 1 | [Usage Guide](usage.md) | Apply configuration in practice |
| 2 | [Architecture Overview](architecture.md) | Understand configuration system |
| 3 | [Development Guide](development.md) | Extend configuration options |