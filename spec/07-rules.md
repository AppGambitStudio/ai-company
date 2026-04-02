# 7. Edge Cases & Rules

> Covers quality gates, conflict resolution, capacity limits, context handling, cooldown strategy, rolling window protocol, non-interactive execution, permission modes, CEO channels, subagent usage, and error recovery procedures.

---

## 7.1 Quality Gate

- Coordinator rejects max 2 times with REVISION_NEEDED
- On 3rd failure -> ESCALATED_TO_CEO with context:
  "Employee X failed task Y three times. Issue: [specific problem]. Worker may lack context or task may need re-scoping."

## 7.2 Conflict Resolution

- If both workers need to commit to management repo simultaneously, standard git conflict resolution applies
- Workers should pull before push, rebase if needed
- COMM.md files are per-project so conflicts are rare

## 7.3 Worker Capacity

- Each account supports max 3 concurrent headless sessions
- Coordinator never assigns more than 3 projects per worker
- If all slots full and new project arrives -> queue it in REGISTRY.md, notify CEO

## 7.4 Context Loss

- Worker sessions are ephemeral. Workers lose in-memory context on restart.
- All state is in Git. Worker reads COMM.md and code repo on every restart.
- Feature branches in code repo serve as work checkpoints.
- COMM.md worker notes serve as context breadcrumbs.

## 7.5 Cooldown Strategy

- After each feature/task completion, 30-60 minute cooldown before next heavy task
- Coordinator manages cooldown by delaying next task assignment
- During cooldown, worker session is not relaunched to avoid accidental usage

## 7.6 Rolling Window Protocol

Working files must stay small enough for AI agents to parse reliably within context windows.

**MILESTONES.md:**
- Holds at most 3-5 milestones at any time (current + upcoming)
- Each milestone contains ~4-5 tasks (guideline, not hard limit)
- Milestones beyond the visible window are not yet broken down — Coordinator plans them when they enter the window
- Deciding whether to split a large project into separate projects is a CEO decision

**COMM.md:**
- Scoped to the current task only — when Coordinator writes a new task, previous task content is replaced
- Fully resets when a new milestone begins (after CEO approval)
- Historical task details live in REVIEW_LOG.md and git history

**Milestone Archive Flow (triggered after CEO approves a completed milestone):**
1. Coordinator appends completed milestone to MILESTONES_ARCHIVE.md (with code repo commit hash and branch)
2. Coordinator removes completed milestone from MILESTONES.md
3. If next milestone not yet broken down, Coordinator plans it now
4. Coordinator resets COMM.md with first task of new milestone -> WAITING_FOR_WORKER
5. git commit + push

## 7.7 Non-Interactive Execution

Worker sessions run unattended. No human is available to provide stdin input.

**Rules:**
- All commands must use non-interactive flags (`-y`, `--yes`, `--non-interactive`)
- Git operations use token-based HTTPS URLs, not SSH
- Never run interactive commands (`git add -i`, `npm init` without `-y`, `read` prompts)
- If a command unexpectedly blocks for input: kill it, log in COMM.md, find non-interactive alternative
- If no non-interactive alternative exists: set COMM.md to BLOCKED with specifics

## 7.8 Permission Modes

Each role uses a different Claude Code permission mode:

| Role | Permission Mode | Rationale |
|------|----------------|-----------|
| Coordinator | `auto` (preferred) or `acceptEdits` (fallback) | `auto` requires Team/Enterprise/API plan. On Pro plan, use `acceptEdits` — auto-accepts file edits, prompts for bash commands. Hooks provide additional guardrails. |
| Workers | `bypassPermissions` | Fully autonomous within their project directory. Hooks provide guardrails instead of permission prompts. No human available to respond to prompts. |
| CEO session | `default` | Human reviews and approves everything. Full oversight. |

## 7.9 CEO Channels (Real-Time Notifications)

CEO_INBOX.md remains the append-only audit log. Channels add a real-time notification layer.

**Setup:** Coordinator session starts with `--channels plugin:telegram@claude-plugins-official` (or Discord).

**When the Coordinator writes to CEO_INBOX.md, it also sends a channel message:**
- Milestone complete -> summary + "approve to continue"
- Escalation -> options + recommendation
- Daily summary -> highlights

**CEO replies via channel** (phone) -> message arrives in Coordinator session as `<channel source="...">` event -> Coordinator processes the reply.

**Platform options:**
- Telegram and Discord available now via official plugins
- Slack integration planned (channel tool already built)
- CEO picks platform during bootstrap

**What stays the same:**
- CEO_INBOX.md is still written — it's the historical record
- CEO can still use live Claude Code session for complex discussions
- Channels are a convenience layer, not a replacement for Git-based protocol

## 7.10 Within-Project Parallelism (Subagents)

Workers can use subagents within their single session for parallel sub-tasks:
- One subagent writes the API route, another writes the tests
- One subagent researches existing patterns, another scaffolds the component

**Rules:**
- One session per project — workers do NOT spawn additional full sessions
- Subagents run inside the worker's session with isolated context
- Subagent results return as summaries to the worker's main context
- Encouraged in worker CLAUDE.md but not enforced — worker uses judgment

## 7.11 Error Recovery

Procedures for handling common failure scenarios across the system.

### Git push fails (conflict)

Worker pulls, rebases, retries. If rebase fails, set COMM.md to BLOCKED with details about the conflict. Coordinator resolves or reassigns.

### Worker code doesn't compile

Worker reads the error output, attempts a fix, and runs the build again. After 3 failed build attempts, Worker sets COMM.md to DONE_AWAITING_REVIEW with notes explaining the build failure and what was tried. Coordinator decides whether to provide guidance (REVISION_NEEDED) or escalate to CEO.

### Coordinator session crashes

CEO restarts the Coordinator in tmux. On restart, Coordinator reads REGISTRY.md and all active COMM.md files to rebuild its understanding of current state. The `/loop` restarts round-robin from index 0.

### Worker session crashes mid-task

Coordinator detects during round-robin check: COMM.md shows IN_PROGRESS but no update for >30 minutes. Coordinator attempts `--resume <session_id>`. If resume fails, Coordinator launches a fresh session. The new worker reads COMM.md and the code repo to continue from the last git commit.

### Rate limit on Coordinator

Coordinator sets a note in DAILY_LOG.md recording the rate limit event and expected cooldown time, then waits for cooldown to expire before resuming the loop.

### Git repo becomes corrupted

Worker clones a fresh copy of the code repo, checks out the feature branch, and continues from the last commit. If management repo is corrupted, Coordinator clones fresh and resumes from the latest commit state.
