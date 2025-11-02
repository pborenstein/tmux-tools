# Design Principles

## Overview

This document outlines the design philosophy and principles that guide tmux-tools development. These principles emerged from real-world usage patterns and the evolution from basic session listing to comprehensive session management.

## Core Problem Statement

Tmux sessions accumulate over time. Default names like "0", "1", or "shellfish-1" provide no meaningful context. Multiple sessions become indistinguishable blobs in session lists. Terminal real estate gets wasted on unhelpful information, while essential details remain hidden.

The core challenge: **How do you make sense of complex tmux environments quickly and efficiently?**

## Evolution of the Solution

### Original Approach: Hierarchical Tree Display

The initial implementation used a hierarchical tree format that emphasized structure:

```
TMUX STATUS Fri Sep 26 19:11:46 EDT 2025
----------------------------------------------
Session: oslo
    Window 0: elk
        Pane 0 | PID 55066 | fish | /Users/philip/projects/tmux-tools
        Pane 1 | PID 54634 | fish | /Users/philip/projects/tmux-tools
        Pane 2 | PID 55024 | 1.0.123 | /Users/philip/projects/tmux-tools
    Window 1: cat
        Pane 0 | PID 55294 | node | /Users/philip/Obsidian/amoxtli
```

**Limitations Identified**:
- Verbose structure consumed too much vertical space
- Visual noise from repeated hierarchy markers
- Essential information buried in verbose display
- Poor density ratio (information per screen line)

### Current Approach: Compact Tabular Display

Evolution to a compact tabular format prioritizing information density:

```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              0              2  1.0.123
              1    cat       0  node
```

**Advantages Achieved**:
- Maximum information density per screen line
- Essential details visible at a glance
- Visual grouping without excessive markup
- Scalable to many sessions without overwhelming display

## Design Principles

### 1. Space Efficiency

**Principle**: Maximize information density per screen line while maintaining readability.

**Implementation**:
- Compact tabular layout over verbose tree structures
- Essential columns visible by default
- Detailed information available on demand (`--show-pid`)
- Names displayed only once per logical group

**Rationale**: Terminal real estate is precious. Users need to scan many sessions quickly. Dense layouts enable rapid pattern recognition and status assessment.

### 2. Device Awareness

**Principle**: Provide contextual information that reveals the physical environment.

**Implementation**:
- Client width column (w) shows terminal dimensions
- Width patterns indicate device types (89 = iPad, 142+ = desktop)
- Attachment indicators show active connections
- Multi-client scenarios clearly distinguished

**Rationale**: Modern tmux usage spans multiple devices. Understanding which sessions are on which devices is crucial for workflow management. The width column provides immediate device identification without additional commands.

### 3. Smart Defaults

**Principle**: Show what users need most often, hide complexity until requested.

**Implementation**:
- Compact view by default, detailed view available (`--show-pid`)
- Essential information (session, window, pane, command) always visible
- Secondary information (PID, full paths) available on demand
- Reasonable column widths for typical use cases

**Rationale**: Most tmux monitoring involves quick status checks. Detailed debugging information should be available but not clutter the default experience. Progressive disclosure enables both quick checks and deep investigation.

### 4. Memorable Naming

**Principle**: Use natural, conflict-resistant naming schemes that scale gracefully.

**Implementation**:
- City names for sessions: tokyo, berlin, oslo, paris
- Mammal names for windows: cat, bear, fox, lion
- No number suffixes - skip to next available name
- Conflict resolution through name advancement, not numbering

**Rationale**: Human memory works better with meaningful names than numbers. The city/mammal scheme provides enough variety for typical session counts while avoiding the cognitive load of remembering arbitrary identifiers. Natural conflict resolution maintains the naming scheme's integrity.

### 5. Respectful Enhancement

**Principle**: Improve existing workflows without breaking them.

**Implementation**:
- Rename only default/auto-generated session names by default
- Preserve user-assigned names unless explicitly requested
- Backward compatibility with original script interfaces
- Optional configuration system doesn't require adoption

**Rationale**: Users invest mental energy in organizing their tmux environments. Aggressive renaming destroys this investment. The tool should enhance organization where it's missing, not replace existing organization.

### 6. Visual Grouping

**Principle**: Use visual patterns to convey logical relationships efficiently.

**Implementation**:
- Session names shown only for first window
- Window names shown only for first pane
- Consistent spacing creates implicit grouping
- Attachment indicators provide status at a glance

**Rationale**: Repeated labels create visual noise without adding information. Strategic repetition and spacing allow users to quickly identify group boundaries and relationships without explicit hierarchical markup.

## Usage Pattern Analysis

### Quick Status Checks

**User Need**: "What tmux sessions are running and where?"

**Design Response**:
- Default compact view shows essential information in minimal space
- Width column immediately identifies device connections
- Attachment indicators show current activity status
- Fast scanning enabled by consistent column alignment

### Debugging and Investigation

**User Need**: "What's running in that pane and where is it located?"

**Design Response**:
- `--show-pid` reveals process IDs and full paths
- Detailed view maintains same layout structure for consistency
- Additional columns align with compact view for easy comparison
- Error diagnosis enabled by complete process information

### Session Organization

**User Need**: "Clean up session names and organize windows"

**Design Response**:
- Smart renaming that preserves manual names
- Conflict-free naming scheme that scales naturally
- Granular control over renaming scope (sessions vs windows)
- Immediate visual feedback on renaming results

### Multi-device Workflows

**User Need**: "Which sessions are on my laptop vs iPad?"

**Design Response**:
- Client width column provides immediate device identification
- Attachment status shows active connections
- Multiple client indicators for shared sessions
- Device-specific workflow optimization enabled

## Technical Design Decisions

### Display Format Choice

**Decision**: Tabular format over tree structure
**Rationale**: Higher information density, better scanning efficiency, cleaner visual grouping

### Column Selection and Order

**Decision**: session, window, name, pane, command, width
**Rationale**: Logical hierarchy from general (session) to specific (pane), essential information first, device context last

### Naming Scheme Selection

**Decision**: Cities for sessions, mammals for windows
**Rationale**: Natural variety, easy to remember, sufficient scale for typical usage, pleasant associations

### Default Information Level

**Decision**: Hide PIDs and full paths by default
**Rationale**: Essential for quick checks, available when needed, prevents information overload

### Conflict Resolution Strategy

**Decision**: Advance to next available name, no number suffixes
**Rationale**: Maintains naming scheme integrity, avoids ugly "tokyo-1" patterns, graceful scaling

## Anti-patterns Avoided

### Information Overload

**Avoided**: Showing all available information by default
**Why**: Overwhelms users during routine status checks, reduces scanning efficiency

### Aggressive Renaming

**Avoided**: Renaming all sessions and windows automatically
**Why**: Destroys user investment in existing organization, creates confusion

### Complex Configuration Requirements

**Avoided**: Requiring configuration file for basic functionality
**Why**: Creates adoption barriers, complicates simple use cases

### Rigid Display Formats

**Avoided**: Single display mode for all use cases
**Why**: Different tasks require different information levels, flexibility enables workflow optimization

### Inconsistent Visual Language

**Avoided**: Different formatting patterns between similar operations
**Why**: Increases cognitive load, reduces muscle memory effectiveness

## Success Metrics

### Usability Success

- **Fast Recognition**: Users can identify relevant sessions within 2-3 seconds
- **Efficient Scanning**: Multiple sessions can be evaluated quickly
- **Clear Context**: Device and connection status immediately apparent
- **Workflow Integration**: Tool enhances rather than disrupts existing practices

### Technical Success

- **Performance**: Handles 20+ sessions without noticeable delay
- **Reliability**: Graceful handling of edge cases and errors
- **Compatibility**: Works across tmux versions and terminal types
- **Maintainability**: Clear code structure enables easy enhancement

### Adoption Success

- **Backward Compatibility**: Existing users can migrate without workflow changes
- **Progressive Enhancement**: New features add value without complexity
- **Documentation Clarity**: Users understand capabilities and limitations
- **Community Feedback**: Design decisions validated by real-world usage

## Future Considerations

### Scalability

As tmux usage patterns evolve, the design must accommodate:
- Higher session counts (50+ sessions)
- More complex multi-device scenarios
- Integration with modern development workflows
- Support for different terminal sizes and capabilities

### Accessibility

Design evolution should consider:
- Color-blind accessibility through themes
- Screen reader compatibility
- High-contrast display options
- Motor accessibility for navigation features

### Integration

Future enhancements should maintain:
- Shell integration patterns
- Package manager compatibility
- Configuration system flexibility
- API stability for automation

## Conclusion

These design principles emerge from practical tmux usage and prioritize real-world workflow efficiency over theoretical completeness. The compact tabular display, intelligent naming, and progressive disclosure combine to create a tool that enhances tmux productivity without imposing new complexity.

The principles guide decision-making by establishing clear priorities: space efficiency, device awareness, smart defaults, memorable naming, respectful enhancement, and visual grouping. These principles ensure that new features align with the tool's core mission of making complex tmux environments comprehensible and manageable.

Success comes from understanding that tmux users have developed workflows and mental models around their session organization. The tool's role is to surface hidden information, provide better defaults where none exist, and optimize display efficiency--all while preserving the investment users have made in their existing organization.

---

*Design Principles Version: 1.0*
*Last Updated: September 27, 2025*
*Evolution: From hierarchical to tabular display*