#!/bin/bash
# coordinator-loop.sh
# Sends /check-cycle to the Coordinator's tmux session at regular intervals.
# This replaces the unreliable /loop command with a reliable external timer.
#
# Usage: ./scripts/coordinator-loop.sh [interval_in_minutes]
# Default: 15 minutes
#
# Prerequisites: Coordinator must be running in tmux session named "coordinator"

INTERVAL_MINUTES=${1:-15}
INTERVAL_SECONDS=$((INTERVAL_MINUTES * 60))
SESSION_NAME="coordinator"

echo "Coordinator loop started. Interval: ${INTERVAL_MINUTES}m"
echo "Target tmux session: ${SESSION_NAME}"
echo "Press Ctrl+C to stop."
echo ""

while true; do
  sleep "$INTERVAL_SECONDS"

  # Check if the tmux session exists
  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) WARNING: tmux session '${SESSION_NAME}' not found. Waiting..."
    continue
  fi

  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Sending /check-cycle to ${SESSION_NAME}"
  tmux send-keys -t "$SESSION_NAME" "/check-cycle" Enter
done
