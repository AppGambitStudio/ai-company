#!/bin/bash
# stop.sh
# Stops the AI Company system: kills Coordinator and loop sessions

echo "Stopping AI Company..."

tmux kill-session -t coordinator-loop 2>/dev/null && echo "Loop stopped." || echo "Loop was not running."
tmux kill-session -t coordinator 2>/dev/null && echo "Coordinator stopped." || echo "Coordinator was not running."

echo "AI Company stopped."
