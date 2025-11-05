# Tmux Command Reference Tables

Quick reference tables for common tmux operations organized by scope.

## Sessions

| action          | key    | tmux command                              |
| :-------------- | :----- | :---------------------------------------- |
| previous        | ^B (   | switch-client -p                          |
| next            | ^B )   | switch-client -n                          |
| last            | ^B L   | switch-client -l                          |
| new             |        | new-session [-s name]                     |
| list/choose     | ^B s   | choose-tree -Zs                           |
| rename          | ^B $   | command-prompt -I "#S" (rename-session)   |
| detach          | ^B d   | detach-client                             |
| kill            |        | kill-session [-t target]                  |
| attach          |        | attach-session [-t target]                |

## Windows

| action          | key    | tmux command                              |
| :-------------- | :----- | :---------------------------------------- |
| previous        | ^B p   | previous-window                           |
| next            | ^B n   | next-window                               |
| last            | ^B l   | last-window                               |
| new             | ^B c   | new-window                                |
| list/choose     | ^B w   | choose-tree -Zw                           |
| select 0-9      | ^B 0-9 | select-window -t :=N                      |
| select by index | ^B '   | command-prompt -T window-target           |
| rename          | ^B ,   | command-prompt -I "#W" (rename-window)    |
| find            | ^B f   | find-window -Z                            |
| move            | ^B .   | command-prompt -T target (move-window)    |
| kill            | ^B &   | confirm-before kill-window                |
| split horiz     | ^B "   | split-window                              |
| split vert      | ^B %   | split-window -h                           |
| swap left       |        | swap-window -t :-1                        |
| swap right      |        | swap-window -t :+1                        |

## Panes

| action              | key          | tmux command                          |
| :------------------ | :----------- | :------------------------------------ |
| select up           | ^B ↑︎         | select-pane -U                        |
| select down         | ^B ↓︎         | select-pane -D                        |
| select left         | ^B ←︎         | select-pane -L                        |
| select right        | ^B →︎         | select-pane -R                        |
| select next         | ^B o         | select-pane -t :.+                    |
| last                | ^B ;         | last-pane                             |
| display numbers     | ^B q         | display-panes                         |
| mark                | ^B m         | select-pane -m                        |
| mark (toggle mode)  | ^B M         | select-pane -M                        |
| break (to window)   | ^B !         | break-pane                            |
| kill                | ^B x         | confirm-before kill-pane              |
| zoom toggle         | ^B z         | resize-pane -Z                        |
| swap up             | ^B {         | swap-pane -U                          |
| swap down           | ^B }         | swap-pane -D                          |
| rotate forward      | ^B ^O        | rotate-window                         |
| rotate backward     | ^B M-o       | rotate-window -D                      |
| resize up           | ^B M-↑︎       | resize-pane -U 5                      |
| resize down         | ^B M-↓︎       | resize-pane -D 5                      |
| resize left         | ^B M-←︎       | resize-pane -L 5                      |
| resize right        | ^B M-→︎       | resize-pane -R 5                      |
| resize up (1 line)  | ^B ^↑︎        | resize-pane -U                        |
| resize down (1 line)| ^B ^↓︎        | resize-pane -D                        |
| resize left (1 col) | ^B ^←︎        | resize-pane -L                        |
| resize right (1 col)| ^B ^→︎        | resize-pane -R                        |
| join from window    |              | join-pane [-s src] [-t dst]           |
| move to window      |              | move-pane [-s src] [-t dst]           |

## Layouts

| action              | key      | tmux command                          |
| :------------------ | :------- | :------------------------------------ |
| next layout         | ^B Space | next-layout                           |
| previous layout     | ^B ^Space| previous-layout                       |
| even horizontal     | ^B M-1   | select-layout even-horizontal         |
| even vertical       | ^B M-2   | select-layout even-vertical           |
| main horizontal     | ^B M-3   | select-layout main-horizontal         |
| main vertical       | ^B M-4   | select-layout main-vertical           |
| tiled               | ^B M-5   | select-layout tiled                   |
| main horiz mirrored | ^B M-6   | select-layout main-horizontal-mirrored|
| main vert mirrored  | ^B M-7   | select-layout main-vertical-mirrored  |

## Copy Mode

| action              | key      | tmux command                          |
| :------------------ | :------- | :------------------------------------ |
| enter copy mode     | ^B [     | copy-mode                             |
| paste buffer        | ^B ]     | paste-buffer -p                       |
| list buffers        | ^B #     | list-buffers                          |
| choose buffer       | ^B =     | choose-buffer -Z                      |
| delete buffer       | ^B -     | delete-buffer                         |

## Miscellaneous

| action              | key      | tmux command                          |
| :------------------ | :------- | :------------------------------------ |
| command prompt      | ^B :     | command-prompt                        |
| show key bindings   | ^B ?     | list-keys -N                          |
| list keys (search)  | ^B /     | command-prompt -k -p key (list-keys)  |
| info                | ^B i     | display-message                       |
| show messages       | ^B ~     | show-messages                         |
| clock               | ^B t     | clock-mode                            |
| refresh             | ^B r     | refresh-client                        |
| customize mode      | ^B C     | customize-mode -Z                     |
| choose client       | ^B D     | choose-client -Z                      |
| suspend client      | ^B ^Z    | suspend-client                        |
| send prefix         | ^B ^B    | send-prefix                           |

## Notes

- `^B` represents the default prefix key (Ctrl-B)
- Some commands don't have default key bindings and must be typed at the command prompt (^B :)
- Arrow keys are represented as: ↑︎ ↓︎ ←︎ →︎
- `M-` prefix means Meta/Alt key
- `-r` flag on bind-key means the key is repeatable
- Commands in parentheses in the "tmux command" column indicate the command is triggered via command-prompt
