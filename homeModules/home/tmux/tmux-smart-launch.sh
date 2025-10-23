#!/bin/bash
SESSION_NAME="ghostty"

# Check if the session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  # If the session exists, reattach to it
  tmux attach-session -t $SESSION_NAME
else
  # If the session doesn't exist, start a new one
  tmux new-session -s $SESSION_NAME -d
  tmux attach-session -t $SESSION_NAME
fi

$SHELL
