#!/bin/bash

# Pretty-print tmux hierarchy with session > window > pane
# Shows pane PID and running command

echo "🖥  TMUX STATUS $(date)"
echo "──────────────────────────────────────────────"

tmux list-sessions -F '#{session_name}' | while read -r session; do
  echo "Session: $session"

  tmux list-windows -t "$session" -F '#{window_index}:#{window_name}' | while IFS=: read -r win_index win_name; do
    echo "  └─ Window $win_index: $win_name"

    tmux list-panes -t "$session:$win_index" -F '#{pane_index} #{pane_pid} #{pane_current_command} #{pane_current_path}' | while read -r pane_index pid cmd path; do
      echo "      └─ Pane $pane_index | PID $pid | $cmd | $path"
    done
  done
done