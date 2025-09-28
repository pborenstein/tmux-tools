# Installation Guide

This guide covers different installation methods for tmux-tools, from quick local setup to system-wide installation.

## Prerequisites

Before installing tmux-tools, ensure you have:

- **tmux**: The terminal multiplexer (required)
- **bash**: Version 4.0 or later
- **Standard Unix tools**: `date`, `sort`, `grep`, etc.

### Installing tmux

| Platform | Package Manager | Command |
|----------|----------------|----------|
| **macOS** | Homebrew | `brew install tmux` |
| | MacPorts | `sudo port install tmux` |
| **Ubuntu/Debian** | APT | `sudo apt update && sudo apt install tmux` |
| **RHEL/CentOS** | YUM | `sudo yum install tmux` |
| **Fedora** | DNF | `sudo dnf install tmux` |

## Installation Methods

| Method | Target | Commands | Use Case |
|--------|--------|----------|----------|
| **Quick Local** | Development | `git clone <url> && cd tmux-tools && chmod +x *.sh tmux-tools` | Testing, development |
| **System-Wide** | All users | `sudo cp tmux-tools tmux-*.sh /usr/local/bin/ && sudo mkdir -p /usr/local/lib/tmux-tools && sudo cp -r lib/ /usr/local/lib/tmux-tools/` | Production servers |
| **User-Local** | Single user | `mkdir -p ~/bin ~/.local/lib/tmux-tools && cp tmux-tools tmux-*.sh ~/bin/ && cp -r lib/ ~/.local/lib/tmux-tools/` | Personal machines |
| **Package Managers** | Automated | `brew install tmux-tools` (planned) | Future convenience |

## Validation

After installation, verify everything works:

### 1. Test Core Functionality
```bash
# Start a test tmux session
tmux new-session -d -s test

# Test status display
tmux-tools status

# Test overview
tmux-tools overview

# Clean up
tmux kill-session -t test
```

### 2. Test Library Loading
```bash
# Verify libraries are found
tmux-tools config show
```

### 3. Test Configuration System
```bash
# Create example configuration
tmux-tools config create

# Verify configuration loads
tmux-tools config show
```

## Configuration Setup

### Create Configuration File

```bash
# Create example configuration
tmux-tools config create

# Edit configuration
tmux-tools config edit
```

### Configuration Locations

| Priority | Location | Purpose |
|----------|----------|----------|
| 1 | `~/.tmux-tools.yaml` | User preferences |
| 2 | `~/.tmux-tools.yml` | User preferences (alt) |
| 3 | `~/.config/tmux-tools/config.yaml` | XDG standard |
| 4 | `~/.config/tmux-tools/config.yml` | XDG standard (alt) |
| 5 | `./tmux-tools.yaml` | Project-specific |
| 6 | `./tmux-tools.yml` | Project-specific (alt) |

## Library Path Configuration

If you installed to a non-standard location, set the library path:

```bash
# Set library path environment variable
export TMUX_TOOLS_LIB_PATH="/path/to/tmux-tools/lib"

# Add to shell configuration for persistence
echo 'export TMUX_TOOLS_LIB_PATH="/path/to/tmux-tools/lib"' >> ~/.bashrc
```

## Troubleshooting

### Common Installation Issues

| Issue | Diagnosis | Solution |
|-------|-----------|----------|
| Permission denied | Scripts not executable | `chmod +x tmux-status.sh tmux-overview tmux-tools` |
| Command not found | PATH missing install dir | `export PATH="/usr/local/bin:$PATH"` |
| Library not found | Missing lib directory | `export TMUX_TOOLS_LIB_PATH="$(pwd)/lib"` |
| tmux not running | tmux server stopped | `tmux new-session -d -s test` |

### Verifying Installation

Run this comprehensive test:

```bash
#!/bin/bash
echo "=== tmux-tools Installation Test ==="

# Test 1: Check executables
echo "1. Checking executables..."
which tmux-tools && echo "✓ tmux-tools found" || echo "✗ tmux-tools not found"
which tmux-status.sh && echo "✓ tmux-status.sh found" || echo "✗ tmux-status.sh not found"
which tmux-overview && echo "✓ tmux-overview found" || echo "✗ tmux-overview not found"

# Test 2: Check tmux
echo "2. Checking tmux..."
which tmux && echo "✓ tmux found" || echo "✗ tmux not found"
tmux list-sessions &>/dev/null && echo "✓ tmux server running" || echo "✗ tmux server not running"

# Test 3: Test functionality
echo "3. Testing functionality..."
tmux new-session -d -s install-test 2>/dev/null
tmux-tools status &>/dev/null && echo "✓ status command works" || echo "✗ status command failed"
tmux-tools overview &>/dev/null && echo "✓ overview command works" || echo "✗ overview command failed"
tmux kill-session -t install-test 2>/dev/null

# Test 4: Check configuration
echo "4. Checking configuration..."
tmux-tools config show &>/dev/null && echo "✓ configuration system works" || echo "✗ configuration system failed"

echo "=== Installation test complete ==="
```

### Getting Help

If you encounter issues:

1. Check the [Troubleshooting](../README.md#troubleshooting) section in the main README
2. Verify all prerequisites are installed
3. Ensure tmux is running: `tmux list-sessions`
4. Check file permissions: `ls -la tmux-tools`
5. Verify PATH includes installation directory: `echo $PATH`

## Uninstallation

To remove tmux-tools:

| Installation Type | Removal Commands |
|-------------------|------------------|
| **Local** | `rm -rf tmux-tools/` |
| **System** | `sudo rm /usr/local/bin/tmux-tools /usr/local/bin/tmux-*.sh && sudo rm -rf /usr/local/lib/tmux-tools` |
| **User** | `rm ~/bin/tmux-tools ~/bin/tmux-*.sh && rm -rf ~/.local/lib/tmux-tools` |
| **Config** (optional) | `rm ~/.tmux-tools.yaml && rm -rf ~/.config/tmux-tools` |

## Next Steps

| Priority | Guide | Purpose |
|----------|-------|----------|
| 1 | [Usage Guide](usage.md) | Learn commands and examples |
| 2 | [Configuration](configuration.md) | Customize for your workflow |
| 3 | [Architecture](architecture.md) | Understand system design |
| 4 | [Development](development.md) | Contribute to project |