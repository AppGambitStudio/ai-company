#!/bin/bash
# start.sh
# Starts the full AI Company system: Coordinator + auto-loop
#
# Usage: ./scripts/start.sh [loop_interval_in_minutes]
# Default loop interval: 15 minutes

INTERVAL=${1:-15}
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "========================================"
echo "  APPGAMBIT AI Company — Starting Up"
echo "========================================"
echo ""
echo "Management repo: $REPO_DIR"
echo "Loop interval: ${INTERVAL}m"
echo ""

# Check prerequisites
if ! command -v claude &> /dev/null; then
  echo "ERROR: claude CLI not found. Install Claude Code first."
  exit 1
fi

if ! command -v tmux &> /dev/null; then
  echo "ERROR: tmux not found. Install with: brew install tmux"
  exit 1
fi

# Kill existing sessions if running
tmux kill-session -t coordinator 2>/dev/null
tmux kill-session -t coordinator-loop 2>/dev/null

# Check runtime files exist
cd "$REPO_DIR"
for f in CEO_CONFIG.md CEO_INBOX.md coordinator/REGISTRY.md coordinator/DAILY_LOG.md; do
  if [ ! -f "$f" ]; then
    template="${f%.md}.template.md"
    if [ -f "$template" ]; then
      echo "Creating $f from template..."
      cp "$template" "$f"
    else
      echo "WARNING: $f missing and no template found"
    fi
  fi
done

mkdir -p projects
chmod +x scripts/hooks/*.sh

# Start Coordinator in tmux
echo "Starting Coordinator session..."
tmux new-session -d -s coordinator -c "$REPO_DIR" \
  "claude --permission-mode bypassPermissions"

# Wait for Claude to initialize
echo "Waiting for Coordinator to initialize..."
sleep 5

# Send the startup prompt automatically
STARTUP_PROMPT="You are APPGAMBIT AI Coordinator. Read coordinator/CLAUDE.md for your operating manual. Read CEO_CONFIG.md for CEO preferences. Read coordinator/REGISTRY.md to check current state. Begin your startup sequence."
tmux send-keys -t coordinator "$STARTUP_PROMPT" Enter
echo "Startup prompt sent."

sleep 2

# Start the loop in a separate tmux session
echo "Starting auto-loop (${INTERVAL}m interval)..."
tmux new-session -d -s coordinator-loop -c "$REPO_DIR" \
  "./scripts/coordinator-loop.sh $INTERVAL"

echo ""
echo "========================================"
echo "  AI Company is running!"
echo "========================================"
echo ""
echo "  Coordinator:  tmux attach -t coordinator"
echo "  Loop monitor: tmux attach -t coordinator-loop"
echo "  Stop all:     ./scripts/stop.sh"
echo ""
