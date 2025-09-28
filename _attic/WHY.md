# Why This Tool Exists

Tmux sessions accumulate. Default names like "0", "1", "shellfish-1" provide no context. Multiple sessions become indistinguishable. Terminal real estate gets wasted on unhelpful session names.

## Evolution

Started with `original-tmux-status.sh` - hierarchical tree format:

```
🖥  TMUX STATUS Fri Sep 26 19:11:46 EDT 2025
──────────────────────────────────────────────
Session: oslo
  └─ Window 0: elk
      └─ Pane 0 | PID 55066 | fish | /Users/philip/projects/tmux-tools
      └─ Pane 1 | PID 54634 | fish | /Users/philip/projects/tmux-tools
      └─ Pane 2 | PID 55024 | 1.0.123 | /Users/philip/projects/tmux-tools
  └─ Window 1: cat
      └─ Pane 0 | PID 55294 | node | /Users/philip/Obsidian/amoxtli
```

Evolved into `tmux-status.sh` - compact tabular format with smart defaults:

```
session       win  name      p  cmd      w
-------       ---  --------  -  -------  ---
oslo          0    elk       0  fish     142
              0              1  fish
              0              2  1.0.123
              1    cat       0  node
```

Much denser format. Added session/window renaming, client width display, and conditional detail view.

## The Solution

- Compact tabular display that groups sessions visually
- City names for sessions: tokyo, berlin, oslo
- Mammal names for windows: cat, bear, fox
- Client width display (w column) shows terminal dimensions
- Essential info by default, details on demand with --show-pid
- Names only appear once per group (sessions) or window (first pane)
- No number suffixes - just skip to next available name

## Why This Works

**Space efficiency:** Compact layout maximizes screen real estate. Essential columns visible by default.

**Device identification:** Width column reveals connection type - 89 columns typically indicates iPad/mobile, 142+ indicates desktop terminal.

**Smart defaults:** Hide rarely-needed PID and path info unless requested with --show-pid.

**Memorable names:** City/mammal scheme avoids conflicts while providing variety for typical session counts.

## Usage Patterns

```bash
./tmux-status.sh                    # Compact view - essential info only
./tmux-status.sh --show-pid         # Detailed view when debugging needed
./tmux-status.sh --rename-sessions  # Clean slate with city names
./tmux-status.sh --rename-windows   # Organize windows with mammals
```

The tool respects existing manual names. Only transforms the noise. Width column immediately shows which device each session is connected from.

