# APPGAMBIT AI Company — Claude Code Features Integration

> Spec amendment (v1.2) integrating native Claude Code CLI features to replace manual orchestration with platform-native capabilities.

---

## 1. Problem Statement

The v1.1 spec uses manual bash-scripted loops, Docker sandboxes, and file-only communication — all of which work, but Claude Code CLI natively provides scheduling (`/loop`), real-time messaging (Channels), programmatic execution (headless mode), deterministic automation (Hooks), and role-based autonomy (Permission Modes). Adopting these features simplifies the architecture, reduces custom scripting, and leverages battle-tested platform capabilities.

This amendment integrates 6 features:
1. `/loop` for the Coordinator's round-robin polling cycle
2. Channels for CEO real-time notifications
3. Headless mode (`-p`) for worker session launch
4. Hooks for deterministic worker guardrails
5. Permission modes tuned per role
6. Subagents for within-project parallelism

---

## 2. Coordinator Loop → `/loop` with Round-Robin

### 2.1 What Changes

The Coordinator's manually scripted standing loop (Section 2.2) is replaced by Claude Code's native `/loop` command.

### 2.2 How It Works

On startup, the Coordinator runs:

```
/loop 5m coordinator-check-cycle
```

Each iteration processes **one project** in round-robin order through active projects listed in REGISTRY.md.

### 2.3 Per-Iteration Steps

```
1. git pull (management repo)
2. Read REGISTRY.md → identify next project in rotation (by index)
3. Read COMM.md for that project
4. Process state change (same logic as v1.1 step 2a-i)
5. Update REGISTRY.md (project status + increment rotation index)
6. git push
```

### 2.4 Rotation Tracking

REGISTRY.md gains a new field:

```markdown
## Rotation
Next check index: 2
Last checked: client-xyz at 2026-04-02T14:30:00Z
```

The index increments after each iteration and wraps to 0 when it exceeds the number of active projects.

### 2.5 Interval Choice

5 minutes is the starting interval. With 6 active projects in round-robin, each project gets checked roughly every 30 minutes. This is acceptable for v1 — tasks take 30-60 minutes on average.

### 2.6 Session Scope

`/loop` is session-scoped — it stops when the Coordinator's Claude Code session exits. The Coordinator should run in a persistent terminal (tmux, screen, or a background process). For more durability, Desktop scheduled tasks or Cloud scheduled tasks can be considered as future upgrades.

---

## 3. CEO Communication → Channels

### 3.1 What Changes

CEO_INBOX.md remains the append-only historical log. Channels add a real-time notification layer so the CEO doesn't need to `git pull` to see updates.

### 3.2 How It Works

The Coordinator session starts with a channel enabled:

```bash
claude --channels plugin:telegram@claude-plugins-official --permission-mode auto
```

When the Coordinator writes to CEO_INBOX.md, it also sends a summary via the channel:

- Milestone complete → channel message with summary + "approve to continue"
- Escalation → channel message with options + recommendation
- Daily summary → channel message with highlights

### 3.3 CEO Replies

The CEO can reply from their phone. The message arrives in the Coordinator's session as a `<channel source="telegram">` event. The Coordinator processes the reply (e.g., milestone approval) and acts on it.

### 3.4 What Stays the Same

- CEO_INBOX.md is still written — it's the audit trail
- CEO can still use the live Claude Code session for complex discussions (discovery phase, multi-round planning)
- Channels are a convenience layer, not a replacement for Git-based protocol

### 3.5 Platform Options

- **Telegram** and **Discord** are available now via official plugins
- **Slack** integration is planned (channel tool already built) — will be integrated in a future version
- The spec describes the pattern generically; the CEO picks a platform during bootstrap

---

## 4. Worker Launch → Headless Mode (`-p`)

### 4.1 What Changes

Workers are launched as headless Claude Code CLI processes instead of Docker sandbox sessions. Docker becomes optional (for filesystem isolation) rather than required.

### 4.2 How Workers Are Launched

The Coordinator launches a worker by running:

```bash
cd /path/to/projects/client-xyz/code-repo

result=$(claude -p "You are Employee 1 assigned to client-xyz. \
  Read /path/to/ai-company/projects/client-xyz/COMM.md for your current task. \
  Read CLAUDE.md for project context. Begin work." \
  --permission-mode bypassPermissions \
  --settings /path/to/ai-company/workers/hooks/settings.json \
  --output-format json)

session_id=$(echo "$result" | jq -r '.session_id')
```

Each worker runs in its own project's code repo directory. No cross-project access.

### 4.3 Worker Identity in REGISTRY.md

REGISTRY.md tracks which worker account runs which session:

```markdown
### Employee 1 (Account 2)
| Slot | Project | Status | Current Task | Session ID |
|------|---------|--------|-------------|------------|
| 1 | client-xyz | IN_PROGRESS | Auth middleware | sess_abc123 |
| 2 | — | AVAILABLE | — | — |
| 3 | — | AVAILABLE | — | — |
```

Session ID replaces the sandbox name from v1.0. It enables `--resume` for crash recovery.

### 4.4 Crash Recovery

If a worker session dies (detected by Coordinator during its round-robin check):

```bash
claude -p "You are Employee 1 resuming work on client-xyz. \
  Read COMM.md for your current task status. Continue from where you left off." \
  --resume <session_id> \
  --permission-mode bypassPermissions \
  --output-format json
```

If `--resume` fails (session expired), the Coordinator launches a fresh session. The worker reads COMM.md and code repo state to pick up from the last git commit.

### 4.5 Context Preparation

Before launching a worker, the Coordinator prepares the full working context:

1. **CLAUDE.md** — written/updated in the project's code repo with:
   - Tech stack and conventions
   - Current milestone context
   - Acceptance criteria for the current task
   - Relevant code patterns and references
   - Links to management repo files (COMM.md, PROJECT.md)

2. **MEMORY.md** — written/updated with:
   - Decisions made during discovery phase
   - CEO preferences and constraints
   - Past revision feedback (what was rejected and why)
   - Architecture decisions and trade-offs

3. **Hooks settings** — `workers/hooks/settings.json` with guardrails (see Section 5)

The worker starts every session fully briefed. No context loss, even after crash/restart.

### 4.6 Docker Sandboxes (Optional)

Docker sandboxes are no longer required but remain an option for teams that want filesystem isolation. If used, the headless `claude -p` command runs inside the sandbox instead of directly on the host. The spec does not mandate either approach.

---

## 5. Hooks — Deterministic Worker Guardrails

### 5.1 What Changes

Instead of relying on LLM instructions (CLAUDE.md) to enforce worker behavior, Hooks provide deterministic enforcement that runs outside the model loop.

### 5.2 Hook Configuration Location

Worker hooks live in the management repo:

```
ai-company/
└── workers/
    └── hooks/
        └── settings.json       Worker hook configuration
```

Passed to workers at launch via `--settings workers/hooks/settings.json`.

### 5.3 Worker Hooks

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/ai-company/workers/hooks/block-dangerous-commands.sh",
            "if": "Bash(rm -rf *)"
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/ai-company/workers/hooks/block-interactive-commands.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' >> /tmp/claude-changed-files.txt"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "cat \"$CLAUDE_PROJECT_DIR\"/CLAUDE.md"
          }
        ]
      }
    ]
  }
}
```

### 5.4 Hook Descriptions

| Hook | Event | Matcher | Purpose |
|------|-------|---------|---------|
| Block dangerous commands | `PreToolUse` | `Bash` | Blocks `rm -rf /`, `git push --force`, `DROP TABLE`, other destructive operations. Exit code 2 to deny. |
| Block interactive commands | `PreToolUse` | `Bash` | Blocks commands requiring stdin input (`npm init` without `-y`, `git add -i`, `read`). Deterministic enforcement of v1.1's non-interactive rule. |
| Track file changes | `PostToolUse` | `Edit\|Write` | Logs changed file paths for the worker's commit summary. |
| Context recovery | `SessionStart` | `compact` | Re-injects project CLAUDE.md content after context compaction so workers don't lose project context mid-task. |

### 5.5 Coordinator Hooks (Separate)

The Coordinator has its own hooks in `coordinator/hooks/settings.json`:

| Hook | Event | Purpose |
|------|-------|---------|
| Notification | `Notification` | Desktop notification when Coordinator needs CEO input |
| Audit git operations | `PostToolUse` (matcher: `Bash`, if: `Bash(git *)`) | Log all git operations for audit trail |

---

## 6. Permission Modes Per Role

### 6.1 Mode Assignment

| Role | Permission Mode | Rationale |
|------|----------------|-----------|
| Coordinator | `auto` (preferred) or `acceptEdits` (fallback) | `auto` needs Team/Enterprise/API plan. If on Pro plan, use `acceptEdits` — Coordinator auto-accepts file edits but prompts for bash commands. Hooks provide additional guardrails. |
| Workers | `bypassPermissions` | Fully autonomous within their project directory. Hooks provide the guardrails instead of permission prompts. No human available to respond to prompts. |
| CEO session | `default` | Human reviews and approves everything. Full oversight. |

### 6.2 Launch Commands

```bash
# Coordinator
claude --permission-mode auto \
  --channels plugin:telegram@claude-plugins-official

# Worker (launched by Coordinator)
claude -p "..." \
  --permission-mode bypassPermissions \
  --settings /path/to/workers/hooks/settings.json \
  --output-format json

# CEO (interactive session)
claude  # default mode
```

### 6.3 Auto Mode for Coordinator

`auto` mode requires a Team, Enterprise, or API plan. If running on Pro plans:
- Use `acceptEdits` as fallback — auto-accepts file edits, prompts for bash commands
- Hooks provide additional guardrails regardless of permission mode

If `auto` mode is available:
- A background classifier reviews each action before execution
- Destructive operations (force push, mass deletion, production deploys) are blocked by default
- The Coordinator's CLAUDE.md and management repo are recognized as trusted
- If the classifier blocks 3 times in a row, auto mode pauses and prompts — the Coordinator runs in a persistent terminal, so the CEO can respond

---

## 7. Within-Project Parallelism → Subagents

### 7.1 What Changes

Workers can use subagents within their single session for parallel sub-tasks. This is native Claude Code behavior — no new infrastructure needed.

### 7.2 When to Use

Within a single task, if there are independent pieces of work:
- One subagent writes the API route, another writes the tests
- One subagent researches existing patterns, another scaffolds the component
- One subagent handles frontend, another handles backend for the same feature

### 7.3 Rules

- A worker does NOT spawn a second full session. One session per project.
- Subagents run inside the worker's session and share its context window
- Subagent results return as summaries to the worker's main context
- This is encouraged in the worker's CLAUDE.md but not enforced — the worker uses judgment on when parallelism helps

---

## 8. Updated Repo Structure

```
ai-company/
├── README.md
├── CEO_INBOX.md
│
├── coordinator/
│   ├── CLAUDE.md
│   ├── REGISTRY.md                  (now includes rotation index + session IDs)
│   ├── DAILY_LOG.md
│   └── hooks/
│       └── settings.json            Coordinator hook configuration
│
├── workers/
│   ├── employee-1/
│   │   └── CLAUDE.md
│   ├── employee-2/
│   │   └── CLAUDE.md
│   └── hooks/
│       ├── settings.json            Worker hook configuration
│       ├── block-dangerous-commands.sh
│       └── block-interactive-commands.sh
│
└── projects/
    └── client-xyz/
        ├── PROJECT.md
        ├── BRIEF.md
        ├── COMM.md
        ├── MILESTONES.md
        ├── MILESTONES_ARCHIVE.md
        └── REVIEW_LOG.md
```

---

## 9. Updated Bootstrap Steps

### Step 1: Accounts (unchanged)
3 Anthropic accounts with Pro plans.

### Step 2: Management Repo
- Initialize with directory structure from Section 8
- Write CLAUDE.md files for coordinator and workers
- Write hook scripts and settings.json files
- Configure channel plugin (Telegram or Discord)

### Step 3: Install Channel Plugin
```bash
# In Claude Code session
/plugin install telegram@claude-plugins-official
/telegram:configure <bot-token>
/telegram:access pair <code>
/telegram:access policy allowlist
```

### Step 4: First Run — Coordinator
```bash
claude --permission-mode auto \
  --channels plugin:telegram@claude-plugins-official
```

Coordinator reads `coordinator/CLAUDE.md`, starts `/loop 5m`, begins round-robin.

### Step 5: First Project
- CEO gives brief → discovery flow (unchanged from v1.1)
- On activation, Coordinator prepares worker context (CLAUDE.md, MEMORY.md in code repo)
- Coordinator launches worker via headless mode
- Verify the loop works end-to-end

### Step 6: Docker (Optional)
If filesystem isolation is desired, install Docker Desktop and wrap worker launches in Docker sandbox commands.

---

## 10. Summary of SPEC.md Changes

| Section | Change |
|---------|--------|
| 2.2 (Coordinator loop) | Replace manual loop with `/loop 5m` + round-robin |
| 2.2 (Coordinator responsibilities) | Add: prepare worker context (CLAUDE.md, MEMORY.md) before launch |
| 2.3 (Worker launch) | Replace Docker sandbox with `claude -p` headless mode |
| 3.2 (Docker Sandboxes) | Mark as optional, add headless mode as primary approach |
| 4 (Repo structure) | Add `workers/hooks/` and `coordinator/hooks/` directories |
| 5.2 (REGISTRY.md) | Add rotation index and session ID fields |
| 7.1 (New project onboarding) | Add context preparation step before worker launch |
| 8 (Edge cases) | Add Section 8.8: Worker Hook Guardrails |
| 9 (Bootstrap) | Update with channel plugin setup and headless mode |
| New section | Permission modes per role |
| New section | Within-project parallelism via subagents |

---

*Design version: 1.0*
*Date: 2026-04-02*
*Author: Dhaval Nagar + Claude (Claude Code features integration session)*
