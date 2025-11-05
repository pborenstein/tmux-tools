# Tmux Command Reference - Experimental Layouts

Alternative ways to organize tmux command references.

## Sessions & Windows - Consolidated by Action

### Navigation

| scope   | action          | key    | tmux command                              |
| :------ | :-------------- | :----- | :---------------------------------------- |
| session | previous        | ^B (   | switch-client -p                          |
| session | next            | ^B )   | switch-client -n                          |
| session | last            | ^B L   | switch-client -l                          |
| window  | previous        | ^B p   | previous-window                           |
| window  | next            | ^B n   | next-window                               |
| window  | last            | ^B l   | last-window                               |

### Create & Select

| scope   | action          | key    | tmux command                              |
| :------ | :-------------- | :----- | :---------------------------------------- |
| session | new             |        | new-session [-s name]                     |
| session | list/choose     | ^B s   | choose-tree -Zs                           |
| session | attach          |        | attach-session [-t target]                |
| window  | new             | ^B c   | new-window                                |
| window  | list/choose     | ^B w   | choose-tree -Zw                           |
| window  | select 0-9      | ^B 0-9 | select-window -t :=N                      |
| window  | select by index | ^B '   | command-prompt -T window-target           |
| window  | find            | ^B f   | find-window -Z                            |

### Rename & Manage

| scope   | action          | key    | tmux command                              |
| :------ | :-------------- | :----- | :---------------------------------------- |
| session | rename          | ^B $   | command-prompt -I "#S" (rename-session)   |
| session | detach          | ^B d   | detach-client                             |
| session | kill            |        | kill-session [-t target]                  |
| window  | rename          | ^B ,   | command-prompt -I "#W" (rename-window)    |
| window  | kill            | ^B &   | confirm-before kill-window                |
| window  | move            | ^B .   | command-prompt -T target (move-window)    |

### Window-Specific Operations

| action          | key    | tmux command                              |
| :-------------- | :----- | :---------------------------------------- |
| split horiz     | ^B "   | split-window                              |
| split vert      | ^B %   | split-window -h                           |
| swap left       |        | swap-window -t :-1                        |
| swap right      |        | swap-window -t :+1                        |

---

## Alternative: Grouped by Scope with Common Actions

### Sessions

| prev   | next   | last   | new  | choose | rename | kill | detach | attach |
| :----- | :----- | :----- | :--- | :----- | :----- | :--- | :----- | :----- |
| ^B (   | ^B )   | ^B L   | —    | ^B s   | ^B $   | —    | ^B d   | —      |

Commands without default keys:
- new: `new-session [-s name]`
- kill: `kill-session [-t target]`
- attach: `attach-session [-t target]`

### Windows

| prev   | next   | last   | new  | choose | rename | kill   | find   | move   | select |
| :----- | :----- | :----- | :--- | :----- | :----- | :----- | :----- | :----- | :----- |
| ^B p   | ^B n   | ^B l   | ^B c | ^B w   | ^B ,   | ^B &   | ^B f   | ^B .   | ^B 0-9 |

Additional window operations:
- select by index: `^B '`
- split horizontal: `^B "`
- split vertical: `^B %`

---

## Alternative: Action-First (Most Common Operations)

| what I want to do        | for session | for window  |
| :----------------------- | :---------- | :---------- |
| go to previous           | ^B (        | ^B p        |
| go to next               | ^B )        | ^B n        |
| go to last used          | ^B L        | ^B l        |
| create new               | new-session | ^B c        |
| see list and choose      | ^B s        | ^B w        |
| rename                   | ^B $        | ^B ,        |
| kill/delete              | kill-session| ^B &        |
| leave/disconnect (detach)| ^B d        | —           |
| reconnect (attach)       | attach-session | —        |
| find by name             | —           | ^B f        |
| move to different position| —          | ^B .        |

---

## Compact Action-First (All Scopes)

| action  | session        | window         | pane           |
| :------ | :------------- | :------------- | :------------- |
| prev    | ^B (           | ^B p           | —              |
| next    | ^B )           | ^B n           | —              |
| last    | ^B L           | ^B l           | ^B ;           |
| new     | new-session    | ^B c           | split-window   |
| choose  | ^B s           | ^B w           | —              |
| select  | —              | ^B 0-9         | ^B ↑↓←→        |
| rename  | ^B $           | ^B ,           | —              |
| kill    | kill-session   | ^B &           | ^B x           |
| detach  | ^B d           | —              | —              |
| attach  | attach-session | —              | —              |
| find    | —              | ^B f           | —              |
| move    | —              | ^B .           | move-pane      |
| swap    | —              | swap-window    | ^B { }         |
| zoom    | —              | —              | ^B z           |
| split ↕ | —              | ^B "           | —              |
| split ↔ | —              | ^B %           | —              |
| display | —              | —              | ^B q           |
| mark    | —              | —              | ^B m           |
| break   | —              | —              | ^B !           |

**Notes:**
- Commands without keys shown as bare commands (e.g., `new-session`, `kill-session`)
- `^B ↑↓←→` means use arrow keys after prefix
- `^B { }` means two separate keys: { for swap up, } for swap down
- Split creates new panes within windows

---

## Notes on Consolidation

The consolidated tables above experiment with different ways to organize commands:

1. **Consolidated by Action**: Groups related operations (navigation, creation, management) together, making it easy to compare session vs window commands for the same action.

2. **Grouped by Scope**: Shows all operations for each scope in a compact horizontal format - good for scanning common operations quickly.

3. **Action-First**: Natural language approach - start with what you want to do, then find the appropriate command for your scope.

Choose the format that best matches your mental model and workflow patterns.
