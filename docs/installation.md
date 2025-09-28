# Installation Guide

This guide covers different installation methods for tmux-tools, from quick local setup to system-wide installation.

## Prerequisites

Before installing tmux-tools, ensure you have:

- **tmux**: The terminal multiplexer (required)
- **bash**: Version 4.0 or later
- **Standard Unix tools**: `date`, `sort`, `grep`, etc.

### Installing tmux

If tmux is not installed on your system:

#### macOS
```bash
# Using Homebrew
brew install tmux

# Using MacPorts
sudo port install tmux
```

#### Linux (Ubuntu/Debian)
```bash
sudo apt update
sudo apt install tmux
```

#### Linux (RHEL/CentOS/Fedora)
```bash
# RHEL/CentOS
sudo yum install tmux

# Fedora
sudo dnf install tmux
```

## Installation Methods

### 1. Quick Local Setup (Recommended for Development)

Clone and set up for local use:

```bash
# Clone the repository
git clone <repository-url>
cd tmux-tools

# Make scripts executable
chmod +x tmux-status.sh tmux-overview tmux-tools

# Test installation
./tmux-tools --help
```

### 2. System-Wide Installation

Install to system PATH for all users:

```bash
# After cloning and setting permissions
sudo cp tmux-tools /usr/local/bin/
sudo cp tmux-status.sh /usr/local/bin/
sudo cp tmux-overview /usr/local/bin/

# Copy library files
sudo mkdir -p /usr/local/lib/tmux-tools
sudo cp -r lib/ /usr/local/lib/tmux-tools/

# Test system installation
tmux-tools --help
```

### 3. User-Local Installation

Install to personal bin directory:

```bash
# Create personal bin if it doesn't exist
mkdir -p ~/bin

# Copy executables
cp tmux-tools ~/bin/
cp tmux-status.sh ~/bin/
cp tmux-overview ~/bin/

# Copy library files
mkdir -p ~/.local/lib/tmux-tools
cp -r lib/ ~/.local/lib/tmux-tools/

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/bin:$PATH"

# Reload shell configuration
source ~/.bashrc  # or ~/.zshrc
```

### 4. Package Manager Installation (Future)

Package manager support is planned:

```bash
# Homebrew (planned)
brew install tmux-tools

# APT (planned)
sudo apt install tmux-tools

# NPM (planned)
npm install -g tmux-tools
```

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

tmux-tools looks for configuration in this order:

1. `~/.tmux-tools.yaml`
2. `~/.tmux-tools.yml`
3. `~/.config/tmux-tools/config.yaml`
4. `~/.config/tmux-tools/config.yml`
5. `./tmux-tools.yaml`
6. `./tmux-tools.yml`

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

#### Permission Denied
```bash
# Make scripts executable
chmod +x tmux-status.sh tmux-overview tmux-tools

# For system installation
sudo cp tmux-tools /usr/local/bin/
```

#### Command Not Found
```bash
# Check if installed location is in PATH
echo $PATH

# Add to PATH if needed
export PATH="/usr/local/bin:$PATH"
```

#### Library Not Found
```bash
# Check library path
ls -la lib/

# Set library path if needed
export TMUX_TOOLS_LIB_PATH="$(pwd)/lib"
```

#### tmux Not Running
```bash
# Start tmux server
tmux new-session -d -s test

# Verify tmux is running
tmux list-sessions
```

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

### Local Installation
```bash
# Remove from local directory
rm -rf tmux-tools/
```

### System Installation
```bash
# Remove executables
sudo rm /usr/local/bin/tmux-tools
sudo rm /usr/local/bin/tmux-status.sh
sudo rm /usr/local/bin/tmux-overview

# Remove libraries
sudo rm -rf /usr/local/lib/tmux-tools
```

### User Installation
```bash
# Remove from personal directories
rm ~/bin/tmux-tools
rm ~/bin/tmux-status.sh
rm ~/bin/tmux-overview
rm -rf ~/.local/lib/tmux-tools

# Remove configuration (optional)
rm ~/.tmux-tools.yaml
rm -rf ~/.config/tmux-tools
```

## Next Steps

After successful installation:

1. Read the [Usage Guide](usage.md) for detailed examples
2. Review [Configuration Options](configuration.md) for customization
3. Explore the [Architecture Overview](architecture.md) to understand the system
4. Check out [Development Guide](development.md) if you want to contribute