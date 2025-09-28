# Development Guide

## Overview

This guide covers contributing to tmux-tools, including setup, architecture understanding, testing, and development workflows. Whether you're fixing bugs, adding features, or improving documentation, this guide will help you get started.

## Quick Start for Contributors

### Prerequisites

- **bash** 4.0+ (check with `bash --version`)
- **tmux** 2.0+ (check with `tmux -V`)
- **git** for version control
- **jq** for JSON processing (optional, for testing)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/username/tmux-tools.git
cd tmux-tools

# Make scripts executable
chmod +x tmux-tools tmux-status.sh tmux-overview

# Test installation
./tmux-tools help

# Create test tmux session
tmux new-session -d -s dev-test

# Verify functionality
./tmux-tools status
./tmux-tools overview
```

### Project Structure

```
tmux-tools/
├── docs/                    # Documentation
│   ├── architecture.md     # System architecture
│   ├── configuration.md    # Configuration reference
│   ├── development.md      # This file
│   ├── integration.md      # Automation and scripting
│   └── examples/           # Usage examples
├── lib/                    # Library modules
│   ├── tmux_core.sh       # Core tmux operations
│   ├── tmux_display.sh    # Display formatting
│   ├── tmux_colors.sh     # Color management
│   └── tmux_config.sh     # Configuration handling
├── tmux-tools             # Main unified interface
├── tmux-status.sh         # Legacy status script
├── tmux-overview          # Legacy overview script
├── README.md              # Main documentation
└── LICENSE                # MIT license
```

## Development Workflow

### Branch Strategy

- **main**: Stable, production-ready code
- **feature/**: New features (`feature/new-command`)
- **fix/**: Bug fixes (`fix/color-display`)
- **docs/**: Documentation improvements (`docs/api-reference`)

### Making Changes

1. **Create feature branch**:
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes** following coding standards

3. **Test thoroughly**:
   ```bash
   # Test core functionality
   ./test-basic-functionality.sh

   # Test with different configurations
   ./test-configuration.sh

   # Test error conditions
   ./test-error-handling.sh
   ```

4. **Update documentation** if needed

5. **Commit with descriptive messages**:
   ```bash
   git commit -m "feat: Add session filtering to overview command

   - Add --filter option to overview command
   - Support multiple filter criteria
   - Update help documentation
   - Add tests for filtering functionality"
   ```

6. **Create pull request** with detailed description

## Code Style Guidelines

### Bash Script Standards

**General Principles**:
- Use `set -euo pipefail` for strict error handling
- Quote all variable expansions: `"$variable"`
- Use meaningful function and variable names
- Include error handling for all external commands

**Function Structure**:
```bash
# Function: description of what it does
# Args: parameter descriptions
# Returns: return value description
function_name() {
  local param1="$1"
  local param2="${2:-default_value}"

  # Validate parameters
  if [[ -z "$param1" ]]; then
    echo "Error: param1 is required" >&2
    return 1
  fi

  # Function logic
  local result
  result=$(some_command "$param1") || return 1

  echo "$result"
}
```

**Error Handling Pattern**:
```bash
# Check dependencies
if ! command -v tmux >/dev/null 2>&1; then
  echo "Error: tmux is not installed" >&2
  exit 1
fi

# Handle command failures
if ! tmux_data=$(tmux list-sessions 2>/dev/null); then
  echo "Error: Could not retrieve tmux sessions" >&2
  return 1
fi
```

**Variable Naming**:
- Use `snake_case` for local variables
- Use `UPPER_CASE` for global constants
- Prefix internal functions with `_` (e.g., `_parse_config`)

### Documentation Standards

**Function Documentation**:
```bash
#=============================================================================
# function_name - Brief description
#=============================================================================
#
# PURPOSE:
#   Detailed description of what the function does and why it exists.
#
# USAGE:
#   function_name arg1 [arg2] [arg3]
#
# ARGUMENTS:
#   arg1        - Description of required argument
#   arg2        - Description of optional argument (default: value)
#   arg3        - Description of optional argument
#
# RETURNS:
#   0           - Success
#   1           - Error condition
#
# OUTPUTS:
#   stdout      - Description of stdout output
#   stderr      - Description of error output
#
# EXAMPLES:
#   function_name "required_value"
#   function_name "value1" "optional_value2"
#
#=============================================================================
```

**File Headers**:
```bash
#!/bin/bash

#=============================================================================
# filename.sh - Brief file description
#=============================================================================
#
# PURPOSE:
#   Description of the file's purpose and functionality.
#
# USAGE:
#   ./filename.sh [options] [arguments]
#
# DEPENDENCIES:
#   - tmux 2.0+
#   - bash 4.0+
#   - jq (optional)
#
#=============================================================================

set -euo pipefail
```

## Architecture Guidelines

### Library Design Principles

1. **Single Responsibility**: Each library file has one clear purpose
2. **Dependency Injection**: Pass dependencies as parameters
3. **Error Propagation**: Consistent error handling and return codes
4. **Configuration**: Use global variables set by config system
5. **Testability**: Design functions to be easily unit tested

### Adding New Commands

**1. Add to Main Dispatcher** (`tmux-tools`):
```bash
# In main command parser
case $command in
  # ... existing commands ...
  newcommand)
    cmd_newcommand "$@"
    ;;
```

**2. Implement Command Handler**:
```bash
# New command implementation
cmd_newcommand() {
  local subcommand="$1"
  shift

  case "$subcommand" in
    --help|-h|help)
      show_newcommand_help
      ;;
    *)
      # Command logic using library functions
      if ! check_tmux_running; then
        exit 1
      fi

      # Use library functions
      local session_data
      session_data=$(get_session_data) || exit 1

      # Process and display
      format_newcommand_output "$session_data"
      ;;
  esac
}
```

**3. Add Help Documentation**:
```bash
show_newcommand_help() {
  cat << EOF
tmux-tools newcommand - Description of new command

USAGE:
    tmux-tools newcommand [options]

OPTIONS:
    --option1       Description of option1
    --option2       Description of option2
    -h, --help      Show this help message

EXAMPLES:
    tmux-tools newcommand --option1
    tmux-tools newcommand --option2 value
EOF
}
```

### Extending Library Functions

**Adding to Core Library** (`lib/tmux_core.sh`):
```bash
# New core function
get_new_tmux_data() {
  local format="${1:-default_format}"
  local session_filter="${2:-}"

  # Validate tmux availability
  if ! check_tmux_running; then
    return 1
  fi

  # Build tmux command
  local tmux_cmd="tmux list-something -F '$format'"

  # Apply filters if specified
  if [[ -n "$session_filter" ]]; then
    tmux_cmd="$tmux_cmd | grep '$session_filter'"
  fi

  # Execute and return
  eval "$tmux_cmd" 2>/dev/null || return 1
}
```

## Testing Guidelines

### Manual Testing Checklist

**Before submitting changes, test:**

1. **Basic Functionality**:
   ```bash
   # Test all main commands
   ./tmux-tools help
   ./tmux-tools version
   ./tmux-tools status
   ./tmux-tools overview
   ./tmux-tools rename auto
   ./tmux-tools config show
   ```

2. **Legacy Compatibility**:
   ```bash
   # Test legacy scripts still work
   ./tmux-status.sh
   ./tmux-overview
   ./tmux-status.sh --help
   ./tmux-overview --help
   ```

3. **Error Conditions**:
   ```bash
   # Test with no tmux sessions
   tmux kill-server
   ./tmux-tools status  # Should show appropriate error

   # Test with invalid options
   ./tmux-tools invalid-command
   ./tmux-tools status --invalid-option
   ```

4. **Configuration Testing**:
   ```bash
   # Test configuration loading
   echo "theme: vibrant" > test-config.yaml
   TMUX_TOOLS_CONFIG=test-config.yaml ./tmux-tools status
   ```

### Unit Testing Framework

**Create test file** (`tests/test_core.sh`):
```bash
#!/bin/bash

# Source the library to test
source lib/tmux_core.sh

# Test counter
TESTS_RUN=0
TESTS_PASSED=0

# Test framework functions
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-}"

  TESTS_RUN=$((TESTS_RUN + 1))

  if [[ "$expected" == "$actual" ]]; then
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo "✓ $message"
  else
    echo "✗ $message"
    echo "  Expected: '$expected'"
    echo "  Actual:   '$actual'"
  fi
}

# Test cases
test_attachment_indicator() {
  # Mock tmux command for testing
  tmux() {
    case "$*" in
      "list-sessions -F session_name session_attached")
        echo "test_session 0"
        ;;
    esac
  }

  local result
  result=$(get_attachment_indicator "test_session")
  assert_equals " " "$result" "Detached session shows space"
}

# Run tests
test_attachment_indicator

# Summary
echo "Tests: $TESTS_PASSED/$TESTS_RUN passed"
[[ $TESTS_PASSED -eq $TESTS_RUN ]]
```

### Integration Testing

**Test with real tmux sessions**:
```bash
#!/bin/bash
# integration-test.sh

setup_test_sessions() {
  # Create predictable test environment
  tmux new-session -d -s test-session-1
  tmux new-session -d -s test-session-2
  tmux new-window -t test-session-1 -n test-window
}

cleanup_test_sessions() {
  tmux kill-session -t test-session-1 2>/dev/null || true
  tmux kill-session -t test-session-2 2>/dev/null || true
}

test_status_output() {
  local output
  output=$(./tmux-tools status)

  # Verify expected sessions appear
  if [[ "$output" =~ test-session-1 ]]; then
    echo "✓ Status shows test sessions"
  else
    echo "✗ Status missing test sessions"
    return 1
  fi
}

# Run integration tests
setup_test_sessions
test_status_output
cleanup_test_sessions
```

## Performance Guidelines

### Optimization Principles

1. **Minimize tmux calls**: Cache data when possible
2. **Efficient parsing**: Use bash built-ins over external commands
3. **Early exit**: Validate inputs before expensive operations
4. **Batch operations**: Combine multiple tmux commands when possible

### Performance Testing

```bash
#!/bin/bash
# performance-test.sh

test_performance() {
  local iterations=100
  local start_time end_time duration

  echo "Testing tmux-tools status performance..."

  start_time=$(date +%s.%N)
  for ((i=1; i<=iterations; i++)); do
    ./tmux-tools status >/dev/null
  done
  end_time=$(date +%s.%N)

  duration=$(echo "$end_time - $start_time" | bc -l)
  avg_time=$(echo "scale=4; $duration / $iterations" | bc -l)

  echo "Average time per call: ${avg_time}s"
  echo "Total time for $iterations calls: ${duration}s"
}

# Create multiple sessions for realistic testing
for i in {1..10}; do
  tmux new-session -d -s "perf-test-$i"
done

test_performance

# Cleanup
for i in {1..10}; do
  tmux kill-session -t "perf-test-$i"
done
```

## Documentation Guidelines

### Documentation Structure

- **README.md**: High-level overview and quick start
- **docs/architecture.md**: Detailed system design
- **docs/configuration.md**: Complete configuration reference
- **docs/integration.md**: Automation and scripting examples
- **docs/development.md**: This file - contributor guide

### Writing Guidelines

1. **Clear Structure**: Use consistent headings and organization
2. **Practical Examples**: Include working code samples
3. **Cross-References**: Link related sections
4. **Maintenance**: Keep documentation updated with code changes

### Documentation Testing

```bash
#!/bin/bash
# test-documentation.sh

test_documentation_examples() {
  # Extract and test code examples from markdown
  grep -A 10 '```bash' docs/*.md | while read -r example; do
    if [[ "$example" =~ tmux-tools ]]; then
      echo "Testing: $example"
      # Test the example (carefully!)
    fi
  done
}
```

## Release Process

### Version Management

**Version Format**: `MAJOR.MINOR.PATCH`
- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

**Update Version**:
```bash
# In tmux-tools main script
VERSION="1.2.3"
```

### Release Checklist

1. **Update version number** in all relevant files
2. **Update CHANGELOG.md** with new features and fixes
3. **Test thoroughly** on different systems
4. **Update documentation** for new features
5. **Create release tag**:
   ```bash
   git tag -a v1.2.3 -m "Release version 1.2.3"
   git push origin v1.2.3
   ```

### Changelog Format

```markdown
# Changelog

## [1.2.3] - 2025-XX-XX

### Added
- New feature descriptions

### Changed
- Changed feature descriptions

### Fixed
- Bug fix descriptions

### Deprecated
- Deprecated feature warnings

### Removed
- Removed feature descriptions
```

## Troubleshooting Development Issues

### Common Issues

**Permission Errors**:
```bash
# Make scripts executable
chmod +x tmux-tools tmux-status.sh tmux-overview
```

**tmux Not Available**:
```bash
# Install tmux
# macOS
brew install tmux

# Ubuntu/Debian
sudo apt-get install tmux

# CentOS/RHEL
sudo yum install tmux
```

**Bash Version Issues**:
```bash
# Check bash version
bash --version

# Update bash on macOS
brew install bash
```

### Debugging Techniques

**Enable Debug Mode**:
```bash
# Add to script
set -x  # Enable debug output
set +x  # Disable debug output

# Or run with debug
bash -x ./tmux-tools status
```

**Add Debug Logging**:
```bash
debug_log() {
  if [[ "${TMUX_TOOLS_DEBUG:-}" == "1" ]]; then
    echo "DEBUG: $*" >&2
  fi
}

# Usage
debug_log "Processing session: $session_name"
```

**Test Individual Functions**:
```bash
# Source library and test function
source lib/tmux_core.sh
get_session_data | head -5
```

## Contributing Guidelines

### Code Review Process

1. **Self-Review**: Review your own changes before submitting
2. **Testing**: Ensure all tests pass
3. **Documentation**: Update relevant documentation
4. **Description**: Provide clear PR description with context

### Issue Reporting

**Bug Reports** should include:
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, tmux version, bash version)
- Relevant configuration

**Feature Requests** should include:
- Use case description
- Proposed implementation approach
- Potential alternatives considered

### Communication

- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Use GitHub Issues for bugs and feature requests
- **PRs**: Use Pull Requests for code changes

## Resources

### Useful References

- [Bash Manual](https://www.gnu.org/software/bash/manual/)
- [tmux Manual](https://man.openbsd.org/tmux)
- [Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Semantic Versioning](https://semver.org/)

### Development Tools

- **shellcheck**: Static analysis for shell scripts
- **bats**: Bash testing framework
- **shfmt**: Shell script formatter
- **bashate**: Bash style checker