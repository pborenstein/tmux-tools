# Design Principles

## Core Problem

Tmux sessions accumulate with unhelpful default names. Terminal space is wasted on noise while essential details are hidden.

**Challenge**: Make complex tmux environments comprehensible quickly.

## Solution: Compact Tabular Display

```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              1    cat       0  node
milan         0    mouse     0  fish     89
```

**Benefits**:
- High information density
- Essential details visible at a glance
- Visual grouping through spacing
- Scales to many sessions

## Key Principles

### 1. Space Efficiency

Maximize information density while maintaining readability:
- Compact tables over verbose trees
- Details on demand (`--show-pid`)
- Names shown once per group

### 2. Device Awareness

Width column identifies devices:
- 89 = iPad
- 142+ = desktop
- Attachment indicators show active connections

### 3. Smart Defaults

Show what's needed most often:
- Compact view by default
- Essential info always visible
- Full details available with flags

### 4. Memorable Naming

Natural names scale better than numbers:
- Cities for sessions: tokyo, berlin, oslo
- Mammals for windows: cat, bear, fox
- No number suffixes, advance to next name

### 5. Respectful Enhancement

Enhance without breaking:
- Rename only auto-generated names by default
- Preserve user-assigned names
- Backward compatible

### 6. Visual Grouping

Use spacing to show relationships:
- Session names shown for first window only
- Window names shown for first pane only
- Spacing creates implicit hierarchy

## Design Decisions

| Decision | Rationale |
|----------|-----------|
| Tabular format | Higher information density than trees |
| Column order: session → window → pane → command → width | Hierarchy from general to specific |
| Cities/mammals naming | Natural variety, memorable, pleasant |
| Hide PIDs by default | Show on demand with `--show-pid` |
| Advance names on conflict | No ugly "tokyo-1" suffixes |

## Usage Patterns

**Quick checks**: Compact view, width column for device ID, attachment indicators

**Debugging**: `--show-pid` adds process IDs and paths

**Organization**: Smart rename preserves manual names, only changes auto-generated

**Multi-device**: Width column identifies iPad (89) vs desktop (142+)