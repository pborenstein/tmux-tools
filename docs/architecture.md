# tmux-tools Architecture

## Overview

tmux-tools is a modular tmux session inspection and naming toolkit built on a unified command interface with pluggable library components. The architecture separates concerns between user interface, data presentation, tmux server queries, and configuration management.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    tmux-tools (Main CLI)                    │
│                 Command Router & Dispatcher                 │
└─────────────────────┬───────────────────────────────────────┘
                      │
         ┌────────────┼────────────┐
         │            │            │
         ▼            ▼            ▼
┌─────────────┐ ┌──────────┐ ┌──────────┐
│   status    │ │ overview │ │  rename  │
│  (legacy)   │ │ (legacy) │ │ (new)    │
└─────────────┘ └──────────┘ └──────────┘
         │            │            │
         └────────────┼────────────┘
                      │
    ┌─────────────────┼─────────────────┐
    │                 │                 │
    ▼                 ▼                 ▼
┌─────────┐    ┌──────────────┐    ┌──────────┐
│ Display │    │     Core     │    │ Config   │
│ Layer   │◄──►│   Business   │◄──►│ Manager  │
│         │    │    Logic     │    │          │
└─────────┘    └──────────────┘    └──────────┘
    │                 │                 │
    ▼                 ▼                 ▼
┌─────────┐    ┌──────────────┐    ┌──────────┐
│ Colors  │    │  tmux API    │    │   YAML   │
│ Themes  │    │   Wrapper    │    │  Parser  │
└─────────┘    └──────────────┘    └──────────┘
                      │
                      ▼
              ┌──────────────┐
              │     tmux     │
              │    Server    │
              └──────────────┘
```

## Component Architecture

### 1. Command Interface Layer

#### `tmux-tools` (Main Entry Point)
- **Purpose**: Unified command dispatcher and argument parser
- **Responsibilities**:
  - Command routing to appropriate handlers
  - Help system management
  - Version information
  - Backward compatibility with legacy scripts

**Key Functions**:
```bash
main()                    # Primary entry point and argument parser
show_main_help()         # Unified help system
cmd_status()             # Route to status functionality
cmd_overview()           # Route to overview functionality
cmd_rename()             # Smart renaming operations
cmd_config()             # Configuration management
```

#### Legacy Script Compatibility
- **`tmux-status.sh`**: Tabular session display (backward compatible)
- **`tmux-overview`**: Tree-structured overview (backward compatible)
- Both scripts now use shared libraries while maintaining original interfaces

### 2. Library Layer

#### `lib/tmux_core.sh` - Data Query Layer
**Purpose**: tmux server queries and session data retrieval

**Key Functions**:
| Function | Purpose | Returns |
|:---------|:--------|:--------|
| `check_tmux_available()` | Validate tmux installation | exit code |
| `check_tmux_running()` | Verify tmux server status | exit code |
| `get_session_data()` | Retrieve session information | formatted session data |
| `get_window_data()` | Retrieve window information | formatted window data |
| `get_pane_data()` | Retrieve pane information | formatted pane data |
| `get_client_data()` | Retrieve client connection info | client data |
| `rename_session()` | Apply new session names | exit code |
| `rename_window()` | Apply new window names | exit code |

**Data Formats**:
```bash
# Session Data Format
"#{session_name}|#{session_created}|#{session_attached}|#{session_windows}"

# Window Data Format
"#{session_name}|#{window_index}|#{window_name}|#{window_panes}|#{window_active}"

# Pane Data Format
"#{session_name}|#{window_index}|#{pane_index}|#{pane_current_command}|#{pane_current_path}|#{pane_active}"
```

#### `lib/tmux_display.sh` - Presentation Layer
**Purpose**: Output formatting and display logic

**Key Functions**:
| Function | Purpose | Output Format |
|:---------|:--------|:--------------|
| `print_status_header()` | Table headers | Fixed-width columns |
| `print_status_row()` | Session/window/pane rows | Tabular format |
| `format_session_display()` | Session name formatting | Styled text |
| `format_window_display()` | Window name formatting | Styled text |
| `print_overview_row()` | Tree-structured display | Tree symbols |
| `get_window_indicator()` | Status symbols | Unicode symbols |

**Display Patterns**:
- **Tabular**: Fixed-width columns with aligned data
- **Tree**: Hierarchical structure with Unicode tree symbols
- **JSON**: Machine-readable structured data

#### `lib/tmux_colors.sh` - Theme System
**Purpose**: Color management and terminal formatting

**Theme Architecture**:
```bash
# Theme Structure
themes = {
  "default": { session: cyan, active: green, ... },
  "vibrant": { session: bright_cyan, active: bright_green, ... },
  "subtle": { session: dim_cyan, active: dim_green, ... },
  "monochrome": { session: white, active: bold_white, ... },
  "none": { session: "", active: "", ... }
}
```

**Key Functions**:
| Function | Purpose | Returns |
|:---------|:--------|:--------|
| `init_colors()` | Initialize theme system | sets global color vars |
| `get_color()` | Retrieve color code | ANSI escape sequence |
| `colorize_session()` | Apply session colors | styled text |
| `colorize_command()` | Apply command colors | styled text |

#### `lib/tmux_config.sh` - Configuration Management
**Purpose**: YAML configuration parsing and default value management

**Configuration Hierarchy**:
1. Environment variables (`TMUX_TOOLS_*`)
2. Configuration file (YAML)
3. Built-in defaults

**Configuration File Locations** (in priority order):
1. `~/.tmux-tools.yaml`
2. `~/.tmux-tools.yml`
3. `~/.config/tmux-tools/config.yaml`
4. `~/.config/tmux-tools/config.yml`
5. `./tmux-tools.yaml`
6. `./tmux-tools.yml`

**Key Functions**:
| Function | Purpose | Returns |
|:---------|:--------|:--------|
| `load_config()` | Load configuration from file | sets config variables |
| `find_config_file()` | Locate configuration file | file path |
| `parse_yaml_value()` | Extract YAML key-value | configuration value |
| `parse_yaml_array()` | Extract YAML arrays | array values |
| `get_session_names()` | Name pool retrieval | name array |
| `create_example_config()` | Generate sample config | writes file |

## Data Flow Architecture

### Status Inspection Flow
```
User Command → tmux-tools → cmd_status() → tmux-status.sh
     ↓
tmux_core.sh (query tmux server for session/window/pane data)
     ↓
tmux_display.sh (format data into tabular display)
     ↓
tmux_colors.sh (apply color themes)
     ↓
Terminal Output
```

### Configuration Flow
```
load_config() → find_config_file() → parse_yaml_value()
     ↓
Set Global Variables (TMUX_TOOLS_*)
     ↓
Used by all library components
```

### Renaming Flow
```
User Command → cmd_rename() → get_session_names()/get_window_names()
     ↓
Name Pool Selection (cities/mammals/custom)
     ↓
Conflict Resolution Algorithm
     ↓
tmux_core.sh (rename_session/rename_window)
     ↓
tmux Server API
```

## Extension Points

### 1. Adding New Commands
Create new command handler in `tmux-tools`:
```bash
cmd_newcommand() {
  # Command implementation
  # Can use all library functions
}
```

### 2. Custom Display Formatters
Extend `tmux_display.sh`:
```bash
format_custom_display() {
  local data="$1"
  # Custom formatting logic
}
```

### 3. Theme Extensions
Add themes to `tmux_colors.sh`:
```bash
init_custom_theme() {
  SESSION_COLOR='\033[custom'
  # Theme definition
}
```

### 4. Configuration Extensions
Extend configuration parsing in `tmux_config.sh`:
```bash
load_custom_config() {
  # Additional configuration handling
}
```

## Error Handling Strategy

### Defensive Programming Patterns
- **Input Validation**: All functions validate parameters
- **tmux Server Checks**: Verify tmux availability before operations
- **Graceful Degradation**: Fall back to defaults on configuration errors
- **Error Propagation**: Consistent return codes and error messages

### Error Handling Hierarchy
```bash
# Level 1: System validation
check_tmux_available() || exit 1

# Level 2: Data availability
check_tmux_running() || exit 1

# Level 3: Operation-specific errors
get_session_data() || return 1

# Level 4: Display fallbacks
format_session_display() || echo "$session_name"
```

## Performance Characteristics

### Data Caching Strategy
- **Session Data**: Retrieved once per command execution
- **Client Data**: Cached for width calculations
- **Configuration**: Loaded once at startup

### Scalability Limits
- **Sessions**: No practical limit (tested with 50+ sessions)
- **Windows per Session**: Limited by tmux (typically 1000+)
- **Panes per Window**: Limited by tmux and terminal display

### Optimization Opportunities
- **Parallel Data Retrieval**: Sessions could be processed concurrently
- **Incremental Updates**: Watch mode could use tmux hooks
- **Output Caching**: Formatted output could be cached for unchanged data

## Security Considerations

### Input Sanitization
- Session/window names validated before tmux commands
- Configuration file parsing uses safe regex patterns
- No evaluation of user-provided code

### File System Access
- Configuration files: Read-only access
- No temporary file creation
- Respects user's file permissions

## Testing Strategy

### Unit Testing Approach
```bash
# Test individual functions in isolation
test_get_attachment_indicator() {
  assertEquals " " "$(get_attachment_indicator 0)"
  assertEquals "•" "$(get_attachment_indicator 1)"
}
```

### Integration Testing
```bash
# Test with live tmux sessions
test_session_creation_and_display() {
  tmux new-session -d -s test_session
  output=$(./tmux-tools status | grep test_session)
  assertNotNull "$output"
}
```

### Configuration Testing
```bash
# Test configuration loading
test_config_loading() {
  echo "theme: vibrant" > test_config.yaml
  load_config test_config.yaml
  assertEquals "vibrant" "$TMUX_TOOLS_THEME"
}
```

## Future Architecture Considerations

### Plugin System
- **Hook-based Architecture**: Commands could trigger plugin hooks
- **External Scripts**: Plugin directory with auto-discovery
- **API Standardization**: Defined interfaces for plugin communication

### API Evolution
- **Versioned Interfaces**: Stable API contracts for library functions
- **Backward Compatibility**: Deprecation strategy for breaking changes
- **Extension Registration**: Formal system for adding new functionality

### Performance Enhancements
- **Async Operations**: Background data collection
- **Delta Updates**: Incremental change detection
- **Caching Layer**: Persistent cache for expensive operations