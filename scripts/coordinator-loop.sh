#!/bin/bash
# coordinator-loop.sh
# Sends /check-cycle to the Coordinator's tmux session at regular intervals.
# Only sends when the Coordinator is idle (waiting for input).
#
# Usage: ./scripts/coordinator-loop.sh [interval_in_minutes]
# Default: 15 minutes
#
# Prerequisites: Coordinator must be running in tmux session named "coordinator"

INTERVAL_MINUTES=${1:-15}
INTERVAL_SECONDS=$((INTERVAL_MINUTES * 60))
SESSION_NAME="coordinator"
PAUSE_FILE="/tmp/coordinator-loop-pause"

echo "Coordinator loop started. Interval: ${INTERVAL_MINUTES}m"
echo "Target tmux session: ${SESSION_NAME}"
echo "To pause:  touch $PAUSE_FILE"
echo "To resume: rm $PAUSE_FILE"
echo "Press Ctrl+C to stop."
echo ""

while true; do
  sleep "$INTERVAL_SECONDS"

  # Check if paused
  if [ -f "$PAUSE_FILE" ]; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) PAUSED (${PAUSE_FILE} exists). Skipping."
    continue
  fi

  # Check if the tmux session exists
  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) WARNING: tmux session '${SESSION_NAME}' not found. Waiting..."
    continue
  fi

  # Check if Coordinator is idle (waiting for input)
  # Capture the last line of the tmux pane — if it shows the input prompt, it's idle
  LAST_LINE=$(tmux capture-pane -t "$SESSION_NAME" -p | tail -5 | grep -c '>')

  if [ "$LAST_LINE" -eq 0 ]; then
    echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Coordinator is busy. Skipping this cycle."
    continue
  fi

  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) Coordinator is idle. Sending /check-cycle."
  tmux send-keys -t "$SESSION_NAME" "/check-cycle" Enter
done
