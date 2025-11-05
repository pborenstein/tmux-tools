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

## V2: Swapped Columns + Bookend Actions

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
| prev    | ^B p           | ^B (           | —              | prev    |
| next    | ^B n           | ^B )           | —              | next    |
| last    | ^B l           | ^B L           | ^B ;           | last    |
| new     | ^B c           | new-session    | split-window   | new     |
| choose  | ^B w           | ^B s           | —              | choose  |
| select  | ^B 0-9         | —              | ^B ↑↓←→        | select  |
| rename  | ^B ,           | ^B $           | —              | rename  |
| kill    | ^B &           | kill-session   | ^B x           | kill    |
| detach  | —              | ^B d           | —              | detach  |
| attach  | —              | attach-session | —              | attach  |
| find    | ^B f           | —              | —              | find    |
| move    | ^B .           | —              | move-pane      | move    |
| swap    | swap-window    | —              | ^B { }         | swap    |
| zoom    | —              | —              | ^B z           | zoom    |
| split ↕ | ^B "           | —              | —              | split ↕ |
| split ↔ | ^B %           | —              | —              | split ↔ |
| display | —              | —              | ^B q           | display |
| mark    | —              | —              | ^B m           | mark    |
| break   | —              | —              | ^B !           | break   |

---

## V3: Action in the Middle

| window         | session        | action  | pane           |
| :------------- | :------------- | :------ | :------------- |
| ^B p           | ^B (           | prev    | —              |
| ^B n           | ^B )           | next    | —              |
| ^B l           | ^B L           | last    | ^B ;           |
| ^B c           | new-session    | new     | split-window   |
| ^B w           | ^B s           | choose  | —              |
| ^B 0-9         | —              | select  | ^B ↑↓←→        |
| ^B ,           | ^B $           | rename  | —              |
| ^B &           | kill-session   | kill    | ^B x           |
| —              | ^B d           | detach  | —              |
| —              | attach-session | attach  | —              |
| ^B f           | —              | find    | —              |
| ^B .           | —              | move    | move-pane      |
| swap-window    | —              | swap    | ^B { }         |
| —              | —              | zoom    | ^B z           |
| ^B "           | —              | split ↕ | —              |
| ^B %           | —              | split ↔ | —              |
| —              | —              | display | ^B q           |
| —              | —              | mark    | ^B m           |
| —              | —              | break   | ^B !           |

---

## V4: Grouped by Action Type (with spacing)

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
| **NAVIGATE** |            |                |                | |
| prev    | ^B p           | ^B (           | —              | prev    |
| next    | ^B n           | ^B )           | —              | next    |
| last    | ^B l           | ^B L           | ^B ;           | last    |
|         |                |                |                |         |
| **CREATE** |             |                |                | |
| new     | ^B c           | new-session    | split-window   | new     |
| split ↕ | ^B "           | —              | —              | split ↕ |
| split ↔ | ^B %           | —              | —              | split ↔ |
|         |                |                |                |         |
| **MANAGE** |             |                |                | |
| choose  | ^B w           | ^B s           | —              | choose  |
| select  | ^B 0-9         | —              | ^B ↑↓←→        | select  |
| rename  | ^B ,           | ^B $           | —              | rename  |
| find    | ^B f           | —              | —              | find    |
| display | —              | —              | ^B q           | display |
|         |                |                |                |         |
| **ARRANGE** |            |                |                | |
| move    | ^B .           | —              | move-pane      | move    |
| swap    | swap-window    | —              | ^B { }         | swap    |
| zoom    | —              | —              | ^B z           | zoom    |
| break   | —              | —              | ^B !           | break   |
| mark    | —              | —              | ^B m           | mark    |
|         |                |                |                |         |
| **DELETE** |             |                |                | |
| kill    | ^B &           | kill-session   | ^B x           | kill    |
|         |                |                |                |         |
| **SESSION** |            |                |                | |
| attach  | —              | attach-session | —              | attach  |
| detach  | —              | ^B d           | —              | detach  |

---

## V5: Minimal (Most Common Only)

| action | window | session     | pane    | action |
| :----- | :----- | :---------- | :------ | :----- |
|        |        |             |         |        |
| prev   | ^B p   | ^B (        | —       | prev   |
| next   | ^B n   | ^B )        | —       | next   |
| last   | ^B l   | ^B L        | ^B ;    | last   |
|        |        |             |         |        |
| new    | ^B c   | new-session | ^B " %  | new    |
| choose | ^B w   | ^B s        | —       | choose |
| rename | ^B ,   | ^B $        | —       | rename |
| kill   | ^B &   | kill-session| ^B x    | kill   |
|        |        |             |         |        |
| detach | —      | ^B d        | —       | detach |

---

## V6: Super Compact (One-Letter Actions)

| ⚡ | win      | ses          | pane     | ⚡ |
| :- | :------- | :----------- | :------- | :- |
| ← | ^B p     | ^B (         | —        | ← |
| → | ^B n     | ^B )         | —        | → |
| ↩ | ^B l     | ^B L         | ^B ;     | ↩ |
|   |          |              |          |   |
| + | ^B c     | new-session  | ^B " %   | + |
| ⋮ | ^B w     | ^B s         | ^B q     | ⋮ |
| ✏ | ^B ,     | ^B $         | —        | ✏ |
| ✕ | ^B &     | kill-session | ^B x     | ✕ |
|   |          |              |          |   |
| ⚲ | —        | ^B d         | —        | ⚲ |

**Legend:** ← prev | → next | ↩ last | + new | ⋮ choose | ✏ rename | ✕ kill | ⚲ detach

---

## V7: Frequency-Based (Most Used First)

| 🔥 | action | window | session      | pane    | action | 🔥 |
| :- | :----- | :----- | :----------- | :------ | :----- | :- |
| 🌟 | new    | ^B c   | new-session  | ^B " %  | new    | 🌟 |
| 🌟 | next   | ^B n   | ^B )         | —       | next   | 🌟 |
| 🌟 | prev   | ^B p   | ^B (         | —       | prev   | 🌟 |
| 🌟 | choose | ^B w   | ^B s         | —       | choose | 🌟 |
|    |        |        |              |         |        |    |
| ⭐ | last   | ^B l   | ^B L         | ^B ;    | last   | ⭐ |
| ⭐ | kill   | ^B &   | kill-session | ^B x    | kill   | ⭐ |
| ⭐ | rename | ^B ,   | ^B $         | —       | rename | ⭐ |
| ⭐ | detach | —      | ^B d         | —       | detach | ⭐ |
|    |        |        |              |         |        |    |
|    | select | ^B 0-9 | —            | ^B ↑↓←→ | select |    |
|    | find   | ^B f   | —            | —       | find   |    |
|    | zoom   | —      | —            | ^B z    | zoom   |    |
|    | swap   | swap-w | —            | ^B { }  | swap   |    |

---

## V8: Vertical Scan (Scopes as Rows)

| scope   | prev   | next   | last   | new     | choose | select  | rename | kill    |
| :------ | :----- | :----- | :----- | :------ | :----- | :------ | :----- | :------ |
| window  | ^B p   | ^B n   | ^B l   | ^B c    | ^B w   | ^B 0-9  | ^B ,   | ^B &    |
| session | ^B (   | ^B )   | ^B L   | new-ses | ^B s   | —       | ^B $   | kill-se |
| pane    | —      | —      | ^B ;   | ^B " %  | —      | ^B ↑↓←→ | —      | ^B x    |

| scope   | detach | attach  | find   | move   | swap   | zoom   | display | mark   | break  |
| :------ | :----- | :------ | :----- | :----- | :----- | :----- | :------ | :----- | :----- |
| window  | —      | —       | ^B f   | ^B .   | swap-w | —      | —       | —      | —      |
| session | ^B d   | attach  | —      | —      | —      | —      | —       | —      | —      |
| pane    | —      | —       | —      | move-p | ^B { } | ^B z   | ^B q    | ^B m   | ^B !   |

---

## V9: Two-Column Split (Core vs Advanced)

### Core Operations

| action | window | session      | pane   | action |
| :----- | :----- | :----------- | :----- | :----- |
| prev   | ^B p   | ^B (         | —      | prev   |
| next   | ^B n   | ^B )         | —      | next   |
| last   | ^B l   | ^B L         | ^B ;   | last   |
|        |        |              |        |        |
| new    | ^B c   | new-session  | ^B " % | new    |
| select | ^B 0-9 | —            | ^B ↑↓←→| select |
| kill   | ^B &   | kill-session | ^B x   | kill   |

### Advanced Operations

| action  | window      | session        | pane      | action  |
| :------ | :---------- | :------------- | :-------- | :------ |
| choose  | ^B w        | ^B s           | —         | choose  |
| rename  | ^B ,        | ^B $           | —         | rename  |
| find    | ^B f        | —              | —         | find    |
|         |             |                |           |         |
| move    | ^B .        | —              | move-pane | move    |
| swap    | swap-window | —              | ^B { }    | swap    |
| zoom    | —           | —              | ^B z      | zoom    |
| display | —           | —              | ^B q      | display |
| mark    | —           | —              | ^B m      | mark    |
| break   | —           | —              | ^B !      | break   |
|         |             |                |           |         |
| attach  | —           | attach-session | —         | attach  |
| detach  | —           | ^B d           | —         | detach  |

---

## V10: Color-Coded by Scope (Text-Based)

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
|         | **[WINDOW]**   | **[SESSION]**  | **[PANE]**     |         |
| prev    | ^B p           | ^B (           | —              | prev    |
| next    | ^B n           | ^B )           | —              | next    |
| last    | ^B l           | ^B L           | ^B ;           | last    |
|         |                |                |                |         |
| new     | ^B c           | new-session    | split-window   | new     |
| choose  | ^B w           | ^B s           | —              | choose  |
| select  | ^B 0-9         | —              | ^B ↑↓←→        | select  |
|         |                |                |                |         |
| rename  | ^B ,           | ^B $           | —              | rename  |
| kill    | ^B &           | kill-session   | ^B x           | kill    |
|         |                |                |                |         |
| find    | ^B f           | —              | —              | find    |
| move    | ^B .           | —              | move-pane      | move    |
| swap    | swap-window    | —              | ^B { }         | swap    |
|         |                |                |                |         |
| zoom    | —              | —              | ^B z           | zoom    |
| display | —              | —              | ^B q           | display |
| mark    | —              | —              | ^B m           | mark    |
| break   | —              | —              | ^B !           | break   |
|         |                |                |                |         |
| detach  | —              | ^B d           | —              | detach  |
| attach  | —              | attach-session | —              | attach  |

---

## V11: Grouped with Commands (Inline)

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
| **NAVIGATE** |            |                |                | |
| prev    | ^B p<br>previous-window | ^B (<br>switch-client -p | — | prev |
| next    | ^B n<br>next-window | ^B )<br>switch-client -n | — | next |
| last    | ^B l<br>last-window | ^B L<br>switch-client -l | ^B ;<br>last-pane | last |
|         |                |                |                |         |
| **CREATE** |             |                |                | |
| new     | ^B c<br>new-window | new-session | split-window | new |
| split ↕ | ^B "<br>split-window | — | — | split ↕ |
| split ↔ | ^B %<br>split-window -h | — | — | split ↔ |
|         |                |                |                |         |
| **MANAGE** |             |                |                | |
| choose  | ^B w<br>choose-tree -Zw | ^B s<br>choose-tree -Zs | — | choose |
| select  | ^B 0-9<br>select-window -t :=N | — | ^B ↑↓←→<br>select-pane | select |
| rename  | ^B ,<br>rename-window | ^B $<br>rename-session | — | rename |
| find    | ^B f<br>find-window -Z | — | — | find |
| display | — | — | ^B q<br>display-panes | display |
|         |                |                |                |         |
| **ARRANGE** |            |                |                | |
| move    | ^B .<br>move-window | — | move-pane | move |
| swap    | swap-window | — | ^B { }<br>swap-pane -U/-D | swap |
| zoom    | — | — | ^B z<br>resize-pane -Z | zoom |
| break   | — | — | ^B !<br>break-pane | break |
| mark    | — | — | ^B m<br>select-pane -m | mark |
|         |                |                |                |         |
| **DELETE** |             |                |                | |
| kill    | ^B &<br>kill-window | kill-session | ^B x<br>kill-pane | kill |
|         |                |                |                |         |
| **SESSION** |            |                |                | |
| attach  | — | attach-session | — | attach |
| detach  | — | ^B d<br>detach-client | — | detach |

---

## V12: Grouped with Commands (Parenthetical)

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
| **NAVIGATE** |            |                |                | |
| prev    | ^B p (previous-window) | ^B ( (switch-client -p) | — | prev |
| next    | ^B n (next-window) | ^B ) (switch-client -n) | — | next |
| last    | ^B l (last-window) | ^B L (switch-client -l) | ^B ; (last-pane) | last |
|         |                |                |                |         |
| **CREATE** |             |                |                | |
| new     | ^B c (new-window) | new-session | split-window | new |
| split ↕ | ^B " (split-window) | — | — | split ↕ |
| split ↔ | ^B % (split-window -h) | — | — | split ↔ |
|         |                |                |                |         |
| **MANAGE** |             |                |                | |
| choose  | ^B w (choose-tree -Zw) | ^B s (choose-tree -Zs) | — | choose |
| select  | ^B 0-9 (select-window) | — | ^B ↑↓←→ (select-pane) | select |
| rename  | ^B , (rename-window) | ^B $ (rename-session) | — | rename |
| find    | ^B f (find-window) | — | — | find |
| display | — | — | ^B q (display-panes) | display |
|         |                |                |                |         |
| **ARRANGE** |            |                |                | |
| move    | ^B . (move-window) | — | move-pane | move |
| swap    | swap-window | — | ^B { } (swap-pane) | swap |
| zoom    | — | — | ^B z (resize-pane -Z) | zoom |
| break   | — | — | ^B ! (break-pane) | break |
| mark    | — | — | ^B m (select-pane -m) | mark |
|         |                |                |                |         |
| **DELETE** |             |                |                | |
| kill    | ^B & (kill-window) | kill-session | ^B x (kill-pane) | kill |
|         |                |                |                |         |
| **SESSION** |            |                |                | |
| attach  | — | attach-session | — | attach |
| detach  | — | ^B d (detach-client) | — | detach |

---

## V13: Grouped - Key/Command Split Columns

| action  | win key | win cmd         | ses key | ses cmd         | pane key  | pane cmd       | action  |
| :------ | :------ | :-------------- | :------ | :-------------- | :-------- | :------------- | :------ |
| **NAVIGATE** |     |                 |         |                 |           |                | |
| prev    | ^B p    | previous-window | ^B (    | switch-client -p| —         | —              | prev    |
| next    | ^B n    | next-window     | ^B )    | switch-client -n| —         | —              | next    |
| last    | ^B l    | last-window     | ^B L    | switch-client -l| ^B ;      | last-pane      | last    |
|         |         |                 |         |                 |           |                |         |
| **CREATE** |      |                 |         |                 |           |                | |
| new     | ^B c    | new-window      | —       | new-session     | ^B " %    | split-window   | new     |
| split ↕ | ^B "    | split-window    | —       | —               | —         | —              | split ↕ |
| split ↔ | ^B %    | split-window -h | —       | —               | —         | —              | split ↔ |
|         |         |                 |         |                 |           |                |         |
| **MANAGE** |      |                 |         |                 |           |                | |
| choose  | ^B w    | choose-tree -Zw | ^B s    | choose-tree -Zs | —         | —              | choose  |
| select  | ^B 0-9  | select-window   | —       | —               | ^B ↑↓←→   | select-pane    | select  |
| rename  | ^B ,    | rename-window   | ^B $    | rename-session  | —         | —              | rename  |
| find    | ^B f    | find-window     | —       | —               | —         | —              | find    |
| display | —       | —               | —       | —               | ^B q      | display-panes  | display |
|         |         |                 |         |                 |           |                |         |
| **ARRANGE** |     |                 |         |                 |           |                | |
| move    | ^B .    | move-window     | —       | —               | —         | move-pane      | move    |
| swap    | —       | swap-window     | —       | —               | ^B { }    | swap-pane      | swap    |
| zoom    | —       | —               | —       | —               | ^B z      | resize-pane -Z | zoom    |
| break   | —       | —               | —       | —               | ^B !      | break-pane     | break   |
| mark    | —       | —               | —       | —               | ^B m      | select-pane -m | mark    |
|         |         |                 |         |                 |           |                |         |
| **DELETE** |      |                 |         |                 |           |                | |
| kill    | ^B &    | kill-window     | —       | kill-session    | ^B x      | kill-pane      | kill    |
|         |         |                 |         |                 |           |                |         |
| **SESSION** |     |                 |         |                 |           |                | |
| attach  | —       | —               | —       | attach-session  | —         | —              | attach  |
| detach  | —       | —               | ^B d    | detach-client   | —         | —              | detach  |

---

## V14: Grouped - Compact Notation (key→cmd)

| action  | window         | session        | pane           | action  |
| :------ | :------------- | :------------- | :------------- | :------ |
| **NAVIGATE** |            |                |                | |
| prev    | ^B p → previous-window | ^B ( → switch-client -p | — | prev |
| next    | ^B n → next-window | ^B ) → switch-client -n | — | next |
| last    | ^B l → last-window | ^B L → switch-client -l | ^B ; → last-pane | last |
|         |                |                |                |         |
| **CREATE** |             |                |                | |
| new     | ^B c → new-window | new-session | split-window | new |
| split ↕ | ^B " → split-window | — | — | split ↕ |
| split ↔ | ^B % → split-window -h | — | — | split ↔ |
|         |                |                |                |         |
| **MANAGE** |             |                |                | |
| choose  | ^B w → choose-tree -Zw | ^B s → choose-tree -Zs | — | choose |
| select  | ^B 0-9 → select-window | — | ^B ↑↓←→ → select-pane | select |
| rename  | ^B , → rename-window | ^B $ → rename-session | — | rename |
| find    | ^B f → find-window | — | — | find |
| display | — | — | ^B q → display-panes | display |
|         |                |                |                |         |
| **ARRANGE** |            |                |                | |
| move    | ^B . → move-window | — | move-pane | move |
| swap    | swap-window | — | ^B { } → swap-pane | swap |
| zoom    | — | — | ^B z → resize-pane -Z | zoom |
| break   | — | — | ^B ! → break-pane | break |
| mark    | — | — | ^B m → select-pane -m | mark |
|         |                |                |                |         |
| **DELETE** |             |                |                | |
| kill    | ^B & → kill-window | kill-session | ^B x → kill-pane | kill |
|         |                |                |                |         |
| **SESSION** |            |                |                | |
| attach  | — | attach-session | — | attach |
| detach  | — | ^B d → detach-client | — | detach |

---

## Notes on Consolidation

The consolidated tables above experiment with different ways to organize commands:

1. **Consolidated by Action**: Groups related operations (navigation, creation, management) together, making it easy to compare session vs window commands for the same action.

2. **Grouped by Scope**: Shows all operations for each scope in a compact horizontal format - good for scanning common operations quickly.

3. **Action-First**: Natural language approach - start with what you want to do, then find the appropriate command for your scope.

Choose the format that best matches your mental model and workflow patterns.
