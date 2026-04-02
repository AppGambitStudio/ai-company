# APPGAMBIT AI Company — Setup Guide

> Fresh setup on a single machine with one Claude account running Coordinator + Employee 1.

---

## Prerequisites

- macOS or Linux
- Claude Code CLI v2.1.72+ (`claude --version`)
- Authenticated Claude account (`claude` should open a session without errors)
- `jq` installed (`brew install jq` on macOS)
- `git` configured with push access to your repos
- `tmux` or `screen` for persistent terminal sessions

---

## Step 1: Clone the Management Repo

```bash
# If starting fresh (you haven't cloned yet)
git clone git@github.com:appgambit/ai-company.git
cd ai-company

# If you already have it
cd /Users/dhaval/Documents/work/antigravity/ai-company
git pull
```

---

## Step 2: Initialize Runtime Files

The spec files, CLAUDE.md operating manuals, and hook scripts are already in the repo. But the runtime files (CEO_INBOX.md, REGISTRY.md, DAILY_LOG.md) need to be created on first run.

```bash
# Create CEO_INBOX.md
cat > CEO_INBOX.md << 'EOF'
# CEO Inbox

Communication from APPGAMBIT AI (Coordinator) to CEO. Append-only.

---
EOF

# Create REGISTRY.md
cat > coordinator/REGISTRY.md << 'EOF'
# Company Registry

Last updated: (not yet started)

## Rotation
Next check index: 0
Last checked: (none)

## Workers

### Employee 1 (Account 1 — shared with Coordinator)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|------------|
| 1 | — | AVAILABLE | — | — |
| 2 | — | AVAILABLE | — | — |
| 3 | — | AVAILABLE | — | — |

## Project Priority (ordered)
(no projects yet)

## Queue (unassigned)
(empty)
EOF

# Create DAILY_LOG.md
cat > coordinator/DAILY_LOG.md << 'EOF'
# APPGAMBIT AI — Daily Log

Append-only daily summaries.

---
EOF

# Create projects directory
mkdir -p projects

# Verify hook scripts are executable
chmod +x scripts/hooks/*.sh

echo "Runtime files created."
```

---

## Step 3: Verify Hook Scripts

The hook scripts block dangerous and interactive commands. Test them:

```bash
# Test dangerous command blocker
echo '{"tool_input":{"command":"rm -rf /"}}' | ./scripts/hooks/block-dangerous-commands.sh
echo "Exit code: $?"  # Should be 2 (blocked)

# Test safe command
echo '{"tool_input":{"command":"npm test"}}' | ./scripts/hooks/block-dangerous-commands.sh
echo "Exit code: $?"  # Should be 0 (allowed)

# Test interactive command blocker
echo '{"tool_input":{"command":"git add -i"}}' | ./scripts/hooks/block-interactive-commands.sh
echo "Exit code: $?"  # Should be 2 (blocked)
```

---

## Step 4: Verify Paths in Settings

The worker hooks settings.json references absolute paths. Verify they match your machine:

```bash
cat workers/hooks/settings.json | jq -r '.. | .command? // empty' | grep -v jq | grep -v cat
```

All paths should start with `/Users/dhaval/Documents/work/antigravity/ai-company/`. If you cloned to a different location, update the paths:

```bash
# Replace paths if needed (run from the repo root)
REPO_ROOT=$(pwd)
sed -i '' "s|/Users/dhaval/Documents/work/antigravity/ai-company|$REPO_ROOT|g" workers/hooks/settings.json
```

---

## Step 5: Commit Runtime Files

```bash
git add CEO_INBOX.md coordinator/REGISTRY.md coordinator/DAILY_LOG.md
git commit -m "bootstrap: initialize runtime files for first run"
git push
```

---

## Step 6: Start the Coordinator

Open a tmux session (so the Coordinator survives terminal closes):

```bash
tmux new-session -s coordinator
```

Inside tmux, start the Coordinator:

```bash
cd /Users/dhaval/Documents/work/antigravity/ai-company
claude --permission-mode acceptEdits
```

> **Note:** We use `acceptEdits` instead of `auto` because `auto` requires Team/Enterprise/API plan. On Pro plan, `acceptEdits` auto-approves file edits but prompts for bash commands. You can approve bash commands as they come up, or add specific allowlist rules.

Once the Coordinator session starts, it will read `coordinator/CLAUDE.md` automatically. Tell it:

```
You are APPGAMBIT AI Coordinator. Read coordinator/CLAUDE.md for your operating manual. 
Read coordinator/REGISTRY.md to check current state. Begin your coordination loop.
```

The Coordinator will start `/loop 5m coordinator-check-cycle`.

**Detach from tmux:** Press `Ctrl+B` then `D`. The Coordinator keeps running.
**Reattach later:** `tmux attach -t coordinator`

---

## Step 7: Onboard Your First Project

Talk to the Coordinator (in the tmux session or via Channel if configured):

```
New project: [your project brief here]
```

The Coordinator will:
1. Create `projects/{name}/` with all required files
2. Write BRIEF.md and draft PROJECT.md
3. Ask you clarifying questions (discovery phase)
4. Once you approve, activate the project and launch a worker

### What the Coordinator Does During Activation

1. Sets project status to ACTIVE in REGISTRY.md
2. Breaks Milestone 1 into 4-5 tasks in MILESTONES.md
3. Writes CLAUDE.md and MEMORY.md in your project's code repo
4. Writes the first task to COMM.md
5. Launches a worker: `claude -p "..." --permission-mode bypassPermissions --output-format json`
6. Records the session ID in REGISTRY.md
7. Confirms to you

---

## Step 8: Monitor Progress

**Check Coordinator status:**
```bash
tmux attach -t coordinator
```

**Check worker progress directly:**
```bash
cat projects/{project-name}/COMM.md | head -20
```

**Check CEO inbox:**
```bash
cat CEO_INBOX.md
```

**Check registry:**
```bash
cat coordinator/REGISTRY.md
```

---

## Single Account Considerations

Since Coordinator and Employee 1 share one Claude account:

1. **Shared rate limits.** The Coordinator's `/loop 5m` and worker's `claude -p` both consume tokens from the same account. You'll hit rate limits faster than with 3 separate accounts.

2. **Sequential, not parallel.** The Coordinator runs the loop, and when it launches a worker, the `claude -p` call blocks until the worker finishes (or the Coordinator can launch it in the background with `&`). With a single account, running both simultaneously is possible but will hit rate limits quickly.

3. **Workaround for rate limits:** If rate limits become a problem:
   - Increase the loop interval: `/loop 10m` instead of `/loop 5m`
   - Add cooldown between worker launches
   - Process one project fully before moving to the next

4. **Scaling up:** When ready, add a second Claude account ($100/month) for dedicated worker capacity. Update REGISTRY.md to show Employee 1 on Account 2.

---

## Onboarding a Second Project

Same process — talk to the Coordinator:

```
New project: [second project brief]
```

With 2 projects on round-robin, each gets checked every 10 minutes. Workers run sequentially (one finishes before the next starts) on a single account.

---

## Troubleshooting

### Coordinator not responding
```bash
tmux attach -t coordinator
# Check if the session is alive. If not:
cd /Users/dhaval/Documents/work/antigravity/ai-company
claude --permission-mode acceptEdits
# Tell it to read CLAUDE.md and resume
```

### Worker session seems stuck
```bash
# Check COMM.md for last update
cat projects/{project-name}/COMM.md | grep "Last worker update"
# If stale >30min, the Coordinator will detect this on its next round-robin pass
```

### Rate limit hit
Wait 30-60 minutes. Both Coordinator and worker will resume automatically. Check `coordinator/DAILY_LOG.md` for rate limit entries.

### Git conflicts
```bash
cd /Users/dhaval/Documents/work/antigravity/ai-company
git pull --rebase
# Resolve conflicts if any
git push
```

### Hook script not working
```bash
# Check it's executable
ls -la scripts/hooks/
# Test manually
echo '{"tool_input":{"command":"rm -rf /"}}' | ./scripts/hooks/block-dangerous-commands.sh
echo $?
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start Coordinator | `tmux new -s coordinator` then `claude --permission-mode acceptEdits` |
| Detach Coordinator | `Ctrl+B` then `D` |
| Reattach | `tmux attach -t coordinator` |
| Check CEO inbox | `cat CEO_INBOX.md` |
| Check registry | `cat coordinator/REGISTRY.md` |
| Check project status | `cat projects/{name}/COMM.md` |
| Check daily log | `cat coordinator/DAILY_LOG.md` |
| View git history | `git log --oneline -20` |

---

*Last updated: 2026-04-02*
