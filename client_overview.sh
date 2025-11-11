#!/bin/bash

# List tmux clients with SSH connection detection and control mode info

tmux list-clients -F '#{client_tty} #{client_pid} #{client_session} #{client_width}x#{client_height} #{client_control_mode}' | while read tty pid session size control; do
    # Check if parent process is sshd
    parent=$(ps -o comm= -p $(ps -o ppid= -p $pid 2>/dev/null) 2>/dev/null)

    # Build connection type label
    if [[ "$parent" == *"sshd"* ]]; then
        conn="[SSH]"
    else
        conn="[local]"
    fi

    # Check for control mode
    if [[ "$control" == "1" ]] || [[ "$size" == "0x0" ]]; then
        echo "$tty $pid $session $size $conn [control mode]"
    else
        echo "$tty $pid $session $size $conn"
    fi
done
