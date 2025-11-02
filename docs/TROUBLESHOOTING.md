# Troubleshooting Guide

This guide covers common issues, error messages, and solutions for tmux-tools.

## Table of Contents

- [Installation Issues](#installation-issues)
- [tmux Server Issues](#tmux-server-issues)
- [Display and Formatting Issues](#display-and-formatting-issues)
- [Configuration Issues](#configuration-issues)
- [Performance Issues](#performance-issues)
- [Color and Terminal Issues](#color-and-terminal-issues)
- [Renaming Issues](#renaming-issues)
- [Platform-Specific Issues](#platform-specific-issues)

## Installation Issues

### "bash: tmux-tools: command not found"

**Symptoms**:
- Command not recognized when running `tmux-tools`
- Works with `./tmux-tools` but not `tmux-tools`

**Solutions**:

1. Ensure scripts are executable:
   ```bash
   chmod +x tmux-tools tmux-status.sh tmux-overview
   ```

2. Add to PATH or create symlink:
   ```bash
   # Option 1: Add to PATH in ~/.bashrc or ~/.bash_profile
   export PATH="$PATH:/path/to/tmux-tools"

   # Option 2: Create symlink in PATH directory
   ln -s /path/to/tmux-tools/tmux-tools /usr/local/bin/tmux-tools
   ```

3. Verify installation:
   ```bash
   which tmux-tools
   tmux-tools version
   ```

**Related Issues**: Permission denied errors

### "Permission denied"

**Symptoms**:
- Error when attempting to run scripts
- Scripts not marked as executable

**Solutions**:

1. Make all scripts executable:
   ```bash
   cd /path/to/tmux-tools
   chmod +x tmux-tools tmux-status.sh tmux-overview
   chmod +x lib/*.sh
   ```

2. Verify permissions:
   ```bash
   ls -l tmux-tools tmux-status.sh tmux-overview
   # Should show: -rwxr-xr-x (executable)
   ```

## tmux Server Issues

### "No tmux sessions found"

**Symptoms**:
- Message: "No tmux sessions found (tmux server may not be running)"
- Commands return empty results
- Exit code 1

**Solutions**:

1. Check if tmux server is running:
   ```bash
   tmux list-sessions
   # If error: "no server running on..."
   ```

2. Start tmux server with a session:
   ```bash
   tmux new-session -d -s test
   tmux-tools status
   ```

3. Verify tmux socket:
   ```bash
   echo $TMUX
   # Should show socket path if inside tmux

   ls -la /tmp/tmux-$(id -u)/
   # Should show tmux socket files
   ```

**Related Issues**: Socket permission issues, multiple tmux servers

### "Error: tmux is not installed or not in PATH"

**Symptoms**:
- tmux command not found
- Error message about missing tmux installation

**Solutions**:

1. Install tmux:
   ```bash
   # macOS
   brew install tmux

   # Ubuntu/Debian
   sudo apt install tmux

   # Fedora/RHEL
   sudo dnf install tmux
   ```

2. Verify installation:
   ```bash
   which tmux
   tmux -V
   ```

3. Check PATH:
   ```bash
   echo $PATH
   # Ensure /usr/local/bin or tmux install location is in PATH
   ```

### "Failed to get tmux session list"

**Symptoms**:
- Error when querying tmux sessions
- Partial or corrupted output
- Script exits unexpectedly

**Solutions**:

1. Check tmux server status:
   ```bash
   tmux info | head -20
   ```

2. Restart tmux server:
   ```bash
   # Save any important sessions first
   tmux kill-server
   tmux new-session -d -s main
   ```

3. Verify tmux version compatibility:
   ```bash
   tmux -V
   # tmux-tools requires tmux 2.0 or later
   ```

## Display and Formatting Issues

### Columns Not Aligned

**Symptoms**:
- Table columns appear misaligned
- Data spills into adjacent columns
- Irregular spacing in output

**Solutions**:

1. Check for very long names:
   ```bash
   tmux-tools overview
   # Look for session/window names >20 characters
   ```

2. Shorten long session names:
   ```bash
   tmux rename-session old-very-long-name-here short-name
   ```

3. Use compact view for many sessions:
   ```bash
   tmux-tools status
   # Instead of: tmux-tools status --show-pid
   ```

4. Increase terminal width:
   ```bash
   # Minimum recommended: 80 columns
   # For detailed view: 120+ columns
   ```

**Related Issues**: Terminal width detection, UTF-8 display

### Special Characters Display Incorrectly

**Symptoms**:
- Non-ASCII characters appear as `?` or boxes
- Unicode symbols broken
- Attachment indicators not visible

**Solutions**:

1. Verify terminal UTF-8 support:
   ```bash
   locale
   # Should show: LANG=en_US.UTF-8
   ```

2. Set locale if needed:
   ```bash
   export LANG=en_US.UTF-8
   export LC_ALL=en_US.UTF-8
   ```

3. Test terminal character support:
   ```bash
   echo "Test: • → ← ↓ ↑"
   # Should display properly
   ```

4. Use alternative attachment indicator:
   ```bash
   # In ~/.tmux-tools.yaml
   display:
     attachment_indicator: "*"  # Use ASCII instead of •
   ```

### Width Column Shows Incorrect Values

**Symptoms**:
- Width column (w) shows unexpected numbers
- Missing width information
- Inconsistent width values

**Solutions**:

1. Check client connections:
   ```bash
   tmux list-clients
   # Shows all connected clients and their widths
   ```

2. Detach and reattach:
   ```bash
   tmux detach-client
   tmux attach-session -t session-name
   ```

3. Clear orphaned client data:
   ```bash
   tmux kill-server
   tmux new-session -s test
   ```

## Configuration Issues

### "Config file not found"

**Symptoms**:
- Warning about missing configuration
- Default settings always used
- Changes to config file not applied

**Solutions**:

1. Create configuration file:
   ```bash
   tmux-tools config create
   # Creates ~/.tmux-tools.yaml
   ```

2. Verify file location:
   ```bash
   ls -la ~/.tmux-tools.yaml
   cat ~/.tmux-tools.yaml
   ```

3. Check search paths:
   ```bash
   # tmux-tools searches in order:
   # 1. ~/.tmux-tools.yaml
   # 2. ~/.tmux-tools.yml
   # 3. ~/.config/tmux-tools/config.yaml
   # 4. ~/.config/tmux-tools/config.yml
   # 5. ./tmux-tools.yaml (project-local)
   ```

4. Show current configuration:
   ```bash
   tmux-tools config show
   ```

### Configuration Changes Not Applied

**Symptoms**:
- Edited config file but settings unchanged
- Theme not changing
- Custom names not used

**Solutions**:

1. Verify YAML syntax:
   ```bash
   # Check for:
   # - Proper indentation (2 spaces)
   # - Colons after keys
   # - Quoted string values
   # - Valid array syntax
   ```

2. Check environment variable overrides:
   ```bash
   env | grep TMUX_TOOLS
   # Environment variables override config file

   # Unset if needed:
   unset TMUX_TOOLS_THEME
   unset TMUX_TOOLS_SESSION_POOL
   ```

3. Validate configuration:
   ```bash
   tmux-tools config show
   # Shows active configuration values
   ```

4. Test with explicit environment variable:
   ```bash
   TMUX_TOOLS_THEME=vibrant tmux-tools status
   ```

### Custom Name Pools Not Working

**Symptoms**:
- Custom session/window names not used
- Default city/mammal names still appearing
- Configuration appears correct

**Solutions**:

1. Verify pool selection in config:
   ```yaml
   naming:
     session_pool: "custom"  # Must be "custom" not "cities"
     window_pool: "custom"   # Must be "custom" not "mammals"

     custom_sessions:
       - "dev"
       - "work"
   ```

2. Check array syntax:
   ```yaml
   # Correct
   custom_sessions:
     - "name1"
     - "name2"

   # Incorrect
   custom_sessions: ["name1", "name2"]  # Not supported
   ```

3. Test renaming manually:
   ```bash
   tmux-tools rename sessions
   tmux-tools overview
   ```

## Performance Issues

### Slow Response with Many Sessions

**Symptoms**:
- Commands take several seconds to complete
- Delay increases with session count
- System resource usage spikes

**Solutions**:

1. Use compact view by default:
   ```bash
   tmux-tools status
   # Faster than: tmux-tools status --show-pid
   ```

2. Filter to specific session:
   ```bash
   tmux-tools overview -s session-name
   # Instead of: tmux-tools overview --detailed
   ```

3. Check session count:
   ```bash
   tmux list-sessions | wc -l
   # >20 sessions may show slowdown
   ```

4. Clean up unused sessions:
   ```bash
   # List all sessions with creation time
   tmux list-sessions

   # Kill specific session
   tmux kill-session -t old-session
   ```

### High CPU Usage

**Symptoms**:
- Sustained high CPU usage when running commands
- Fan noise or system slowdown
- Commands seem to hang

**Solutions**:

1. Check for runaway processes in panes:
   ```bash
   tmux-tools status --show-pid
   # Look for unusual PIDs or commands
   ```

2. Limit detail level:
   ```bash
   tmux-tools overview
   # Instead of: tmux-tools overview --detailed
   ```

3. Disable JSON output if not needed:
   ```bash
   tmux-tools overview
   # Instead of: tmux-tools overview --json
   ```

## Color and Terminal Issues

### Colors Not Displaying

**Symptoms**:
- All output appears monochrome
- No color highlighting
- Terminal appears to support colors but none shown

**Solutions**:

1. Check NO_COLOR environment variable:
   ```bash
   echo $NO_COLOR
   # If set, colors are disabled

   unset NO_COLOR
   ```

2. Verify terminal color support:
   ```bash
   echo $TERM
   # Should be: xterm-256color, screen-256color, etc.

   tput colors
   # Should show: 256 or higher
   ```

3. Enable colors in configuration:
   ```yaml
   display:
     colors_enabled: true
   ```

4. Test color support:
   ```bash
   printf "\033[31mRed\033[0m \033[32mGreen\033[0m \033[34mBlue\033[0m\n"
   ```

### Colors Appear Incorrect

**Symptoms**:
- Colors different than expected
- Garbled or escaped color codes visible
- Wrong theme colors displayed

**Solutions**:

1. Set explicit theme:
   ```bash
   TMUX_TOOLS_THEME=default tmux-tools status
   ```

2. Try different themes:
   ```bash
   TMUX_TOOLS_THEME=vibrant tmux-tools status
   TMUX_TOOLS_THEME=subtle tmux-tools status
   TMUX_TOOLS_THEME=monochrome tmux-tools status
   ```

3. Check terminal emulator settings:
   - iTerm2: Preferences → Profiles → Colors
   - Terminal.app: Preferences → Profiles → Text
   - Ensure ANSI colors are enabled

4. Disable colors if problematic:
   ```bash
   export NO_COLOR=1
   tmux-tools status
   ```

### Escape Sequences Visible in Output

**Symptoms**:
- See `^[[31m` or similar codes in output
- Color codes not interpreted
- Raw ANSI escape sequences displayed

**Solutions**:

1. Verify terminal emulator supports ANSI:
   ```bash
   printf "\033[31mTest\033[0m\n"
   # Should show colored "Test", not raw codes
   ```

2. Check TERM variable:
   ```bash
   echo $TERM
   # Should NOT be: dumb, unknown
   ```

3. Disable colors:
   ```bash
   tmux-tools status | cat
   # Should strip color codes when piped
   ```

4. Use none theme:
   ```yaml
   display:
     theme: "none"
   ```

## Renaming Issues

### Sessions Not Renamed

**Symptoms**:
- `tmux-tools rename sessions` completes but names unchanged
- Only some sessions renamed
- Error messages during rename

**Solutions**:

1. Check which sessions will be renamed:
   ```bash
   tmux list-sessions
   # Only default names (numbers, "shellfish-N") are renamed
   # User-assigned names are preserved
   ```

2. Force rename specific session:
   ```bash
   tmux rename-session -t old-name new-name
   ```

3. Verify name pool:
   ```bash
   tmux-tools config show
   # Check session_pool setting
   ```

### Name Conflicts Occurring

**Symptoms**:
- Multiple sessions with similar names
- Naming scheme appears broken
- Expected names not assigned

**Solutions**:

1. Check current names:
   ```bash
   tmux list-sessions -F "#{session_name}"
   ```

2. Understand conflict resolution:
   - tmux-tools advances to next available name
   - No number suffixes added (e.g., "oslo-1")
   - Preserves existing user names

3. Manual resolution:
   ```bash
   # Rename conflicting session
   tmux rename-session -t duplicate-name unique-name

   # Then retry auto-rename
   tmux-tools rename sessions
   ```

### Windows Not Renamed

**Symptoms**:
- Window renaming fails
- Some windows renamed, others not
- Automatic window renaming interferes

**Solutions**:

1. Disable tmux automatic window renaming:
   ```bash
   tmux set-option -g allow-rename off
   tmux set-window-option -g automatic-rename off
   ```

2. Rename windows manually first:
   ```bash
   tmux rename-window -t session:0 name
   ```

3. Use window renaming command:
   ```bash
   tmux-tools rename windows
   ```

## Platform-Specific Issues

### macOS Issues

**Problem**: Old bash version (3.2) on macOS

**Symptoms**:
- Syntax errors with modern bash features
- Array handling issues

**Solutions**:

1. Install modern bash:
   ```bash
   brew install bash
   ```

2. Update shebang or use explicit path:
   ```bash
   /usr/local/bin/bash tmux-tools status
   ```

**Problem**: tmux clipboard integration

**Solutions**:
- Install reattach-to-user-namespace: `brew install reattach-to-user-namespace`

### Linux Distribution Issues

**Problem**: Missing tmux on minimal systems

**Solutions**:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install tmux

# CentOS/RHEL
sudo yum install tmux

# Arch Linux
sudo pacman -S tmux
```

**Problem**: Different default shell

**Solutions**:
```bash
# Ensure bash is used
bash /path/to/tmux-tools status
```

### WSL (Windows Subsystem for Linux) Issues

**Problem**: Display issues with Windows terminal

**Solutions**:

1. Use Windows Terminal (not cmd.exe or PowerShell):
   - Better color support
   - Proper UTF-8 handling

2. Set terminal correctly:
   ```bash
   export TERM=xterm-256color
   ```

## Diagnostic Commands

When reporting issues, include output from these commands:

```bash
# Environment information
echo "OS: $(uname -s)"
echo "Shell: $SHELL"
bash --version
tmux -V
echo "TERM: $TERM"
locale

# tmux status
tmux info | head -20
tmux list-sessions
tmux list-clients

# tmux-tools status
tmux-tools version
tmux-tools config show
env | grep TMUX_TOOLS

# Test basic functionality
tmux-tools status
tmux-tools overview
```

## Getting Help

If issues persist:

1. **Check documentation**:
   - [README.md](../README.md) - General usage
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
   - [DESIGN-PRINCIPLES.md](DESIGN-PRINCIPLES.md) - Design rationale

2. **Search existing issues**:
   - GitHub Issues for known problems
   - Discussions for questions

3. **Report new issue**:
   - Include diagnostic output (see above)
   - Describe expected vs actual behavior
   - Provide minimal reproduction steps
   - See [CONTRIBUTING.md](../CONTRIBUTING.md) for bug report template

4. **Try workarounds**:
   - Disable colors: `export NO_COLOR=1`
   - Use original scripts: `./tmux-status.sh`
   - Simplify configuration: remove config file temporarily
