---
name: error-recovery
description: Error recovery procedures for git failures, worker crashes, rate limits, and repeated failures. Use when encountering errors.
disable-model-invocation: false
---

# Error Recovery

## Git Push Fails
1. `git pull --rebase`
2. Resolve conflicts (prefer latest management state)
3. `git push`
4. If still fails, log in DAILY_LOG.md and retry next iteration

## Worker Session Dies
1. Detect via COMM.md staleness (IN_PROGRESS but no update >30min)
2. Attempt: `claude -p "Resume work" --resume <session_id>`
3. If fails: launch fresh session with RESUME prompt
4. Update session ID in REGISTRY.md
5. If fresh launch also fails: log in DAILY_LOG.md, retry next iteration

## Coordinator Session Crashes
CEO will restart. On restart:
1. Read CLAUDE.md (automatic)
2. Read REGISTRY.md to rebuild state
3. Read CEO_INBOX.md for pending responses
4. External loop script will send /check-cycle automatically

## Rate Limit Awareness
- Do NOT launch multiple workers back-to-back — space them out
- If rate limit hit: log in DAILY_LOG.md, pause pending worker tasks
- **80% rule:** At first sign of slowdowns, stop launching new workers
- **Shared account:** Worker `claude -p` calls draw from same quota

## Repeated Worker Failures (3x same task)
1. Set COMM.md to ESCALATED_TO_CEO
2. Write to CEO_INBOX.md: what failed, specific issue, re-scoping recommendation
3. Send channel notification
4. Wait for CEO decision
