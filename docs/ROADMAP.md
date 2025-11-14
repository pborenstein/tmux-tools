# Roadmap

## Recently Completed

**Control mode indicator redesign**:
- Removed separate control mode column for more compact display
- Control mode now indicated by underlining attachment indicator (• or number)
- Better visual integration while maintaining clear indication

**Client information and control mode (v1.3.0)**:
- Control mode detection for sessions with control mode clients
- `--show-clients` flag to display detailed client connection info
- Client dimensions in WxH format (e.g., 172x53) instead of just width
- Shows TTY, timestamps (HH:MM), dimensions, control mode, and user info
- Detached sessions visible in client view with clear placeholders

**Usability improvements**:
- Short command aliases (`s`, `stat`, `o`, `ov`, `r`, `ren`, `c`, `conf`, `h`, `v`, `ver`)
- Help topic shortcuts (`ses`, `win`, `pan`)
- `tt` short alias for `tmux-tools`
- Integrated help system with COMMANDS.md
- Default command changed to `status`
- Commands show help instead of errors when missing subcommands

**Smart window naming**:
- Directory-based window naming using active pane's current directory
- Automatic truncation to 20 characters
- More contextual and meaningful than generic names

**Compatibility**:
- bash 3.2+ support for macOS compatibility

## Potential Improvements

### Near-term (Low effort)

**Display refinements**:
- Column width limits with ellipsis for long names
- Path truncation for readability
- Shell completion scripts (bash/zsh)

**Error handling**:
- Better messages with remediation suggestions
- Tmux version compatibility checks
- Graceful degradation when server unavailable

**Performance**:
- Cache client data
- Batch tmux queries for large session counts

### Medium-term (Moderate effort)

**Export formats**:
- CSV for spreadsheet analysis
- Markdown for documentation
- HTML with styling

**Configuration**:
- Validation with error messages
- Multiple profiles (work/personal)
- Per-command format preferences

### Long-term (High effort)

**Interactive mode**:
- Real-time monitoring with live updates
- Keyboard navigation
- Session/window switching

**Advanced naming**:
- Git repository integration (branch name, repo status)
- Project-based naming from config files

## Contributing

Submit feature requests via GitHub Issues with use cases. Include tests with code contributions. Follow existing code patterns.