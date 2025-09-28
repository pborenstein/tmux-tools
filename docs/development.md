# Development Guide

This guide covers contributing to tmux-tools, from setting up a development environment to implementing new features and maintaining code quality.

## Development Environment Setup

### Prerequisites

- **Git**: Version control
- **bash**: Version 4.0 or later
- **tmux**: For testing functionality
- **ShellCheck**: For bash linting (recommended)
- **bats**: For testing framework (optional)

### Development Installation

```bash
# Clone the repository
git clone <repository-url>
cd tmux-tools

# Set up development environment
make dev-setup  # If Makefile exists, otherwise:

# Make scripts executable
chmod +x tmux-status.sh tmux-overview tmux-tools

# Install development dependencies
# macOS
brew install shellcheck bats-core

# Ubuntu/Debian
sudo apt install shellcheck bats

# Test installation
./tmux-tools --help
```

### Development Configuration

Create a development configuration:

```yaml
# dev-config.yaml
display:
  theme: "vibrant"
  show_timestamps: true

naming:
  session_pool: "custom"
  custom_sessions:
    - "dev-session-1"
    - "dev-session-2"
    - "test-session"

output:
  default_format: "detailed"
```

Use with:
```bash
TMUX_TOOLS_CONFIG=dev-config.yaml ./tmux-tools status
```

## Project Structure Understanding

### Core Components

```
tmux-tools/
├── tmux-tools              # Main entry point (argument parsing, command dispatch)
├── tmux-status.sh          # Legacy status tool (backward compatibility)
├── tmux-overview           # Legacy overview tool (backward compatibility)
├── lib/                    # Shared libraries
│   ├── tmux_core.sh        # Core tmux operations and utilities
│   ├── tmux_display.sh     # Output formatting and display logic
│   ├── tmux_colors.sh      # Color theme management
│   └── tmux_config.sh      # Configuration file handling
├── docs/                   # Documentation
└── _attic/                 # Historical files and archives
```

### Code Organization Principles

1. **Shared functionality** goes in `lib/` modules
2. **Tool-specific logic** stays in individual scripts
3. **Configuration** is centralized in `tmux_config.sh`
4. **Display formatting** is abstracted in `tmux_display.sh`
5. **Legacy compatibility** is maintained in original scripts

## Coding Standards

### Bash Style Guide

Follow these conventions for consistency:

#### Variables and Functions

```bash
# ✅ Use lowercase with underscores for variables
local session_name="oslo"
local window_count=5

# ✅ Use lowercase with underscores for functions
get_session_data() {
    local session="$1"
    # function body
}

# ❌ Avoid camelCase or mixed case
sessionName="oslo"              # Don't do this
GetSessionData() {              # Don't do this
    # function body
}
```

#### Error Handling

```bash
# ✅ Always check command success
if ! tmux_data=$(tmux list-sessions); then
    echo "Error: Failed to get tmux sessions" >&2
    return 1
fi

# ✅ Use explicit error messages
validate_session_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        echo "Error: Session name cannot be empty" >&2
        return 1
    fi
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Error: Invalid characters in session name: $name" >&2
        return 1
    fi
}
```

#### Parameter Handling

```bash
# ✅ Handle parameters safely
process_session() {
    local session_name="$1"
    local format="${2:-}"  # Optional parameter with default

    # Validate required parameters
    if [[ -z "$session_name" ]]; then
        echo "Error: Session name required" >&2
        return 1
    fi

    # Set default for optional parameters
    if [[ -z "$format" ]]; then
        format="#{session_name}|#{session_created}"
    fi
}
```

#### Quoting and Safety

```bash
# ✅ Quote variables to handle spaces
tmux new-session -d -s "$session_name" -c "$working_directory"

# ✅ Use arrays for lists
local city_names=("oslo" "milan" "tokyo" "berlin")

# ✅ Use here-docs for multi-line strings
cat <<EOF
This is a multi-line
message that preserves
formatting properly.
EOF
```

### Documentation Standards

#### Function Documentation

```bash
# Description: Retrieves session data with specified format
# Parameters:
#   $1 - session_name (required): Name of the tmux session
#   $2 - format (optional): tmux format string, defaults to name|created
# Returns: 0 on success, 1 on error
# Output: Formatted session data to stdout
get_session_data() {
    local session_name="$1"
    local format="${2:-}"

    # Implementation...
}
```

#### Configuration Options

```bash
# Configuration: display.theme
# Values: default, vibrant, subtle, monochrome, none
# Default: default
# Description: Color theme for terminal output
```

### Testing Standards

#### Unit Tests

Create tests for individual functions:

```bash
# test/test_tmux_core.sh
#!/usr/bin/env bats

setup() {
    # Load library for testing
    source "lib/tmux_core.sh"
}

@test "get_attachment_indicator returns correct symbols" {
    run get_attachment_indicator 0
    [ "$status" -eq 0 ]
    [ "$output" = " " ]

    run get_attachment_indicator 1
    [ "$status" -eq 0 ]
    [ "$output" = "•" ]

    run get_attachment_indicator 5
    [ "$status" -eq 0 ]
    [ "$output" = "5" ]
}

@test "validate_session_name rejects invalid names" {
    run validate_session_name ""
    [ "$status" -eq 1 ]

    run validate_session_name "invalid name with spaces"
    [ "$status" -eq 1 ]

    run validate_session_name "valid-name_123"
    [ "$status" -eq 0 ]
}
```

#### Integration Tests

Test complete workflows:

```bash
# test/test_integration.sh
#!/usr/bin/env bats

setup() {
    # Create test tmux session
    tmux new-session -d -s test_integration_$$
}

teardown() {
    # Clean up test session
    tmux kill-session -t test_integration_$$ 2>/dev/null || true
}

@test "status command shows test session" {
    run ./tmux-tools status
    [ "$status" -eq 0 ]
    [[ "$output" =~ test_integration ]]
}

@test "overview JSON output is valid" {
    run ./tmux-tools overview --json
    [ "$status" -eq 0 ]

    # Validate JSON syntax
    echo "$output" | jq . >/dev/null
}
```

### Code Quality Tools

#### ShellCheck Integration

```bash
# Run ShellCheck on all scripts
shellcheck tmux-tools tmux-status.sh tmux-overview lib/*.sh

# Common ShellCheck fixes
# SC2034: Variable appears unused
# SC2086: Double quote to prevent globbing
# SC2059: Don't use variables in printf format string
```

#### Development Makefile

```makefile
# Makefile for development tasks
.PHONY: test lint format check install-dev

# Run all tests
test:
	bats test/

# Lint all shell scripts
lint:
	shellcheck tmux-tools tmux-status.sh tmux-overview lib/*.sh

# Format shell scripts (if using shfmt)
format:
	shfmt -w -i 2 tmux-tools tmux-status.sh tmux-overview lib/*.sh

# Complete code quality check
check: lint test

# Install development dependencies
install-dev:
	brew install shellcheck bats-core shfmt
```

## Contributing New Features

### Adding New Commands

1. **Plan the command structure**:
   ```bash
   tmux-tools <new-command> [options]
   ```

2. **Add command dispatch** in `tmux-tools`:
   ```bash
   case "$command" in
       "status") handle_status "$@" ;;
       "overview") handle_overview "$@" ;;
       "new-command") handle_new_command "$@" ;;  # Add here
       *) show_help; exit 1 ;;
   esac
   ```

3. **Implement handler function**:
   ```bash
   handle_new_command() {
       local option="$1"

       # Parse options
       case "$option" in
           "--help"|"-h") show_new_command_help ;;
           *) execute_new_command "$@" ;;
       esac
   }
   ```

4. **Add help documentation**:
   ```bash
   show_new_command_help() {
       cat <<EOF
   Usage: tmux-tools new-command [options]

   Description of the new command functionality.

   Options:
     --option1    Description of option1
     --help, -h   Show this help message
   EOF
   }
   ```

### Adding New Library Functions

1. **Choose appropriate library**:
   - Core tmux operations → `tmux_core.sh`
   - Display formatting → `tmux_display.sh`
   - Color management → `tmux_colors.sh`
   - Configuration → `tmux_config.sh`

2. **Follow function template**:
   ```bash
   # lib/tmux_core.sh

   # Description: New function description
   # Parameters: Parameter documentation
   # Returns: Return value documentation
   new_function_name() {
       local param1="$1"
       local param2="${2:-default_value}"

       # Validate parameters
       if [[ -z "$param1" ]]; then
           echo "Error: param1 is required" >&2
           return 1
       fi

       # Implementation
       local result
       if ! result=$(some_operation "$param1"); then
           echo "Error: Operation failed" >&2
           return 1
       fi

       echo "$result"
   }
   ```

3. **Update library exports** if needed:
   ```bash
   # At end of library file
   export -f new_function_name
   ```

4. **Add tests**:
   ```bash
   @test "new_function_name handles valid input" {
       run new_function_name "valid_input"
       [ "$status" -eq 0 ]
       [ "$output" = "expected_output" ]
   }
   ```

### Adding New Output Formats

1. **Extend format dispatch** in relevant tool:
   ```bash
   case "$format" in
       "compact") print_compact_format "$data" ;;
       "detailed") print_detailed_format "$data" ;;
       "json") print_json_format "$data" ;;
       "new-format") print_new_format "$data" ;;  # Add here
       *) echo "Error: Unknown format: $format" >&2; return 1 ;;
   esac
   ```

2. **Implement format function**:
   ```bash
   print_new_format() {
       local data="$1"

       # Process data for new format
       while IFS='|' read -r session window pane cmd; do
           # Format logic here
           printf "formatted output\n" "$session" "$window" "$pane" "$cmd"
       done <<< "$data"
   }
   ```

### Adding Configuration Options

1. **Document the option**:
   ```yaml
   # Example configuration section
   new_section:
     new_option: "default_value"    # Description of option
   ```

2. **Add parsing support**:
   ```bash
   # In tmux_config.sh
   get_new_option() {
       get_config_value "new_section.new_option" "default_value"
   }
   ```

3. **Use in application code**:
   ```bash
   # Load configuration
   load_config

   # Get option value
   new_option=$(get_new_option)

   # Apply setting
   apply_new_option "$new_option"
   ```

## Debugging and Troubleshooting

### Debug Mode

Enable debug output:

```bash
# Set debug mode
export TMUX_TOOLS_DEBUG=1
./tmux-tools status

# Debug specific components
export TMUX_TOOLS_DEBUG_CONFIG=1    # Configuration loading
export TMUX_TOOLS_DEBUG_COLORS=1    # Color management
export TMUX_TOOLS_DEBUG_CORE=1      # Core operations
```

### Debug Functions

Add debug output to functions:

```bash
debug_log() {
    if [[ "${TMUX_TOOLS_DEBUG:-}" == "1" ]]; then
        echo "DEBUG: $*" >&2
    fi
}

get_session_data() {
    debug_log "Getting session data for: $1"

    local data
    if ! data=$(tmux list-sessions); then
        debug_log "Failed to get session data"
        return 1
    fi

    debug_log "Retrieved ${#data} bytes of session data"
    echo "$data"
}
```

### Common Issues and Solutions

#### Library Loading Problems

```bash
# Check library path
echo "Library path: ${TMUX_TOOLS_LIB_PATH:-${SCRIPT_DIR}/lib}"
ls -la "${TMUX_TOOLS_LIB_PATH:-${SCRIPT_DIR}/lib}"

# Verify library files
for lib in tmux_core.sh tmux_display.sh tmux_colors.sh tmux_config.sh; do
    if [[ -f "${LIB_DIR}/${lib}" ]]; then
        echo "✓ ${lib} found"
    else
        echo "✗ ${lib} missing"
    fi
done
```

#### tmux Integration Issues

```bash
# Test tmux connectivity
if ! tmux list-sessions >/dev/null 2>&1; then
    echo "tmux server not running or not accessible"
    exit 1
fi

# Check tmux version compatibility
tmux_version=$(tmux -V | grep -o '[0-9.]*')
echo "tmux version: $tmux_version"
```

#### Configuration Problems

```bash
# Validate configuration syntax
validate_config_syntax() {
    local config_file="$1"

    # Basic YAML syntax check
    if ! python3 -c "import yaml; yaml.safe_load(open('$config_file'))" 2>/dev/null; then
        echo "Invalid YAML syntax in: $config_file"
        return 1
    fi
}
```

## Release Process

### Version Management

1. **Update version number** in `tmux-tools`:
   ```bash
   VERSION="1.2.0"
   ```

2. **Tag release**:
   ```bash
   git tag -a v1.2.0 -m "Release version 1.2.0"
   git push origin v1.2.0
   ```

3. **Update changelog**:
   ```markdown
   ## [1.2.0] - 2025-09-27
   ### Added
   - New feature description
   ### Changed
   - Changed functionality description
   ### Fixed
   - Bug fix description
   ```

### Pre-release Testing

```bash
# Run complete test suite
make test

# Test installation process
./install.sh
tmux-tools --version

# Test backward compatibility
./tmux-status.sh --help
./tmux-overview --help

# Test configuration migration
tmux-tools config validate
```

### Documentation Updates

1. **Update README.md** with new features
2. **Update docs/** with detailed information
3. **Verify all examples** work with current version
4. **Check cross-references** between documentation files

## Maintenance Guidelines

### Code Review Checklist

- [ ] Code follows style guidelines
- [ ] Functions are documented
- [ ] Error handling is comprehensive
- [ ] Tests cover new functionality
- [ ] ShellCheck passes without warnings
- [ ] Backward compatibility is maintained
- [ ] Configuration options are documented

### Performance Monitoring

```bash
# Profile script execution
time ./tmux-tools status

# Monitor memory usage
/usr/bin/time -l ./tmux-tools overview

# Test with large session counts
for i in {1..50}; do
    tmux new-session -d -s "perf_test_$i"
done
time ./tmux-tools status
```

### Dependency Management

- Keep external dependencies minimal
- Document all requirements in README
- Provide alternative implementations when possible
- Test on multiple platforms (macOS, Linux)

## Getting Help

### Resources

- **Issue Tracker**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Wiki**: Additional documentation and examples
- **Code Review**: Submit pull requests for review

### Contributing Guidelines

1. **Fork** the repository
2. **Create feature branch**: `git checkout -b feature/new-feature`
3. **Make changes** following coding standards
4. **Add tests** for new functionality
5. **Update documentation** as needed
6. **Submit pull request** with clear description

### Contact

- **Maintainer**: See repository contributors
- **Community**: Join project discussions
- **Documentation**: Improve docs via pull requests

## Next Steps

After reading this guide:

1. Set up your development environment
2. Run the test suite to verify setup
3. Read the [Architecture Overview](architecture.md) for deeper understanding
4. Start with small contributions to get familiar with the codebase
5. Join the community and ask questions

Happy developing!