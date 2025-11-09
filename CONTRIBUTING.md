# Contributing to tmux-tools

Thank you for considering contributing to tmux-tools. This document provides guidelines and information for contributors.

## Getting Started

### Prerequisites

- bash 3.2 or later (macOS compatible)
- tmux (any recent version)
- Git for version control

Optional:
- jq for JSON processing
- ShellCheck for shell script linting

### Development Setup

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR-USERNAME/tmux-tools.git
   cd tmux-tools
   ```

2. Make scripts executable:
   ```bash
   chmod +x tmux-tools tmux-status.sh tmux-overview tt
   ```

3. Test basic functionality:
   ```bash
   ./tmux-tools status     # Or use short alias: ./tt s
   ./tmux-tools overview   # Or use short alias: ./tt o
   ./tt h                  # Show help and command reference
   ```

## Project Structure

```
tmux-tools/
├── lib/
│   ├── tmux_core.sh      # Core tmux operations (255 lines)
│   ├── tmux_display.sh   # Display formatting (313 lines)
│   ├── tmux_colors.sh    # Color management (205 lines)
│   └── tmux_config.sh    # Configuration handling (284 lines)
├── tmux-tools            # Unified command interface (355 lines)
├── tt                    # Short alias (symlink to tmux-tools)
├── tmux-status.sh        # Status display script (364 lines)
└── tmux-overview         # Overview script (336 lines)
```

## Development Guidelines

### Code Style

**Shell Scripting Standards**:
- Use bash, not sh or other shells
- Indent with 2 spaces (no tabs)
- Use `#!/bin/bash` shebang
- Quote variables: `"$var"` not `$var`
- Use `[[ ]]` for conditionals, not `[ ]`
- Prefer `local` for function variables

**Naming Conventions**:
- Functions: `snake_case` (e.g., `get_session_data`)
- Variables: `snake_case` with descriptive names
- Constants: `UPPER_CASE` (e.g., `SESSION_COLOR`)
- Private/internal functions: prefix with underscore `_internal_func`

**Error Handling**:
- Check command availability with `command -v`
- Use `|| return 1` for critical operations
- Redirect errors to stderr: `>&2`
- Provide actionable error messages

**Example**:
```bash
# Good
check_tmux_available() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux not found. Install with: brew install tmux" >&2
    return 1
  fi
  return 0
}

# Bad
check_tmux() {
  if [ ! $(which tmux) ]; then
    echo "tmux not found"
    exit 1
  fi
}
```

### Library Organization

**Where to add new code**:

| Module | Purpose | Add When |
|--------|---------|----------|
| tmux_core.sh | tmux operations, data retrieval | Adding tmux queries or session operations |
| tmux_display.sh | Formatting, output generation | Creating new display formats or layouts |
| tmux_colors.sh | Colors, themes, styling | Adding themes or color management |
| tmux_config.sh | Configuration, YAML parsing | Extending configuration options |

**Adding new library functions**:
1. Place in appropriate module (see table above)
2. Add header comment explaining purpose and usage
3. Document parameters and return values
4. Include error handling
5. Test with and without tmux running

### Testing

**Manual Testing Checklist**:

1. Test with tmux running:
   ```bash
   tmux new-session -d -s test
   ./tmux-tools status
   ./tmux-tools overview
   ```

2. Test without tmux running:
   ```bash
   # Stop all tmux sessions
   tmux kill-server
   ./tmux-tools status  # Should show helpful error
   ```

3. Test backward compatibility:
   ```bash
   ./tmux-status.sh              # Original interface
   ./tmux-overview --detailed    # Original options
   ```

4. Test configuration:
   ```bash
   ./tmux-tools config create
   ./tmux-tools config show
   ```

5. Test all themes:
   ```bash
   TMUX_TOOLS_THEME=vibrant ./tmux-tools status
   TMUX_TOOLS_THEME=subtle ./tmux-tools status
   TMUX_TOOLS_THEME=monochrome ./tmux-tools status
   NO_COLOR=1 ./tmux-tools status
   ```

**Edge Cases to Test**:
- Very long session names (>20 characters)
- Very long window names (>20 characters)
- Sessions with many windows (10+)
- Windows with many panes (5+)
- Non-ASCII characters in names
- Special characters in paths

### Commit Guidelines

**Commit Message Format**:
```
<type>: <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style/formatting (no functional changes)
- `refactor`: Code restructuring (no functional changes)
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Example**:
```
feat: Add CSV export format to overview command

Implement CSV output option for tmux-tools overview to enable
spreadsheet analysis of session data. Includes proper escaping
of special characters and configurable field delimiter.

Resolves #42
```

**Commit Best Practices**:
- Keep commits focused and atomic
- Write clear, descriptive messages
- Reference issues when applicable
- Test before committing
- One logical change per commit

## Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow code style guidelines
   - Add comments for complex logic
   - Update documentation if needed
   - Test thoroughly

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Open a pull request**:
   - Provide clear description of changes
   - Reference related issues
   - Explain why the change is needed
   - Include testing notes

### Pull Request Checklist

Before submitting, verify:

- [ ] Code follows project style guidelines
- [ ] All scripts are executable (`chmod +x`)
- [ ] Changes work with bash 3.2+ (macOS compatible)
- [ ] Backward compatibility maintained
- [ ] Error handling implemented
- [ ] Documentation updated (if needed)
- [ ] Manual testing completed
- [ ] No unnecessary files added (.DS_Store, etc.)
- [ ] Commit messages follow format

## Bug Reports

When reporting bugs, include:

**Environment Information**:
- OS and version (macOS 13.5, Ubuntu 22.04, etc.)
- bash version: `bash --version`
- tmux version: `tmux -V`
- Terminal emulator and version

**Bug Description**:
- What you expected to happen
- What actually happened
- Steps to reproduce
- Error messages (full output)

**Example Bug Report**:
```markdown
**Environment**:
- macOS 14.2
- bash 5.2.15
- tmux 3.3a
- iTerm2 3.4.19

**Description**:
When running `tmux-tools status --show-pid`, column alignment breaks
for window names longer than 15 characters.

**Steps to Reproduce**:
1. Create session with long window name: `tmux rename-window "very-long-window-name-here"`
2. Run: `./tmux-tools status --show-pid`
3. Observe misaligned columns

**Expected**: Columns remain aligned
**Actual**: PID column shifts right

**Error Output**:
[paste output here]
```

## Feature Requests

When proposing features:

1. **Describe the use case**: What problem does this solve?
2. **Provide examples**: Show how it would work
3. **Consider alternatives**: Are there existing solutions?
4. **Assess impact**: Does it affect existing functionality?

**Example Feature Request**:
```markdown
**Feature**: Session filtering by attachment status

**Use Case**:
I manage 20+ tmux sessions across multiple devices. I want to quickly
view only attached sessions to see what's actively running.

**Proposed Usage**:
```bash
tmux-tools status --attached-only
tmux-tools overview --detached-only
```

**Alternatives Considered**:
- Using grep on output (loses formatting)
- Manual filtering (time-consuming)

**Implementation Notes**:
Could filter in get_session_data() using #{session_attached}
```

## Documentation Contributions

Documentation improvements are highly valued:

**Areas needing documentation**:
- Usage examples for specific workflows
- Troubleshooting common issues
- Integration with other tools
- Advanced configuration patterns
- Performance optimization tips

**Documentation Guidelines**:
- Use clear, technical language
- Include code examples with context
- Test all commands before documenting
- Use tables for structured information
- Add ASCII diagrams for complex workflows
- No emojis in documentation

## Code Review Process

Pull requests will be reviewed for:

1. **Functionality**: Does it work as intended?
2. **Code Quality**: Follows style guidelines, well-structured
3. **Compatibility**: Maintains backward compatibility
4. **Error Handling**: Handles edge cases gracefully
5. **Documentation**: Includes necessary documentation updates
6. **Testing**: Evidence of testing provided

**Review Timeline**:
- Initial review within 3-5 business days
- Follow-up responses within 2 business days
- Merge when approved and CI passes

## Questions and Support

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and general discussion
- **Pull Request Comments**: Implementation-specific questions

## License

By contributing to tmux-tools, you agree that your contributions will be licensed under the MIT License.

## Acknowledgments

Contributors will be acknowledged in release notes and documentation. Thank you for helping improve tmux-tools!
